#!/usr/bin/env python3
"""
Hierarchical Diff Generator V4 - Smart Baseline Selection
Uses live device config as baseline, with fallbacks to Oxidized and Git
"""
import sys
import os
import yaml
from pathlib import Path
from collections import defaultdict
from ciscoconfparse import CiscoConfParse

# Disable logging
import logging
logging.basicConfig(level=logging.CRITICAL)

try:
    from loguru import logger
    logger.remove()
    logger.add(sys.stderr, level="CRITICAL")
except ImportError:
    pass

def log(msg):
    """All logging to stderr only"""
    print(msg, file=sys.stderr, flush=True)

def normalize_line(line):
    """Remove dynamic content from a single line"""
    line = line.rstrip()
    
    skip_patterns = [
        '!',
        'Last configuration change',
        'NVRAM config last updated',
        'ntp clock-period',
        'Configuration last modified',
        'Cryptochecksum:',
        'Current configuration :',
        'Building configuration',
        'uptime is',
    ]
    
    if any(pattern in line for pattern in skip_patterns):
        return None
    
    return line

def parse_config_hierarchy(config_lines):
    """
    Parse Cisco IOS config into hierarchical structure
    Returns: {parent_cmd: [child_cmd1, child_cmd2, ...], ...}
    Also returns global commands separately
    """
    filtered_lines = []
    for line in config_lines:
        normalized = normalize_line(line)
        if normalized is not None:
            filtered_lines.append(normalized)
    
    parse = CiscoConfParse(filtered_lines, syntax='ios')
    
    hierarchy = defaultdict(list)
    global_commands = []
    
    for parent_obj in parse.find_objects(r'^[^\s]'):
        parent_text = parent_obj.text
        children = []
        for child_obj in parent_obj.children:
            children.append(child_obj.text.strip())
        
        if children:
            hierarchy[parent_text] = children
        else:
            global_commands.append(parent_text)
    
    return hierarchy, global_commands

def get_live_config(device_name, device_type):
    """
    Fetch current running-config directly from device
    Returns: (success, config_lines, error_message)
    """
    try:
        from netmiko import ConnectHandler
        
        username = os.getenv('CISCO_USER', 'kyriakosp')
        password = os.getenv('CISCO_PASSWORD')
        
        if not password:
            return False, None, "CISCO_PASSWORD not set"
        
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
        
        log(f"   → Connecting to {device_name}...")
        conn = ConnectHandler(**device)
        
        log(f"   → Fetching running-config...")
        running_config = conn.send_command("show running-config")
        
        conn.disconnect()
        
        config_lines = running_config.splitlines()
        log(f"   → Retrieved {len(config_lines)} lines")
        
        return True, config_lines, None
        
    except Exception as e:
        return False, None, str(e)

def get_baseline_config(device_type, device_name, oxidized_backup_path):
    """
    Get baseline config using smart cascading strategy:
    1. Live device config (preferred)
    2. Oxidized backup (fallback)
    3. Error if neither available
    
    Returns: (source, config_lines)
    """
    log("")
    log("SMART BASELINE SELECTION")
    log("-" * 60)
    
    # Try 1: Live device config
    log("Attempting: Live device running-config")
    success, config_lines, error = get_live_config(device_name, device_type)
    
    if success:
        log("   ✓ SUCCESS: Using live device config as baseline")
        log("   This ensures 100% accuracy regardless of Oxidized timing")
        return "live", config_lines
    else:
        log(f"   ✗ Failed: {error}")
    
    # Try 2: Oxidized backup
    log("")
    log("Attempting: Oxidized backup")
    if oxidized_backup_path.exists():
        log(f"   ✓ Found: {oxidized_backup_path}")
        with open(oxidized_backup_path) as f:
            config_lines = f.readlines()
        
        log("   ⚠ WARNING: Using Oxidized backup as baseline")
        log("   This may be out of sync if device was recently changed")
        log(f"   Oxidized backup age: Check file timestamp")
        
        return "oxidized", config_lines
    else:
        log(f"   ✗ Not found: {oxidized_backup_path}")
    
    # No baseline available
    log("")
    log("ERROR: No baseline config available!")
    log("Solutions:")
    log("  1. Ensure device is reachable")
    log("  2. Wait for Oxidized to scrape device")
    log("  3. Manually create baseline config")
    raise Exception("No baseline config available")

def generate_diff_blocks(old_hierarchy, old_global, new_hierarchy, new_global):
    """Generate deployment blocks by comparing hierarchies"""
    diff_blocks = []
    
    # Global deletions
    old_global_set = set(old_global)
    new_global_set = set(new_global)
    
    global_deletions = old_global_set - new_global_set
    if global_deletions:
        deletion_cmds = []
        for cmd in sorted(global_deletions):
            if cmd.startswith('no '):
                deletion_cmds.append(cmd[3:])
            else:
                deletion_cmds.append(f"no {cmd}")
        
        diff_blocks.append({
            "parents": [],
            "lines": deletion_cmds,
            "description": "Global deletions"
        })
    
    # Global additions
    global_additions = new_global_set - old_global_set
    if global_additions:
        diff_blocks.append({
            "parents": [],
            "lines": sorted(list(global_additions)),
            "description": "Global additions"
        })
    
    # Hierarchical changes
    all_parents = set(old_hierarchy.keys()) | set(new_hierarchy.keys())
    
    for parent in sorted(all_parents):
        old_children = set(old_hierarchy.get(parent, []))
        new_children = set(new_hierarchy.get(parent, []))
        
        # Parent deleted
        if parent in old_hierarchy and parent not in new_hierarchy:
            diff_blocks.append({
                "parents": [],
                "lines": [f"no {parent}"],
                "description": f"Delete parent: {parent[:50]}"
            })
            continue
        
        # Parent added
        if parent not in old_hierarchy and parent in new_hierarchy:
            diff_blocks.append({
                "parents": [parent],
                "lines": sorted(list(new_children)),
                "description": f"New parent: {parent[:50]}"
            })
            continue
        
        # Parent modified
        child_deletions = old_children - new_children
        child_additions = new_children - old_children
        
        if child_deletions or child_additions:
            commands = []
            
            for child in sorted(child_deletions):
                if child.startswith('no '):
                    commands.append(child[3:])
                else:
                    commands.append(f"no {child}")
            
            commands.extend(sorted(list(child_additions)))
            
            diff_blocks.append({
                "parents": [parent],
                "lines": commands,
                "description": f"Modify: {parent[:50]}"
            })
    
    return diff_blocks

def generate_diff(device_type, device_name, config_file):
    """Generate hierarchical diff with smart baseline selection"""
    
    try:
        gitlab_config = Path(config_file)
        oxidized_backup = Path(f"network/oxidized/{device_type}/{device_name}")
        
        log("=" * 60)
        log("HIERARCHICAL DIFF GENERATOR V4")
        log("Smart baseline with live config support")
        log("=" * 60)
        
        if not gitlab_config.exists():
            log(f"ERROR: GitLab config not found: {gitlab_config}")
            return 1
        
        # Read desired config
        log(f"Desired config: {gitlab_config}")
        with open(gitlab_config) as f:
            gitlab_lines = f.readlines()
        log(f"  Lines: {len(gitlab_lines)}")
        
        # Get baseline using smart selection
        baseline_source, baseline_lines = get_baseline_config(
            device_type, 
            device_name, 
            oxidized_backup
        )
        
        log("")
        log("BASELINE SELECTION RESULT")
        log("-" * 60)
        log(f"Source: {baseline_source.upper()}")
        log(f"Lines: {len(baseline_lines)}")
        
        if baseline_source == "oxidized":
            log("")
            log("⚠ IMPORTANT: Using Oxidized backup")
            log("If you made recent changes, they may not be reflected!")
            log("For best results, ensure device is reachable for live config.")
        
        log("")
        log("PARSING CONFIGURATIONS")
        log("-" * 60)
        
        # Parse both configs
        old_hierarchy, old_global = parse_config_hierarchy(baseline_lines)
        new_hierarchy, new_global = parse_config_hierarchy(gitlab_lines)
        
        log(f"Baseline: {len(old_global)} global, {len(old_hierarchy)} parents")
        log(f"Desired:  {len(new_global)} global, {len(new_hierarchy)} parents")
        
        # Generate diff
        log("")
        log("GENERATING DIFF")
        log("-" * 60)
        diff_blocks = generate_diff_blocks(old_hierarchy, old_global, new_hierarchy, new_global)
        
        log("")
        log(f"DEPLOYMENT PLAN: {len(diff_blocks)} blocks")
        log("=" * 60)
        
        for i, block in enumerate(diff_blocks, 1):
            parents = block.get('parents', [])
            lines = block.get('lines', [])
            desc = block.get('description', '')
            
            log("")
            log(f"Block {i}: {desc}")
            if parents:
                log(f"  Context: {parents[0][:60]}")
            else:
                log(f"  Context: [GLOBAL]")
            
            log(f"  Commands: {len(lines)}")
            for j, line in enumerate(lines[:5], 1):
                log(f"    {j}. {line[:70]}")
            if len(lines) > 5:
                log(f"    ... and {len(lines) - 5} more")
        
        if not diff_blocks:
            log("")
            log("No changes detected")
        
        log("")
        log("=" * 60)
        
        # Output YAML
        output = {
            "diff_blocks": diff_blocks,
            "baseline_source": baseline_source,
            "baseline_note": "live = fetched from device, oxidized = from backup"
        }
        yaml.dump(output, sys.stdout, default_flow_style=False, sort_keys=False)
        sys.stdout.flush()
        
        log("SUCCESS: Diff generated")
        log("=" * 60)
        return 0
        
    except Exception as e:
        log(f"ERROR: {str(e)}")
        import traceback
        traceback.print_exc(file=sys.stderr)
        return 1

if __name__ == "__main__":
    if len(sys.argv) != 4:
        log("Usage: generate_diff.py <device_type> <device_name> <config_file>")
        sys.exit(1)
    
    device_type = sys.argv[1]
    device_name = sys.argv[2]
    config_file = sys.argv[3]
    
    try:
        exit_code = generate_diff(device_type, device_name, config_file)
        sys.exit(exit_code)
    except Exception as e:
        log(f"FATAL ERROR: {str(e)}")
        import traceback
        traceback.print_exc(file=sys.stderr)
        sys.exit(1)