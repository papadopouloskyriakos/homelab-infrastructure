***REMOVED***
# BGPalerter - BGP Monitoring and Alerting
***REMOVED***
# Monitors AS214304 prefix for hijacks, route leaks, and RPKI issues
# Based on BGPalerter v2.0.1 config format from:
# https://raw.githubusercontent.com/nttgin/BGPalerter/main/config.yml.example
#
# Key v2.x changes applied:
# - configVersion: 2
# - processMonitors with uptimeApi ENABLED (required for /status endpoint)
# - rest section configures host/port for APIs
# - preCacheROAs REMOVED (deprecated in v2.0, was causing OOM)
# - monitorROAS uses channel: roa (not rpki)
# - vrpProvider: rpkiclient (v2.x default)
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
    "config.yml" = yamlencode({
      # =========================================================================
      # CONNECTORS - Data sources
      # =========================================================================
      connectors = [
        {
          file = "connectorRIS"
          name = "ris"
          params = {
            carefulSubscription = true
            url                 = "ws://ris-live.ripe.net/v1/ws/"
            perMessageDeflate   = true
            authorizationHeader = null
            subscription = {
              moreSpecific = true
              type         = "UPDATE"
              host         = null
              socketOptions = {
                includeRaw = false
              }
            }
          }
        }
      ]

      # =========================================================================
      # MONITORS - Alert detection
      # =========================================================================
      monitors = [
        {
          file    = "monitorHijack"
          channel = "hijack"
          name    = "basic-hijack-detection"
          params = {
            thresholdMinPeers = 2
          }
        },
        {
          file    = "monitorNewPrefix"
          channel = "newprefix"
          name    = "prefix-detection"
          params = {
            thresholdMinPeers = 2
          }
        },
        {
          file    = "monitorVisibility"
          channel = "visibility"
          name    = "withdrawal-detection"
          params = {
            thresholdMinPeers           = 10
            notificationIntervalSeconds = 3600
          }
        },
        {
          file    = "monitorAS"
          channel = "misconfiguration"
          name    = "asn-monitor"
          params = {
            skipPrefixMatch   = false
            thresholdMinPeers = 2
          }
        },
        {
          file    = "monitorRPKI"
          channel = "rpki"
          name    = "rpki-monitor"
          params = {
            thresholdMinPeers = 1
            checkUncovered    = true
            checkDisappearing = false
          }
        },
        {
          file    = "monitorPath"
          channel = "path"
          name    = "path-matching"
          params = {
            thresholdMinPeers = 2
          }
        },
        {
          file    = "monitorROAS"
          channel = "roa"
          name    = "rpki-diff"
          params = {
            enableDiffAlerts        = true
            enableExpirationAlerts  = true
            enableExpirationCheckTA = true
            enableDeletedCheckTA    = true
            enableAdvancedRpkiStats = false
            roaExpirationAlertHours = 2
            checkOnlyASns           = true
          }
        },
        {
          file    = "monitorPathNeighbors"
          channel = "path"
          name    = "path-neighbors"
          params = {
            thresholdMinPeers = 2
          }
        }
      ]

      # =========================================================================
      # REPORTS - Alert destinations
      # =========================================================================
      reports = [
        # Syslog reporter - sends alerts to syslog-ng -> Loki
        {
          file     = "reportSyslog"
          channels = ["hijack", "newprefix", "visibility", "path", "misconfiguration", "rpki", "roa"]
          params = {
            host      = "10.0.X.X"
            port      = 514
            transport = "udp"
          }
        },
        {
          file     = "reportFile"
          channels = ["hijack", "newprefix", "visibility", "path", "misconfiguration", "rpki", "roa"]
          params = {
            persistAlertData   = false
            alertDataDirectory = "alertdata/"
          }
        },
        {
          file     = "reportEmail"
          channels = ["hijack", "visibility", "rpki", "roa", "misconfiguration"]
          params = {
            showPaths   = 5
            senderEmail = "BGPalerter@mxmx.email"
            smtp = {
              host      = "10.0.X.X"
              port      = 25
              secure    = false
              ignoreTLS = true
            }
            notifiedEmails = {
              default = ["BGPalerter@mxmx.email"]
            }
          }
        },
        {
          file     = "reportHTTP"
          channels = ["hijack", "visibility", "rpki", "roa", "misconfiguration"]
          params = {
            method         = "post"
            headers        = {}
            isTemplateJSON = true
            showPaths      = 0
            templates = {
              default = "{\"text\": \"BGP Alert: $${channel} - $${summary}\"}"
            }
            hooks = {
              default = "https://matrix.example.net/webhook/d2774582-ca35-4348-ac57-cbf7fd781589"
            }
          }
        }
      ]

      # =========================================================================
      # NOTIFICATION SETTINGS
      # =========================================================================
      notificationIntervalSeconds = 300
      persistStatus               = false

      # =========================================================================
      # REST API SETTINGS - Configures where APIs listen
      # =========================================================================
      rest = {
        host = "0.0.0.0"
        port = 8011
      }

      # =========================================================================
      # PROCESS MONITORS - REQUIRED for /status endpoint!
      # This was commented out by default - must be explicitly enabled
      # =========================================================================
      processMonitors = [
        {
          file = "uptimeApi"
          params = {
            useStatusCodes = true
          }
        }
      ]

      # =========================================================================
      # LOGGING
      # =========================================================================
      logging = {
        directory          = "logs"
        logRotatePattern   = "YYYY-MM-DD"
        maxRetainedFiles   = 10
        maxFileSizeMB      = 15
        compressOnRotation = false
        useUTC             = true
      }

      # =========================================================================
      # RPKI SETTINGS
      # Note: preCacheROAs was REMOVED in v2.0 (was causing OOM issues)
      # =========================================================================
      rpki = {
        vrpProvider                 = "rpkiclient"
        refreshVrpListMinutes       = 15
        markDataAsStaleAfterMinutes = 120
      }

      # =========================================================================
      # OTHER SETTINGS
      # =========================================================================
      checkForUpdatesAtBoot       = false
      generatePrefixListEveryDays = 0

      # =========================================================================
      # ADVANCED SETTINGS
      # =========================================================================
      alertOnlyOnce             = false
      fadeOffSeconds            = 360
      checkFadeOffGroupsSeconds = 30
      pidFile                   = "bgpalerter.pid"
      maxMessagesPerSecond      = 6000
      multiProcess              = false
      environment               = "production"
      configVersion             = 2

      # =========================================================================
      # MONITORED PREFIXES FILES
      # =========================================================================
      monitoredPrefixesFiles = ["prefixes.yml"]
    })

    "prefixes.yml" = yamlencode({
      "2a0c:9a40:8e20::/48" = {
        description         = "Nuclear Lighters primary IPv6 prefix"
        asn                 = 214304
        ignoreMorespecifics = false
        ignore              = false
        group               = "default"
      }

      options = {
        monitorASns = {
          "214304" = {
            group     = "default"
            upstreams = [34927, 56655]
          }
        }
      }
    })
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
              cpu    = "200m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "1536Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/status"
              port = 8011
            }
            initial_delay_seconds = 120
            period_seconds        = 60
            timeout_seconds       = 10
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path = "/status"
              port = 8011
            }
            initial_delay_seconds = 90
            period_seconds        = 30
            timeout_seconds       = 10
            failure_threshold     = 5
          }

          volume_mount {
            name       = "volume"
            mount_path = "REDACTED_729ea3cb"
          }
        }

        volume {
          name = "config-readonly"
          config_map {
            name = REDACTED_9343442e.bgpalerter_config.metadata[0].name
          }
        }

        volume {
          name = "volume"
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
          path     = "/status"
          interval = "60s"
        }
      ]
    }
  }
  depends_on = [kubernetes_service_v1.bgpalerter]
}
