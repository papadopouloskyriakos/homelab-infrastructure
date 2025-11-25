***REMOVED***
# Monitoring Stack (Prometheus + Grafana)
***REMOVED***
# Deploys REDACTED_d8074874 with proper node affinity to keep
# Prometheus and Alertmanager OFF control plane nodes
***REMOVED***

variable "common_labels" {
  description = "Common labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "1095d"
}

variable "REDACTED_6a2724e6" {
  description = "Prometheus PVC size"
  type        = string
  default     = "200Gi"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "grafana_storage_size" {
  description = "Grafana PVC size"
  type        = string
  default     = "20Gi"
}

# -----------------------------------------------------------------------------
# Helm Release: REDACTED_d8074874
# -----------------------------------------------------------------------------
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
          # Retention settings
          retention     = var.prometheus_retention
          retentionSize = "190GB"

          # Resource requests/limits
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

          ***REMOVED*** configuration
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

          # =======================================================================
          # NODE AFFINITY - Keep Prometheus OFF control plane nodes
          # =======================================================================
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

          # Tolerate nothing - don't schedule on tainted nodes
          tolerations = []
        }

        # Service configuration
        service = {
          type = "NodePort"
          nodePort = 30090
        }
      }

      # =========================================================================
      # ALERTMANAGER CONFIGURATION
      # =========================================================================
      alertmanager = {
        alertmanagerSpec = {
          ***REMOVED*** for alertmanager
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

          # Resource limits
          resources = {
            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
          }

          # =======================================================================
          # NODE AFFINITY - Keep Alertmanager OFF control plane nodes
          # =======================================================================
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
      }

      # =========================================================================
      # GRAFANA CONFIGURATION
      # =========================================================================
      grafana = {
        adminPassword = var.grafana_admin_password

        # Persistence
        persistence = {
          enabled          = true
          storageClassName = "nfs-client"
          size             = var.grafana_storage_size
        }

        # Service configuration
        service = {
          type     = "NodePort"
          nodePort = 30000
        }

        # =======================================================================
        # NODE AFFINITY - Keep Grafana OFF control plane nodes
        # =======================================================================
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
      # KUBE-STATE-METRICS CONFIGURATION
      # =========================================================================
      kube-state-metrics = {
        # Keep off control plane
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
        # Keep operator off control plane
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
        # Node exporter SHOULD run on control plane to collect metrics
        tolerations = [{
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }]
      }

      # =========================================================================
      # ADDITIONAL SETTINGS
      # =========================================================================
      # Disable components we don't need
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
# Outputs
# -----------------------------------------------------------------------------
output "namespace" {
  value = helm_release.monitoring.metadata[0].namespace
}

output "chart_version" {
  value = helm_release.monitoring.metadata[0].version
}

output "grafana_nodeport" {
  value = 30000
}

output "prometheus_nodeport" {
  value = 30090
}
