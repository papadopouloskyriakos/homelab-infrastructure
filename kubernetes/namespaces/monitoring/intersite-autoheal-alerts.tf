# =============================================================================
# Inter-site tunnel AUTO-HEAL health alerts (IFRNLLEI01PRD-1833, 2026-08-14).
#
# Mirror of:
#   claude-gateway prometheus/alert-rules/intersite-autoheal.yml
# When adding / changing / removing an alert, edit BOTH files. This .tf is
# the deployed truth; the YAML is the test+doc copy.
#
# Metric source (node_exporter textfile collector on nlclaude01):
#   scripts/intersite-tunnel-heal.py — the Layer-2 consumer invoked by
#   bgp-mesh-watchdog.sh (Cronicle emqurqyj26j, */5) after the metrics
#   publish. It executes the full both-ends wedged-SA re-key (netmiko, GR
#   via the :2222 stone) when an inter-site leg is down >=2 watchdog runs
#   and the wedge signature confirms (GR public pingable + decaps frozen /
#   no SA data). Runbook: claude-gateway
#   docs/runbooks/intersite-tunnel-autoheal.md.
#
# These alerts watch the HEALER, not the legs (the legs have
# REDACTED_51fe99b0): a failed heal, an escalation, and a dead
# consumer while armed each need a human.
# =============================================================================

resource "kubernetes_manifest" "intersite_autoheal_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "intersite-autoheal-alert-rules"
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
          name     = "intersite-autoheal"
          interval = "1m"
          rules = [
            {
              # The healer ran the full both-ends re-key and the leg still
              # did not re-Establish — deeper than the wedged-SA class.
              alert = "REDACTED_daf67915"
              expr  = "intersite_autoheal_last_result == 0"
              for   = "15m"
              labels = {
                severity = "critical"
                category = "bgp-intersite"
              }
              annotations = {
                summary     = "Intersite auto-heal FAILED on the {{ $labels.leg }} leg"
                description = "intersite-tunnel-heal.py executed the full both-ends re-key for the {{ $labels.leg }} NL<->GR leg but BGP did not re-Establish within the verify window. The wedge is deeper than the runbook re-key — human needed. Runbooks: edge/CLAUDE.md 'Total NL<->GR partition' + claude-gateway docs/runbooks/intersite-tunnel-autoheal.md."
              }
            },
            {
              # 3-strike cap reached, or GR unreachable over plain internet
              # (site outage, not a wedge). The healer stops retrying.
              alert = "REDACTED_a1123207"
              expr  = "increase(intersite_autoheal_escalations_total[30m]) > 0"
              for   = "0m"
              labels = {
                severity = "critical"
                category = "bgp-intersite"
              }
              annotations = {
                summary     = "Intersite auto-heal escalated to human"
                description = "The auto-heal consumer hit its 3-strike cap (repeated heals without lasting recovery) or found the GR site unreachable over plain internet. It will not retry — investigate via claude-gateway docs/runbooks/intersite-tunnel-autoheal.md."
              }
            },
            {
              # Armed but not running = the heal layer is silently dark.
              # Deliberately silent while DISARMED (armed gauge gates it).
              alert = "REDACTED_11ee2d95"
              expr  = "(intersite_autoheal_armed == 1) and ((time() - intersite_autoheal_last_run_timestamp) > 1800)"
              for   = "10m"
              labels = {
                severity = "warning"
                category = "bgp-intersite"
              }
              annotations = {
                summary     = "Intersite auto-heal consumer is stale while armed"
                description = "gateway.intersite_autoheal_armed is present but the consumer has not run in 30+ min — the bgp-mesh-watchdog hook (Cronicle emqurqyj26j) is likely broken, so the armed heal layer is silently dark."
              }
            },
          ]
        },
      ]
    }
  }
}
