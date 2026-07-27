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
              alert = "OmoikaneCapabilityDown"
              expr  = "omoikane_status_capability_up == 0"
              for   = "10m"
              labels = {
                severity = "critical"
                service  = "omoikane-daemon"
              }
              annotations = {
                summary     = "Omoikane capability {{ $labels.capability }} has been unavailable for 10m on {{ $labels.instance }}"
                description = "The user-facing capability {{ $labels.capability }} is reporting unavailable. Open /admin/status on the affected host for the component breakdown. Runbook: docs/runbooks/embedding-path-dark.md"
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
                summary     = "Omoikane overall status has been red for 10m on {{ $labels.instance }}"
                description = "At least one essential or capability-critical dependency has been alarming for 10 minutes."
              }
            },
          ]
        },
        {
          name     = "omoikane-status-subsystems"
          interval = "1m"
          rules = [
            {
              # Sustained per-subsystem outage. 15m rather than 5m because the
              # prober needs two passes (~2m) to call something down, and a
              # shared upstream briefly bouncing is not worth a page.
              alert = "OmoikaneSubsystemDown"
              expr  = "omoikane_status_subsystem_up{criticality=~\"essential|capability_critical\"} == 0"
              for   = "15m"
              labels = {
                severity = "critical"
                service  = "omoikane-daemon"
              }
              annotations = {
                summary     = "Omoikane dependency {{ $labels.subsystem }} down 15m on {{ $labels.instance }}"
                description = "{{ $labels.subsystem }} ({{ $labels.criticality }}, capability {{ $labels.capability }}) has been down for 15 minutes."
              }
            },
            {
              # Enhancing dependencies degrade quality, not availability, so
              # they warn rather than page. tei_rerank has been down for 6+
              # hours as of this writing and nothing said so.
              alert = "OmoikaneEnhancingSubsystemDown"
              expr  = "omoikane_status_subsystem_up{criticality=\"enhancing\"} == 0"
              for   = "1h"
              labels = {
                severity = "warning"
                service  = "omoikane-daemon"
              }
              annotations = {
                summary     = "Omoikane {{ $labels.subsystem }} has been down for an hour on {{ $labels.instance }}"
                description = "{{ $labels.subsystem }} is enhancing-only: {{ $labels.capability }} still works but is degraded. Silent fallbacks make these easy to miss for months."
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
        {
          name     = "omoikane-backups"
          interval = "5m"
          rules = [
            {
              # OMOIKANE-1489: omoikane-backup.service failed on both app
              # hosts for three days and nothing said so. The cause was an
              # unreadable restic lock object plus an 81-day-old exclusive
              # lock; both are fixed, but the silence is the part worth
              # alerting on. node_exporter already exports this — the metric
              # was there the whole time, unqueried.
              alert = "REDACTED_20ab386c"
              expr  = "node_systemd_unit_state{name=\"omoikane-backup.service\",state=\"failed\"} == 1"
              for   = "30m"
              labels = {
                severity = "critical"
                service  = "omoikane-backup"
              }
              annotations = {
                summary     = "omoikane-backup.service has been failed for 30m on {{ $labels.instance }}"
                description = "Backups are not running on {{ $labels.instance }}. Check `journalctl -u omoikane-backup.service`. Common cause is a stale restic lock: `restic unlock --remove-all` removes locks by id without reading them, which plain `unlock` cannot do for a corrupt lock object. Note restic can only judge staleness of a lock naming the host it runs on, so a lock held by a dead PID on the OTHER host must be cleared from that host."
              }
            },
            {
              # A timer that stops firing is as bad as a service that fails,
              # and looks like nothing at all.
              alert = "REDACTED_03fe34b7"
              expr  = "node_systemd_unit_state{name=\"omoikane-backup.timer\",state=\"active\"} == 0"
              for   = "1h"
              labels = {
                severity = "warning"
                service  = "omoikane-backup"
              }
              annotations = {
                summary     = "omoikane-backup.timer is not active on {{ $labels.instance }}"
                description = "The daily backup timer is not armed. No failure will ever be reported because nothing will run."
              }
            },
          ]
        },
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
              # Absence of the whole job. `up` is synthesised by Prometheus,
              # so this fires even when the daemon emits nothing at all.
              alert = "REDACTED_857792c8"
              expr  = "up{job=\"omoikane-daemon\"} == 0"
              for   = "10m"
              labels = {
                severity = "critical"
                service  = "omoikane-daemon"
              }
              annotations = {
                summary     = "Prometheus cannot scrape omoikane-daemon on {{ $labels.instance }}"
                description = "Either the daemon is down or /metrics is unreachable. Until 2026-07-27 this job did not exist at all and every daemon alert was dormant."
              }
            },
          ]
        },
      ]
    }
  }
}
