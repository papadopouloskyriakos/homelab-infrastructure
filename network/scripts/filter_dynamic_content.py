#!/usr/bin/env python3
import re

class DynamicContentFilter:
    def __init__(self):
        self.removal_patterns = [
            r'^!\s*Last configuration change at.*$',
            r'^!\s*NVRAM config last updated at.*$',
            r'^!\s*Configuration last modified by.*$',
            r'^!\s*Cryptochecksum:.*$',
            r'^Cryptochecksum:.*$',
            r'^ntp clock-period\s+\d+$',
            r'^!\s*Current configuration\s*:\s*\d+\s*bytes.*$',
            r'^Current configuration\s*:\s*\d+\s*bytes.*$',
            r'^.*uptime is.*$',
            r'^!\s*$',
        ]
        self.compiled_patterns = [re.compile(p, re.IGNORECASE | re.MULTILINE) for p in self.removal_patterns]
    
    def normalize_oxidized_format(self, config_text):
        if not config_text:
            return ""
        lines = []
        for line in config_text.split('\n'):
            stripped = line.strip()
            if stripped == '!':
                continue
            if re.match(r'^(!)?\s*Current configuration\s*:', line, re.IGNORECASE):
                continue
            lines.append(line.rstrip())
        return '\n'.join(lines)
    
    def filter_config(self, config_text):
        if not config_text:
            return ""
        lines = []
        for line in config_text.split('\n'):
            if any(pattern.match(line) for pattern in self.compiled_patterns):
                continue
            line = line.rstrip()
            if not line:
                continue
            lines.append(line)
        filtered = '\n'.join(lines)
        filtered = re.sub(r'\n{3,}', '\n\n', filtered)
        return filtered.strip()
    
    def compare_configs(self, config1, config2):
        norm1 = self.normalize_oxidized_format(config1)
        norm2 = self.normalize_oxidized_format(config2)
        filtered1 = self.filter_config(norm1)
        filtered2 = self.filter_config(norm2)
        are_equal = filtered1 == filtered2
        return are_equal, filtered1, filtered2