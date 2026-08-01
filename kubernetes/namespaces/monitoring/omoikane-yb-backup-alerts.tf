# =============================================================================
# omoikane YugabyteDB DR snapshot-receive alerts — OMOIKANE-1287.
#
# The YB cluster (notrf01dmz03/04) pushes a ~1.4 GB snapshot to the two app
# hosts nightly at 03:00 UTC over the xfrm tunnels.
#
# On 2026-06-20 that receiver had no retention: 24 snapshots accumulated, both
# root filesystems reached 100%, and rsync thereafter authenticated and was
# ALLOWed but could not write. The DR pipeline was broken for roughly three
# days and nothing reported it — every check on the host asked whether the
# files existed, not whether last night's push had landed.
#
# Fed by `omoikane-yb-backup-metrics.sh` (daemon repo, `backup/`), a
# node-exporter textfile collector on a 15-minute timer. Both hosts are already
# targets of the `omoikane-node` job, so no scrape change was needed.
#
# ## The one design point that matters
#
# The exporter is a SEPARATE process from the receive wrapper, and the alerts
# below key off snapshot *age* rather than anything the receive path reports
# about itself. A metric emitted by the receiver can only ever describe receives
# that happened; it cannot say "last night's receive never ran", which is
# precisely what went wrong. Age-of-newest-snapshot can.
#
# Confirmed flowing 2026-07-29: both hosts, 3 snapshots each, newest 23.0h old,
# 14.86 GB, perm-truncation marker clear.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_c23b9ca7" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_ba0ba2b4"
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
          name     = "omoikane-yb-backup"
          interval = "60s"
          rules = [
            # -----------------------------------------------------------------
            # The receive is nightly at 03:00 UTC, so snapshot age cycles
            # naturally between 0 and 24h. 26h is one missed night plus two
            # hours of grace for a slow push; anything tighter would page on a
            # receive that merely started late.
            # -----------------------------------------------------------------
            {
              alert = "REDACTED_a0d02b01"
              expr  = "(time() - omoikane_yb_backup_newest_snapshot_seconds) > 26 * 3600"
              for   = "30m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "omoikane-dmz"
              }
              annotations = {
                summary     = "{{ $labels.instance }} has had no YugabyteDB DR snapshot for {{ $value | humanizeDuration }}"
                description = "Last night's DR push did not land. In the 2026-06-20 incident the cause was a full root filesystem: rsync authenticated and was ALLOWed but could not write, so the sending side saw no hard failure. Check disk first (`df -h /`), then the wrapper log on the receiving host: `sudo tail -30 /var/log/yb-backup-receive.log` — RECEIVE-FAIL, PRUNE-FAIL and REJECT all appear there. Ref OMOIKANE-1287."
              }
            },
            {
              alert = "REDACTED_c52c0699"
              expr  = "(time() - omoikane_yb_backup_newest_snapshot_seconds) > 50 * 3600"
              for   = "30m"
              labels = {
                severity = "critical"
                # tier = "1"  # SMS-disabled 2026-08-01 (operator SMS triage — uncomment to re-page)
                service = "omoikane-dmz"
              }
              annotations = {
                summary     = "{{ $labels.instance }} has missed two consecutive YugabyteDB DR snapshots ({{ $value | humanizeDuration }})"
                description = "Two nights with no DR snapshot. Retention keeps only 3, so continued failure walks the recovery point backwards and then off the end. The 2026-06-20 outage ran three days in this state undetected. Ref OMOIKANE-1287."
                impact      = "The disaster-recovery restore point is ageing. With keep=3 the usable window is about three days of failures before there is nothing recent to restore from."
              }
            },
            # -----------------------------------------------------------------
            # OMOIKANE-1515: the Synology PULLS this tree and rsync preserves
            # the sender's modes, so a 0600 file lands unreadable to the puller.
            # That once carried 1.01 MB of a 16.33 GB dataset offsite while
            # every check on this host passed. The receive wrapper drops a
            # marker file when its own permission verification fails.
            # -----------------------------------------------------------------
            {
              alert = "REDACTED_0f97d9d8"
              expr  = "omoikane_yb_backup_perm_normalise_failed > 0"
              for   = "15m"
              labels = {
                severity = "critical"
                # tier = "1"  # SMS-disabled 2026-08-01 (operator SMS triage — uncomment to re-page)
                service = "omoikane-dmz"
              }
              annotations = {
                summary     = "{{ $labels.instance }} DR snapshot is not readable by the offsite puller — the mirror WILL truncate"
                description = "The receive wrapper's permission normalisation failed and set /srv/yb-backups/.perm-normalise-failed. The offsite Synology pull runs as a different user and rsync preserves the SENDER's modes, so unreadable files are simply skipped — the mirror completes, reports success, and carries a fraction of the data. On 2026-07-27 that was 6 readable files out of 20402. Check `PERM-VERIFY-FAIL` in /var/log/yb-backup-receive.log. Ref OMOIKANE-1515 / OMOIKANE-1287."
              }
            },
            # -----------------------------------------------------------------
            # Retention keeps 3. Dropping below 2 means either a prune bug or
            # receives that are failing while old snapshots age out — both of
            # which shrink the restore window silently.
            # -----------------------------------------------------------------
            {
              alert = "REDACTED_0eef0b8f"
              expr  = "omoikane_yb_backup_snapshots < 2"
              for   = "1h"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "omoikane-dmz"
              }
              annotations = {
                summary     = "{{ $labels.instance }} holds only {{ $value }} DR snapshot(s)"
                description = "Retention is configured to keep 3 (OMOIKANE_YB_BACKUP_KEEP in /etc/default/yb-backup-receive). Fewer than 2 means either over-pruning or receives failing while existing snapshots age out. Ref OMOIKANE-1287."
              }
            },
            # -----------------------------------------------------------------
            # Watch the watcher. If the exporter stops, every rule above stops
            # matching and the silence looks identical to a healthy pipeline —
            # which is the whole failure mode being fixed here.
            # -----------------------------------------------------------------
            {
              alert = "REDACTED_277be7b6"
              expr  = "absent(omoikane_yb_backup_newest_snapshot_seconds{instance=\"notrf01dmz01\"}) or absent(omoikane_yb_backup_newest_snapshot_seconds{instance=\"notrf01dmz02\"})"
              for   = "1h"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "omoikane-dmz"
              }
              annotations = {
                summary     = "DR snapshot metrics missing from an omoikane app host"
                description = "No DR receive metrics from one of the two app hosts, so none of the alerts in this group can fire for it and its silence means nothing. Check `systemctl status omoikane-yb-backup-metrics.timer`, or reinstall from the daemon repo: backup/install-yb-backup-metrics.sh. Ref OMOIKANE-1287."
              }
            },
          ]
        },
      ]
    }
  }
}
