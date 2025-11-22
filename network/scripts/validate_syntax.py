#!/usr/bin/env python3
"""
Syntax Validation Script
Validates Cisco configuration syntax using ciscoconfparse

Exit codes:
  0 = Valid syntax
  1 = Syntax errors detected
"""
import sys
import os
from pathlib import Path
from ciscoconfparse import CiscoConfParse

def validate_syntax(config_file):
    """
    Validate Cisco configuration file syntax
    """
    config_path = Path(config_file)
    
    if not config_path.exists():
        print(f"❌ Config file not found: {config_file}")
        return 1
    
    print(f"📖 Validating: {config_file}")
    
    # Read config file
    with open(config_path) as f:
        config_lines = f.readlines()
    
    if not config_lines:
        print(f"❌ Config file is empty")
        return 1
    
    # Check for minimum expected content
    has_hostname = any('hostname' in line for line in config_lines)
    has_interface = any('interface' in line for line in config_lines)
    
    # Determine device type from path
    device_type = str(config_path).split('/')[2] if len(str(config_path).split('/')) > 2 else "Unknown"
    
    # Basic validation
    validation_errors = []
    
    # 1. Check for basic required elements
    if not has_hostname:
        validation_errors.append("Missing 'hostname' command")
    
    # 2. Device-type specific validation
    if device_type in ['Switch', 'Router', 'Access-Point']:
        if not has_interface:
            validation_errors.append(f"{device_type} config missing 'interface' configuration")
    
    # 3. Parse config with ciscoconfparse
    try:
        parse = CiscoConfParse(config_lines)
        print(f"✅ Config parsed successfully")
        
        # Get some basic stats
        interfaces = parse.find_objects(r'^interface')
        vlans = parse.find_objects(r'^vlan')
        
        print(f"   📊 Statistics:")
        print(f"      Interfaces: {len(interfaces)}")
        print(f"      VLANs: {len(vlans)}")
        
        # Check for common configuration issues
        
        # Check for interfaces without descriptions (warning only)
        no_desc_count = 0
        for intf in interfaces:
            if not intf.re_search_children(r'^\s+description'):
                no_desc_count += 1
        
        if no_desc_count > 0:
            print(f"   ⚠️  {no_desc_count} interfaces without descriptions (non-critical)")
        
        # Check for unshut interfaces without IP addresses (switches OK)
        if device_type == 'Router':
            for intf in interfaces:
                has_ip = bool(intf.re_search_children(r'^\s+ip address'))
                is_shutdown = bool(intf.re_search_children(r'^\s+shutdown'))
                intf_name = intf.text.strip()
                
                if not has_ip and not is_shutdown and 'loopback' not in intf_name.lower():
                    print(f"   ⚠️  Interface {intf_name} is up but has no IP address")
        
    except Exception as e:
        validation_errors.append(f"Parse error: {str(e)}")
    
    # 4. Check for malformed lines
    line_num = 0
    for line in config_lines:
        line_num += 1
        stripped = line.strip()
        
        # Skip empty lines and comments
        if not stripped or stripped.startswith('!'):
            continue
        
        # Check for common syntax issues
        if stripped.startswith('  ') and not stripped[2:3].strip():
            # Triple space or more (likely formatting error)
            validation_errors.append(f"Line {line_num}: Excessive indentation")
        
        # Check for incomplete commands
        if stripped.endswith('\\'):
            validation_errors.append(f"Line {line_num}: Incomplete command (ends with backslash)")
    
    # Report results
    if validation_errors:
        print(f"\n❌ Validation failed with {len(validation_errors)} errors:")
        for i, error in enumerate(validation_errors, 1):
            print(f"   {i}. {error}")
        return 1
    
    print(f"\n✅ Syntax validation passed")
    return 0

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: validate_syntax.py <config_file>")
        print("Example: validate_syntax.py network/configs/Switch/nlsw01")
        sys.exit(1)
    
    config_file = sys.argv[1]
    sys.exit(validate_syntax(config_file))