***REMOVED***
# Monitoring Stack (Prometheus + Grafana)
***REMOVED***
# Deploys REDACTED_d8074874 with proper node affinity to keep
# Prometheus and Alertmanager OFF control plane nodes
***REMOVED***

resource "helm_release" "monitoring" {
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "REDACTED_d8074874"
  namespace        = "monitoring"
  create_namespace = true
  version          = "79.7.1"
  timeout          = 600
  wait             = true

  values = [
    yamlencode({
      # =========================================================================
      # PROMETHEUS CONFIGURATION
      # =========================================================================
      prometheus = {
        prometheusSpec = {
          replicas = 2

          podDisruptionBudget = {
            enabled      = true
            minAvailable = 1
          }

          retention     = var.prometheus_retention
          retentionSize = "190GB"

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
                storageClassName = "nfs-client"
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

          podDisruptionBudget = {
            enabled      = true
            minAvailable = 1
          }

          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "nfs-client"
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
      # GRAFANA CONFIGURATION
      # =========================================================================
      grafana = {
        replicas = 2

        podDisruptionBudget = {
          enabled      = true
          minAvailable = 1
        }

        adminPassword = var.grafana_admin_password

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
