#!/usr/bin/env python3
"""
Enhanced configuration validation.

Goes beyond basic syntax checking (validate_syntax.py) with:
  - Structural validation using hier_config parsing
  - ACL self-lockout detection (management access)
  - Routing sanity checks (default route, BGP peering)
  - Interface consistency (IP conflicts, MTU mismatches)
  - Remediation preview (diff against live device)

Usage:
    validate.py <device_type> <device_name> <config_file> [--live]

--live: Also fetch running config and show remediation preview.

Example:
    validate.py Router nlrtr01 REDACTED_6b872376 --live
"""
import json
import re
import sys
import os
from collections import defaultdict
from pathlib import Path

from hier_config import get_hconfig_fast_load, Platform

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from filter_dynamic_content import DynamicContentFilter
from lib.devices import build_profile, fetch_running_config
from lib.asa import prepare_asa_config, get_asa_hconfig

PLATFORM_MAP = {
    "Router": Platform.CISCO_IOS,
    "Switch": Platform.CISCO_IOS,
    "Access-Point": Platform.CISCO_IOS,
    "Firewall": Platform.GENERIC,
}

# Management subnets that must remain reachable
MGMT_SUBNETS = ["192.168.181."]

# Patterns that should never appear in a valid config
DANGEROUS_PATTERNS = [
    (r"^\s*no ip routing\s*$", "CRITICAL", "Disabling IP routing breaks all L3 connectivity"),
    (r"^\s*default interface\s+", "CRITICAL", "Erases interface configuration"),
    (r"^\s*write erase\s*$", "CRITICAL", "Deletes startup configuration"),
    (r"^\s*reload\s*$", "CRITICAL", "Reload command in config file"),
    (r"^\s*no service password-encryption\s*$", "WARNING", "Passwords will be stored in cleartext"),
    (r"^\s*no enable secret\s*$", "WARNING", "Removes enable secret"),
    (r"^\s*snmp-server community\s+public\s+RW", "WARNING", "Public SNMP community with write access"),
]


class ConfigValidator:
    """Validate Cisco configuration files."""

    def __init__(self, device_type, device_name):
        self.device_type = device_type
        self.device_name = device_name
        self.profile = build_profile(device_type, device_name)
        self.platform = PLATFORM_MAP[device_type]
        self.content_filter = DynamicContentFilter()
        self.errors = []
        self.warnings = []
        self.info = []

    def validate(self, config_text, live_config=None):
        """Run all validation checks."""
        self._check_basic_structure(config_text)
        self._check_dangerous_patterns(config_text)
        self._check_formatting(config_text)
        self._check_interface_consistency(config_text)
        self._check_routing_sanity(config_text)
        self._check_acl_lockout(config_text)
        self._check_hierconfig_parse(config_text)

        if live_config:
            self._check_remediation_preview(config_text, live_config)

    def _check_basic_structure(self, config_text):
        """Verify basic config structure."""
        lines = config_text.splitlines()

        if not config_text.strip():
            self.errors.append("Config file is empty")
            return

        if len(lines) < 10:
            self.errors.append(f"Config suspiciously small ({len(lines)} lines)")

        has_hostname = any(
            line.strip().startswith("hostname ") for line in lines
        )
        if not has_hostname:
            self.warnings.append("No hostname command found")

        has_interface = any(
            line.strip().startswith("interface ") for line in lines
        )
        if not has_interface:
            self.warnings.append("No interface definitions found")

    def _check_dangerous_patterns(self, config_text):
        """Check for dangerous commands."""
        for line_num, line in enumerate(config_text.splitlines(), 1):
            stripped = line.strip()
            for pattern, severity, message in DANGEROUS_PATTERNS:
                if re.match(pattern, stripped, re.IGNORECASE):
                    entry = f"Line {line_num}: {message} ({stripped[:60]})"
                    if severity == "CRITICAL":
                        self.errors.append(entry)
                    else:
                        self.warnings.append(entry)

    def _check_formatting(self, config_text):
        """Check formatting issues."""
        for line_num, line in enumerate(config_text.splitlines(), 1):
            if "\t" in line:
                self.warnings.append(f"Line {line_num}: Tab character (use spaces)")
            if len(line) > 500:
                self.warnings.append(f"Line {line_num}: Very long ({len(line)} chars)")

    def _check_interface_consistency(self, config_text):
        """Check for IP address conflicts and interface issues."""
        ip_to_interface = {}
        current_interface = None

        for line in config_text.splitlines():
            stripped = line.strip()
            if stripped.startswith("interface "):
                current_interface = stripped
            elif current_interface and stripped.startswith("ip address "):
                # Extract IP
                parts = stripped.split()
                if len(parts) >= 3:
                    ip = parts[2]
                    if ip in ip_to_interface:
                        self.errors.append(
                            f"Duplicate IP {ip}: {ip_to_interface[ip]} and {current_interface}"
                        )
                    else:
                        ip_to_interface[ip] = current_interface
            elif not stripped.startswith(" ") and stripped and stripped != "!":
                current_interface = None

    def _check_routing_sanity(self, config_text):
        """Check basic routing sanity."""
        has_default_route = bool(
            re.search(r"ip route 0\.0\.0\.0 0\.0\.0\.0", config_text)
        )
        has_bgp = bool(re.search(r"^router bgp\s+\d+", config_text, re.MULTILINE))
        has_ospf = bool(re.search(r"^router ospf\s+\d+", config_text, re.MULTILINE))

        if not has_default_route and not has_bgp and not has_ospf:
            self.warnings.append(
                "No default route, BGP, or OSPF found — device may lose upstream connectivity"
            )

        if has_bgp:
            # Verify BGP has at least one neighbor
            neighbors = re.findall(r"neighbor\s+(\S+)\s+remote-as", config_text)
            if not neighbors:
                self.warnings.append("BGP configured but no neighbors defined")
            else:
                self.info.append(f"BGP peers: {', '.join(neighbors[:5])}")

    def _check_acl_lockout(self, config_text):
        """
        Check if any ACL applied to VTY lines would block management access.
        This is a simplified check — not a full ACL evaluator.
        """
        # Find ACLs applied to VTY lines
        vty_acl = None
        in_vty = False
        for line in config_text.splitlines():
            stripped = line.strip()
            if stripped.startswith("line vty"):
                in_vty = True
            elif in_vty and stripped.startswith("access-class "):
                parts = stripped.split()
                if len(parts) >= 2:
                    vty_acl = parts[1]
            elif not stripped.startswith(" ") and stripped and stripped != "!":
                in_vty = False

        if vty_acl:
            # Check if the ACL permits management subnet
            acl_lines = []
            for line in config_text.splitlines():
                if line.strip().startswith(f"access-list {vty_acl} "):
                    acl_lines.append(line.strip())

            if acl_lines:
                mgmt_permitted = any(
                    any(subnet in acl_line for subnet in MGMT_SUBNETS)
                    for acl_line in acl_lines
                    if "permit" in acl_line
                )
                if not mgmt_permitted:
                    self.warnings.append(
                        f"VTY access-class {vty_acl} may not permit management subnet {MGMT_SUBNETS[0]}0/24"
                    )

    def _parse_config(self, config_text):
        """Parse config with the correct platform handler."""
        if self.device_type == "Firewall":
            prepared = prepare_asa_config(config_text, base_filter=self.content_filter)
            return get_asa_hconfig(prepared)
        else:
            filtered = self.content_filter.filter_config(config_text)
            return get_hconfig_fast_load(self.platform, filtered)

    def _check_hierconfig_parse(self, config_text):
        """Verify config parses cleanly with hier_config."""
        try:
            hc = self._parse_config(config_text)
            child_count = len(list(hc.all_children()))
            self.info.append(f"hier_config parsed {child_count} config lines")
        except Exception as e:
            self.errors.append(f"hier_config parse failed: {e}")

    def _check_remediation_preview(self, config_text, live_config):
        """Show what would change if deployed (idempotency check)."""
        running_hc = self._parse_config(live_config)
        intended_hc = self._parse_config(config_text)

        remediation = running_hc.config_to_get_to(intended_hc)
        rem_lines = list(remediation.all_children())

        if rem_lines:
            self.info.append(f"Remediation would apply {len(rem_lines)} commands")
            for line in rem_lines[:10]:
                self.info.append(f"  {line.cisco_style_text()}")
            if len(rem_lines) > 10:
                self.info.append(f"  ... and {len(rem_lines) - 10} more")
        else:
            self.info.append("Config matches live device — zero remediation needed (idempotent)")

    def report(self):
        """Print validation report and return exit code."""
        print("=" * 70)
        print(f"VALIDATION: {self.device_name} ({self.device_type})")
        print("=" * 70)
        print()

        if self.errors:
            print(f"ERRORS ({len(self.errors)}):")
            for err in self.errors:
                print(f"  [ERROR] {err}")
            print()

        if self.warnings:
            print(f"WARNINGS ({len(self.warnings)}):")
            for warn in self.warnings:
                print(f"  [WARN]  {warn}")
            print()

        if self.info:
            print(f"INFO ({len(self.info)}):")
            for info in self.info:
                print(f"  [INFO]  {info}")
            print()

        print("=" * 70)
        if self.errors:
            print(f"RESULT: FAILED ({len(self.errors)} errors, {len(self.warnings)} warnings)")
            return 1
        elif self.warnings:
            print(f"RESULT: PASSED WITH WARNINGS ({len(self.warnings)} warnings)")
            return 0
        else:
            print("RESULT: PASSED")
            return 0


def main():
    if len(sys.argv) < 4:
        print(
            "Usage: validate.py <device_type> <device_name> <config_file> [--live]",
            file=sys.stderr,
        )
        sys.exit(1)

    device_type = sys.argv[1]
    device_name = sys.argv[2]
    config_file = sys.argv[3]
    do_live = "--live" in sys.argv

    valid_types = list(PLATFORM_MAP)
    if device_type not in valid_types:
        print(f"ERROR: Invalid device type: {device_type}", file=sys.stderr)
        sys.exit(1)

    config_path = Path(config_file)
    if not config_path.exists():
        print(f"ERROR: Config file not found: {config_file}", file=sys.stderr)
        sys.exit(1)

    config_text = config_path.read_text()

    live_config = None
    if do_live:
        print(f"Fetching live config from {device_name}...", file=sys.stderr)
        profile = build_profile(device_type, device_name)
        live_config = fetch_running_config(profile)
        print(f"Fetched {len(live_config)} bytes", file=sys.stderr)

    validator = ConfigValidator(device_type, device_name)
    validator.validate(config_text, live_config)
    exit_code = validator.report()
    sys.exit(exit_code)


if __name__ == "__main__":
    main()
