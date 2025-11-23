#!/usr/bin/env python3
"""
Enhanced dynamic content filter for Cisco configurations.
"""
import re

class DynamicContentFilter:
    def __init__(self):
        """Define removal patterns for dynamic content."""
        self.removal_patterns = [
            # Building configuration headers
            r'^\s*!?\s*Building configuration.*$',

            # Current configuration lines with byte counts
            r'^\s*!?\s*Current configuration\s*:.*\d+\s*bytes\s*$',
            r'^\s*!?\s*Current configuration.*\d+\s*bytes\s*$',

            # Last configuration change (timestamp lines)
            r'^\s*!+\s*Last configuration change.*$',
            r'^\s*Last configuration change\s+at\s+.*$',

            # NVRAM / config updated (with optional comment marker)
            r'^\s*!?\s*NVRAM config last.*$',
            r'^\s*!?\s*Configuration last modified.*$',

            # Crypto checksums
            r'^\s*!?\s*cryptochecksum.*$',

            # NTP clock period
            r'^\s*ntp\s+clock-period\s+\d+.*$',

            # Uptime (conservative pattern)
            r'^\s*!?\s*(uptime|System uptime|router uptime).*$', 
        ]

        self.compiled_patterns = [re.compile(p, re.IGNORECASE) for p in self.removal_patterns]

    def is_dynamic_line(self, line):
        """Check if a line contains dynamic content.
        
        IMPORTANT: blank lines are NOT considered dynamic.
        We preserve single blank lines and collapse multiples later.
        """
        if line is None:
            return False

        for pattern in self.compiled_patterns:
            if pattern.search(line):
                return True

        return False

    def filter_config(self, config_text):
        """Filter out dynamic content in a single pass.
        
        - Removes dynamic content lines
        - Strips trailing whitespace from all lines
        - Preserves single blank lines
        - Collapses multiple blank lines into one
        """
        if not config_text:
            return ""

        filtered_lines = []
        blank_count = 0

        for raw in config_text.splitlines():
            # Strip trailing whitespace (fixes "waas " vs "waas" issue)
            line = raw.rstrip()
            
            # Skip dynamic content
            if self.is_dynamic_line(line):
                continue

            # Blank line handling: collapse multiples into single blank
            if line.strip() == "":
                blank_count += 1
                if blank_count > 1:
                    continue
                filtered_lines.append("")
                continue
            else:
                blank_count = 0

            filtered_lines.append(line)

        # Remove leading/trailing blank lines
        while filtered_lines and filtered_lines[0] == "":
            filtered_lines.pop(0)
        while filtered_lines and filtered_lines[-1] == "":
            filtered_lines.pop()

        return "\n".join(filtered_lines)

    def compare_configs(self, config1, config2):
        """Compare two configurations after filtering dynamic content."""
        filtered1 = self.filter_config(config1)
        filtered2 = self.filter_config(config2)

        are_equal = filtered1 == filtered2
        return are_equal, filtered1, filtered2