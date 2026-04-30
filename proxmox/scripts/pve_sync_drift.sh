#!/usr/bin/env bash
# pve_sync_drift.sh — Sync drifted PVE configs from live hosts to Git
#
# Runs pve_detect_drift.sh, then for each drifted/new/removed config:
#   DRIFT  → overwrite Git config with PVE live config
#   NEW    → add PVE live config to Git
#   REMOVED → delete config from Git
#
# Commits and pushes to main with author "GitLab CI Auto-Sync"
# (deploy pipeline skips this author to prevent feedback loops)
#
# Usage:
#   pve_sync_drift.sh
#
# Prerequisites:
#   - SSH key for PVE hosts (~/.ssh/id_ed25519 or ~/.ssh/one_key)
#   - Git configured with push credentials and author
#   - Run from repo root (or CI_PROJECT_DIR)
#
# Exit codes: 0=no changes, 1=synced, 2=error

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

PVE_HOSTS="nl-pve01 nl-pve02 nl-pve03"
CONFIG_TYPES="lxc qemu"

# Sanity cap on bulk deletions per host/ctype block. PVE API can briefly
# return empty inventory under host memory thrash (IFRNLLEI01PRD-739):
# `ls /etc/pve/lxc` returns nothing → every Git VMID falls into the
# "in_git && !in_pve" delete branch → script auto-pushes a 41-LXC-deletion
# commit to main on a transient blink. Refuse to proceed if would-be
# deletions exceed this cap; exit 2 (error) so the CI job fails loudly
# rather than committing the bad state.
MAX_DELETIONS_PER_RUN="${MAX_DELETIONS_PER_RUN:-5}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=pve_normalize_config.sh
source "${SCRIPT_DIR}/pve_normalize_config.sh"

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
SSH_CM_DIR=$(mktemp -d /tmp/pve-sync-ssh.XXXXXX)

# Counters
COUNT_SYNCED=0
COUNT_ADDED=0
COUNT_DELETED=0
COUNT_UNCHANGED=0
COUNT_ERROR=0

CHANGES_MADE=false
CAP_TRIPPED=false

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

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

echo "======================================================================"
echo "PVE DRIFT SYNC"
echo "======================================================================"
echo ""

for host in ${PVE_HOSTS}; do
  echo "--- ${host} ---"

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
    git_vmids=""
    if [[ -d "$git_dir" ]]; then
      git_vmids=$(ls "$git_dir"/*.conf 2>/dev/null | xargs -I{} basename {} .conf | sort || true)
    fi

    pve_vmids=$(ssh_cm_run "$host" "ls ${remote_dir}/ 2>/dev/null" | sed 's/\.conf$//' | sort || true)

    # Sanity cap pre-flight (IFRNLLEI01PRD-739): count would-be deletions for
    # this host/ctype before mutating Git. If the count exceeds the cap, this
    # is almost certainly a transient PVE inventory blink — skip the block,
    # mark the run as failed, and refuse to commit later.
    would_delete=0
    for vmid in $git_vmids; do
      if ! echo "$pve_vmids" | grep -qw "$vmid"; then
        would_delete=$((would_delete + 1))
      fi
    done
    if [[ $would_delete -gt $MAX_DELETIONS_PER_RUN ]]; then
      echo "  [ABORT]   ${ctype}: would-be deletions=${would_delete} exceeds cap=${MAX_DELETIONS_PER_RUN} — likely PVE inventory blink, skipping this ctype on ${host}"
      echo "            (override via MAX_DELETIONS_PER_RUN env var if a real bulk-delete is intended)"
      CAP_TRIPPED=true
      COUNT_ERROR=$((COUNT_ERROR + 1))
      continue
    fi

    all_vmids=$(printf '%s\n%s\n' "$git_vmids" "$pve_vmids" | grep -v '^$' | sort -u || true)

    for vmid in $all_vmids; do
      in_git=false
      in_pve=false
      [[ -n "$(echo "$git_vmids" | grep -w "$vmid")" ]] && in_git=true
      [[ -n "$(echo "$pve_vmids" | grep -w "$vmid")" ]] && in_pve=true

      if $in_git && ! $in_pve; then
        # REMOVED: config in Git but not on PVE — delete from Git
        printf "  [DELETE]  %s/%-12s (removed from PVE)\n" "$ctype" "$vmid"
        rm -f "${git_dir}/${vmid}.conf"
        git -C "$GIT_ROOT" add "${git_dir}/${vmid}.conf" 2>/dev/null || true
        git -C "$GIT_ROOT" rm --cached "${git_dir}/${vmid}.conf" 2>/dev/null || true
        COUNT_DELETED=$((COUNT_DELETED + 1))
        CHANGES_MADE=true

      elif ! $in_git && $in_pve; then
        # NEW: config on PVE but not in Git — add to Git
        printf "  [ADD]     %s/%-12s (new on PVE)\n" "$ctype" "$vmid"
        mkdir -p "$git_dir"
        ssh_cm_run "$host" "cat ${remote_dir}/${vmid}.conf 2>/dev/null" > "${git_dir}/${vmid}.conf"
        git -C "$GIT_ROOT" add "${git_dir}/${vmid}.conf"
        COUNT_ADDED=$((COUNT_ADDED + 1))
        CHANGES_MADE=true

      elif $in_git && $in_pve; then
        # Both exist — compare normalized versions
        git_normalized=$(cat "${git_dir}/${vmid}.conf" | normalize_pve_config)
        pve_normalized=$(ssh_cm_run "$host" "cat ${remote_dir}/${vmid}.conf 2>/dev/null" | normalize_pve_config)

        if [[ "$git_normalized" != "$pve_normalized" ]]; then
          # DRIFT: overwrite Git with PVE live config
          printf "  [SYNC]    %s/%-12s (drift detected)\n" "$ctype" "$vmid"
          ssh_cm_run "$host" "cat ${remote_dir}/${vmid}.conf 2>/dev/null" > "${git_dir}/${vmid}.conf"
          git -C "$GIT_ROOT" add "${git_dir}/${vmid}.conf"
          COUNT_SYNCED=$((COUNT_SYNCED + 1))
          CHANGES_MADE=true
        else
          COUNT_UNCHANGED=$((COUNT_UNCHANGED + 1))
        fi
      fi
    done
  done

  echo ""
done

echo "======================================================================"
echo "Summary: ${COUNT_UNCHANGED} unchanged, ${COUNT_SYNCED} synced, ${COUNT_ADDED} added, ${COUNT_DELETED} deleted, ${COUNT_ERROR} errors"
echo "======================================================================"

# Cap-trip path: refuse to commit + push when the deletion sanity cap
# tripped on at least one host/ctype block. The remaining ctypes may have
# completed cleanly, but the run is unsafe overall — fail loudly so the
# scheduled pipeline turns red and the operator can decide whether the
# inventory blink was real (bump MAX_DELETIONS_PER_RUN once) or transient
# (re-run on next schedule, no action needed). IFRNLLEI01PRD-739.
if $CAP_TRIPPED; then
  echo ""
  echo "ABORT: deletion sanity cap tripped at least once. Not committing or pushing."
  echo "       If this was a real bulk-delete, re-run with MAX_DELETIONS_PER_RUN=N where N is large enough."
  exit 2
fi

# ---------------------------------------------------------------------------
# Commit and push
# ---------------------------------------------------------------------------

if $CHANGES_MADE; then
  TOTAL_CHANGES=$((COUNT_SYNCED + COUNT_ADDED + COUNT_DELETED))
  COMMIT_MSG="chore(pve): sync ${TOTAL_CHANGES} config(s) from live PVE hosts"

  # Build details
  DETAILS=""
  [[ $COUNT_SYNCED -gt 0 ]] && DETAILS="${DETAILS}, ${COUNT_SYNCED} drifted"
  [[ $COUNT_ADDED -gt 0 ]] && DETAILS="${DETAILS}, ${COUNT_ADDED} new"
  [[ $COUNT_DELETED -gt 0 ]] && DETAILS="${DETAILS}, ${COUNT_DELETED} removed"
  DETAILS="${DETAILS#, }"  # strip leading comma

  echo ""
  echo "Committing: ${COMMIT_MSG} (${DETAILS})"
  git -C "$GIT_ROOT" commit -m "${COMMIT_MSG}

Synced: ${DETAILS}
Auto-generated by pve_sync_drift.sh"

  echo "Pushing to origin/main..."
  git -C "$GIT_ROOT" push origin main

  echo ""
  echo "Sync complete: ${TOTAL_CHANGES} change(s) pushed"
  exit 1  # exit 1 = changes were synced (informational)
else
  echo ""
  echo "No changes to sync"
  exit 0
fi
