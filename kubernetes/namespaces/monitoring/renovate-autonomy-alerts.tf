# =============================================================================
# Renovate MR Autonomy lane — safety / liveness alert rules.
#
# Mirror of:
#   claude-gateway prometheus/alert-rules/renovate-autonomy.yml
# When adding / changing / removing an alert, edit BOTH files. This .tf is the
# deployed truth; the YAML is the test+doc copy consumed by
# scripts/qa/suites/test-726-prom-alert-rules.sh (promtool test rules).
#
# Metric source (node_exporter textfile collector on nlclaude01):
#   scripts/write-renovate-autonomy-metrics.py  (Cronicle */5)    -> renovate_autonomy_metrics.prom
#   scripts/write-renovate-audit-metrics.sh      (Cronicle weekly) -> renovate_autonomy_audit.prom
# prom:renovate_autonomy_metrics is a CRITICAL registry dead-man
# (scripts/registry-curate.py CRITICAL set) — a stale writer also pages via REDACTED_fc4d47da.
#
# The lane autonomously MERGES Renovate dependency MRs on infrastructure/nl/
# production when every gate passes (CI-green AND review-APPROVE AND verified snapshot),
# gated behind ~/gateway.renovate_autonomy. These alerts guard its safety invariants:
# floor breach, tamper-evident audit chain, and dead-man staleness.
#
# Background: 2026-07-06 go-live + first live POLL (openbao MR !359).
# Memory: claude-gateway memory/renovate_autonomy_golive_first_poll_20260706.md.
# Adopted into IaC 2026-07-07 (was hand-applied via kubectl at go-live).
# =============================================================================

resource "kubernetes_manifest" "REDACTED_34afa039" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_83f021e5"
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
          name = "renovate-autonomy"
          rules = [
            {
              # Floor breach: a live decision=AUTO row exists that bypassed the
              # CI-green AND review-APPROVE AND verified-snapshot floor. Must never happen.
              alert = "REDACTED_ec19a4fa"
              expr  = "renovate_autonomy_merged_without_snapshot_total > 0"
              for   = "0m"
              labels = {
                severity = "critical"
                tier     = "1"
              }
              annotations = {
                summary     = "Renovate autonomy floor breach: a live AUTO-merge bypassed CI/review/snapshot"
                description = "renovate_autonomy_merged_without_snapshot_total={{ $value }}. A live decision=AUTO row exists without CI-green ∧ review-APPROVE ∧ verified-snapshot. Freeze now: rm ~/gateway.renovate_autonomy"
              }
            },
            {
              # Tamper-evidence: a committed audit row was edited/deleted/reordered.
              alert = "REDACTED_f8010289"
              expr  = "renovate_autonomy_chain_ok == 0"
              for   = "0m"
              labels = {
                severity = "critical"
                tier     = "1"
              }
              annotations = {
                summary     = "Renovate autonomy audit hash chain BROKEN (ledger tampered)"
                description = "renovate_autonomy_chain_ok=0 — a committed audit row was edited/deleted/reordered. The tamper-evident ledger no longer verifies; treat the autonomy decision record as compromised."
              }
            },
            {
              # Independent weekly cross-check of the same chain.
              alert = "REDACTED_f8010289Weekly"
              expr  = "renovate_autonomy_chain_broken == 1"
              for   = "0m"
              labels = {
                severity = "critical"
                tier     = "1"
              }
              annotations = {
                summary     = "Renovate autonomy audit hash chain BROKEN (weekly cross-check)"
                description = "The weekly auditor's independent chain verify failed — corroborates a tampered/broken ledger."
              }
            },
            {
              # Weekly floor-invariant auditor found a live AUTO row outside the floor.
              alert = "REDACTED_6278b673"
              expr  = "renovate_autonomy_audit_fail == 1"
              for   = "5m"
              labels = {
                severity = "critical"
                tier     = "1"
              }
              annotations = {
                summary     = "Renovate autonomy weekly invariant auditor FAILED"
                description = "audit-renovate-decisions.sh exited non-zero — a live AUTO row is outside the snapshot/CI/review floor. rm ~/gateway.renovate_autonomy to freeze."
              }
            },
            {
              # Dead-man: the */5 safety-invariant writer stopped or is absent.
              alert = "REDACTED_94d1bde1"
              expr  = "(time() - renovate_autonomy_last_run_timestamp_seconds > 1800) or absent(renovate_autonomy_last_run_timestamp_seconds)"
              for   = "30m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Renovate autonomy metrics writer stale (>30m) or absent"
                description = "prom:renovate_autonomy_metrics has not run in >30m — the safety invariant metric is no longer fresh."
              }
            },
            {
              # The weekly floor-invariant auditor itself stopped running (~8d window).
              alert = "REDACTED_f79de48d"
              expr  = "(time() - renovate_autonomy_audit_last_run_timestamp_seconds > 700000) or absent(renovate_autonomy_audit_last_run_timestamp_seconds)"
              for   = "1h"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Renovate autonomy weekly invariant auditor stale (~8d) or absent"
                description = "The weekly floor-invariant hasn't run — the safety invariant is no longer being checked."
              }
            },
            {
              # Reminder (not a failure): the lane has never been armed for 2 weeks.
              alert = "REDACTED_759c672c"
              expr  = "renovate_autonomy_live_enabled == 0"
              for   = "14d"
              labels = {
                severity = "info"
              }
              annotations = {
                summary     = "Renovate autonomy lane still shadow-only (14d)"
                description = "The lane has run shadow-only for 2 weeks (~/gateway.renovate_autonomy never set). Not a failure — a reminder to make a go-live decision."
              }
            },
            {
              # >50% of MRs stalling on human poll → autonomy isn't paying off.
              alert = "REDACTED_98fffbfa"
              expr  = "sum(increase(renovate_autonomy_decisions_total{decision=\"POLL\"}[24h])) / clamp_min(sum(increase(renovate_autonomy_decisions_total[24h])), 1) > 0.5"
              for   = "6h"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Renovate autonomy: >50% of MRs stalling on human poll (24h)"
                description = "The classifier/gates may be too conservative, or CI/snapshots are failing — autonomy isn't paying off."
              }
            },
          ]
        }
      ]
    }
  }
}
