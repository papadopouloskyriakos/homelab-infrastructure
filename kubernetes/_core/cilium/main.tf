# ========================================================================
# Cilium CNI Helm Release
# ========================================================================
# Manages Cilium installation via Helm through OpenTofu
# Enables Service Mesh mTLS with SPIRE
# ClusterMesh with shared CA for NL ↔ GR connectivity
# ========================================================================

# ========================================================================
# Data source for shared CA (synced by ExternalSecret)
# ========================================================================
data "kubernetes_secret" "cilium_ca_shared" {
  metadata {
    name      = "cilium-ca-shared"
    namespace = "kube-system"
  }
}

resource "helm_release" "cilium" {
  name             = "cilium"
  namespace        = "kube-system"
  repository       = "https://helm.cilium.io/"
  chart            = "cilium"
  version          = "1.18.4"
  create_namespace = false

  set = [
    # Cluster settings
    {
      name  = "cluster.name"
      value = "nlcl01k8s"
    },
    {
      name  = "cluster.id"
      value = "1"
    },
    {
      name  = "k8sServiceHost"
      value = var.k8s_api_host
    },
    {
      name  = "k8sServicePort"
      value = "6443"
    },
    # Networking
    {
      name  = "REDACTED_fd61d0fe"
      value = "true"
    },
    {
      name  = "routingMode"
      value = "tunnel"
    },
    {
      name  = "tunnelProtocol"
      value = "vxlan"
    },
    {
      name  = "MTU"
      value = "1350"
    },
    # Operator
    {
      name  = "operator.replicas"
      value = "1"
    },
    # ========================================================================
    # Hubble Observability
    # ========================================================================
    {
      name  = "hubble.enabled"
      value = "true"
    },
    {
      name  = "hubble.relay.enabled"
      value = "true"
    },
    {
      name  = "hubble.ui.enabled"
      value = "true"
    },
    # Hubble Metrics
    {
      name  = "hubble.metrics.enableOpenMetrics"
      value = "true"
    },
    {
      name  = "hubble.metrics.enabled"
      value = "{dns,drop,tcp,flow,icmp,http}"
    },
    {
      name  = "hubble.metrics.serviceMonitor.enabled"
      value = "true"
    },
    # ========================================================================
    # Hubble TLS Configuration
    # Explicit config to force cert regeneration with cluster-specific SANs
    # SAN pattern: *.{cluster.name}.hubble-grpc.cilium.io
    # ========================================================================
    {
      name  = "hubble.tls.auto.enabled"
      value = "true"
    },
    {
      name  = "hubble.tls.auto.method"
      value = "helm"
    },
    # Force Hubble relay pod recreation to pick up new certs
    {
      name  = "hubble.relay.podAnnotations.cert-regen-trigger"
      value = "REDACTED_a36086b6"
    },
    # ========================================================================
    # Prometheus Metrics
    # ========================================================================
    {
      name  = "prometheus.enabled"
      value = "true"
    },
    {
      name  = "prometheus.serviceMonitor.enabled"
      value = "true"
    },
    {
      name  = "operator.prometheus.enabled"
      value = "true"
    },
    {
      name  = "operator.prometheus.serviceMonitor.enabled"
      value = "true"
    },
    # ========================================================================
    # ClusterMesh Metrics
    # ========================================================================
    {
      name  = "clustermesh.apiserver.metrics.serviceMonitor.enabled"
      value = "true"
    },
    # ========================================================================
    # Gateway API (future-proofing)
    # ========================================================================
    {
      name  = "gatewayAPI.enabled"
      value = "true"
    },
    # ========================================================================
    # Service Mesh - mTLS with SPIRE
    # ========================================================================
    {
      name  = "authentication.mutual.spire.enabled"
      value = "true"
    },
    {
      name  = "authentication.mutual.spire.install.enabled"
      value = "true"
    },
    {
      name  = "authentication.mutual.spire.install.server.dataStorage.storageClass"
      value = "nfs-client"
    },

    # SPIRE server security context - running as root due to hostPath socket permissions
    # TODO: Revert to non-root (UID 1000) when Cilium fixes upstream issue
    # Bug: https://github.com/cilium/cilium/issues/40533
    # Risk: LOW - no privileged mode, no dangerous capabilities, internal-only exposure
    {
      name  = "authentication.mutual.spire.install.server.podSecurityContext.runAsUser"
      value = "0"
    },
    {
      name  = "authentication.mutual.spire.install.server.podSecurityContext.runAsGroup"
      value = "0"
    },

    # SPIRE Agent tolerations - must include ALL tolerations as array is replaced, not merged
    # Index 0: Edge nodes
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[0].key"
      value = "node-type"
    },
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[0].operator"
      value = "Equal"
    },
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[0].value"
      value = "edge"
    },
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[0].effect"
      value = "NoSchedule"
    },
    # Index 1: Control plane
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[1].key"
      value = "node-role.kubernetes.io/control-plane"
    },
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[1].effect"
      value = "NoSchedule"
    },
    # Index 2: Master (legacy)
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[2].key"
      value = "node-role.kubernetes.io/master"
    },
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[2].effect"
      value = "NoSchedule"
    },
    # Index 3: Not ready nodes
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[3].key"
      value = "node.kubernetes.io/not-ready"
    },
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[3].effect"
      value = "NoSchedule"
    },
    # Index 4: Critical addons
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[4].key"
      value = "CriticalAddonsOnly"
    },
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[4].operator"
      value = "Exists"
    },
    # Index 5: Cilium agent not ready
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[5].key"
      value = "node.cilium.io/agent-not-ready"
    },
    {
      name  = "authentication.mutual.spire.install.agent.tolerations[5].effect"
      value = "NoSchedule"
    },
    # ========================================================================
    # Cluster Mesh - Multi-cluster connectivity
    # ========================================================================
    {
      name  = "clustermesh.useAPIServer"
      value = "true"
    },
    {
      name  = "clustermesh.enableEndpointSliceSynchronization"
      value = "true"
    },
    {
      name  = "clustermesh.apiserver.replicas"
      value = "1"
    },
    {
      name  = "clustermesh.apiserver.service.type"
      value = "LoadBalancer"
    },
    # ========================================================================
    # Cluster Mesh - Remote cluster configuration
    # Automatically creates hostAliases and clustermesh secret
    # ========================================================================
    {
      name  = "clustermesh.config.enabled"
      value = "true"
    },
    {
      name  = "clustermesh.config.domain"
      value = "mesh.cilium.io"
    },
    {
      name  = "clustermesh.config.clusters[0].name"
      value = "grcl01k8s"
    },
    {
      name  = "clustermesh.config.clusters[0].ips[0]"
      value = "10.0.X.X"
    },
    {
      name  = "clustermesh.config.clusters[0].port"
      value = "2379"
    },
  ]

  # ========================================================================
  # Shared CA for ClusterMesh TLS
  # CA synced from OpenBao via ExternalSecret
  # ========================================================================
  set_sensitive = [
    {
      name  = "tls.ca.cert"
      value = base64encode(data.kubernetes_secret.cilium_ca_shared.data["ca.crt"])
    },
    {
      name  = "tls.ca.key"
      value = base64encode(data.kubernetes_secret.cilium_ca_shared.data["ca.key"])
    },
  ]
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

# Hubble UI Ingress
resource "kubernetes_ingress_v1" "hubble_ui" {
  metadata {
    name      = "hubble-ui"
    namespace = "kube-system"
    labels = {
      "k8s-app" = "hubble-ui"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "nl-hubble.example.net"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "hubble-ui"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
