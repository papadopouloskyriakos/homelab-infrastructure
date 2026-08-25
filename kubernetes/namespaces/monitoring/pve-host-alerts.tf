# =============================================================================
# PVE host SITE-LOCAL alerts — exporter liveness + host pressure for THIS
# site's PVE hosts (var.pve_hosts; empty list ⇒ no PrometheusRule).
# Canonical/mirrored: each cluster evaluates ONLY its own hosts, fed by the
# per-site `pve-exporter` / `pve-node-exporter` jobs in main.tf (handover from
# the NL estate job 2026-08-26 when GR Prometheus returned, IFRGRSKG01PRD-313).
#
# The CLUSTER-VIEW rules (PVENodeOffline / PVEOnbootGuestDown / PVEStorage* /
# PVEGuestNotBackedUp) deliberately stay NL-ONLY in host-pressure-alerts.tf
# (mirror-exempt): every pve-exporter serves the whole cluster view, so
# evaluating them on both sites would double every alert.
#
# NOTE PVELoadHigh: the historical expression divided node_load5 by
# `count(...) by (instance)` WITHOUT `on (instance)` — full-label vector
# matching returned an empty vector, so the rule could NEVER fire. Fixed here
# with `/ on (instance)` (verified live 2026-08-26: 5 series vs 0).
#
# Test/doc copy: claude-gateway prometheus/alert-rules/pve-host-health.yml.
# =============================================================================

resource "kubernetes_manifest" "pve_host_alert_rules" {
  count = length(var.pve_hosts) > 0 ? 1 : 0
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "pve-host-alert-rules"
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
          name     = "pve-exporter-liveness"
          interval = "60s"
          rules = [
            {
              alert = "PVEExporterDown"
              expr  = "up{job=\"pve-exporter\"} == 0"
              for   = "5m"
              labels = {
                severity = "warning"
                service  = "pve-host"
              }
              annotations = {
                summary     = "{{ $labels.instance }} prometheus-pve-exporter (:9221) is down"
                description = "The native pve-exporter on this PVE host stopped answering. Its scrape doubles as the API/pmxcfs responsiveness canary of that host. Runbook: claude-gateway docs/runbooks/pve-host-exporters.md (re-run scripts/pve-host-exporters-install.sh --check)."
              }
            },
            {
              alert = "PVENodeExporterDown"
              expr  = "up{job=\"pve-node-exporter\"} == 0"
              for   = "5m"
              labels = {
                severity = "warning"
                service  = "pve-host"
              }
              annotations = {
                summary     = "{{ $labels.instance }} node_exporter (:9100) is down"
                description = "Host-native node_exporter stopped answering — the REDACTED_75aca2cb rules go blind for this host. Runbook: claude-gateway docs/runbooks/pve-host-exporters.md."
              }
            },
          ]
        },
        {
          name     = "REDACTED_75aca2cb"
          interval = "30s"
          rules = [
            {
              alert = "REDACTED_c580ce1a"
              expr  = "(1 - (node_memory_MemAvailable_bytes{job=\"pve-node-exporter\"} / node_memory_MemTotal_bytes{job=\"pve-node-exporter\"})) > 0.85"
              for   = "10m"
              labels = {
                severity = "warning"
                tier     = "1"
                service  = "pve-host"
              }
              annotations = {
                summary     = "{{ $labels.instance }} memory >85% used for >10min ({{ $value | humanizePercentage }})"
                description = "PVE host memory pressure rising — guests on this node degrade before the host itself pages (ref: 2026-04-27 HAHA cascade; 2026-08-25 nlpve04 host-OOM killed nlk8s-node01). Check free -h and the top guests via pvesh get /cluster/resources; rebalance or stop non-critical guests."
              }
            },
            {
              alert = "REDACTED_57cdabcd"
              expr  = "(1 - (node_memory_MemAvailable_bytes{job=\"pve-node-exporter\"} / node_memory_MemTotal_bytes{job=\"pve-node-exporter\"})) > 0.95"
              for   = "3m"
              labels = {
                severity = "critical"
                # tier = "1"  # SMS-disabled 2026-08-01 (operator SMS triage — uncomment to re-page)
                service = "pve-host"
              }
              annotations = {
                summary     = "{{ $labels.instance }} memory >95% used — host OOM-kill imminent"
                description = "PVE host is near-OOM; the kernel OOM-killer will take a guest next (exactly the 2026-08-25 nlpve04 → nlk8s-node01 kill). Act now."
              }
            },
            {
              alert = "PVELoadHigh"
              expr  = "node_load5{job=\"pve-node-exporter\"} / on (instance) count(node_cpu_seconds_total{mode=\"idle\",job=\"pve-node-exporter\"}) by (instance) > 1.5"
              for   = "10m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "pve-host"
              }
              annotations = {
                summary     = "{{ $labels.instance }} 5-min load avg above 1.5 cores per CPU for >10min"
                description = "Sustained CPU saturation or I/O wait. Often correlates with DRBD replication backlog or guest disk thrashing — but if CPU is IDLE while load is high, suspect the pmxcfs wedge (see the pve-pmxcfs-wedge rules on NL). Check top, iostat -x 5 5."
              }
            },
          ]
        },
      ]
    }
  }
}
