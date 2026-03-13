#!/usr/bin/env bash
# pve_detect_drift.sh — Bidirectional drift detection for PVE LXC and QEMU configs
#
# Usage:
#   pve_detect_drift.sh [pve_host] [vmid]
#
# Exit codes: 0=no drift, 1=drift found, 2=error

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

PVE_HOSTS="nl-pve01 nl-pve02 nl-pve03"
CONFIG_TYPES="lxc qemu"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=pve_normalize_config.sh
source "${SCRIPT_DIR}/pve_normalize_config.sh"

# Find Git repo root (walk up from script dir)
GIT_ROOT="$(cd "${SCRIPT_DIR}" && git rev-parse --show-toplevel 2>/dev/null || echo "")"
if [[ -z "$GIT_ROOT" ]]; then
  echo "ERROR: Not inside a Git repository" >&2
  exit 2
fi

# SSH key: prefer id_ed25519 (CI), fall back to one_key (local)
if [[ -f "${HOME}/.ssh/id_ed25519" ]]; then
  SSH_KEY="${HOME}/.ssh/id_ed25519"
elif [[ -f "${HOME}/.ssh/one_key" ]]; then
  SSH_KEY="${HOME}/.ssh/one_key"
else
  echo "ERROR: No SSH key found (~/.ssh/id_ed25519 or ~/.ssh/one_key)" >&2
  exit 2
fi

SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=10 -o BatchMode=yes -i ${SSH_KEY}"
SSH_CM_DIR=$(mktemp -d /tmp/pve-drift-ssh.XXXXXX)

# Optional filters
FILTER_HOST="${1:-}"
FILTER_VMID="${2:-}"

# Counters
COUNT_OK=0
COUNT_DRIFT=0
COUNT_NEW=0
COUNT_REMOVED=0
COUNT_ERROR=0

# Output file
REPORT_FILE="${PWD}/drift_report.txt"

# Tee all stdout+stderr to report file while keeping terminal output
exec > >(tee "${REPORT_FILE}") 2>&1

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

ssh_cm_start() {
  local host="$1"
  local socket="${SSH_CM_DIR}/${host}"
  # shellcheck disable=SC2086
  ssh ${SSH_OPTS} -o ControlMaster=yes -o ControlPath="${socket}" -o ControlPersist=120 \
    -fN "root@${host}" 2>/dev/null
}

ssh_cm_run() {
  local host="$1"
  shift
  local socket="${SSH_CM_DIR}/${host}"
  # shellcheck disable=SC2086
  ssh ${SSH_OPTS} -o ControlPath="${socket}" "root@${host}" "$@"
}

ssh_cm_stop() {
  local host="$1"
  local socket="${SSH_CM_DIR}/${host}"
  # shellcheck disable=SC2086
  ssh ${SSH_OPTS} -o ControlPath="${socket}" -O exit "root@${host}" 2>/dev/null || true
}

cleanup() {
  for host in ${PVE_HOSTS}; do
    ssh_cm_stop "$host" 2>/dev/null || true
  done
  rm -rf "${SSH_CM_DIR}"
}
trap cleanup EXIT

# Map config type to PVE remote path
pve_remote_dir() {
  local ctype="$1"
  case "$ctype" in
    lxc)  echo "/etc/pve/lxc" ;;
    qemu) echo "/etc/pve/qemu-server" ;;
  esac
}

# Extract hostname/name from a config (stdin)
extract_vm_name() {
  local ctype="$1"
  local key
  case "$ctype" in
    lxc)  key="hostname" ;;
    qemu) key="name" ;;
  esac
  grep -m1 "^${key}:" | sed "s/^${key}:[[:space:]]*//" | tr -d '\r'
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

# Apply host filter
if [[ -n "$FILTER_HOST" ]]; then
  PVE_HOSTS="$FILTER_HOST"
fi

echo "======================================================================"
echo "PVE DRIFT DETECTION"
echo "======================================================================"
echo ""

for host in ${PVE_HOSTS}; do
  echo "--- ${host} ---"

  # Open ControlMaster
  if ! ssh_cm_start "$host"; then
    echo "  [ERROR]    Cannot connect to ${host}"
    COUNT_ERROR=$((COUNT_ERROR + 1))
    echo ""
    continue
  fi

  for ctype in ${CONFIG_TYPES}; do
    remote_dir="$(pve_remote_dir "$ctype")"
    git_dir="${GIT_ROOT}/pve/${host}/${ctype}"

    # Gather VMID sets
    # Git VMIDs
    git_vmids=""
    if [[ -d "$git_dir" ]]; then
      git_vmids=$(ls "$git_dir"/*.conf 2>/dev/null | xargs -I{} basename {} .conf | sort || true)
    fi

    # PVE VMIDs
    pve_vmids=$(ssh_cm_run "$host" "ls ${remote_dir}/ 2>/dev/null" | sed 's/\.conf$//' | sort || true)

    # Apply VMID filter
    if [[ -n "$FILTER_VMID" ]]; then
      git_vmids=$(echo "$git_vmids" | grep -w "$FILTER_VMID" || true)
      pve_vmids=$(echo "$pve_vmids" | grep -w "$FILTER_VMID" || true)
    fi

    # Sets for comparison
    all_vmids=$(printf '%s\n%s\n' "$git_vmids" "$pve_vmids" | grep -v '^$' | sort -u || true)

    for vmid in $all_vmids; do
      in_git=false
      in_pve=false
      [[ -n "$(echo "$git_vmids" | grep -w "$vmid")" ]] && in_git=true
      [[ -n "$(echo "$pve_vmids" | grep -w "$vmid")" ]] && in_pve=true

      if $in_git && ! $in_pve; then
        # Config in Git but not on PVE
        vm_name=$(cat "${git_dir}/${vmid}.conf" | extract_vm_name "$ctype" || echo "")
        printf "  [REMOVED] %s/%-12s %s\n" "$ctype" "$vmid" "(not on PVE)${vm_name:+ — }${vm_name}"
        COUNT_REMOVED=$((COUNT_REMOVED + 1))

      elif ! $in_git && $in_pve; then
        # Config on PVE but not in Git
        vm_name=$(ssh_cm_run "$host" "cat ${remote_dir}/${vmid}.conf 2>/dev/null" | extract_vm_name "$ctype" || echo "")
        printf "  [NEW]     %s/%-12s %s\n" "$ctype" "$vmid" "(not in Git)${vm_name:+ — }${vm_name}"
        COUNT_NEW=$((COUNT_NEW + 1))

      elif $in_git && $in_pve; then
        # Both exist — compare normalized versions
        git_normalized=$(cat "${git_dir}/${vmid}.conf" | normalize_pve_config)
        pve_normalized=$(ssh_cm_run "$host" "cat ${remote_dir}/${vmid}.conf 2>/dev/null" | normalize_pve_config)

        if [[ "$git_normalized" == "$pve_normalized" ]]; then
          vm_name=$(echo "$git_normalized" | extract_vm_name "$ctype" || echo "")
          printf "  [OK]      %s/%-12s %s\n" "$ctype" "$vmid" "$vm_name"
          COUNT_OK=$((COUNT_OK + 1))
        else
          vm_name=$(cat "${git_dir}/${vmid}.conf" | extract_vm_name "$ctype" || echo "")
          printf "  [DRIFT]   %s/%-12s %s\n" "$ctype" "$vmid" "$vm_name"
          COUNT_DRIFT=$((COUNT_DRIFT + 1))

          # Show first 20 lines of diff
          diff_output=$(diff --unified=1 \
            <(echo "$git_normalized") \
            <(echo "$pve_normalized") \
            2>/dev/null || true)
          if [[ -n "$diff_output" ]]; then
            echo "$diff_output" | head -20 | sed 's/^/            /'
            line_count=$(echo "$diff_output" | wc -l)
            if [[ "$line_count" -gt 20 ]]; then
              echo "            ... ($((line_count - 20)) more lines)"
            fi
          fi
        fi
      fi
    done
  done

  echo ""
done

echo "======================================================================"
echo "Summary: ${COUNT_OK} OK, ${COUNT_DRIFT} DRIFT, ${COUNT_NEW} NEW, ${COUNT_REMOVED} REMOVED, ${COUNT_ERROR} ERROR"

if [[ $COUNT_ERROR -gt 0 ]]; then
  echo "Exit code: 2 (error)"
  echo "======================================================================"
elif [[ $COUNT_DRIFT -gt 0 || $COUNT_NEW -gt 0 || $COUNT_REMOVED -gt 0 ]]; then
  echo "Exit code: 1 (drift found)"
  echo "======================================================================"
else
  echo "Exit code: 0 (no drift)"
  echo "======================================================================"
fi
# Set exit code
if [[ $COUNT_ERROR -gt 0 ]]; then
  exit 2
elif [[ $COUNT_DRIFT -gt 0 || $COUNT_NEW -gt 0 || $COUNT_REMOVED -gt 0 ]]; then
  exit 1
else
  exit 0
fi
