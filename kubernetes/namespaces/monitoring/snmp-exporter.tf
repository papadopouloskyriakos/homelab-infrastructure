# =============================================================================
# SNMP Exporter - Cisco ASA Monitoring
# =============================================================================
# Scrapes BGP and IPsec metrics from the LOCAL site's ASA firewall via SNMP v2c
# Target: var.snmp_asa_target / var.snmp_asa_device (each cluster scrapes only
# its own ASA — NL: 10.0.X.X/nlfw01, GR: 10.0.X.X/grfw01)
#
# Every resource here is gated on var.asa_snmp_enabled (count) — a site
# without an ASA deploys none of it (the matching snmp-asa scrape job in
# main.tf is gated on the same var). moved{} blocks map the historical
# unindexed state addresses onto [0].
# =============================================================================

# -----------------------------------------------------------------------------
# ConfigMap - SNMP Exporter Configuration for Cisco ASA
# -----------------------------------------------------------------------------
moved {
  from = REDACTED_a9df2e77_v1.REDACTED_2b0aa899
  to   = REDACTED_a9df2e77_v1.REDACTED_2b0aa899[0]
}

resource "REDACTED_a9df2e77_v1" "REDACTED_2b0aa899" {
  count = var.asa_snmp_enabled ? 1 : 0

  metadata {
    name      = "REDACTED_c70333e5"
    namespace = "monitoring"
    labels = merge(var.common_labels, {
      "app.kubernetes.io/name"      = "snmp-exporter"
      "app.kubernetes.io/component" = "config"
    })
  }

  data = {
    "snmp.yml" = <<-EOT
auths:
  asa_v2:
    community: ${var.snmp_community}
    version: 2
  syno_v2:
    community: '${var.snmp_syno_community}'
    version: 2

modules:
  cisco_asa:
    walk:
      - 1.3.6.1.2.1.1                    # system
      - 1.3.6.1.2.1.15.3                 # bgpPeerTable
      - 1.3.6.1.4.1.9.9.171.1.3.2        # cipSecTunnelTable (CISCO-IPSEC-FLOW-MONITOR-MIB)
      - 1.3.6.1.4.1.9.9.171.1.2.3        # cikePhase1GWStatsTable
    metrics:
      - name: sysUpTime
        oid: 1.3.6.1.2.1.1.3.0
        type: gauge
        help: System uptime in hundredths of a second

      - name: bgpPeerState
        oid: 1.3.6.1.2.1.15.3.1.2
        type: gauge
        help: BGP peer state (6=established)
        indexes:
          - labelname: bgpPeerRemoteAddr
            type: InetAddress

      - name: bgpPeerRemoteAs
        oid: 1.3.6.1.2.1.15.3.1.9
        type: gauge
        help: BGP peer remote AS
        indexes:
          - labelname: bgpPeerRemoteAddr
            type: InetAddress

      - name: bgpPeerInUpdates
        oid: 1.3.6.1.2.1.15.3.1.10
        type: counter
        help: BGP updates received
        indexes:
          - labelname: bgpPeerRemoteAddr
            type: InetAddress

      - name: bgpPeerOutUpdates
        oid: 1.3.6.1.2.1.15.3.1.11
        type: counter
        help: BGP updates sent
        indexes:
          - labelname: bgpPeerRemoteAddr
            type: InetAddress

      - name: bgpPeerFsmEstablishedTime
        oid: 1.3.6.1.2.1.15.3.1.16
        type: gauge
        help: Seconds since BGP session established
        indexes:
          - labelname: bgpPeerRemoteAddr
            type: InetAddress

      # IPsec Tunnel Metrics (CISCO-IPSEC-FLOW-MONITOR-MIB)
      - name: cipSecTunStatus
        oid: 1.3.6.1.4.1.9.9.171.1.3.2.1.3
        type: gauge
        help: IPsec tunnel status (1=active, 2=destroy)
        indexes:
          - labelname: cipSecTunIndex
            type: Integer

      - name: cipSecTunLocalAddr
        oid: 1.3.6.1.4.1.9.9.171.1.3.2.1.4
        type: InetAddress
        help: IPsec tunnel local address
        indexes:
          - labelname: cipSecTunIndex
            type: Integer

      - name: cipSecTunRemoteAddr
        oid: 1.3.6.1.4.1.9.9.171.1.3.2.1.5
        type: InetAddress
        help: IPsec tunnel remote address
        indexes:
          - labelname: cipSecTunIndex
            type: Integer

      - name: cipSecTunInOctets
        oid: 1.3.6.1.4.1.9.9.171.1.3.2.1.26
        type: counter
        help: IPsec tunnel inbound bytes
        indexes:
          - labelname: cipSecTunIndex
            type: Integer

      - name: cipSecTunOutOctets
        oid: 1.3.6.1.4.1.9.9.171.1.3.2.1.39
        type: counter
        help: IPsec tunnel outbound bytes
        indexes:
          - labelname: cipSecTunIndex
            type: Integer

      - name: cipSecTunInPkts
        oid: 1.3.6.1.4.1.9.9.171.1.3.2.1.27
        type: counter
        help: IPsec tunnel inbound packets
        indexes:
          - labelname: cipSecTunIndex
            type: Integer

      - name: cipSecTunOutPkts
        oid: 1.3.6.1.4.1.9.9.171.1.3.2.1.40
        type: counter
        help: IPsec tunnel outbound packets
        indexes:
          - labelname: cipSecTunIndex
            type: Integer

      - name: cipSecTunActiveTime
        oid: 1.3.6.1.4.1.9.9.171.1.3.2.1.8
        type: gauge
        help: IPsec tunnel active time in seconds
        indexes:
          - labelname: cipSecTunIndex
            type: Integer

      # IKE Phase 1 Stats
      - name: cikeGlobalActiveTunnels
        oid: 1.3.6.1.4.1.9.9.171.1.2.1.1.0
        type: gauge
        help: Number of active IKE tunnels

      - name: cikeGlobalInOctets
        oid: 1.3.6.1.4.1.9.9.171.1.2.1.2.0
        type: counter
        help: Total IKE inbound bytes

      - name: cikeGlobalOutOctets
        oid: 1.3.6.1.4.1.9.9.171.1.2.1.6.0
        type: counter
        help: Total IKE outbound bytes
  synology:
    walk:
      - 1.3.6.1.4.1.2021.4                # UCD memory
      - 1.3.6.1.4.1.2021.10.1.5           # UCD laLoadInt table
    metrics:
      - name: synoMemTotalReal
        oid: 1.3.6.1.4.1.2021.4.5.0
        type: gauge
        help: Total real memory (kB, UCD-SNMP memTotalReal)

      - name: synoMemAvailReal
        oid: 1.3.6.1.4.1.2021.4.6.0
        type: gauge
        help: FREE real memory (kB, UCD memAvailReal — free only, NOT MemAvailable; do not threshold on this)

      - name: synoMemTotalSwap
        oid: 1.3.6.1.4.1.2021.4.3.0
        type: gauge
        help: Total swap (kB, UCD memTotalSwap)

      - name: synoMemAvailSwap
        oid: 1.3.6.1.4.1.2021.4.4.0
        type: gauge
        help: Available swap (kB, UCD memAvailSwap)

      - name: synoLaLoadInt
        oid: 1.3.6.1.4.1.2021.10.1.5
        type: gauge
        help: Load average x100 (UCD-SNMP laLoadInt; laIndex 1=1min 2=5min 3=15min)
        indexes:
          - labelname: laIndex
            type: gauge
EOT
  }

  depends_on = [helm_release.monitoring]
}

# -----------------------------------------------------------------------------
# Deployment - SNMP Exporter
# -----------------------------------------------------------------------------
moved {
  from = REDACTED_08d34ae1.snmp_exporter
  to   = REDACTED_08d34ae1.snmp_exporter[0]
}

resource "REDACTED_08d34ae1" "snmp_exporter" {
  count = var.asa_snmp_enabled ? 1 : 0

  metadata {
    name      = "snmp-exporter"
    namespace = "monitoring"
    labels = merge(var.common_labels, {
      "app.kubernetes.io/name"      = "snmp-exporter"
      "app.kubernetes.io/component" = "exporter"
    })
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name"      = "snmp-exporter"
        "app.kubernetes.io/component" = "exporter"
      }
    }

    template {
      metadata {
        labels = merge(var.common_labels, {
          "app.kubernetes.io/name"      = "snmp-exporter"
          "app.kubernetes.io/component" = "exporter"
        })
        annotations = {
          "checksum/config" = sha256(REDACTED_a9df2e77_v1.REDACTED_2b0aa899[0].data["snmp.yml"])
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }
              }
            }
          }
        }

        container {
          name  = "snmp-exporter"
          image = "prom/snmp-exporter:v0.30.1"

          args = [
            "--config.file=/etc/snmp_exporter/snmp.yml",
            "--log.level=info",
          ]

          port {
            name           = "http"
            container_port = 9116
            protocol       = "TCP"
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/snmp_exporter"
            read_only  = true
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }

          liveness_probe {
            http_get {
              # v0.30.x moved to exporter-toolkit endpoints: /health is 404,
              # health lives at /-/healthy (verified live 2026-07-08). The old
              # path killed a healthy container every ~90s (149 restarts/9h).
              path = "/-/healthy"
              port = 9116
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/-/healthy"
              port = 9116
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 65534
          }
        }

        volume {
          name = "config"
          config_map {
            name = REDACTED_a9df2e77_v1.REDACTED_2b0aa899[0].metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [REDACTED_a9df2e77_v1.REDACTED_2b0aa899]
}

# -----------------------------------------------------------------------------
# Service - SNMP Exporter
# -----------------------------------------------------------------------------
moved {
  from = kubernetes_service_v1.snmp_exporter
  to   = kubernetes_service_v1.snmp_exporter[0]
}

resource "kubernetes_service_v1" "snmp_exporter" {
  count = var.asa_snmp_enabled ? 1 : 0

  metadata {
    name      = "snmp-exporter"
    namespace = "monitoring"
    labels = merge(var.common_labels, {
      "app.kubernetes.io/name"      = "snmp-exporter"
      "app.kubernetes.io/component" = "exporter"
    })
  }

  spec {
    type = "ClusterIP"

    selector = {
      "app.kubernetes.io/name"      = "snmp-exporter"
      "app.kubernetes.io/component" = "exporter"
    }

    port {
      name        = "http"
      port        = 9116
      target_port = 9116
      protocol    = "TCP"
    }
  }
}

# -----------------------------------------------------------------------------
# ServiceMonitor - SNMP Exporter self-metrics
# -----------------------------------------------------------------------------
moved {
  from = kubernetes_manifest.REDACTED_6b7ed15a
  to   = kubernetes_manifest.REDACTED_6b7ed15a[0]
}

resource "kubernetes_manifest" "REDACTED_6b7ed15a" {
  count = var.asa_snmp_enabled ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "snmp-exporter"
      namespace = "monitoring"
      labels = merge(var.common_labels, {
        "app.kubernetes.io/name" = "snmp-exporter"
        release                  = "monitoring"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "snmp-exporter"
        }
      }
      namespaceSelector = {
        matchNames = ["monitoring"]
      }
      endpoints = [{
        port          = "http"
        path          = "/metrics"
        interval      = "30s"
        scrapeTimeout = "10s"
      }]
    }
  }

  depends_on = [helm_release.monitoring]
}
