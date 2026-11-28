#!/bin/bash
# zigbee_coordinator_alert.sh
# Pacemaker alert handler -- auto-recovers a hung TubesZB Zigbee coordinator.
#
# Mirrors the clear_arp_nfs.sh alert pattern. Fires on every Pacemaker alert;
# self-filters to REDACTED_9d35477e start/monitor FAILURES only. When a
# recent z2m application log shows the coordinator-unreachable signature (the
# radio firmware hang: serial bridge up but "SRSP - SYS - ping" / "Failed to
# connect to the adapter"), it triggers a surgical PoE power-cycle of the
# coordinator (zigbee_coordinator_reset.sh), detached so the alert returns fast.
#
# The signature check ensures we ONLY power-cycle hardware for a genuine radio
# hang -- not for unrelated z2m failures (bad image pull, config error, or an
# NFS outage where /mnt/iot is gone, handled separately by clear_arp_nfs.sh /
# p_fs_iot). If /mnt/iot is unreachable the logs can't be read, the signature
# won't match, and we correctly do nothing.
#
# Log scanning is robust against the crash-loop race: z2m writes a fresh
# timestamped log dir on every (re)start, so the single newest dir can be a
# just-created near-empty one while the dir that actually logged the adapter
# failure is one back. We therefore scan ALL z2m log dirs touched in the last
# 5 minutes, with a short bounded retry to let a still-failing container flush
# its log before we decide. (Hardened 2026-06-27 after a controlled hang test
# showed a single-latest-dir scan could miss the signature during a crash-loop.)
#
# A cooldown lock inside the reset script prevents reset storms across repeated
# failures. The daily 05:00/06:00 cron (hard_reset_tubeszb_olimex.sh) remains a
# periodic belt-and-suspenders reset.
#
# PRIVILEGE: Pacemaker runs alert agents as the unprivileged `hacluster` user,
# which cannot write /var/run, /var/log, or run pcs/crm cleanup. The reset must
# therefore run as root via sudo (see /etc/sudoers.d/zigbee-autoheal), exactly
# like the cron does. The setsid output goes to /dev/null because hacluster also
# cannot open a /var/log file for the redirect -- the reset logs to syslog
# (logger -t zigbee_reset) instead. (Found 2026-06-27 by a controlled hang test:
# the handler logged "triggering" but the reset silently never ran.)
#
# Wired into the CIB as:  alert alert_zigbee_reset "/usr/local/sbin/zigbee_coordinator_alert.sh"
# Env hook for testing: RESET_CMD overrides the full reset invocation.
#
# Snapshot: native/haha/<host>/scripts/zigbee_coordinator_alert.sh
# Ref: HAHA Zigbee coordinator auto-heal (2026-06-27).

RSC="REDACTED_9d35477e"
# Word-split intentionally: default invocation is "sudo -n <script>".
RESET_CMD="${RESET_CMD:-sudo -n /usr/local/sbin/zigbee_coordinator_reset.sh}"
Z2M_LOG_DIR="REDACTED_b293d140"
SIG='Failed to connect to the adapter|SRSP - SYS - ping|Error while starting zigbee-herdsman'
LOG_TAG="zigbee_alert"

# Only act on our resource's non-zero (failed) start/monitor results.
[ "${CRM_alert_kind:-}" = "resource" ] || exit 0
[ "${CRM_alert_rsc:-}" = "$RSC" ]      || exit 0
[ "${CRM_alert_rc:-0}" != "0" ]        || exit 0
case "${CRM_alert_task:-}" in
    start|monitor) ;;
    *) exit 0 ;;
esac

logger -t "$LOG_TAG" "$RSC ${CRM_alert_task} failed (rc=${CRM_alert_rc} desc=${CRM_alert_desc:0:120})"

# Scan every z2m log.log modified in the last 5 minutes for the hang signature.
scan_sig() {
    local f
    while IFS= read -r f; do
        grep -qiE "$SIG" "$f" 2>/dev/null && return 0
    done < <(find "$Z2M_LOG_DIR" -mindepth 2 -maxdepth 2 -name log.log -mmin -5 2>/dev/null)
    return 1
}

# Bounded retry (~12s) so a container still flushing its failure log is caught.
found=1
for _ in 1 2 3 4; do
    if scan_sig; then found=0; break; fi
    sleep 3
done

if [ "$found" = "0" ]; then
    logger -t "$LOG_TAG" "coordinator-hang signature matched in recent z2m logs -- triggering PoE reset"
    # shellcheck disable=SC2086 # intentional word-split: $RESET_CMD is "sudo -n <script>"
    setsid $RESET_CMD </dev/null >/dev/null 2>&1 &
else
    logger -t "$LOG_TAG" "no coordinator-hang signature in recent z2m logs -- leaving to normal Pacemaker retry (no power-cycle)"
fi
exit 0
