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
