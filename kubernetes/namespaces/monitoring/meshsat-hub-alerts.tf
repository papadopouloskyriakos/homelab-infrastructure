# =============================================================================
# MeshSat Hub OUTSIDE-IN probes + alerts (MESHSAT-944, k8s migration phase 5)
#
# NL-ONLY, mirror-exempt (scripts/k8s-mirror-exempt.txt). Applied at cutover:
# before that auth.meshsat.net has no backend and the down-rule would fire.
#
# Two views of the Hub on notrf01cl01k8s:
#   1. Outside-in: the blackbox exporter on nlclaude01 (10.0.X.X:9115,
#      egresses through the NL ASA WAN, which the edge Tier 5a allowlist admits)
#      probes the four public legs through the real path: Cloudflare DNS ->
#      VPS HAProxy -> notrf01 relay -> ingress / NATS / stunnel.
#        https://hub.meshsat.net/healthz          http_2xx
#        https://auth.meshsat.net/-/health/live/  http_2xx (authentik, MeshSat brand)
#        mqtt-hub.meshsat.net:443                 tcp_connect (TLS passthrough to NATS;
#        reticulum.meshsat.net:443                 a TLS handshake needs a bridge client
#                                                  certificate, so TCP reachability is
#                                                  what an outside probe can assert)
#   2. Inside-out: the Hub's own /metrics reach this Prometheus through the
#      notrf01 -> NL remote-write stream (only *_bucket and recording-rule series
#      are dropped): meshsat_hub_dependency_up, meshsat_hub_leader, dbwrap retry
#      counters.
#
# Routing: Alertmanager -> n8n -> Matrix + YouTrack, no tier=1 SMS (same as
# the omoikane public-surface rules). Negative control done at authoring per
# the plan: probe_success is 1 for a live surface and 0 for an unreachable one;
# the absent() guards cover a dead exporter or a filtered stream.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_f4ab4444" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1alpha1"
    kind       = "ScrapeConfig"
    metadata = {
      name      = "meshsat-hub-public"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "release"                   = "monitoring"
      }
    }
    spec = {
      jobName        = "meshsat-hub-public"
      scrapeInterval = "60s"
      scrapeTimeout  = "30s"
      metricsPath    = "/probe"
      params = {
        module = ["http_2xx"]
      }
      staticConfigs = [
        {
          targets = [
            "https://hub.meshsat.net/healthz",
            "https://auth.meshsat.net/-/health/live/",
          ]
          labels = {
            service = "meshsat-hub"
            env     = "production"
            leg     = "https"
          }
        },
      ]
      relabelings = [
        { sourceLabels = ["__address__"], targetLabel = "__param_target" },
        { sourceLabels = ["__param_target"], targetLabel = "instance" },
        { targetLabel = "__address__", replacement = "10.0.X.X:9115" },
      ]
    }
  }
}

resource "kubernetes_manifest" "REDACTED_be56ac24" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1alpha1"
    kind       = "ScrapeConfig"
    metadata = {
      name      = "REDACTED_871b7849"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "release"                   = "monitoring"
      }
    }
    spec = {
      jobName        = "meshsat-hub-public"
      scrapeInterval = "60s"
      scrapeTimeout  = "30s"
      metricsPath    = "/probe"
      # Both legs sit behind mTLS, so a plain tcp_connect cannot prove them (and the
      # exporter's tcp_connect prefers IPv6, which the runner cannot route). The two
      # modules live in the blackbox exporter config on nlclaude01 (2026-09-08):
      #   tls_sni_mqtt_hub    - TLS handshake with SNI (NATS, TLS 1.3, cert expiry visible)
      #   tls_hello_reticulum - raw ClientHello with SNI, expects the ServerHello record
      #                         (stunnel, TLS 1.2, aborts without a client certificate)
      staticConfigs = [
        {
          targets = ["mqtt-hub.meshsat.net:443"]
          labels = {
            service = "meshsat-hub"
            env     = "production"
            leg     = "tcp"
            module  = "tls_sni_mqtt_hub"
          }
        },
        {
          targets = ["reticulum.meshsat.net:443"]
          labels = {
            service = "meshsat-hub"
            env     = "production"
            leg     = "tcp"
            module  = "tls_hello_reticulum"
          }
        },
      ]
      relabelings = [
        { sourceLabels = ["__address__"], targetLabel = "__param_target" },
        { sourceLabels = ["module"], targetLabel = "__param_module" },
        { sourceLabels = ["__param_target"], targetLabel = "instance" },
        { targetLabel = "__address__", replacement = "10.0.X.X:9115" },
      ]
    }
  }
}

resource "kubernetes_manifest" "meshsat_hub_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "meshsat-hub-alert-rules"
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
          name     = "REDACTED_6b1393b4"
          interval = "1m"
          rules = [
            {
              alert = "REDACTED_e644fb3b"
              expr  = "probe_success{job=\"meshsat-hub-public\",env=\"production\"} == 0"
              for   = "5m"
              labels = {
                severity = "critical"
                service  = "meshsat-hub"
              }
              annotations = {
                summary     = "MeshSat Hub public leg {{ $labels.instance }} is unreachable from the outside (5m)"
                description = "The blackbox exporter on nlclaude01 cannot complete the {{ $labels.leg }} probe of {{ $labels.instance }} through the public path (Cloudflare -> VPS HAProxy -> notrf01 relay -> ingress/NATS/stunnel). Check `show stat` on the VPS HAProxy (backends meshsat_hub / meshsat_auth / meshsat_mqtt / meshsat_reticulum), then the notrf01 edge-relay DaemonSet and ingress-nginx, then the Hub pod. No SMS by design (Matrix/YT only)."
              }
            },
            {
              alert = "REDACTED_3f2e0e29"
              expr  = "absent(probe_success{job=\"meshsat-hub-public\"})"
              for   = "10m"
              labels = {
                severity = "critical"
                service  = "meshsat-hub"
              }
              annotations = {
                summary     = "MeshSat Hub public-surface probing has stopped (10m)"
                description = "No probe_success series for job=meshsat-hub-public: the blackbox exporter (nlclaude01:9115) is down or the ScrapeConfig was removed. While this is true REDACTED_e644fb3b cannot fire."
              }
            },
            {
              alert = "REDACTED_34815fef"
              expr  = "min(probe_ssl_earliest_cert_expiry{job=\"meshsat-hub-public\"}) - time() < 14 * 24 * 3600"
              for   = "1h"
              labels = {
                severity = "warning"
                service  = "meshsat-hub"
              }
              annotations = {
                summary     = "*.meshsat.net TLS certificate expires in under 14 days"
                description = "The wildcard served on the public MeshSat Hub surfaces expires in less than 14 days. Renewal is automatic (Let's Encrypt -> NL cert-manager -> OpenBao -> notrf01 ExternalSecret; the edge has its own ACME copy). If this fired, check the cert-manager PushSecret REDACTED_d86e428b and the edge ACME before every leg goes down at once."
              }
            },
          ]
        },
        {
          name     = "REDACTED_e9a9f82e"
          interval = "1m"
          rules = [
            {
              # The database is the Hub's one critical dependency (MR 3 health
              # classes); /readyz already fails on it, this is the alert.
              alert = "REDACTED_6e27676d"
              expr  = "meshsat_hub_dependency_up{dependency=\"db\"} == 0"
              for   = "5m"
              labels = {
                severity = "critical"
                service  = "meshsat-hub"
              }
              annotations = {
                summary     = "MeshSat Hub cannot reach its database (5m)"
                description = "meshsat_hub_dependency_up{dependency=db} has been 0 for 5m on {{ $labels.instance }}. Check the CNPG cluster meshsat-hub-main (kubectl -n meshsat-hub-db get cluster) and the hub-secrets ExternalSecret."
              }
            },
            {
              # Informational dependencies (mqtt, redis, apprise, ntfy, hawkbit,
              # reticulum_identity, leader_election, bridge_ca_export): degraded,
              # not down. Warning after 15m.
              alert = "REDACTED_26c9d062"
              expr  = "meshsat_hub_dependency_up{dependency!=\"db\"} == 0"
              for   = "15m"
              labels = {
                severity = "warning"
                service  = "meshsat-hub"
              }
              annotations = {
                summary     = "MeshSat Hub dependency {{ $labels.dependency }} is down (15m)"
                description = "The Hub keeps serving, but {{ $labels.dependency }} has failed its probe for 15m (see /readyz?verbose=1). mqtt = NATS StatefulSet; redis = Redis StatefulSet; bridge_ca_export = the meshsat-bridge-ca Secret writer (RBAC); leader_election = the Lease."
              }
            },
            {
              # Pollers, reapers and retention run on the leader only (MR 12).
              # No leader for 10m means none of them run.
              alert = "MeshSatHubNoLeader"
              expr  = "max(meshsat_hub_leader) == 0"
              for   = "10m"
              labels = {
                severity = "warning"
                service  = "meshsat-hub"
              }
              annotations = {
                summary     = "No MeshSat Hub replica holds the leader Lease (10m)"
                description = "meshsat_hub_leader is 0 on every replica: the Kubernetes Lease election is failing (RBAC on leases in namespace meshsat-hub, or the API server). Leader-only singletons (OTS poller, credit poller, reapers, audit retention, alert evaluator) are not running."
              }
            },
            {
              # The Incident 20a shape: transient DB errors that never resolve.
              alert = "REDACTED_b07cf696"
              expr  = "increase(meshsat_hub_db_retries_exhausted_total[10m]) > 0"
              for   = "0m"
              labels = {
                severity = "warning"
                service  = "meshsat-hub"
              }
              annotations = {
                summary     = "MeshSat Hub gave up on a database operation after its retry budget"
                description = "meshsat_hub_db_retries_exhausted_total increased in the last 10m (reason {{ $labels.reason }}). A transient error persisted past HUB_DB_RETRY_MAX_ATTEMPTS. Check the CNPG primary (switchover in progress?) and the Hub logs for the operation name."
              }
            },
            {
              # Negative control for the whole inside-out view (plan item 8): if
              # the Hub series stop arriving over remote-write, every rule above
              # goes blind rather than firing.
              alert = "REDACTED_2de24016"
              expr  = "absent(meshsat_hub_dependency_up)"
              for   = "10m"
              labels = {
                severity = "warning"
                service  = "meshsat-hub"
              }
              annotations = {
                summary     = "No MeshSat Hub metrics are arriving (10m)"
                description = "meshsat_hub_dependency_up is absent from this Prometheus. Either the Hub Deployment is scaled to 0, the ServiceMonitor meshsat-hub in the notrf01 monitoring namespace is not scraping (bearer token Secret meshsat-hub-metrics-token), or the notrf01 -> NL remote-write stream is down. While this is true the REDACTED_e9a9f82e rules cannot fire."
              }
            },
          ]
        },
      ]
    }
  }
}

# =============================================================================
# PER-EDGE probes + alerts (IFRNLLEI01PRD-2833, 2026-09-11)
#
# WHY THIS EXISTS, and why the rules above were not enough.
#
# hub/auth/mqtt-hub.meshsat.net each resolve to ALL THREE VPS edges. The probes
# above target the HOSTNAME, so each scrape lands on one edge at random. When
# txhou01vps01 lost its IPsec tunnels to notrf01 on 2026-09-11 05:55, its
# haproxy began silent-dropping every request for those three names
# (`http-request silent-drop if { nbsrv(meshsat_hub) eq 0 }`) — and
# probe_success went to 0 on roughly a third of scrapes and never 0
# continuously, so REDACTED_e644fb3b (for: 5m) could not fire. The
# rule was correct; the target set was the bug.
#
# Cost while it was invisible: a third of all public traffic dropped with no
# HTTP response, a third of Stripe's webhook deliveries lost (confirmed by
# Stripe's own pending_webhooks counter — a customer could cancel and stay on a
# paid plan), and a third of bridge MQTT connections refused. Measured, not
# estimated: 0/6 on the dead edge, 6/6 on each of the others.
#
# So: probe each edge ADDRESS directly, with the SNI and Host header the VPS
# haproxy routes on. The hostname probes above stay — they answer the different
# question "can a real client reach the service at all".
# =============================================================================

locals {
  # The three VPS edges behind every meshsat.net public name.
  meshsat_edges = {
    txhou   = "185.121.169.27"
    notrf01 = "198.51.100.X"
    chzrh   = "198.51.100.X"
  }

  # Modules live in the blackbox exporter config on nlclaude01
  # (docker/nlclaude01/blackbox/config.yml). http_hub_edge and
  # http_auth_edge were added for this; tls_sni_mqtt_hub already pinned the SNI
  # so it works unchanged against an address.
  meshsat_edge_legs = {
    hub        = { module = "http_hub_edge", target = "https://%s/healthz" }
    auth       = { module = "http_auth_edge", target = "https://%s/-/health/live/" }
    "mqtt-hub" = { module = "tls_sni_mqtt_hub", target = "%s:443" }
  }

  meshsat_edge_targets = flatten([
    for edge_name, edge_ip in local.meshsat_edges : [
      for leg_name, leg in local.meshsat_edge_legs : {
        targets = [format(leg.target, edge_ip)]
        labels = {
          service = "meshsat-hub"
          env     = "production"
          edge    = edge_name
          leg     = leg_name
          module  = leg.module
        }
      }
    ]
  ])
}

resource "kubernetes_manifest" "meshsat_edge_scrape" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1alpha1"
    kind       = "ScrapeConfig"
    metadata = {
      name      = "meshsat-edge"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "release"                   = "monitoring"
      }
    }
    spec = {
      jobName        = "meshsat-edge"
      scrapeInterval = "60s"
      scrapeTimeout  = "30s"
      metricsPath    = "/probe"
      staticConfigs  = local.meshsat_edge_targets
      relabelings = [
        { sourceLabels = ["__address__"], targetLabel = "__param_target" },
        { sourceLabels = ["module"], targetLabel = "__param_module" },
        { sourceLabels = ["__param_target"], targetLabel = "instance" },
        { targetLabel = "__address__", replacement = "10.0.X.X:9115" },
      ]
    }
  }
}

resource "kubernetes_manifest" "meshsat_edge_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "meshsat-edge-alert-rules"
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
          name     = "meshsat-edge"
          interval = "1m"
          rules = [
            {
              # tier 1: this is the failure that hid for hours. One dead edge is
              # a third of customers and a third of Stripe's webhooks, and the
              # service looks fine to anyone who happens to resolve elsewhere.
              alert = "MeshSatEdgeDown"
              expr  = "probe_success{job=\"meshsat-edge\"} == 0"
              for   = "5m"
              labels = {
                severity = "critical"
                service  = "meshsat-hub"
                tier     = "1"
              }
              annotations = {
                summary     = "MeshSat edge {{ $labels.edge }} is not serving {{ $labels.leg }} (5m)"
                description = <<-EOT
                  The blackbox exporter cannot complete the {{ $labels.leg }} probe against edge {{ $labels.edge }} ({{ $labels.instance }}) while the other edges may be fine, so the service looks healthy to anyone who resolves elsewhere. A third of clients are being dropped.

                  Most likely cause: that VPS lost its IPsec tunnels to the notrf01 workers, so `nbsrv(meshsat_hub)` is 0 and haproxy silent-drops every request with no HTTP response at all.

                  Check: `swanctl --list-sas | grep no-dmz` on the VPS — expect six ESTABLISHED. If they are missing, `swanctl --initiate --child no-dmz0N`. Since IFRNLLEI01PRD-2833 charon retries a failed initiate every 60s, so a tunnel that is still down after a few minutes is a new fault, not the old one.
                  Then: `nc -z 10.255.{4,5,10}.11 8443` from the VPS, then the notrf01 edge-relay DaemonSet, then ingress-nginx.
                EOT
              }
            },
            {
              # Negative control: while this fires, MeshSatEdgeDown cannot.
              alert = "REDACTED_e80a8dbf"
              expr  = "absent(probe_success{job=\"meshsat-edge\"})"
              for   = "10m"
              labels = {
                severity = "critical"
                service  = "meshsat-hub"
              }
              annotations = {
                summary     = "Per-edge probing of meshsat.net has stopped (10m)"
                description = "No probe_success series for job=meshsat-edge: the blackbox exporter (nlclaude01:9115) is down, its config lost the http_hub_edge/http_auth_edge modules, or the ScrapeConfig was removed. While this is true a single dead edge is invisible again."
              }
            },
          ]
        },
        {
          name     = "meshsat-hub-billing"
          interval = "1m"
          rules = [
            {
              # tier 1: money arrived that belongs to nobody. Every Checkout
              # session the Hub creates carries metadata[tenant_id], so an
              # unattributed payment means either a session the Hub did not
              # build (a payment link, agentic commerce) or a Stripe payload
              # whose shape moved. Both need a person, and the customer has
              # already been charged.
              #
              # kind="payment" is load-bearing, learned the hard way: the first
              # version of this rule matched the counter unlabelled and fired
              # within MINUTES of being deployed -- three times, for zero-amount
              # subscription events belonging to a probe whose tenant row had
              # been deleted while Stripe was still sending trailing events. No
              # money was involved in any of them. A pager that cries wolf on
              # its first day is worse than no pager, so only money pages; the
              # lifecycle case is the warning below.
              alert = "REDACTED_1dec2c7c"
              expr  = "increase(meshsat_hub_payments_unattributed_total{kind=\"payment\"}[15m]) > 0"
              for   = "0m"
              labels = {
                severity = "critical"
                service  = "meshsat-hub"
                tier     = "1"
              }
              annotations = {
                summary     = "MeshSat took a payment it could not attribute to a tenant"
                description = "Money was taken and no tenant owns it, so no receipt and no VAT document will be issued for it. List them at GET /api/admin/payments/unmatched and read the audit entries (action payment_unattributed). Do not leave it: a sent invoice takes a number out of a gapless series, so the document has to be issued deliberately once the tenant is known."
              }
            },
            {
              # No money moved: a subscription event named a tenant this Hub does
              # not know, which usually means a subscription outlived the account
              # it was for. Worth seeing, not worth waking anyone.
              alert = "REDACTED_33e8af56"
              expr  = "increase(meshsat_hub_payments_unattributed_total{kind=\"lifecycle\"}[1h]) > 0"
              for   = "0m"
              labels = {
                severity = "warning"
                service  = "meshsat-hub"
              }
              annotations = {
                summary     = "A Stripe subscription event named a tenant MeshSat does not know"
                description = "A subscription lifecycle event could not be attributed. No money moved, so nobody is owed a document -- but a live subscription may exist in Stripe for an account that no longer does, which will keep billing somebody. Check the audit entries (action payment_unattributed, amount_cents 0) and cancel the subscription in Stripe if the tenant is really gone. Probes that delete a tenant before cancelling in Stripe produce this too."
              }
            },
            {
              alert = "REDACTED_a7c2f4e8"
              expr  = "increase(meshsat_hub_payments_failed_total[1h]) > 0"
              for   = "0m"
              labels = {
                severity = "warning"
                service  = "meshsat-hub"
              }
              annotations = {
                summary     = "MeshSat subscription payments are failing"
                description = "One or more invoices failed to collect in the last hour. This does NOT change anyone's plan by design (past_due and unpaid keep their tier — a failing card is Stripe retrying, not a cancellation). Check the Stripe dashboard for the decline reason; Radar Pro is enabled, so a block may be a false positive worth reviewing."
              }
            },
          ]
        },
      ]
    }
  }
}
