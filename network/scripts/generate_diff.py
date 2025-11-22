#!/usr/bin/env python3
"""
Intelligent Diff Generator - DIAGNOSTIC VERSION
This version has extra safety to prevent stdout contamination
"""
import sys
import os
import difflib
import yaml
import re
from pathlib import Path

# CRITICAL: Ensure all diagnostic output goes to stderr
def log(msg):
    """All logging goes to stderr, never stdout"""
    print(msg, file=sys.stderr, flush=True)

def generate_diff(device_type, device_name, config_file):
    """Generate diff and output ONLY to stdout"""
    
    try:
        # Import here to avoid any import-time stdout pollution
        try:
            from ciscoconfparse import CiscoConfParse
            has_ciscoconfparse = True
        except ImportError:
            log("WARNING: ciscoconfparse not available")
            has_ciscoconfparse = False
        
        gitlab_config = Path(config_file)
        oxidized_backup = Path(f"network/oxidized/{device_type}/{device_name}")
        
        log("=" * 60)
        log(f"DIFF GENERATOR STARTED")
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
            
            diff_blocks = [{"parents": [], "lines": all_lines}]
            log(f"Full deployment: {len(all_lines)} lines")
            
            # Output YAML to stdout ONLY
            output = {"diff_blocks": diff_blocks}
            yaml.dump(output, sys.stdout, default_flow_style=False, sort_keys=False)
            sys.stdout.flush()
            
            log("SUCCESS: YAML written to stdout")
            return 0
        
        # Read configs
        log("Reading configs...")
        with open(gitlab_config) as f:
            gitlab_lines = f.readlines()
        
        with open(oxidized_backup) as f:
            oxidized_lines = f.readlines()
        
        log(f"GitLab: {len(gitlab_lines)} lines")
        log(f"Oxidized: {len(oxidized_lines)} lines")
        
        # Normalize
        def normalize(lines):
            normalized = []
            for line in lines:
                line = line.rstrip()
                if any(p in line for p in ['!', 'Last configuration change', 'NVRAM config last updated',
                                            'ntp clock-period', 'Cryptochecksum:', 'uptime is']):
                    continue
                normalized.append(line)
            return normalized
        
        gitlab_normalized = normalize(gitlab_lines)
        oxidized_normalized = normalize(oxidized_lines)
        
        log(f"Normalized: GitLab={len(gitlab_normalized)}, Oxidized={len(oxidized_normalized)}")
        
        # Parse
        parse = None
        if has_ciscoconfparse:
            try:
                parse = CiscoConfParse(gitlab_lines)
                log("Config parsed successfully")
            except Exception as e:
                log(f"Parse warning: {str(e)}")
        
        # Diff
        diff = list(difflib.unified_diff(
            oxidized_normalized,
            gitlab_normalized,
            lineterm='',
            n=0
        ))
        
        log(f"Diff generated: {len(diff)} lines")
        
        # Extract additions
        diff_blocks = []
        current_block = {"parents": [], "lines": []}
        additions = 0
        
        for line in diff:
            if line.startswith('@@') or line.startswith('+++') or line.startswith('---'):
                continue
            
            if line.startswith('+'):
                additions += 1
                cmd = line[1:].strip()
                if not cmd or cmd.startswith('!'):
                    continue
                
                parents = []
                if parse and has_ciscoconfparse:
                    try:
                        escaped = re.escape(cmd)
                        objs = parse.find_objects(f"^{escaped}$")
                        if objs:
                            obj = objs[0]
                            current = obj.parent
                            while current and not current.is_global_config:
                                parents.insert(0, current.text.strip())
                                current = current.parent
                    except:
                        pass
                
                if parents != current_block["parents"]:
                    if current_block["lines"]:
                        diff_blocks.append(current_block.copy())
                    current_block = {"parents": parents, "lines": [cmd]}
                else:
                    current_block["lines"].append(cmd)
        
        if current_block["lines"]:
            diff_blocks.append(current_block)
        
        log(f"Additions: {additions}")
        log(f"Blocks: {len(diff_blocks)}")
        
        # Output YAML to stdout ONLY
        output = {"diff_blocks": diff_blocks}
        yaml.dump(output, sys.stdout, default_flow_style=False, sort_keys=False)
        sys.stdout.flush()
        
        log("=" * 60)
        log("SUCCESS: YAML generation complete")
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
        sys.exit(1)
    
    device_type = sys.argv[1]
    device_name = sys.argv[2]
    config_file = sys.argv[3]
    
    sys.exit(generate_diff(device_type, device_name, config_file))