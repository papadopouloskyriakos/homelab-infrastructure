***REMOVED***
# SNMP Exporter - Cisco ASA Monitoring
***REMOVED***
# Scrapes BGP and interface metrics from ASA firewalls via SNMP v2c
# Targets: NL ASA (10.0.X.X), GR ASA (10.0.X.X)
***REMOVED***

# -----------------------------------------------------------------------------
# ConfigMap - SNMP Exporter Configuration for Cisco ASA
# -----------------------------------------------------------------------------
resource "REDACTED_9343442e" "REDACTED_2b0aa899" {
  metadata {
    name      = "REDACTED_c70333e5"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "snmp-exporter"
      "app.kubernetes.io/component" = "config"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
  }

  data = {
    "snmp.yml" = <<-EOT
auths:
  asa_v2:
    community: ${var.snmp_community}
    version: 2

modules:
  cisco_asa:
    walk:
      - 1.3.6.1.2.1.1                    # system
      - 1.3.6.1.2.1.2.2.1                # ifTable
      - 1.3.6.1.2.1.31.1.1               # ifXTable  
      - 1.3.6.1.2.1.15.3                 # bgpPeerTable
      - 1.3.6.1.4.1.9.9.171.1.3.2        # cipSecTunnelTable (CISCO-IPSEC-FLOW-MONITOR-MIB)
      - 1.3.6.1.4.1.9.9.171.1.2.3        # cikePhase1GWStatsTable
    metrics:
      - name: sysUpTime
        oid: 1.3.6.1.2.1.1.3.0
        type: gauge
        help: System uptime in hundredths of a second

      - name: ifOperStatus
        oid: 1.3.6.1.2.1.2.2.1.8
        type: gauge
        help: Interface operational status
        indexes:
          - labelname: ifIndex
            type: Integer
        lookups:
          - labels: [ifIndex]
            labelname: ifDescr
            oid: 1.3.6.1.2.1.2.2.1.2
            type: DisplayString

      - name: ifHCInOctets
        oid: 1.3.6.1.2.1.31.1.1.1.6
        type: counter
        help: Total bytes received
        indexes:
          - labelname: ifIndex
            type: Integer
        lookups:
          - labels: [ifIndex]
            labelname: ifDescr
            oid: 1.3.6.1.2.1.2.2.1.2
            type: DisplayString

      - name: ifHCOutOctets
        oid: 1.3.6.1.2.1.31.1.1.1.10
        type: counter
        help: Total bytes sent
        indexes:
          - labelname: ifIndex
            type: Integer
        lookups:
          - labels: [ifIndex]
            labelname: ifDescr
            oid: 1.3.6.1.2.1.2.2.1.2
            type: DisplayString

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
    auth:
      community: ${var.snmp_community}
EOT
  }

  depends_on = [helm_release.monitoring]
}

# -----------------------------------------------------------------------------
# Deployment - SNMP Exporter
# -----------------------------------------------------------------------------
resource "REDACTED_08d34ae1" "snmp_exporter" {
  metadata {
    name      = "snmp-exporter"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "snmp-exporter"
      "app.kubernetes.io/component" = "exporter"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
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
        labels = {
          "app.kubernetes.io/name"      = "snmp-exporter"
          "app.kubernetes.io/component" = "exporter"
          environment                   = "production"
          "managed-by"                  = "opentofu"
        }
        annotations = {
          "checksum/config" = sha256(REDACTED_9343442e.REDACTED_2b0aa899.data["snmp.yml"])
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
          image = "prom/snmp-exporter:v0.26.0"

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
              path = "/health"
              port = 9116
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/health"
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
            name = REDACTED_9343442e.REDACTED_2b0aa899.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [REDACTED_9343442e.REDACTED_2b0aa899]
}

# -----------------------------------------------------------------------------
# Service - SNMP Exporter
# -----------------------------------------------------------------------------
resource "kubernetes_service_v1" "snmp_exporter" {
  metadata {
    name      = "snmp-exporter"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "snmp-exporter"
      "app.kubernetes.io/component" = "exporter"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
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
resource "kubernetes_manifest" "REDACTED_6b7ed15a" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "snmp-exporter"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/name" = "snmp-exporter"
        environment              = "production"
        "managed-by"             = "opentofu"
        release                  = "monitoring"
      }
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
