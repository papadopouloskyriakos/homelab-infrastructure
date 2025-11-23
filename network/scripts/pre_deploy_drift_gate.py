#!/usr/bin/env python3
"""
Pre-Deployment Drift Gate
Blocks deployment if manual device changes haven't been synced to GitLab

This script fetches the LIVE device configuration and compares it with GitLab.
If the device has been manually modified, it creates a merge request and blocks
deployment until the drift is resolved.

Exit Codes:
  0 = No drift, safe to deploy
  1 = Error occurred
  2 = Drift detected, deployment blocked

Usage: pre_deploy_drift_gate.py <device_type> <device_name>
"""
import sys
import os
import re
import json
import subprocess
from pathlib import Path
from datetime import datetime
from netmiko import ConnectHandler

# Import the comprehensive dynamic content filter
sys.path.insert(0, os.path.dirname(__file__))
from filter_dynamic_content import DynamicContentFilter

class DriftGate:
    """Pre-deployment drift detection gate"""
    
    def __init__(self, device_type, device_name):
        self.device_type = device_type
        self.device_name = device_name
        self.filter = DynamicContentFilter()
    
    def fetch_live_config(self):
        """
        Fetch current running config from live device
        
        Returns:
            Config text as string
        """
        username = os.getenv('CISCO_USER', 'kyriakosp')
        password = os.getenv('CISCO_PASSWORD')
        
        if not password:
            raise Exception("CISCO_PASSWORD environment variable not set")
        
        # Map device types to Netmiko device types
        netmiko_type_map = {
            'Firewall': 'cisco_asa',
            'Router': 'cisco_ios',
            'Switch': 'cisco_ios',
            'Access-Point': 'cisco_ios',
        }
        
        device_type_netmiko = netmiko_type_map.get(self.device_type, 'cisco_ios')
        
        device_params = {
            'device_type': device_type_netmiko,
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
            print(f"   ERROR: Failed to connect: {str(e)}", file=sys.stderr)
            return None
    
    def load_gitlab_config(self):
        """
        Load configuration from GitLab repository
        
        Returns:
            Config text as string
        """
        # Try both old and new paths
        possible_paths = [
            Path(f"network/configs/{self.device_type}/{self.device_name}"),
            Path(f"network/oxidized/{self.device_type}/{self.device_name}"),
        ]
        
        for gitlab_path in possible_paths:
            if gitlab_path.exists():
                with open(gitlab_path) as f:
                    config = f.read()
                print(f"   Loaded GitLab config: {len(config)} bytes from {gitlab_path}", file=sys.stderr)
                return config
        
        print(f"   WARNING: GitLab config not found in any expected location", file=sys.stderr)
        return None
    
    def compare_configs(self, live_config, gitlab_config):
        """
        Compare live device config with GitLab config
        
        Handles differences between Oxidized backup format and direct device output.
        
        Returns:
            (has_drift, drift_lines_count, drift_diff)
        """
        # Use the filter's comprehensive comparison method
        # This handles both Oxidized normalization and dynamic content filtering
        are_equal, live_filtered, gitlab_filtered = self.filter.compare_configs(
            live_config, 
            gitlab_config
        )
        
        # Quick check
        if are_equal:
            return False, 0, None
        
        # Generate detailed diff
        import difflib
        
        live_lines = live_filtered.split('\n')
        gitlab_lines = gitlab_filtered.split('\n')
        
        diff = list(difflib.unified_diff(
            gitlab_lines,
            live_lines,
            fromfile='gitlab',
            tofile='device',
            lineterm=''
        ))
        
        if not diff:
            return False, 0, None
        
        # Count changes (exclude diff header lines)
        changes = [line for line in diff if line.startswith(('+', '-')) 
                   and not line.startswith(('+++', '---'))]
        total_changes = len(changes)
        
        if total_changes == 0:
            return False, 0, None
        
        return True, total_changes, diff
    
    def create_drift_merge_request(self, live_config, drift_diff, drift_lines_count):
        """
        Create GitLab merge request with device drift
        
        Returns:
            MR URL or None
        """
        gitlab_url = os.getenv('CI_SERVER_URL', 'https://gitlab.example.net')
        project_id = os.getenv('CI_PROJECT_ID')
        gitlab_token = os.getenv('GITLAB_TOKEN') or os.getenv('CI_JOB_TOKEN')
        
        if not gitlab_token:
            print("   WARNING: No GitLab token available, cannot create MR", file=sys.stderr)
            return None
        
        try:
            import requests
        except ImportError:
            print("   WARNING: requests library not available, cannot create MR", file=sys.stderr)
            return None
        
        # Create branch name
        timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
        branch_name = f"drift-detection/{self.device_name}-{timestamp}"
        
        print(f"   Creating drift sync branch: {branch_name}", file=sys.stderr)
        
        # Create branch
        api_url = f"{gitlab_url}/api/v4"
        headers = {'PRIVATE-TOKEN': gitlab_token}
        
        response = requests.post(
            f"{api_url}/projects/{project_id}/repository/branches",
            headers=headers,
            json={
                'branch': branch_name,
                'ref': 'main'
            }
        )
        
        if response.status_code not in [201, 409]:  # 409 = already exists
            print(f"   ERROR: Failed to create branch: {response.text}", file=sys.stderr)
            return None
        
        # Try both possible config paths
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
            print(f"   ERROR: Could not find config file in GitLab", file=sys.stderr)
            return None
        
        # Update file with live config
        response = requests.put(
            f"{api_url}/projects/{project_id}/repository/files/{gitlab_config_path.replace('/', '%2F')}",
            headers=headers,
            json={
                'branch': branch_name,
                'content': live_config,
                'commit_message': f"🔄 Sync device drift: {self.device_name}\n\nDetected {drift_lines_count} lines of drift from live device"
            }
        )
        
        if response.status_code not in [200, 201]:
            print(f"   ERROR: Failed to update file: {response.text}", file=sys.stderr)
            return None
        
        # Save diff as artifact
        diff_file = f"drift_{self.device_name}.diff"
        with open(diff_file, 'w') as f:
            f.write('\n'.join(drift_diff))
        
        # Create MR
        mr_title = f"🔄 Device Drift Sync: {self.device_name}"
        mr_description = f"""## Configuration Drift Detected

**Device:** `{self.device_name}` ({self.device_type})  
**Timestamp:** {datetime.now().isoformat()}  
**Drift:** {drift_lines_count} lines changed on device

### ⚠️ Deployment Blocked

The device has been manually modified and is out of sync with GitLab.  
This merge request contains the current device configuration.

### 📊 Changes Summary

The device configuration differs from GitLab by **{drift_lines_count} lines**.

### 🔍 Review Required

**Before merging:**
1. Review the diff to understand what changed on the device
2. Verify changes are intentional (not accidental)
3. Document why manual changes were necessary
4. Consider if changes should be kept or reverted

### 🚀 After Merging

1. The blocked pipeline will be able to proceed
2. Your GitLab change will be rebased on top of device changes
3. Run: `git pull --rebase origin main` then push again

### 📝 Drift Details

See artifact `{diff_file}` for full diff.

---
*Auto-generated by pre_deploy_drift_gate.py*  
*Filtering: Normalized Oxidized format differences and dynamic content*
"""
        
        response = requests.post(
            f"{api_url}/projects/{project_id}/merge_requests",
            headers=headers,
            json={
                'source_branch': branch_name,
                'target_branch': 'main',
                'title': mr_title,
                'description': mr_description,
                'REDACTED_dae379fc': True,
                'labels': ['drift-detection', 'automated']
            }
        )
        
        if response.status_code == 201:
            mr_data = response.json()
            mr_url = mr_data['web_url']
            print(f"   ✅ Created MR: {mr_url}", file=sys.stderr)
            return mr_url
        else:
            print(f"   ERROR: Failed to create MR: {response.text}", file=sys.stderr)
            return None
    
    def check_drift(self):
        """
        Main drift check function
        
        Returns:
            Exit code (0=no drift, 1=error, 2=drift detected)
        """
        print(f"\n{'='*60}", file=sys.stderr)
        print(f"DRIFT GATE: {self.device_name}", file=sys.stderr)
        print(f"{'='*60}", file=sys.stderr)
        
        # Step 1: Fetch live config
        print(f"\n[1/4] Fetching live device configuration...", file=sys.stderr)
        live_config = self.fetch_live_config()
        
        if not live_config:
            print(f"   ERROR: Could not fetch live config", file=sys.stderr)
            return 1
        
        # Step 2: Load GitLab config
        print(f"\n[2/4] Loading GitLab configuration...", file=sys.stderr)
        gitlab_config = self.load_gitlab_config()
        
        if not gitlab_config:
            print(f"   WARNING: No GitLab config exists", file=sys.stderr)
            print(f"   This appears to be a new device", file=sys.stderr)
            print(f"   Allowing deployment to proceed", file=sys.stderr)
            return 0
        
        # Step 3: Compare configs
        print(f"\n[3/4] Comparing configurations...", file=sys.stderr)
        print(f"   (Normalizing Oxidized format differences)", file=sys.stderr)
        has_drift, drift_lines_count, drift_diff = self.compare_configs(live_config, gitlab_config)
        
        if not has_drift:
            print(f"   ✅ No drift detected", file=sys.stderr)
            print(f"   Device and GitLab are in sync", file=sys.stderr)
            return 0
        
        print(f"   ⚠️  DRIFT DETECTED", file=sys.stderr)
        print(f"   {drift_lines_count} lines differ", file=sys.stderr)
        
        # Show preview of drift
        print(f"\n   Drift preview (first 20 lines):", file=sys.stderr)
        for i, line in enumerate(drift_diff[:20], 1):
            print(f"   {line}", file=sys.stderr)
        
        if len(drift_diff) > 20:
            print(f"   ... and {len(drift_diff) - 20} more lines", file=sys.stderr)
        
        # Step 4: Create MR
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
    """Main entry point"""
    if len(sys.argv) != 3:
        print("Usage: pre_deploy_drift_gate.py <device_type> <device_name>", file=sys.stderr)
        print("", file=sys.stderr)
        print("Example:", file=sys.stderr)
        print("  pre_deploy_drift_gate.py Router nl-lte01", file=sys.stderr)
        sys.exit(1)
    
    device_type = sys.argv[1]
    device_name = sys.argv[2]
    
    gate = DriftGate(device_type, device_name)
    exit_code = gate.check_drift()
    
    sys.exit(exit_code)

if __name__ == "__main__":
    main()