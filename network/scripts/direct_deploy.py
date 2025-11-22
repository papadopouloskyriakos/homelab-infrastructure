#!/usr/bin/env python3
"""
Direct Deployment Script (Fallback)
Deploys configuration using Netmiko when Ansible is unavailable

Usage: direct_deploy.py <device_type> <device_name> <diff_yaml>
"""
import sys
import os
import yaml
from pathlib import Path
from netmiko import ConnectHandler

def direct_deploy(device_type, device_name, diff_yaml):
    """
    Deploy configuration directly using Netmiko
    """
    print(f"==> Direct deployment to {device_name} (Netmiko)")
    
    # Get credentials
    username = os.getenv('CISCO_USER', 'kyriakosp')
    password = os.getenv('CISCO_PASSWORD')
    
    if not password:
        print(f"ERROR: CISCO_PASSWORD environment variable not set")
        return 1
    
    # Load diff YAML
    diff_path = Path(diff_yaml)
    if not diff_path.exists():
        print(f"ERROR: Diff file not found: {diff_yaml}")
        return 1
    
    print(f"[1/4] Loading deployment configuration...")
    with open(diff_path) as f:
        diff_data = yaml.safe_load(f)
    
    diff_blocks = diff_data.get('diff_blocks', [])
    
    if not diff_blocks:
        print(f"INFO: No configuration changes to apply")
        return 0
    
    print(f"   Loaded {len(diff_blocks)} configuration blocks")
    
    # Determine device type for Netmiko
    if device_type == 'Firewall':
        device_type_netmiko = 'cisco_asa'
    else:
        device_type_netmiko = 'cisco_ios'
    
    # Build device parameters
    device = {
        'device_type': device_type_netmiko,
        'host': f"{device_name}.example.net",
        'username': username,
        'password': password,
        'timeout': 120,
        'session_log': f'artifacts/direct_deploy_{device_name}_session.log',
        'fast_cli': False,  # More reliable for config changes
    }
    
    try:
        print(f"[2/4] Connecting to device...")
        conn = ConnectHandler(**device)
        print(f"   SUCCESS: Connected to {device_name}")
        
        # Backup running config
        print(f"[3/4] Backing up running configuration...")
        running_config = conn.send_command("show running-config")
        
        backup_file = f"backups/{device_name}_direct_{os.getpid()}.cfg"
        os.makedirs("backups", exist_ok=True)
        with open(backup_file, 'w') as f:
            f.write(running_config)
        
        print(f"   SUCCESS: Backup saved to {backup_file}")
        
        # Enter config mode
        print(f"[4/4] Applying configuration changes...")
        output = conn.send_command("configure terminal")
        
        # Apply each block
        for i, block in enumerate(diff_blocks, 1):
            parents = block.get('parents', [])
            lines = block.get('lines', [])
            
            print(f"   Block {i}/{len(diff_blocks)}: {len(lines)} commands")
            if parents:
                print(f"      Context: {' > '.join(parents)}")
            
            # Enter parent context
            for parent in parents:
                output = conn.send_command(parent)
                if 'Invalid' in output or 'Error' in output:
                    print(f"      WARNING: {output}")
            
            # Apply lines
            for line in lines:
                output = conn.send_command(line)
                if 'Invalid' in output or 'Error' in output:
                    print(f"      WARNING on '{line}': {output}")
            
            # Exit parent context
            for _ in parents:
                conn.send_command("exit")
        
        # Exit config mode
        conn.send_command("end")
        print(f"   SUCCESS: Configuration applied")
        
        # Save config
        print(f"   Saving configuration to NVRAM...")
        if device_type == 'Firewall':
            save_output = conn.send_command("write memory")
        else:
            save_output = conn.send_command("write memory", expect_string=r"#")
        
        if 'OK' in save_output or 'building configuration' in save_output.lower():
            print(f"   SUCCESS: Configuration saved")
        else:
            print(f"   WARNING: Unexpected save output: {save_output}")
        
        # Verify connectivity
        version_output = conn.send_command("show version | include uptime")
        print(f"   SUCCESS: Device operational: {version_output.strip()}")
        
        conn.disconnect()
        
        print(f"")
        print(f"SUCCESS: Direct deployment completed")
        return 0
        
    except Exception as e:
        print(f"")
        print(f"ERROR: Deployment failed: {str(e)}")
        import traceback
        traceback.print_exc()
        return 1

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: direct_deploy.py <device_type> <device_name> <diff_yaml>")
        print("Example: direct_deploy.py Switch nlsw01 artifacts/diffs/nlsw01_diff.yml")
        sys.exit(1)
    
    device_type = sys.argv[1]
    device_name = sys.argv[2]
    diff_yaml = sys.argv[3]
    
    sys.exit(direct_deploy(device_type, device_name, diff_yaml))