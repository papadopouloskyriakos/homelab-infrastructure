# =============================================================================
# NFS server health alerts — closes IFRNLLEI01PRD-805.
#
# Fed by /usr/local/sbin/nfs-stale-fh-exporter.py on file01 + file02 (port 9101).
# Tracks NFS4ERR_STALE responses emitted by nfsd. Healthy server reports 0
# forever; any non-zero rate is the smoking-gun signal of fh-cache poisoning
# (the 2026-04-27 -> 2026-04-30 HAHA outage root cause).
#
# Detection ladder:
#   1. REDACTED_1395f6c8 — tcpdump-based exporter not scrapable.
#   2. NFSStaleFhPoisoning — server emitting STALE responses.
#   3. REDACTED_dc405c9b — exporter running but not seeing NFS
#      traffic (suggests tcpdump dropped, BPF filter wrong, or nfsd silent).
# =============================================================================

resource "kubernetes_manifest" "nfs_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "nfs-alert-rules"
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
          name     = "fisha-nfs-health"
          interval = "30s"
          rules = [
            {
              alert = "NFSStaleFhPoisoning"
              expr  = "rate(nfs_stale_fh_responses_total[5m]) > 0.05"
              for   = "3m"
              labels = {
                severity = "critical"
                # tier = "1"  # not tier-1 by operator decision 2026-08-25 (Matrix/YT only; tier-1 = ntfy paging population — docs/runbooks/paging-ntfy.md in claude-gateway)
                service = "fisha-nfs"
              }
              annotations = {
                summary     = "nfsd emitting NFS4ERR_STALE on {{ $labels.instance }} ({{ $value | printf \"%.2f\" }}/s)"
                description = "Likely fh-cache poisoning. This is the exact pattern that diagnosed the 2026-04-27 -> 2026-04-30 HAHA outage (~66h downtime). Phase 2 auto-flush should have caught this; if alert still fires, run `pcs resource restart exportfs --wait=60` manually on {{ $labels.instance }}. Verify with tcpdump: `tcpdump -i enp6s19 -nn -A 'src port 2049' | grep -i 'Stale NFS file handle'`. Refs IFRNLLEI01PRD-804 (auto-flush), IFRNLLEI01PRD-805 (this exporter)."
                impact      = "Fresh NFS mount attempts from clients (especially Pacemaker-managed Filesystem resources) will fail with `mount.nfs4: Stale file handle`. Existing mounts continue but new failovers will hang."
                runbook     = "memory `incident_haha_nfs_stale_fh_20260430.md`"
              }
            },
            {
              alert = "REDACTED_1395f6c8"
              expr  = "up{job=\"fisha-nfs-stale-fh\"} == 0"
              for   = "5m"
              labels = {
                severity = "warning"
                tier     = "1"
                service  = "fisha-nfs"
              }
              annotations = {
                summary     = "NFS stale-fh exporter unreachable on {{ $labels.instance }}"
                description = "The Prometheus exporter at port 9101 on file01/file02 is not responding. Detection of fh-cache poisoning is blind while this is firing. SSH to {{ $labels.instance }} and check `systemctl status nfs-stale-fh-exporter`. Likely cause: tcpdump not installed, NIC name changed, or service crashed."
              }
            },
            {
              alert = "REDACTED_dc405c9b"
              # Aggregate across both file01+file02 exporters: only fire when
              # NEITHER node sees NFS traffic. Previous per-instance form fired
              # on the standby HA member (which sees zero packets by design)
              # — IFRNLLEI01PRD-817. `max` returns the max packet rate across
              # instances; if it is zero, no exporter is seeing traffic.
              expr = "max(rate(nfs_stale_fh_exporter_packets_total[10m])) == 0 and min(nfs_stale_fh_exporter_uptime_seconds) > 600"
              for  = "10m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "fisha-nfs"
              }
              annotations = {
                summary     = "NFS stale-fh exporters on file01 AND file02 see zero NFS traffic"
                description = "Both fisha exporters are up but tcpdump has captured no NFS reply packets on either node for 10 min. Either nfsd is genuinely idle on whichever node is HA-active (verify with `ls /proc/fs/nfsd/clients/` and `pcs status resources`) or the BPF filter / NIC name is wrong on both nodes. Per-instance form was retired 2026-04-30 because it false-positived on the standby HA member; alert now requires BOTH exporters to be silent before firing."
              }
            },
          ]
        },
        {
          # Nightly file-level backup of /mnt/ocfs2 to nlpbs01, read from the
          # datastore by claude-gateway scripts/write-fisha-backup-metrics.py.
          # Test + doc copy: claude-gateway prometheus/alert-rules/fisha-backup.yml.
          name     = "fisha-ocfs2-backup"
          interval = "1m"
          rules = [
            {
              # A run was missed or failed; 26 h leaves 2 h of slack on the 04:00 UTC job.
              alert = "REDACTED_52d217ad"
              expr  = "time() - max(fisha_ocfs2_backup_last_success_timestamp_seconds) > 26 * 3600"
              for   = "10m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "fisha-nfs"
                scope    = "backup"
              }
              annotations = {
                summary     = "No finished FISHA OCFS2 backup on nlpbs01 for over 26 hours"
                description = "The nightly 04:00 UTC run of /opt/pve-backups/pbc-host-backup.sh on the node holding nfs-group produced no finished snapshot with ocfs2.pxar. Check /var/log/fisha-vm-backup/<node>/fisha-vm-backup-error.log on nlcl01file02."
              }
            },
            {
              # A run can finish with almost nothing if /mnt/ocfs2 was not mounted.
              alert = "REDACTED_19b69bce"
              expr  = "max(fisha_ocfs2_backup_last_size_bytes) < 20 * 1024 * 1024 * 1024"
              for   = "10m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "fisha-nfs"
                scope    = "backup"
              }
              annotations = {
                summary     = "Newest FISHA OCFS2 backup is under 20 GiB (normally about 74 GiB)"
                description = "The run finished but captured far too little, which usually means /mnt/ocfs2 was not mounted when it ran. Treat the snapshot as unusable and check the node that took it."
              }
            },
            {
              # Dead-man: no data must not read as no problem.
              alert = "REDACTED_7678c703"
              expr  = "absent(fisha_ocfs2_backup_collector_last_run_timestamp_seconds) or (time() - max(fisha_ocfs2_backup_collector_last_run_timestamp_seconds) > 3600) or (max(fisha_ocfs2_backup_collector_up) == 0)"
              for   = "30m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "fisha-nfs"
                scope    = "backup"
              }
              annotations = {
                summary     = "FISHA OCFS2 backup monitoring is blind"
                description = "scripts/write-fisha-backup-metrics.py on nlclaude01 is not running or cannot read the nlpbs01 datastore, so REDACTED_52d217ad cannot fire."
              }
            },
          ]
        },
      ]
    }
  }
}
