# =============================================================================
# SeaweedFS WRITE-PATH alerts
#
# Closes the gap found on 2026-07-30 (IFRNLLEI01PRD-2052): the NL SeaweedFS S3
# write path was completely dead for 12h and NOTHING alerted. cv.omoikane.coach —
# a commercial SaaS domain — was down to the public internet the whole time, and
# Thanos, Loki and Tempo writes were being discarded with no signal at all. The
# outage was found only because an unrelated daily security scan happened to
# report a HAProxy backend as DOWN.
#
# WHAT ACTUALLY HAPPENED — the shape matters, because it explains the rules:
#
#   seaweedfs-volume-1 reached 6.99% free against -minFreeSpacePercent=7. Below
#   that line a volume server marks EVERY volume it holds read-only AND refuses
#   to compact. That is self-deadlocking: volume.vacuum is the tool that would
#   reclaim the space and it is disabled by the same condition it would fix
#   (verified — vacuum selected zero volumes even at -garbageThreshold=0.001).
#   With replication:001 a write needs a writable slot on BOTH servers, so one
#   server in low-space protection failed every allocation cluster-wide. That is
#   why even reactive-resume, whose entire collection is 0.2 GiB and nowhere near
#   any limit, could not be written.
#
# WHY EXISTING ALERTING MISSED IT — do not rely on either of these again:
#
#   1) KubePersistentVolumeFillingUp DID fire for seaweedfs on 2026-07-12,
#      eighteen days early (IFRNLLEI01PRD-1775 / -1767). Both were auto-closed by
#      alert-yt-autoclose.py the moment the PV dipped back under threshold, with
#      Resolution Type "None". A threshold oscillating is not a problem being
#      fixed. PV-percentage alerting is a trailing proxy anyway — the thing that
#      actually breaks is writability, so alert on writability.
#
#   2) Nothing watched the S3 write path itself. Health checks that only read
#      stayed green throughout: an authenticated ListObjects returned 200 in 85ms
#      while every PUT failed. Read-plane green is not write-plane green.
#
# tier="1" + severity="critical" is the Twilio SMS route (main.tf alertmanager
# route -> 10.0.X.X:9106). Applied to the two conditions that mean the
# cluster cannot accept writes, because that is a silent, total, and
# user-visible-only-by-accident failure.
#
# ⚠ TRAPS THESE RULES DELIBERATELY AVOID — do not "simplify" them:
#
#   A) volume_layout_writable is only meaningful on the RAFT LEADER. Followers
#      serve a stale/empty layout view — during this incident Prometheus held a
#      stale scrape showing 0 writable for a collection that the leader and the
#      other follower both reported as 22. Every layout expression below is
#      therefore joined against SeaweedFS_master_is_leader == 1. Without that
#      join the alert flaps on whichever follower was scraped last.
#
#   B) Do NOT alert on collections matching sync-test-* — they are cross-site
#      replication test leftovers that legitimately sit idle with no writable
#      volumes and would pin the alert on forever.
#
#   C) SeaweedFS_master_pick_for_write_error has no _total suffix but IS a
#      counter; PromQL emits an info-level warning on rate() over it. That
#      warning is expected and is not a reason to switch to increase()/delta().
# =============================================================================

resource "kubernetes_manifest" "REDACTED_78d971a7" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_a34d22c3"
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
          name     = "seaweedfs-write-path"
          interval = "1m"
          rules = [
            {
              # THE alert. type="isDiskSpaceLow" is literally "volumes I have put
              # read-only because my disk is below minFreeSpacePercent" — the exact
              # condition of the 2026-07-30 outage, named by the server itself
              # rather than inferred from a percentage. Zero on a healthy cluster,
              # so any non-zero value is actionable.
              alert = "REDACTED_cc66fa91"
              expr  = "sum by (instance, pod) (SeaweedFS_volumeServer_read_only_volumes{type=\"isDiskSpaceLow\"}) > 0"
              for   = "5m"
              labels = {
                severity  = "critical"
                tier      = "1" # re-promoted 2026-09-21 by operator decision (IFRNLLEI01PRD-2850): the 09-21 outage ran 12 h with no page
                category  = "storage-write-path"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS volume server {{ $labels.pod }} has entered low-space protection"
                description = "{{ $labels.pod }} has marked {{ $value }} volume(s) read-only because free disk fell below -minFreeSpacePercent. In SeaweedFS 4.44 a vacuum still compacts volumes that are read-only only because the disk is low (drill 2026-09-21), provided each server has free space >= the volume's .dat+.idx; the hourly seaweedfs-reconciler vacuums the highest-garbage volumes by explicit id, which is fast (the master's own walk takes 4+ h) and also covers volumes the master flags read-only. If the disk is 100 % full nothing can compact: free a volume by hand. With replication:001 one server in this state fails writes for the WHOLE cluster, including collections that are nowhere near full. Check: kubectl exec -n seaweedfs {{ $labels.pod }} -- df -h /data, and the server log line 'disk_location.go: dir /data disk free X% < required Y%'."
                impact      = "S3 writes to nl-s3 fail cluster-wide with 'No writable volumes'. Velero, CNPG WAL archiving and Thanos/Loki uploads all stop; Thanos/Loki/Tempo discard data silently. (cv.omoikane.coach no longer goes down with it since OMOIKANE-1668.) Reads keep working, so read-only health checks stay green."
              }
            },
            {
              # The symptom, independent of cause. Only increments when a write
              # assignment actually fails, so it catches any failure mode the
              # state-based rules above miss. Measured at ~194/s during the
              # 2026-07-30 outage and 0/s once writes recovered.
              alert = "REDACTED_8ea3848e"
              expr  = "sum(rate(SeaweedFS_master_pick_for_write_error[5m])) > 0"
              for   = "10m"
              labels = {
                severity  = "critical"
                tier      = "1" # re-promoted 2026-09-21 by operator decision (IFRNLLEI01PRD-2850): the 09-21 outage ran 12 h with no page
                category  = "storage-write-path"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS is failing to assign volumes for writes ({{ $value | printf \"%.1f\" }}/s)"
                description = "The SeaweedFS master is rejecting write-volume assignments. Every failure here is an S3 PUT that did not happen. Check the filer log for 'No writable volumes' and which collections it names: kubectl logs -n seaweedfs seaweedfs-filer-0 --tail 20. Most likely causes, in order: a volume server in low-space protection (see REDACTED_cc66fa91), the volume-count ceiling reached, or no volume satisfying the replication policy."
                impact      = "Silent write loss. Producers that do not surface S3 errors (Thanos, Loki, Tempo) drop data without complaint; apps whose health check writes to S3 go hard-down."
              }
            },
            {
              # A bucket the S3 gateway has made read-only: writes to it get 403
              # AccessDenied while every other bucket works, so REDACTED_8ea3848e
              # never sees it (IFRNLLEI01PRD-2850). Set by quota enforcement (every
              # minute, both directions) or by a path rule left behind when a bucket
              # was deleted and recreated (open upstream bug). max across filers:
              # each filer exports the same bucket.
              alert = "REDACTED_439f78b0"
              expr  = "max by (bucket) (SeaweedFS_s3_bucket_read_only{cluster=\"\"}) == 1"
              for   = "5m"
              labels = {
                severity  = "critical"
                tier      = "1"
                category  = "storage-write-path"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "S3 bucket {{ $labels.bucket }} is read-only: every write to it is refused"
                description = "SeaweedFS_s3_bucket_read_only=1 for {{ $labels.bucket }}. Over quota: weed shell `s3.bucket.quota -name {{ $labels.bucket }} -op get` and compare with `collection.list` (quota counts live single-copy bytes); free space in the bucket or raise its quota and it unlocks within a minute. No quota set: a stale path rule, check `fs.configure` for locationPrefix /buckets/{{ $labels.bucket }}/ and remove it with `fs.configure -locationPrefix=/buckets/{{ $labels.bucket }}/ -delete -apply`. Deletes still work while read-only."
                impact      = "Every writer of this bucket fails with 403; for a Thanos or Loki bucket that includes the retention markers, so its own reclaimer stops too."
              }
            },
            {
              # Leader-scoped (trap A) and excluding sync-test-* (trap B).
              # Warning rather than critical: the two rules above are the
              # actionable ones, this names WHICH collection is starved.
              alert = "REDACTED_adabb237"
              expr  = "min by (collection) ((SeaweedFS_master_volume_layout_writable{rp=\"001\", collection!~\"sync-test-.*\"} and on (instance) (SeaweedFS_master_is_leader == 1))) == 0"
              for   = "15m"
              labels = {
                severity  = "warning"
                category  = "storage-write-path"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS collection {{ $labels.collection }} has no writable volumes"
                description = "The raft leader reports zero writable volumes for collection {{ $labels.collection }} (replication 001). New writes to this collection will fail. Read via the LEADER only — follower masters serve a stale layout view and will disagree. Check: kubectl exec -n seaweedfs seaweedfs-master-0 -- sh -c 'echo \"volume.list\" | weed shell -master=localhost:9333' | head -5."
                impact      = "Writes to this collection fail. If the collection backs a user-facing service, that service is down for anything that writes."
              }
            },
          ]
        },
        {
          # READ-path canary rules (IFRNLLEI01PRD-2605). The canary CronJob in
          # namespaces/seaweedfs/read-canary.tf writes+reads a roundtrip object
          # and streams the 1GiB sentinel every 6h through the site's real
          # consumer path. Rules key on kube_job metrics (kube-state-metrics).
          # Stale rule includes absent() — a canary that has NEVER run must
          # alert, not read as healthy (the frozen-gauge lesson, 2026-08-23).
          name     = "seaweedfs-read-path"
          interval = "1m"
          rules = [
            {
              alert = "SeaweedFSReadCanaryFailed"
              # Bound to runs started in the last 12 h (two schedule periods):
              # a failed Job object from days ago kept this critical on NL for a
              # canary that had been green for a week (2026-09-15). The Stale
              # rule below still covers a canary that stops running.
              expr = "max by (job_name) (kube_job_status_failed{namespace=\"seaweedfs\", job_name=~\"seaweedfs-read-canary-.+\"}) > 0 and on (job_name) (time() - kube_job_status_start_time{namespace=\"seaweedfs\", job_name=~\"seaweedfs-read-canary-.+\"}) < 43200"
              for  = "5m"
              labels = {
                severity  = "critical"
                category  = "storage-read-path"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS read canary FAILED — objects are not coming back intact"
                description = "The read canary could not round-trip a small object or could not stream the 1GiB sentinel with the correct length+SHA256 through this site's consumer S3 path. This is the corruption/truncation class that broke barman restores on 2026-08-23 (ModSecurity cut a 2GB GET at exactly 512MiB with a clean EOF). Read the failed job log: kubectl -n seaweedfs logs job/<latest seaweedfs-read-canary job>."
                impact      = "Backups/restores and any large-object consumer on this path may be silently receiving truncated or corrupt data. Treat as a data-integrity incident, not an availability blip."
              }
            },
            {
              alert = "SeaweedFSReadCanaryStale"
              expr  = "(time() - max(kube_job_status_completion_time{namespace=\"seaweedfs\", job_name=~\"seaweedfs-read-canary-.+\"}) > 28800) or absent(kube_job_status_completion_time{namespace=\"seaweedfs\", job_name=~\"seaweedfs-read-canary-.+\"})"
              for   = "30m"
              labels = {
                severity  = "warning"
                category  = "storage-read-path"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS read canary has not completed in >8h (or has never run)"
                description = "No seaweedfs-read-canary job completion in over 8 hours (schedule is every 6h), or the metric is entirely absent. A canary that is not running certifies nothing — restore the CronJob or fix what blocks it; do not silence this."
                impact      = "The read path is unmonitored while this fires; corruption/truncation would go unseen exactly as it did before 2026-08-23."
              }
            },
          ]
        },
        {
          # MASTER raft health (IFRNLLEI01PRD-2605 follow-up, 2026-08-24). The
          # goraft election wedged leaderless TWICE in one day on peer churn:
          # every master healthy/0-restarts, all logging `topo leader: <nil>`,
          # filers cycling "raft.Server: Not current leader", every S3 PUT 500.
          # The 6h read canary is far too slow for this class. Cure that worked
          # both times: bounce all three masters; a leader emerged ~3min after
          # a full restart. {cluster=""} scopes to LOCAL series only — remote-
          # written twins carry a cluster label, and without the guard the NL
          # aggregation would count another site's leader and miss a local wedge.
          name     = "seaweedfs-master-raft"
          interval = "1m"
          rules = [
            {
              alert = "SeaweedFSMasterRaftLeaderless"
              expr  = "sum(SeaweedFS_master_is_leader{cluster=\"\"}) == 0"
              for   = "5m"
              labels = {
                severity  = "critical"
                category  = "storage-control-plane"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS master raft has NO leader — S3 writes are failing"
                description = "No master reports is_leader=1 for 5m. Filers cannot get volume assignments; every PUT returns 500. Known wedge (2x on 2026-08-24, after node cordon churn). Cure: bounce all three master pods (kubectl -n seaweedfs delete pod seaweedfs-master-{0,1,2}) and wait ~3min for the election; verify via /cluster/status Leader."
                impact      = "The site's S3 is write-dead while this fires: velero backups, barman WAL archiving, uploads and filer.sync all fail."
              }
            },
            {
              alert = "REDACTED_d1cc5a68"
              expr  = "absent(SeaweedFS_master_is_leader{cluster=\"\"})"
              for   = "15m"
              labels = {
                severity  = "warning"
                category  = "storage-control-plane"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS master leader metric is absent — the raft rule above is blind"
                description = "SeaweedFS_master_is_leader has no local series. Master scrape broken or masters gone; the Leaderless rule cannot fire in this state (a check that cannot express the failure certifies it)."
                impact      = "Master raft health is unmonitored while this fires."
              }
            },
          ]
        },
      ]
    }
  }
}
