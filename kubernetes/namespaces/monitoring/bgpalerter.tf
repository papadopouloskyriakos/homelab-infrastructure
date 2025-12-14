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
        level: info
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
        - file:
            logFile: /tmp/bgpalerter.log
            channels:
              - hijack
              - newprefix
              - visibility
              - rpki
              - path
              - misconfiguration
              - heartbeat
              - withdrawal

        - email:
            showPaths: 5
            senderEmail: BGPalerter@mxmx.email
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
        monitorHijack:
          enabled: true
          thresholdMinPeers: 2

        monitorNewPrefix:
          enabled: true
          thresholdMinPeers: 2

        monitorVisibility:
          enabled: true
          thresholdMinPeers: 10

        monitorRPKI:
          enabled: true
          checkUncovered: true

        monitorPath:
          enabled: true
          thresholdMinPeers: 2

        monitorAS:
          enabled: true

        monitorHeartbeat:
          enabled: true
          intervalSeconds: 3600

      # -----------------------------------------------------------------------------
      # Connectors (Data Sources)
      # -----------------------------------------------------------------------------
      connectors:
        - connectorRIS:
            url: wss://ris-live.ripe.net/v1/ws/
            subscription:
              type: UPDATE
            perMessageDeflate: true

      # -----------------------------------------------------------------------------
      # Processing Options
      # -----------------------------------------------------------------------------
      processMonitors:
        notificationIntervalSeconds: 300
        persistStatus: false
    EOT

    "prefixes.yml" = <<-EOT
      # AS214304 - Nuclear Lighters Network
      214304:
        - prefix: "2a0c:9a40:8e20::/48"
          description: "Nuclear Lighters primary IPv6 prefix"
          ignoreMorespecifics: false
          monitorVisibility: true
          monitorRPKI: true
          monitorPath: true
          expectedUpstreams:
            - 34927
            - 56655
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
          "checksum/config" = sha256(REDACTED_9343442e.bgpalerter_config.data["config.yml"])
        }
      }

      spec {
        node_selector = {
          "topology.kubernetes.io/region" = "nl-lei"
        }

        # Init container copies config files to writable volume
        init_container {
          name  = "copy-config"
          image = "busybox:1.36"
          command = [
            "sh", "-c",
            "cp /config-readonly/* REDACTED_729ea3cb/"
          ]

          volume_mount {
            name       = "config-readonly"
            mount_path = "/config-readonly"
            read_only  = true
          }

          volume_mount {
            name       = "volume"
            mount_path = "REDACTED_729ea3cb"
          }
        }

        container {
          name  = "bgpalerter"
          image = "nttgin/bgpalerter:latest"

          command = ["npm"]
          args    = ["run", "serve", "--", "--d", "REDACTED_729ea3cb/"]

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

          # Writable volume for config + runtime data
          volume_mount {
            name       = "volume"
            mount_path = "REDACTED_729ea3cb"
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }

        # ConfigMap (read-only source)
        volume {
          name = "config-readonly"
          config_map {
            name = REDACTED_9343442e.bgpalerter_config.metadata[0].name
          }
        }

        # Writable emptyDir for BGPalerter runtime
        volume {
          name = "volume"
          empty_dir {}
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
# ServiceMonitor - Prometheus metrics
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
