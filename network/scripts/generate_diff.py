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
import re
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
    try:
        # Escape special regex characters in the line
        escaped_line = re.escape(line)
        
        # Find the config object for this line
        objs = config_parse.find_objects(f"^{escaped_line}$")
        if not objs:
            # Try without anchors
            objs = config_parse.find_objects(escaped_line)
        
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
    except Exception as e:
        print(f"   ⚠️  Warning: Could not determine parent for line: {line[:60]}...", file=sys.stderr)
        print(f"      Error: {str(e)}", file=sys.stderr)
        return []

def generate_diff(device_type, device_name, config_file):
    """
    Generate intelligent diff between Oxidized backup and GitLab config
    Returns diff in hierarchical structure for Ansible
    """
    try:
        gitlab_config = Path(config_file)
        oxidized_backup = Path(f"network/oxidized/{device_type}/{device_name}")
        
        # Check if GitLab config exists
        if not gitlab_config.exists():
            print(f"❌ GitLab config not found: {gitlab_config}", file=sys.stderr)
            return 1
        
        print(f"📖 Checking for Oxidized backup...", file=sys.stderr)
        print(f"   Path: {oxidized_backup}", file=sys.stderr)
        
        # If no Oxidized backup exists, deploy entire config
        if not oxidized_backup.exists():
            print(f"ℹ️  No Oxidized backup found - will deploy entire config", file=sys.stderr)
            print(f"   This is normal for first deployment", file=sys.stderr)
            
            with open(gitlab_config) as f:
                all_lines = [line.strip() for line in f if line.strip() and not line.startswith('!')]
            
            # For first deployment, structure as simple blocks
            diff_blocks = [{
                "parents": [],
                "lines": all_lines
            }]
            
            print(f"\n📊 Full config deployment:", file=sys.stderr)
            print(f"   Total lines: {len(all_lines)}", file=sys.stderr)
            
            output = {"diff_blocks": diff_blocks}
            yaml.dump(output, sys.stdout, default_flow_style=False, sort_keys=False)
            return 0
        
        # Read both configs
        print(f"\n📖 Reading configs for comparison...", file=sys.stderr)
        print(f"   GitLab:   {gitlab_config}", file=sys.stderr)
        print(f"   Oxidized: {oxidized_backup}", file=sys.stderr)
        
        with open(gitlab_config) as f:
            gitlab_lines = f.readlines()
        
        with open(oxidized_backup) as f:
            oxidized_lines = f.readlines()
        
        print(f"\n📊 Config sizes:", file=sys.stderr)
        print(f"   GitLab:   {len(gitlab_lines)} lines", file=sys.stderr)
        print(f"   Oxidized: {len(oxidized_lines)} lines", file=sys.stderr)
        
        # Normalize for comparison
        print(f"\n🔄 Normalizing configs...", file=sys.stderr)
        gitlab_normalized = normalize_config(gitlab_lines)
        oxidized_normalized = normalize_config(oxidized_lines)
        
        print(f"   GitLab normalized:   {len(gitlab_normalized)} lines", file=sys.stderr)
        print(f"   Oxidized normalized: {len(oxidized_normalized)} lines", file=sys.stderr)
        
        # Parse the GitLab config to understand hierarchy
        print(f"\n🔍 Parsing GitLab config structure...", file=sys.stderr)
        try:
            parse = CiscoConfParse(gitlab_lines)
            print(f"   ✅ Parsed successfully", file=sys.stderr)
        except Exception as e:
            print(f"   ⚠️  Parse warning: {str(e)}", file=sys.stderr)
            print(f"   Continuing with simplified structure...", file=sys.stderr)
            parse = None
        
        # Generate unified diff
        print(f"\n🔄 Generating diff...", file=sys.stderr)
        diff = list(difflib.unified_diff(
            oxidized_normalized,
            gitlab_normalized,
            lineterm='',
            n=0  # No context lines (we'll handle hierarchy ourselves)
        ))
        
        print(f"   Diff lines: {len(diff)}", file=sys.stderr)
        
        # Extract only the additions (lines to configure)
        diff_blocks = []
        current_block = {"parents": [], "lines": []}
        additions_count = 0
        deletions_count = 0
        
        for line in diff:
            if line.startswith('@@') or line.startswith('+++') or line.startswith('---'):
                continue
            
            if line.startswith('-'):
                deletions_count += 1
                continue
            
            if line.startswith('+'):
                additions_count += 1
                # This is a line to add
                cmd = line[1:].strip()
                if not cmd or cmd.startswith('!'):
                    continue
                
                # Get parent context for this line (only if parse succeeded)
                if parse:
                    parents = get_parent_context(cmd, parse)
                else:
                    parents = []
                
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
        
        # Report diff statistics
        print(f"\n📊 Diff Analysis:", file=sys.stderr)
        print(f"   Lines to add:    {additions_count}", file=sys.stderr)
        print(f"   Lines to remove: {deletions_count}", file=sys.stderr)
        
        if deletions_count > 0:
            print(f"\n   ⚠️  WARNING: {deletions_count} lines will be removed", file=sys.stderr)
            print(f"   This indicates manual changes on the device", file=sys.stderr)
        
        # If no diff blocks, configs are identical
        if not diff_blocks:
            print(f"\n✅ No configuration changes needed", file=sys.stderr)
            print(f"   GitLab config matches Oxidized backup", file=sys.stderr)
            diff_blocks = []
        else:
            print(f"\n📦 Generated {len(diff_blocks)} configuration blocks:", file=sys.stderr)
            for i, block in enumerate(diff_blocks, 1):
                print(f"\n   Block {i}:", file=sys.stderr)
                if block['parents']:
                    print(f"     Parents: {block['parents']}", file=sys.stderr)
                else:
                    print(f"     Parents: [global config]", file=sys.stderr)
                print(f"     Lines: {len(block['lines'])} commands", file=sys.stderr)
                # Show first few lines
                for j, line in enumerate(block['lines'][:3], 1):
                    print(f"       {j}. {line[:60]}{'...' if len(line) > 60 else ''}", file=sys.stderr)
                if len(block['lines']) > 3:
                    print(f"       ... and {len(block['lines']) - 3} more", file=sys.stderr)
        
        # Output YAML for Ansible
        output = {"diff_blocks": diff_blocks}
        yaml.dump(output, sys.stdout, default_flow_style=False, sort_keys=False)
        
        print(f"\n✅ Diff generation complete", file=sys.stderr)
        return 0
        
    except Exception as e:
        print(f"\n❌ ERROR in generate_diff:", file=sys.stderr)
        print(f"   {str(e)}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        return 1

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: generate_diff.py <device_type> <device_name> <config_file>", file=sys.stderr)
        print("Example: generate_diff.py Switch nlsw01 network/configs/Switch/nlsw01", file=sys.stderr)
        sys.exit(1)
    
    device_type = sys.argv[1]
    device_name = sys.argv[2]
    config_file = sys.argv[3]
    
    try:
        exit_code = generate_diff(device_type, device_name, config_file)
        sys.exit(exit_code)
    except Exception as e:
        print(f"❌ FATAL ERROR: {str(e)}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        sys.exit(1)