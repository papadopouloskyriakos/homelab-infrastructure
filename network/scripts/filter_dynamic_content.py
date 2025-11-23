#!/usr/bin/env python3
"""
Enhanced dynamic content filter for Cisco configurations.

This module filters out dynamic/timestamp content that changes automatically
but doesn't represent actual configuration drift.
"""
import re

class DynamicContentFilter:
    def __init__(self):
        """Define removal patterns for dynamic content."""
        self.removal_patterns = [
            # Building configuration header
            r'^Building configuration\.\.\.\s*$',
            
            # Current configuration byte count (with or without !)
            r'^!\s*Current configuration\s*:\s*\d+\s*bytes.*$',
            r'^Current configuration\s*:\s*\d+\s*bytes.*$',
            
            # Last configuration change timestamp
            r'^!\s*Last configuration change at\s+.*$',
            r'^Last configuration change at\s+.*$',
            
            # NVRAM config timestamp
            r'^!\s*NVRAM config last updated at\s+.*$',
            r'^NVRAM config last updated at\s+.*$',
            
            # Configuration last modified by
            r'^!\s*Configuration last modified by\s+.*$',
            r'^Configuration last modified by\s+.*$',
            
            # Crypto checksums
            r'^!\s*Cryptochecksum:.*$',
            r'^Cryptochecksum:.*$',
            
            # NTP clock period (changes automatically)
            r'^ntp clock-period\s+\d+\s*$',
            
            # Uptime information
            r'^.*uptime is.*$',
            r'^.*\d+\s+years?,\s+\d+\s+weeks?.*$',
            
            # Standalone exclamation marks (Oxidized format)
            r'^!\s*$',
            
            # Empty lines
            r'^\s*$',
        ]
        
        # Compile patterns with flags
        self.compiled_patterns = [
            re.compile(p, re.IGNORECASE | re.MULTILINE) 
            for p in self.removal_patterns
        ]
    
    def normalize_oxidized_format(self, config_text):
        """
        Normalize Oxidized backup format differences.
        
        Oxidized adds standalone '!' lines as separators. These aren't in
        live device configs, so we remove them for comparison.
        """
        if not config_text:
            return ""
        
        lines = []
        for line in config_text.split('\n'):
            line = line.rstrip()
            
            # Remove standalone exclamation marks
            if line.strip() == '!':
                continue
            
            # Skip "Building configuration..." lines
            if re.match(r'^\s*Building configuration\.\.\.', line, re.IGNORECASE):
                continue
            
            # Skip "Current configuration" byte count lines
            if re.match(r'^\s*!?\s*Current configuration\s*:\s*\d+', line, re.IGNORECASE):
                continue
            
            lines.append(line)
        
        return '\n'.join(lines)
    
    def filter_config(self, config_text):
        """
        Filter out dynamic content from configuration.
        
        Removes lines matching any of the dynamic content patterns,
        ensuring only actual configuration differences are detected.
        """
        if not config_text:
            return ""
        
        filtered_lines = []
        
        for line in config_text.split('\n'):
            line = line.rstrip()
            
            # Skip empty lines
            if not line:
                continue
            
            # Check if line matches any removal pattern
            if any(pattern.match(line) for pattern in self.compiled_patterns):
                continue
            
            # Keep this line
            filtered_lines.append(line)
        
        # Join lines and normalize excessive blank lines
        filtered = '\n'.join(filtered_lines)
        filtered = re.sub(r'\n{3,}', '\n\n', filtered)
        
        return filtered.strip()
    
    def compare_configs(self, config1, config2):
        """
        Compare two configurations after filtering dynamic content.
        
        Returns:
            Tuple of (are_equal, filtered_config1, filtered_config2)
        """
        # Step 1: Normalize Oxidized format differences
        norm1 = self.normalize_oxidized_format(config1)
        norm2 = self.normalize_oxidized_format(config2)
        
        # Step 2: Filter dynamic content
        filtered1 = self.filter_config(norm1)
        filtered2 = self.filter_config(norm2)
        
        # Step 3: Compare
        are_equal = filtered1 == filtered2
        
        return are_equal, filtered1, filtered2