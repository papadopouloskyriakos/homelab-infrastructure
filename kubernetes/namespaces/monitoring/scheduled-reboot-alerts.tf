# =============================================================================
# Scheduled-reboot suppression alert rules — IaC PrometheusRule twin.
#
# Mirror of: claude-gateway prometheus/alert-rules/agentic-health.yml
#            (group "scheduled-reboot"). When adding/changing/removing an
# alert, edit BOTH — the YAML is the promtool test+doc copy
# (scripts/qa/suites/test-726-prom-alert-rules.sh), this .tf is deployed truth.
#
# Previously YAML-only ("tf-twin deferred"): the self-learning scheduled-reboot
# suppression feature (LIVE + armed via ~/gateway.sched_reboot since 2026-06-29)
# emits scheduled_reboot_* metrics via write-scheduled-reboot-metrics.sh (*/5
# Cronicle) — scraped on nlclaude01 (job chatops-node) — but no in-cluster
# rule alerted on them. Deploying the twin now the feature is confirmed live +
# emitting (metric present, sentinel armed 2026-07-08), so the absent() clause
# in REDACTED_e9ab4b94 is a real dead-man, not a false positive.
#
# Runbook: claude-gateway docs/runbooks/scheduled-reboot-suppression.md
# =============================================================================

resource "kubernetes_manifest" "REDACTED_faf4a833" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_a8cf98c9"
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
          name     = "scheduled-reboot"
          interval = "1m"
          rules = [
            {
              alert = "REDACTED_880627c0"
              expr  = "increase(scheduled_reboot_misclassified_total[1h]) > 0"
              for   = "1m"
              labels = {
                severity = "critical"
                tier     = "1"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "scheduled-reboot two-phase verify REOPENED {{ $value }} suppression(s) in 1h"
                description = "A reboot suppressed as 'scheduled' was confirmed by the two-phase verify NOT to be a clean systemd-reboot (OOM/watchdog/self-heal landed in-window). The verify already force-escalated a real investigation + paged #alerts; this alert is the aggregate signal."
              }
            },
            {
              alert = "REDACTED_e9ab4b94"
              expr  = "(time() - scheduled_reboot_metrics_last_run_timestamp_seconds > 1200) or absent(scheduled_reboot_metrics_last_run_timestamp_seconds)"
              for   = "30m"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "scheduled-reboot metrics exporter stale 20m+ (or absent)"
                description = "write-scheduled-reboot-metrics.sh (*/5 Cronicle) is not running. Registry counts + verify accumulators stop updating."
              }
            },
            {
              alert = "REDACTED_e648eeb8"
              expr  = "scheduled_reboot_registry_entries{status=\"observing\"} > 0 and on() (time() - scheduled_reboot_metrics_last_run_timestamp_seconds < 1200)"
              for   = "3h"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "scheduled-reboot: observing row(s) not promoting to live"
                description = "A discovered schedule has stayed 'observing' — either its cron never fires as predicted (wrong attribution) or the promoter can't SSH the host. Check promote-scheduled-reboot logs."
              }
            },
          ]
        },
      ]
    }
  }
}
