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
        # =====================================================================
        # pmxcfs-wedge signature (IFRNLLEI01PRD-1501)
        #
        # nl-pve01 has wedged its pmxcfs (/etc/pve FUSE fs) 3x
        # (2026-06-23/-27/-30; the -30 wedge took matrix LXC 101201202 down).
        # The signature is load-avg 100+ while CPU is ~IDLE: dozens of
        # pvesh/qm/pvestatd stuck D-state on /etc/pve. The PVELoadHigh rule
        # above CANNOT see it — pve01 is NOT a node_exporter/snmp target, so
        # `node_load5{instance="nl-pve01"}` returns no data and those rules
        # are silently inert for pve01. (Known gap; tracked in -1501.)
        #
        # These rules instead consume pve_wedge_* metrics emitted by
        # scripts/write-pve-wedge-metrics.sh on nlclaude01 (Cronicle */2),
        # which SSHes the PVE host and reports the wedge canary. Metrics are
        # labeled by `host=`, NOT `instance=` (the series lives on the
        # claude01 collector instance). No-install-on-PVE rule honored.
        # =====================================================================
        {
          name     = "pve-pmxcfs-wedge"
          interval = "30s"
          rules = [
            {
              # Early warning: D-state mgmt procs piling up OR pmxcfs probe
              # getting slow. Catches the wedge while CPU still looks idle —
              # the exact blind spot of the generic NodeSaturation alert.
              alert = "REDACTED_5cfc0fe8"
              expr  = "pve_wedge_dstate_procs > 25 or pve_wedge_pmxcfs_probe_seconds > 6"
              for   = "3m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "pve-host"
              }
              annotations = {
                summary     = "{{ $labels.host }} pmxcfs wedge forming — D-state mgmt procs / slow pmxcfs (NOT CPU)"
                description = "{{ $labels.host }}: D-state pvesh/qm/pvestatd procs > 25 OR pmxcfs probe > 6s. This is the pmxcfs-wedge signature (/etc/pve FUSE hung), NOT CPU saturation — the generic NodeSaturation alert mis-reads it. Likely a runaway pvesh/qm caller stranding D-state orphans. NO-REBOOT FIX: `systemctl restart pve-cluster` (FUSE teardown releases D-states) THEN `systemctl reset-failed pvestatd && systemctl restart pvestatd`. Inspect: pve_wedge_dstate_procs / pve_wedge_pmxcfs_probe_seconds in Grafana. Ref IFRNLLEI01PRD-1501, MR claude-gateway!130 (lab-stats amplifier fix)."
              }
            },
            {
              # Confirmed wedge: pmxcfs probe failing OR pvestatd blind to guests
              # OR the collector can't even SSH in (host down / sshd can't fork).
              alert = "PVEPmxcfsWedged"
              expr  = "pve_wedge_pmxcfs_probe_ok == 0 or pve_wedge_guests_status_unknown > 0 or pve_wedge_collector_up == 0"
              for   = "3m"
              labels = {
                severity = "critical"
                tier     = "1"
                service  = "pve-host"
              }
              annotations = {
                summary     = "{{ $labels.host }} pmxcfs WEDGED / unreachable — guests at risk (e.g. matrix CT 101201202)"
                description = "pmxcfs probe rc!=0, pvestatd reporting guest status=unknown, OR the collector cannot SSH in. This is the 3x-recurring wedge that takes guests on {{ $labels.host }} down (matrix, NPM, FreeIPA, Pi-hole, NetBox, NFS file01). NO-REBOOT FIX (proven 2026-06-27): `systemctl restart pve-cluster` FIRST (releases D-states) THEN `systemctl reset-failed pvestatd && systemctl restart pvestatd`. If SSH itself is dead, the host may need a PDU power-cycle. Ref IFRNLLEI01PRD-1501."
                impact      = "Guests on the wedged PVE host become unmanageable and may go unreachable. Generic NodeSaturation mis-attributes this to CPU — trust THIS alert."
              }
            },
            {
              # Dead-man: the collector itself stopped writing (cron dead /
              # claude01 down / textfile stale). Without this, a silent collector
              # looks identical to "all healthy".
              alert = "REDACTED_0356a081"
              expr  = "time() - pve_wedge_collector_last_run_timestamp_seconds > 900"
              for   = "5m"
              labels = {
                severity = "warning"
                tier     = "2"
                service  = "pve-host"
              }
              annotations = {
                summary     = "pmxcfs-wedge collector stale >15min — wedge detection is BLIND"
                description = "scripts/write-pve-wedge-metrics.sh on nlclaude01 (Cronicle */2) has not refreshed pve_wedge_* in >15min. The pmxcfs-wedge alerts are now blind. Check the Cronicle job + /home/claude-runner/logs/claude-gateway/pve-wedge-metrics.log. Ref IFRNLLEI01PRD-1501."
              }
            },
          ]
        },
      ]
    }
  }
}
