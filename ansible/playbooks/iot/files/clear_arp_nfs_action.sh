#!/bin/bash
# clear_arp_nfs_action.sh
# Privileged remediation for p_fs_iot (IoT NFS mount) failures. Invoked as ROOT
# via sudo by the clear_arp_nfs.sh Pacemaker alert handler, which itself runs as
# the unprivileged `hacluster` user and therefore cannot do any of this:
#   - `arp -d` needs CAP_NET_ADMIN (root)
#   - /etc/exportfs-flush-webhook.token is 0600 root (hacluster can't read it)
#   - `pcs resource cleanup` needs pcsd auth (hacluster gets rc=1)
# Before 2026-06-27 all three ran directly in the hacluster alert handler and
# silently failed -- the NFS fast-path auto-remediation was a no-op. (Confirmed
# by a controlled diagnostic-alert test; recovery had been falling back to
# Pacemaker's own native retry.)
#
# Args: $1 = CRM_alert_task (start|monitor), $2 = CRM_alert_desc.
#
# Actions (mirrors the original logic, now actually privileged):
#   - Always: flush the stale ARP entry for the NFS VIP (10.0.X.X).
#   - On a start failure whose desc contains "Stale file handle": call the
#     cross-cluster exportfs-flush webhook on file01 + file02 to rebuild the
#     nfsd fh-cache, then clean up p_fs_iot so Pacemaker retries the mount.
#   - Otherwise: just clean up p_fs_iot.
# Uses crm_resource --cleanup (works via the CIB) with a pcs fallback.
#
# Allowed for hacluster via /etc/sudoers.d/clear-arp-nfs.
# Snapshot: native/haha/<host>/scripts/clear_arp_nfs_action.sh
# Ref: HAHA NFS alert auto-heal privilege fix (2026-06-27).

TASK="${1:-}"
DESC="${2:-}"
TOKEN_FILE=/etc/exportfs-flush-webhook.token
WEBHOOKS=("http://10.0.X.X:9107/flush" "http://10.0.X.X:9107/flush")

logger -t clear_arp_nfs "[helper] running as $(id -un) task=$TASK -- flushing ARP for NFS VIP 10.0.X.X"
arp -d 10.0.X.X 2>/dev/null || logger -t clear_arp_nfs "[helper] arp -d returned non-zero (entry may already be absent)"

cleanup_fs() {
    crm_resource --cleanup --resource p_fs_iot >/dev/null 2>&1 \
        || pcs resource cleanup p_fs_iot >/dev/null 2>&1 \
        || logger -t clear_arp_nfs "[helper] WARNING: resource cleanup p_fs_iot failed"
}

if [ "$TASK" = "start" ] && [ -r "$TOKEN_FILE" ] && echo "${DESC:-}" | grep -qiE "Stale file handle"; then
    TOKEN=$(cat "$TOKEN_FILE")
    for url in "${WEBHOOKS[@]}"; do
        logger -t clear_arp_nfs "[helper] calling exportfs flush webhook: $url"
        out=$(curl -fsS -m 8 -X POST -H "Authorization: Bearer $TOKEN" "$url" 2>&1)
        rc=$?
        logger -t clear_arp_nfs "[helper] webhook $url rc=$rc out=${out//$'\n'/ }"
    done
    sleep 8
    cleanup_fs
    logger -t clear_arp_nfs "[helper] post-webhook resource cleanup p_fs_iot done"
else
    cleanup_fs
fi
exit 0
