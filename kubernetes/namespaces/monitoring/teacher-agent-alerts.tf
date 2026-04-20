# =============================================================================
# Teacher Agent Alert Rules (IFRNLLEI01PRD-654)
# Fed by /var/lib/node_exporter/textfile_collector/learning_progress.prom
# (cron scripts/write-learning-metrics.sh on nlclaude01, */5).
#
# Stale-cron alerts key off /var/lib/claude-gateway/teacher-<kind>.last mtime,
# bumped by teacher-agent.py._touch_last_run() at the end of a successful
# --morning-nudge or --class-digest run.
# =============================================================================

resource "kubernetes_manifest" "teacher_agent_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "teacher-agent-alert-rules"
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
          name     = "teacher-agent-health"
          interval = "1m"
          rules = [
            {
              alert = "REDACTED_e762a0b2"
              expr  = "absent(learning_operators_total)"
              for   = "15m"
              labels = {
                severity = "warning"
                service  = "teacher-agent"
              }
              annotations = {
                summary     = "teacher-agent Prometheus textfile exporter hasn't emitted for >=15m"
                description = "write-learning-metrics.sh (*/5 cron on nlclaude01) is expected to write learning_progress.prom every 5 minutes. Absent for 15m indicates the cron stopped, the SQLite DB is unreadable, or the textfile collector directory disappeared. Runbook: docs/runbooks/teacher-agent.md"
                impact      = "Learning progress observability blind. Crons themselves (morning-nudge, class-digest) may still be firing."
              }
            },
            {
              alert = "REDACTED_ca861940"
              expr  = "time() - learning_morning_nudge_last_run_timestamp > 129600"
              for   = "1h"
              labels = {
                severity = "warning"
                service  = "teacher-agent"
              }
              annotations = {
                summary     = "Morning-nudge cron hasn't fired for >=36h"
                description = "The daily 08:30 UTC `teacher-agent.py --morning-nudge` cron touches /var/lib/claude-gateway/teacher-morning_nudge.last on success. Gap >36h means the cron is broken or disabled. Operators won't see due-topic reminders. Runbook: docs/runbooks/teacher-agent.md"
                impact      = "Operators no longer pinged about due lessons. Progression stalls."
              }
            },
            {
              alert = "REDACTED_b30ef248"
              expr  = "time() - learning_class_digest_last_run_timestamp > 1209600"
              for   = "6h"
              labels = {
                severity = "warning"
                service  = "teacher-agent"
              }
              annotations = {
                summary     = "Weekly class-digest cron hasn't fired for >=14d"
                description = "The Sunday 16:00 UTC class-digest cron touches /var/lib/claude-gateway/teacher-class_digest.last on success. Gap >14d means two consecutive weeks missed — cron broken or the #learning Matrix room unreachable. Runbook: docs/runbooks/teacher-agent.md"
                impact      = "No weekly aggregate posted to #learning. Classroom feels abandoned."
              }
            },
          ]
        },
      ]
    }
  }
}
