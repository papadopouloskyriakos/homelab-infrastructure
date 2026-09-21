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
#
# Second group, "reclaimer-integrity" (2026-09-21, IFRNLLEI01PRD-2850): a Thanos
# compactor that is not running. ThanosCompactHalted / REDACTED_daccd521
# (seaweedfs-capacity-alerts.tf) read thanos_compact_* series, and a StatefulSet
# at 0 replicas emits none, so both were structurally unable to fire when the NL
# compactor was parked "until nl-s3 has room" on 09-15. Nothing applied Thanos
# retention for six days and nl-s3 filled again on 09-21. Keyed on
# kube-state-metrics instead. Lives in this NL-only (mirror-exempt) file on
# purpose: it covers NL and, via remote-write, notrf01; GR parks its compactor
# deliberately (IFRGRSKG01PRD-313) and is non-production.
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
        {
          name     = "reclaimer-integrity"
          interval = "5m"
          rules = [
            {
              alert = "REDACTED_8fdc9a1c"
              expr  = "max by (cluster) (kube_statefulset_replicas{namespace=\"monitoring\",statefulset=\"thanos-compactor\",cluster=~\"|notrf01\"}) == 0 or max by (cluster) (kube_statefulset_status_replicas_ready{namespace=\"monitoring\",statefulset=\"thanos-compactor\",cluster=~\"|notrf01\"}) == 0"
              for   = "12h"
              labels = {
                severity = "critical"
                tier     = "1" # same failure as ThanosCompactHalted, which pages since IFRNLLEI01PRD-2850
                service  = "thanos"
              }
              annotations = {
                summary     = "Thanos compactor not running on {{ if $labels.cluster }}{{ $labels.cluster }}{{ else }}nl{{ end }} for 12h"
                description = "thanos-compactor has 0 desired or 0 ready replicas. The compactor is the only thing that applies --retention.resolution-* and downsamples, so while it is down the Thanos bucket grows without bound and raw days that were never downsampled are lost for good once retention finally runs. ThanosCompactHalted cannot see this state: a StatefulSet at 0 replicas exports no thanos_compact_* series. If it was parked deliberately (REDACTED_bf135212 = 0 in terraform.tfvars), the park needs a re-enable, not a silence: on 2026-09-21 a 'back to 1 once there is room' park filled nl-s3 in six days (IFRNLLEI01PRD-2850). Before re-enabling on a nearly full store, cut --delete-delay and expect a net-negative first hour."
                impact      = "Unbounded growth of the site's Thanos bucket on SeaweedFS; when the store fills, every S3 writer (Velero, CNPG WAL, Loki, cv.omoikane.coach) stops."
              }
            },
          ]
        },
      ]
    }
  }
}
