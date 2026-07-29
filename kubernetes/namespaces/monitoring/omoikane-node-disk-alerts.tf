# =============================================================================
# omoikane DMZ node disk-pressure alerts — OMOIKANE-183.
#
# Two production outages from the same cause:
#
#   2026-05-18 03:51Z  both DMZ hosts at 98-99%. The YB tablet server rejected
#                      writes ("Node ... has insufficient disk space"). Users
#                      saw every "Apply through omoikane" click redirect to
#                      /postings/discover?import=error.
#   2026-05-24 ~19:50Z recurrence at 87% / 92%. Daemon crash-looped on OIDC
#                      discovery because YB connections died mid-handshake.
#
# Both were found by a human looking. There was no disk alert then, and there
# was still none before this file — but NOT because nobody wrote one.
#
# ## Why the alerts that exist do not cover these hosts
#
# REDACTED_d8074874 ships the full node-exporter rule set:
# NodeFilesystemSpaceFillingUp, NodeFilesystemAlmostOutOfSpace,
# NodeFilesystemAlmostOutOfFiles, and so on. Every one of them is scoped
# `job="node-exporter"`.
#
# The omoikane hosts are scraped by the `omoikane-node` job defined in main.tf,
# not by the cluster's `node-exporter` job. Measured 2026-07-29:
#
#   count(node_filesystem_avail_bytes{job="node-exporter", instance=~"notrf01dmz0[12]"})   -> 0
#   count(node_filesystem_avail_bytes{job="omoikane-node", instance=~"notrf01dmz0[12]"})   -> 4
#   count(node_filesystem_avail_bytes{fstype!="", job="node-exporter", mountpoint!=""})    -> 40
#   count(node_filesystem_avail_bytes{fstype!="", mountpoint!=""})                         -> 91
#
# So 51 filesystem series estate-wide — every omoikane DMZ host, including the
# whole YugabyteDB tier whose full disk caused the outage — sat outside every
# disk alert in the system. Not a threshold set too high. A label mismatch that
# made the rules structurally incapable of seeing these hosts, which on a
# dashboard is indistinguishable from coverage.
#
# Same shape as OMOIKANE-1493, where the container-memory alerts were scoped to
# kube-state-metrics and could never match a docker-compose host.
#
# ## Scope
#
# `job="omoikane-node"` covers notrf01dmz01/02 (apps), notrf01dmz03/04 (YB),
# nldmz01 (YB arbitrator) and nlomktst01 (benchmark). 14 filesystem
# series, all ext4 or vfat — no overlay or tmpfs noise to filter out.
#
# At authoring time notrf01dmz01 was 80.4% and notrf01dmz02 80.6% full, so the
# 85% rule is quiet today but close enough to matter.
# =============================================================================

locals {
  # Used-percentage for every omoikane-scraped filesystem. Written once because
  # four rules need it and a typo in one copy would silently narrow that rule.
  omoikane_disk_used_pct = "100 * (1 - node_filesystem_avail_bytes{job=\"omoikane-node\",fstype!=\"\"} / node_filesystem_size_bytes{job=\"omoikane-node\",fstype!=\"\"})"
}

resource "kubernetes_manifest" "REDACTED_289e5914" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_845a0c85"
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
          name     = "omoikane-node-disk"
          interval = "60s"
          rules = [
            # -----------------------------------------------------------------
            # The threshold the incident report asked for, in its own words:
            # "surface BEFORE 99% breaks YB".
            # -----------------------------------------------------------------
            {
              alert = "REDACTED_96945896"
              expr  = "${local.omoikane_disk_used_pct} > 85"
              for   = "15m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "omoikane-dmz"
              }
              annotations = {
                summary     = "{{ $labels.instance }} {{ $labels.mountpoint }} is {{ $value | printf \"%.1f\" }}% full"
                description = "Disk pressure on an omoikane host. The usual causes here, in order: unbounded container json logs (`sudo du -sh /var/lib/docker/containers/*/*-json.log | sort -h | tail`), then dangling images from every :latest CI push (`docker system df`). Recovery that has worked twice: `truncate -s 0` the largest json.log files — no container restart needed — then `docker image prune -af` and `docker builder prune -af`. Ref OMOIKANE-183."
              }
            },
            # -----------------------------------------------------------------
            # 92%, not 95%. The 2026-05-24 recurrence already had YB connections
            # dying at 92%, so a 95% critical would have paged after the damage.
            # -----------------------------------------------------------------
            {
              alert = "REDACTED_dfa95302"
              expr  = "${local.omoikane_disk_used_pct} > 92"
              for   = "5m"
              labels = {
                severity = "critical"
                tier     = "1"
                service  = "omoikane-dmz"
              }
              annotations = {
                summary     = "{{ $labels.instance }} {{ $labels.mountpoint }} is {{ $value | printf \"%.1f\" }}% full — YugabyteDB writes at risk"
                description = "Act now. At this level on 2026-05-24 YugabyteDB connections were already dying mid-handshake, and at 98-99% on 2026-05-18 the tablet server rejected writes outright with 'Node ... has insufficient disk space' — every user 'Apply through omoikane' click failed. Free space immediately: truncate the largest container json logs, then prune images and build cache. Ref OMOIKANE-183."
                impact      = "YugabyteDB refuses writes when a tserver runs out of disk. The user-visible symptom is the apply/import flow failing for everyone, not a slow page."
              }
            },
            # -----------------------------------------------------------------
            # A static threshold catches a slow fill. It does not give much
            # warning for a fast one — the 2026-05-18 incident went from 62% to
            # 98% between sweeps, driven by container logs growing GB/day.
            # predict_linear catches that while there is still room.
            #
            # Floored at 60% so a small, fast-but-harmless fluctuation on a
            # mostly-empty disk does not page.
            # -----------------------------------------------------------------
            {
              alert = "REDACTED_e844cf2a"
              expr  = "(${local.omoikane_disk_used_pct} > 60) and (predict_linear(node_filesystem_avail_bytes{job=\"omoikane-node\",fstype!=\"\"}[6h], 24 * 3600) < 0)"
              for   = "30m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "omoikane-dmz"
              }
              annotations = {
                summary     = "{{ $labels.instance }} {{ $labels.mountpoint }} is on track to fill within 24h (now {{ $value | printf \"%.1f\" }}%)"
                description = "Projected from the last 6h of trend, this filesystem runs out within a day. On 2026-05-18 this disk went 62% -> 98% between manual sweeps because container json logs were growing by GB/day, so a static 85% threshold alone gives little warning. Find the grower: `sudo du -sh /var/lib/docker/containers/*/*-json.log | sort -h | tail`. Ref OMOIKANE-183."
              }
            },
            # -----------------------------------------------------------------
            # Inodes fill independently of bytes and produce a far more
            # confusing failure — writes fail with ENOSPC while `df -h` shows
            # free space. Currently 10.3% at the worst, so this is quiet.
            # -----------------------------------------------------------------
            {
              alert = "REDACTED_f228870d"
              expr  = "100 * (1 - node_filesystem_files_free{job=\"omoikane-node\",fstype!=\"\"} / node_filesystem_files{job=\"omoikane-node\",fstype!=\"\"}) > 85"
              for   = "15m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "omoikane-dmz"
              }
              annotations = {
                summary     = "{{ $labels.instance }} {{ $labels.mountpoint }} has used {{ $value | printf \"%.1f\" }}% of its inodes"
                description = "Inode exhaustion fails writes with ENOSPC while `df -h` still shows free space, which sends everyone looking in the wrong place. Check `df -i` and hunt for a directory with a very large number of small files. Ref OMOIKANE-183."
              }
            },
          ]
        },
      ]
    }
  }
}
