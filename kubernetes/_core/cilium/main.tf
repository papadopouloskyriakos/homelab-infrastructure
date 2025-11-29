# ========================================================================
# Cilium CNI Helm Release
# ========================================================================
# Manages Cilium installation via Helm through OpenTofu
# Enables Service Mesh mTLS with SPIRE
# ========================================================================

resource "helm_release" "cilium" {
  name             = "cilium"
  namespace        = "kube-system"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  version          = "1.18.4"
  create_namespace = false

  # Cluster settings
  set {
    name  = "cluster.name"
    value = "kubernetes"
  }

  set {
    name  = "k8sServiceHost"
    value = var.k8s_api_host
  }

  set {
    name  = "k8sServicePort"
    value = "6443"
  }

  # Networking
  set {
    name  = "REDACTED_fd61d0fe"
    value = "true"
  }

  set {
    name  = "routingMode"
    value = "tunnel"
  }

  set {
    name  = "tunnelProtocol"
    value = "vxlan"
  }

  # Operator
  set {
    name  = "operator.replicas"
    value = "1"
  }

  # ========================================================================
  # Hubble Observability
  # ========================================================================
  set {
    name  = "hubble.enabled"
    value = "true"
  }

  set {
    name  = "hubble.relay.enabled"
    value = "true"
  }

  set {
    name  = "hubble.ui.enabled"
    value = "true"
  }

  # Hubble Metrics
  set {
    name  = "hubble.metrics.enableOpenMetrics"
    value = "true"
  }

  set {
    name  = "hubble.metrics.enabled"
    value = "{dns,drop,tcp,flow,icmp,http}"
  }

  set {
    name  = "hubble.metrics.serviceMonitor.enabled"
    value = "true"
  }

  # ========================================================================
  # Prometheus Metrics
  # ========================================================================
  set {
    name  = "prometheus.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "operator.prometheus.enabled"
    value = "true"
  }

  set {
    name  = "operator.prometheus.serviceMonitor.enabled"
    value = "true"
  }

  # ========================================================================
  # Gateway API (future-proofing)
  # ========================================================================
  set {
    name  = "gatewayAPI.enabled"
    value = "true"
  }

  # ========================================================================
  # Service Mesh - mTLS with SPIRE
  # ========================================================================
  set {
    name  = "authentication.mutual.spire.enabled"
    value = "true"
  }

  set {
    name  = "authentication.mutual.spire.install.enabled"
    value = "true"
  }

  set {
    name  = "authentication.mutual.spire.install.server.dataStorage.storageClass"
    value = "nfs-client"
  }
}

# ========================================================================
# Cilium BGP Configuration
# Manages LB-IPAM pool and BGP peering for LoadBalancer services
# ========================================================================

resource "kubernetes_manifest" "cilium_lb_pool" {
  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "REDACTED_ad8886c8"
    metadata = {
      name = "lb-pool"
    }
    spec = {
      blocks = [
        {
          start = var.lb_pool_start
          stop  = var.lb_pool_stop
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "REDACTED_5c4a3b9e" {
  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "CiliumBGPPeerConfig"
    metadata = {
      name = "asa-peer-config"
    }
    spec = {
      timers = {
        holdTimeSeconds      = 90
        keepAliveTimeSeconds = 30
      }
      gracefulRestart = {
        enabled            = true
        restartTimeSeconds = 120
      }
      families = [
        {
          afi  = "ipv4"
          safi = "unicast"
          advertisements = {
            matchLabels = {
              advertise = "bgp"
            }
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "REDACTED_5868bd7c" {
  depends_on = [kubernetes_manifest.REDACTED_5c4a3b9e]

  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "REDACTED_916bf007"
    metadata = {
      name = "bgp-cluster-config"
    }
    spec = {
      nodeSelector = {
        matchLabels = {
          "node-role.kubernetes.io/worker" = "worker"
        }
      }
      bgpInstances = [
        {
          name     = "k8s-bgp"
          localASN = var.local_asn
          peers = [
            {
              name        = "asa-peer"
              peerASN     = var.peer_asn
              peerAddress = var.peer_address
              peerConfigRef = {
                name = "asa-peer-config"
              }
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "REDACTED_4dd3398e" {
  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "REDACTED_ace81415"
    metadata = {
      name = "lb-advertisement"
      labels = {
        advertise = "bgp"
      }
    }
    spec = {
      advertisements = [
        {
          advertisementType = "Service"
          service = {
            addresses = ["LoadBalancerIP"]
          }
          selector = {
            matchExpressions = [
              {
                key      = "somekey"
                operator = "NotIn"
                values   = ["REDACTED_c5e92d4f"]
              }
            ]
          }
        }
      ]
    }
  }
}

# ========================================================================
# Hubble Relay LoadBalancer Service
# Exposes Hubble Relay for CLI access outside the cluster
# ========================================================================

resource "kubernetes_service_v1" "hubble_relay_lb" {
  metadata {
    name      = "hubble-relay-lb"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"    = "hubble-relay"
      "app.kubernetes.io/part-of" = "cilium"
      "managed-by"                = "opentofu"
    }
  }

  spec {
    type = "LoadBalancer"

    selector = {
      "k8s-app" = "hubble-relay"
    }

    port {
      name        = "grpc"
      port        = 80
      target_port = 4245
      protocol    = "TCP"
    }
  }
}

# ========================================================================
