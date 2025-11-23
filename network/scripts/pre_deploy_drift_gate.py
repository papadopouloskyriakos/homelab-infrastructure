#!/usr/bin/env python3
import sys
import os
import re
from pathlib import Path
from datetime import datetime
from netmiko import ConnectHandler

sys.path.insert(0, os.path.dirname(__file__))
from filter_dynamic_content import DynamicContentFilter

class DriftGate:
    def __init__(self, device_type, device_name):
        self.device_type = device_type
        self.device_name = device_name
        self.filter = DynamicContentFilter()
    
    def fetch_live_config(self):
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
        
        print(f"   Connecting to {self.device_name}...", file=sys.stderr)
        try:
            conn = ConnectHandler(**device_params)
            config = conn.send_command("show running-config", read_timeout=120)
            conn.disconnect()
            print(f"   Fetched {len(config)} bytes", file=sys.stderr)
            return config
        except Exception as e:
            print(f"   ERROR: {str(e)}", file=sys.stderr)
            return None
    
    def load_gitlab_config(self):
        """Load GitLab config from BEFORE current commit (baseline for drift detection)"""
        import subprocess
        
        possible_paths = [
            f"network/configs/{self.device_type}/{self.device_name}",
            f"network/oxidized/{self.device_type}/{self.device_name}",
        ]
        
        # Try to get file from parent commit (before current changes)
        commit_before = os.getenv('CI_COMMIT_BEFORE_SHA', 'HEAD~1')
        
        for path in possible_paths:
            try:
                # Try to get file from previous commit
                result = subprocess.run(
                    ['git', 'show', f'{commit_before}:{path}'],
                    capture_output=True,
                    text=True,
                    timeout=10
                )
                if result.returncode == 0 and result.stdout:
                    config = result.stdout
                    print(f"   Loaded GitLab baseline: {len(config)} bytes from {commit_before}:{path}", file=sys.stderr)
                    return config
            except Exception as e:
                continue
        
        # Fallback: check if file exists in working directory
        # This handles new devices that don't exist in previous commits
        for path_str in possible_paths:
            path = Path(path_str)
            if path.exists():
                with open(path) as f:
                    config = f.read()
                print(f"   Loaded GitLab config: {len(config)} bytes (new device)", file=sys.stderr)
                return config
        
        print(f"   WARNING: GitLab baseline not found", file=sys.stderr)
        return None
    
    def compare_configs(self, live_config, gitlab_config):
        are_equal, live_filtered, gitlab_filtered = self.filter.compare_configs(
            live_config, gitlab_config
        )
        
        if are_equal:
            return False, 0, None
        
        import difflib
        live_lines = live_filtered.split('\n')
        gitlab_lines = gitlab_filtered.split('\n')
        
        diff = list(difflib.unified_diff(
            gitlab_lines, live_lines,
            fromfile='gitlab', tofile='device',
            lineterm=''
        ))
        
        if not diff:
            return False, 0, None
        
        changes = [line for line in diff if line.startswith(('+', '-')) 
                   and not line.startswith(('+++', '---'))]
        total_changes = len(changes)
        
        if total_changes == 0:
            return False, 0, None
        
        return True, total_changes, diff
    
    def create_drift_merge_request(self, live_config, drift_diff, drift_lines_count):
        gitlab_url = os.getenv('CI_SERVER_URL', 'https://gitlab.example.net')
        project_id = os.getenv('CI_PROJECT_ID')
        gitlab_token = os.getenv('GITLAB_TOKEN') or os.getenv('CI_JOB_TOKEN')
        
        if not gitlab_token:
            print("   WARNING: No GitLab token, cannot create MR", file=sys.stderr)
            return None
        
        try:
            import requests
        except ImportError:
            print("   WARNING: requests not available", file=sys.stderr)
            return None
        
        timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
        branch_name = f"drift-detection/{self.device_name}-{timestamp}"
        
        print(f"   Creating drift sync branch: {branch_name}", file=sys.stderr)
        
        api_url = f"{gitlab_url}/api/v4"
        headers = {'PRIVATE-TOKEN': gitlab_token}
        
        response = requests.post(
            f"{api_url}/projects/{project_id}/repository/branches",
            headers=headers,
            json={'branch': branch_name, 'ref': 'main'}
        )
        
        if response.status_code not in [201, 409]:
            print(f"   ERROR: Failed to create branch: {response.text}", file=sys.stderr)
            return None
        
        config_paths = [
            f"network/configs/{self.device_type}/{self.device_name}",
            f"network/oxidized/{self.device_type}/{self.device_name}",
        ]
        
        gitlab_config_path = None
        for path in config_paths:
            response = requests.get(
                f"{api_url}/projects/{project_id}/repository/files/{path.replace('/', '%2F')}",
                headers=headers,
                params={'ref': 'main'}
            )
            if response.status_code == 200:
                gitlab_config_path = path
                break
        
        if not gitlab_config_path:
            print(f"   ERROR: Could not find config in GitLab", file=sys.stderr)
            return None
        
        response = requests.put(
            f"{api_url}/projects/{project_id}/repository/files/{gitlab_config_path.replace('/', '%2F')}",
            headers=headers,
            json={
                'branch': branch_name,
                'content': live_config,
                'commit_message': f"🔄 Sync device drift: {self.device_name}\n\nDetected {drift_lines_count} lines of drift"
            }
        )
        
        if response.status_code not in [200, 201]:
            print(f"   ERROR: Failed to update file: {response.text}", file=sys.stderr)
            return None
        
        diff_file = f"drift_{self.device_name}.diff"
        with open(diff_file, 'w') as f:
            f.write('\n'.join(drift_diff))
        
        mr_description = f"""## Configuration Drift Detected

**Device:** `{self.device_name}` ({self.device_type})  
**Drift:** {drift_lines_count} lines changed

### Next Steps
1. Review this MR to see what changed on the device
2. Merge this MR to sync device state to GitLab
3. Rebase your original change: `git pull --rebase origin main && git push`
4. Pipeline will automatically retry

See artifact `{diff_file}` for full diff.
"""
        
        response = requests.post(
            f"{api_url}/projects/{project_id}/merge_requests",
            headers=headers,
            json={
                'source_branch': branch_name,
                'target_branch': 'main',
                'title': f"🔄 Device Drift Sync: {self.device_name}",
                'description': mr_description,
                'REDACTED_dae379fc': True,
                'labels': ['drift-detection', 'automated']
            }
        )
        
        if response.status_code == 201:
            mr_url = response.json()['web_url']
            print(f"   ✅ Created MR: {mr_url}", file=sys.stderr)
            return mr_url
        else:
            print(f"   ERROR: Failed to create MR: {response.text}", file=sys.stderr)
            return None
    
    def check_drift(self):
        print(f"\n{'='*60}", file=sys.stderr)
        print(f"DRIFT GATE: {self.device_name}", file=sys.stderr)
        print(f"{'='*60}", file=sys.stderr)
        
        print(f"\n[1/4] Fetching live device configuration...", file=sys.stderr)
        live_config = self.fetch_live_config()
        if not live_config:
            print(f"   ERROR: Could not fetch live config", file=sys.stderr)
            return 1
        
        print(f"\n[2/4] Loading GitLab configuration...", file=sys.stderr)
        gitlab_config = self.load_gitlab_config()
        if not gitlab_config:
            print(f"   WARNING: No GitLab config, allowing deployment", file=sys.stderr)
            return 0
        
        print(f"\n[3/4] Comparing configurations...", file=sys.stderr)
        print(f"   (Normalizing Oxidized format differences)", file=sys.stderr)
        has_drift, drift_lines_count, drift_diff = self.compare_configs(live_config, gitlab_config)
        
        if not has_drift:
            print(f"   ✅ No drift detected", file=sys.stderr)
            return 0
        
        print(f"   ⚠️  DRIFT DETECTED", file=sys.stderr)
        print(f"   {drift_lines_count} lines differ", file=sys.stderr)
        print(f"\n   Drift preview (first 20 lines):", file=sys.stderr)
        for line in drift_diff[:20]:
            print(f"   {line}", file=sys.stderr)
        
        print(f"\n[4/4] Creating drift sync merge request...", file=sys.stderr)
        mr_url = self.create_drift_merge_request(live_config, drift_diff, drift_lines_count)
        
        print(f"\n{'='*60}", file=sys.stderr)
        print(f"RESULT: DRIFT DETECTED - DEPLOYMENT BLOCKED", file=sys.stderr)
        print(f"{'='*60}", file=sys.stderr)
        
        if mr_url:
            print(f"\n📋 Merge Request: {mr_url}", file=sys.stderr)
        
        print(f"\n⚠️  This deployment cannot proceed until drift is resolved", file=sys.stderr)
        print(f"\nNext steps:", file=sys.stderr)
        print(f"  1. Review the drift detection MR", file=sys.stderr)
        print(f"  2. Merge the MR to sync device changes to GitLab", file=sys.stderr)
        print(f"  3. Rebase your commit:", file=sys.stderr)
        print(f"     git pull --rebase origin main && git push", file=sys.stderr)
        print(f"  4. Pipeline will automatically retry", file=sys.stderr)
        
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