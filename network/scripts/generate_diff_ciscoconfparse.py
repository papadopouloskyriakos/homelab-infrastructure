#!/usr/bin/env python3
"""
Generate Hierarchical Configuration Diff
Uses ciscoconfparse for proper Cisco config parsing

Usage: generate_diff.py <device_type> <device_name> <gitlab_config_file>
"""
import sys
import os
import json
from pathlib import Path
from netmiko import ConnectHandler

# Try to import ciscoconfparse, fall back to manual parsing if unavailable
try:
    from ciscoconfparse import CiscoConfParse
    HAS_CISCOCONFPARSE = True
except ImportError:
    HAS_CISCOCONFPARSE = False
    print("WARNING: ciscoconfparse not available, using manual parsing", file=sys.stderr)

sys.path.insert(0, os.path.dirname(__file__))
from filter_dynamic_content import DynamicContentFilter

class CiscoConfigParser:
    """Parse Cisco configs using ciscoconfparse"""
    
    def __init__(self, device_type='Router'):
        self.device_type = device_type
        self.filter = DynamicContentFilter()
        
        # Determine syntax for ciscoconfparse
        self.syntax_map = {
            'Firewall': 'asa',
            'Router': 'ios',
            'Switch': 'ios',
            'Access-Point': 'ios',
        }
        self.syntax = self.syntax_map.get(device_type, 'ios')
    
    def parse_config(self, config_text):
        """
        Parse config into hierarchical structure using ciscoconfparse
        
        Returns:
            List of dicts with 'parents' and 'lines' keys
        """
        # Filter dynamic content first
        filtered_config = self.filter.filter_config(config_text)
        
        if HAS_CISCOCONFPARSE:
            return self._parse_with_ciscoconfparse(filtered_config)
        else:
            return self._parse_manual(filtered_config)
    
    def _parse_with_ciscoconfparse(self, config_text):
        """Parse using ciscoconfparse (preferred method)"""
        lines = config_text.split('\n')
        parse = CiscoConfParse(lines, syntax=self.syntax)
        
        blocks = []
        
        # Get all parent objects (lines with children)
        for obj in parse.find_objects(r'^.+'):
            # Skip if this is a child of another object
            if obj.parent and obj.parent != obj:
                continue
            
            # Check if this object has children
            if obj.children:
                # Parent with children
                parent_line = obj.text.strip()
                child_lines = [child.text.strip() for child in obj.children]
                
                if child_lines:
                    blocks.append({
                        'parents': [parent_line],
                        'lines': child_lines
                    })
            else:
                # Global command (no parent, no children)
                blocks.append({
                    'parents': [],
                    'lines': [obj.text.strip()]
                })
        
        return blocks
    
    def _parse_manual(self, config_text):
        """Fallback manual parsing based on indentation"""
        blocks = []
        current_parents = []
        current_lines = []
        
        lines = config_text.split('\n')
        
        for line in lines:
            # Skip empty lines and comments
            if not line.strip() or line.strip().startswith('!'):
                continue
            
            # Determine indentation level
            indent = len(line) - len(line.lstrip())
            stripped = line.strip()
            
            if indent == 0:
                # Save previous block
                if current_parents or current_lines:
                    blocks.append({
                        'parents': list(current_parents),
                        'lines': list(current_lines)
                    })
                    current_lines = []
                
                # Check if parent command
                if self._is_parent_command(stripped):
                    current_parents = [stripped]
                else:
                    current_parents = []
                    current_lines = [stripped]
            else:
                # Child command (indented)
                current_lines.append(stripped)
        
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
            # IOS/ASA common
            'interface ',
            'router ',
            'line ',
            'class-map ',
            'policy-map ',
            'route-map ',
            'crypto ',
            'aaa ',
            'vrf definition ',
            # ASA-specific
            'object-group ',
            'object network ',
            'object service ',
            'tunnel-group ',
            'group-policy ',
            'dns server-group ',
            'dhcpd ',
            'webvpn ',
            'ssl trust-point ',
            'ldap attribute-map ',
            'nat ',
            'access-list ',
        ]
        
        return any(line.startswith(keyword) for keyword in parent_keywords)

class DiffGenerator:
    """Generate deployment diffs between current and desired configs"""
    
    def __init__(self, device_type='Router'):
        self.device_type = device_type
        self.parser = CiscoConfigParser(device_type)
        self.filter = DynamicContentFilter()
    
    def normalize_line(self, line):
        """Normalize line for comparison"""
        return ' '.join(line.split())
    
    def fetch_device_config(self, device_type, device_name):
        """Fetch current running config from device"""
        username = os.getenv('CISCO_USER', 'kyriakosp')
        password = os.getenv('CISCO_PASSWORD')
        
        if not password:
            raise Exception("CISCO_PASSWORD environment variable not set")
        
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
        print(f"Parsing configs with ciscoconfparse: {HAS_CISCOCONFPARSE}", file=sys.stderr)
        
        # Parse both configs
        current_blocks = self.parser.parse_config(current_config)
        desired_blocks = self.parser.parse_config(desired_config)
        
        print(f"Parsed {len(current_blocks)} current blocks, {len(desired_blocks)} desired blocks", file=sys.stderr)
        
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
        """Build map of context -> lines"""
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
    """Main function to generate deployment diff"""
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
    
    # Create generator with device type
    generator = DiffGenerator(device_type)
    
    try:
        current_config = generator.fetch_device_config(device_type, device_name)
    except Exception as e:
        error_msg = f"Could not fetch current config from device: {str(e)}"
        print(f"ERROR: {error_msg}", file=sys.stderr)
        
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
    
    # Show preview
    for i, block in enumerate(diff_blocks[:3], 1):
        parents = block.get('parents', [])
        lines = block.get('lines', [])
        desc = block.get('description', '')
        
        context = parents[0] if parents else '[GLOBAL]'
        print(f"Block {i}: {desc}", file=sys.stderr)
        print(f"  Context: {context}", file=sys.stderr)
        print(f"  Commands: {len(lines)}", file=sys.stderr)
    
    if len(diff_blocks) > 3:
        print(f"... and {len(diff_blocks) - 3} more blocks", file=sys.stderr)
    
    print("", file=sys.stderr)
    
    # Output JSON to stdout
    output = {
        'diff_blocks': diff_blocks,
        'baseline': 'live_device',
        'device_name': device_name,
        'device_type': device_type,
        'parser': 'ciscoconfparse' if HAS_CISCOCONFPARSE else 'manual'
    }
    
    json_output = json.dumps(output, indent=2, ensure_ascii=False)
    print(json_output)

def main():
    """Main entry point"""
    try:
        if len(sys.argv) != 4:
            print("Usage: generate_diff.py <device_type> <device_name> <gitlab_config_file>", file=sys.stderr)
            print("", file=sys.stderr)
            print("Example:", file=sys.stderr)
            print("  generate_diff.py Firewall nlfw01 network/configs/Firewall/nlfw01", file=sys.stderr)
            print(json.dumps({"diff_blocks": [], "error": "Invalid arguments"}))
            sys.exit(1)
        
        device_type = sys.argv[1]
        device_name = sys.argv[2]
        gitlab_config_file = sys.argv[3]
        
        valid_types = ['Router', 'Switch', 'Firewall', 'Access-Point']
        if device_type not in valid_types:
            print(f"ERROR: Invalid device type: {device_type}", file=sys.stderr)
            print(json.dumps({"diff_blocks": [], "error": f"Invalid device type: {device_type}"}))
            sys.exit(1)
        
        generate_deployment_diff(device_type, device_name, gitlab_config_file)
        
    except Exception as e:
        print(f"ERROR: {str(e)}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        
        error_output = {
            "diff_blocks": [],
            "error": str(e),
            "error_type": type(e).__name__
        }
        print(json.dumps(error_output, indent=2))
        sys.exit(1)

if __name__ == "__main__":
    main()