#!/usr/bin/env bash
# pve_drift_gate.sh — Pre-deploy drift gate for PVE configs
#
# 3-way compare: live PVE config vs HEAD vs HEAD^ for each VMID being deployed.
# Blocks deployment if PVE has changes not accounted for in Git history.
#
# Logic per VMID:
#   1. Fetch live config from PVE host (normalized)
#   2. Get HEAD config (the commit being deployed, normalized)
#   3. Get HEAD^ config (previous commit, normalized)
#   4. If live == HEAD → no drift, safe to deploy
#   5. If live == HEAD^ → PVE hasn't applied the previous commit yet, safe
#   6. If live != HEAD and live != HEAD^ → PVE has manual changes, BLOCK
#
# Usage:
#   pve_drift_gate.sh <config_type> <pve_host> <vmid>
#     config_type: "lxc" or "qemu"
#     pve_host: e.g. "nl-pve01"
#     vmid: e.g. "101100103"
#
# Exit codes: 0=safe to deploy, 1=error, 2=drift detected (block deploy)

set -euo pipefail

CONFIG_TYPE="${1:?Usage: pve_drift_gate.sh <lxc|qemu> <pve_host> <vmid>}"
PVE_HOST="${2:?Usage: pve_drift_gate.sh <lxc|qemu> <pve_host> <vmid>}"
VMID="${3:?Usage: pve_drift_gate.sh <lxc|qemu> <pve_host> <vmid>}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=pve_normalize_config.sh
source "${SCRIPT_DIR}/pve_normalize_config.sh"

GIT_ROOT="$(cd "${SCRIPT_DIR}" && git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$GIT_ROOT" ]]; then
  echo "ERROR: Not inside a Git repository" >&2
  exit 1
fi

# SSH key
if [[ -f "${HOME}/.ssh/id_ed25519" ]]; then
  SSH_KEY="${HOME}/.ssh/id_ed25519"
elif [[ -f "${HOME}/.ssh/one_key" ]]; then
  SSH_KEY="${HOME}/.ssh/one_key"
else
  echo "ERROR: No SSH key found" >&2
  exit 1
fi

SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=10 -o BatchMode=yes -i ${SSH_KEY}"

# PVE remote path
case "$CONFIG_TYPE" in
  lxc)  REMOTE_DIR="/etc/pve/lxc" ;;
  qemu) REMOTE_DIR="/etc/pve/qemu-server" ;;
  *)    echo "ERROR: config_type must be 'lxc' or 'qemu'" >&2; exit 1 ;;
esac

GIT_PATH="pve/${PVE_HOST}/${CONFIG_TYPE}/${VMID}.conf"

echo "Drift gate: ${CONFIG_TYPE}/${VMID} on ${PVE_HOST}"

# ---------------------------------------------------------------------------
# Step 1: Fetch live config from PVE (normalized)
# ---------------------------------------------------------------------------

# shellcheck disable=SC2086
LIVE_RAW=$(ssh ${SSH_OPTS} "root@${PVE_HOST}" "cat ${REMOTE_DIR}/${VMID}.conf 2>/dev/null" || true)

if [[ -z "$LIVE_RAW" ]]; then
  echo "  Container/VM ${VMID} not found on ${PVE_HOST} — new deployment, no drift possible"
  exit 0
fi

LIVE_NORMALIZED=$(echo "$LIVE_RAW" | normalize_pve_config)

# ---------------------------------------------------------------------------
# Step 2: Get HEAD config (the commit being deployed, normalized)
# ---------------------------------------------------------------------------

HEAD_RAW=$(git -C "$GIT_ROOT" show "HEAD:${GIT_PATH}" 2>/dev/null || true)

if [[ -z "$HEAD_RAW" ]]; then
  echo "  Config not in HEAD (file was deleted?) — skipping drift gate"
  exit 0
fi

HEAD_NORMALIZED=$(echo "$HEAD_RAW" | normalize_pve_config)

# ---------------------------------------------------------------------------
# Step 3: Compare live vs HEAD
# ---------------------------------------------------------------------------

if [[ "$LIVE_NORMALIZED" == "$HEAD_NORMALIZED" ]]; then
  echo "  PASS: PVE matches HEAD — no drift"
  exit 0
fi

# ---------------------------------------------------------------------------
# Step 4: Get HEAD^ config (previous commit, normalized)
# ---------------------------------------------------------------------------

PREV_RAW=$(git -C "$GIT_ROOT" show "HEAD^:${GIT_PATH}" 2>/dev/null || true)

if [[ -n "$PREV_RAW" ]]; then
  PREV_NORMALIZED=$(echo "$PREV_RAW" | normalize_pve_config)

  if [[ "$LIVE_NORMALIZED" == "$PREV_NORMALIZED" ]]; then
    echo "  PASS: PVE matches HEAD^ — deploy pipeline hasn't applied yet, safe"
    exit 0
  fi
fi

# ---------------------------------------------------------------------------
# Step 5: True drift — PVE has changes not in Git history
# ---------------------------------------------------------------------------

echo ""
echo "  DRIFT DETECTED: ${CONFIG_TYPE}/${VMID} on ${PVE_HOST}"
echo "  PVE has manual changes not present in HEAD or HEAD^"
echo ""
echo "  Action required:"
echo "    1. Run: sync_pve_drift (manual trigger in CI) to sync PVE state to Git"
echo "    2. Rebase your commit on top of the synced state"
echo "    3. Push again — drift gate will pass"
echo ""
echo "  Diff (HEAD vs PVE live):"
diff --unified=3 \
  <(echo "$HEAD_NORMALIZED") \
  <(echo "$LIVE_NORMALIZED") \
  2>/dev/null | head -30 | sed 's/^/    /' || true

DIFF_LINES=$(diff <(echo "$HEAD_NORMALIZED") <(echo "$LIVE_NORMALIZED") 2>/dev/null | wc -l || echo "0")
if [[ "$DIFF_LINES" -gt 30 ]]; then
  echo "    ... ($((DIFF_LINES - 30)) more lines)"
fi

exit 2
