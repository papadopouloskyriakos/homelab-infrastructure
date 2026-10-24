#!/bin/bash
# zigbee_coordinator_reset.sh
# Event-driven recovery for a hung TubesZB CC2652P7 Zigbee coordinator.
#
# Failure mode (observed 2026-06-27): the coordinator's serial-over-IP bridge
# (10.0.X.X:6638) and its PoE stay UP, but the CC2652 radio firmware
# locks up. zigbee-herdsman connects the TCP socket, then times out on the
# adapter handshake:
#     Error: Failed to connect to the adapter (Error: SRSP - SYS - ping after 6000ms)
# z2m exits, Pacemaker fails REDACTED_9d35477e's start, hits
# migration-threshold, and -- because g_iot_stack is an ORDERED group -- the
# resources after z2m (p_docker_esphome, p_docker_nodered) never start either.
# The ONLY recovery is a PoE power-cycle of the coordinator switch port.
#
# Previously that only happened via the daily 05:00/06:00 cron
# (hard_reset_tubeszb_olimex.sh), so a mid-day hang left the whole Zigbee stack
# (plus esphome + nodered) down for up to ~24h with no self-heal. This script
# is the event-driven complement, fired by zigbee_coordinator_alert.sh.
#
# It power-cycles ONLY Gi1/0/17 (the Zigbee coordinator). It deliberately does
# NOT touch Gi1/0/35 (Olimex BT proxy) -- a Zigbee radio hang is unrelated to
# Bluetooth, so there is no reason to drop the BT proxy too. A cooldown lock
# prevents reset storms. After the radio reboots it asks Pacemaker to retry z2m.
#
# Usable manually. Env hooks for testing: DRY_RUN=1 (skip switch + sleeps),
# RESET_COOLDOWN / RESET_BOOT_WAIT overrides.
#
# Snapshot: native/haha/<host>/scripts/zigbee_coordinator_reset.sh
# Ref: HAHA Zigbee coordinator auto-heal (2026-06-27).

set -u

SWITCH_IP="10.0.X.X"
SWITCH_USER="kyriakosp"
SWITCH_PASS="Exng@n3d!g0lD"
ZB_PORT="REDACTED_11844068"
COORD_IP="10.0.X.X"
COORD_TCP_PORT="6638"

LOCK="/var/run/zigbee_coordinator_reset.lock"
COOLDOWN="${RESET_COOLDOWN:-600}"     # don't power-cycle more than once / 10 min
BOOT_WAIT="${RESET_BOOT_WAIT:-60}"    # wait for the radio to boot before cleanup
DRY_RUN="${DRY_RUN:-0}"
LOG_TAG="zigbee_reset"

log() { logger -t "$LOG_TAG" "$*" 2>/dev/null; echo "$(date '+%F %T') $*"; }

# --- cooldown guard -------------------------------------------------------
now=$(date +%s)
if [ -f "$LOCK" ]; then
    last=$(cat "$LOCK" 2>/dev/null || echo 0)
    [ -z "$last" ] && last=0
    delta=$(( now - last ))
    if [ "$delta" -lt "$COOLDOWN" ]; then
        log "cooldown active (${delta}s < ${COOLDOWN}s since last reset) -- skipping power-cycle"
        exit 0
    fi
fi
echo "$now" > "$LOCK" 2>/dev/null || true

log "power-cycling Zigbee coordinator PoE port $ZB_PORT on $SWITCH_IP (DRY_RUN=$DRY_RUN)"

cycle_off() {
    sshpass -p "$SWITCH_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=15 \
        "$SWITCH_USER@$SWITCH_IP" >/dev/null 2>&1 <<EOF
configure terminal
interface $ZB_PORT
shutdown
power inline never
end
EOF
}
cycle_on() {
    sshpass -p "$SWITCH_PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=15 \
        "$SWITCH_USER@$SWITCH_IP" >/dev/null 2>&1 <<EOF
configure terminal
interface $ZB_PORT
power inline auto
no shutdown
end
EOF
}

if [ "$DRY_RUN" = "1" ]; then
    log "DRY_RUN: would shutdown/power-off, sleep 8, power-on $ZB_PORT, then wait ${BOOT_WAIT}s"
else
    cycle_off
    sleep 8
    cycle_on
    log "PoE port cycled; waiting ${BOOT_WAIT}s for coordinator radio to boot"
    sleep "$BOOT_WAIT"
    # Best-effort: wait for the serial bridge to accept TCP again.
    for i in $(seq 1 12); do
        if timeout 5 bash -c "cat < /dev/null > /dev/tcp/$COORD_IP/$COORD_TCP_PORT" 2>/dev/null; then
            log "coordinator bridge $COORD_IP:$COORD_TCP_PORT reachable"
            break
        fi
        sleep 5
    done
fi

log "requesting Pacemaker retry of REDACTED_9d35477e"
if [ "$DRY_RUN" != "1" ]; then
    pcs resource cleanup REDACTED_9d35477e >/dev/null 2>&1 \
        || crm resource cleanup REDACTED_9d35477e >/dev/null 2>&1 \
        || log "WARNING: resource cleanup command failed"
fi
log "reset cycle complete"
exit 0
