#!/usr/bin/env python3
"""
Filter dynamic content from configs before comparison
"""
import re

def filter_cisco_config(config_text):
    """
    Remove dynamic/timestamp content that causes false drift detection
    """
    lines = config_text.splitlines()
    filtered_lines = []
    
    for line in lines:
        # Skip timestamp lines
        if any(pattern in line for pattern in [
            'Last configuration change at',
            'NVRAM config last updated at',
            'Configuration last modified by',
            'Cryptochecksum:',
            'ntp clock-period',
            'Building configuration',
            'Current configuration',
        ]):
            continue
        
        # Filter lines with "uptime" (but keep interface descriptions)
        if 'uptime' in line.lower() and 'description' not in line.lower():
            continue
        
        # Filter crypto key generation timestamps
        if re.match(r'^\s*!\s*\d{2}:\d{2}:\d{2}', line):
            continue
        
        filtered_lines.append(line)
    
    return '\n'.join(filtered_lines)