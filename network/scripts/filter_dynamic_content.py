#!/usr/bin/env python3
"""
Enhanced dynamic content filter for Cisco configurations.

This module filters out dynamic/timestamp content that changes automatically
but doesn't represent actual configuration drift, including:
- Timestamps (Last configuration change, NVRAM config last updated)
- Byte counts in "Current configuration" headers
- Crypto checksums
- NTP clock periods
- Uptime information
- Building configuration messages
"""
import re

class DynamicContentFilter:
    def __init__(self):
        """
        Define removal patterns for dynamic content.
        
        Patterns are intentionally permissive to catch format variations.
        """
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
            
            # Empty lines (will be handled separately but included for completeness)
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
        
        Args:
            config_text: Raw configuration text
            
        Returns:
            Normalized configuration text
        """
        if not config_text:
            return ""
        
        lines = []
        for line in config_text.split('\n'):
            # Strip trailing whitespace
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
        
        Args:
            config_text: Configuration text (pre-normalized)
            
        Returns:
            Filtered configuration text
        """
        if not config_text:
            return ""
        
        filtered_lines = []
        
        for line in config_text.split('\n'):
            # Strip trailing whitespace first
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
        
        # Reduce multiple consecutive blank lines to single blank line
        filtered = re.sub(r'\n{3,}', '\n\n', filtered)
        
        return filtered.strip()
    
    def compare_configs(self, config1, config2):
        """
        Compare two configurations after filtering dynamic content.
        
        Args:
            config1: First configuration (e.g., live device config)
            config2: Second configuration (e.g., GitLab baseline)
            
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
    
    def get_meaningful_diff(self, config1, config2):
        """
        Generate a diff showing only meaningful configuration differences.
        
        This is useful for debugging - it shows what's actually different
        after filtering out dynamic content.
        
        Args:
            config1: First configuration
            config2: Second configuration
            
        Returns:
            List of diff lines, or empty list if no differences
        """
        are_equal, filtered1, filtered2 = self.compare_configs(config1, config2)
        
        if are_equal:
            return []
        
        import difflib
        
        lines1 = filtered1.split('\n')
        lines2 = filtered2.split('\n')
        
        diff = list(difflib.unified_diff(
            lines2, lines1,
            fromfile='baseline',
            tofile='device',
            lineterm=''
        ))
        
        return diff


# Standalone testing function
def test_filter():
    """Test the filter with sample Cisco output"""
    
    sample_config = """Building configuration...

Current configuration : 10391 bytes
!
! Last configuration change at 21:48:44 CET Sat Nov 22 2025 by kyriakosp
! NVRAM config last updated at 19:13:57 CET Fri Nov 21 2025 by kyriakosp
!
version 15.6
no service pad
service timestamps debug datetime msec
!
hostname nl-lte01
!
ntp clock-period 37378432
!
Cryptochecksum:8ac1ec0b35ccfed1b10e9560ed22aa53
"""
    
    filter_obj = DynamicContentFilter()
    filtered = filter_obj.filter_config(sample_config)
    
    print("=== Original Config ===")
    print(sample_config)
    print("\n=== Filtered Config ===")
    print(filtered)
    print("\n=== Lines Removed ===")
    original_lines = len(sample_config.split('\n'))
    filtered_lines = len(filtered.split('\n'))
    print(f"Original: {original_lines} lines")
    print(f"Filtered: {filtered_lines} lines")
    print(f"Removed: {original_lines - filtered_lines} lines")


if __name__ == "__main__":
    test_filter()