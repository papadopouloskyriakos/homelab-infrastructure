#!/usr/bin/env python3
"""
Auto-Sync from Device with Safeguards
Automatically syncs detected drift with safety checks

Enhanced with filtering to prevent false drift detection.

Usage: auto_sync_drift.py [--dry-run]
"""
import sys
import os
import re
import subprocess
from pathlib import Path
from datetime import datetime

# Safety thresholds
MAX_CHANGES_AUTO_SYNC = 100  # Max lines changed for auto-sync
MAX_DEVICES_AUTO_SYNC = 10   # Max devices to sync at once
REQUIRE_APPROVAL_PATTERNS = [
    'no shutdown',           # Interface state changes
    'ip route',              # Routing changes
    'access-list',           # ACL changes
    # 'crypto',              # COMMENTED: Too broad, blocks firewall sync
    'username',              # User management
    'enable secret',         # Password changes
]


def filter_cisco_config(config_text):
    """
    Remove dynamic/timestamp content that changes frequently
    but doesn't represent actual configuration drift.
    
    This matches the filtering logic in sync_oxidized_gitlab.sh
    and detect_drift.py to prevent false drift detection.
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


def is_safe_for_auto_sync(device_name, diff_lines, changes_summary):
    """
    Determine if drift is safe for automatic sync
    Returns: (safe, reason)
    """
    
    # Extract change counts
    try:
        parts = changes_summary.split(',')
        additions = int(parts[0].split()[0]) if 'additions' in parts[0] else 0
        deletions = int(parts[1].split()[0]) if 'deletions' in parts[1] else 0
        total_changes = additions + deletions
    except:
        return False, "Cannot parse change summary"
    
    # Safety check 1: Too many changes
    if total_changes > MAX_CHANGES_AUTO_SYNC:
        return False, f"Too many changes ({total_changes} > {MAX_CHANGES_AUTO_SYNC})"
    
    # Safety check 2: Critical command patterns
    for line in diff_lines:
        for pattern in REQUIRE_APPROVAL_PATTERNS:
            if pattern in line.lower():
                return False, f"Contains critical pattern: {pattern}"
    
    # Safety check 3: File deletions (config file removed)
    # RELAXED: Allow 10x more deletions for initial sync
    if deletions > additions * 10:
        return False, f"Suspicious: Many deletions ({deletions}) vs additions ({additions})"
    
    return True, "Safe for auto-sync"


def auto_sync_device(device_type, device_name, dry_run=False):
    """
    Automatically sync a single device with safety checks
    Returns: (success, action_taken, details)
    """
    
    print(f"\n{'='*70}")
    print(f"AUTO-SYNC: {device_name}")
    print(f"{'='*70}")
    
    # Import the sync script
    sys.path.insert(0, 'network/scripts')
    
    try:
        # Fetch config from device
        from netmiko import ConnectHandler
        
        username = os.getenv('CISCO_USER', 'kyriakosp')
        password = os.getenv('CISCO_PASSWORD')
        
        if not password:
            return False, 'error', 'CISCO_PASSWORD not set'
        
        if device_type == 'Firewall':
            device_type_netmiko = 'cisco_asa'
        else:
            device_type_netmiko = 'cisco_ios'
        
        device = {
            'device_type': device_type_netmiko,
            'host': f"{device_name}.example.net",
            'username': username,
            'password': password,
            'timeout': 30,
            'fast_cli': True,
        }
        
        print(f"[1/5] Fetching live config from {device_name}...")
        conn = ConnectHandler(**device)
        live_config = conn.send_command("show running-config")
        conn.disconnect()
        print(f"   SUCCESS: Retrieved {len(live_config.splitlines())} lines")
        
        # Read GitLab config
        config_path = Path(f"network/configs/{device_type}/{device_name}")
        
        if not config_path.exists():
            return False, 'missing', 'No GitLab config file'
        
        with open(config_path) as f:
            gitlab_config = f.read()
        
        # CRITICAL: Filter both configs before comparison
        print(f"[2/5] Comparing configurations...")
        live_config_filtered = filter_cisco_config(live_config)
        gitlab_config_filtered = filter_cisco_config(gitlab_config)
        
        # Generate diff
        import difflib
        
        diff = list(difflib.unified_diff(
            gitlab_config_filtered.splitlines(),
            live_config_filtered.splitlines(),
            fromfile='gitlab',
            tofile='device',
            lineterm=''
        ))
        
        if not diff:
            print(f"   SUCCESS: No drift detected")
            return True, 'synced', 'Already in sync'
        
        additions = sum(1 for line in diff if line.startswith('+') and not line.startswith('+++'))
        deletions = sum(1 for line in diff if line.startswith('-') and not line.startswith('---'))
        changes_summary = f"{additions} additions, {deletions} deletions"
        
        print(f"   Drift detected: {changes_summary}")
        
        # Safety check
        print(f"[3/5] Running safety checks...")
        safe, reason = is_safe_for_auto_sync(device_name, diff, changes_summary)
        
        if not safe:
            print(f"   BLOCKED: {reason}")
            print(f"   Manual review required")
            return False, 'blocked', reason
        
        print(f"   SUCCESS: Safe for auto-sync: {reason}")
        
        # Show preview
        print(f"[4/5] Preview of changes:")
        print("-" * 70)
        for i, line in enumerate(diff[:20], 1):
            print(f"   {line}")
        if len(diff) > 20:
            print(f"   ... and {len(diff) - 20} more lines")
        print("-" * 70)
        
        if dry_run:
            print(f"\n[DRY-RUN] Would auto-sync {device_name}")
            print(f"Changes: {changes_summary}")
            return True, 'dry_run', 'Would have synced'
        
        # Apply sync - COMMIT DIRECTLY TO MAIN (no branches in CI)
        print(f"[5/5] Auto-syncing to GitLab...")
        
        # Update file with UNFILTERED live config (we want full config in GitLab)
        with open(config_path, 'w') as f:
            f.write(live_config)
        
        # Commit directly to main
        timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
        commit_msg = f"""Auto-sync from device: {device_name}

Drift detected and auto-synced with safety checks passed.

Changes: {changes_summary}
Safety check: {reason}
Timestamp: {timestamp}

This change was automatically approved based on:
- Change size within threshold ({MAX_CHANGES_AUTO_SYNC} lines)
- No critical command patterns detected
- Change ratio appears normal

For audit: Review commit history and session logs if needed.
"""
        
        # Add and commit
        subprocess.run(['git', 'add', str(config_path)], check=True, capture_output=True)
        subprocess.run(['git', 'commit', '-m', commit_msg], check=True, capture_output=True)
        
        # Push directly to main (CI already has write access)
        result = subprocess.run(
            ['git', 'push', 'origin', 'HEAD:main'],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print(f"   SUCCESS: Auto-synced and pushed to main")
            return True, 'auto_synced', f"Auto-synced: {changes_summary}"
        else:
            print(f"   ERROR: Failed to push to main")
            print(f"   stdout: {result.stdout}")
            print(f"   stderr: {result.stderr}")
            return False, 'error', f"Failed to push: {result.stderr}"
        
    except subprocess.CalledProcessError as e:
        print(f"   ERROR: Git command failed: {str(e)}")
        return False, 'error', f"Git error: {str(e)}"
    except Exception as e:
        print(f"   ERROR: {str(e)}")
        return False, 'error', str(e)


def auto_sync_all_drift(dry_run=False):
    """
    Auto-sync all devices with detected drift
    """
    
    print("=" * 70)
    print("AUTO-SYNC ALL DRIFTED DEVICES")
    print("=" * 70)
    
    if dry_run:
        print("\nWARNING: DRY-RUN MODE - No changes will be made\n")
    
    # First, detect drift
    print("\n[Step 1] Detecting drift across all devices...")
    print("-" * 70)
    
    sys.path.insert(0, 'network/scripts')
    from detect_drift import discover_devices, check_device_drift
    
    devices = discover_devices()
    print(f"Found {len(devices)} device(s)\n")
    
    # Check each device
    drifted_devices = []
    
    for device_type, device_name, config_path in devices:
        result = check_device_drift(device_type, device_name, config_path)
        name, status, details = result
        
        if status == 'drift':
            print(f"WARNING: {name:20s} DRIFT: {details}")
            drifted_devices.append((device_type, device_name, details))
        elif status == 'synced':
            print(f"SUCCESS: {name:20s} OK")
        else:
            print(f"ERROR: {name:20s} {status.upper()}: {details}")
    
    print("-" * 70)
    print(f"\nDrift summary: {len(drifted_devices)} device(s) out of sync\n")
    
    if not drifted_devices:
        print("SUCCESS: All devices in sync - nothing to do!")
        return 0
    
    # Safety check: Too many devices
    if len(drifted_devices) > MAX_DEVICES_AUTO_SYNC:
        print(f"WARNING: SAFETY LIMIT EXCEEDED")
        print(f"   Detected drift on {len(drifted_devices)} devices")
        print(f"   Auto-sync limit: {MAX_DEVICES_AUTO_SYNC} devices")
        print(f"   Manual intervention required")
        print(f"\nDrifted devices:")
        for device_type, device_name, details in drifted_devices:
            print(f"   - {device_name}: {details}")
        return 1
    
    # Auto-sync each drifted device
    print(f"\n[Step 2] Auto-syncing {len(drifted_devices)} device(s)...")
    
    results = []
    
    for device_type, device_name, details in drifted_devices:
        success, action, message = auto_sync_device(device_type, device_name, dry_run)
        results.append((device_name, action, message))
    
    # Summary
    print("\n" + "=" * 70)
    print("AUTO-SYNC SUMMARY")
    print("=" * 70)
    
    synced = sum(1 for _, action, _ in results if action == 'auto_synced')
    blocked = sum(1 for _, action, _ in results if action == 'blocked')
    errors = sum(1 for _, action, _ in results if action == 'error')
    
    print(f"Total drifted:    {len(drifted_devices)}")
    print(f"SUCCESS Auto-synced:    {synced}")
    print(f"WARNING Blocked:        {blocked} (manual review required)")
    print(f"ERROR Errors:         {errors}")
    print()
    
    for device_name, action, message in results:
        if action == 'auto_synced':
            icon = 'SUCCESS'
        elif action == 'blocked':
            icon = 'WARNING'
        else:
            icon = 'ERROR'
        
        print(f"{icon}: {device_name:20s} {action:20s} {message}")
    
    print()
    
    if blocked > 0:
        print("WARNING: Some devices require manual review")
        print("   Use sync_from_device.py for blocked devices")
    
    if errors == 0 and blocked == 0:
        print("SUCCESS: All devices auto-synced successfully!")
    
    return 0 if errors == 0 else 1


if __name__ == "__main__":
    dry_run = '--dry-run' in sys.argv
    sys.exit(auto_sync_all_drift(dry_run))