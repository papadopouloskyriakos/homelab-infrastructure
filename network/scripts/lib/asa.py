"""
Cisco ASA support for hier_config and the v2 pipeline.

ASA configs differ from IOS in several ways that require special handling:

1. Header/footer: `: Saved`, `: Serial Number`, `Cryptochecksum`, `: end`
2. `!` used as section separators (not config commands) — must be stripped
3. Flat ordered commands: `access-list`, `nat (iface,iface)` — not hierarchical,
   order-dependent, and may have duplicate remark lines
4. Hierarchical blocks: `object network`, `object-group`, `tunnel-group`,
   `group-policy`, `policy-map`, `class-map` — indentation-based like IOS
5. Multi-level tunnel-groups: `tunnel-group X type`, `tunnel-group X general-attributes`,
   `tunnel-group X ipsec-attributes` are separate blocks for the same tunnel
6. `nameif` on interfaces defines the security zone name used everywhere else
7. `write memory` to save (not `copy running startup`)
8. No `enable` mode separation — ASA always runs in enable after login

This module provides:
- `prepare_asa_config()` — full preprocessing pipeline for hierconfig
- `get_asa_hconfig()` — hierconfig loader after preprocessing
- `strip_remark_sequences()` — cleanup before sending commands to device
"""
import re

from hier_config import get_hconfig_fast_load, Platform


# ASA-specific lines to strip (beyond what filter_dynamic_content.py handles)
ASA_STRIP_PATTERNS = [
    # Header metadata lines
    re.compile(r"^:\s*$"),
    re.compile(r"^: Saved\s*$"),
    re.compile(r"^: Serial Number:"),
    re.compile(r"^: Hardware:"),
    # Footer
    re.compile(r"^: end\s*$"),
    # Cryptochecksum (also in base filter, but belt-and-suspenders)
    re.compile(r"^Cryptochecksum:", re.IGNORECASE),
    # ! separator lines — ASA uses these as visual separators, not config commands.
    # hierconfig treats them as duplicate top-level sections and errors out.
    re.compile(r"^\s*!\s*$"),
]


def strip_asa_dynamic(config_text: str) -> str:
    """
    Strip ASA-specific dynamic/metadata lines that break hierconfig parsing.

    Should be applied AFTER the base DynamicContentFilter and BEFORE hierconfig.
    Also strips `!` separator lines.
    """
    lines = []
    for line in config_text.splitlines():
        if any(p.match(line) for p in ASA_STRIP_PATTERNS):
            continue
        lines.append(line)
    return "\n".join(lines)


def deduplicate_top_level(config_text: str) -> str:
    """
    Deduplicate identical top-level section headers.

    ASA configs have two patterns that produce duplicates:
    1. `access-list X remark [text]` — same remark text repeated
    2. `object network X` — appears once for definition (host/subnet)
       and again later for NAT rule. This is standard ASA behavior.

    We append a sequence number `{#N}` to the Nth occurrence of each
    duplicate top-level line, making them unique for hierconfig parsing.
    The markers are stripped before deployment via strip_dedup_markers().
    """
    seen = {}
    lines = []
    for line in config_text.splitlines():
        stripped = line.strip()
        # Only deduplicate top-level lines (no leading whitespace)
        if stripped and not line.startswith(" ") and not line.startswith("\t"):
            count = seen.get(stripped, 0) + 1
            seen[stripped] = count
            if count > 1:
                line = f"{line} {{#{count}}}"
        lines.append(line)
    return "\n".join(lines)


def strip_dedup_markers(remediation_text: str) -> str:
    """Strip the dedup sequence markers before sending commands to device."""
    return re.sub(r"\s*\{#\d+\}", "", remediation_text)


def prepare_asa_config(config_text: str, base_filter=None) -> str:
    """
    Full ASA config preparation pipeline for hierconfig parsing.

    1. Apply base dynamic content filter (timestamps, byte counts, etc.)
    2. Strip ASA-specific metadata (: headers, !, Cryptochecksum, : end)
    3. Deduplicate remark lines to avoid hierconfig duplicate errors
    4. Strip leading/trailing blank lines
    """
    if base_filter:
        config_text = base_filter.filter_config(config_text)
    config_text = strip_asa_dynamic(config_text)
    config_text = deduplicate_top_level(config_text)

    # Strip leading/trailing blank lines
    lines = config_text.splitlines()
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()

    return "\n".join(lines)


def get_asa_hconfig(config_text: str):
    """
    Parse a preprocessed ASA config with hierconfig.

    The config_text MUST be processed by prepare_asa_config() first.
    Uses GENERIC platform since hier_config has no ASA platform.
    """
    return get_hconfig_fast_load(Platform.GENERIC, config_text)
