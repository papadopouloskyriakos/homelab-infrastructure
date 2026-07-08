# =============================================================================
# Live IaC working-checkout drift alerts.
#
# Guards against the "stranded on a stale feature branch" class: on 2026-07-08
# the NL IaC live checkout was found parked on a local-only 'agora-dashboard'
# branch 182 commits behind main, so every read/edit hit ~2-week-stale IaC until
# someone noticed. sync-live-iac-checkouts.sh (claude-gateway
# scripts/sync-live-iac-checkouts.sh, cron */daily on nlclaude01) auto-heals
# a CLEAN stranded checkout and emits iac_checkout_* metrics (scraped via job
# chatops-node). These alerts ensure a checkout that DRIFTS and can't be
# auto-healed (dirty / un-pushed commits) never again goes unnoticed for weeks.
#
# Mirror of claude-gateway prometheus/alert-rules/iac-checkout-drift.yml.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_f1402bb5" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_800d2db9"
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
          name     = "iac-checkout-drift"
          interval = "5m"
          rules = [
            {
              # A live IaC checkout has been off its default branch for 6h and
              # the guard could not auto-heal it (uncommitted changes or
              # un-pushed commits block the safe auto-checkout).
              alert = "REDACTED_d6ac37f1"
              expr  = "iac_checkout_on_default_branch == 0"
              for   = "6h"
              labels = {
                severity = "warning"
                category = "iac-hygiene"
              }
              annotations = {
                summary     = "Live IaC checkout {{ $labels.repo }} stranded on branch {{ $labels.branch }}"
                description = "The live IaC working checkout {{ $labels.repo }} on nlclaude01 has been on a non-default branch ({{ $labels.branch }}) for 6h+ and sync-live-iac-checkouts.sh could not auto-heal it (it only auto-switches a CLEAN, no-commits-ahead checkout). Reads/edits of this tree are hitting stale IaC. Commit/stash the work, then let the guard return it to main."
              }
            },
            {
              # Uncommitted changes sitting in a live IaC checkout for 24h.
              alert = "REDACTED_9375ca33"
              expr  = "iac_checkout_dirty > 0"
              for   = "24h"
              labels = {
                severity = "warning"
                category = "iac-hygiene"
              }
              annotations = {
                summary     = "Live IaC checkout {{ $labels.repo }} has uncommitted changes for 24h+"
                description = "{{ $value }} uncommitted file(s) have sat in the live IaC checkout {{ $labels.repo }} for 24h+. Either commit them via an MR or discard/stash so the checkout can track main."
              }
            },
            {
              # The guard cron itself stopped (who-watches-the-watchdog).
              alert = "REDACTED_61565271"
              expr  = "(time() - iac_checkout_sync_last_run_timestamp > 172800) or absent(iac_checkout_sync_last_run_timestamp)"
              for   = "1h"
              labels = {
                severity = "warning"
                category = "iac-hygiene"
              }
              annotations = {
                summary     = "IaC-checkout drift guard has not run in 2+ days"
                description = "sync-live-iac-checkouts.sh (daily cron on nlclaude01) has not emitted iac_checkout_sync_last_run_timestamp in 2+ days (or it is absent) — the drift auto-heal + detection is dark. Check the crontab and the script."
              }
            },
          ]
        },
      ]
    }
  }
}
