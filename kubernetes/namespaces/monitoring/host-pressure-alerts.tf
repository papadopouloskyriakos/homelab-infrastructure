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
# Since 2026-08-25 all 5 LIVE PVE hosts run a host-native node_exporter
# (per-site canonical job `pve-node-exporter` in main.tf, installed by
# claude-gateway scripts/pve-host-exporters-install.sh) — live for the first
# time. 2026-08-26: the pressure + liveness rules moved to the canonical
# per-site pve-host-alerts.tf; THIS file keeps only the NL-scoped zram rule,
# the pmxcfs-wedge canary rules, and the single-evaluation CLUSTER-VIEW group.
# Verify with:
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
            # (REDACTED_c580ce1a / REDACTED_57cdabcd / PVELoadHigh
            # moved 2026-08-26 to the canonical, per-site pve-host-alerts.tf —
            # group REDACTED_75aca2cb, job-scoped — so each cluster
            # covers its own hosts. PVELoadHigh also got the missing
            # `/ on (instance)` fix there; the old form never matched.)
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
        # pvesh/qm/pvestatd stuck D-state on /etc/pve. (Until 2026-08-25 no
        # PVE host was a node_exporter target, so the rules above were inert;
        # they are now live via the `pve-node-exporter` job. These wedge rules
        # remain complementary: the SSH canary sees D-state pile-ups and
        # pmxcfs probe latency that load/memory series cannot.)
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
                tier     = "1"   # restored 2026-08-25 (ntfy cutover)
                page     = "sms" # ULTRA-urgent: the paging bridge also SMSes this one (operator decision 2026-08-25)
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
        # =====================================================================
        # pve-exporter cluster-view rules (2026-08-25)
        #
        # Fed by the `pve-exporter` job in scrape-estate.tf: every live PVE
        # host serves the WHOLE cluster view (/pve?cluster=1&node=0), so the
        # expressions dedup with max by (id) / max by (storage) across the 5
        # reporters — any single surviving reporter keeps the rules alive,
        # including during an NL<->GR partition (reporters on both sites).
        # No tier=1 on any of these (operator SMS decision 2026-08-01).
        # =====================================================================
        {
          name     = "pve-exporter"
          interval = "60s"
          rules = [
            # (PVEExporterDown / PVENodeExporterDown moved 2026-08-26 to the
            # canonical pve-host-alerts.tf, group pve-exporter-liveness —
            # up{} is per-scraping-cluster, so liveness must be site-local.)
            {
              alert = "PVENodeOffline"
              expr  = "max by (id) (pve_up{job=\"pve-exporter\", id=~\"node/.*\", id!=\"node/nl-pve02\"}) == 0"
              for   = "3m"
              labels = {
                severity = "critical"
                service  = "pve-host"
              }
              annotations = {
                summary     = "PVE {{ $labels.id }} reports offline in /cluster/resources"
                description = "A live PVE cluster member is offline as seen by the surviving pve-exporter reporters (max by id across all 5). nl-pve02 is excluded (POWERED OFF by design, IFRNLLEI01PRD-2646). During an NL-GR partition the remote site nodes WILL show offline — correlate with IntersiteBGPLegDown."
              }
            },
            {
              alert = "PVEOnbootGuestDown"
              expr  = "(max by (id) (pve_up{job=\"pve-exporter\", id=~\"(qemu|lxc)/.*\"}) == 0) and on (id) (max by (id) (pve_onboot_status{job=\"pve-exporter\"}) == 1)"
              for   = "15m"
              labels = {
                severity = "warning"
                service  = "pve-host"
              }
              annotations = {
                summary     = "onboot guest {{ $labels.id }} is not running"
                description = "A guest with onboot=1 has been down >15m — after a host recovery this is the half-recovered-boot signature (cf. gr-pve01 2026-08-25: 36/36 onboot guests had to come back). Resolve the name via pve_guest_info on this id."
              }
            },
            {
              alert = "PVEStorageNearFull"
              expr  = "max by (storage) ((pve_disk_usage_bytes{job=\"pve-exporter\", id=~\"storage/.*\"} / (pve_disk_size_bytes{job=\"pve-exporter\", id=~\"storage/.*\"} > 0)) * on (id, instance) group_left (storage) pve_storage_info{job=\"pve-exporter\"}) > 0.85"
              for   = "30m"
              labels = {
                severity = "warning"
                service  = "pve-host"
              }
              annotations = {
                summary     = "PVE storage {{ $labels.storage }} above 85% ({{ $value | humanizePercentage }})"
                description = "Collapsed per storage NAME across nodes (shared storages alert once; for local storages the LibreNMS per-device disk rule names the exact host). At rollout 2026-08-25 nlpbs01 and nlpvecl01-nfs were already at 85.7% — known finding."
              }
            },
            {
              alert = "REDACTED_5ca3a25b"
              expr  = "max by (storage) ((pve_disk_usage_bytes{job=\"pve-exporter\", id=~\"storage/.*\"} / (pve_disk_size_bytes{job=\"pve-exporter\", id=~\"storage/.*\"} > 0)) * on (id, instance) group_left (storage) pve_storage_info{job=\"pve-exporter\"}) > 0.95"
              for   = "10m"
              labels = {
                severity = "critical"
                service  = "pve-host"
              }
              annotations = {
                summary     = "PVE storage {{ $labels.storage }} above 95% ({{ $value | humanizePercentage }})"
                description = "vzdump/PBS writes and guest disk allocation are about to start failing on {{ $labels.storage }}."
              }
            },
            {
              alert = "PVEGuestNotBackedUp"
              expr  = "max (pve_not_backed_up_total{job=\"pve-exporter\"}) > 0"
              for   = "6h"
              labels = {
                severity = "info"
                service  = "pve-host"
              }
              annotations = {
                summary     = "{{ $value }} PVE guests are in no vzdump/PBS backup job"
                description = "The cluster backup-info endpoint reports guests outside every backup job for >6h. List them via pve_not_backed_up_info. Known rollout state 2026-08-25: 9 guests. Place guests by LIVE node, never by VMID digits (memory: unbacked_guests_added_to_vzdump_20260803)."
              }
            },
          ]
        },
      ]
    }
  }
}
