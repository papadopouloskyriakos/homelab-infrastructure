***REMOVED***
# Monitoring Stack (Prometheus + Grafana)
***REMOVED***
# Deploys REDACTED_d8074874 with proper node affinity to keep
# Prometheus and Alertmanager OFF control plane nodes
***REMOVED***

# -----------------------------------------------------------------------------
# ExternalSecret for Grafana Admin Credentials
# -----------------------------------------------------------------------------
# Creates the secret BEFORE Helm release so Grafana can use existingSecret
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_9675462a" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "monitoring-grafana"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/name"      = "grafana"
        "app.kubernetes.io/component" = "admin-secret"
        environment                   = "production"
        "managed-by"                  = "opentofu"
      }
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "monitoring-grafana"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "admin-user"
          remoteRef = {
            key      = "REDACTED_f6e2d5a1"
            property = "admin-user"
          }
        },
        {
          secretKey = REDACTED_e7c10ed7
          remoteRef = {
            key      = "REDACTED_f6e2d5a1"
            property = REDACTED_e7c10ed7
          }
        }
      ]
    }
  }
}

# -----------------------------------------------------------------------------
# Monitoring Helm Release
# -----------------------------------------------------------------------------
resource "helm_release" "monitoring" {
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "REDACTED_d8074874"
  namespace        = "monitoring"
  create_namespace = true
  version          = "79.10.0"
  timeout          = 1800
  wait             = true

  # Ensure ExternalSecret creates the secret first
  depends_on = [kubernetes_manifest.REDACTED_9675462a]

  values = [
    yamlencode({
      # =========================================================================
      # PROMETHEUS CONFIGURATION
      # =========================================================================
      prometheus = {
        prometheusSpec = {
          replicas = 2

          # Scrape all ServiceMonitors and PodMonitors (not just release=monitoring)
          serviceMonitorSelector                  = {}
          serviceMonitorSelectorNilUsesHelmValues = false
          serviceMonitorNamespaceSelector         = {}
          podMonitorSelector                      = {}
          podMonitorSelectorNilUsesHelmValues     = false
          podMonitorNamespaceSelector             = {}

          podDisruptionBudget = {
            enabled      = true
            minAvailable = 1
          }

          retention     = "24h"
          retentionSize = "50GB"

          # Thanos sidecar configuration
          thanos = {
            image = "quay.io/thanos/thanos:v0.37.2"
            objectStorageConfig = {
              existingSecret = {
                name = "REDACTED_5f4971dc"
                key  = "objstore.yml"
              }
            }
            resources = {
              requests = {
                cpu    = "50m"
                memory = "128Mi"
              }
              limits = {
                cpu    = "200m"
                memory = "512Mi"
              }
            }
          }

          # External labels for Thanos deduplication
          externalLabels = {
            cluster = "nl"
            site    = "nl"
          }

          replicaExternalLabelName = "prometheus_replica"

          resources = {
            requests = {
              cpu    = "500m"
              memory = "2Gi"
            }
            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
          }

          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "REDACTED_4f3da73d"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.REDACTED_6a2724e6
                  }
                }
              }
            }
          }

          affinity = {
            nodeAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = {
                nodeSelectorTerms = [{
                  matchExpressions = [{
                    key      = "node-role.kubernetes.io/control-plane"
                    operator = "DoesNotExist"
                  }]
                }]
              }
            }
            podAntiAffinity = {
              preferredDuringSchedulingIgnoredDuringExecution = [{
                weight = 100
                podAffinityTerm = {
                  labelSelector = {
                    matchExpressions = [{
                      key      = "app.kubernetes.io/name"
                      operator = "In"
                      values   = ["prometheus"]
                    }]
                  }
                  topologyKey = "kubernetes.io/hostname"
                }
              }]
            }
          }

          tolerations = []

          # =================================================================
          # Additional Scrape Configs - Network Infrastructure Exporters
          # =================================================================
          additionalScrapeConfigs = [
            # FRR BGP Exporters - Route Reflector VMs
            {
              job_name = "frr-route-reflectors"
              static_configs = [{
                targets = [
                  "10.0.X.X:9342",
                  "10.0.X.X:9342",
                  "10.0.X.X:9342",
                  "10.0.X.X:9342",
                ]
                labels = {
                  role = "route-reflector"
                }
              }]
              relabel_configs = [
                { source_labels = ["__address__"], regex = "192\\.168\\.192\\.3:.*", target_label = "instance", replacement = "nl-rtr01" },
                { source_labels = ["__address__"], regex = "192\\.168\\.192\\.4:.*", target_label = "instance", replacement = "nl-rtr02" },
                { source_labels = ["__address__"], regex = "192\\.168\\.15\\.3:.*", target_label = "instance", replacement = "gr-rtr01" },
                { source_labels = ["__address__"], regex = "192\\.168\\.15\\.4:.*", target_label = "instance", replacement = "gr-rtr02" },
                { source_labels = ["__address__"], regex = "192\\.168\\.192\\..*", target_label = "site", replacement = "nl" },
                { source_labels = ["__address__"], regex = "192\\.168\\.15\\..*", target_label = "site", replacement = "gr" },
              ]
            },
            # FRR BGP Exporters - Edge Nodes
            {
              job_name = "frr-edge-nodes"
              static_configs = [{
                targets = [
                  "10.255.2.11:9342",
                  "10.255.3.11:9342",
                ]
                labels = {
                  role = "edge-node"
                }
              }]
              relabel_configs = [
                { source_labels = ["__address__"], regex = "10\\.255\\.2\\.11:.*", target_label = "instance", replacement = "ch-edge" },
                { source_labels = ["__address__"], regex = "10\\.255\\.2\\.11:.*", target_label = "site", replacement = "ch" },
                { source_labels = ["__address__"], regex = "10\\.255\\.3\\.11:.*", target_label = "instance", replacement = "no-edge" },
                { source_labels = ["__address__"], regex = "10\\.255\\.3\\.11:.*", target_label = "site", replacement = "no" },
              ]
            },
            # IPsec Exporters - Edge Nodes
            {
              job_name = "ipsec-edge-nodes"
              static_configs = [{
                targets = [
                  "10.255.2.11:9536",
                  "10.255.3.11:9536",
                ]
                labels = {
                  role = "ipsec-gateway"
                }
              }]
              relabel_configs = [
                { source_labels = ["__address__"], regex = "10\\.255\\.2\\.11:.*", target_label = "instance", replacement = "ch-edge" },
                { source_labels = ["__address__"], regex = "10\\.255\\.2\\.11:.*", target_label = "site", replacement = "ch" },
                { source_labels = ["__address__"], regex = "10\\.255\\.3\\.11:.*", target_label = "instance", replacement = "no-edge" },
                { source_labels = ["__address__"], regex = "10\\.255\\.3\\.11:.*", target_label = "site", replacement = "no" },
              ]
            },
            # SNMP Exporter - Cisco ASA Firewall (local site only)
            {
              job_name        = "snmp-asa"
              scrape_interval = "60s"
              scrape_timeout  = "55s"
              metrics_path    = "/snmp"
              params = {
                module = ["cisco_asa"]
                auth   = ["asa_v2"]
              }
              static_configs = [{
                targets = ["10.0.X.X"] # NL ASA only - GR cluster scrapes its own ASA
              }]
              relabel_configs = [
                { source_labels = ["__address__"], target_label = "__param_target" },
                { source_labels = ["__param_target"], target_label = "instance" },
                { target_label = "device", replacement = "nlfw01" },
                { target_label = "site", replacement = "nl" },
                { target_label = "__address__", replacement = "snmp-exporter.monitoring.svc:9116" },
              ]
            },
            # Node Exporter - Edge/DMZ Hosts
            {
              job_name = "node-exporter-edge"
              static_configs = [{
                targets = [
                  "10.0.X.X:9100", # nldmz01 - NL DMZ Docker host
                  "10.0.X.X:9100",  # grdmz01 - GR DMZ Docker host
                  "10.255.2.11:9100",    # chzrh01vps01 - CH VPS edge proxy
                  "10.255.3.11:9100",    # notrf01vps01 - NO VPS edge proxy
                ]
                labels = {
                  role = "edge-host"
                }
              }]
              relabel_configs = [
                # Instance names
                { source_labels = ["__address__"], regex = "192\\.168\\.192\\.10:.*", target_label = "instance", replacement = "nldmz01" },
                { source_labels = ["__address__"], regex = "192\\.168\\.15\\.10:.*", target_label = "instance", replacement = "grdmz01" },
                { source_labels = ["__address__"], regex = "10\\.255\\.2\\.11:.*", target_label = "instance", replacement = "chzrh01vps01" },
                { source_labels = ["__address__"], regex = "10\\.255\\.3\\.11:.*", target_label = "instance", replacement = "notrf01vps01" },
                # Site labels
                { source_labels = ["__address__"], regex = "192\\.168\\.192\\..*", target_label = "site", replacement = "nl" },
                { source_labels = ["__address__"], regex = "192\\.168\\.15\\..*", target_label = "site", replacement = "gr" },
                { source_labels = ["__address__"], regex = "10\\.255\\.2\\..*", target_label = "site", replacement = "ch" },
                { source_labels = ["__address__"], regex = "10\\.255\\.3\\..*", target_label = "site", replacement = "no" },
              ]
            },
            # CrowdSec Security Metrics
            {
              job_name = "crowdsec"
              static_configs = [{
                targets = [
                  "10.0.X.X:6060", # nldmz01
                  "10.0.X.X:6060",  # grdmz01
                  "10.255.2.11:6060",    # chzrh01vps01
                  "10.255.3.11:6060",    # notrf01vps01
                ]
                labels = {
                  role = "security"
                }
              }]
              relabel_configs = [
                { source_labels = ["__address__"], regex = "192\\.168\\.192\\.10:.*", target_label = "instance", replacement = "nldmz01" },
                { source_labels = ["__address__"], regex = "192\\.168\\.15\\.10:.*", target_label = "instance", replacement = "grdmz01" },
                { source_labels = ["__address__"], regex = "10\\.255\\.2\\.11:.*", target_label = "instance", replacement = "chzrh01vps01" },
                { source_labels = ["__address__"], regex = "10\\.255\\.3\\.11:.*", target_label = "instance", replacement = "notrf01vps01" },
                { source_labels = ["__address__"], regex = "192\\.168\\.192\\..*", target_label = "site", replacement = "nl" },
                { source_labels = ["__address__"], regex = "192\\.168\\.15\\..*", target_label = "site", replacement = "gr" },
                { source_labels = ["__address__"], regex = "10\\.255\\.2\\..*", target_label = "site", replacement = "ch" },
                { source_labels = ["__address__"], regex = "10\\.255\\.3\\..*", target_label = "site", replacement = "no" },
              ]
            },
          ]
        }

        service = {
          type     = "NodePort"
          nodePort = 30090
        }
      }

      # =========================================================================
      # ALERTMANAGER CONFIGURATION
      # =========================================================================
      alertmanager = {
        alertmanagerSpec = {
          replicas = 2

          # Scrape all ServiceMonitors and PodMonitors (not just release=monitoring)
          serviceMonitorSelector                  = {}
          serviceMonitorSelectorNilUsesHelmValues = false
          serviceMonitorNamespaceSelector         = {}
          podMonitorSelector                      = {}
          podMonitorSelectorNilUsesHelmValues     = false
          podMonitorNamespaceSelector             = {}

          podDisruptionBudget = {
            enabled      = true
            minAvailable = 1
          }

          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "REDACTED_4f3da73d"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "10Gi"
                  }
                }
              }
            }
          }

          resources = {
            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
          }

          affinity = {
            nodeAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = {
                nodeSelectorTerms = [{
                  matchExpressions = [{
                    key      = "node-role.kubernetes.io/control-plane"
                    operator = "DoesNotExist"
                  }]
                }]
              }
            }
            podAntiAffinity = {
              preferredDuringSchedulingIgnoredDuringExecution = [{
                weight = 100
                podAffinityTerm = {
                  labelSelector = {
                    matchExpressions = [{
                      key      = "app.kubernetes.io/name"
                      operator = "In"
                      values   = ["alertmanager"]
                    }]
                  }
                  topologyKey = "kubernetes.io/hostname"
                }
              }]
            }
          }

          tolerations = []
        }
      }

      # =========================================================================
      # GRAFANA CONFIGURATION (NFS for RWX multi-replica support)
      # =========================================================================
      grafana = {
        replicas = 2

        # Scrape all ServiceMonitors and PodMonitors (not just release=monitoring)
        serviceMonitorSelector                  = {}
        serviceMonitorSelectorNilUsesHelmValues = false
        serviceMonitorNamespaceSelector         = {}
        podMonitorSelector                      = {}
        podMonitorSelectorNilUsesHelmValues     = false
        podMonitorNamespaceSelector             = {}

        podDisruptionBudget = {
          enabled      = true
          minAvailable = 1
        }

        # Use existing secret created by ExternalSecret instead of plaintext password
        admin = {
          existingSecret = "monitoring-grafana"
          userKey        = "admin-user"
          passwordKey    = REDACTED_e7c10ed7
        }

        persistence = {
          enabled          = true
          storageClassName = "nfs-client"
          size             = var.grafana_storage_size
        }

        service = {
          type     = "NodePort"
          nodePort = 30000
        }

        affinity = {
          nodeAffinity = {
            requiredDuringSchedulingIgnoredDuringExecution = {
              nodeSelectorTerms = [{
                matchExpressions = [{
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }]
              }]
            }
          }
          podAntiAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [{
              weight = 100
              podAffinityTerm = {
                labelSelector = {
                  matchExpressions = [{
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values   = ["grafana"]
                  }]
                }
                topologyKey = "kubernetes.io/hostname"
              }
            }]
          }
        }

        tolerations = []

        # Loki datasource for centralized log aggregation
        additionalDataSources = [
          {
            name      = "Loki"
            type      = "loki"
            url       = "http://loki.logging.svc.cluster.local:3100"
            access    = "proxy"
            isDefault = false
            jsonData = {
              maxLines = 1000
            }
          }
        ]
      }

      # =========================================================================
      # KUBE-STATE-METRICS CONFIGURATION
      # =========================================================================
      kube-state-metrics = {
        podDisruptionBudget = {
          enabled      = true
          minAvailable = 1
        }

        affinity = {
          nodeAffinity = {
            requiredDuringSchedulingIgnoredDuringExecution = {
              nodeSelectorTerms = [{
                matchExpressions = [{
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }]
              }]
            }
          }
        }

        tolerations = []
      }

      # =========================================================================
      # PROMETHEUS OPERATOR CONFIGURATION
      # =========================================================================
      prometheusOperator = {
        podDisruptionBudget = {
          enabled      = true
          minAvailable = 1
        }

        affinity = {
          nodeAffinity = {
            requiredDuringSchedulingIgnoredDuringExecution = {
              nodeSelectorTerms = [{
                matchExpressions = [{
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }]
              }]
            }
          }
        }

        tolerations = []
      }

      # =========================================================================
      # NODE EXPORTER - DaemonSet (runs on ALL nodes including control plane)
      # =========================================================================
      prometheus-node-exporter = {
        tolerations = [{
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }]
      }

      # =========================================================================
      # ADDITIONAL SETTINGS
      # =========================================================================
      kubeEtcd = {
        enabled = true
      }

      kubeControllerManager = {
        enabled = true
      }

      kubeScheduler = {
        enabled = true
      }

      kubeProxy = {
        enabled = true
      }
    })
  ]
}

# -----------------------------------------------------------------------------
# Prometheus Ingress
# -----------------------------------------------------------------------------
resource "kubernetes_ingress_v1" "prometheus" {
  count = var.REDACTED_4c06acbb ? 1 : 0

  metadata {
    name      = "prometheus"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name" = "prometheus"
      environment              = "production"
      "managed-by"             = "opentofu"
      site                     = "nl"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = var.prometheus_hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "REDACTED_6dfbe9fc"
              port {
                number = 9090
              }
            }
          }
        }
      }
    }
  }
}
