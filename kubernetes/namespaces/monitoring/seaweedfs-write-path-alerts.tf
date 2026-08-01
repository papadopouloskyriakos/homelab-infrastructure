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
                severity = "critical"
                # tier = "1"  # SMS-disabled 2026-08-01 (operator SMS triage — uncomment to re-page)
                category  = "storage-write-path"
                service   = "seaweedfs"
                namespace = "seaweedfs"
              }
              annotations = {
                summary     = "SeaweedFS volume server {{ $labels.pod }} has entered low-space protection"
                description = "{{ $labels.pod }} has marked {{ $value }} volume(s) read-only because free disk fell below -minFreeSpacePercent. It will ALSO refuse to compact while in this state, so volume.vacuum cannot dig it out — this is self-deadlocking and needs space added or the threshold lowered before GC can run. With replication:001 one server in this state fails writes for the WHOLE cluster, including collections that are nowhere near full. Check: kubectl exec -n seaweedfs {{ $labels.pod }} -- df -h /data, and the server log line 'disk_location.go: dir /data disk free X% < required Y%'."
                impact      = "S3 writes to nl-s3 fail cluster-wide with 'No writable volumes'. Known blast radius: cv.omoikane.coach goes fully down (its /api/health performs an S3 write), and Thanos/Loki/Tempo silently discard data. Reads keep working, so read-only health checks stay green."
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
                severity = "critical"
                # tier = "1"  # SMS-disabled 2026-08-01 (operator SMS triage — uncomment to re-page)
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
      ]
    }
  }
}
