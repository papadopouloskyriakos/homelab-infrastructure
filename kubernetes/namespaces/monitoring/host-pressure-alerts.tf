# =============================================================================
# PVE host-pressure proactive alerts — closes Phase 5 of HAHA reliability plan.
#
# pve01 + pve03 each host one node of HAHA AND one node of FISHA. A pressured
# pve host can cause file01/file02 NFS to stutter, which manifests as HA
# Recorder DB SIGBUS — the 2026-04-27 outage trigger event.
#
# Goal: page the operator with hours of headroom before pressure cascades into
# an HA outage. Memory pressure is the primary indicator (per IFRNLLEI01PRD-704
# repeated re-drift on pve01).
#
# These alerts inherit the existing node-exporter scrape from k8s monitoring
# stack; the pve* hosts must already be node-exporter targets. Verify with:
#   curl -s 'http://nl-prometheus.example.net/api/v1/query?query=up{instance=~"nlpve.*"}'
# =============================================================================

resource "kubernetes_manifest" "host_pressure_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "host-pressure-alert-rules"
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
          name     = "pve-host-pressure"
          interval = "30s"
          rules = [
            {
              alert = "REDACTED_c580ce1a"
              expr  = "(1 - (node_memory_MemAvailable_bytes{instance=~\"nlpve0[13].*\"} / node_memory_MemTotal_bytes{instance=~\"nlpve0[13].*\"})) > 0.85"
              for   = "10m"
              labels = {
                severity = "warning"
                tier     = "1"
                service  = "pve-host"
              }
              annotations = {
                summary     = "{{ $labels.instance }} memory >85% used for >10min ({{ $value | humanizePercentage }})"
                description = "PVE host memory pressure rising. {{ $labels.instance }} hosts one HAHA node + one FISHA node; sustained pressure here cascades into NFS stutter and HA recorder SIGBUS. Investigate VM RSS: `pvesh get /nodes/{{ $labels.instance | reReplaceAll \"nlpve0([13]).*\" \"$1\" }}/qemu` or directly check pressure with `cat /proc/pressure/memory`. Related: IFRNLLEI01PRD-704 (balloon floors)."
              }
            },
            {
              alert = "REDACTED_57cdabcd"
              expr  = "(1 - (node_memory_MemAvailable_bytes{instance=~\"nlpve0[13].*\"} / node_memory_MemTotal_bytes{instance=~\"nlpve0[13].*\"})) > 0.95"
              for   = "3m"
              labels = {
                severity = "critical"
                tier     = "1"
                service  = "pve-host"
              }
              annotations = {
                summary     = "{{ $labels.instance }} memory >95% used — HAHA + FISHA at risk"
                description = "PVE host is near-OOM. Cascading risk: file01/file02 NFS stutters → HA recorder SIGBUS → 60h+ outage class (ref. 2026-04-27 incident). Take action now: identify the worst VM with `pvestatd auto_balloon` data and either standby+migrate or stop a non-critical guest. Consider implementing IFRNLLEI01PRD-704 balloon floors permanently."
                impact      = "An HA recorder bus-error during SQLite mmap is now imminent. Detection (Phase A monitor_cmd) will catch the resulting HA crash but the underlying host is at fault."
              }
            },
            {
              alert = "PVELoadHigh"
              expr  = "node_load5{instance=~\"nlpve0[13].*\"} / count(node_cpu_seconds_total{mode=\"idle\",instance=~\"nlpve0[13].*\"}) by (instance) > 1.5"
              for   = "10m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "pve-host"
              }
              annotations = {
                summary     = "{{ $labels.instance }} 5-min load avg above 1.5 cores per CPU for >10min"
                description = "Sustained CPU saturation or I/O wait. Often correlates with DRBD replication backlog or guest disk thrashing. Check `top`, `iostat -x 5 5`, and per-VM CPU usage."
              }
            },
            {
              alert = "PVEZramSwapNearFull"
              expr  = "(1 - (node_memory_SwapFree_bytes{instance=~\"nl-pve01.*\"} / node_memory_SwapTotal_bytes{instance=~\"nl-pve01.*\"})) > 0.95"
              for   = "5m"
              labels = {
                severity = "warning"
                tier     = "1"
                service  = "pve-host"
              }
              annotations = {
                summary     = "{{ $labels.instance }} zramswap >95% saturated"
                description = "The 9.4 GiB zramswap cushion installed 2026-04-19 (per CLAUDE.md, IFRNLLEI01PRD-622) is exhausted. The cushion was the buffer between memory pressure and OOM-kill of LXC/VM workers. With it full, the next memory spike causes hard pressure. Same remediation as REDACTED_c580ce1a."
              }
            },
          ]
        },
      ]
    }
  }
}
