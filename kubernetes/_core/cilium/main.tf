# ========================================================================
# Cilium CNI Helm Release
# ========================================================================
# Manages Cilium installation via Helm through OpenTofu
# Enables Service Mesh mTLS with SPIRE
# ClusterMesh with shared CA for cross-site (NL ↔ GR) connectivity
# ========================================================================

locals {
  # REDACTED_9b1272d3 is "<ip>:<port>"; the Helm values take them
  # as separate keys (clusters[0].ips[0] + clusters[0].port).
  clustermesh_remote_ip   = split(":", var.REDACTED_9b1272d3)[0]
  clustermesh_remote_port = split(":", var.REDACTED_9b1272d3)[1]
}

# ========================================================================
# Data source for shared CA (synced by ExternalSecret)
# ========================================================================
data "kubernetes_secret_v1" "cilium_ca_shared" {
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
  version          = var.cilium_version
  create_namespace = false

  # Canary-safe: don't block the Atlantis apply on the full DaemonSet roll — it is
  # monitored externally by a per-node host-egress canary (cilium/cilium #44430).
  wait = false

  set = [
    # Cluster settings
    {
      name  = "cluster.name"
      value = var.cluster_name
    },
    {
      name  = "cluster.id"
      value = var.cluster_id
    },
    {
      name  = "k8sServiceHost"
      value = var.k8s_api_host
    },
    {
      name  = "k8sServicePort"
      value = "6443"
    },
    # =========================================================================
    # IPAM Configuration - CRITICAL FOR CLUSTERMESH
    # NL Cluster uses 10.0.0.0/16, GR Cluster uses 10.1.0.0/16 (var.pod_cidr)
    # This prevents pod CIDR collisions across clusters
    # =========================================================================
    {
      name  = "ipam.mode"
      value = "cluster-pool"
    },
    {
      name  = "ipam.operator.clusterPoolIPv4PodCIDRList"
      value = var.pod_cidr
    },
    {
      name  = "ipam.operator.clusterPoolIPv4MaskSize"
      value = "24"
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
      value = var.REDACTED_46d876c8
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
    # ⚠ Value must stay BYTE-IDENTICAL — changing it regenerates clustermesh
    # certs and blips the mesh.
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
      value = var.REDACTED_46d876c8
    },
    {
      name  = "operator.prometheus.enabled"
      value = "true"
    },
    {
      name  = "operator.prometheus.serviceMonitor.enabled"
      value = var.REDACTED_46d876c8
    },
    # ========================================================================
    # ClusterMesh Metrics
    # ========================================================================
    {
      name  = "clustermesh.apiserver.metrics.serviceMonitor.enabled"
      value = var.REDACTED_46d876c8
    },
    # ========================================================================
    # Gateway API (future-proofing)
    # ========================================================================
    {
      name  = "gatewayAPI.enabled"
      value = "true"
    },
    # ========================================================================
    # BGP Control Plane
    # Both clusters run live with enable-bgp-control-plane=true; set it
    # explicitly so the Helm values finally record reality.
    # ========================================================================
    {
      name  = "bgpControlPlane.enabled"
      value = "true"
    },
    # ========================================================================
    # Service Mesh - mTLS with SPIRE
    # ========================================================================
    {
      name  = "REDACTED_6fa691d2.mutual.spire.enabled"
      value = "true"
    },
    # REDACTED_6fa691d2.enabled=true is REQUIRED alongside spire.enabled since 1.19
    # (chart validate.yaml hard-fails otherwise — fail-SAFE, rejects before
    # rolling any pod).
    {
      name  = "REDACTED_6fa691d2.enabled"
      value = "true"
    },
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.enabled"
      value = "true"
    },
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.server.dataStorage.storageClass"
      value = var.spire_storage_class
    },

    # SPIRE server security context - running as root due to hostPath socket permissions
    # TODO: Revert to non-root (UID 1000) when Cilium fixes upstream issue
    # Bug: https://github.com/cilium/cilium/issues/40533
    # Risk: LOW - no privileged mode, no dangerous capabilities, internal-only exposure
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.server.podSecurityContext.runAsUser"
      value = "0"
    },
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.server.podSecurityContext.runAsGroup"
      value = "0"
    },

    # SPIRE Agent tolerations - must include ALL tolerations as array is replaced, not merged
    # Index 0: Edge nodes
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[0].key"
      value = "node-type"
    },
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[0].operator"
      value = "Equal"
    },
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[0].value"
      value = "edge"
    },
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[0].effect"
      value = "NoSchedule"
    },
    # Index 1: Control plane
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[1].key"
      value = "node-role.kubernetes.io/control-plane"
    },
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[1].effect"
      value = "NoSchedule"
    },
    # Index 2: Master (legacy)
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[2].key"
      value = "node-role.kubernetes.io/master"
    },
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[2].effect"
      value = "NoSchedule"
    },
    # Index 3: Not ready nodes
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[3].key"
      value = "node.kubernetes.io/not-ready"
    },
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[3].effect"
      value = "NoSchedule"
    },
    # Index 4: Critical addons
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[4].key"
      value = "CriticalAddonsOnly"
    },
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[4].operator"
      value = "Exists"
    },
    # Index 5: Cilium agent not ready
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[5].key"
      value = "node.cilium.io/agent-not-ready"
    },
    {
      name  = "REDACTED_6fa691d2.mutual.spire.install.agent.tolerations[5].effect"
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
      value = var.clustermesh_remote_cluster_name
    },
    {
      name  = "clustermesh.config.clusters[0].ips[0]"
      value = local.clustermesh_remote_ip
    },
    {
      name  = "clustermesh.config.clusters[0].port"
      value = local.clustermesh_remote_port
    },
    # 1.20 upgrade safety (IFRNLLEI01PRD-2373): REDACTED_d95cbb1b = outgoing minor;
    # pin datapathMode=veth — 1.20's new default "auto" probes netkit (present on our 7.0 kernels)
    # and an in-place upgrade must not switch datapath modes.
    {
      name  = "REDACTED_d95cbb1b"
      value = "1.19"
    },
    {
      name  = "bpf.datapathMode"
      value = "veth"
    },
    {
      name  = "REDACTED_08ead801"
      value = "false"
    },
  ]

  # ========================================================================
  # Shared CA for ClusterMesh TLS
  # CA synced from OpenBao via ExternalSecret
  # ========================================================================
  set_sensitive = [
    {
      name  = "tls.ca.cert"
      value = base64encode(data.kubernetes_secret_v1.cilium_ca_shared.data["ca.crt"])
    },
    {
      name  = "tls.ca.key"
      value = base64encode(data.kubernetes_secret_v1.cilium_ca_shared.data["ca.key"])
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
      host = var.hubble_hostname

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
