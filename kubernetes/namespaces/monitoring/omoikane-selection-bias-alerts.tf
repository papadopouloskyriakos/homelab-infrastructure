# =============================================================================
# Omoikane selection-bias drift alerts (OMOIKANE-1115, spec/040 REQ-40046)
#
# The daemon's outcome_sensor bias_metrics_worker computes, daily, how far the
# outcome-consenting sample diverges from the platform-active population
# (Hellinger distance per cohort axis x channel) and exports the result as
# gauges from the daemon /metrics endpoint on both DMZ hosts, alongside the
# operator-tunable tolerance bound:
#
#   omoikane_outcome_sensor_bias_cohort_overrepresentation{cohort_axis,channel}
#   omoikane_outcome_sensor_bias_threshold_pct          (bound, e.g. 25.0)
#   omoikane_outcome_sensor_bias_feature_adoption_rate{channel}
#
# The detection gap this closes: a calibration proposal fit on a sample that
# silently over-represents one cohort would look healthy from every existing
# series — the divergence is only visible in these purpose-built metrics, and
# a metric nobody alerts on is a dashboard, not a control.
#
# MERGE ORDERING (load-bearing): the daemon MR (!3473) must be DEPLOYED before
# this rule lands, or the absent-guard below fires immediately on a series
# that has never existed. Post-merge negative controls (house rule): the
# threshold rule at the real bound must return empty AND at a reachable bound
# (e.g. * 100 > 0.001) must return series; the absent-guard must return empty
# while the daemon is up.
#
# No `tier = "1"` label — Matrix/YT surface only, same posture as the other
# omoikane rules (SMS is operator-curated).
# =============================================================================

resource "kubernetes_manifest" "REDACTED_817fc099" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_36746831-alert-rules"
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
          name     = "REDACTED_36746831"
          interval = "5m"
          rules = [
            {
              # THE rule this file exists for. The gauge is the textbook
              # Hellinger distance in [0,1]; the bound gauge is a percentage
              # (25.0 = 0.25), so the comparison scales by 100. scalar(max())
              # collapses the two-host bound series to one value — a vector
              # match would many-to-many across the HA pair. 24h `for`: the
              # worker ticks daily, and selection bias is a slow structural
              # signal, not an incident.
              alert = "REDACTED_5d59a8f1"
              expr  = "max by (cohort_axis, channel) (omoikane_outcome_sensor_bias_cohort_overrepresentation{cohort_axis!=\"boot\"}) * 100 > scalar(max(omoikane_outcome_sensor_bias_threshold_pct))"
              for   = "24h"
              labels = {
                severity = "warning"
                service  = "omoikane-outcome-sensor"
              }
              annotations = {
                summary     = "Outcome-consent cohort diverges from the platform on {{ $labels.cohort_axis }} for {{ $labels.channel }} (24h over bound)"
                description = "The Hellinger distance between the outcome-consenting sample and the platform-active population exceeds the operator-set tolerance bound for cohort_axis={{ $labels.cohort_axis }}, channel={{ $labels.channel }}. Any calibration fit from this window over-represents some cohorts; the review-page bias panel (REQ-40048) shows which. This is a structural-fairness signal, not an outage — review /admin/methodology/selection-bias before approving outcome-evidence proposals."
              }
            },
            {
              # The watcher needs watching: the worker emits boot sentinels at
              # startup, so on a healthy daemon the adoption series ALWAYS
              # exists. Absent for 6h = the worker (or its registration) is
              # gone, and while that is true the threshold rule above cannot
              # fire — the bias view is dark, which the estate's standing rule
              # says must itself alert.
              alert = "REDACTED_6cd49b26"
              expr  = "absent(omoikane_outcome_sensor_bias_feature_adoption_rate)"
              for   = "6h"
              labels = {
                severity = "warning"
                service  = "omoikane-outcome-sensor"
              }
              annotations = {
                summary     = "Omoikane selection-bias metrics have disappeared (6h)"
                description = "No omoikane_outcome_sensor_bias_feature_adoption_rate series at all — the bias_metrics_worker is not running or its metrics registration was dropped. While this is true, REDACTED_5d59a8f1 cannot fire and cohort divergence is invisible. Check the daemon logs for the worker's guard_pass series."
              }
            },
            {
              # The hole the absent-guard cannot see: the metrics registry
              # keeps exporting a dead worker's LAST values, so if the tokio
              # task dies after its first tick, absent() stays quiet and the
              # threshold rule reads yesterday's gauges as current — a frozen
              # dashboard indistinguishable from a fresh one. The daemon
              # stamps every guard_pass tick into
              # omoikane_worker_last_tick_timestamp_seconds, so staleness IS
              # expressible: > 2 missed daily ticks. Verified live before
              # writing (both hosts export the worker="outcome-sensor-bias-
              # metrics-worker" series).
              alert = "REDACTED_f8e39e1f"
              expr  = "(time() - omoikane_worker_last_tick_timestamp_seconds{worker=\"outcome-sensor-bias-metrics-worker\"}) > 172800"
              for   = "1h"
              labels = {
                severity = "warning"
                service  = "omoikane-outcome-sensor"
              }
              annotations = {
                summary     = "Selection-bias worker on {{ $labels.instance }} has not ticked in 2+ days — gauges are frozen, not fresh"
                description = "The bias_metrics_worker's last guard_pass tick on {{ $labels.instance }} is over two daily intervals old. Its gauges are still exported (the registry keeps last values), so the other two rules in this group see a plausible, frozen picture. Treat the current bias metrics as stale until the worker ticks again; check daemon logs for a died task or a panicking tick (omoikane_worker_panics_total)."
              }
            },
          ]
        },
      ]
    }
  }
}
