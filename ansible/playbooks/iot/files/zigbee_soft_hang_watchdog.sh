#!/bin/bash
# zigbee_soft_hang_watchdog.sh
# Proactive detector + in-place healer for TubesZB CC2652P7 coordinator SOFT hangs.
#
# WHY THIS EXISTS -- the failure mode the Pacemaker alert CANNOT see:
#   The CC2652 radio firmware freezes, but its serial-over-IP bridge
#   (10.0.X.X:6638) and PoE stay UP, and z2m stays "Started" with a green
#   web-UI monitor. Pacemaker therefore never raises a failure event, so the
#   alert handler (zigbee_coordinator_alert.sh) never runs. Meanwhile every device
#   ping times out with "SRSP - AF - dataRequest after 6000ms" and the whole
#   Zigbee network goes dark while the cluster reports full health. On 2026-06-29
#   this condition persisted ~10h until it escalated into a connect failure.
#
#   Even the alert's own signature would miss it: it matches the STARTUP hang
#   ("SRSP - SYS - ping" / "Failed to connect to the adapter"), NOT the runtime
#   soft-hang ("SRSP - AF - dataRequest"). This watchdog keys on the runtime
#   signature directly.
#
# HOW IT RUNS:
#   systemd timer (zigbee-soft-hang-watchdog.timer, every ~30s) on every cluster
#   node. Self-gates to the ACTIVE node only (where REDACTED_9d35477e is
#   located) -- only that node has /mnt/iot mounted and the z2m logs, and only it
#   should act. Detection = a STORM of coordinator-level SRSP timeouts (the
#   coordinator ignoring its own ZNP commands) in a short window -- not a single
#   transient device timeout -- to avoid false-positive power-cycles of a healthy
#   coordinator.
#
# RECOVERY (in place, NO group failover -- avoids the ~2h churn of 2026-06-29):
#   1. PoE-cycle the coordinator via the existing zigbee_coordinator_reset.sh
#      (proven; owns the 10-min hardware cooldown; waits for the bridge; clears
#      z2m failcount).
#   2. `crm resource restart REDACTED_9d35477e` so herdsman re-initializes the
#      adapter against the freshly-booted radio. (z2m does NOT reliably auto-
#      recover its adapter after a coordinator reboot -- the reset helper's
#      `resource cleanup` is a no-op on a Started-but-wedged container. Observed
#      2026-06-29.)
#   Target: detect in ~60-90s, recover in ~90s => <3min total outage.
#
# Runs as root (systemd) -- no sudo needed. Shares the reset helper's cooldown
# lock so the watchdog and the alert never double-cycle the hardware. A short
# re-entry lock prevents restart thrash while a cycle settles.
#
# Env hooks for testing: DRY_RUN=1 (detect+log only), FORCE_HANG=1 (force the
# detect branch for wiring tests), RESET_CMD / RESTART_CMD overrides.
#
# Snapshot: native/haha/<host>/scripts/zigbee_soft_hang_watchdog.sh
# systemd:  zigbee-soft-hang-watchdog.{service,timer}
# Ref: HAHA Zigbee coordinator auto-heal (2026-06-27); soft-hang gap (2026-06-29).

set -u

RSC="REDACTED_9d35477e"
Z2M_LOG_DIR="REDACTED_b293d140"
LOG_TAG="zigbee_watchdog"
COORD_IP="10.0.X.X"
COORD_PORT="6638"

# Coordinator ignored its own ZNP command. Covers runtime soft-hang (AF -
# dataRequest) AND startup/connect hang (SYS - ping). Broad on purpose.
SIG='SRSP - (AF|SYS|ZDO|UTIL) - .* after [0-9]+ms'

WINDOW="${WATCH_WINDOW:-3}"        # sliding window (minutes) for SRSP counting
THRESHOLD="${WATCH_THRESHOLD:-2}"  # coordinator-level timeouts in window => hang
                                   # healthy baseline = 0 (validated 2026-06-29),
                                   # so 2 is safe AND fires in ~1min at ~2/min hang density.
REENTRY_LOCK="/var/run/zigbee_watchdog.lock"
REENTRY_COOLDOWN="${REENTRY_COOLDOWN:-180}"   # don't re-enter while a cycle settles
DRY_RUN="${DRY_RUN:-0}"
FORCE_HANG="${FORCE_HANG:-0}"

log() { logger -t "$LOG_TAG" "$*" 2>/dev/null || true; echo "$(date '+%F %T') $*"; }

# --- gate 1: am I the active node? ----------------------------------------
# Only the node running z2m has /mnt/iot mounted and should recover it. During a
# failover z2m is located on neither/both transiently -- we simply bail.
me="$(hostname -s)"
if ! crm_resource --locate -r "$RSC" 2>/dev/null | grep -qi "$me"; then
    exit 0
fi

# --- gate 2: can I read the z2m logs? -------------------------------------
# /mnt/iot is only mounted on the active node (p_fs_iot). If it's gone (NFS
# outage, handled by clear_arp_nfs.sh) we can't assess -- exit, don't act.
[ -d "$Z2M_LOG_DIR" ] || exit 0

# --- re-entry guard --------------------------------------------------------
now=$(date +%s)
if [ -f "$REENTRY_LOCK" ]; then
    last=$(cat "$REENTRY_LOCK" 2>/dev/null || echo 0)
    [ -z "$last" ] && last=0
    if [ $(( now - last )) -lt "$REENTRY_COOLDOWN" ]; then
        exit 0
    fi
fi

# --- detect: coordinator-level SRSP timeouts in a TRUE sliding window -----
# Count SRSP lines whose own timestamp is within the last WINDOW minutes -- NOT
# merely all lines in a recently-touched file. This bounds detection to CURRENT
# coordinator trouble, so a long-running log file can't accumulate stale hits
# into a false trigger. z2m logs in Europe/Amsterdam; match that TZ for cutoff.
# (Pre-filter files by mtime to keep the grep cheap; the timestamp match is exact.)
cutoff=$(TZ=Europe/Amsterdam date -d "-${WINDOW} minutes" '+%Y-%m-%d %H:%M:%S' 2>/dev/null)
count=0
if [ "$FORCE_HANG" = "1" ]; then
    count=$(( THRESHOLD + 1 ))
elif [ -n "$cutoff" ]; then
    while IFS= read -r f; do
        n=$(grep -iE "$SIG" "$f" 2>/dev/null \
             | grep -oE '\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9:]+\]' \
             | tr -d '[]' \
             | awk -v cut="$cutoff" '$0 >= cut {n++} END {print n+0}')
        count=$(( count + n ))
    done < <(find "$Z2M_LOG_DIR" -mindepth 2 -maxdepth 2 -name 'log.log' -mmin -10 2>/dev/null)
fi

if [ "$count" -lt "$THRESHOLD" ]; then
    exit 0     # healthy or a transient blip -- no action
fi

log "coordinator soft-hang detected: ${count} SRSP timeouts in last ${WINDOW}min -- recovering in place (no failover)"
echo "$now" > "$REENTRY_LOCK" 2>/dev/null || true

RESET_CMD="${RESET_CMD:-/usr/local/sbin/zigbee_coordinator_reset.sh}"
RESTART_CMD="${RESTART_CMD:-crm resource restart $RSC}"

if [ "$DRY_RUN" = "1" ]; then
    log "DRY_RUN: would run '$RESET_CMD' then '$RESTART_CMD'"
    exit 0
fi

# 1) PoE-cycle the coordinator (reset helper owns the 10-min hardware cooldown,
#    waits for the bridge, clears failcount). We are root -- call it directly.
log "step 1/2: PoE-reset coordinator via $RESET_CMD"
if ! "$RESET_CMD" >/dev/null 2>&1; then
    log "WARNING: reset helper non-zero (10-min cooldown may have skipped PoE); still restarting z2m"
fi

# 2) Ensure the coordinator bridge is READY, then restart z2m in place so
#    herdsman re-inits the adapter against a booted radio. The reset helper
#    normally guarantees this (PoE + 60s boot wait), but if it COOLDOWN-SKIPPED
#    because another actor (the alert, or a prior cycle) just PoE'd, the radio
#    may still be mid-boot -- restarting z2m then crash-loops it (found in the
#    2026-06-29 live-fire test). Wait up to ~90s for the bridge before restarting.
log "step 2/2: waiting for coordinator bridge ready, then restarting $RSC"
ready=0
for i in $(seq 1 18); do
    if timeout 4 bash -c "cat </dev/null >/dev/tcp/$COORD_IP/$COORD_PORT" 2>/dev/null; then ready=1; break; fi
    sleep 5
done
[ "$ready" = 1 ] || log "WARNING: coordinator bridge not reachable after ~90s -- restarting z2m anyway"
if ! eval "$RESTART_CMD" >/dev/null 2>&1; then
    log "WARNING: crm resource restart non-zero (may still recover via monitor)"
fi

log "recovery cycle complete"
exit 0
