# =============================================================================
# Public-BGP upstream / transit health alert rules for AS214304.
#
# Mirror of:
#   claude-gateway prometheus/alert-rules/bgp-upstream-health.yml
# When adding / changing / removing an alert, edit BOTH files. This .tf is
# the deployed truth; the YAML is the test+doc copy and is consumed by
# scripts/qa/suites/test-726-prom-alert-rules.sh (promtool test rules).
#
# Metric source (node_exporter textfile collector on nlclaude01):
#   scripts/write-bgp-upstream-metrics.py  (cron */5)
#   -> /var/lib/node_exporter/textfile_collector/bgp_upstream.prom
# The script reuses get_ripe_bgp() from scripts/vpn-mesh-stats.py so the
# alert definition of "upstream" + "transit" matches what the live status
# diagram on kyriakos.papadopoulos.tech renders.
#
# Background: 2026-05-16 status-diagram fix.
# Memory: claude-gateway memory/status_diagram_upstream_render_gaps_20260516.md.
# =============================================================================

resource "kubernetes_manifest" "bgp_upstream_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "bgp-upstream-alert-rules"
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
          name     = "bgp-upstream-health"
          interval = "1m"
          rules = [
            {
              # A specific upstream (iFog AS34927 or Terrahost AS56655) has
              # disappeared from RIPE asn-neighbours for AS214304. 10 min
              # for: clause absorbs transient RIS update propagation gaps.
              alert = "REDACTED_3f814e57"
              expr  = "as214304_upstream_visible == 0"
              for   = "10m"
              labels = {
                severity = "critical"
                category = "bgp-public"
              }
              annotations = {
                summary     = "AS214304 upstream AS{{ $labels.asn }} ({{ $labels.name }}) not visible at RIPE for 10+ min"
                description = "RIPE asn-neighbours has stopped reporting AS{{ $labels.asn }} ({{ $labels.name }}) as a left-neighbour of AS214304. This typically means the eBGP session between iFog (AS34927) or Gigahost/Terrahost (AS56655) and {{ $labels.name }} is down. Verify the session is up at the upstream side. If BOTH upstreams are missing, our /48 prefix is unreachable from most of the internet. Runbook: docs/runbooks/upstream-bgp-failure.md."
              }
            },
            {
              # Aggregate fallback: even if the per-upstream gauge somehow
              # doesn't fire (e.g. all upstreams renumbered at once), this
              # catches the underlying "we lost upstream redundancy" state.
              alert = "REDACTED_a65c924a"
              expr  = "as214304_upstream_count < 2"
              for   = "5m"
              labels = {
                severity = "critical"
                category = "bgp-public"
              }
              annotations = {
                summary     = "AS214304 has only {{ $value }} upstream peer(s) visible at RIPE"
                description = "We're single-homed (or worse) for the {{ $value }} upstream still visible. The second upstream provides our redundancy — losing it means a single eBGP session away from full unreachability. Check status of iFog and Terrahost peerings. Runbook: docs/runbooks/upstream-bgp-failure.md."
              }
            },
            {
              # Soft signal: < 90% of RIS peers can see our /48. Often a
              # benign RIS propagation hiccup but persistent low visibility
              # is a real reachability problem worth investigating.
              alert = "REDACTED_6a59c053"
              expr  = "as214304_visibility_v6_pct < 90"
              for   = "15m"
              labels = {
                severity = "warning"
                category = "bgp-public"
              }
              annotations = {
                summary     = "AS214304 v6 prefix visibility dropped to {{ $value }}%"
                description = "Less than 90% of RIPE RIS peers can see our /48 prefix. Could be partial route propagation, a RIS data hiccup, or a real-world reachability drop. Cross-check at bgp.tools and Cloudflare Radar. If visibility stays < 90% for hours, treat it as a real partial-outage. Runbook: docs/runbooks/upstream-bgp-failure.md."
              }
            },
            {
              # Meta-alert: without this exporter the AS214304Upstream*
              # alerts cannot fire. Mirrors REDACTED_a1528267
              # in agentic-health-alerts.tf.
              alert = "REDACTED_08ee2180"
              expr  = "time() - as214304_bgp_metrics_last_run_timestamp > 1800"
              for   = "10m"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "AS214304 BGP-upstream metrics exporter has not run in 30+ min"
                description = "scripts/write-bgp-upstream-metrics.py is cron `*/5` on nlclaude01 — if its last-run timestamp is more than 30 min behind, the cron is wedged, the script is erroring, or RIPE STAT is unreachable for an extended period. Without this exporter, the AS214304Upstream* alerts cannot fire. Check `crontab -l` and run manually to reproduce."
              }
            },
          ]
        },
      ]
    }
  }
}
