#!/usr/bin/env python3
"""
Conflict Detection Script
Compares network/configs/ with network/oxidized/ to detect manual changes

Exit codes:
  0 = No conflicts
  1 = Error occurred
  2 = Conflicts detected (requires merge request)
"""
import sys
import os
import difflib
from pathlib import Path

def normalize_config(config_lines):
    """
    Normalize config by removing dynamic content
    """
    normalized = []
    for line in config_lines:
        line = line.rstrip()
        
        # Skip lines that change frequently (dynamic content)
        skip_patterns = [
            '!',  # Comments
            'Last configuration change',
            'NVRAM config last updated',
            'ntp clock-period',
            'Configuration last modified',
            'Cryptochecksum:',
            'Current configuration :',
            'Building configuration',
            'uptime is',
            'System image file',
        ]
        
        if any(pattern in line for pattern in skip_patterns):
            continue
            
        normalized.append(line)
    
    return normalized

def detect_conflicts(device_type, device_name):
    """
    Detect conflicts between GitLab config and Oxidized backup
    Returns: (exit_code, description)
    """
    # Build paths using your structure
    gitlab_config = Path(f"network/configs/{device_type}/{device_name}")
    oxidized_backup = Path(f"network/oxidized/{device_type}/{device_name}")
    
    # Check if GitLab config exists
    if not gitlab_config.exists():
        print(f"❌ GitLab config not found: {gitlab_config}")
        return 1, "GitLab config file missing"
    
    # Check if Oxidized backup exists
    if not oxidized_backup.exists():
        print(f"ℹ️  No Oxidized backup found for {device_name}")
        print(f"   Path checked: {oxidized_backup}")
        print(f"   This is normal for:")
        print(f"   - New devices being added")
        print(f"   - First deployment before Oxidized has scraped")
        return 0, "No baseline - first deployment"
    
    # Read and normalize both configs
    print(f"📖 Reading configs...")
    print(f"   GitLab:   {gitlab_config}")
    print(f"   Oxidized: {oxidized_backup}")
    
    with open(gitlab_config) as f:
        gitlab_lines = normalize_config(f.readlines())
    
    with open(oxidized_backup) as f:
        oxidized_lines = normalize_config(f.readlines())
    
    # Generate diff
    diff = list(difflib.unified_diff(
        oxidized_lines,
        gitlab_lines,
        fromfile=f'oxidized/{device_type}/{device_name}',
        tofile=f'gitlab/{device_type}/{device_name}',
        lineterm='',
        n=3  # 3 lines of context
    ))
    
    if not diff:
        print(f"✅ Configs are identical (no conflicts)")
        return 0, "Configs in sync"
    
    # Analyze the diff
    additions = [line for line in diff if line.startswith('+') and not line.startswith('+++')]
    deletions = [line for line in diff if line.startswith('-') and not line.startswith('---')]
    
    print(f"\n📊 Diff Analysis:")
    print(f"   Lines to add:    {len(additions)}")
    print(f"   Lines to remove: {len(deletions)}")
    
    # Check for conflicts (deletions indicate manual changes on device)
    if deletions:
        print(f"\n⚠️  CONFLICT DETECTED!")
        print(f"\n╔════════════════════════════════════════════════════════╗")
        print(f"║  Manual changes were made directly on the device      ║")
        print(f"║  These changes are NOT in your GitLab config          ║")
        print(f"╚════════════════════════════════════════════════════════╝")
        
        print(f"\n📝 Lines present on device but NOT in GitLab:")
        print(f"   (These will be REMOVED if you deploy)")
        print(f"")
        
        for i, line in enumerate(deletions[:20], 1):  # Show first 20
            print(f"   {i:2d}. {line}")
        
        if len(deletions) > 20:
            print(f"   ... and {len(deletions) - 20} more lines")
        
        print(f"\n💡 RECOMMENDED ACTION:")
        print(f"   1. Review the Oxidized backup: {oxidized_backup}")
        print(f"   2. Decide which changes to keep:")
        print(f"      - Keep device changes: Copy them to GitLab config")
        print(f"      - Overwrite device: Proceed with deployment")
        print(f"   3. A merge request will be created automatically")
        
        # This is a conflict - requires merge request
        return 2, f"CONFLICT: {len(deletions)} manual changes on device"
    
    # Only additions - safe to deploy
    if additions:
        print(f"\n✅ Changes are safe (additions only)")
        print(f"\n📝 Lines to be added to device:")
        for i, line in enumerate(additions[:10], 1):
            print(f"   {i:2d}. {line}")
        
        if len(additions) > 10:
            print(f"   ... and {len(additions) - 10} more lines")
        
        return 0, f"Safe deployment ({len(additions)} additions)"
    
    return 0, "No changes"

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: detect_conflicts.py <device_type> <device_name>")
        print("Example: detect_conflicts.py Switch nlsw01")
        sys.exit(1)
    
    device_type = sys.argv[1]
    device_name = sys.argv[2]
    
    exit_code, description = detect_conflicts(device_type, device_name)
    
    print(f"\n{'='*60}")
    print(f"Result: {description}")
    print(f"{'='*60}\n")
    
    sys.exit(exit_code)