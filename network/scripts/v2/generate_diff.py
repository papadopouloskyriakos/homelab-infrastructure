#!/usr/bin/env python3
"""
Generate configuration remediation using hier_config.

Replaces the hand-rolled parser in generate_diff.py with hier_config,
which correctly handles:
  - Hierarchical parent/child context
  - Ordered commands (access-lists, route-maps)
  - Platform-aware negation (no <command>)
  - Idempotent remediation output

Usage:
    generate_diff.py <device_type> <device_name> <config_file>

Example:
    generate_diff.py Router nlrtr01 REDACTED_6b872376

Output: JSON to stdout with remediation commands.
"""
import json
import sys
import os

from pathlib import Path

from hier_config import get_hconfig_fast_load, Platform

# Allow imports from parent dir
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
from filter_dynamic_content import DynamicContentFilter
from lib.devices import build_profile, fetch_running_config
from lib.asa import prepare_asa_config, get_asa_hconfig, strip_dedup_markers

# Map our device types to hier_config platforms
PLATFORM_MAP = {
    "Router": Platform.CISCO_IOS,
    "Switch": Platform.CISCO_IOS,
    "Access-Point": Platform.CISCO_IOS,
    "Firewall": Platform.GENERIC,  # ASA — uses lib/asa.py preprocessing
}


def _parse_config(device_type, config_text, content_filter):
    """Parse a config with the correct platform handler."""
    if device_type == "Firewall":
        prepared = prepare_asa_config(config_text, base_filter=content_filter)
        return get_asa_hconfig(prepared)
    else:
        filtered = content_filter.filter_config(config_text)
        platform = PLATFORM_MAP[device_type]
        return get_hconfig_fast_load(platform, filtered)


def generate_remediation(device_type, device_name, config_file):
    """Generate remediation config from running vs intended."""
    profile = build_profile(device_type, device_name)
    content_filter = DynamicContentFilter()

    # Load intended config from git
    config_path = Path(config_file)
    if not config_path.exists():
        print(f"ERROR: Config file not found: {config_file}", file=sys.stderr)
        sys.exit(1)

    intended_raw = config_path.read_text()
    print(f"Loaded intended config ({len(intended_raw)} bytes)", file=sys.stderr)

    # Fetch live config from device
    print(f"Fetching live config from {device_name}...", file=sys.stderr)
    running_raw = fetch_running_config(profile)
    print(f"Fetched running config ({len(running_raw)} bytes)", file=sys.stderr)

    # Parse with platform-appropriate handler
    print(f"Generating remediation with hier_config ({device_type})...", file=sys.stderr)
    running_hc = _parse_config(device_type, running_raw, content_filter)
    intended_hc = _parse_config(device_type, intended_raw, content_filter)

    # Generate remediation (running → intended)
    remediation = running_hc.config_to_get_to(intended_hc)

    # Build structured output
    blocks = []
    for child in remediation.children:
        block = {
            "parents": [child.text] if child.children else [],
            "lines": [c.text for c in child.all_children()] if child.children else [child.text],
            "description": f"{'Modify' if child.children else 'Global'}: {child.text[:60]}",
        }
        blocks.append(block)

    # Also generate flat remediation text for NAPALM merge
    remediation_lines = []
    for line in remediation.all_children():
        remediation_lines.append(line.cisco_style_text())
    remediation_text = "\n".join(remediation_lines)

    # Strip ASA dedup markers from remediation before deployment
    if device_type == "Firewall":
        remediation_text = strip_dedup_markers(remediation_text)
        for block in blocks:
            block["lines"] = [strip_dedup_markers(l) for l in block["lines"]]
            block["parents"] = [strip_dedup_markers(p) for p in block["parents"]]
            block["description"] = strip_dedup_markers(block["description"])

    # Show summary
    print(f"Generated {len(blocks)} remediation blocks", file=sys.stderr)
    for i, block in enumerate(blocks[:5], 1):
        desc = block["description"]
        cmds = len(block["lines"])
        print(f"  Block {i}: {desc} ({cmds} commands)", file=sys.stderr)
    if len(blocks) > 5:
        print(f"  ... and {len(blocks) - 5} more", file=sys.stderr)

    output = {
        "diff_blocks": blocks,
        "remediation_text": remediation_text,
        "baseline": "live_device",
        "parser": "hier_config",
        "platform": platform.name,
        "device_name": device_name,
        "device_type": device_type,
    }

    print(json.dumps(output, indent=2))


def main():
    if len(sys.argv) != 4:
        print(
            "Usage: generate_diff.py <device_type> <device_name> <config_file>",
            file=sys.stderr,
        )
        print(
            "\nExample: generate_diff.py Router nlrtr01 "
            "REDACTED_6b872376",
            file=sys.stderr,
        )
        print(json.dumps({"diff_blocks": [], "error": "Invalid arguments"}))
        sys.exit(1)

    device_type = sys.argv[1]
    device_name = sys.argv[2]
    config_file = sys.argv[3]

    valid_types = list(PLATFORM_MAP)
    if device_type not in valid_types:
        print(f"ERROR: Invalid device type: {device_type}", file=sys.stderr)
        print(json.dumps({"diff_blocks": [], "error": f"Invalid device type: {device_type}"}))
        sys.exit(1)

    try:
        generate_remediation(device_type, device_name, config_file)
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc(file=sys.stderr)
        print(json.dumps({"diff_blocks": [], "error": str(e), "error_type": type(e).__name__}))
        sys.exit(1)


if __name__ == "__main__":
    main()
