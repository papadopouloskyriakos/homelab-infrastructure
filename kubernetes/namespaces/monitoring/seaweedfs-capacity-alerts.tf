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
      groups = concat([
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
                tier      = "1" # pages: it sat critical and unread for two days on 2026-09-13 while the store filled (IFRNLLEI01PRD-2850)
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
              # The CNPG janitor (_core/cnpg-janitor, IFRNLLEI01PRD-2850) releases latched
              # Backups and FAILS its Job when any ScheduledBackup has not fired, or its
              # cluster has not backed up, within 30h. Keyed on the CronJob's last
              # SUCCESSFUL run, so one rule covers: a stale schedule, a janitor that
              # errors, and one that never runs. absent() is essential: a janitor that
              # fails from its first run never gets a last-success series at all.
              alert = "REDACTED_4c435e3b"
              expr  = "((time() - max(kube_cronjob_status_last_successful_time{namespace=\"cnpg-system\", cronjob=\"cnpg-janitor\", cluster=\"\"})) > 3 * 3600) or absent(kube_cronjob_status_last_successful_time{namespace=\"cnpg-system\", cronjob=\"cnpg-janitor\", cluster=\"\"})"
              for   = "90m"
              labels = {
                severity  = "critical"
                tier      = "1"
                category  = "storage-capacity"
                service   = "cnpg"
                namespace = "cnpg-system"
              }
              annotations = {
                summary     = "CNPG backups unproven: the cnpg-janitor has not succeeded in 3h"
                description = "The hourly cnpg-janitor Job (namespace cnpg-system) has not completed successfully in 3h, or never has. It fails when a ScheduledBackup has not fired or its cluster has not backed up within 30h, printing one STALE line per problem: kubectl logs -n cnpg-system job/<latest cnpg-janitor-*>. A schedule that stopped firing is almost always a Backup that is not done (walArchivingFailing, or stuck running): the janitor releases those itself after 2h / 12h, so a STALE that persists means the backups themselves fail (check the Backup's status.error and the barman target's S3)."
                impact      = "Without new base backups, barman retention prunes nothing: the database's S3 prefix grows until the store fills (the 2026-09-21 nl-s3 outage), and point-in-time recovery depends on an ever-older base."
              }
            },
            {
              # --compact.skip-block-with-out-of-order-chunks (thanos.tf) marks such a block
              # no-compact instead of halting everything; a skipped block is then never
              # compacted or DOWNSAMPLED, so its data is lost once raw retention passes it.
              alert = "REDACTED_dab4956a"
              expr  = "sum(increase(thanos_compact_blocks_marked_total{marker=\"no-compact-mark.json\", cluster=\"\"}[24h])) > 0"
              for   = "15m"
              labels = {
                severity  = "warning"
                category  = "storage-capacity"
                service   = "thanos"
                namespace = "monitoring"
              }
              annotations = {
                summary     = "Thanos compactor marked {{ $value }} block(s) no-compact in 24h"
                description = "A block was skipped (out-of-order chunks or index too large) rather than halting the compactor. It will never be downsampled, so its history is lost when raw retention passes it. kubectl logs -n monitoring thanos-compactor-0 | grep -i 'no-compact'; repair or delete the block with `thanos tools bucket` before raw retention reaches it."
                impact      = "A gap in long-term metrics for the time range of the skipped block."
              }
            },
            {
              # Retention never waits for downsampling (thanos retention.go): if downsampling
              # falls behind raw retention, raw days are deleted with no 5m/1h copy. That is
              # how NL lost 2026-08-25 -> 09-14 while the compactor was halted/parked.
              alert = "REDACTED_1739a474"
              expr  = "max(thanos_compact_todo_downsample_blocks{cluster=\"\"}) > 0"
              for   = "24h"
              labels = {
                severity  = "warning"
                category  = "storage-capacity"
                service   = "thanos"
                namespace = "monitoring"
              }
              annotations = {
                summary     = "Thanos downsampling has had a backlog for 24h"
                description = "thanos_compact_todo_downsample_blocks has been above zero for a day. Raw retention deletes blocks whether or not they were downsampled, so a persistent backlog becomes a permanent gap in long-term metrics. Check the compactor log and its CPU/memory limits; never run `thanos tools bucket retention` while this fires (it does not downsample first)."
                impact      = "Long-term (5m/1h) metrics history is lost for every raw day that expires before it is downsampled."
              }
            },
            {
              # Loki's compactor applies retention_period; if it never runs the
              # bucket is unbounded regardless of what the config says. Before
              # 2026-09-10 Loki was not scraped at all, so this could not be known.
              # site="" (NOT cluster="", 2026-09-21): Loki exports its OWN label
              # cluster="loki", so the old cluster="" selector matched nothing and
              # the rule fired forever on absent(). That hid a real failure: NL's
              # value was 0 (never succeeded) because one expired table held 0-byte
              # index files (-2090 corruption) and retention aborted on it every run.
              # Local series carry no `site`; notrf01's remote-written copies on the
              # NL hub carry site="no". Pages: a dead reclaimer (IFRNLLEI01PRD-2850).
              alert = "LokiRetentionNotRunning"
              expr  = "absent(loki_compactor_apply_retention_last_successful_run_timestamp_seconds{site=\"\"}) or ((time() - max(loki_compactor_apply_retention_last_successful_run_timestamp_seconds{site=\"\"})) > 2 * 86400)"
              for   = "2h"
              labels = {
                severity  = "critical"
                tier      = "1"
                category  = "storage-capacity"
                service   = "loki"
                namespace = "logging"
              }
              annotations = {
                summary     = "Loki retention has not run successfully in 2 days (or is not measurable)"
                description = "loki_compactor_apply_retention_last_successful_run_timestamp_seconds is absent or older than 48h. Either the compactor is not applying retention (kubectl logs -n logging loki-0 -c loki | grep -E 'failed to (apply retention|compact files)'; the table it names may hold unreadable index files, see IFRNLLEI01PRD-2850), or Loki is not being scraped (monitoring.serviceMonitor.enabled in the chart values). A value of 0 means it has never succeeded since the pod started."
                impact      = "The loki S3 bucket grows without bound (+4 GB/day at NL when this was found)."
              }
            },
            {
              # The seaweedfs-reconciler (namespaces/seaweedfs/reconciler-cronjob.tf,
              # IFRNLLEI01PRD-2850) is the hourly reclaim loop: explicit-id vacuum,
              # deleteEmpty, vacuum.enable, abandoned uploads, drift vs Git. It fails
              # its Job on any parsed error, on "garbage but no room to compact" and
              # on drift. Keyed on the last SUCCESSFUL run (plus absent(): a job that
              # fails from its first run never gets that series), so one rule covers a
              # failing, a stuck (Forbid + lock held) and a missing reconciler.
              # Replaces SeaweedFSVacuumJobNotRunning (weekly CronJob, removed).
              alert = "REDACTED_875a0962"
              expr  = "((time() - max(kube_cronjob_status_last_successful_time{namespace=\"seaweedfs\", cronjob=\"seaweedfs-reconciler\", cluster=\"\"})) > 3 * 3600) or absent(kube_cronjob_status_last_successful_time{namespace=\"seaweedfs\", cronjob=\"seaweedfs-reconciler\", cluster=\"\"})"
              for   = "90m"
              labels = {
                severity  = "critical"
                tier      = "1"
                category  = "storage-capacity"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS reconciler has not succeeded in 3h: garbage is not being reclaimed"
                description = "The hourly seaweedfs-reconciler has not completed successfully in 3h, or never has. Read the last run: kubectl logs -n seaweedfs job/<latest seaweedfs-reconciler-*>; each step prints ok or FAILED. [vacuum] 'none fits in the free space' = the disk is too full to compact anything (free a volume by hand, e.g. delete an expired bucket prefix, or grow the PV). [drift] = a StatefulSet was changed live (restore it from Git, never edit it live). 'timed out ... weed lock held elsewhere' = someone is holding a weed shell lock. 'Vacuum is already running' is benign."
                impact      = "Deleted data stops turning back into free space; a burst of deletions (a retention catch-up) is not reclaimed, and the store drifts toward the write floor."
              }
            },
          ]
        },
        {
          name     = "REDACTED_552ff583"
          interval = "5m"
          rules = [
            {
              # The bulkhead's early warning (IFRNLLEI01PRD-2850). At 100 % the S3 gateway makes
              # the bucket read-only, and for Thanos/Loki that also stops their OWN retention
              # (deletion marks and index rewrites are writes), so a human must act before it.
              # size (not logical) is exported and is always >= the logical size the quota
              # enforces, so this errs early. Only buckets that have a quota have the series.
              alert = "REDACTED_b3f2fec6"
              expr  = "(max by (bucket) (SeaweedFS_s3_bucket_size_bytes{cluster=\"\"}) / max by (bucket) (SeaweedFS_s3_bucket_quota_bytes{cluster=\"\"} > 0)) > 0.85"
              for   = "30m"
              labels = {
                severity  = "critical"
                tier      = "1"
                category  = "storage-capacity"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "S3 bucket {{ $labels.bucket }} is at {{ $value | humanizePercentage }} of its quota"
                description = "{{ $labels.bucket }} will go read-only at 100 % of its quota (REDACTED_fd6d5350 in terraform.tfvars). First check its reclaimer (Thanos compactor / Loki retention), because a bucket that grows to its quota usually has a dead one; raise the quota in Git only if the steady state really grew. Current use: weed shell `s3.bucket.list`."
                impact      = "At 100 % the bucket refuses all writes, including its own retention markers, so it cannot shrink itself back."
              }
            },
            {
              # The PAGING forecast (IFRNLLEI01PRD-2850). SeaweedFSFreeSpaceForecast
              # below fired three days before the 2026-09-21 outage and paged nobody.
              # node-mixin shape: a 6h trend projected 72h ahead, gated on a level so
              # a quiet disk with a noisy trend does not page. Projects to the FLOOR,
              # not to zero: below -minFreeSpacePercent every volume is read-only.
              alert = "SeaweedFSWillFillSoon"
              expr  = "(100 * kubelet_volume_stats_available_bytes{persistentvolumeclaim=~\"data-seaweedfs-volume-.*\", cluster=\"\"} / kubelet_volume_stats_capacity_bytes{persistentvolumeclaim=~\"data-seaweedfs-volume-.*\", cluster=\"\"} < ${var.REDACTED_71980370 + 20}) and (predict_linear(kubelet_volume_stats_available_bytes{persistentvolumeclaim=~\"data-seaweedfs-volume-.*\", cluster=\"\"}[6h], 72 * 3600) < ${var.REDACTED_71980370 / 100} * kubelet_volume_stats_capacity_bytes{persistentvolumeclaim=~\"data-seaweedfs-volume-.*\", cluster=\"\"})"
              for   = "30m"
              labels = {
                severity  = "critical"
                tier      = "1"
                category  = "storage-capacity"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS PV {{ $labels.persistentvolumeclaim }} reaches the ${var.REDACTED_71980370}% write floor within 72h at the current rate"
                description = "The last 6h of free-space trend on {{ $labels.persistentvolumeclaim }} ({{ $labels.node }}) crosses -minFreeSpacePercent (${var.REDACTED_71980370}%) within 72h, and free space is already under ${var.REDACTED_71980370 + 20}%. Below the floor every volume goes read-only and every S3 writer stops. Find the growing collection: sort_desc(sum by (collection)(delta(SeaweedFS_volumeServer_total_disk_size[24h]))), then its reclaimer (Thanos compactor, CNPG backups, Loki retention, Velero TTL). The seaweedfs-reconciler vacuums garbage hourly; if garbage is high and free is not rising, check its last run."
                impact      = "At the floor the whole S3 write path stops (2052 / 2831 / 2850 class)."
              }
            },
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
        ], var.node_root_floor_alert_enabled ? [
        {
          name = "seaweedfs-node-floor"
          rules = [
            {
              # THE UNALERTED BAND (IFRNLLEI01PRD-2848, 2026-09-17). Between the storage
              # floor and the node-exporter defaults there was NO alert at all:
              #
              #   25% .......................... nothing watched this
              #   17%  seaweedfs minFreeSpacePercent -> volumes read-only, vacuum DISABLED
              #   15%  kubelet evictionHard imagefs.available -> node tainted, every
              #        LocalPV-pinned pod stranded, S3 gateway gone
              #    5%  NodeFilesystemAlmostOutOfSpace finally fires (kube-prometheus default)
              #
              # So the shipped node alert fires ten points BELOW the point at which this
              # site is already in a total outage. On 2026-09-17 the roots walked from
              # ~25% to 11.8% with nothing paging on the node itself: containerd had grown
              # to 26 GiB on dmz06 and 13 GiB on dmz01 because kubelet's
              # imageGCHighThresholdPercent (85) is the SAME point as evictionHard, so
              # image GC never runs before eviction rather than instead of it.
              #
              # 22% is chosen deliberately, not 25%. It sits 5 points (~7.7 GiB) above the
              # floor, which in steady state is days of warning. 25% was measured first and
              # rejected: dmz01 sits at 25.3% RIGHT NOW, so a 25% rule would fire the moment
              # it was deployed and never clear. An alert that is on at birth is an alert
              # that gets ignored - which is exactly how LokiRetentionNotRunning went
              # unactioned for seven days here. Warning, not critical: the point is lead
              # time, not urgency.
              alert = "REDACTED_76f07183"
              expr  = "min by (instance) (node_filesystem_avail_bytes{mountpoint=\"/\", fstype!~\"tmpfs|overlay\", cluster=\"\"} / node_filesystem_size_bytes{mountpoint=\"/\", fstype!~\"tmpfs|overlay\", cluster=\"\"}) < ${var.node_root_floor_threshold}"
              for   = "30m"
              labels = {
                severity = "warning"
                category = "storage-capacity"
                service  = "kubernetes"
              }
              annotations = {
                summary     = "Node {{ $labels.instance }} root filesystem is below 22% free - above the SeaweedFS floor but heading for it"
                description = "{{ $labels.instance }} has {{ $value | humanizePercentage }} free on /. These are 155 GiB shared roots carrying OS, containerd AND every local-hostpath PV. At 17% SeaweedFS latches its volumes read-only and can no longer vacuum - the operation that would free the space is the one the floor disables. At 15% kubelet taints the node and every LocalPV-pinned pod is stranded, which takes the S3 gateway down and with it Loki and Thanos retention, so nothing deletes anything any more. The shipped NodeFilesystemAlmostOutOfSpace does not fire until 5%, long past all of that. Act now while there is still headroom: check containerd size (`du -sh /var/lib/containerd`), the SeaweedFS garbage ratio, and that the daily vacuum CronJob is actually reclaiming rather than merely running."
                impact      = "Lead time before a storage deadlock that requires manual intervention to escape."
              }
            }
          ]
        }
      ] : [])
    }
  }
}
