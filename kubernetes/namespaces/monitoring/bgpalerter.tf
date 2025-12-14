***REMOVED***
# BGPalerter - BGP Monitoring and Alerting
***REMOVED***
# Monitors AS214304 prefix for hijacks, route leaks, and RPKI issues
# Alerts via Email and Matrix webhook
# Logs to Loki via Promtail for Grafana dashboard
***REMOVED***

# -----------------------------------------------------------------------------
# ConfigMap - BGPalerter Configuration
# -----------------------------------------------------------------------------
resource "REDACTED_9343442e" "bgpalerter_config" {
  metadata {
    name      = "bgpalerter-config"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"       = "bgpalerter"
      "app.kubernetes.io/component"  = "config"
      "app.kubernetes.io/managed-by" = "opentofu"
    }
  }

  data = {
    "config.yml" = <<-EOT
      ***REMOVED***
      # BGPalerter Configuration
      ***REMOVED***
      # Documentation: https://github.com/nttgin/BGPalerter/blob/main/docs/configuration.md
      ***REMOVED***

      # -----------------------------------------------------------------------------
      # Logging Configuration
      # -----------------------------------------------------------------------------
      logging:
        # Log level: debug, info, warn, error
        level: info
        # Output format: json for Loki parsing
        format: json

      # -----------------------------------------------------------------------------
      # HTTP API (for status endpoint)
      # -----------------------------------------------------------------------------
      rest:
        host: 0.0.0.0
        port: 8011

      # -----------------------------------------------------------------------------
      # Report Channels (Alerting)
      # -----------------------------------------------------------------------------
      reports:
        # File output (also captured by Promtail via stdout)
        - file:
            logFile: /tmp/bgpalerter.log
            # Also output to stdout for Promtail
            channels:
              - hijack
              - newprefix
              - visibility
              - rpki
              - path
              - misconfiguration
              - heartbeat
              - withdrawal

        # Email notifications
        - email:
            showPaths: 5
            senderEmail: BGPalerter@mxmx.email
            # SMTP without auth/TLS
            smtp:
              host: 10.0.X.X
              port: 25
              secure: false
              ignoreTLS: true
            notifiedEmails:
              default:
                - BGPalerter@mxmx.email
            channels:
              - hijack
              - visibility
              - rpki
              - misconfiguration

        # Matrix webhook (generic HTTP hook)
        - webHook:
            name: matrix
            url: https://matrix.example.net/webhook/d2774582-ca35-4348-ac57-cbf7fd781589
            method: POST
            headers:
              Content-Type: application/json
            templates:
              default: |
                {
                  "text": "BGP Alert: $${type} - $${message}",
                  "prefix": "$${prefix}",
                  "type": "$${type}",
                  "timestamp": "$${timestamp}"
                }
            channels:
              - hijack
              - visibility
              - rpki
              - misconfiguration

      # -----------------------------------------------------------------------------
      # Monitors Configuration
      # -----------------------------------------------------------------------------
      monitors:
        # Detect BGP hijacks (most critical)
        monitorHijack:
          enabled: true
          # Alert on exact prefix match hijacks
          thresholdMinPeers: 2

        # Detect new sub-prefix announcements (potential hijack indicator)
        monitorNewPrefix:
          enabled: true
          # Alert when new more-specific is seen
          thresholdMinPeers: 2

        # Monitor prefix visibility
        monitorVisibility:
          enabled: true
          # Alert if seen by fewer than this many peers
          thresholdMinPeers: 10

        # Monitor RPKI validation status
        monitorRPKI:
          enabled: true
          # Alert on invalid RPKI status
          checkUncovered: true

        # Monitor AS path changes (informational)
        monitorPath:
          enabled: true
          # Alert when AS path changes significantly
          thresholdMinPeers: 2

        # Monitor for common misconfigurations
        monitorAS:
          enabled: true

        # Heartbeat for proof of life
        monitorHeartbeat:
          enabled: true
          # Heartbeat every hour
          intervalSeconds: 3600

      # -----------------------------------------------------------------------------
      # Connectors (Data Sources)
      # -----------------------------------------------------------------------------
      connectors:
        # RIPE RIS Live streaming (primary)
        - connectorRIS:
            url: wss://ris-live.ripe.net/v1/ws/
            subscription:
              type: UPDATE
            # Filter to our prefix for efficiency
            perMessageDeflate: true

        # RouteViews (backup, uses archived data)
        # Disabled by default, enable if RIS has issues
        # - connectorRouteViews:
        #     enabled: false

      # -----------------------------------------------------------------------------
      # Processing Options
      # -----------------------------------------------------------------------------
      processMonitors:
        # How long to wait before alerting (avoids flapping alerts)
        notificationIntervalSeconds: 300
        # Store state in memory (no persistence needed)
        persistStatus: false
    EOT

    "prefixes.yml" = <<-EOT
      ***REMOVED***
      # Monitored Prefixes Configuration
      ***REMOVED***
      # Your ASN and prefix allocations
      ***REMOVED***

      # AS214304 - Nuclear Lighters Network
      214304:
        # IPv6 prefix from iFog
        - prefix: "2a0c:9a40:8e20::/48"
          description: "Nuclear Lighters primary IPv6 prefix"
          # Don't alert on more specifics you might announce
          ignoreMorespecifics: false
          # Monitor all visibility from this prefix
          monitorVisibility: true
          # Monitor RPKI status
          monitorRPKI: true
          # Monitor AS path changes
          monitorPath: true
          # Expected upstream ASNs (for path monitoring)
          expectedUpstreams:
            - 34927   # iFog GmbH
            - 56655   # Terrahost/Gigahost
    EOT
  }
}

# -----------------------------------------------------------------------------
# Deployment - BGPalerter
# -----------------------------------------------------------------------------
resource "REDACTED_08d34ae1" "bgpalerter" {
  metadata {
    name      = "bgpalerter"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"       = "bgpalerter"
      "app.kubernetes.io/component"  = "monitor"
      "app.kubernetes.io/managed-by" = "opentofu"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "bgpalerter"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"      = "bgpalerter"
          "app.kubernetes.io/component" = "monitor"
        }
        annotations = {
          # Trigger redeploy on config changes
          "checksum/config" = sha256(REDACTED_9343442e.bgpalerter_config.data["config.yml"])
        }
      }

      spec {
        # Run on NL nodes only
        node_selector = {
          "topology.kubernetes.io/region" = "nl-lei"
        }

        container {
          name  = "bgpalerter"
          image = "nttgin/bgpalerter:latest"

          port {
            name           = "http"
            container_port = 8011
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
          }

          # Health checks
          liveness_probe {
            http_get {
              path = "/status"
              port = 8011
            }
            initial_delay_seconds = 30
            period_seconds        = 60
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/status"
              port = 8011
            }
            initial_delay_seconds = 10
            period_seconds        = 30
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          # Mount config files
          volume_mount {
            name       = "config"
            mount_path = "/opt/bgpalerter"
            read_only  = true
          }

          # Temp directory for log file
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }

        volume {
          name = "config"
          config_map {
            name = REDACTED_9343442e.bgpalerter_config.metadata[0].name
          }
        }

        volume {
          name = "tmp"
          empty_dir {}
        }

        restart_policy                   = "Always"
        termination_grace_period_seconds = 30
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Service - Internal access to status API
# -----------------------------------------------------------------------------
resource "kubernetes_service_v1" "bgpalerter" {
  metadata {
    name      = "bgpalerter"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"       = "bgpalerter"
      "app.kubernetes.io/component"  = "service"
      "app.kubernetes.io/managed-by" = "opentofu"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "bgpalerter"
    }

    port {
      name        = "http"
      port        = 8011
      target_port = 8011
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# -----------------------------------------------------------------------------
# ServiceMonitor - Prometheus metrics (optional, BGPalerter has basic metrics)
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_6b288666" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "bgpalerter"
      namespace = "monitoring"
      labels = {
        "release"     = "monitoring"
        "environment" = "production"
        "managed-by"  = "opentofu"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "bgpalerter"
        }
      }
      endpoints = [
        {
          port     = "http"
          path     = "/metrics"
          interval = "60s"
        }
      ]
    }
  }
  depends_on = [kubernetes_service_v1.bgpalerter]
}
