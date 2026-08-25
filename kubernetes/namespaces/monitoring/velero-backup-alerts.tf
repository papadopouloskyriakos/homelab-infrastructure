# =============================================================================
# Velero BACKUP PHASE alerting
#
# Closes the gap named in IFRNLLEI01PRD-2091: "nothing pages on PartiallyFailed or
# Failed today, which is exactly how three months passed".
#
# EVERY backup on record was degraded — a stable 38 errors / 78 warnings
# `PartiallyFailed` back to at least 2026-05-10 — and nobody knew. That stability was
# itself the clue: one fixed set of resources failing nightly, not flakiness. The root
# cause turned out to be SeaweedFS kopia-blob corruption presenting one layer up
# (IFRNLLEI01PRD-2090); fixing the blobs produced the first clean backup on record with
# NO Velero change at all. Three months of failure went nowhere because nothing looked.
#
# Confirmed still live while writing these rules (2026-07-31): the most recent scheduled
# run, daily-backup-20260730020006, is phase=Failed — an S3 PutObject 500 from SeaweedFS
# during the write-path outage — with 5 errors and 9 warnings. Nothing alerted on that
# either. `min_over_time(velero_backup_last_status[7d])` == 0 for daily-backup proves the
# signal was there the whole time and simply had no rule attached.
#
# ⚠ FOUR TRAPS THESE RULES DELIBERATELY AVOID:
#
#  A) Do NOT alert on the *_total counters. velero_backup_partial_failure_total et al are
#     process counters that RESET when the velero pod restarts. Live proof: the pod has
#     ~60h uptime and reports partial_failure_total=2 for weekly-backup, while the cluster
#     holds ~35 PartiallyFailed Backup objects. A counter rule would have read "2 problems
#     ever" against three months of failure. The trustworthy signals are the
#     velero_backup_last_status gauge and the age of the last successful backup.
#
#  B) `last_status == 1` does NOT mean healthy. Velero reports PartiallyFailed as
#     success=1 in that gauge. That is precisely how the three-month gap stayed invisible.
#     REDACTED_9ac51d9f therefore keys on velero_backup_items_errors > 0, which is
#     non-zero on a PartiallyFailed run even while last_status reads 1.
#
#  C) A backup that never STARTS produces no failure signal at all — the metric simply
#     stops advancing. VeleroBackupStale is the dead-man for a schedule that silently
#     stopped firing, and REDACTED_8cdf02da bounds the age of the newest
#     usable restore point regardless of phase.
#
#  D) If the velero deployment is removed or its ServiceMonitor breaks there are no series
#     left to be 0, so every `== 0` rule goes quiet. VeleroMetricsMissing uses absent().
#
# ⚠ RELATIONSHIP TO custom-alerts.tf (updated 2026-08-16, canonical split).
# custom-alerts.tf used to carry three legacy Velero rules (VeleroBackupPartiallyFailed,
# VeleroBackupFailed, VeleroBackupStale). The first two were counter-based
# (`increase(velero_backup_partial_failure_total[1h]) > 0`) and exactly what trap A
# describes: counters reset on every velero pod restart, so `max_over_time(...[7d])`
# measured **0** across a week holding ~35 PartiallyFailed backups. All three were
# DELETED in the 2026-08-16 custom-alerts split — this file is now the single home of
# Velero alerting. Staleness/absence coverage here: REDACTED_8cdf02da
# (gauge timestamp) + VeleroMetricsMissing (absent()).
#
# tier="1" + severity="critical" is the Twilio SMS route (main.tf alertmanager route ->
# 10.0.X.X:9106). Applied to VeleroBackupFailed and REDACTED_8cdf02da:
# both mean the estate may have no usable restore point, and an untested backup is only a
# hypothesis to begin with.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_e981a6a4" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_663cbf23"
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
          name     = "velero-backup"
          interval = "1m"
          rules = [
            {
              # Hard failure of the most recent run for a schedule.
              alert = "REDACTED_59968a02"
              expr  = "velero_backup_last_status == 0"
              for   = "15m"
              labels = {
                severity = "critical"
                # tier = "1"  # not tier-1 by operator decision 2026-08-25 (Matrix/YT only; tier-1 = ntfy paging population — docs/runbooks/paging-ntfy.md in claude-gateway)
                team  = "infra"
                scope = "backup"
              }
              annotations = {
                summary     = "Velero backup FAILED for schedule {{ $labels.schedule }}"
                description = <<-EOT
                  The most recent Velero backup for schedule {{ $labels.schedule }} finished in a
                  failed phase. There may be no usable restore point from this run.

                  This is the alert that did not exist while three months of degraded backups
                  accumulated (IFRNLLEI01PRD-2091), and while daily-backup-20260730020006 failed
                  outright with an S3 PutObject 500 from SeaweedFS.

                  Check: kubectl -n velero get backups.velero.io --sort-by=.metadata.creationTimestamp | tail -10
                  Then: kubectl -n velero get backup <name> -o jsonpath='{.status.failureReason}'
                  A PutObject/500 failureReason points at the SeaweedFS write path, NOT at Velero —
                  see the seaweedfs low-space deadlock notes in k8s/CLAUDE.md.
                EOT
              }
            },
            {
              # Trap B: PartiallyFailed still reports last_status=1. items_errors is the
              # signal that survives that.
              alert = "REDACTED_9ac51d9f"
              expr  = "velero_backup_items_errors > 0"
              for   = "30m"
              labels = {
                severity = "warning"
                team     = "infra"
                scope    = "backup"
              }
              annotations = {
                summary     = "Velero backup for {{ $labels.schedule }} completed with {{ $value }} item errors"
                description = <<-EOT
                  The last backup for schedule {{ $labels.schedule }} reported
                  {{ $value }} item errors. Velero records PartiallyFailed as SUCCESS in
                  velero_backup_last_status, so this is the only phase signal that distinguishes a
                  clean backup from a degraded one — and a degraded backup is not a restore point
                  you can rely on.

                  A STABLE error count across runs is the tell that it is one fixed set of
                  resources failing every night, not flakiness. That pattern (38 errors / 78
                  warnings, unchanged for three months) turned out to be SeaweedFS object
                  corruption, not a Velero misconfiguration.

                  Check: kubectl -n velero get backup <name> -o jsonpath='{.status.errors} {.status.warnings}'
                  kubectl -n velero logs deploy/velero | grep -i error | tail -30
                EOT
              }
            },
            {
              # Trap C: bounds the age of the newest usable restore point, whatever the
              # phase. Daily schedule at 02:00 -> 26h covers a normal run plus slack.
              alert = "REDACTED_8cdf02da"
              expr  = "time() - velero_backup_last_successful_timestamp > 129600"
              for   = "30m"
              labels = {
                severity = "critical"
                # tier = "1"  # not tier-1 by operator decision 2026-08-25 (Matrix/YT only; tier-1 = ntfy paging population — docs/runbooks/paging-ntfy.md in claude-gateway)
                team  = "infra"
                scope = "backup"
              }
              annotations = {
                summary     = "No successful Velero backup in over 36 hours"
                description = <<-EOT
                  The newest successful Velero backup is more than 36 hours old (daily schedule
                  runs at 02:00). Whatever the individual run phases say, the estate's most recent
                  usable restore point is stale.

                  This is deliberately independent of the phase alerts: a schedule that silently
                  stops firing produces NO failure signal at all — the metric just stops advancing.

                  Check: kubectl -n velero get schedules.velero.io ;
                  kubectl -n velero get backups.velero.io --sort-by=.metadata.creationTimestamp | tail
                EOT
              }
            },
            {
              # Backup storage location unavailable => backups cannot be written at all.
              alert = "REDACTED_8b7ceddf"
              expr  = "velero_backup_location_status_gauge == 0"
              for   = "15m"
              labels = {
                severity = "critical"
                team     = "infra"
                scope    = "backup"
              }
              annotations = {
                summary     = "Velero backup storage location unavailable"
                description = <<-EOT
                  A Velero BackupStorageLocation is reporting unavailable. Backups cannot be
                  written, so every subsequent run will fail regardless of cluster health.

                  Backups target the same SeaweedFS S3 that the cluster itself depends on — a
                  known single point of shared failure flagged in IFRNLLEI01PRD-2091. When
                  SeaweedFS goes read-only (low-space deadlock), this is what fires.

                  Check: kubectl -n velero get backupstoragelocations.velero.io ;
                  kubectl -n velero logs deploy/velero | grep -i 'backupstoragelocation\\|s3' | tail -20
                EOT
              }
            },
            {
              # Restores matter as much as backups — an untested backup is a hypothesis.
              alert = "VeleroRestoreFailed"
              expr  = "increase(velero_restore_failed_total[1h]) > 0"
              for   = "5m"
              labels = {
                severity = "warning"
                team     = "infra"
                scope    = "backup"
              }
              annotations = {
                summary     = "A Velero restore failed"
                description = <<-EOT
                  At least one Velero restore failed in the last hour. Restores are rare here and
                  usually deliberate, so this is almost certainly a real recovery attempt going
                  wrong — or a restore drill finding a genuine problem, which is the point of
                  running one.

                  Uses increase() rather than the raw counter deliberately; the *_total counters
                  reset when the velero pod restarts.

                  Check: kubectl -n velero get restores.velero.io ;
                  kubectl -n velero logs deploy/velero | grep -i restore | tail -30
                EOT
              }
            },
            {
              # Trap D: everything gone => no series left to be 0.
              alert = "VeleroMetricsMissing"
              expr  = "absent(velero_backup_last_status)"
              for   = "30m"
              labels = {
                severity = "critical"
                team     = "infra"
                scope    = "backup"
              }
              annotations = {
                summary     = "Velero metrics have disappeared entirely"
                description = <<-EOT
                  velero_backup_last_status has no series at all. Either the Velero deployment is
                  gone, its ServiceMonitor broke, or the velero-metrics scrape target was dropped.

                  Every other rule in this group keys on `== 0` or a threshold, so all of them go
                  SILENT in this state — a missing check looks exactly like a passing one. That is
                  the same shape that let notrf01dmz01-04 sit unfirewalled for months while the
                  daily report read CLEAN.

                  Check: kubectl -n velero get pods ;
                  kubectl -n monitoring get servicemonitor | grep -i velero ;
                  Prometheus targets page -> job velero-metrics
                EOT
              }
            },
            {
              # Wedged-controller trap (IFRNLLEI01PRD-2605 follow-up, 2026-08-24):
              # the velero server sat with a created Backup CR at empty phase for
              # 22+ min after an S3 flap — schedules kept "existing" but produced
              # no attempts. attempt_total stops moving in exactly that state.
              # {cluster=""} = local series only (remote-written twins carry a
              # cluster label; without the guard this would double-evaluate).
              alert = "REDACTED_45e7a03a"
              expr  = "sum by (schedule) (increase(velero_backup_attempt_total{schedule!=\"\",cluster=\"\"}[26h])) == 0"
              for   = "30m"
              labels = {
                severity = "critical"
                team     = "infra"
                scope    = "backup"
              }
              annotations = {
                summary     = "Velero schedule {{ $labels.schedule }} produced NO backup attempt in 26h"
                description = <<-EOT
                  The daily schedule should attempt at least once per 24h; zero attempts in 26h
                  means the backup controller is wedged (seen 2026-08-24: BSL poller and backup
                  controller both went silent after an S3 flap; a created Backup CR sat with no
                  phase). This fires even when the LAST backup was green — success-age rules
                  cannot see a controller that has stopped trying.

                  Cure that worked: kubectl -n velero rollout restart deploy/velero
                  (and ds/node-agent if PVB data paths sit at 0 bytes).
                EOT
              }
            },
          ]
        },
      ]
    }
  }
}
