#!/usr/bin/env python3
"""
Pre-deployment drift detection gate with commit history awareness.
Compares device against HEAD and HEAD^ to distinguish:
- Pending deletions (was in HEAD^, removed in HEAD) → ALLOW
- True drift (never in GitLab) → BLOCK

Exit codes: 0=no drift, 2=drift+MR created, 1=error
"""
import sys
import os
import requests
from pathlib import Path
from netmiko import ConnectHandler
import subprocess

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
        self.config_path = f"network/configs/{self.device_type}/{self.device_name}"
        
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
    
    def get_git_config(self, ref):
        """Get config from a git reference (HEAD, HEAD^, etc)"""
        try:
            result = subprocess.run(
                ['git', 'show', f'{ref}:{self.config_path}'],
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.returncode == 0 and result.stdout:
                return result.stdout
        except Exception as e:
            print(f"WARNING: git show {ref} failed: {e}", file=sys.stderr)
        
        return None
    
    def load_current_and_previous_configs(self):
        """Load both HEAD and HEAD^ configs"""
        print(f"Loading HEAD config...", file=sys.stderr)
        head_config = self.get_git_config('HEAD')
        
        if not head_config:
            # Fallback to filesystem for HEAD
            path = Path(self.config_path)
            if path.exists():
                with open(path) as f:
                    head_config = f.read()
                print(f"Loaded HEAD from filesystem", file=sys.stderr)
            else:
                print(f"ERROR: Cannot load HEAD config", file=sys.stderr)
                return None, None
        else:
            print(f"Loaded HEAD config: {len(head_config)} bytes", file=sys.stderr)
        
        print(f"Loading HEAD^ (previous commit) config...", file=sys.stderr)
        previous_config = self.get_git_config('HEAD^')
        
        if previous_config:
            print(f"Loaded HEAD^ config: {len(previous_config)} bytes", file=sys.stderr)
        else:
            print(f"WARNING: No HEAD^ found (might be first commit)", file=sys.stderr)
            print(f"Will treat all device additions as drift", file=sys.stderr)
        
        return head_config, previous_config
    
    def create_drift_mr(self, device_additions, live_filtered, head_filtered):
        """Create MR with filtered configs showing true drift"""
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
        
        # Commit 1: Filter HEAD baseline
        print(f"Commit 1: Filtering HEAD baseline...", file=sys.stderr)
        commit1_response = requests.post(
            f"{self.gitlab_url}/api/v4/projects/{self.project_id}/repository/commits",
            headers=headers,
            json={
                'branch': branch_name,
                'commit_message': f'[drift-sync] Filter HEAD baseline for {self.device_name}',
                'actions': [{
                    'action': 'update',
                    'file_path': self.config_path,
                    'content': head_filtered
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
                    'file_path': self.config_path,
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
                'title': f'Drift: {self.device_name} has unreported manual changes',
                'description': f'''Device has **{len(device_additions)} line(s) that were never in GitLab**.

These are manual SSH changes that were never committed to GitLab.

### True Drift (Manual SSH Additions):
```
{additions_preview}
```

### How this was detected:
- Compared device vs HEAD (current commit)
- Compared device vs HEAD^ (previous commit)
- These lines exist on device but were NEVER in GitLab history
- Therefore: Manual SSH changes (true drift)

### What to do:
- **If changes are correct**: Merge this MR to add them to GitLab
- **If changes are unwanted**: Close MR and remove them via SSH

### Note:
Lines removed in your current commit (pending deletions) were correctly ignored.
Only NEW additions that were never in GitLab are flagged as drift.
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
        """Main drift detection with commit history awareness"""
        print(f"\nDrift gate: {self.device_name}", file=sys.stderr)
        print("Checking for TRUE drift (manual SSH changes)", file=sys.stderr)
        print("Comparing: Device vs HEAD vs HEAD^", file=sys.stderr)
        
        # Fetch device config
        try:
            live_config = self.fetch_live_config()
        except Exception as e:
            print(f"ERROR: Cannot fetch live config: {e}", file=sys.stderr)
            return 1
        
        # Load current and previous GitLab configs
        head_config, previous_config = self.load_current_and_previous_configs()
        
        if not head_config:
            print("ERROR: Cannot load HEAD config", file=sys.stderr)
            return 1
        
        # Filter all configs
        print("Filtering configs...", file=sys.stderr)
        _, live_filtered, head_filtered = self.filter.compare_configs(
            live_config, head_config
        )
        
        # Convert to line sets
        device_lines = set(line.strip() for line in live_filtered.split('\n') if line.strip())
        head_lines = set(line.strip() for line in head_filtered.split('\n') if line.strip())
        
        # Lines on device but not in HEAD
        device_not_in_head = device_lines - head_lines
        
        if not device_not_in_head:
            print("\nNo drift detected - device matches HEAD", file=sys.stderr)
            return 0
        
        print(f"\nDevice has {len(device_not_in_head)} line(s) not in HEAD", file=sys.stderr)
        print("Analyzing commit history to distinguish drift vs deletions...", file=sys.stderr)
        
        # Determine which lines are TRUE DRIFT
        true_drift = set()
        pending_deletions = set()
        
        if previous_config:
            # Filter previous config
            _, previous_filtered, _ = self.filter.compare_configs(
                previous_config, head_config
            )
            previous_lines = set(line.strip() for line in previous_filtered.split('\n') if line.strip())
            
            for line in device_not_in_head:
                if line in previous_lines:
                    # Line was in HEAD^ (previous commit) → Pending deletion
                    pending_deletions.add(line)
                else:
                    # Line was NOT in HEAD^ → True drift (manual addition)
                    true_drift.add(line)
        else:
            # No previous commit - treat all as drift
            true_drift = device_not_in_head
        
        # Show analysis
        print(f"\nAnalysis:", file=sys.stderr)
        print(f"  Pending deletions (was in HEAD^, removed in HEAD): {len(pending_deletions)} lines", file=sys.stderr)
        print(f"  True drift (never in GitLab history): {len(true_drift)} lines", file=sys.stderr)
        
        if pending_deletions:
            print(f"\nPending deletions (will be removed on deployment):", file=sys.stderr)
            for line in list(pending_deletions)[:5]:
                print(f"  - {line[:80]}", file=sys.stderr)
            if len(pending_deletions) > 5:
                print(f"  ... and {len(pending_deletions) - 5} more", file=sys.stderr)
        
        if not true_drift:
            print("\nNo true drift detected - device has no unreported additions", file=sys.stderr)
            print("Deployment can proceed (will apply pending deletions)", file=sys.stderr)
            return 0
        
        # TRUE DRIFT DETECTED
        print(f"\nTRUE DRIFT DETECTED - device has {len(true_drift)} manual SSH additions", file=sys.stderr)
        
        print("\nManual SSH additions (never in GitLab):", file=sys.stderr)
        for line in list(true_drift)[:10]:
            print(f"  + {line[:80]}", file=sys.stderr)
        
        if len(true_drift) > 10:
            print(f"  ... and {len(true_drift) - 10} more lines", file=sys.stderr)
        
        # Create MR
        if not self.gitlab_token or not self.project_id:
            print("ERROR: GitLab token not configured", file=sys.stderr)
            return 1
        
        try:
            mr_url = self.create_drift_mr(true_drift, live_filtered, head_filtered)
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