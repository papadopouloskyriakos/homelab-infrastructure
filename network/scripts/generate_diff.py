#!/usr/bin/env python3
"""
Generate Hierarchical Configuration Diff
Compares live device config with GitLab config to produce exact deployment changes

This script generates hierarchical diffs that include both additions and deletions.
Deletions are represented as "no <command>" statements. This enables true declarative
configuration management where GitLab is the source of truth.

The baseline is ALWAYS the live device config (Oxidized is not used).

Usage: generate_diff.py <device_type> <device_name> <gitlab_config_file>

Example: generate_diff.py Router nl-lte01 network/configs/Router/nl-lte01
"""
import sys
import os
import re
import json
from pathlib import Path
from netmiko import ConnectHandler

# Import dynamic content filter
sys.path.insert(0, os.path.dirname(__file__))
from filter_dynamic_content import DynamicContentFilter

class ConfigParser:
    """Parse Cisco IOS/ASA configs into hierarchical structure"""
    
    def __init__(self):
        self.filter = DynamicContentFilter()
    
    def parse_config(self, config_text):
        """
        Parse config into hierarchical structure
        
        Returns:
            List of dicts with 'parents' and 'lines' keys
        """
        # Filter dynamic content first
        filtered_config = self.filter.filter_config(config_text)
        
        blocks = []
        current_parents = []
        current_lines = []
        
        lines = filtered_config.split('\n')
        
        for line in lines:
            # Skip empty lines and comments
            if not line.strip() or line.strip().startswith('!'):
                continue
            
            # Determine indentation level
            indent = len(line) - len(line.lstrip())
            
            if indent == 0:
                # Global command or new top-level block
                
                # Save previous block if exists
                if current_parents or current_lines:
                    blocks.append({
                        'parents': list(current_parents),
                        'lines': list(current_lines)
                    })
                    current_lines = []
                
                # Check if this is a parent command (creates context)
                if self._is_parent_command(line.strip()):
                    current_parents = [line.strip()]
                else:
                    # Global command
                    current_parents = []
                    current_lines = [line.strip()]
            
            else:
                # Child command under parent
                current_lines.append(line.strip())
        
        # Save final block
        if current_parents or current_lines:
            blocks.append({
                'parents': list(current_parents),
                'lines': list(current_lines)
            })
        
        return blocks
    
    def _is_parent_command(self, line):
        """Check if command creates a configuration context"""
        parent_keywords = [
            'interface ',
            'router ',
            'line ',
            'class-map ',
            'policy-map ',
            'route-map ',
            'access-list ',
            'object-group ',
            'object network ',
            'object service ',
            'crypto ',
            'username ',
            'tunnel-group ',
            'group-policy ',
            'aaa ',
            'vrf definition ',
        ]
        
        return any(line.startswith(keyword) for keyword in parent_keywords)

class DiffGenerator:
    """Generate deployment diffs between current and desired configs"""
    
    def __init__(self):
        self.parser = ConfigParser()
        self.filter = DynamicContentFilter()
    
    def normalize_line(self, line):
        """Normalize line for comparison (strip extra spaces, etc.)"""
        return ' '.join(line.split())
    
    def fetch_device_config(self, device_type, device_name):
        """
        Fetch current running config from device
        
        This is the BASELINE for all comparisons.
        Oxidized is no longer used.
        
        Returns:
            Config text as string
        """
        username = os.getenv('CISCO_USER', 'kyriakosp')
        password = os.getenv('CISCO_PASSWORD')
        
        if not password:
            raise Exception("CISCO_PASSWORD environment variable not set")
        
        # Determine Netmiko device type
        netmiko_type_map = {
            'Firewall': 'cisco_asa',
            'Router': 'cisco_ios',
            'Switch': 'cisco_ios',
            'Access-Point': 'cisco_ios',
        }
        
        device_type_netmiko = netmiko_type_map.get(device_type, 'cisco_ios')
        
        device_params = {
            'device_type': device_type_netmiko,
            'host': f"{device_name}.example.net",
            'username': username,
            'password': password,
            'timeout': 120,
            'fast_cli': False,
        }
        
        print(f"Fetching live config from {device_name}...", file=sys.stderr)
        
        try:
            conn = ConnectHandler(**device_params)
            config = conn.send_command("show running-config", read_timeout=120)
            conn.disconnect()
            
            print(f"Successfully fetched live config ({len(config)} bytes)", file=sys.stderr)
            return config
        
        except Exception as e:
            print(f"ERROR: Failed to fetch from device: {str(e)}", file=sys.stderr)
            raise
    
    def generate_diff(self, current_config, desired_config):
        """
        Generate hierarchical diff between current and desired configs
        
        Returns:
            List of diff blocks with additions and deletions
        """
        # Parse both configs (filter is applied inside parse_config)
        current_blocks = self.parser.parse_config(current_config)
        desired_blocks = self.parser.parse_config(desired_config)
        
        # Create lookup structures
        current_map = self._build_block_map(current_blocks)
        desired_map = self._build_block_map(desired_blocks)
        
        diff_blocks = []
        
        # Find blocks to delete (in current but not in desired)
        for context_key, current_lines in current_map.items():
            if context_key not in desired_map:
                # Entire block should be removed
                parents = self._key_to_parents(context_key)
                
                # Generate "no" commands for all lines
                no_commands = []
                for line in current_lines:
                    # Don't double-negate
                    if not line.startswith('no '):
                        no_commands.append(f"no {line}")
                
                if no_commands:
                    diff_blocks.append({
                        'parents': parents,
                        'lines': no_commands,
                        'description': f"Remove: {context_key}"
                    })
        
        # Find blocks to add or modify
        for context_key, desired_lines in desired_map.items():
            parents = self._key_to_parents(context_key)
            
            if context_key not in current_map:
                # New block - add everything
                diff_blocks.append({
                    'parents': parents,
                    'lines': list(desired_lines),
                    'description': f"Add: {context_key}"
                })
            
            else:
                # Existing block - find differences
                current_lines = current_map[context_key]
                
                additions = []
                deletions = []
                
                # Normalize for comparison
                current_set = set(self.normalize_line(line) for line in current_lines)
                desired_set = set(self.normalize_line(line) for line in desired_lines)
                
                # Lines to delete
                for line in current_lines:
                    norm_line = self.normalize_line(line)
                    if norm_line not in desired_set:
                        if not line.startswith('no '):
                            deletions.append(f"no {line}")
                
                # Lines to add
                for line in desired_lines:
                    norm_line = self.normalize_line(line)
                    if norm_line not in current_set:
                        additions.append(line)
                
                # Create diff block if there are changes
                if deletions or additions:
                    # Apply deletions first, then additions
                    all_changes = deletions + additions
                    
                    diff_blocks.append({
                        'parents': parents,
                        'lines': all_changes,
                        'description': f"Modify: {context_key}"
                    })
        
        return diff_blocks
    
    def _build_block_map(self, blocks):
        """
        Build map of context -> lines
        
        Returns:
            Dict mapping context key to list of lines
        """
        block_map = {}
        
        for block in blocks:
            parents = block['parents']
            lines = block['lines']
            
            # Create unique key for this context
            if parents:
                context_key = ' > '.join(parents)
            else:
                context_key = '[GLOBAL]'
            
            if context_key not in block_map:
                block_map[context_key] = []
            
            block_map[context_key].extend(lines)
        
        return block_map
    
    def _key_to_parents(self, context_key):
        """Convert context key back to parents list"""
        if context_key == '[GLOBAL]':
            return []
        return context_key.split(' > ')

def generate_deployment_diff(device_type, device_name, gitlab_config_file):
    """
    Main function to generate deployment diff
    
    Outputs JSON to stdout
    """
    print(f"Generating diff for {device_name}...", file=sys.stderr)
    print(f"Device type: {device_type}", file=sys.stderr)
    print(f"GitLab config: {gitlab_config_file}", file=sys.stderr)
    print("", file=sys.stderr)
    
    # Load desired config from GitLab
    gitlab_path = Path(gitlab_config_file)
    if not gitlab_path.exists():
        print(f"ERROR: GitLab config not found: {gitlab_config_file}", file=sys.stderr)
        sys.exit(1)
    
    with open(gitlab_path) as f:
        desired_config = f.read()
    
    print(f"Loaded GitLab config ({len(desired_config)} bytes)", file=sys.stderr)
    
    # Get current config from LIVE DEVICE (not Oxidized)
    generator = DiffGenerator()
    
    try:
        current_config = generator.fetch_device_config(device_type, device_name)
    except Exception as e:
        error_msg = f"Could not fetch current config from device: {str(e)}"
        print(f"ERROR: {error_msg}", file=sys.stderr)
        
        # Output error in JSON format
        error_output = {
            "diff_blocks": [],
            "error": error_msg,
            "device_name": device_name,
            "device_type": device_type
        }
        print(json.dumps(error_output, indent=2))
        sys.exit(1)
    
    print("", file=sys.stderr)
    print("Comparing configurations...", file=sys.stderr)
    
    # Generate diff
    diff_blocks = generator.generate_diff(current_config, desired_config)
    
    print(f"Generated {len(diff_blocks)} diff blocks", file=sys.stderr)
    print("", file=sys.stderr)
    
    # Output JSON to stdout
    output = {
        'diff_blocks': diff_blocks,
        'baseline': 'live_device',
        'device_name': device_name,
        'device_type': device_type
    }
    
    # Use JSON with proper formatting
    json_output = json.dumps(output, indent=2, ensure_ascii=False)
    
    print(json_output)

def main():
    """Main entry point"""
    try:
        if len(sys.argv) != 4:
            print("Usage: generate_diff.py <device_type> <device_name> <gitlab_config_file>", file=sys.stderr)
            print("", file=sys.stderr)
            print("Arguments:", file=sys.stderr)
            print("  device_type        - Device type (Router/Switch/Firewall/Access-Point)", file=sys.stderr)
            print("  device_name        - Device hostname (e.g., nl-lte01)", file=sys.stderr)
            print("  gitlab_config_file - Path to GitLab config file", file=sys.stderr)
            print("", file=sys.stderr)
            print("Example:", file=sys.stderr)
            print("  generate_diff.py Router nl-lte01 network/configs/Router/nl-lte01", file=sys.stderr)
            print("", file=sys.stderr)
            print("NOTE: This script uses the LIVE device config as baseline", file=sys.stderr)
            print("      Oxidized is not used (it runs independently)", file=sys.stderr)
            print("", file=sys.stderr)
            # Output empty diff blocks as valid JSON
            print(json.dumps({"diff_blocks": [], "error": "Invalid arguments"}))
            sys.exit(1)
        
        device_type = sys.argv[1]
        device_name = sys.argv[2]
        gitlab_config_file = sys.argv[3]
        
        # Validate device type
        valid_types = ['Router', 'Switch', 'Firewall', 'Access-Point']
        if device_type not in valid_types:
            print(f"ERROR: Invalid device type: {device_type}", file=sys.stderr)
            print(f"Valid types: {', '.join(valid_types)}", file=sys.stderr)
            # Output empty diff blocks as valid JSON
            print(json.dumps({"diff_blocks": [], "error": f"Invalid device type: {device_type}"}))
            sys.exit(1)
        
        generate_deployment_diff(device_type, device_name, gitlab_config_file)
        
    except Exception as e:
        # Always output valid JSON even on error
        print(f"ERROR: {str(e)}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        
        # Output error in JSON format
        error_output = {
            "diff_blocks": [],
            "error": str(e),
            "error_type": type(e).__name__
        }
        print(json.dumps(error_output, indent=2))
        sys.exit(1)

if __name__ == "__main__":
    main()