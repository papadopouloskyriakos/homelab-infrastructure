#!/usr/bin/env python3
"""
Pre-deployment drift detection gate.
Creates MR only when actual drift detected.
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
        print(f"Fetched {len(config)} bytes", file=sys.stderr)
        return config
    
    def load_gitlab_config(self):
        """Load GitLab config from BEFORE current commit"""
        import subprocess
        
        config_path = f"network/configs/{self.device_type}/{self.device_name}"
        
        # Use HEAD~1 to get version BEFORE user's commit
        # This compares: what was in GitLab before vs what's on device now
        baseline_ref = os.getenv('CI_COMMIT_BEFORE_SHA', 'HEAD~1')
        
        # Try git show with previous version
        try:
            result = subprocess.run(
                ['git', 'show', f'{baseline_ref}:{config_path}'],
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.returncode == 0 and result.stdout:
                print(f"Loaded GitLab config from {baseline_ref}:{config_path}", file=sys.stderr)
                return result.stdout, config_path
        except Exception:
            pass
        
        # Fallback to filesystem
        path = Path(config_path)
        if path.exists():
            with open(path) as f:
                config = f.read()
            print(f"Loaded GitLab config from filesystem", file=sys.stderr)
            return config, config_path
        
        return None, None
    
    def create_drift_mr(self, gitlab_path, gitlab_filtered, live_filtered):
        """Create MR with filtered configs on both sides"""
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
        
        # Commit 1: Filter baseline (removes headers from GitLab file)
        print(f"Commit 1: Filtering baseline...", file=sys.stderr)
        commit1_response = requests.post(
            f"{self.gitlab_url}/api/v4/projects/{self.project_id}/repository/commits",
            headers=headers,
            json={
                'branch': branch_name,
                'commit_message': f'[drift-sync] Filter baseline for {self.device_name}',
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
        
        # Commit 2: Write live config (shows actual drift)
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
        
        # Create MR
        print(f"Creating merge request...", file=sys.stderr)
        mr_response = requests.post(
            f"{self.gitlab_url}/api/v4/projects/{self.project_id}/merge_requests",
            headers=headers,
            json={
                'source_branch': branch_name,
                'target_branch': source_branch,
                'title': f'Drift: Sync {self.device_name} from device',
                'description': f'''Device has configuration changes not in GitLab.

Review changes and merge if device config is correct.
If GitLab is correct, close this MR and revert device changes.
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
        """Main drift detection workflow"""
        print(f"\nChecking drift: {self.device_name}", file=sys.stderr)
        
        try:
            live_config = self.fetch_live_config()
        except Exception as e:
            print(f"ERROR: Cannot fetch live config: {e}", file=sys.stderr)
            return 1
        
        gitlab_config, gitlab_path = self.load_gitlab_config()
        
        if not gitlab_config:
            print("No GitLab baseline (new device)", file=sys.stderr)
            return 0
        
        # Compare filtered configs
        print("Comparing configs...", file=sys.stderr)
        are_equal, live_filtered, gitlab_filtered = self.filter.compare_configs(
            live_config, gitlab_config
        )
        
        if are_equal:
            print("No drift detected", file=sys.stderr)
            return 0
        
        # Drift detected
        print("DRIFT DETECTED", file=sys.stderr)
        
        import difflib
        diff = list(difflib.unified_diff(
            gitlab_filtered.split('\n'),
            live_filtered.split('\n'),
            fromfile='GitLab',
            tofile='Device',
            lineterm=''
        ))
        
        changes = [line for line in diff if line.startswith(('+', '-')) 
                   and not line.startswith(('+++', '---'))]
        
        print(f"{len(changes)} lines differ", file=sys.stderr)
        
        # Show preview
        print("\nDrift preview:", file=sys.stderr)
        for line in diff[:20]:
            print(f"  {line}", file=sys.stderr)
        
        # Create MR
        if not self.gitlab_token or not self.project_id:
            print("ERROR: GitLab token not configured", file=sys.stderr)
            return 1
        
        try:
            mr_url = self.create_drift_mr(gitlab_path, gitlab_filtered, live_filtered)
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