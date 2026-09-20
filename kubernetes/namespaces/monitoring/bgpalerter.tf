# =============================================================================
# BGPalerter - BGP Monitoring and Alerting
# =============================================================================
# Monitors AS214304 prefix for hijacks, route leaks, and RPKI issues
# Based on BGPalerter v2.0.1 config format from:
# https://raw.githubusercontent.com/nttgin/BGPalerter/main/config.yml.example
#
# IMPORTANT: Using heredoc YAML instead of yamlencode() because yamlencode()
# doesn't guarantee key ordering, which was causing 'channels' to be incorrectly
# associated with wrong reporters. This broke reportSyslog and reportEmail.
# =============================================================================

# -----------------------------------------------------------------------------
# ConfigMap - BGPalerter Configuration
# -----------------------------------------------------------------------------
resource "REDACTED_a9df2e77_v1" "bgpalerter_config" {
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
    # Using heredoc to ensure proper YAML structure
    # The $${} escaping is for Terraform - BGPalerter receives ${channel}, ${summary}, etc.
    "config.yml" = <<-YAML
connectors:
  - file: connectorRIS
    name: ris
    params:
      carefulSubscription: true
      url: ws://ris-live.ripe.net/v1/ws/
      perMessageDeflate: true
      authorizationHeader: null
      subscription:
        moreSpecific: true
        type: UPDATE
        host: null
        socketOptions:
          includeRaw: false

monitors:
  - file: monitorHijack
    channel: hijack
    name: basic-hijack-detection
    params:
      thresholdMinPeers: 2

  - file: monitorNewPrefix
    channel: newprefix
    name: prefix-detection
    params:
      thresholdMinPeers: 2

  - file: monitorVisibility
    channel: visibility
    name: withdrawal-detection
    params:
      thresholdMinPeers: 10
      notificationIntervalSeconds: 3600

  - file: monitorAS
    channel: misconfiguration
    name: asn-monitor
    params:
      skipPrefixMatch: false
      thresholdMinPeers: 2

  - file: monitorRPKI
    channel: rpki
    name: rpki-monitor
    params:
      thresholdMinPeers: 1
      checkUncovered: true
      checkDisappearing: false

  - file: monitorPath
    channel: path
    name: path-matching
    params:
      thresholdMinPeers: 2

  - file: monitorROAS
    channel: roa
    name: rpki-diff
    params:
      enableDiffAlerts: true
      enableExpirationAlerts: true
      enableExpirationCheckTA: true
      enableDeletedCheckTA: true
      enableAdvancedRpkiStats: false
      roaExpirationAlertHours: 2
      checkOnlyASns: true

  - file: monitorPathNeighbors
    channel: path
    name: path-neighbors
    params:
      thresholdMinPeers: 2

reports:
  # Syslog reporter - sends alerts to syslog-ng -> Loki
  # transport MUST stay udp. With tcp, syslog-client arms a 10s idle timeout on the
  # socket and emits "error"; BGPalerter 2.0.1's reportSyslog.js binds that handler
  # with `function` instead of an arrow, so `this.logger` is undefined and the
  # uncaught TypeError exits the process ~10s after EVERY alert it sends. On
  # 2026-09-19 that crash-looped bgpalerter on all three clusters for 2h20m
  # (54 alert mails; 28 restarts NL, 27 NO). Do not "restore tcp for reliability":
  # tcp delivers the first message and then kills the alerter.
  - file: reportSyslog
    channels:
      - hijack
      - newprefix
      - visibility
      - path
      - misconfiguration
      - rpki
      - roa
    params:
      host: 10.0.X.X
      port: 514
      transport: udp
      templates:
        default: "$${channel}: $${summary}"

  # File reporter - local logs
  - file: reportFile
    channels:
      - hijack
      - newprefix
      - visibility
      - path
      - misconfiguration
      - rpki
      - roa
    params:
      persistAlertData: false
      alertDataDirectory: alertdata/

  # Email reporter
  - file: reportEmail
    channels:
      - hijack
      - visibility
      - rpki
      - roa
      - misconfiguration
    params:
      showPaths: 5
      senderEmail: BGPalerter@mail.example.net
      smtp:
        host: 10.0.X.X
        port: 25
        secure: false
        ignoreTLS: true
      notifiedEmails:
        default:
          - BGPalerter@mail.example.net

  # HTTP/Webhook reporter - Matrix
  - file: reportHTTP
    channels:
      - hijack
      - visibility
      - rpki
      - roa
      - misconfiguration
    params:
      method: post
      headers: {}
      isTemplateJSON: true
      showPaths: 0
      templates:
        default: '{"text": "BGP Alert: $${channel} - $${summary}"}'
      hooks:
        default: https://matrix.example.net/webhook/d2774582-ca35-4348-ac57-cbf7fd781589

notificationIntervalSeconds: 300
persistStatus: false

rest:
  host: 0.0.0.0
  port: 8011

processMonitors:
  - file: uptimeApi
    params:
      useStatusCodes: true

logging:
  directory: logs
  logRotatePattern: YYYY-MM-DD
  maxRetainedFiles: 10
  maxFileSizeMB: 15
  compressOnRotation: false
  useUTC: true

rpki:
  vrpProvider: rpkiclient
  refreshVrpListMinutes: 15
  markDataAsStaleAfterMinutes: 120

checkForUpdatesAtBoot: false
generatePrefixListEveryDays: 0

alertOnlyOnce: false
fadeOffSeconds: 360
checkFadeOffGroupsSeconds: 30
pidFile: bgpalerter.pid
maxMessagesPerSecond: 6000
multiProcess: false
environment: production
configVersion: 2

monitoredPrefixesFiles:
  - prefixes.yml
YAML

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
    # BGPalerter is an ESTATE-WIDE subsystem, not a cluster-local one. All three
    # clusters run byte-identical config, watch the SAME single prefix
    # (2a0c:9a40:8e20::/48, AS214304) via the SAME global RIS Live feed, and mail
    # the SAME address, so extra copies add no detection coverage and simply
    # multiply every notification. On 2026-09-19 one upstream event produced 54
    # mails from three crash-looping copies. This is the same single-site rule
    # that keeps estate_scrape_enabled true on exactly one Prometheus.
    # Gated on replicas rather than count so the objects stay in state and
    # re-enabling a site is a one-word tfvars flip with no state moves.
    replicas = var.bgpalerter_enabled ? 1 : 0

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
          "checksum/config" = sha256(REDACTED_a9df2e77_v1.bgpalerter_config.data["config.yml"])
        }
      }

      spec {
        node_selector = {
          "topology.kubernetes.io/region" = var.node_region
        }

        # Init container copies config files to writable volume
        init_container {
          name  = "copy-config"
          image = "busybox:1.38"
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
          name = "bgpalerter"
          # Pinned by DIGEST. Two things to know before changing this line:
          #   - This repo forbids mutable :latest tags, and this was :latest
          #     until 2026-09-20, so the running image could change under us
          #     with no commit and no plan.
          #   - The v2.0.1 TAG is NOT this image. Both were pushed 2025-08-07
          #     but they are different builds: tag v2.0.1 is
          #     sha256:c65a1942... (92,952,686 B), this one is 92,984,792 B.
          #     "Tidying" this to nttgin/bgpalerter:v2.0.1 would silently swap
          #     the running image for one nobody has run here.
          # App version is 2.0.1 (the container logs `bgpalerter@2.0.1 serve`).
          # To move: pull the candidate, confirm it starts and still alerts,
          # then replace the digest here.
          image = "nttgin/bgpalerter@sha256:7716926952c431baf851d9923a5273e42f32c21aa248da1d6a35158d37d1b894"

          command = ["npm"]
          args    = ["run", "serve", "--", "--d", "REDACTED_729ea3cb/"]

          port {
            name           = "http"
            container_port = 8011
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu = "200m"
              # 512Mi -> 1536Mi 2026-07-31 (OMOIKANE-1547): bgpalerter holds the RIS routing state
              # in RAM permanently — steady ~1.1Gi, 14d peak 1.40Gi (GR peaks 1.48Gi). At 512Mi it
              # was a chronic co-tenant crowder in the node02/03 kernel-OOM incident.
              memory = "1536Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "2048Mi"
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
            name = REDACTED_a9df2e77_v1.bgpalerter_config.metadata[0].name
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

# ServiceMonitor removed (2026-03-25): bgpalerter does not expose /metrics.
# Its /status endpoint returns JSON (not Prometheus exposition format), causing
# TargetDown alert (IFRNLLEI01PRD-251). bgpalerter is an alert-push tool,
# not a metrics source — no ServiceMonitor needed.
