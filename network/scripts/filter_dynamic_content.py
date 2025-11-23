#!/usr/bin/env python3
"""
Enhanced dynamic content filter for Cisco configurations.
"""
import re

class DynamicContentFilter:
    def __init__(self):
        """Define removal patterns for dynamic content."""
        # SUPER AGGRESSIVE patterns - match anything that could vary
        self.removal_patterns = [
            # Building configuration - any variation
            r'.*[Bb]uilding.*[Cc]onfiguration.*',
            
            # Current configuration with byte count - ANY variation
            r'.*[Cc]urrent.*[Cc]onfiguration.*\d+.*[Bb]ytes.*',
            r'.*[Cc]urrent.*[Cc]onfiguration.*:.*\d+.*',
            
            # Last configuration change - any variation
            r'.*[Ll]ast.*[Cc]onfiguration.*[Cc]hange.*',
            
            # NVRAM config - any variation
            r'.*NVRAM.*[Cc]onfig.*[Uu]pdated.*',
            
            # Configuration last modified
            r'.*[Cc]onfiguration.*[Mm]odified.*',
            
            # Crypto checksums
            r'.*[Cc]ryptochecksum.*',
            
            # NTP clock period
            r'.*ntp\s+clock-period.*',
            
            # Uptime
            r'.*uptime.*',
            
            # Standalone ! lines
            r'^\s*!\s*$',
        ]
        
        self.compiled_patterns = [
            re.compile(p, re.IGNORECASE) 
            for p in self.removal_patterns
        ]
    
    def is_dynamic_line(self, line):
        """Check if a line contains dynamic content."""
        # Strip and check
        stripped = line.strip()
        
        # Empty line
        if not stripped:
            return True
        
        # Just "!"
        if stripped == '!':
            return True
        
        # Check all patterns
        for pattern in self.compiled_patterns:
            if pattern.search(line):
                return True
        
        return False
    
    def normalize_oxidized_format(self, config_text):
        """Normalize Oxidized backup format differences."""
        if not config_text:
            return ""
        
        lines = []
        for line in config_text.split('\n'):
            line = line.rstrip()
            
            # Skip dynamic lines
            if self.is_dynamic_line(line):
                continue
            
            lines.append(line)
        
        return '\n'.join(lines)
    
    def filter_config(self, config_text):
        """Filter out dynamic content from configuration."""
        if not config_text:
            return ""
        
        filtered_lines = []
        
        for line in config_text.split('\n'):
            line = line.rstrip()
            
            # Skip empty
            if not line:
                continue
            
            # Skip dynamic content
            if self.is_dynamic_line(line):
                continue
            
            filtered_lines.append(line)
        
        # Join and normalize
        filtered = '\n'.join(filtered_lines)
        filtered = re.sub(r'\n{3,}', '\n\n', filtered)
        
        return filtered.strip()
    
    def compare_configs(self, config1, config2):
        """Compare two configurations after filtering dynamic content."""
        # Normalize and filter both
        norm1 = self.normalize_oxidized_format(config1)
        norm2 = self.normalize_oxidized_format(config2)
        
        filtered1 = self.filter_config(norm1)
        filtered2 = self.filter_config(norm2)
        
        # Compare
        are_equal = filtered1 == filtered2
        
        return are_equal, filtered1, filtered2