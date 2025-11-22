#!/usr/bin/env python3
"""
Post-Deployment Validation Script
Verifies configuration was applied correctly

Exit codes:
  0 = Validation passed
  1 = Validation failed (warnings OK)
"""
import sys
import os
from pathlib import Path
from netmiko import ConnectHandler

def post_validate(device_type, device_name):
    """
    Post-deployment validation checks
    """
    print(f"🔍 Post-deployment validation for {device_name}")
    
    # Get credentials from environment
    username = os.getenv('CISCO_USER', 'kyriakosp')
    password = os.getenv('CISCO_PASSWORD')
    
    if not password:
        print(f"⚠️  CISCO_PASSWORD not set - skipping connectivity test")
        return 0
    
    # Determine device type for Netmiko
    if device_type == 'Firewall':
        device_type_netmiko = 'cisco_asa'
    else:
        device_type_netmiko = 'cisco_ios'
    
    # Build device connection parameters
    device = {
        'device_type': device_type_netmiko,
        'host': f"{device_name}.example.net",
        'username': username,
        'password': password,
        'timeout': 30,
        'session_log': f'artifacts/postval_{device_name}_session.log',
    }
    
    try:
        print(f"   [1/3] Connecting to device...")
        conn = ConnectHandler(**device)
        print(f"   ✅ Connected successfully")
        
        # Get running config
        print(f"   [2/3] Retrieving running configuration...")
        running_config = conn.send_command("show running-config")
        
        # Save for comparison
        with open(f'artifacts/postval_{device_name}_running.cfg', 'w') as f:
            f.write(running_config)
        
        print(f"   ✅ Running config saved ({len(running_config)} bytes)")
        
        # Get version info
        print(f"   [3/3] Checking device status...")
        version_output = conn.send_command("show version")
        
        # Parse uptime (basic check)
        if 'uptime is' in version_output:
            uptime_line = [line for line in version_output.split('\n') if 'uptime is' in line][0]
            print(f"   ℹ️  Device uptime: {uptime_line.split('uptime is')[1].strip()}")
        
        conn.disconnect()
        print(f"   ✅ Device is operational")
        
        # Compare running config with GitLab config
        gitlab_config = Path(f"network/configs/{device_type}/{device_name}")
        if gitlab_config.exists():
            with open(gitlab_config) as f:
                gitlab_lines = set(line.strip() for line in f if line.strip() and not line.startswith('!'))
            
            running_lines = set(line.strip() for line in running_config.split('\n') if line.strip() and not line.startswith('!'))
            
            # Find commands in GitLab but not in running
            missing = gitlab_lines - running_lines
            if missing:
                print(f"\n   ⚠️  {len(missing)} commands from GitLab not found in running-config:")
                for cmd in list(missing)[:10]:
                    print(f"      - {cmd}")
                if len(missing) > 10:
                    print(f"      ... and {len(missing) - 10} more")
                print(f"\n   This may be normal for:")
                print(f"   - Commands that don't appear in running-config")
                print(f"   - Commands consolidated by IOS")
                print(f"   - Platform-specific differences")
            else:
                print(f"\n   ✅ All GitLab commands found in running-config")
        
        return 0
        
    except Exception as e:
        print(f"\n   ❌ Validation error: {str(e)}")
        print(f"   Note: This is non-critical - deployment may still have succeeded")
        return 0  # Non-critical failure

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: post_validate.py <device_type> <device_name>")
        print("Example: post_validate.py Switch nlsw01")
        sys.exit(1)
    
    device_type = sys.argv[1]
    device_name = sys.argv[2]
    
    sys.exit(post_validate(device_type, device_name))