# =============================================================================
# omoikane background-worker panic alerts.
#
# THE FAILURE MODE THIS EXISTS FOR: a supervised worker panics, the supervisor
# catches it and the loop continues, so nothing crashes, no container restarts,
# every dashboard stays green — and the work that tick was supposed to do
# simply never happens. Forever, silently.
#
# This is not hypothetical. Discovered 2026-08-03:
#   omoikane_worker_panics_total{worker="REDACTED_0832fad9"}
#   = 178 on EACH of notrf01dmz01/02 (355 total)
#
# Root cause was a byte-index slice in `clean_scraped_job_text`:
#   byte index 12000 is not a char boundary; it is inside '€'
# i.e. every euro-denominated Dutch posting and every Greek posting was a
# candidate. Fixed in daemon !3342 — but the point of THIS file is that the
# counter had been climbing with nobody watching, because
# `omoikane_worker_panics_total` existed as a metric and had NO RULE against
# it anywhere in this repo. The only visible symptom was postings that quietly
# never got their full text, which is indistinguishable from "that posting had
# no description".
#
# `worker_supervisor::guard_pass` is what makes this survivable AND invisible:
#   crate::metrics::record_worker_panic(worker);
#   tracing::error!(worker, "worker tick PANICKED (caught; loop continues)");
# Catching the panic is correct. Not alerting on it is the gap.
#
# SELECTOR NOTE — the estate-wide trap (the OMOIKANE-1493 lesson): the daemon's
# own application metrics come from the omoikane-daemon scrape job, not from
# node_exporter. A rule written against the wrong job matches nothing and is an
# ABSENT rule, not a quiet one. Deliberately job-agnostic here for that reason:
# the metric name is unique to the daemon, so no job selector is needed and one
# cannot be wrong.
#
# CONFIRMED PRESENT before this file was written (never write a rule against a
# series you have not seen):
#   curl -s 'http://nl-prometheus.example.net/api/v1/query?query=omoikane_worker_panics_total'
#   -> REDACTED_0832fad9 = 178 (x2 series, one per host)
# =============================================================================

resource "kubernetes_manifest" "REDACTED_04da320e" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_fd471647"
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
          name     = "REDACTED_6ab95328"
          interval = "5m"
          rules = [
            {
              # A worker that has started panicking. Rate-based rather than
              # absolute so the 355 already on the counter do not pin this
              # firing forever — what matters is NEW panics.
              alert = "REDACTED_396bb734"
              expr  = "increase(omoikane_worker_panics_total[1h]) > 0"
              for   = "15m"
              labels = {
                severity = "warning"
                category = "omoikane-worker"
              }
              annotations = {
                summary     = "{{ $labels.worker }} panicked {{ $value | printf \"%.0f\" }}x in the last hour on {{ $labels.instance }}"
                description = <<-EOT
                  A background worker tick panicked. `worker_supervisor::guard_pass`
                  caught it and the loop continues, so NOTHING will look broken:
                  the container stays healthy, no restart happens, dashboards stay
                  green. The only consequence is that whatever that tick was
                  supposed to do did not happen.

                  Find the panic site:
                    docker logs --since 1h omoikane-daemon 2>&1 | grep -A2 'PANICKED'
                  The line immediately after names the file:line.

                  Do NOT resolve this by restarting. The counter is cumulative and
                  a restart hides the evidence without fixing the cause.
                EOT
              }
            },
            {
              # Sustained panicking is a different problem from a one-off: it
              # means the worker is failing on ORDINARY input, not an edge case.
              alert = "REDACTED_396bb734Sustained"
              expr  = "increase(omoikane_worker_panics_total[6h]) > 50"
              for   = "30m"
              labels = {
                severity = "critical"
                category = "omoikane-worker"
              }
              annotations = {
                summary     = "{{ $labels.worker }} panicked {{ $value | printf \"%.0f\" }}x in 6h — failing on ordinary input"
                description = <<-EOT
                  Sustained panic volume means the worker is not hitting a rare edge
                  case, it is failing on routine content. The 2026-08-03 instance was
                  a byte-index slice landing inside a '€' character, so every
                  euro-denominated posting tripped it.

                  This worker has effectively been doing NO useful work for as long
                  as the counter has been climbing. Check how far back that goes
                  before assuming it is recent:
                    increase(omoikane_worker_panics_total[7d])
                EOT
              }
            },
          ]
        },
      ]
    }
  }
}
