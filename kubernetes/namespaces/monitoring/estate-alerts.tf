# =============================================================================
# Estate-Scope Prometheus Alert Rules — NL ONLY (mirror-exempt)
#
# These rules watch things that exist ONCE in the estate and are scraped only
# by the NL Prometheus: the Pacemaker cluster (HAHA / IoT hosts) and the
# omoikane edge/DMZ hosts (ClamAV gate, restic retention + mirror, systemd
# timer units). They were split out of custom-alerts.tf on 2026-08-16 for the
# NL<->GR mirror campaign so custom-alerts.tf can be byte-identical in both
# repos. This file is on the mirror-exemption list — do NOT copy it to the GR
# repo; GR's Prometheus never sees these series and every rule would sit in
# permanent `absent()`-style limbo or simply never evaluate.
#
# Rule bodies are moved VERBATIM from custom-alerts.tf (same alert names,
# exprs, labels, annotations, and group names) — only the PrometheusRule
# OBJECT holding them changed, which changes Prometheus rule-group file
# membership but not alert identity.
#
# Deleted during the same split (NOT moved here): the 3 legacy counter-based
# Velero rules from the custom-backup group — VeleroBackupPartiallyFailed,
# VeleroBackupFailed, VeleroBackupStale. Documented-broken: `increase(...)`
# on velero_* counters resets on every velero pod restart (a week holding
# ~35 PartiallyFailed backups measured 0), and velero_backup_last_status
# reports PartiallyFailed as success=1. Superseded by the 6 gauge-based rules
# in velero-backup-alerts.tf (MR !440/!441), which both sites now run.
# =============================================================================

resource "kubernetes_manifest" "estate_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "estate-alert-rules"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "prometheus"                = "monitoring"
        "role"                      = "alert-rules"
        "release"                   = "monitoring"
      }
    }
    spec = {
      groups = [
        {
          # Pacemaker cluster (HAHA / IoT) — catches forgotten "crm node standby"
          # state. Today's incident: weekly-update playbook left iot02 in standby
          # for ~16h with zero alerting, so the cluster lost failover redundancy
          # silently. Metric source: native/haha/pacemaker-standby-exporter/
          # (textfile collector on iot01/iot02/iotarb01).
          name = "custom-pacemaker"
          rules = [
            {
              alert = "REDACTED_2aa4f351"
              expr  = "max by (node) (pacemaker_node_standby) == 1"
              for   = "30m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Pacemaker node {{ $labels.node }} stuck in standby for >30m"
                description = "Pacemaker node {{ $labels.node }} has been in standby (no resources allowed) for more than 30 minutes — cluster has lost failover redundancy. Likely cause: a maintenance / weekly-update playbook left the node in standby and forgot to bring it back online. Recover with 'crm node online {{ $labels.node }}' from any cluster member."
              }
            },
            {
              alert = "REDACTED_d78e0784"
              expr  = "(time() - max by (instance) (node_textfile_mtime_seconds{file=~\".*pacemaker_standby.prom\"})) > 600"
              for   = "5m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "pacemaker-standby-exporter on {{ $labels.instance }} has not refreshed in >10m"
                description = "The pacemaker-standby-exporter.timer on {{ $labels.instance }} has not updated /var/lib/node_exporter/textfile_collector/pacemaker_standby.prom in over 10 minutes. REDACTED_2aa4f351 may be evaluating stale data. Check 'systemctl status pacemaker-standby-exporter.timer'."
              }
            }
          ]
        },
        {
          # OMOIKANE-1527 / OMOIKANE-1520.
          #
          # Velero ran for 244 days and never once produced a Completed backup.
          # Nothing alerted because nothing COULD: velero exports 27 metric
          # series on :8085 but had no Service and no ServiceMonitor, so every
          # velero_* query returned 0 series. The metrics were wired up first
          # (argocd-apps/velero/servicemonitor.yaml); these expressions are
          # written against series confirmed present in Prometheus rather than
          # assumed metric names.
          name = "REDACTED_b00a177a"
          rules = [
            {
              # OMOIKANE-1434. The daemon's malware gate defaults to BLOCK mode:
              # an upload it cannot scan is refused. That is the right default —
              # but if block mode is on with no CLAMAV_URL configured, the gate
              # refuses EVERYTHING, and the product looks like "uploads are
              # broken" rather than like a misconfiguration.
              #
              # This exact state reached production on 2026-07-24. Three
              # independent alarms were supposed to catch it — a startup error
              # line, this gauge, and /readyz reporting clamav:false — and ALL
              # THREE were silent, because Prometheus had never scraped the
              # daemon at all (OMOIKANE-1490, fixed 2026-07-26). The rule below
              # is the first of the three that can now actually fire.
              #
              # The daemon's own metric description specifies the threshold:
              # "Alert on > 0 for more than one scrape interval."
              #
              # {sentinel!="boot"} is REQUIRED, not decoration. The daemon
              # emits every described metric twice: the real series, plus a
              # zero-valued sample labelled sentinel="boot" so the HELP text
              # exists in /metrics before any real sample does
              # (metrics.rs:763-770). That file states the rule outright —
              # "Operator PromQL MUST filter {sentinel!=\"boot\"}".
              #
              # Verified against live Prometheus: this gauge currently returns
              # FOUR series for two hosts, one of each pair carrying
              # sentinel="boot". Today the sentinel is pinned at 0 so a bare
              # "> 0" happens to be harmless, but it would double-count the
              # moment the sentinel convention changes, and a rule that is
              # only accidentally correct is not correct.
              alert = "REDACTED_ea768c16"
              expr  = "omoikane_clamav_fail_closed_misconfigured{sentinel!=\"boot\"} > 0"
              for   = "5m"
              labels = {
                severity = "critical"
              }
              annotations = {
                summary     = "omoikane-daemon on {{ $labels.instance }} is fail-closed with no malware scanner"
                description = "The malware gate is in block mode but no CLAMAV_URL is configured on {{ $labels.instance }}, so EVERY file upload will 503 — CVs, offer contracts and inbound mail attachments alike. Users see a broken uploader, not a security message. Check CLAUDE_/CLAMAV_URL in that host's /srv/omoikane-daemon/app/.env and 'curl -s https://app.omoikane.coach/readyz | jq .subsystems.clamav'. Either point it at a reachable clamd or set the gate to log mode deliberately; leaving it here means the product is down for uploads."
              }
            },
            {
              # The other half: the scanner is CONFIGURED but unreachable, so
              # ingests are being rejected one at a time. The daemon's own
              # description of this series: "a sustained non-zero rate on that
              # series means users are being turned away, not protected."
              #
              # Rate-based rather than a gauge, because a single unavailable
              # verdict is a blip (a restart, a timeout) while a sustained rate
              # is an outage the user experiences as "my CV will not upload".
              alert = "REDACTED_3437cf48"
              expr  = "sum by (instance) (rate(omoikane_clamav_verdict_total{outcome=\"unavailable\",mode=\"block\",sentinel!=\"boot\"}[15m])) > 0"
              for   = "15m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "omoikane-daemon on {{ $labels.instance }} is rejecting uploads it could not scan"
                description = "Ingests are being refused because the ClamAV scanner was unreachable or the payload exceeded the scan cap. This is the gate working as designed, but the user experience is a failed upload with no explanation. COVERAGE CAVEAT: handlers/upload.rs does NOT emit this series yet (it calls scan_bytes + verdict_gate by hand), so CV and LinkedIn uploads are invisible here — a quiet reading does NOT mean those paths are healthy."
              }
            },
          ]
        },
        {
          name = "custom-backup"
          rules = [
            {
              # OMOIKANE-1526 — restic retention is pinned to ONE host
              # (OMOIKANE-1510 item 2), because `restic forget --prune` needs an
              # exclusive repo lock and two hosts contending for it is what
              # produced the stale lock in OMOIKANE-1489.
              #
              # The failure mode that pinning leaves behind: lose the designated
              # host and the other keeps capturing, writes `ok-capture-only` and
              # reports GREEN, while pruning never runs again anywhere and the
              # bucket grows until it fills. That is exactly how OMOIKANE-1489
              # ran 81 days unnoticed.
              #
              # Staleness + absence, never failure. A failure rule cannot fire
              # here because nothing fails — the host is simply gone. And it is
              # deliberately aggregated with max() and NO host label: scoped to
              # one instance, losing that instance loses the series and the rule
              # silently stops evaluating at the exact moment it is needed.
              # Only the retention host ever reaches state=ok, so max() across
              # the estate is the correct reading of "has retention run at all".
              #
              # 3d, against a daily timer: two consecutive misses plus slack.
              alert = "OmoikaneResticRetentionStale"
              expr  = "(time() - max(omoikane_backup_retention_last_success_seconds) > 259200) or absent(omoikane_backup_retention_last_success_seconds)"
              for   = "30m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "restic retention has not succeeded anywhere in over 3 days"
                description = "No host has completed `restic forget --prune` for the shared omoikane-backups repo in more than 3 days, or the heartbeat metric has vanished entirely. Backups may still be CAPTURING fine — this is specifically about pruning, which is pinned to one host (OMOIKANE_RETENTION_HOST, default notrf01dmz01). If that host is down or was rebuilt, fail retention over by setting OMOIKANE_RETENTION_HOST in /etc/restic/omoikane.env on both hosts and restarting omoikane-backup.timer. Left alone, the repo grows until the bucket fills. See daemon backup/README.md and OMOIKANE-1489."
              }
            },
            {
              # OMOIKANE-1534 — the restic repo's SECOND copy. The primary lives
              # on SeaweedFS, and SeaweedFS's own PVCs are protected by Velero
              # writing to the SAME object storage, so losing that cluster
              # plausibly loses both the backups and the backup of the backups.
              # The mirror is written to /srv/yb-backups/restic-mirror and then
              # pulled to the Synology, which shares no fate with SeaweedFS.
              #
              # A second copy that silently stops is WORSE than none, because it
              # is counted on. So: staleness + absence, never failure — the same
              # shape as OmoikaneResticRetentionStale above and for the same
              # reason (a failure rule cannot fire when the producer is gone).
              #
              # This one is real: the first offsite pull left a 24 KB directory
              # with no config, no snapshots and no data — an empty shell that
              # read as "present" — because restic writes the repo 2700
              # root-owned and the NAS pulls as a different user.
              #
              # 3d against a daily 06:40 timer: two consecutive misses plus slack.
              alert = "OmoikaneResticMirrorStale"
              expr  = "(time() - max(omoikane_restic_mirror_last_success_seconds) > 259200) or absent(omoikane_restic_mirror_last_success_seconds)"
              for   = "30m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "restic second copy has not succeeded in over 3 days"
                description = "The second copy of the restic repository (/srv/yb-backups/restic-mirror on the retention host, mirrored to the Synology by the nightly pull) has not completed for more than 3 days, or its heartbeat has vanished. The PRIMARY backup may be perfectly healthy — this is specifically about the offsite duplicate, which exists because the primary repo lives inside SeaweedFS alongside Velero's own target. Check 'systemctl status omoikane-restic-mirror.service' on notrf01dmz01 and 'journalctl -u omoikane-restic-mirror'. See daemon backup/README.md and OMOIKANE-1534."
              }
            },
            {
              # The estate had ten omoikane timer-driven units and not one had
              # OnFailure=. node_systemd_unit_state is ALREADY scraped (1125
              # series on notrf01dmz01) and nothing consumed it.
              #
              # This is a LEVEL signal — it reports what is true right now.
              # An OnFailure= handler only fires on the TRANSITION into failure,
              # so by construction it can never report a unit that was already
              # failed when the handler was installed. Both are wanted; only
              # this one describes current reality.
              alert = "REDACTED_febdf887"
              expr  = "node_systemd_unit_state{name=~\"omoikane-.*|smoke-harness.*\",state=\"failed\"} == 1"
              for   = "10m"
              labels = {
                severity = "critical"
              }
              annotations = {
                summary     = "systemd unit {{ $labels.name }} is failed on {{ $labels.instance }}"
                description = "An omoikane timer-driven unit is in the failed state. On 2026-07-27 two such units had been failed for hours on both DMZ hosts with nobody aware, and restic retention died silently for 81 days the same way. Check 'systemctl status {{ $labels.name }}' and 'journalctl -u {{ $labels.name }}'."
              }
            }
          ]
        },
      ]
    }
  }
}
