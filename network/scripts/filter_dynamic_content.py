#!/usr/bin/env python3
"""
Filter Dynamic Content from Cisco Configs
Removes timestamps, byte counts, and other dynamic content that causes false drift

This is used across multiple scripts to ensure consistent comparison behavior.
"""
import re

class DynamicContentFilter:
    """
    Comprehensive filter for Cisco IOS/ASA dynamic content
    
    This filters out content that changes frequently but has no
    configuration impact, such as:
    - Timestamps
    - Configuration byte counts (CRITICAL - changes on every save)
    - Crypto checksums
    - NTP clock periods
    - Uptime information
    """
    
    def __init__(self):
        self.patterns = [
            # ================================================================
            # CONFIGURATION METADATA (changes frequently)
            # ================================================================
            
            # Current configuration byte count - CHANGES ON EVERY CONFIG SAVE
            # Examples:
            #   Current configuration : 10391 bytes
            #   Current configuration : 10380 bytes
            #   ! Current configuration : 123456 bytes
            r'^!\s*Current configuration\s*:\s*\d+\s*bytes.*',
            r'^Current configuration\s*:\s*\d+\s*bytes.*',
            
            # Last configuration change timestamp
            # Example: ! Last configuration change at 21:48:44 CET Sat Nov 22 2025 by kyriakosp
            r'^!\s*Last configuration change at .*',
            
            # NVRAM config last updated
            # Example: ! NVRAM config last updated at 19:13:57 CET Fri Nov 21 2025 by kyriakosp
            r'^!\s*NVRAM config last updated at .*',
            
            # Configuration last modified by
            r'^!\s*Configuration last modified by .*',
            
            # ================================================================
            # CRYPTO & SECURITY (regenerated periodically)
            # ================================================================
            
            # Crypto checksum - changes when config is written
            # Example: ! Cryptochecksum:8ac1ec0b35ccfed1b10e9560ed22aa53
            r'^!\s*Cryptochecksum:.*',
            r'^Cryptochecksum:.*',
            
            # ================================================================
            # NTP & TIMING (drifts over time)
            # ================================================================
            
            # NTP clock period - adjusts based on clock drift
            # Example: ntp clock-period 17208098
            r'^ntp clock-period\s+\d+',
            
            # ================================================================
            # UPTIME & RUNTIME INFO
            # ================================================================
            
            # Uptime strings
            # Examples:
            #   uptime is 2 weeks, 3 days, 4 hours, 30 minutes
            #   ASA up 45 days 3 hours
            r'.*uptime is.*',
            r'.*\d+\s+(year|week|day|hour|minute)s?.*',
            
            # ================================================================
            # BUILD & VERSION INFO (shown in comments)
            # ================================================================
            
            # Building configuration messages
            r'^Building configuration.*',
            
            # Compilation timestamps in comments
            # Example: ! Image: Compiled: Thu 03-Dec-15 14:44 by prod_rel_team
            r'^!\s*Image:.*Compiled.*',
            
            # ================================================================
            # TIMESTAMPS IN VARIOUS FORMATS
            # ================================================================
            
            # Standalone timestamp lines
            # Example: ! 18:45:23.456 CET Mon Jan 15 2025
            r'^!\s*\d{2}:\d{2}:\d{2}\.\d+\s+[A-Z]+\s+\w+\s+\w+\s+\d+\s+\d{4}',
            
            # ================================================================
            # SHOW COMMAND OUTPUT (shouldn't be in config but sometimes is)
            # ================================================================
            
            # Show command headers
            r'^\s*show\s+.*',
            
            # ================================================================
            # EMPTY LINES & STANDALONE COMMENTS
            # ================================================================
            
            # Empty comment lines
            r'^!\s*$',
            
            # Completely empty lines
            r'^\s*$',
        ]
        
        # Compile all patterns for performance
        self.compiled_patterns = [
            re.compile(p, re.IGNORECASE) 
            for p in self.patterns
        ]
    
    def is_dynamic_line(self, line):
        """
        Check if a line contains dynamic content
        
        Args:
            line: Single line of config text
            
        Returns:
            True if line should be filtered, False otherwise
        """
        for pattern in self.compiled_patterns:
            if pattern.match(line):
                return True
        return False
    
    def filter_config(self, config_text):
        """
        Filter dynamic content from configuration text
        
        Args:
            config_text: Full configuration as string
            
        Returns:
            Filtered configuration with dynamic content removed
        """
        filtered_lines = []
        
        for line in config_text.split('\n'):
            # Remove trailing whitespace
            line = line.rstrip()
            
            # Skip dynamic lines
            if self.is_dynamic_line(line):
                continue
            
            # Skip empty lines
            if not line.strip():
                continue
            
            filtered_lines.append(line)
        
        return '\n'.join(filtered_lines)
    
    def filter_config_keep_structure(self, config_text):
        """
        Filter dynamic content but preserve line structure
        
        This replaces dynamic lines with empty comments to maintain
        line numbers for debugging.
        
        Args:
            config_text: Full configuration as string
            
        Returns:
            Filtered configuration with dynamic lines replaced by '!'
        """
        filtered_lines = []
        
        for line in config_text.split('\n'):
            # Check if line is dynamic
            if self.is_dynamic_line(line):
                # Replace with empty comment to preserve line numbers
                filtered_lines.append('!')
            else:
                filtered_lines.append(line.rstrip())
        
        return '\n'.join(filtered_lines)

# Convenience function for simple usage
def filter_cisco_config(config_text):
    """
    Convenience function to filter dynamic content from config
    
    Args:
        config_text: Full configuration as string
        
    Returns:
        Filtered configuration string
    """
    filter_obj = DynamicContentFilter()
    return filter_obj.filter_config(config_text)

def main():
    """
    Command-line interface for testing filter
    
    Usage: python3 filter_dynamic_content.py < config.txt
    """
    import sys
    
    if sys.stdin.isatty():
        print("Usage: filter_dynamic_content.py < config_file.txt", file=sys.stderr)
        print("", file=sys.stderr)
        print("Example:", file=sys.stderr)
        print("  python3 filter_dynamic_content.py < nlsw01.cfg", file=sys.stderr)
        sys.exit(1)
    
    # Read config from stdin
    config_text = sys.stdin.read()
    
    # Filter and output
    filtered = filter_cisco_config(config_text)
    print(filtered)

if __name__ == "__main__":
    main()