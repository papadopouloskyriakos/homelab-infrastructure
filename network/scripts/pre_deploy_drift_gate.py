#!/usr/bin/env python3
"""
Pre-deployment drift detection gate.
Compares device against HEAD (current GitLab state).
Only flags ADDITIONS on device (true drift from SSH changes).
Ignores deletions (pending deployments from GitLab).
Exit codes: 0=no drift, 2=drift+MR created, 1=error
"""
import sys
import os
import requests
from pathlib import Path
from netmiko import ConnectHandler

sys.path.insert(0, os.path.dirname(__file__))
from filter_dynamic_content import DynamicContentFilter

class DriftGate:
    def __init__(self, device_type, device_name):
        self.device_type = device_type
        self.device_name = device_name
        self.filter = DynamicContentFilter()
        self.gitlab_url = os.getenv('CI_SERVER_URL', 'https://gitlab.example.net')
        self.project_id = os.getenv('CI_PROJECT_ID')
        self.gitlab_token = os.getenv('GITLAB_TOKEN') or os.getenv('GITLAB_PUSH_TOKEN')
        
    def fetch_live_config(self):
        """Fetch running config from device"""
        username = os.getenv('CISCO_USER', 'kyriakosp')
        password = os.getenv('CISCO_PASSWORD')
        if not password:
            raise Exception("CISCO_PASSWORD not set")
        
        netmiko_type_map = {
            'Firewall': 'cisco_asa',
            'Router': 'cisco_ios',
            'Switch': 'cisco_ios',
            'Access-Point': 'cisco_ios',
        }
        
        device_params = {
            'device_type': netmiko_type_map.get(self.device_type, 'cisco_ios'),
            'host': f"{self.device_name}.example.net",
            'username': username,
            'password': password,
            'timeout': 120,
            'fast_cli': False,
        }
        
        print(f"Fetching live config from {self.device_name}...", file=sys.stderr)
        conn = ConnectHandler(**device_params)
        config = conn.send_command("show running-config", read_timeout=120)
        conn.disconnect()
        print(f"Fetched {len(config)} bytes from device", file=sys.stderr)
        return config
    
    def load_gitlab_config(self):
        """Load GitLab config from HEAD (current state)"""
        import subprocess
        
        config_path = f"network/configs/{self.device_type}/{self.device_name}"
        
        print(f"Using baseline: HEAD (current GitLab state)", file=sys.stderr)
        
        # Try git show HEAD
        try:
            result = subprocess.run(
                ['git', 'show', f'HEAD:{config_path}'],
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.returncode == 0 and result.stdout:
                print(f"Loaded HEAD config: {config_path}", file=sys.stderr)
                print(f"HEAD config size: {len(result.stdout)} bytes", file=sys.stderr)
                return result.stdout, config_path
        except Exception as e:
            print(f"ERROR: git show failed: {e}", file=sys.stderr)
        
        # Fallback to filesystem
        path = Path(config_path)
        if path.exists():
            with open(path) as f:
                config = f.read()
            print(f"Loaded from filesystem (fallback)", file=sys.stderr)
            return config, config_path
        
        return None, None
    
    def create_drift_mr(self, gitlab_path, gitlab_filtered, live_filtered, device_additions):
        """Create MR with filtered configs showing device additions"""
        branch_name = f"drift-sync-{self.device_name}"
        source_branch = os.getenv('CI_COMMIT_REF_NAME', 'main')
        
        headers = {
            'PRIVATE-TOKEN': self.gitlab_token,
            'Content-Type': 'application/json'
        }
        
        # Delete existing branch if exists
        try:
            requests.delete(
                f"{self.gitlab_url}/api/v4/projects/{self.project_id}/repository/branches/{branch_name}",
                headers=headers,
                timeout=10
            )
        except:
            pass
        
        # Create branch from HEAD
        print(f"Creating branch {branch_name}...", file=sys.stderr)
        create_response = requests.post(
            f"{self.gitlab_url}/api/v4/projects/{self.project_id}/repository/branches",
            headers=headers,
            json={'branch': branch_name, 'ref': source_branch},
            timeout=10
        )
        
        if create_response.status_code not in [200, 201]:
            raise Exception(f"Failed to create branch: {create_response.text}")
        
        # Commit 1: Filter baseline (HEAD)
        print(f"Commit 1: Filtering HEAD baseline...", file=sys.stderr)
        commit1_response = requests.post(
            f"{self.gitlab_url}/api/v4/projects/{self.project_id}/repository/commits",
            headers=headers,
            json={
                'branch': branch_name,
                'commit_message': f'[drift-sync] Filter HEAD baseline for {self.device_name}',
                'actions': [{
                    'action': 'update',
                    'file_path': gitlab_path,
                    'content': gitlab_filtered
                }]
            },
            timeout=10
        )
        
        if commit1_response.status_code not in [200, 201]:
            raise Exception(f"Commit 1 failed: {commit1_response.text}")
        
        # Commit 2: Write live config
        print(f"Commit 2: Writing device config...", file=sys.stderr)
        commit2_response = requests.post(
            f"{self.gitlab_url}/api/v4/projects/{self.project_id}/repository/commits",
            headers=headers,
            json={
                'branch': branch_name,
                'commit_message': f'[drift-sync] Sync {self.device_name} from device',
                'actions': [{
                    'action': 'update',
                    'file_path': gitlab_path,
                    'content': live_filtered
                }]
            },
            timeout=10
        )
        
        if commit2_response.status_code not in [200, 201]:
            raise Exception(f"Commit 2 failed: {commit2_response.text}")
        
        # Create MR with detailed description
        additions_preview = '\n'.join(f"  + {line}" for line in list(device_additions)[:20])
        if len(device_additions) > 20:
            additions_preview += f"\n  ... and {len(device_additions) - 20} more lines"
        
        print(f"Creating merge request...", file=sys.stderr)
        mr_response = requests.post(
            f"{self.gitlab_url}/api/v4/projects/{self.project_id}/merge_requests",
            headers=headers,
            json={
                'source_branch': branch_name,
                'target_branch': source_branch,
                'title': f'Drift: Sync {self.device_name} from device',
                'description': f'''Device has unreported SSH configuration changes.

**Device has {len(device_additions)} line(s) NOT in GitLab HEAD.**

These are manual changes made directly on the device via SSH.

### Device Additions Preview:
```
{additions_preview}
```

### What to do:
- **If changes are correct**: Merge this MR to sync device state to GitLab
- **If changes are unwanted**: Close MR and remove them via SSH

### Note:
This drift gate only flags ADDITIONS on the device.
Lines missing from device (pending GitLab deployments) are ignored.
''',
                'REDACTED_dae379fc': True
            },
            timeout=10
        )
        
        if mr_response.status_code not in [200, 201]:
            raise Exception(f"Failed to create MR: {mr_response.text}")
        
        mr_url = mr_response.json().get('web_url')
        print(f"\nMR created: {mr_url}", file=sys.stderr)
        return mr_url
    
    def check_drift(self):
        """Main drift detection workflow - only flags device additions"""
        print(f"\nDrift gate: {self.device_name}", file=sys.stderr)
        print("Comparing device to HEAD (current GitLab state)", file=sys.stderr)
        print("Only flagging ADDITIONS on device (true drift)", file=sys.stderr)
        
        try:
            live_config = self.fetch_live_config()
        except Exception as e:
            print(f"ERROR: Cannot fetch live config: {e}", file=sys.stderr)
            return 1
        
        gitlab_config, gitlab_path = self.load_gitlab_config()
        
        if not gitlab_config:
            print("No GitLab config found (new device)", file=sys.stderr)
            return 0
        
        # Filter both configs
        print("Filtering configs...", file=sys.stderr)
        _, live_filtered, gitlab_filtered = self.filter.compare_configs(
            live_config, gitlab_config
        )
        
        # Convert to line sets for comparison
        live_lines = set(line.strip() for line in live_filtered.split('\n') if line.strip())
        gitlab_lines = set(line.strip() for line in gitlab_filtered.split('\n') if line.strip())
        
        # Check for device additions (device has lines NOT in GitLab)
        device_additions = live_lines - gitlab_lines
        
        # Check for device deletions (GitLab has lines NOT on device)
        # These are OK - they're pending deployments
        device_deletions = gitlab_lines - live_lines
        
        print(f"Analysis:", file=sys.stderr)
        print(f"  Device additions (drift): {len(device_additions)} lines", file=sys.stderr)
        print(f"  Device deletions (pending deploy): {len(device_deletions)} lines", file=sys.stderr)
        
        if not device_additions:
            print("\nNo drift detected - device has no unreported additions", file=sys.stderr)
            if device_deletions:
                print(f"Device is missing {len(device_deletions)} lines (will be deployed)", file=sys.stderr)
            return 0
        
        # TRUE DRIFT - device has additions
        print(f"\nDRIFT DETECTED - device has {len(device_additions)} unreported additions", file=sys.stderr)
        
        # Show preview of additions
        print("\nDevice additions preview:", file=sys.stderr)
        for i, line in enumerate(list(device_additions)[:10], 1):
            print(f"  + {line[:80]}", file=sys.stderr)
        
        if len(device_additions) > 10:
            print(f"  ... and {len(device_additions) - 10} more lines", file=sys.stderr)
        
        # Create MR
        if not self.gitlab_token or not self.project_id:
            print("ERROR: GitLab token not configured", file=sys.stderr)
            return 1
        
        try:
            mr_url = self.create_drift_mr(gitlab_path, gitlab_filtered, live_filtered, device_additions)
            print(f"\nDeployment blocked - review MR: {mr_url}", file=sys.stderr)
        except Exception as e:
            print(f"ERROR: MR creation failed: {e}", file=sys.stderr)
            return 1
        
        return 2

def main():
    if len(sys.argv) != 3:
        print("Usage: pre_deploy_drift_gate.py <device_type> <device_name>", file=sys.stderr)
        sys.exit(1)
    
    device_type = sys.argv[1]
    device_name = sys.argv[2]
    
    gate = DriftGate(device_type, device_name)
    exit_code = gate.check_drift()
    sys.exit(exit_code)

if __name__ == "__main__":
    main()