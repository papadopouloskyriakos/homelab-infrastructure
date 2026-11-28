#!/bin/bash
# Pacemaker alert handler for p_fs_iot (IoT NFS mount) failures.
#
# Runs as the unprivileged `hacluster` user (Pacemaker executes all alert agents
# as hacluster). It therefore only filters + logs here, and hands the actual
# privileged remediation to the root helper clear_arp_nfs_action.sh via sudo --
# arp -d, reading the 0600 webhook token, and resource cleanup all need root and
# silently failed when they lived in this handler (fixed 2026-06-27, see helper).
#
# - Always: clear ARP for the NFS VIP and trigger a resource cleanup so
#   Pacemaker retries promptly.
# - Stale-fh on start: the helper also calls the cross-cluster exportfs-flush
#   webhook on file01 + file02 to rebuild the nfsd kernel fh-cache. Automates the
#   manual `pcs resource restart exportfs` recovery proven during the
#   2026-04-30 11:48 spontaneous re-poisoning event.
#
# Refs: IFRNLLEI01PRD-803 (IP + start-trigger fix),
#       IFRNLLEI01PRD-804 (auto-flush; webhook is the cross-cluster flavour),
#       memory `incident_haha_nfs_stale_fh_20260430.md`,
#       `haha_reliability_hardening_20260430.md`,
#       `project_haha_zigbee_coordinator_autoheal.md` (hacluster/sudo finding).
#
# Env hook for testing: ACTION_CMD overrides the privileged invocation.

# Default invocation runs the helper as root via sudo (word-split intentional).
ACTION_CMD="${ACTION_CMD:-sudo -n /usr/local/sbin/clear_arp_nfs_action.sh}"

if [ "$CRM_alert_kind" != "resource" ] || \
   [ "$CRM_alert_rsc" != "p_fs_iot" ] || \
   [ "$CRM_alert_rc" = "0" ]; then
    exit 0
fi

case "$CRM_alert_task" in
    monitor|start) ;;
    *) exit 0 ;;
esac

logger -t clear_arp_nfs "p_fs_iot $CRM_alert_task failed (rc=$CRM_alert_rc desc=${CRM_alert_desc:0:120})"

# Detached so the alert handler returns fast (helper may webhook + sleep).
# shellcheck disable=SC2086 # intentional word-split: $ACTION_CMD is "sudo -n <script>"
setsid $ACTION_CMD "$CRM_alert_task" "${CRM_alert_desc:-}" </dev/null >/dev/null 2>&1 &
exit 0
