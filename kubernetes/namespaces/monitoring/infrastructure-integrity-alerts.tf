# =============================================================================
# Infrastructure-integrity alert rules.
#
# Fed by /var/lib/node_exporter/textfile_collector/asa_binding_drift.prom,
# written every 15 min by the `check-asa-binding-drift.py` cron on
# nlclaude01 (claude-gateway repo: scripts/check-asa-binding-drift.py).
#
# Root cause context — 2026-04-21 Matrix + portfolio outage:
#   `access-group vti_access_in` was stripped from every VTI interface on
#   both ASAs during unrelated xs4all troubleshooting. ACL still existed;
#   binding did not. Every site-to-site transit SYN was acl-dropped at
#   ingress while BGP kept working (control-plane bypasses interface ACLs),
#   masking the outage signal. These alerts close the observability gap.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_ddd03fc1" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_8b6e83db"
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
          name     = "infrastructure-integrity"
          interval = "5m"
          rules = [
            {
              alert = "ASABindingDrift"
              expr  = "asa_binding_drift_total > 0"
              for   = "10m"
              labels = {
                severity = "critical"
                service  = "site-to-site-vpn"
              }
              annotations = {
                summary     = "ASA config drift: {{ $value }} missing VTI access-group binding(s)"
                description = "At least one VTI interface has lost its `access-group vti_access_in` binding. Without it, transit traffic on that interface is silently dropped with `acl-drop` at ingress while BGP keeps working (control-plane bypasses interface ACLs), so the failure is invisible to normal health checks. This was the root cause of the 2026-04-21 Matrix + portfolio outage. Inspect: `python3 scripts/check-asa-binding-drift.py` on nlclaude01. Fix: on the affected ASA, re-apply `access-group vti_access_in in interface <iface>` then `write memory`."
                impact      = "Matrix, portfolio, and anything routed through the VPS VPN backhaul goes silently DOWN for external clients while BGP + internal health checks stay green."
              }
            },
            {
              alert = "REDACTED_33f74497"
              expr  = "time() - node_textfile_mtime_seconds{file=\"asa_binding_drift\"} > 3600"
              for   = "10m"
              labels = {
                severity = "warning"
                service  = "site-to-site-vpn"
              }
              annotations = {
                summary     = "ASA drift check metric stale (>1h since last update)"
                description = "The check-asa-binding-drift cron (`*/15`) on nlclaude01 hasn't refreshed asa_binding_drift.prom in the node-exporter textfile collector for over an hour. Root: `tail /tmp/asa-drift.log` on nlclaude01 and check `crontab -l | grep asa-binding-drift`. Alerting on the drift itself goes blind while this is firing."
                impact      = "ASABindingDrift alert cannot fire during the stale window."
              }
            },
          ]
        },
      ]
    }
  }
}
