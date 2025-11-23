#!/usr/bin/env python3
"""
Detect Configuration Drift
Compares device configs with GitLab to find unreported changes

This script checks if devices have been modified manually without updating GitLab.
If drift is detected, it means the device is out of sync with GitLab.

Usage: detect_drift.py [device_type] [device_name]

Examples:
  detect_drift.py                           # Check all devices
  detect_drift.py Router nl-lte01      # Check specific device
"""
import sys
import os
from pathlib import Path
from netmiko import ConnectHandler

# Import centralized filter
sys.path.insert(0, os.path.dirname(__file__))
from filter_dynamic_content import DynamicContentFilter

class DriftDetector:
    """Detect configuration drift between devices and GitLab"""
    
    def __init__(self):
        self.drift_found = False
        self.filter = DynamicContentFilter()  # Use centralized filter
    
    def normalize_config(self, config):
        """
        Normalize config for comparison (remove dynamic content)
        Uses centralized DynamicContentFilter for consistency
        """
        # Use the centralized filter
        filtered = self.filter.filter_config(config)
        
        # Remove empty lines and pure comments
        lines = []
        for line in filtered.split('\n'):
            if line.strip() and line.strip() != '!':
                lines.append(line)
        
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
    
    def check_device(self, device_type, device_name):
        """
        Check single device for drift
        
        Returns:
            (has_drift, message)
        """
        print(f"Checking {device_name}...", end=' ')
        
        try:
            # Fetch device config
            device_config = self.fetch_device_config(device_type, device_name)
            
            # Load GitLab config
            gitlab_config = self.load_gitlab_config(device_type, device_name)
            
            if not gitlab_config:
                print(f"[SKIP] No GitLab config found")
                return False, "No GitLab config"
            
            # Normalize both configs
            device_normalized = self.normalize_config(device_config)
            gitlab_normalized = self.normalize_config(gitlab_config)
            
            # Compare
            if device_normalized == gitlab_normalized:
                print("[OK] In sync")
                return False, "In sync"
            else:
                print("[DRIFT] Device has unreported changes")
                self.drift_found = True
                
                # Calculate rough diff size
                device_lines = set(device_normalized.split('\n'))
                gitlab_lines = set(gitlab_normalized.split('\n'))
                
                added = len(device_lines - gitlab_lines)
                removed = len(gitlab_lines - device_lines)
                
                message = f"~{added} additions, ~{removed} deletions"
                print(f"        {message}")
                
                return True, message
        
        except Exception as e:
            print(f"[ERROR] {str(e)[:60]}")
            return False, f"Error: {str(e)}"
    
    def check_all_devices(self):
        """Check all devices in network/configs/"""
        configs_dir = Path("network/configs")
        
        if not configs_dir.exists():
            print("ERROR: network/configs/ directory not found")
            return 1
        
        print("=" * 70)
        print("DRIFT DETECTION - Checking all devices")
        print("=" * 70)
        print()
        
        devices_checked = 0
        
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
                    
                    self.check_device(device_type, device_name)
                    devices_checked += 1
        
        print()
        print("=" * 70)
        
        if self.drift_found:
            print("DRIFT DETECTED")
            print("=" * 70)
            print()
            print("One or more devices have unreported changes.")
            print("This means the device config differs from GitLab.")
            print()
            print("Recommended actions:")
            print("1. Run auto_sync_drift.py to sync device -> GitLab")
            print("2. Review the changes in the resulting MR")
            print("3. Merge if changes are correct")
            print()
            return 1
        else:
            print("ALL DEVICES IN SYNC")
            print("=" * 70)
            print()
            print(f"Checked {devices_checked} devices - all in sync with GitLab")
            return 0

def main():
    """Main entry point"""
    detector = DriftDetector()
    
    if len(sys.argv) == 3:
        # Check specific device
        device_type = sys.argv[1]
        device_name = sys.argv[2]
        
        has_drift, message = detector.check_device(device_type, device_name)
        
        if has_drift:
            print()
            print("DRIFT DETECTED")
            print(f"Message: {message}")
            sys.exit(1)
        else:
            print()
            print("NO DRIFT")
            sys.exit(0)
    
    elif len(sys.argv) == 1:
        # Check all devices
        exit_code = detector.check_all_devices()
        sys.exit(exit_code)
    
    else:
        print("Usage: detect_drift.py [device_type] [device_name]", file=sys.stderr)
        print("", file=sys.stderr)
        print("Examples:", file=sys.stderr)
        print("  detect_drift.py                      # Check all devices", file=sys.stderr)
        print("  detect_drift.py Router nl-lte01  # Check specific device", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()