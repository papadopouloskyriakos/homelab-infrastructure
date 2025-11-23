#!/usr/bin/env python3
"""
Validate Cisco Configuration Syntax
Basic syntax validation for Cisco IOS/ASA configs

Usage: validate_syntax.py <config_file>

Example: validate_syntax.py network/configs/Router/nl-lte01
"""
import sys
import re
from pathlib import Path

class SyntaxValidator:
    """Validate Cisco configuration syntax"""
    
    def __init__(self):
        self.errors = []
        self.warnings = []
    
    def validate_file(self, config_file):
        """
        Validate configuration file
        
        Returns:
            True if valid, False if errors found
        """
        config_path = Path(config_file)
        
        if not config_path.exists():
            self.errors.append(f"File not found: {config_file}")
            return False
        
        with open(config_path) as f:
            config_text = f.read()
        
        if not config_text.strip():
            self.errors.append("File is empty")
            return False
        
        lines = config_text.split('\n')
        
        # Basic validations
        self._check_basic_structure(lines)
        self._check_dangerous_commands(lines)
        self._check_common_mistakes(lines)
        
        return len(self.errors) == 0
    
    def _check_basic_structure(self, lines):
        """Check for basic config structure"""
        has_hostname = False
        has_commands = False
        
        for line in lines:
            stripped = line.strip()
            
            if stripped.startswith('hostname '):
                has_hostname = True
            
            # Check for at least some configuration commands
            if stripped and not stripped.startswith('!'):
                has_commands = True
        
        if not has_hostname:
            self.warnings.append("No hostname command found")
        
        if not has_commands:
            self.errors.append("No configuration commands found")
    
    def _check_dangerous_commands(self, lines):
        """Check for potentially dangerous commands"""
        dangerous_patterns = [
            (r'^\s*no ip routing\s*$', "Disabling IP routing can break connectivity"),
            (r'^\s*shutdown\s*$', "Shutdown command found (check if intentional)"),
            (r'^\s*no shutdown\s*$', None),  # This is OK
            (r'^\s*default interface', "Default interface command will erase config"),
            (r'^\s*write erase', "Write erase will delete config"),
            (r'^\s*reload', "Reload command found (should not be in config)"),
        ]
        
        in_interface = False
        
        for line_num, line in enumerate(lines, 1):
            stripped = line.strip()
            
            # Track interface context
            if stripped.startswith('interface '):
                in_interface = True
            elif not stripped.startswith(' ') and stripped:
                in_interface = False
            
            # Check dangerous patterns
            for pattern, warning_msg in dangerous_patterns:
                if re.match(pattern, stripped, re.IGNORECASE):
                    if warning_msg:
                        # Special case: shutdown in interface is often OK
                        if pattern.startswith(r'^\s*shutdown') and in_interface:
                            continue
                        
                        self.warnings.append(f"Line {line_num}: {warning_msg}")
    
    def _check_common_mistakes(self, lines):
        """Check for common configuration mistakes"""
        for line_num, line in enumerate(lines, 1):
            stripped = line.strip()
            
            # Check for tabs (should be spaces)
            if '\t' in line:
                self.warnings.append(f"Line {line_num}: Contains tab characters (should use spaces)")
            
            # Check for trailing whitespace
            if line.rstrip() != line.rstrip('\n').rstrip('\r'):
                # Trailing whitespace (not critical)
                pass
            
            # Check for very long lines
            if len(line) > 500:
                self.warnings.append(f"Line {line_num}: Very long line ({len(line)} chars)")
            
            # Check for common typos
            if stripped.startswith('interace '):
                self.errors.append(f"Line {line_num}: Typo - 'interace' should be 'interface'")
            
            if stripped.startswith('descripion '):
                self.errors.append(f"Line {line_num}: Typo - 'descripion' should be 'description'")
    
    def print_results(self):
        """Print validation results"""
        if self.errors:
            print("ERRORS:")
            for error in self.errors:
                print(f"  ERROR: {error}")
            print()
        
        if self.warnings:
            print("WARNINGS:")
            for warning in self.warnings:
                print(f"  WARNING: {warning}")
            print()
        
        if not self.errors and not self.warnings:
            print("Syntax validation: PASS")
            print("No errors or warnings found")

def main():
    """Main entry point"""
    if len(sys.argv) != 2:
        print("Usage: validate_syntax.py <config_file>", file=sys.stderr)
        print("", file=sys.stderr)
        print("Example:", file=sys.stderr)
        print("  validate_syntax.py network/configs/Router/nl-lte01", file=sys.stderr)
        sys.exit(1)
    
    config_file = sys.argv[1]
    
    validator = SyntaxValidator()
    
    is_valid = validator.validate_file(config_file)
    
    validator.print_results()
    
    if is_valid:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()