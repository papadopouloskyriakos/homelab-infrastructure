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
        
        # Extract only the additions (lines to configure)
        # Using SIMPLIFIED structure - no parent/child hierarchy
        # This avoids ciscoconfparse issues
        additions = []
        deletions = 0
        
        for line in diff:
            if line.startswith('@@') or line.startswith('+++') or line.startswith('---'):
                continue
            
            if line.startswith('-'):
                deletions += 1
                continue
            
            if line.startswith('+'):
                cmd = line[1:].strip()
                if cmd and not cmd.startswith('!'):
                    additions.append(cmd)
        
        log(f"")
        log(f"DIFF ANALYSIS:")
        log(f"  Lines to add:    {len(additions)}")
        log(f"  Lines to remove: {deletions}")
        
        if deletions > 0:
            log(f"")
            log(f"  WARNING: {deletions} lines will be removed")
            log(f"  This indicates manual changes on the device")
        
        # Create diff blocks
        # Simple flat structure - all commands in one block
        if not additions:
            log(f"")
            log(f"SUCCESS: No configuration changes needed")
            diff_blocks = []
        else:
            log(f"")
            log(f"DEPLOYMENT PLAN:")
            log(f"  Total commands: {len(additions)}")
            log(f"  Structure: Flat (no hierarchy)")
            
            # Show first few lines
            log(f"")
            log(f"  Preview (first 5 commands):")
            for i, cmd in enumerate(additions[:5], 1):
                preview = cmd[:60] + '...' if len(cmd) > 60 else cmd
                log(f"    {i}. {preview}")
            if len(additions) > 5:
                log(f"    ... and {len(additions) - 5} more")
            
            # Create single block with all additions
            diff_blocks = [{
                "parents": [],
                "lines": additions
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