# =============================================================================
# Inter-site tunnel AUTO-HEAL health alerts (IFRNLLEI01PRD-1833, 2026-08-14).
#
# Mirror of:
#   claude-gateway prometheus/alert-rules/intersite-autoheal.yml   (group intersite-autoheal)
#   claude-gateway prometheus/alert-rules/REDACTED_6616a81a.yml (group REDACTED_6616a81a)
# When adding / changing / removing an alert, edit BOTH files. This .tf is
# the deployed truth; the YAML (+ .test.yml, promtool) is the test+doc copy.
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
#
# 2026-11-07 (IFRNLLEI01PRD-2992, NL power-loss postmortem):
#   - REDACTED_daf67915 keys on intersite_autoheal_failure_open (the last
#     REAL heal failed AND the leg has not been seen healthy since) instead of
#     the bare last_result == 0, which is history: it kept firing for months
#     after the freedom leg recovered on 2026-08-25.
#   - Group REDACTED_6616a81a: scripts/freedom-ont-heal.py (Cronicle */2 on
#     nlclaude01) detects a powered-but-dark Freedom ONT on nlsw01
#     Gi1/0/36 and, when armed, PoE-cycles it (max 3 per 24 h). Same NL-only,
#     mirror-exempt edge auto-heal layer as the group above, so it lives here.
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
              expr  = "intersite_autoheal_failure_open == 1"
              for   = "15m"
              labels = {
                severity = "critical"
                category = "bgp-intersite"
              }
              annotations = {
                summary     = "Intersite auto-heal FAILED on the {{ $labels.leg }} leg"
                description = "intersite-tunnel-heal.py executed the full both-ends re-key for the {{ $labels.leg }} NL<->GR leg but BGP did not re-Establish within the verify window, and the leg has not been seen healthy since. The wedge is deeper than the runbook re-key — human needed. Runbooks: edge/CLAUDE.md 'Total NL<->GR partition' + claude-gateway docs/runbooks/intersite-tunnel-autoheal.md."
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
        {
          name     = "REDACTED_6616a81a"
          interval = "1m"
          rules = [
            {
              # The post-power-loss wedge (2026-11-06: 8 h unnoticed). Fires
              # whether or not the heal is armed — the detector always runs.
              alert = "FreedomOntWedged"
              expr  = "freedom_ont_autoheal_wedged == 1"
              for   = "10m"
              labels = {
                severity = "warning"
                category = "wan-freedom"
              }
              annotations = {
                summary     = "Freedom ONT powered but dark on nlsw01 Gi1/0/36"
                description = "nlsw01 Gi1/0/36 (Freedom ONT) has been notconnect with PoE on for 10+ min and nlfw01 Track 1 is not Up — the post-power-loss wedge. If the auto-heal is armed it PoE-cycles the port itself; if freedom_ont_autoheal_suppressed is 1 (master switch, shadow, or disarmed) run the recipe by hand: interface Gi1/0/36 / power inline never / wait 15 s / power inline auto / shutdown / no shutdown. Runbook: docs/runbooks/REDACTED_6616a81a.md."
              }
            },
            {
              # A real PoE cycle did not bring Freedom back and it has not been
              # seen healthy (link + Track 1 Up) since.
              alert = "REDACTED_ac411470"
              expr  = "freedom_ont_autoheal_failure_open == 1"
              for   = "5m"
              labels = {
                severity = "critical"
                category = "wan-freedom"
              }
              annotations = {
                summary     = "Freedom ONT auto-heal did not restore Freedom"
                description = "freedom-ont-heal.py PoE-cycled nlsw01 Gi1/0/36 but the link and/or nlfw01 Track 1 did not come back, and Freedom has not been seen healthy since. Check freedom_ont_autoheal_last_link_restored: 1 = ONT link is back, PPPoE/BRAS is the problem; 0 = the ONT is still dark. Runbook: docs/runbooks/REDACTED_6616a81a.md."
              }
            },
            {
              # 3 PoE cycles in 24 h without recovery, or a PoE restore failed.
              alert = "REDACTED_5e16dec3"
              expr  = "increase(freedom_ont_autoheal_escalations_total[30m]) > 0"
              for   = "0m"
              labels = {
                severity = "critical"
                category = "wan-freedom"
              }
              annotations = {
                summary     = "Freedom ONT auto-heal escalated to a human"
                description = "The cap of 3 PoE cycles per 24 h was reached with the ONT still powered but dark, or a PoE restore failed (the port may be left with PoE OFF — run `power inline auto` on nlsw01 Gi1/0/36). The heal will not retry. Runbook: docs/runbooks/REDACTED_6616a81a.md."
              }
            },
            {
              # The detector itself is dark (absent() closes no-data=no-alert).
              alert = "REDACTED_eee0f969"
              expr  = "((time() - freedom_ont_autoheal_last_run_timestamp) > 900) or absent(freedom_ont_autoheal_last_run_timestamp)"
              for   = "10m"
              labels = {
                severity = "warning"
                category = "wan-freedom"
              }
              annotations = {
                summary     = "Freedom ONT detector/auto-heal has not run in 15+ min"
                description = "freedom_ont_autoheal.prom on nlclaude01 is stale or missing — the Cronicle job freedom-ont-heal (*/2) is broken, so FreedomOntWedged can no longer fire."
              }
            },
          ]
        },
      ]
    }
  }
}
