#!/usr/bin/env python3
"""
Intelligent Diff Generator - Final Version
Disables ciscoconfparse logging to prevent stdout contamination
"""
import sys
import os
import difflib
import yaml
from pathlib import Path

# CRITICAL: Disable ciscoconfparse/loguru logging that goes to stdout
import logging
logging.basicConfig(level=logging.CRITICAL)

# Disable loguru if it's being used
try:
    from loguru import logger
    logger.remove()  # Remove all handlers
    logger.add(sys.stderr, level="CRITICAL")  # Only critical to stderr
except ImportError:
    pass

def log(msg):
    """All logging to stderr only"""
    print(msg, file=sys.stderr, flush=True)

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

def generate_diff(device_type, device_name, config_file):
    """
    Generate diff between Oxidized backup and GitLab config
    Returns YAML with diff_blocks (simplified - no parent/child hierarchy)
    """
    
    try:
        gitlab_config = Path(config_file)
        oxidized_backup = Path(f"network/oxidized/{device_type}/{device_name}")
        
        log("=" * 60)
        log("DIFF GENERATOR STARTED")
        log("=" * 60)
        
        # Check if GitLab config exists
        if not gitlab_config.exists():
            log(f"ERROR: GitLab config not found: {gitlab_config}")
            return 1
        
        log(f"GitLab config: {gitlab_config} (exists)")
        log(f"Oxidized backup: {oxidized_backup}")
        
        # If no Oxidized backup exists, deploy entire config
        if not oxidized_backup.exists():
            log("INFO: No Oxidized backup - deploying full config")
            
            with open(gitlab_config) as f:
                all_lines = [line.strip() for line in f if line.strip() and not line.startswith('!')]
            
            # Simple flat structure for first deployment
            diff_blocks = [{"parents": [], "lines": all_lines}]
            
            log(f"Full deployment: {len(all_lines)} lines")
            
            # Output YAML to stdout ONLY
            output = {"diff_blocks": diff_blocks}
            yaml.dump(output, sys.stdout, default_flow_style=False, sort_keys=False)
            sys.stdout.flush()
            
            log("=" * 60)
            log("SUCCESS: Full config YAML generated")
            log("=" * 60)
            return 0
        
        # Read both configs
        log("Reading configs...")
        with open(gitlab_config) as f:
            gitlab_lines = f.readlines()
        
        with open(oxidized_backup) as f:
            oxidized_lines = f.readlines()
        
        log(f"  GitLab:   {len(gitlab_lines)} lines")
        log(f"  Oxidized: {len(oxidized_lines)} lines")
        
        # Normalize for comparison
        log("Normalizing configs...")
        gitlab_normalized = normalize_config(gitlab_lines)
        oxidized_normalized = normalize_config(oxidized_lines)
        
        log(f"  Normalized: GitLab={len(gitlab_normalized)}, Oxidized={len(oxidized_normalized)}")
        
        # Generate unified diff
        log("Generating diff...")
        diff = list(difflib.unified_diff(
            oxidized_normalized,
            gitlab_normalized,
            lineterm='',
            n=0  # No context lines
        ))
        
        log(f"  Diff lines: {len(diff)}")
        
        # Process diff to extract additions and deletions
        additions = []
        deletions = []
        
        for line in diff:
            if line.startswith('@@') or line.startswith('+++') or line.startswith('---'):
                continue
            
            if line.startswith('-'):
                cmd = line[1:].strip()
                if cmd and not cmd.startswith('!'):
                    deletions.append(cmd)
            
            elif line.startswith('+'):
                cmd = line[1:].strip()
                if cmd and not cmd.startswith('!'):
                    additions.append(cmd)
        
        log(f"")
        log(f"DIFF ANALYSIS:")
        log(f"  Lines to add:    {len(additions)}")
        log(f"  Lines to remove: {len(deletions)}")
        
        # Detect changes vs separate operations
        # A "change" is when the command prefix is the same but value differs
        changes = []
        pure_deletions = []
        pure_additions = list(additions)  # Start with all additions
        
        for del_cmd in deletions:
            # Extract command prefix (first few words)
            del_parts = del_cmd.split()
            if len(del_parts) < 2:
                pure_deletions.append(del_cmd)
                continue
            
            # Look for matching addition with same prefix
            matched = False
            for add_cmd in additions:
                add_parts = add_cmd.split()
                if len(add_parts) < 2:
                    continue
                
                # Check if this is a change (same command, different value)
                # Examples:
                #   - "ip name-server 9.9.9.9" -> "ip name-server 1.1.1.1"
                #   - "snmp-server host X" -> "snmp-server host Y"
                if del_parts[0:2] == add_parts[0:2]:  # Same command prefix
                    changes.append({
                        'old': del_cmd,
                        'new': add_cmd,
                        'type': 'change'
                    })
                    pure_additions.remove(add_cmd)
                    matched = True
                    break
            
            if not matched:
                pure_deletions.append(del_cmd)
        
        log(f"")
        log(f"OPERATION BREAKDOWN:")
        log(f"  Pure additions: {len(pure_additions)}")
        log(f"  Pure deletions: {len(pure_deletions)}")
        log(f"  Changes:        {len(changes)}")
        
        # Show detected changes
        if changes:
            log(f"")
            log(f"  Detected changes (showing first 3):")
            for i, change in enumerate(changes[:3], 1):
                log(f"    {i}. OLD: {change['old'][:50]}")
                log(f"       NEW: {change['new'][:50]}")
        
        # Convert deletions to "no" commands
        deletion_commands = []
        for cmd in pure_deletions:
            # Special cases where we can't just prepend "no"
            skip_patterns = [
                'hostname',  # Can't "no hostname"
                'end',
                'exit',
                '!',
            ]
            
            # Check if this is a special command
            if any(cmd.strip().startswith(pattern) for pattern in skip_patterns):
                log(f"  SKIP deletion (special): {cmd[:60]}")
                continue
            
            # Check if command already starts with "no"
            if cmd.strip().startswith('no '):
                # Invert: remove the "no" to re-enable
                no_cmd = cmd.strip()[3:]  # Remove "no "
                deletion_commands.append(no_cmd)
            else:
                # Normal case: prepend "no"
                no_cmd = f"no {cmd}"
                deletion_commands.append(no_cmd)
        
        # Process changes (delete old, add new)
        change_commands = []
        for change in changes:
            # Add deletion of old value
            old_cmd = change['old']
            if not old_cmd.strip().startswith('no '):
                change_commands.append(f"no {old_cmd}")
            
            # Add new value
            change_commands.append(change['new'])
        
        # Build final command list: deletions, changes, then pure additions
        all_commands = deletion_commands + change_commands + pure_additions
        
        log(f"")
        log(f"COMMAND GENERATION:")
        log(f"  Deletion 'no' commands: {len(deletion_commands)}")
        log(f"  Change commands:        {len(change_commands)}")
        log(f"  Addition commands:      {len(pure_additions)}")
        log(f"  Total:                  {len(all_commands)}")
        
        # Create diff blocks
        if not all_commands:
            log(f"")
            log(f"SUCCESS: No configuration changes needed")
            diff_blocks = []
        else:
            log(f"")
            log(f"DEPLOYMENT PLAN:")
            log(f"  Total commands: {len(all_commands)}")
            log(f"  Order: Deletions → Changes → Additions")
            
            # Show deployment preview
            log(f"")
            log(f"  Deployment preview (first 5 commands):")
            for i, cmd in enumerate(all_commands[:5], 1):
                preview = cmd[:65] + '...' if len(cmd) > 65 else cmd
                log(f"    {i}. {preview}")
            if len(all_commands) > 5:
                log(f"    ... and {len(all_commands) - 5} more commands")
            
            # Create single block with all commands
            diff_blocks = [{
                "parents": [],
                "lines": all_commands
            }]
        
        # Output YAML to stdout ONLY
        output = {"diff_blocks": diff_blocks}
        yaml.dump(output, sys.stdout, default_flow_style=False, sort_keys=False)
        sys.stdout.flush()
        
        log(f"")
        log("=" * 60)
        log("SUCCESS: Diff YAML generated")
        log("=" * 60)
        return 0
        
    except Exception as e:
        log("=" * 60)
        log(f"ERROR: {str(e)}")
        log("=" * 60)
        import traceback
        traceback.print_exc(file=sys.stderr)
        return 1

if __name__ == "__main__":
    if len(sys.argv) != 4:
        log("Usage: generate_diff.py <device_type> <device_name> <config_file>")
        log("Example: generate_diff.py Router nl-lte01 network/configs/Router/nl-lte01")
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