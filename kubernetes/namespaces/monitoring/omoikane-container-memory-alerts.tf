# =============================================================================
# omoikane DMZ container memory + OOM-kill alerts — OMOIKANE-1493.
#
# The daemon was memcg-OOM-killed 26 times on notrf01dmz02 between 23 Jul 12:12
# and 24 Jul 00:53 2026, every time at the 8 GiB cgroup ceiling, and NOTHING
# reported it. It was found by reading `dmesg` while chasing an unrelated bug.
#
# Why nothing caught it: `ContainerOOMKilled` and `REDACTED_879bd353` in
# custom-alerts.tf are built on kube-state-metrics. The omoikane app hosts are
# plain docker-compose on the DMZ, not k8s, so no series existed for them and
# the rules matched nothing. A rule that cannot match is not a quiet rule, it is
# an absent one.
#
# Feeding these rules: `omoikane-cgroup-metrics.sh`, a node-exporter textfile
# collector installed on both app hosts by the daemon repo
# (monitoring/host-metrics/, OMOIKANE-1493). It runs every minute and exports
# per-container memory.current / memory.max / memory.peak plus two OOM counters.
# These hosts are already node-exporter targets via the `omoikane-node` job in
# main.tf, so no scrape change is needed.
#
# Verify the feed before trusting these rules:
#   curl -s 'http://nl-prometheus.example.net/api/v1/query?query=omoikane_container_memory_bytes'
#   curl -s 'http://nl-prometheus.example.net/api/v1/query?query=omoikane_oom_kills_total'
# Confirmed flowing 2026-07-29: both hosts, 32 container series each, daemon
# ratio 0.627 (dmz01) / 0.625 (dmz02).
# =============================================================================

resource "kubernetes_manifest" "REDACTED_1d82d73d" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_629f1804"
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
          name     = "omoikane-container-memory"
          interval = "30s"
          rules = [
            # -----------------------------------------------------------------
            # The alert that actually prevents the outage.
            #
            # Each of the 26 kills was preceded by a climb of roughly 3 GiB over
            # about six minutes. At a 1-minute scrape that ramp is ~6 samples,
            # so `for: 5m` holds through it and still fires with headroom left.
            # An OOM counter can only ever report that the kill already
            # happened; this one arrives while there is still time to act.
            #
            # The `> 0` on the denominator drops containers with memory.max
            # unset — the exporter reports those as limit 0, and dividing by it
            # would yield +Inf and page on every unlimited container.
            #
            # 2026-08-01 — BOTH thresholds moved off omoikane_container_memory_bytes
            # (cgroup memory.current) onto ..._anon_bytes (memory.stat anon).
            # memory.current INCLUDES page cache, essentially all of which the
            # kernel reclaims before OOM-killing anything, so the old expression
            # could not distinguish "about to die" from "warm cache". It sent a
            # tier-1 SMS at 95.6% while the real state was: anon 6.78G of an 8G
            # limit (79%), file 1.42G of which inactive_file 1.42G — 1.4G of
            # instantly-reclaimable headroom, zero OOM kills, zero restarts, anon
            # flat across repeated sampling. anon is what the kernel's OOM
            # decision keys on. The July 23-24 incident this rule was built for
            # (26 kills in 12.7h) is visible on anon too: the signal is kept, the
            # false positive removed.
            # -----------------------------------------------------------------
            {
              alert = "REDACTED_87090a5b"
              expr  = "omoikane_container_memory_anon_bytes / (omoikane_container_memory_limit_bytes > 0) > 0.90"
              for   = "5m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "omoikane-dmz"
              }
              annotations = {
                summary     = "{{ $labels.container }} on {{ $labels.instance }} above 90% of its memory limit ({{ $value | humanizePercentage }})"
                description = "Container {{ $labels.container }} is approaching its cgroup ceiling. When it reaches it the kernel kills the process and docker restarts it, which for omoikane-daemon means dropped in-flight requests. Check the trend: `omoikane_container_memory_peak_bytes` gives the high-water mark since the container started. On the host: `docker stats --no-stream {{ $labels.container }}`. If the growth is legitimate rather than a leak, raise OMOIKANE_DAEMON_MEM_LIMIT in /srv/omoikane-daemon/app/.env and recreate ONE host at a time — the pair is the only redundancy. Ref OMOIKANE-1493."
              }
            },
            {
              alert = "REDACTED_d0f7e350"
              expr  = "omoikane_container_memory_anon_bytes / (omoikane_container_memory_limit_bytes > 0) > 0.95"
              for   = "2m"
              labels = {
                severity = "critical"
                # tier 2, NOT 1 (operator ruling 2026-08-01): omoikane has no
                # customers yet, so an SMS at 03:00 about a pre-launch container
                # is noise, not an incident. Restore tier="1" at launch, when a
                # crash-loop actually costs a user something.
                tier    = "2"
                service = "omoikane-dmz"
              }
              annotations = {
                summary     = "{{ $labels.container }} on {{ $labels.instance }} above 95% of its memory limit — OOM kill imminent"
                description = "An OOM kill is minutes away. On 23-24 July 2026 this state produced 26 kills of omoikane-daemon in 12.7 hours, in bursts roughly 6 minutes apart, and the container crash-looped through each burst. Act now rather than waiting for the restart. Ref OMOIKANE-1493."
                impact      = "The container's main process will be killed by the kernel and restarted, dropping in-flight work. On a crash-loop the host is effectively out of the pair."
              }
            },
            # -----------------------------------------------------------------
            # The forensic one: it definitely happened.
            #
            # Sourced from the kernel ring buffer rather than the cgroup
            # counter, because the cgroup is destroyed and recreated by the very
            # restart the kill causes — `memory.events` reads 0 again within
            # seconds and a 1-minute sampler never sees it. journald is not an
            # option either: on notrf01dmz02 `journalctl -k --grep oom` returns
            # zero lines for all time while dmesg holds 26.
            #
            # The exporter keeps a persistent tally so the series is monotonic
            # across container recreation AND reboot. Caveat: if
            # /var/lib/omoikane-cgroup-metrics is wiped the counter restarts,
            # and Prometheus reads that as a counter reset — expect one spurious
            # firing in that case.
            # -----------------------------------------------------------------
            {
              alert = "REDACTED_c6121fc1"
              expr  = "increase(omoikane_oom_kills_total[10m]) > 0"
              for   = "0m"
              labels = {
                severity = "critical"
                tier     = "1"
                service  = "omoikane-dmz"
              }
              annotations = {
                summary     = "{{ $labels.task }} was OOM-killed by its cgroup on {{ $labels.instance }} ({{ $value }} in 10m)"
                description = "The kernel killed {{ $labels.task }} for exceeding its memory cgroup limit. Confirm and read the size it died at: `dmesg -T | grep oom-kill | tail`. anon-rss in that line tells you whether it hit the configured ceiling or something far below it — a kill well under the limit points at a different cgroup, not this container. Ref OMOIKANE-1493."
              }
            },
            # -----------------------------------------------------------------
            # Watch the watcher.
            #
            # A textfile collector that stops running does not go red, it goes
            # SILENT — node-exporter simply stops serving the series and every
            # rule above quietly stops matching. That is the same failure shape
            # as the restic verify that sat dead for 81 days (OMOIKANE-1516)
            # while the thing it checked was also broken.
            #
            # `absent()` covers the collector being gone entirely; the staleness
            # arm covers it running but wedged.
            # -----------------------------------------------------------------
            {
              alert = "REDACTED_bcb59ba1"
              expr  = "(time() - omoikane_cgroup_metrics_last_run_seconds) > 600"
              for   = "5m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "omoikane-dmz"
              }
              annotations = {
                summary     = "omoikane cgroup metrics on {{ $labels.instance }} are {{ $value | humanizeDuration }} stale"
                description = "The exporter feeding every omoikane container-memory alert has stopped updating, so those alerts can no longer fire — absence of alerts from this host now means nothing. On the host: `systemctl status omoikane-cgroup-metrics.timer` and `journalctl -u omoikane-cgroup-metrics.service -n 50`. Ref OMOIKANE-1493."
              }
            },
            {
              alert = "REDACTED_a9bb4c91"
              expr  = "absent(omoikane_cgroup_metrics_last_run_seconds{instance=\"notrf01dmz01\"}) or absent(omoikane_cgroup_metrics_last_run_seconds{instance=\"notrf01dmz02\"})"
              for   = "15m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "omoikane-dmz"
              }
              annotations = {
                summary     = "omoikane cgroup metrics missing entirely from a DMZ app host"
                description = "No cgroup memory series at all from one of the two app hosts. Either node-exporter is down (check `up{job=\"omoikane-node\"}`) or the textfile collector was never installed / was removed. Reinstall from the daemon repo: monitoring/host-metrics/install-cgroup-metrics.sh. Ref OMOIKANE-1493."
              }
            },
          ]
        },
      ]
    }
  }
}
