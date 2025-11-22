#!/usr/bin/env python3
"""
Drift Detection - Check all devices for config drift
Compares GitLab vs Live configs and reports discrepancies

Enhanced with comprehensive filtering to prevent false drift detection
from timestamps, checksums, and other dynamic content.

Usage: detect_drift.py [--auto-sync]
"""
import sys
import os
import re
import yaml
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from netmiko import ConnectHandler


def filter_cisco_config(config_text):
    """
    Remove dynamic/timestamp content that changes frequently
    but doesn't represent actual configuration drift.
    
    This matches the filtering logic in sync_oxidized_gitlab.sh
    to prevent false drift detection.
    """
    lines = config_text.splitlines()
    filtered_lines = []
    
    # Patterns to skip entirely
    skip_patterns = [
        # Timestamps
        r'Last configuration change at',
        r'NVRAM config last updated at',
        r'Configuration last modified by',
        r'Building configuration',
        r'Current configuration\s*:',
        
        # Crypto/hashes (change on every save)
        r'^Cryptochecksum:',
        r'^!\s*Cryptochecksum:',
        
        # NTP clock drift (changes constantly)
        r'^ntp clock-period',
        
        # Dynamic comment lines with timestamps
        r'^!\s*\d{2}:\d{2}:\d{2}',
        
        # Configuration headers with sizes/bytes
        r'^!\s*Last configuration change',
        r'^!\s*NVRAM config last',
    ]
    
    for line in lines:
        # Remove trailing whitespace for consistent comparison
        line = line.rstrip()
        
        # Skip empty comment lines
        if line.strip() == '!':
            continue
        
        # Check skip patterns
        skip = False
        for pattern in skip_patterns:
            if re.search(pattern, line, re.IGNORECASE):
                skip = True
                break
        
        if skip:
            continue
        
        # Filter "uptime" mentions (but keep interface descriptions)
        if 'uptime' in line.lower() and 'description' not in line.lower():
            continue
        
        # Keep the line
        filtered_lines.append(line)
    
    return '\n'.join(filtered_lines)


def check_device_drift(device_type, device_name, gitlab_config_path):
    """
    Check single device for drift
    Returns: (device_name, status, details)
    """
    try:
        # Get credentials
        username = os.getenv('CISCO_USER', 'kyriakosp')
        password = os.getenv('CISCO_PASSWORD')
        
        if not password:
            return device_name, 'error', 'CISCO_PASSWORD not set'
        
        # Determine device type
        if device_type == 'Firewall':
            device_type_netmiko = 'cisco_asa'
        else:
            device_type_netmiko = 'cisco_ios'
        
        # Connect and fetch config
        device = {
            'device_type': device_type_netmiko,
            'host': f"{device_name}.example.net",
            'username': username,
            'password': password,
            'timeout': 30,
            'fast_cli': True,
        }
        
        conn = ConnectHandler(**device)
        live_config = conn.send_command("show running-config")
        conn.disconnect()
        
        # Read GitLab config
        if not gitlab_config_path.exists():
            return device_name, 'missing', 'No GitLab config file'
        
        with open(gitlab_config_path) as f:
            gitlab_config = f.read()
        
        # CRITICAL: Filter both configs before comparison
        live_config_filtered = filter_cisco_config(live_config)
        gitlab_config_filtered = filter_cisco_config(gitlab_config)
        
        # Compare filtered configs
        if live_config_filtered == gitlab_config_filtered:
            return device_name, 'synced', 'No drift detected'
        
        # Calculate drift size
        import difflib
        diff = list(difflib.unified_diff(
            gitlab_config_filtered.splitlines(),
            live_config_filtered.splitlines(),
            lineterm=''
        ))
        
        additions = sum(1 for line in diff if line.startswith('+') and not line.startswith('+++'))
        deletions = sum(1 for line in diff if line.startswith('-') and not line.startswith('---'))
        
        return device_name, 'drift', f'{additions} additions, {deletions} deletions'
        
    except Exception as e:
        return device_name, 'error', str(e)[:100]


def discover_devices():
    """
    Discover all devices from network/configs/
    Returns: [(device_type, device_name, config_path), ...]
    """
    devices = []
    configs_dir = Path('network/configs')
    
    if not configs_dir.exists():
        return devices
    
    for device_type_dir in configs_dir.iterdir():
        if not device_type_dir.is_dir():
            continue
        
        device_type = device_type_dir.name
        
        for config_file in device_type_dir.iterdir():
            # SKIP special files
            if config_file.name in ['.gitkeep', '.gitignore', 'README.md']:
                continue
            
            # SKIP hidden files
            if config_file.name.startswith('.'):
                continue
                
            if config_file.is_file():
                device_name = config_file.name
                devices.append((device_type, device_name, config_file))
    
    return devices


def detect_drift(auto_sync=False):
    """Main drift detection function"""
    
    print("=" * 70)
    print("DRIFT DETECTION - Config Synchronization Check")
    print("=" * 70)
    print()
    
    # Discover devices
    print("Discovering devices...")
    devices = discover_devices()
    print(f"Found {len(devices)} device(s)")
    print()
    
    if not devices:
        print("No devices found in network/configs/")
        return 0
    
    # Check each device (in parallel)
    print("Checking devices for drift...")
    print("-" * 70)
    
    results = []
    
    with ThreadPoolExecutor(max_workers=5) as executor:
        future_to_device = {
            executor.submit(check_device_drift, dtype, dname, dpath): (dtype, dname)
            for dtype, dname, dpath in devices
        }
        
        for future in as_completed(future_to_device):
            device_type, device_name = future_to_device[future]
            try:
                result = future.result()
                results.append(result)
                
                name, status, details = result
                
                if status == 'synced':
                    icon = 'OK'
                elif status == 'drift':
                    icon = 'DRIFT'
                elif status == 'missing':
                    icon = 'MISS'
                else:
                    icon = 'ERROR'
                
                print(f"{icon:6s} {name:20s} {status:10s} {details}")
                
            except Exception as e:
                print(f"ERROR  {device_name:20s} error      {str(e)[:50]}")
    
    print("-" * 70)
    print()
    
    # Summarize results
    synced = sum(1 for _, status, _ in results if status == 'synced')
    drifted = sum(1 for _, status, _ in results if status == 'drift')
    missing = sum(1 for _, status, _ in results if status == 'missing')
    errors = sum(1 for _, status, _ in results if status == 'error')
    
    print("SUMMARY")
    print("=" * 70)
    print(f"Total devices:    {len(results)}")
    print(f"Synced:           {synced}")
    print(f"Drift detected:   {drifted}")
    print(f"Missing config:   {missing}")
    print(f"Errors:           {errors}")
    print()
    
    # List drifted devices
    if drifted > 0:
        print("DEVICES WITH DRIFT:")
        print("-" * 70)
        for name, status, details in results:
            if status == 'drift':
                print(f"  {name}: {details}")
        print()
        
        if auto_sync:
            print("Auto-sync enabled - creating sync jobs...")
            # Create GitLab CI jobs to sync these devices
            # (This would trigger sync_from_device.py for each)
        else:
            print("ACTION REQUIRED:")
            print("Run sync for drifted devices:")
            print()
            for name, status, details in results:
                if status == 'drift':
                    # Find device type
                    device_type = next(
                        (dt for dt, dn, _ in devices if dn == name),
                        'Unknown'
                    )
                    print(f"  python3 network/scripts/sync_from_device.py {device_type} {name}")
            print()
    
    # Exit code
    if drifted > 0 or errors > 0:
        print("WARNING: Drift or errors detected - review required")
        return 1
    else:
        print("SUCCESS: All devices in sync")
        return 0


if __name__ == "__main__":
    auto_sync = '--auto-sync' in sys.argv
    sys.exit(detect_drift(auto_sync))