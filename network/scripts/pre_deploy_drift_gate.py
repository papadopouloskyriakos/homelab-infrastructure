#!/usr/bin/env python3
"""
Pre-Deploy Drift Gate - Block deployment if device has unreported changes

This script runs BEFORE deployment to ensure the device hasn't been manually
modified via SSH or GUI. If drift is detected, it:
1. Blocks the pipeline (fails with exit code 1)
2. Creates a merge request with the device changes
3. Provides clear instructions for the user

Usage: pre_deploy_drift_gate.py

Environment Variables Required:
- CISCO_USER, CISCO_PASSWORD: Device credentials
- CI_PROJECT_ID: GitLab project ID
- GITLAB_TOKEN: GitLab API token
- CI_SERVER_URL: GitLab instance URL
- CI_COMMIT_SHA: Current commit SHA
- CI_COMMIT_AUTHOR_NAME: Author of the commit being deployed
"""
import sys
import os
import re
import subprocess
from pathlib import Path
from datetime import datetime
from netmiko import ConnectHandler

# Try importing requests, provide helpful error if missing
try:
    import requests
except ImportError:
    print("ERROR: requests library not installed")
    print("Install with: pip install requests")
    sys.exit(1)


class DriftGate:
    """Pre-deployment drift detection and MR creation"""
    
    def __init__(self):
        self.drift_found = False
        self.drifted_devices = []
        
        # GitLab API setup
        self.gitlab_url = os.getenv('CI_SERVER_URL', 'https://gitlab.example.net')
        self.project_id = os.getenv('CI_PROJECT_ID')
        self.gitlab_token = os.getenv('GITLAB_TOKEN')
        self.commit_sha = os.getenv('CI_COMMIT_SHA', 'HEAD')
        self.commit_author = os.getenv('CI_COMMIT_AUTHOR_NAME', 'Unknown')
        
        if not self.gitlab_token:
            print("⚠️  WARNING: GITLAB_TOKEN not set - cannot create MR")
            self.can_create_mr = False
        else:
            self.can_create_mr = True
    
    def normalize_config(self, config):
        """Remove dynamic content for comparison"""
        lines = []
        
        dynamic_patterns = [
            'Last configuration change at',
            'NVRAM config last updated at',
            'Cryptochecksum:',
            'ntp clock-period',
            'uptime is',
            'Configuration last modified by',
            'building configuration',
            'Current configuration :',
            'No configuration change since last restart',
        ]
        
        for line in config.split('\n'):
            # Skip dynamic content
            if any(pattern in line for pattern in dynamic_patterns):
                continue
            
            # Skip empty lines and pure comments
            if not line.strip() or line.strip() == '!':
                continue
            
            lines.append(line.rstrip())
        
        return '\n'.join(lines)
    
    def fetch_device_config(self, device_type, device_name):
        """Fetch running config from device"""
        username = os.getenv('CISCO_USER', 'kyriakosp')
        password = os.getenv('CISCO_PASSWORD')
        
        if not password:
            raise Exception("CISCO_PASSWORD environment variable not set")
        
        netmiko_type_map = {
            'Firewall': 'cisco_asa',
            'Router': 'cisco_ios',
            'Switch': 'cisco_ios',
            'Access-Point': 'cisco_ios',
        }
        
        device_type_netmiko = netmiko_type_map.get(device_type, 'cisco_ios')
        
        device_params = {
            'device_type': device_type_netmiko,
            'host': f"{device_name}.example.net",
            'username': username,
            'password': password,
            'timeout': 120,
            'fast_cli': False,
        }
        
        conn = ConnectHandler(**device_params)
        config = conn.send_command("show running-config", read_timeout=120)
        conn.disconnect()
        
        return config
    
    def load_gitlab_config(self, device_type, device_name):
        """Load config from GitLab"""
        gitlab_path = Path(f"network/configs/{device_type}/{device_name}")
        
        if not gitlab_path.exists():
            return None
        
        with open(gitlab_path) as f:
            return f.read()
    
    def check_device_for_drift(self, device_type, device_name):
        """
        Check single device for drift
        
        Returns:
            (has_drift, additions, deletions, device_config)
        """
        try:
            # Fetch device config
            device_config = self.fetch_device_config(device_type, device_name)
            
            # Load GitLab config
            gitlab_config = self.load_gitlab_config(device_type, device_name)
            
            if not gitlab_config:
                # No GitLab config - skip (might be new device being added)
                return False, 0, 0, None
            
            # Normalize both configs
            device_normalized = self.normalize_config(device_config)
            gitlab_normalized = self.normalize_config(gitlab_config)
            
            # Compare
            if device_normalized == gitlab_normalized:
                return False, 0, 0, None
            
            # Calculate diff size
            device_lines = set(device_normalized.split('\n'))
            gitlab_lines = set(gitlab_normalized.split('\n'))
            
            additions = len(device_lines - gitlab_lines)
            deletions = len(gitlab_lines - device_lines)
            
            return True, additions, deletions, device_config
        
        except Exception as e:
            print(f"⚠️  WARNING: Could not check {device_name}: {str(e)}")
            return False, 0, 0, None
    
    def get_changed_devices_from_commit(self):
        """
        Get list of devices that were modified in the current commit
        
        Returns:
            List of (device_type, device_name) tuples
        """
        try:
            # Get files changed in current commit
            result = subprocess.run(
                ['git', 'diff', '--name-only', 'HEAD~1', 'HEAD'],
                capture_output=True,
                text=True,
                check=True
            )
            
            changed_files = result.stdout.strip().split('\n')
            
            devices = []
            pattern = re.compile(r'^network/configs/([^/]+)/(.+)$')
            
            for file_path in changed_files:
                match = pattern.match(file_path)
                if match:
                    device_type = match.group(1)
                    device_name = match.group(2)
                    
                    # Skip non-device directories
                    if device_type not in ['PDU', 'UPS']:
                        devices.append((device_type, device_name))
            
            return devices
        
        except subprocess.CalledProcessError:
            # If we can't get diff (first commit?), check all devices
            return self.get_all_devices()
    
    def get_all_devices(self):
        """Get all devices from network/configs/"""
        configs_dir = Path("network/configs")
        devices = []
        
        if not configs_dir.exists():
            return devices
        
        for device_type_dir in configs_dir.iterdir():
            if not device_type_dir.is_dir():
                continue
            
            device_type = device_type_dir.name
            
            # Skip non-device directories
            if device_type in ['PDU', 'UPS']:
                continue
            
            for device_file in device_type_dir.iterdir():
                if device_file.is_file():
                    device_name = device_file.name
                    devices.append((device_type, device_name))
        
        return devices
    
    def create_drift_mr(self, device_type, device_name, additions, deletions, device_config):
        """
        Create merge request with device drift
        
        Returns:
            (success, mr_url)
        """
        if not self.can_create_mr:
            return False, None
        
        # Create branch name
        timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
        branch_name = f"drift/{device_name}-{timestamp}"
        
        print(f"📋 Creating drift MR for {device_name}...")
        
        try:
            api_url = f"{self.gitlab_url}/api/v4"
            headers = {'PRIVATE-TOKEN': self.gitlab_token}
            
            # Get current main branch SHA
            response = requests.get(
                f"{api_url}/projects/{self.project_id}/repository/branches/main",
                headers=headers,
                timeout=30
            )
            
            if response.status_code != 200:
                print(f"   ⚠️  Could not get main branch: {response.status_code}")
                return False, None
            
            main_sha = response.json()['commit']['id']
            
            # Create branch from main
            response = requests.post(
                f"{api_url}/projects/{self.project_id}/repository/branches",
                headers=headers,
                json={
                    'branch': branch_name,
                    'ref': 'main'
                },
                timeout=30
            )
            
            if response.status_code != 201:
                print(f"   ⚠️  Could not create branch: {response.status_code}")
                return False, None
            
            # Update the config file in the new branch
            config_path = f"network/configs/{device_type}/{device_name}"
            
            # Get current file to get blob_id
            response = requests.get(
                f"{api_url}/projects/{self.project_id}/repository/files/{config_path.replace('/', '%2F')}",
                headers=headers,
                params={'ref': 'main'},
                timeout=30
            )
            
            if response.status_code == 200:
                # File exists - update it
                response = requests.put(
                    f"{api_url}/projects/{self.project_id}/repository/files/{config_path.replace('/', '%2F')}",
                    headers=headers,
                    json={
                        'branch': branch_name,
                        'content': device_config,
                        'commit_message': f'Drift sync: {device_name} ({additions} additions, {deletions} deletions)'
                    },
                    timeout=30
                )
            else:
                # File doesn't exist - create it
                response = requests.post(
                    f"{api_url}/projects/{self.project_id}/repository/files/{config_path.replace('/', '%2F')}",
                    headers=headers,
                    json={
                        'branch': branch_name,
                        'content': device_config,
                        'commit_message': f'Drift sync: {device_name} ({additions} additions, {deletions} deletions)'
                    },
                    timeout=30
                )
            
            if response.status_code not in [200, 201]:
                print(f"   ⚠️  Could not update file: {response.status_code}")
                return False, None
            
            # Create MR description
            mr_description = self._generate_mr_description(
                device_type, device_name, additions, deletions
            )
            
            # Create merge request
            response = requests.post(
                f"{api_url}/projects/{self.project_id}/merge_requests",
                headers=headers,
                json={
                    'source_branch': branch_name,
                    'target_branch': 'main',
                    'title': f'🚨 Drift Detected: {device_name}',
                    'description': mr_description,
                    'REDACTED_dae379fc': True,
                    'labels': ['drift-detected', 'requires-rebase']
                },
                timeout=30
            )
            
            if response.status_code == 201:
                mr_data = response.json()
                mr_url = mr_data['web_url']
                print(f"   ✅ Created MR: {mr_url}")
                return True, mr_url
            else:
                print(f"   ⚠️  Could not create MR: {response.status_code}")
                return False, None
        
        except Exception as e:
            print(f"   ⚠️  Error creating MR: {str(e)}")
            return False, None
    
    def _generate_mr_description(self, device_type, device_name, additions, deletions):
        """Generate helpful MR description"""
        return f"""## 🚨 Drift Detected: {device_name}

**Manual changes were made directly on the device** (via SSH/ASDM/GUI).

These changes are **NOT** in your GitLab commit.

### 📊 Changes Found:
- **{additions} additions** (lines added on device)
- **{deletions} deletions** (lines removed on device)

---

## ✅ Option A: Keep Device Changes (Recommended)

**Use this if the ASDM/SSH changes should be kept.**

### Steps:

1. **Merge this MR** _(click "Merge" button below)_

2. **Rebase your commit on top**:
   ```bash
   # Fetch latest including the merged drift
   git fetch origin
   
   # Rebase your commit
   git rebase origin/main
   
   # Force push (safe because we're rebasing our own commit)
   git push origin main --force-with-lease
   ```

3. **New pipeline will run** with BOTH changes ✅

### Quick Script:
```bash
# Or use the helper script:
./network/scripts/rebase-after-drift.sh
```

---

## ❌ Option B: Discard Device Changes

**Use this if the device changes were mistakes/testing.**

### Steps:

1. **Close this MR** without merging

2. **Re-run the failed pipeline**:
   - Go to Pipelines → Find failed pipeline → Click "Retry"
   - Your GitLab changes will overwrite the device ✅

---

## 📋 Review the Diff

**Check the "Changes" tab below** to see exactly what was modified on the device.

Compare with your GitLab commit to decide which approach to use.

---

## 🔍 Why This Happened

Device: `{device_name}` ({device_type})

The device configuration was modified after the last GitLab sync. This could be from:
- ASDM GUI changes (Cisco ASA)
- SSH console commands
- Manual troubleshooting
- Emergency fixes

---

## 💡 Preventing This

To avoid drift detection blocks:
1. **Always edit in GitLab first** (preferred)
2. If you must use SSH/ASDM:
   - Run `./network/scripts/sync-from-device.sh {device_type} {device_name}` afterwards
   - Or wait for nightly drift sync

---

*🤖 Auto-generated by pre_deploy_drift_gate.py*
*Pipeline commit: `{self.commit_sha[:8]}`*
*Commit author: {self.commit_author}*
"""
    
    def run_drift_check(self):
        """
        Main drift check - examines devices and blocks if drift found
        
        Returns:
            exit_code (0 = no drift, 1 = drift detected)
        """
        print("=" * 70)
        print("🔍 PRE-DEPLOY DRIFT GATE")
        print("=" * 70)
        print()
        print("Checking devices for unreported changes...")
        print()
        
        # Get devices to check (only those being deployed)
        devices_to_check = self.get_changed_devices_from_commit()
        
        if not devices_to_check:
            print("ℹ️  No device config changes in this commit")
            print("   Skipping drift check")
            print()
            return 0
        
        print(f"📋 Checking {len(devices_to_check)} device(s) being deployed:")
        for device_type, device_name in devices_to_check:
            print(f"   - {device_name} ({device_type})")
        print()
        
        # Check each device
        print("─" * 70)
        
        for device_type, device_name in devices_to_check:
            print(f"Checking {device_name}...", end=' ')
            
            has_drift, additions, deletions, device_config = self.check_device_for_drift(
                device_type, device_name
            )
            
            if has_drift:
                print(f"❌ DRIFT DETECTED")
                print(f"   Changes: +{additions} additions, -{deletions} deletions")
                
                self.drift_found = True
                self.drifted_devices.append({
                    'device_type': device_type,
                    'device_name': device_name,
                    'additions': additions,
                    'deletions': deletions,
                    'device_config': device_config
                })
            else:
                print("✅ Clean")
        
        print("─" * 70)
        print()
        
        # If drift found, create MRs and block
        if self.drift_found:
            print("=" * 70)
            print("🛑 DEPLOYMENT BLOCKED - DRIFT DETECTED")
            print("=" * 70)
            print()
            print(f"Found unreported changes on {len(self.drifted_devices)} device(s):")
            print()
            
            mr_urls = []
            
            for device in self.drifted_devices:
                device_name = device['device_name']
                device_type = device['device_type']
                additions = device['additions']
                deletions = device['deletions']
                device_config = device['device_config']
                
                print(f"📍 {device_name}:")
                print(f"   +{additions} additions, -{deletions} deletions")
                
                # Create MR
                success, mr_url = self.create_drift_mr(
                    device_type, device_name, additions, deletions, device_config
                )
                
                if success and mr_url:
                    mr_urls.append((device_name, mr_url))
                
                print()
            
            # Print summary
            print("=" * 70)
            print("📋 NEXT STEPS")
            print("=" * 70)
            print()
            
            if mr_urls:
                print("Merge requests created:")
                for device_name, mr_url in mr_urls:
                    print(f"  • {device_name}: {mr_url}")
                print()
            
            print("Choose one option:")
            print()
            print("✅ OPTION A - Keep device changes (recommended):")
            print("   1. Review and merge the MR(s) above")
            print("   2. Rebase your commit:")
            print("      git fetch origin")
            print("      git rebase origin/main")
            print("      git push origin main --force-with-lease")
            print("   3. New pipeline will deploy both changes")
            print()
            print("❌ OPTION B - Discard device changes:")
            print("   1. Close the MR(s) without merging")
            print("   2. Re-run this pipeline (it will overwrite device)")
            print()
            print("=" * 70)
            
            return 1  # Block deployment
        
        else:
            print("=" * 70)
            print("✅ DRIFT CHECK PASSED")
            print("=" * 70)
            print()
            print("All devices are in sync with GitLab")
            print("Proceeding with deployment...")
            print()
            
            return 0  # Allow deployment


def main():
    """Main entry point"""
    gate = DriftGate()
    exit_code = gate.run_drift_check()
    sys.exit(exit_code)


if __name__ == "__main__":
    main()