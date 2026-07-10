# =============================================================================
# Chaos-engineering — observability / liveness alert rules.
#
# Mirror of:
#   claude-gateway prometheus/alert-rules/chaos-engineering.yml
# When adding / changing / removing an alert, edit BOTH files. This .tf is the
# deployed truth; the YAML is the test+doc copy.
#
# Metric sources (node_exporter textfile collector on nlclaude01):
#   scripts/write-chaos-metrics.sh           (Cronicle */5)     -> chaos_metrics.prom
#   scripts/write-chaos-mtbf-metrics.py      (Cronicle */5)     -> chaos_mtbf.prom
#   scripts/verify-chaos-findings.py         (Cronicle 16:20)   -> chaos_findings_autoverify.prom
#   scripts/test-hook-blocks.py --adversarial (quarterly-redteam) -> redteam_metrics.prom
#
# Closes the 2026-04-25 undetected-freeze failure class: the chaos plane had
# ZERO alerts, so a dead metrics-writer or a multi-day drill freeze paged no one.
# Added 2026-07-10 (chaos defect-batch). All warning-tier by design — chaos is a
# self-improvement plane, not a production-serving one.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_9e4a5b5c" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_1388c5a9"
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
          name = "chaos-engineering"
          rules = [
            {
              alert = "REDACTED_781b2355"
              expr  = "time() - chaos_metrics_last_run_timestamp_seconds > 1800"
              for   = "10m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Chaos metrics exporter stale (>30m)"
                description = "write-chaos-metrics.sh (Cronicle */5) has not refreshed chaos_metrics.prom in over 30 minutes — the chaos observability plane is going dark."
              }
            },
            {
              alert = "REDACTED_40f5e03a"
              expr  = "absent(chaos_metrics_last_run_timestamp_seconds)"
              for   = "15m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Chaos metrics exporter absent"
                description = "chaos_metrics_last_run_timestamp_seconds has no series — the chaos textfile exporter is not being scraped at all (writer removed, wrong textfile dir, or permissions)."
              }
            },
            {
              alert = "ChaosDrillOverdue"
              expr  = "chaos_last_exercise_age_seconds > 1209600"
              for   = "1h"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "No chaos exercise in >14 days"
                description = "chaos-calendar.sh should run a weekly-baseline every Wednesday. The last scheduled exercise is over 14 days old — the drill scheduler may be wedged (2026-04-25 freeze class, generalized to a fortnight)."
              }
            },
            {
              alert = "REDACTED_13454230"
              expr  = "redteam_tests_fail > 0 and (time() - redteam_last_run_timestamp < 7776000)"
              for   = "30m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Chaos red-team: {{ $value }} adversarial guard test(s) failing"
                description = "The quarterly adversarial guard suite (test-hook-blocks.py G33-G52) reported failures in its most recent run (<90d old). Either unified-guard.sh regressed or the harness broke — inspect /tmp/chaos-calendar.log and rerun from the repo root."
              }
            },
            {
              alert = "REDACTED_d9400db6"
              expr  = "(time() - chaos_findings_harvest_timestamp_seconds > 172800) or absent(chaos_findings_harvest_timestamp_seconds)"
              for   = "1h"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Chaos findings harvester stale (>2d)"
                description = "verify-chaos-findings.py (Cronicle 16:20 UTC daily) has not run in >2 days — resolved findings will not be auto-closed and the YouTrack digest (IFRNLLEI01PRD-1744) will drift stale."
              }
            },
          ]
        },
      ]
    }
  }
}
