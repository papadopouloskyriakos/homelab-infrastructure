# =============================================================================
# Omoikane public-surface OUTSIDE-IN alerts (OMOIKANE-8)
#
# The detection gap this closes: until now every omoikane alert watched an
# INTERNAL series — the daemon's own /metrics, node_exporter, an internal mesh
# IP. If the EDGE or the DMZ ingress broke while the daemon stayed healthy,
# nothing fired: the daemon kept reporting itself green to a Prometheus that
# could still reach it, and no rule looked from the outside.
#
# The `omoikane-public` scrape job (namespaces/monitoring/main.tf) probes the
# real public URLs through the blackbox exporter on nlclaude01, which
# egresses to the internet like a member would — edge -> DMZ -> daemon. These
# rules alert on that probe.
#
# Severity: the production down-rule is `critical` (someone must look) but
# carries NO `tier = "1"` label, so it deliberately does NOT reach the Twilio
# SMS surface (operator-curated at 12, 2026-08-01) — it routes via
# Alertmanager -> n8n -> Matrix + YouTrack like every other omoikane rule.
# Staging is a warning; a broken beta site is not a page.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_2b86794b" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_40e7121b-alert-rules"
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
          name     = "REDACTED_40e7121b"
          interval = "1m"
          rules = [
            {
              # THE rule this file exists for. probe_success is 0 when the
              # blackbox exporter cannot complete an http_2xx probe of the
              # public URL — a broken edge, a broken DMZ ingress, an expired
              # cert, or a down daemon all trip it, none of which the
              # internal-only rules can see. 5m so a single scrape blip or a
              # deploy restart does not page. Negative-controlled at authoring:
              # a live surface returns 1, an unreachable one returns 0.
              alert = "REDACTED_ab4c05b6"
              expr  = "probe_success{job=\"omoikane-public\",env=\"production\"} == 0"
              for   = "5m"
              labels = {
                severity = "critical"
                service  = "omoikane-public"
              }
              annotations = {
                summary     = "Omoikane public surface {{ $labels.instance }} is unreachable from the outside (5m)"
                description = "The blackbox exporter on nlclaude01 cannot complete an http_2xx probe of {{ $labels.instance }} through the public path. This looks from OUTSIDE the mesh, so unlike the internal daemon rules it fires on an edge/DMZ/cert failure even while the daemon reports itself healthy. Check the edge HAProxy and the DMZ ingress first, then the daemon. No SMS by design (Matrix/YT only)."
              }
            },
            {
              # The watcher needs watching. If the scrape job or the blackbox
              # exporter dies, probe_success goes ABSENT (not 0), and the
              # down-rule above — which matches on `== 0` — cannot fire. This
              # is the "a check that cannot express the failure certifies it"
              # guard: absent() fires precisely when the primary rule is blind.
              alert = "REDACTED_b131ba18"
              expr  = "absent(probe_success{job=\"omoikane-public\"})"
              for   = "10m"
              labels = {
                severity = "critical"
                service  = "omoikane-public"
              }
              annotations = {
                summary     = "Omoikane public-surface probing has stopped (10m)"
                description = "No probe_success series for job=omoikane-public. Either the blackbox exporter (nlclaude01:9115) is down or the scrape job was removed. While this is true, REDACTED_ab4c05b6 cannot fire — the outside-in view is dark and an edge outage would be silent."
              }
            },
            {
              # Reduced capability, not an outage: the public path answers but
              # slowly. Warning, and an hour, because a slow page is a quality
              # regression, not a page-someone event. probe_duration_seconds is
              # the full DNS+connect+TLS+transfer time; live baseline ~0.13s, so
              # 5s sustained is genuinely wrong, not jitter.
              alert = "REDACTED_d006aecd"
              expr  = "probe_duration_seconds{job=\"omoikane-public\",env=\"production\"} > 5"
              for   = "1h"
              labels = {
                severity = "warning"
                service  = "omoikane-public"
              }
              annotations = {
                summary     = "Omoikane public surface {{ $labels.instance }} is slow (>5s for 1h)"
                description = "Outside-in response time for {{ $labels.instance }} has stayed above 5s for an hour (baseline ~0.13s). The surface is up but degraded — edge, DMZ, or daemon latency. Not a page."
              }
            },
            {
              # The edge terminates TLS with the *.omoikane.coach wildcard;
              # every probed host shares it, so this fires once, ~14 days out.
              # Warning: renewal is automated (cert-manager / edge ACME), this
              # is the backstop for when it silently is not.
              alert = "REDACTED_37a9274c"
              expr  = "min(probe_ssl_earliest_cert_expiry{job=\"omoikane-public\"}) - time() < 14 * 24 * 3600"
              for   = "1h"
              labels = {
                severity = "warning"
                service  = "omoikane-public"
              }
              annotations = {
                summary     = "Omoikane public TLS cert expires in under 14 days"
                description = "The TLS certificate served on the omoikane public surfaces expires in less than 14 days. Renewal should be automatic; if this fired, check the edge ACME / cert-manager path before it becomes an REDACTED_ab4c05b6 for every surface at once."
              }
            },
          ]
        },
        {
          name     = "REDACTED_40e7121b-staging"
          interval = "1m"
          rules = [
            {
              # Staging (beta) — a warning, never a page. 15m because a staging
              # deploy legitimately takes it down and nobody needs telling at
              # 03:00.
              alert = "REDACTED_ac919bcb"
              expr  = "probe_success{job=\"omoikane-public\",env=\"staging\"} == 0"
              for   = "15m"
              labels = {
                severity = "warning"
                service  = "omoikane-public"
              }
              annotations = {
                summary     = "Omoikane staging surface {{ $labels.instance }} is unreachable (15m)"
                description = "beta.omoikane.coach has failed its outside-in probe for 15m. Staging, so a warning — often just a deploy in flight. Only worth a look if it stays down."
              }
            },
          ]
        },
      ]
    }
  }
}
