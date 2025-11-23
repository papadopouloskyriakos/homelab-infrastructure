#!/usr/bin/env python3
"""
Dynamic Content Filter for Cisco Configurations

Filters out content that changes automatically but doesn't represent
actual configuration changes. Handles differences between Oxidized
backups and direct show running-config output.

Key Normalizations:
- Removes Oxidized-specific exclamation mark separators
- Removes "Current configuration" size lines
- Filters timestamps, crypto checksums, NTP clock periods
- Normalizes whitespace and empty lines
"""
import re


class DynamicContentFilter:
    """
    Comprehensive filter for dynamic content in Cisco configs
    
    Handles both Oxidized backup format and direct device output format
    """
    
    def __init__(self):
        # Patterns for lines to completely remove
        self.removal_patterns = [
            # Timestamps and last modified indicators
            r'^!\s*Last configuration change at.*$',
            r'^!\s*NVRAM config last updated at.*$',
            r'^!\s*Configuration last modified by.*$',
            
            # Crypto checksums (change on every write)
            r'^!\s*Cryptochecksum:.*$',
            r'^Cryptochecksum:.*$',
            
            # NTP clock period (changes automatically)
            r'^ntp clock-period\s+\d+$',
            
            # Current configuration size (changes with every edit)
            r'^!\s*Current configuration\s*:\s*\d+\s*bytes.*$',
            r'^Current configuration\s*:\s*\d+\s*bytes.*$',
            
            # Uptime references (dynamic)
            r'^.*uptime is.*$',
            
            # Boot time references
            r'^.*System returned to ROM by.*$',
            r'^.*System restarted at.*$',
            
            # Oxidized metadata comments
            r'^!\s*Oxidized.*$',
            r'^!\s*Scraped at.*$',
            
            # Empty comment lines from Oxidized (standalone exclamation marks)
            r'^!\s*$',
        ]
        
        # Compile patterns for efficiency
        self.compiled_patterns = [
            re.compile(pattern, re.IGNORECASE | re.MULTILINE)
            for pattern in self.removal_patterns
        ]
    
    def filter_config(self, config_text):
        """
        Filter dynamic content from config
        
        Args:
            config_text: Raw configuration text
            
        Returns:
            Filtered configuration text with dynamic content removed
        """
        if not config_text:
            return ""
        
        lines = config_text.split('\n')
        filtered_lines = []
        
        for line in lines:
            # Skip if line matches any removal pattern
            if any(pattern.match(line) for pattern in self.compiled_patterns):
                continue
            
            # Normalize whitespace
            line = line.rstrip()
            
            # Skip empty lines (but preserve structural indentation)
            if not line:
                continue
            
            filtered_lines.append(line)
        
        # Join lines and ensure consistent line endings
        filtered_config = '\n'.join(filtered_lines)
        
        # Normalize multiple consecutive newlines to single newline
        filtered_config = re.sub(r'\n{3,}', '\n\n', filtered_config)
        
        return filtered_config.strip()
    
    def normalize_oxidized_format(self, config_text):
        """
        Specifically normalize Oxidized backup format
        
        Oxidized adds standalone '!' as section separators.
        Direct device output doesn't have these.
        
        Args:
            config_text: Configuration text (possibly from Oxidized)
            
        Returns:
            Normalized text without Oxidized-specific formatting
        """
        if not config_text:
            return ""
        
        lines = config_text.split('\n')
        normalized_lines = []
        
        for line in lines:
            stripped = line.strip()
            
            # Skip standalone exclamation marks (Oxidized separators)
            if stripped == '!':
                continue
            
            # Skip "Current configuration" size lines
            if re.match(r'^(!)?\s*Current configuration\s*:', line, re.IGNORECASE):
                continue
            
            normalized_lines.append(line.rstrip())
        
        return '\n'.join(normalized_lines)
    
    def compare_configs(self, config1, config2):
        """
        Compare two configs with full normalization
        
        This does comprehensive filtering and normalization for both configs
        before comparison, handling Oxidized format differences.
        
        Args:
            config1: First configuration text
            config2: Second configuration text
            
        Returns:
            (are_equal, filtered_config1, filtered_config2)
        """
        # First normalize Oxidized-specific formatting
        norm1 = self.normalize_oxidized_format(config1)
        norm2 = self.normalize_oxidized_format(config2)
        
        # Then filter dynamic content
        filtered1 = self.filter_config(norm1)
        filtered2 = self.filter_config(norm2)
        
        # Compare
        are_equal = filtered1 == filtered2
        
        return are_equal, filtered1, filtered2


def filter_for_comparison(config_text):
    """
    Convenience function for filtering config text
    
    Args:
        config_text: Raw configuration text
        
    Returns:
        Filtered configuration text
    """
    filter_obj = DynamicContentFilter()
    
    # Apply both normalizations
    normalized = filter_obj.normalize_oxidized_format(config_text)
    filtered = filter_obj.filter_config(normalized)
    
    return filtered


if __name__ == "__main__":
    # Test filtering
    import sys
    
    if len(sys.argv) > 1:
        with open(sys.argv[1]) as f:
            config = f.read()
        
        filtered = filter_for_comparison(config)
        print(filtered)
    else:
        print("Usage: filter_dynamic_content.py <config_file>")
        print("  Filters and normalizes Cisco configuration for comparison")