#!/usr/bin/env python3
"""
Intelligent Diff Generator
Creates hierarchical parent/lines structure for Ansible deployment

Output: YAML file with diff_blocks for cisco.ios.ios_config
"""
import sys
import os
import difflib
import yaml
from pathlib import Path
from ciscoconfparse import CiscoConfParse

def normalize_config(lines):
    """Remove dynamic content that changes frequently"""
    normalized = []
    for line in lines:
        line = line.rstrip()
        # Skip dynamic lines
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
            continue
        normalized.append(line)
    return normalized

def get_parent_context(line, config_parse):
    """
    Determine the parent context for a configuration line
    using ciscoconfparse to understand hierarchy
    """
    # Find the config object for this line
    objs = config_parse.find_objects(f"^{line}$")
    if not objs:
        return []
    
    obj = objs[0]
    parents = []
    
    # Walk up the parent chain
    current = obj.parent
    while current and not current.is_global_config:
        parents.insert(0, current.text.strip())
        current = current.parent
    
    return parents

def generate_diff(device_type, device_name, config_file):
    """
    Generate intelligent diff between Oxidized backup and GitLab config
    Returns diff in hierarchical structure for Ansible
    """
    gitlab_config = Path(config_file)
    oxidized_backup = Path(f"network/oxidized/{device_type}/{device_name}")
    
    # Check if GitLab config exists
    if not gitlab_config.exists():
        print(f"❌ GitLab config not found: {gitlab_config}", file=sys.stderr)
        return 1
    
    # If no Oxidized backup exists, deploy entire config
    if not oxidized_backup.exists():
        print(f"ℹ️  No Oxidized backup found - will deploy entire config")
        
        with open(gitlab_config) as f:
            all_lines = [line.strip() for line in f if line.strip() and not line.startswith('!')]
        
        # For first deployment, structure as simple blocks
        diff_blocks = [{
            "parents": [],
            "lines": all_lines
        }]
        
        output = {"diff_blocks": diff_blocks}
        yaml.dump(output, sys.stdout, default_flow_style=False, sort_keys=False)
        return 0
    
    # Read both configs
    print(f"📖 Reading configs...", file=sys.stderr)
    print(f"   GitLab:   {gitlab_config}", file=sys.stderr)
    print(f"   Oxidized: {oxidized_backup}", file=sys.stderr)
    
    with open(gitlab_config) as f:
        gitlab_lines = f.readlines()
    
    with open(oxidized_backup) as f:
        oxidized_lines = f.readlines()
    
    # Normalize for comparison
    gitlab_normalized = normalize_config(gitlab_lines)
    oxidized_normalized = normalize_config(oxidized_lines)
    
    # Parse the GitLab config to understand hierarchy
    parse = CiscoConfParse(gitlab_lines)
    
    # Generate unified diff
    diff = list(difflib.unified_diff(
        oxidized_normalized,
        gitlab_normalized,
        lineterm='',
        n=0  # No context lines (we'll handle hierarchy ourselves)
    ))
    
    # Extract only the additions (lines to configure)
    diff_blocks = []
    current_block = {"parents": [], "lines": []}
    
    for line in diff:
        if line.startswith('@@') or line.startswith('+++') or line.startswith('---'):
            continue
        
        if line.startswith('+'):
            # This is a line to add
            cmd = line[1:].strip()
            if not cmd or cmd.startswith('!'):
                continue
            
            # Get parent context for this line
            parents = get_parent_context(cmd, parse)
            
            # If parents changed, start a new block
            if parents != current_block["parents"]:
                if current_block["lines"]:
                    diff_blocks.append(current_block.copy())
                current_block = {"parents": parents, "lines": [cmd]}
            else:
                current_block["lines"].append(cmd)
    
    # Add the last block
    if current_block["lines"]:
        diff_blocks.append(current_block)
    
    # If no diff blocks, configs are identical
    if not diff_blocks:
        print(f"✅ No configuration changes needed", file=sys.stderr)
        diff_blocks = []
    
    print(f"\n📊 Generated {len(diff_blocks)} configuration blocks", file=sys.stderr)
    for i, block in enumerate(diff_blocks, 1):
        print(f"   Block {i}:", file=sys.stderr)
        print(f"     Parents: {block['parents']}", file=sys.stderr)
        print(f"     Lines: {len(block['lines'])} commands", file=sys.stderr)
    
    # Output YAML for Ansible
    output = {"diff_blocks": diff_blocks}
    yaml.dump(output, sys.stdout, default_flow_style=False, sort_keys=False)
    
    return 0

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: generate_diff.py <device_type> <device_name> <config_file>", file=sys.stderr)
        print("Example: generate_diff.py Switch nlsw01 network/configs/Switch/nlsw01", file=sys.stderr)
        sys.exit(1)
    
    device_type = sys.argv[1]
    device_name = sys.argv[2]
    config_file = sys.argv[3]
    
    sys.exit(generate_diff(device_type, device_name, config_file))