# =============================================================================
# Omoikane Status alert rules (OMOIKANE-1486 / OMOIKANE-1490)
#
# The daemon has emitted these series since OMOIKANE-1486 shipped, but nothing
# scraped it until the omoikane-daemon job was added, and no rule has ever
# referenced them. The 2026-07-25 embedding outage ran roughly twenty hours
# with no alert; the detection half is now real, and this is the part that
# actually tells somebody.
#
# Deliberately conservative. Every rule here fires on a SUSTAINED condition,
# never on a single sample, because the daemon's own severity model already
# requires two consecutive failed probes before it calls a dependency down —
# and a rule that pages on a blip teaches the reader to mute it.
#
# Severity mapping matches the daemon's Article LXXXIII tiers:
#   Alarm       -> critical   (someone must look)
#   Calibration -> warning    (reduced capability, correctly reported)
#   Structural  -> no alert   (a deliberate choice is not a fault)
# =============================================================================

resource "kubernetes_manifest" "REDACTED_84ac6bca" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_b016dfb1"
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
          name     = "REDACTED_15688fad"
          interval = "1m"
          rules = [
            {
              # The customer-facing rollup. This is the one that would have
              # caught 2026-07-25: match scores went to zero for twenty hours.
              # NotDeployed emits no series at all, so `== 0` cannot fire for
              # a capability nobody deployed.
              alert = "REDACTED_cd76c02a"
              expr  = "omoikane_status_capability_up == 0"
              for   = "10m"
              labels = {
                severity = "warning"
                service  = "omoikane-daemon"
              }
              annotations = {
                summary     = "Omoikane capability {{ $labels.capability }} is not fully working on {{ $labels.instance }} (10m)"
                description = "This gauge is 1 only when the capability is fully Up, so it cannot distinguish Degraded from Down — warning, not critical. The site rollup omoikane_status_overall carries the daemon's own severity tiering; REDACTED_1bc9b144 is the page. Open /admin/status for the component breakdown. Runbook: docs/runbooks/embedding-path-dark.md"
              }
            },
            {
              # Site rollup: 0 = red. -1 means nothing measured yet, which is
              # the boot window and deliberately not an alert.
              alert = "REDACTED_1bc9b144"
              expr  = "omoikane_status_overall == 0"
              for   = "10m"
              labels = {
                severity = "critical"
                service  = "omoikane-daemon"
              }
              annotations = {
                summary     = "Omoikane overall status has been RED for 10m on {{ $labels.instance }}"
                description = "At least one essential or capability-critical dependency has been ALARMING (not merely degraded) for 10 minutes. This is the page. omoikane_status_overall is the only series carrying the daemon severity tiers — 2 green, 1 amber, 0 red, -1 not yet measured — so it is the only one that can tell a real outage from correctly-reported reduced capability. The per-subsystem warnings tell you which component."
              }
            },
          ]
        },
        {
          name     = "omoikane-status-subsystems"
          interval = "1m"
          rules = [
            {
              # Precise: the ALARM tier only. omoikane_status_subsystem_state
              # carries the daemon's severity classification (2 nominal, 1
              # calibration, 0 alarm) — the same encoding as
              # omoikane_status_overall — so this cannot fire for a merely
              # degraded dependency.
              #
              # It replaces a rule written against omoikane_status_subsystem_up,
              # which is 1 only when fully Up and therefore could not tell
              # Degraded from Down. That rule paged critical for goal_match_rag
              # while match scores were still working via a fallback and the
              # daemon's own rollup read amber.
              alert = "REDACTED_3d159ed5"
              expr  = "omoikane_status_subsystem_state{criticality=~\"essential|capability_critical\"} == 0"
              for   = "10m"
              labels = {
                severity = "critical"
                service  = "omoikane-daemon"
              }
              annotations = {
                summary     = "Omoikane dependency {{ $labels.subsystem }} is ALARMING on {{ $labels.instance }} (10m)"
                description = "{{ $labels.subsystem }} ({{ $labels.criticality }}, capability {{ $labels.capability }}) has reached the alarm tier — two consecutive failed probes on a dependency whose loss a member would notice. This is a real outage, not reduced capability."
              }
            },
            {
              # The calibration tier: reduced capability, correctly reported.
              # Warning by design — this is the tier the whole severity model
              # exists to keep OFF the pager. It covers both a degraded
              # capability-critical dependency and an enhancing one that is
              # fully down (enhancing can never reach alarm), so it replaces
              # the separate enhancing rule.
              #
              # An hour, because these are quality regressions: tei_rerank was
              # down for months behind a silent RRF-only fallback and nothing
              # said so.
              alert = "REDACTED_40473522"
              expr  = "omoikane_status_subsystem_state == 1"
              for   = "1h"
              labels = {
                severity = "warning"
                service  = "omoikane-daemon"
              }
              annotations = {
                summary     = "Omoikane {{ $labels.subsystem }} degraded for an hour on {{ $labels.instance }}"
                description = "{{ $labels.subsystem }} ({{ $labels.criticality }}) is at the calibration tier: {{ $labels.capability }} still works but is reduced. Silent fallbacks make these easy to miss for months, which is why this alerts at all — and why it is a warning, not a page."
              }
            },
            {
              # Flapping. A subsystem bouncing repeatedly is a distinct
              # failure mode that no `for:` duration can catch, because it is
              # never continuously down long enough to trip one. clamav
              # bounced ~40 times in four hours and no rule could see it.
              alert = "REDACTED_35f8a5d6"
              expr  = "changes(omoikane_status_subsystem_up[1h]) > 6"
              for   = "10m"
              labels = {
                severity = "warning"
                service  = "omoikane-daemon"
              }
              annotations = {
                summary     = "Omoikane {{ $labels.subsystem }} changed state {{ $value }} times in an hour on {{ $labels.instance }}"
                description = "Repeated up/down transitions. A crashlooping container or a probe whose deadline is too tight will look healthy to any duration-based alert."
              }
            },
          ]
        },
        # (omoikane-backups group REMOVED 2026-08-18, OMOIKANE-1623: the
        # omoikane-backup.service/.timer host units were retired with the
        # compose estate — DB backup is CNPG barman + WAL to s3://cnpg-omoikane
        # (ScheduledBackup omoikane-main-daily) plus Velero, each with their
        # own monitoring.)
        {
          name     = "REDACTED_6360e2dd"
          interval = "1m"
          rules = [
            {
              # The watcher needs watching. If the prober stops, every series
              # above goes stale and stops alerting — silently.
              alert = "REDACTED_6c4412c0"
              expr  = "time() - max by (instance) (omoikane_status_refresh_duration_seconds_count > 0) * 0 - max by (instance) (timestamp(omoikane_status_refresh_duration_seconds_count)) > 600"
              for   = "5m"
              labels = {
                severity = "critical"
                service  = "omoikane-daemon"
              }
              annotations = {
                summary     = "Omoikane status prober has not completed a pass in 10m on {{ $labels.instance }}"
                description = "The prober publishes the snapshot that /readyz, the status page and every rule in this file depend on. If it stalls, everything above reports stale data and stops firing."
              }
            },
            {
              # OMOIKANE-1623 (2026-08-18): was `up{job="omoikane-daemon"} == 0`
              # against the retired mesh scrape. The daemon's series now arrive
              # via NO-cluster remote-write, and `up` for a remote-written
              # series does not exist on THIS Prometheus — absence of the
              # stream is the only NL-observable failure. This is the guard
              # that keeps every other omoikane_* rule in this file honest: if
              # remote-write breaks, their exprs silently evaluate over
              # nothing, which is the estate's certified-by-silence defect
              # class. The NO cluster pages for its own scrape failures; the
              # Gatus "Prometheus (NO)" dead-man pages for NO monitoring death.
              alert = "REDACTED_f3ab62b3"
              expr  = "absent(omoikane_status_overall{job=\"daemon\", site=\"no\"})"
              for   = "10m"
              labels = {
                severity = "critical"
                service  = "omoikane-daemon"
              }
              annotations = {
                summary     = "No omoikane daemon series arriving over remote-write"
                description = "NL Prometheus has stopped receiving the daemon's status series from the NO cluster. Either the daemon is down, the NO Prometheus scrape broke, or remote-write NO->NL broke. Check no-prometheus.example.net:8443 targets and the NO remote-write config. While this fires, EVERY other omoikane_* rule on this Prometheus is evaluating over absent data."
              }
            },
          ]
        },
      ]
    }
  }
}
