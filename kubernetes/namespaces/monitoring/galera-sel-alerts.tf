# =============================================================================
# Galera no-Primary + in-band BMC SEL alert rules (IFRNLLEI01PRD-2992, NL power-loss
# postmortem 2026-11-06 items 8 and 13). NL-ONLY, mirror-exempt: the metrics exist
# only in NL Prometheus.
#
# Mirror of:
#   claude-gateway prometheus/alert-rules/galera-sel.yml (+ galera-sel.test.yml)
# When adding / changing / removing an alert, edit BOTH files. This .tf is the
# deployed truth; the YAML is the test+doc copy consumed by
# scripts/qa/suites/test-726-prom-alert-rules.sh (promtool test rules).
#
# Metric sources:
#   galera_*   claude-gateway scripts/write-galera-metrics.py, Cronicle job
#              galera-metrics (every minute) on nlclaude01 -> textfile
#              galera.prom -> scrape job chatops-node
#   pve_sel_*  claude-gateway scripts/pve-sel-exporter.py, systemd timer (5 min)
#              on nlpve04 -> /var/lib/prometheus/node-exporter/pve_sel.prom
#              -> scrape job pve-node-exporter
#
# Recovery for GaleraNoPrimary: claude-gateway scripts/galera-guarded-bootstrap.py
# (plan is read-only; --execute is operator-only, never automatic) and
# native/dbcluster/CLAUDE.md § Troubleshooting.
# =============================================================================

resource "kubernetes_manifest" "galera_sel_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "galera-sel-alert-rules"
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
          name     = "galera-cluster"
          interval = "1m"
          rules = [
            {
              # No DB node Primary while at least one DB host answers SSH = every proxysql
              # consumer is down. The `and` keeps an SSH failure from nlclaude01 (no
              # evidence either way) out of this rule: that is GaleraStateUnknown.
              # tier 1 = ntfy push to the phone, one per episode (operator decision
              # 2026-11-07): a total DB outage needs a human for the guarded bootstrap.
              alert = "GaleraNoPrimary"
              expr  = "max by (cluster) (galera_node_primary) == 0 and on (cluster) max by (cluster) (galera_node_host_reachable) == 1"
              for   = "5m"
              labels = {
                severity = "critical"
                category = "database"
                tier     = "1"
              }
              annotations = {
                summary     = "Galera {{ $labels.cluster }} has no Primary component (5+ min): every app on proxysql is down"
                description = "No DB node reports wsrep_cluster_status=Primary while at least one DB host answers SSH, so Nextcloud, paperless, healthops and the other proxysql consumers get 500s. Read-only plan: on nlclaude01 run ~/gitlab/n8n/claude-gateway/scripts/galera-guarded-bootstrap.py (it refuses on a UUID mismatch or a live Primary and names the highest-seqno winner). --execute is for the operator only, never automatic (postmortem IFRNLLEI01PRD-2992 item 8). Runbook: infrastructure/nl/production native/dbcluster/CLAUDE.md § Troubleshooting."
              }
            },
            {
              # The writer reaches no DB host: GaleraNoPrimary cannot see anything.
              alert = "GaleraStateUnknown"
              expr  = "max by (cluster) (galera_node_host_reachable) == 0"
              for   = "10m"
              labels = {
                severity = "warning"
                category = "database"
              }
              annotations = {
                summary     = "Galera {{ $labels.cluster }}: no DB host answers SSH from nlclaude01 (10+ min)"
                description = "write-galera-metrics.py cannot reach nlcl01mariadb01 or nlcl01mariadb02, so GaleraNoPrimary is blind. Check the hosts (nlpve04, nl-pve03) and SSH from nlclaude01 (root, ~/.ssh/one_key)."
              }
            },
            {
              # Dead-man: a textfile gauge is re-served forever by node_exporter, so a dead
              # writer reads healthy. absent() closes the no-data = no-alert gap.
              alert = "GaleraStateExporterStale"
              expr  = "(time() - max by (cluster) (galera_exporter_last_run_timestamp_seconds) > 600) or absent(galera_exporter_last_run_timestamp_seconds)"
              for   = "5m"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "Galera state writer has not run for 10+ min: GaleraNoPrimary is blind"
                description = "Cronicle job galera-metrics on nlclaude01 runs scripts/write-galera-metrics.py every minute into /var/lib/node_exporter/textfile_collector/galera.prom. A textfile gauge is re-served forever by node_exporter, so a dead writer looks healthy. Check the Cronicle job history and run the script by hand."
              }
            },
          ]
        },
        {
          name     = "pve-bmc-sel"
          interval = "1m"
          rules = [
            {
              # Keys on FIRST-SEEN (host clock), not the SEL timestamp: the BMC clock drifts
              # +2 h after each host clock sync. The exporter seeds existing records with
              # their event time on its first run, so deploying never fires; a record logged
              # while the host was hung fires once the host is back (the 2026-11-07 shape).
              # tier 2 = ntfy quiet topic alrt-quiet, visible but never rings (operator
              # decision 2026-11-07): it usually fires after the host is already back.
              alert = "PVEBMCCriticalEvent"
              expr  = "(time() - pve_sel_last_critical_seen_timestamp_seconds < 900) and pve_sel_last_critical_seen_timestamp_seconds > 0"
              for   = "0m"
              labels = {
                severity = "critical"
                category = "hardware"
                tier     = "2"
              }
              annotations = {
                summary     = "{{ $labels.instance }} BMC logged a new critical {{ $labels.type }} SEL event"
                description = "pve-sel-exporter saw a new critical BMC SEL assertion (type {{ $labels.type }}) on {{ $labels.instance }} within the last 15 min. If the host had hung, this fires once it is back. On 2026-11-07 06:25:37 UTC a PCI SERR from the BCM57416 10 G NIC (bus 05, both bond0 legs) halted nlpve04 with no kernel trace. Read the SEL: ssh root@{{ $labels.instance }} python3 /usr/local/bin/pve-sel-exporter.py --dump (records hex; --stdout for the decoded summary). Runbook: claude-gateway docs/runbooks/pve-host-exporters.md § In-band BMC SEL exporter."
              }
            },
            {
              # Dead-man for the SEL exporter (timer stopped, or /dev/ipmi0 unreadable).
              alert = "PVESelExporterStale"
              expr  = "(time() - pve_sel_last_run_timestamp_seconds > 1800) or pve_sel_read_ok == 0"
              for   = "15m"
              labels = {
                severity = "warning"
                category = "hardware"
              }
              annotations = {
                summary     = "{{ $labels.instance }} BMC SEL exporter is stale or cannot read /dev/ipmi0"
                description = "pve-sel-exporter.timer (5 min) has not completed a SEL read for 30+ min, or reports pve_sel_read_ok 0, so PVEBMCCriticalEvent is blind on this host. Check: systemctl status pve-sel-exporter.service; journalctl -u pve-sel-exporter; ls -l /dev/ipmi0 (ipmi_devintf)."
              }
            },
          ]
        },
      ]
    }
  }
}
