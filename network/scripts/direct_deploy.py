#!/usr/bin/env python3
"""
Direct Deployment Script V2 - Improved Error Handling
Deploys configuration using Netmiko with proper verification

Usage: direct_deploy.py <device_type> <device_name> <diff_yaml>
"""
import sys
import os
import yaml
import time
from pathlib import Path
from netmiko import ConnectHandler

def verify_commands(conn, commands, device_type):
    """
    Verify commands are valid before applying
    Returns: (valid, error_message)
    """
    # For now, basic validation
    # TODO: Could add more sophisticated validation
    return True, None

def apply_block_safely(conn, block, device_type):
    """
    Apply a single configuration block with verification
    Returns: (success, output)
    """
    parents = block.get('parents', [])
    lines = block.get('lines', [])
    
    # Build command sequence
    commands = []
    
    # Enter parent contexts
    commands.extend(parents)
    
    # Add configuration lines
    commands.extend(lines)
    
    # Exit parent contexts (one exit per parent)
    for _ in parents:
        commands.append("exit")
    
    if not commands:
        return True, "No commands in block"
    
    try:
        # Apply commands
        output = conn.send_config_set(commands, exit_config_mode=False)
        
        # Check for errors
        error_indicators = [
            'Invalid input',
            'Incomplete command',
            'Ambiguous command',
            '% Error',
            'Failed to',
        ]
        
        output_lower = output.lower()
        for indicator in error_indicators:
            if indicator.lower() in output_lower:
                return False, f"Error detected: {indicator}\nOutput: {output[:200]}"
        
        return True, output
        
    except Exception as e:
        return False, f"Exception: {str(e)}"

def direct_deploy(device_type, device_name, diff_yaml):
    """
    Deploy configuration directly using Netmiko
    """
    print(f"=" * 70)
    print(f"DIRECT DEPLOYMENT: {device_name}")
    print(f"=" * 70)
    
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
    
    print(f"[1/6] Loading deployment configuration...")
    with open(diff_path) as f:
        diff_data = yaml.safe_load(f)
    
    diff_blocks = diff_data.get('diff_blocks', [])
    
    if not diff_blocks:
        print(f"   INFO: No configuration changes to apply")
        return 0
    
    print(f"   Loaded {len(diff_blocks)} configuration blocks")
    
    # Show what we're about to do
    print(f"")
    print(f"DEPLOYMENT PREVIEW:")
    print(f"-" * 70)
    for i, block in enumerate(diff_blocks, 1):
        parents = block.get('parents', [])
        lines = block.get('lines', [])
        desc = block.get('description', '')
        
        print(f"Block {i}: {desc[:50] if desc else 'Configuration change'}")
        if parents:
            print(f"  Context: {parents[0][:60]}")
        else:
            print(f"  Context: [GLOBAL]")
        print(f"  Commands: {len(lines)}")
        for line in lines[:3]:
            print(f"    - {line[:65]}")
        if len(lines) > 3:
            print(f"    ... and {len(lines) - 3} more")
        print()
    
    print(f"-" * 70)
    print()
    
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
        'fast_cli': False,
        'read_timeout_override': 90,
    }
    
    try:
        print(f"[2/6] Connecting to device...")
        conn = ConnectHandler(**device)
        print(f"   SUCCESS: Connected to {device_name}")
        print()
        
        # Verify we're in the right place
        hostname_output = conn.send_command("show running-config | include hostname")
        if device_name not in hostname_output:
            print(f"   WARNING: Connected device hostname doesn't match")
            print(f"   Expected: {device_name}")
            print(f"   Got: {hostname_output}")
        
        # Backup running config
        print(f"[3/6] Backing up running configuration...")
        running_config = conn.send_command("show running-config")
        
        backup_file = f"backups/{device_name}_pre_deploy_{int(time.time())}.cfg"
        os.makedirs("backups", exist_ok=True)
        with open(backup_file, 'w') as f:
            f.write(running_config)
        
        print(f"   SUCCESS: Backup saved to {backup_file}")
        print()
        
        # Enter config mode once
        print(f"[4/6] Entering configuration mode...")
        conn.config_mode()
        print(f"   SUCCESS: In configuration mode")
        print()
        
        # Apply configuration blocks
        print(f"[5/6] Applying configuration blocks...")
        
        failed_blocks = []
        
        for i, block in enumerate(diff_blocks, 1):
            desc = block.get('description', f'Block {i}')
            print(f"   [{i}/{len(diff_blocks)}] {desc[:60]}")
            
            success, output = apply_block_safely(conn, block, device_type)
            
            if success:
                print(f"      ✓ Applied successfully")
            else:
                print(f"      ✗ FAILED: {output[:100]}")
                failed_blocks.append((i, desc, output))
        
        # Exit config mode
        conn.exit_config_mode()
        print()
        
        if failed_blocks:
            print(f"ERROR: {len(failed_blocks)} block(s) failed to apply:")
            for block_num, desc, error in failed_blocks:
                print(f"   Block {block_num}: {desc}")
                print(f"      Error: {error[:150]}")
            print()
            print(f"Check session log: artifacts/direct_deploy_{device_name}_session.log")
            return 1
        
        # Save config
        print(f"[6/6] Saving configuration to NVRAM...")
        if device_type == 'Firewall':
            save_output = conn.send_command_timing("write memory", read_timeout=60)
        else:
            save_output = conn.save_config()
        
        # Check save was successful
        save_indicators = ['OK', '[OK]', 'building configuration']
        if any(indicator in save_output for indicator in save_indicators):
            print(f"   SUCCESS: Configuration saved")
        else:
            print(f"   WARNING: Unexpected save output:")
            print(f"   {save_output[:200]}")
        
        print()
        
        # Verify connectivity after deployment
        print(f"VERIFICATION:")
        version_output = conn.send_command("show version | include uptime")
        print(f"   Device status: {version_output.strip()}")
        
        # Save post-deployment config
        post_config = conn.send_command("show running-config")
        post_backup_file = f"backups/{device_name}_post_deploy_{int(time.time())}.cfg"
        with open(post_backup_file, 'w') as f:
            f.write(post_config)
        print(f"   Post-deployment backup: {post_backup_file}")
        
        conn.disconnect()
        
        print()
        print(f"=" * 70)
        print(f"SUCCESS: Deployment completed")
        print(f"=" * 70)
        return 0
        
    except Exception as e:
        print()
        print(f"=" * 70)
        print(f"ERROR: Deployment failed")
        print(f"=" * 70)
        print(f"Error: {str(e)}")
        print()
        print(f"Check artifacts/direct_deploy_{device_name}_session.log for details")
        
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