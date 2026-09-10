# =============================================================================
# SeaweedFS CAPACITY leading indicators (IFRNLLEI01PRD-2831, 2026-09-10)
#
# Every rule in seaweedfs-write-path-alerts.tf fires AFTER volumes are already
# read-only. Twice in six weeks (IFRNLLEI01PRD-2052 on 2026-07-30, -2831 on
# 2026-09-10) the NL disks filled to 95 % and every S3 write stopped, and both
# times the cause was not the disk but a reclaimer that had silently stopped:
#   - the NL Thanos compactor had been HALTED for 2 weeks (thanos_compact_halted=1,
#     0 compactions/day) — Thanos retention is applied by the compactor, so
#     nothing was deleted or downsampled and thanos-nl reached 883 GB raw;
#   - the omoikane-main CNPG ScheduledBackup had not scheduled since 2026-08-26
#     (a Backup stuck in walArchivingFailing) — CNPG prunes WAL only past the
#     oldest RETAINED base backup, so retentionPolicy 14d pruned nothing;
#   - Loki said retention_enabled=true but was never scraped, so whether its
#     compactor ever applied retention was unknowable.
# None of that had an alert. This file alerts on the RECLAIMERS and on the
# TREND, so the disk-full state is never the first signal again.
#
# Canonical (byte-identical NL/GR/NO). `cluster=""` scopes every rule to the
# local site's own series: NL is also the remote-write hub for notrf01 and would
# otherwise double-fire on NO's series, which NO's own Prometheus already covers.
#
# ⚠ Validate every rule by INVERTING it against live Prometheus before merge
# (memory feedback_validate_alert_rules_by_inverting): an expression that can
# never return series is indistinguishable from a healthy system.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_8555c6b5" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_ce1de749"
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
          name     = "REDACTED_c3c1b312"
          interval = "1m"
          rules = [
            {
              # The reclaimer for the single largest consumer. Halted = Thanos
              # found a state it refuses to compact through (overlapping or
              # corrupt blocks); it keeps syncing metadata every minute and looks
              # alive from the outside, but retention and downsampling stop.
              # Recovery: `thanos tools bucket verify`, mark the block(s) for
              # deletion, restart the compactor. NL sat halted 2026-08-27 → 09-10.
              alert = "ThanosCompactHalted"
              expr  = "thanos_compact_halted{cluster=\"\"} == 1"
              for   = "30m"
              labels = {
                severity  = "critical"
                category  = "storage-capacity"
                service   = "thanos"
                namespace = "monitoring"
              }
              annotations = {
                summary     = "Thanos compactor {{ $labels.pod }} is HALTED — retention and downsampling have stopped"
                description = "thanos_compact_halted=1 on {{ $labels.pod }}. The compactor stops all work after a critical error (usually overlapping or corrupt blocks after an uncontrolled upload) and does NOT recover on its own; it still syncs block metadata every minute so it looks healthy. While halted, --retention.resolution-* is not applied and every 2h raw block from every Prometheus replica accumulates in the S3 bucket. Run: kubectl logs -n monitoring {{ $labels.pod }} | grep -i halt; then `thanos tools bucket verify` with the compactor's objstore config, `thanos tools bucket mark --marker=deletion-mark.json --id=<block>` for the offending block(s), and restart the pod."
                impact      = "The Thanos bucket grows without bound (~13 GB/day raw at NL) and will fill SeaweedFS; queries older than the raw retention window slowly disappear from downsampled resolutions."
              }
            },
            {
              # A compactor that is not halted but also never compacts is the same
              # failure with a different face (objstore unreachable, stuck lock,
              # wrong bucket). Two days with zero group compactions is abnormal
              # for any site that receives 2h blocks continuously.
              alert = "REDACTED_daccd521"
              expr  = "(sum by (pod) (increase(thanos_compact_group_compactions_total{cluster=\"\"}[2d])) == 0) and on (pod) (thanos_compact_halted{cluster=\"\"} == 0)"
              for   = "6h"
              labels = {
                severity  = "warning"
                category  = "storage-capacity"
                service   = "thanos"
                namespace = "monitoring"
              }
              annotations = {
                summary     = "Thanos compactor {{ $labels.pod }} has completed zero compactions in 2 days"
                description = "thanos_compact_group_compactions_total has not increased in 48h on {{ $labels.pod }} while the compactor reports not-halted. Check the compactor log for objstore errors, a stale lock, or an empty/wrong bucket; check thanos_objstore_bucket_operation_failures_total."
                impact      = "Raw blocks accumulate uncompacted; retention is effectively not running."
              }
            },
            {
              # CNPG only deletes WAL and base backups older than retentionPolicy
              # relative to the newest SUCCESSFUL backup. If the ScheduledBackup
              # stops scheduling (a Backup stuck in walArchivingFailing does
              # exactly this), retention prunes nothing and WAL grows forever —
              # omoikane-main: 17 days, 367 GB, +9 GB/day.
              alert = "REDACTED_2b95b756"
              expr  = "(time() - max by (namespace, cnpg_io_cluster) (cnpg_collector_last_available_backup_timestamp{cluster=\"\"})) > 2 * 86400"
              for   = "1h"
              labels = {
                severity = "critical"
                category = "storage-capacity"
                service  = "cnpg"
              }
              annotations = {
                summary     = "CNPG cluster {{ $labels.namespace }}/{{ $labels.cnpg_io_cluster }} has no successful backup for >2 days"
                description = "The newest successful base backup is {{ $value | humanizeDuration }} old. With a daily ScheduledBackup this means backups are failing or the schedule has stopped (kubectl get scheduledbackup,backup -n {{ $labels.namespace }}; a Backup stuck in walArchivingFailing blocks the next schedule). Until a new base backup succeeds, retentionPolicy prunes NOTHING and the WAL archive in S3 grows without bound."
                impact      = "Recovery point is aging and the object store fills; this is what filled NL SeaweedFS on 2026-09-10."
              }
            },
            {
              # Continuous archiving is the write side of the backup. A failing
              # archiver both breaks PITR and, once space is exhausted, is the
              # first casualty of a full S3 — so it doubles as an S3 write probe.
              alert = "REDACTED_2a56445c"
              expr  = "cnpg_collector_pg_stat_archiver_last_failed_time{cluster=\"\"} > cnpg_collector_pg_stat_archiver_last_archived_time{cluster=\"\"}"
              for   = "1h"
              labels = {
                severity = "critical"
                category = "storage-capacity"
                service  = "cnpg"
              }
              annotations = {
                summary     = "CNPG cluster {{ $labels.namespace }}/{{ $labels.cnpg_io_cluster }} WAL archiving is failing"
                description = "pg_stat_archiver's last failure is newer than its last success on {{ $labels.pod }} for over an hour. WAL segments pile up on the instance PV (which fills and crashes Postgres) and no PITR is possible past the last archived segment. Check: kubectl cnpg status {{ $labels.cnpg_io_cluster }} -n {{ $labels.namespace }}; the condition message names the barman-cloud-wal-archive error — 'exit status 4' with a full S3 is the 2831 signature."
                impact      = "Backups are incomplete and the database's own PV is at risk."
              }
            },
            {
              # The two rules above are blind when no CNPG cluster exports
              # metrics — which was the estate-wide state until 2026-09-10
              # (no Cluster had monitoring.enablePodMonitor). Say so.
              alert = "CnpgMetricsMissing"
              expr  = "absent(cnpg_collector_up{cluster=\"\"})"
              for   = "30m"
              labels = {
                severity = "warning"
                category = "storage-capacity"
                service  = "cnpg"
              }
              annotations = {
                summary     = "No CNPG cluster exports metrics — backup-age and WAL-archiving rules are blind"
                description = "cnpg_collector_up has no series at this site. Every CNPG Cluster needs spec.monitoring.enablePodMonitor: true (the operator's PodMonitor only covers the operator itself). While this fires, REDACTED_2b95b756 and REDACTED_2a56445c cannot express the failure they exist for."
                impact      = "A stuck ScheduledBackup or failing archiver is invisible."
              }
            },
            {
              # Loki's compactor applies retention_period; if it never runs the
              # bucket is unbounded regardless of what the config says. Before
              # 2026-09-10 Loki was not scraped at all, so this could not be known.
              alert = "LokiRetentionNotRunning"
              expr  = "absent(loki_compactor_apply_retention_last_successful_run_timestamp_seconds{cluster=\"\"}) or ((time() - max(loki_compactor_apply_retention_last_successful_run_timestamp_seconds{cluster=\"\"})) > 2 * 86400)"
              for   = "2h"
              labels = {
                severity  = "warning"
                category  = "storage-capacity"
                service   = "loki"
                namespace = "logging"
              }
              annotations = {
                summary     = "Loki retention has not run successfully in 2 days (or is not measurable)"
                description = "loki_compactor_apply_retention_last_successful_run_timestamp_seconds is absent or older than 48h. Either the compactor is not applying retention (check compactor.retention_enabled, delete_request_store, and the loki log for 'retention'), or Loki is not being scraped (monitoring.serviceMonitor.enabled in the chart values)."
                impact      = "The loki S3 bucket grows without bound (+4 GB/day at NL when this was found)."
              }
            },
            {
              # The scheduled explicit vacuum (namespaces/seaweedfs/vacuum-cronjob.tf)
              # is the safety net under the master's background GC. If its Job
              # fails, or has not completed in 8 days, the net is gone.
              alert = "REDACTED_d3ee51ca"
              expr  = "(max(kube_job_status_failed{namespace=\"seaweedfs\", job_name=~\"seaweedfs-vacuum-.+\", cluster=\"\"}) > 0) or ((time() - max(kube_job_status_completion_time{namespace=\"seaweedfs\", job_name=~\"seaweedfs-vacuum-.+\", cluster=\"\"})) > 8 * 86400) or absent(kube_cronjob_info{namespace=\"seaweedfs\", cronjob=\"seaweedfs-vacuum\", cluster=\"\"})"
              for   = "30m"
              labels = {
                severity  = "warning"
                category  = "storage-capacity"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS weekly vacuum job failed, is overdue, or the CronJob is missing"
                description = "The explicit weekly `weed shell` vacuum pass (seaweedfs-vacuum CronJob, Sunday 04:10 UTC) has a failed Job, has not completed in 8 days, or the CronJob object is gone. kubectl get jobs -n seaweedfs | grep vacuum; kubectl logs job/<name> -n seaweedfs. A pass that prints 'Vacuum is already running' is benign."
                impact      = "Garbage below master.garbageThreshold per volume is never reclaimed and empty volumes keep their slots."
              }
            },
          ]
        },
        {
          name     = "REDACTED_552ff583"
          interval = "5m"
          rules = [
            {
              # THE leading indicator this estate lacked. Linear projection of the
              # volume-server PV free bytes over the last 3 days: negative in 14
              # days means "you will hit the wall in two weeks at the current
              # rate" — while everything is still writable and vacuum still works.
              # Percentage thresholds (KubePersistentVolumeFillingUp) fired 18 days
              # early in July and were auto-closed on the first dip (Known Gap 5a);
              # a forecast is a statement about the trend, not the level.
              alert = "SeaweedFSFreeSpaceForecast"
              expr  = "predict_linear(kubelet_volume_stats_available_bytes{persistentvolumeclaim=~\"data-seaweedfs-volume-.*\", cluster=\"\"}[3d], 14 * 86400) < 0"
              for   = "1h"
              labels = {
                severity  = "warning"
                category  = "storage-capacity"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS PV {{ $labels.persistentvolumeclaim }} will be full within 14 days at the current rate"
                description = "Linear projection of free bytes over the last 3 days crosses zero within 14 days on {{ $labels.persistentvolumeclaim }} ({{ $labels.node }}). Find the consumer: sort_desc(sum by (collection)(delta(SeaweedFS_volumeServer_total_disk_size[24h]))). Then check that consumer's reclaimer (Thanos compactor halted? CNPG backups stuck? Loki retention? Velero TTL?) BEFORE considering more disk — twice the fix was a retention that had silently stopped."
                impact      = "Below -minFreeSpacePercent the whole S3 write path stops (2052/2831 class)."
              }
            },
            {
              # One collection projected to add more than a tenth of the whole
              # cluster's PV capacity within 30 days. Canonical form (no bucket
              # names): any collection, any site.
              alert = "REDACTED_9873c1d0"
              expr  = "(predict_linear(sum by (collection) (SeaweedFS_volumeServer_total_disk_size{cluster=\"\"})[3d:5m], 30 * 86400) - sum by (collection) (SeaweedFS_volumeServer_total_disk_size{cluster=\"\"})) > 0.10 * scalar(sum(kubelet_volume_stats_capacity_bytes{persistentvolumeclaim=~\"data-seaweedfs-volume-.*\", cluster=\"\"}))"
              for   = "2h"
              labels = {
                severity  = "warning"
                category  = "storage-capacity"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS collection '{{ $labels.collection }}' is on track to add >10% of total S3 capacity in 30 days"
                description = "Projected 30-day growth of collection {{ $labels.collection }} exceeds a tenth of the cluster's total volume-server PV capacity (2026-09-10 calibration: thanos-nl +447 GB, cnpg-omoikane +304 GB, cnpg-litellm +301 GB projected on a 2147 GB cluster — 10% catches all three, 25% none). This is the shape of a retention that has stopped (Thanos compactor halted, CNPG backups not succeeding, Loki compactor idle, Velero TTL removed) or a new unbounded writer. Every consumer of this S3 must have a retention that bounds it and an alert proving the retention runs."
                impact      = "At this rate the volume PVs fill and every writer stops."
              }
            },
            {
              # Slot exhaustion is the OTHER wall (IFRNLLEI01PRD-2605, 2026-08-26):
              # -max reached while the disk had room, replicated assigns hung.
              alert = "REDACTED_2f6b6876"
              expr  = "(sum by (pod) (SeaweedFS_volumeServer_volumes{cluster=\"\"}) / on (pod) max by (pod) (SeaweedFS_volumeServer_max_volumes{cluster=\"\"})) > 0.9"
              for   = "30m"
              labels = {
                severity  = "warning"
                category  = "storage-capacity"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS volume server {{ $labels.pod }} is using >90% of its volume slots (-max)"
                description = "{{ $labels.pod }} holds {{ $value | humanizePercentage }} of its -max volume slots. New volumes cannot be created once this reaches 100% even with free disk; replicated assigns then hang to timeout for any NEW collection while existing ones keep working. Raise REDACTED_d36a9dce in terraform.tfvars, or let the weekly vacuum's volume.deleteEmpty free slots."
                impact      = "Silent, bucket-selective write failure for new collections."
              }
            },
          ]
        },
      ]
    }
  }
}
