#!/usr/bin/env bash
# pve_normalize_config.sh — Shared normalization function for PVE configs
# Source this file; do not execute directly.
#
# Usage:
#   source pve_normalize_config.sh
#   cat config.conf | normalize_pve_config

normalize_pve_config() {
  sed -E '
    # Remove HTML template comment headers (Proxmox Helper Scripts)
    /^#/d

    # Remove transient lock lines
    /^lock:/d

    # Remove snapshot metadata
    /^parent:/d
    /^snaptime:/d

    # Trim trailing whitespace
    s/[[:space:]]+$//
  ' | awk '
    # Remove [pve:pending] and [snapshot-*] sections (and their contents)
    BEGIN { skip = 0 }
    /^\[pve:pending\]/ { skip = 1; next }
    /^\[snapshot-/     { skip = 1; next }
    /^\[/              { skip = 0 }
    skip { next }
    # Skip blank lines
    /^[[:space:]]*$/ { next }
    { print }
  ' | sed -E '
    # Normalize key: value — collapse multiple spaces after colon to single space
    s/^([a-zA-Z0-9._-]+):[[:space:]]+/\1: /
  ' | sort
}
