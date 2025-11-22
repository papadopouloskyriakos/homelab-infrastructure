#!/usr/bin/env python3
"""
Hierarchical Diff Generator V2 - Uses diff context to preserve hierarchy
"""
import sys
import os
import difflib
import yaml
import re
from pathlib import Path

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

def normalize_config(lines):
    """Remove dynamic content"""
    normalized = []
    for line in lines:
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
            continue
        normalized.append(line)
    return normalized

def is_parent_command(line):
    """Check if line is a parent (no leading whitespace)"""
    return line and not line[0].isspace()

def is_child_command(line):
    """Check if line is a child (has leading whitespace)"""
    return line and line[0].isspace()

def parse_diff_with_context(diff_lines):
    """
    Parse unified diff and extract changes with their parent context
    Returns: [(operation, parent, command), ...]
    """
    changes = []
    current_parent = None
    
    for line in diff_lines:
        # Skip diff metadata
        if line.startswith('@@') or line.startswith('+++') or line.startswith('---'):
            continue
        
        # Context line (no +/-)
        if line and line[0] not in ['+', '-', '@']:
            # This is context - check if it's a parent
            if is_parent_command(line):
                current_parent = line.strip()
        
        # Deletion
        elif line.startswith('-'):
            cmd = line[1:]
            if cmd.strip() and not cmd.startswith('!'):
                if is_child_command(cmd):
                    # Child command
                    changes.append(('delete', current_parent, cmd.strip()))
                else:
                    # Global command
                    changes.append(('delete', None, cmd.strip()))
                    # Update parent for next context
                    if is_parent_command(cmd):
                        current_parent = cmd.strip()
        
        # Addition
        elif line.startswith('+'):
            cmd = line[1:]
            if cmd.strip() and not cmd.startswith('!'):
                if is_child_command(cmd):
                    # Child command
                    changes.append(('add', current_parent, cmd.strip()))
                else:
                    # Global command
                    changes.append(('add', None, cmd.strip()))
                    # Update parent for next context
                    if is_parent_command(cmd):
                        current_parent = cmd.strip()
    
    return changes

def generate_diff(device_type, device_name, config_file):
    """
    Generate hierarchical diff with proper parent-child relationships
    """
    
    try:
        gitlab_config = Path(config_file)
        oxidized_backup = Path(f"network/oxidized/{device_type}/{device_name}")
        
        log("=" * 60)
        log("HIERARCHICAL DIFF GENERATOR V2")
        log("=" * 60)
        
        if not gitlab_config.exists():
            log(f"ERROR: GitLab config not found: {gitlab_config}")
            return 1
        
        log(f"GitLab config: {gitlab_config} (exists)")
        log(f"Oxidized backup: {oxidized_backup}")
        
        # Read configs
        with open(gitlab_config) as f:
            gitlab_lines = f.readlines()
        
        if not oxidized_backup.exists():
            log("INFO: No Oxidized backup - full deployment needed")
            log("ERROR: Full deployment not yet implemented with hierarchical support")
            log("Please create oxidized backup first or use manual deployment")
            return 1
        
        with open(oxidized_backup) as f:
            oxidized_lines = f.readlines()
        
        log(f"  GitLab:   {len(gitlab_lines)} lines")
        log(f"  Oxidized: {len(oxidized_lines)} lines")
        
        # Normalize
        gitlab_normalized = normalize_config(gitlab_lines)
        oxidized_normalized = normalize_config(oxidized_lines)
        
        # Generate diff WITH CONTEXT (n=5 gives us parent context)
        log("Generating unified diff with context...")
        diff = list(difflib.unified_diff(
            oxidized_normalized,
            gitlab_normalized,
            lineterm='',
            n=5  # Context lines to capture parent
        ))
        
        log(f"  Diff lines: {len(diff)}")
        
        # Parse diff to extract changes with parent context
        changes = parse_diff_with_context(diff)
        
        log(f"")
        log(f"PARSED CHANGES: {len(changes)}")
        
        # Group by (parent, operation)
        groups = {}
        for operation, parent, command in changes:
            key = (parent, operation)
            if key not in groups:
                groups[key] = []
            groups[key].append(command)
        
        # Show analysis
        global_adds = len(groups.get((None, 'add'), []))
        global_dels = len(groups.get((None, 'delete'), []))
        
        hierarchical_parents = set(p for (p, op) in groups.keys() if p is not None)
        
        log(f"")
        log(f"OPERATION BREAKDOWN:")
        log(f"  Global additions:  {global_adds}")
        log(f"  Global deletions:  {global_dels}")
        log(f"  Hierarchical contexts: {len(hierarchical_parents)}")
        
        if hierarchical_parents:
            log(f"")
            log(f"  Parent contexts:")
            for parent in sorted(hierarchical_parents):
                adds = len(groups.get((parent, 'add'), []))
                dels = len(groups.get((parent, 'delete'), []))
                log(f"    {parent[:50]}: {adds} adds, {dels} dels")
        
        # Build diff blocks
        diff_blocks = []
        
        # Global deletions first
        if (None, 'delete') in groups:
            deletion_cmds = []
            for cmd in groups[(None, 'delete')]:
                if cmd.startswith('no '):
                    # Invert double negative
                    deletion_cmds.append(cmd[3:])
                else:
                    deletion_cmds.append(f"no {cmd}")
            
            if deletion_cmds:
                diff_blocks.append({
                    "parents": [],
                    "lines": deletion_cmds
                })
        
        # Global additions
        if (None, 'add') in groups:
            diff_blocks.append({
                "parents": [],
                "lines": groups[(None, 'add')]
            })
        
        # Hierarchical blocks
        for parent in sorted(hierarchical_parents):
            commands = []
            
            # Deletions for this parent
            if (parent, 'delete') in groups:
                for cmd in groups[(parent, 'delete')]:
                    if cmd.startswith('no '):
                        commands.append(cmd[3:])
                    else:
                        commands.append(f"no {cmd}")
            
            # Additions for this parent
            if (parent, 'add') in groups:
                commands.extend(groups[(parent, 'add')])
            
            if commands:
                diff_blocks.append({
                    "parents": [parent],
                    "lines": commands
                })
        
        log("")
        log(f"DEPLOYMENT PLAN:")
        log(f"  Total blocks: {len(diff_blocks)}")
        log(f"")
        
        for i, block in enumerate(diff_blocks, 1):
            parents = block.get('parents', [])
            lines = block.get('lines', [])
            if parents:
                log(f"  Block {i}: [{parents[0][:40]}]")
                for j, line in enumerate(lines[:3], 1):
                    log(f"    {j}. {line[:60]}")
                if len(lines) > 3:
                    log(f"    ... and {len(lines) - 3} more")
            else:
                log(f"  Block {i}: [GLOBAL]")
                for j, line in enumerate(lines[:3], 1):
                    log(f"    {j}. {line[:60]}")
                if len(lines) > 3:
                    log(f"    ... and {len(lines) - 3} more")
        
        if not diff_blocks:
            log("  No changes detected")
        
        # Output YAML
        output = {"diff_blocks": diff_blocks}
        yaml.dump(output, sys.stdout, default_flow_style=False, sort_keys=False)
        sys.stdout.flush()
        
        log("")
        log("=" * 60)
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