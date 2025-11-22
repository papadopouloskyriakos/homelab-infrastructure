#!/usr/bin/env python3
"""
Hierarchical Diff Generator V3 - Proper Hierarchical Parsing
Uses ciscoconfparse to actually understand IOS command structure
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
    """
    Remove dynamic content from a single line
    Returns None if line should be skipped entirely
    """
    line = line.rstrip()
    
    # Skip patterns
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
    
    # Filter out dynamic lines
    filtered_lines = []
    for line in config_lines:
        normalized = normalize_line(line)
        if normalized is not None:
            filtered_lines.append(normalized)
    
    # Parse with ciscoconfparse
    parse = CiscoConfParse(filtered_lines, syntax='ios')
    
    hierarchy = defaultdict(list)
    global_commands = []
    
    # Process all parent objects
    for parent_obj in parse.find_objects(r'^[^\s]'):
        parent_text = parent_obj.text
        
        # Get children
        children = []
        for child_obj in parent_obj.children:
            children.append(child_obj.text.strip())
        
        if children:
            # Has children - it's a hierarchical parent
            hierarchy[parent_text] = children
        else:
            # No children - it's a global command
            global_commands.append(parent_text)
    
    return hierarchy, global_commands

def generate_diff_blocks(old_hierarchy, old_global, new_hierarchy, new_global):
    """
    Generate deployment blocks by comparing hierarchies
    """
    diff_blocks = []
    
    # =========================================================================
    # 1. HANDLE GLOBAL COMMANDS
    # =========================================================================
    
    old_global_set = set(old_global)
    new_global_set = set(new_global)
    
    # Global deletions
    global_deletions = old_global_set - new_global_set
    if global_deletions:
        deletion_cmds = []
        for cmd in sorted(global_deletions):
            if cmd.startswith('no '):
                # Double negative - just add without "no"
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
    
    # =========================================================================
    # 2. HANDLE HIERARCHICAL COMMANDS
    # =========================================================================
    
    all_parents = set(old_hierarchy.keys()) | set(new_hierarchy.keys())
    
    for parent in sorted(all_parents):
        old_children = set(old_hierarchy.get(parent, []))
        new_children = set(new_hierarchy.get(parent, []))
        
        # Check if parent itself was deleted
        if parent in old_hierarchy and parent not in new_hierarchy:
            # Parent was deleted entirely
            diff_blocks.append({
                "parents": [],
                "lines": [f"no {parent}"],
                "description": f"Delete parent: {parent[:50]}"
            })
            continue
        
        # Check if parent is new
        if parent not in old_hierarchy and parent in new_hierarchy:
            # Parent is new - add parent and all children
            diff_blocks.append({
                "parents": [parent],
                "lines": sorted(list(new_children)),
                "description": f"New parent: {parent[:50]}"
            })
            continue
        
        # Parent exists in both - check for child changes
        child_deletions = old_children - new_children
        child_additions = new_children - old_children
        
        if child_deletions or child_additions:
            commands = []
            
            # Add deletions first
            for child in sorted(child_deletions):
                if child.startswith('no '):
                    commands.append(child[3:])
                else:
                    commands.append(f"no {child}")
            
            # Then additions
            commands.extend(sorted(list(child_additions)))
            
            diff_blocks.append({
                "parents": [parent],
                "lines": commands,
                "description": f"Modify: {parent[:50]}"
            })
    
    return diff_blocks

def generate_diff(device_type, device_name, config_file):
    """
    Generate hierarchical diff with proper config parsing
    """
    
    try:
        gitlab_config = Path(config_file)
        oxidized_backup = Path(f"network/oxidized/{device_type}/{device_name}")
        
        log("=" * 60)
        log("HIERARCHICAL DIFF GENERATOR V3")
        log("Proper hierarchical parsing with ciscoconfparse")
        log("=" * 60)
        
        if not gitlab_config.exists():
            log(f"ERROR: GitLab config not found: {gitlab_config}")
            return 1
        
        log(f"GitLab config: {gitlab_config}")
        log(f"Oxidized backup: {oxidized_backup}")
        
        # Read configs
        with open(gitlab_config) as f:
            gitlab_lines = f.readlines()
        
        if not oxidized_backup.exists():
            log("INFO: No Oxidized backup - full deployment needed")
            log("ERROR: Full deployment not yet implemented")
            log("Please create oxidized backup first")
            return 1
        
        with open(oxidized_backup) as f:
            oxidized_lines = f.readlines()
        
        log(f"  GitLab:   {len(gitlab_lines)} lines")
        log(f"  Oxidized: {len(oxidized_lines)} lines")
        log("")
        
        # Parse both configs into hierarchical structures
        log("Parsing configurations...")
        old_hierarchy, old_global = parse_config_hierarchy(oxidized_lines)
        new_hierarchy, new_global = parse_config_hierarchy(gitlab_lines)
        
        log(f"  Oxidized: {len(old_global)} global, {len(old_hierarchy)} hierarchical parents")
        log(f"  GitLab:   {len(new_global)} global, {len(new_hierarchy)} hierarchical parents")
        log("")
        
        # Generate diff blocks
        log("Generating deployment blocks...")
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
        
        # Output YAML (to stdout)
        output = {"diff_blocks": diff_blocks}
        yaml.dump(output, sys.stdout, default_flow_style=False, sort_keys=False)
        sys.stdout.flush()
        
        log("SUCCESS: Hierarchical diff generated")
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