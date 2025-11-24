***REMOVED***
# Monitoring Stack (Prometheus + Grafana)
***REMOVED***
# Helm chart: REDACTED_d8074874
# Components: Prometheus, Grafana, Alertmanager, Node Exporter, Kube-State-Metrics
#
# Import command:
# tofu import 'helm_release.monitoring' 'monitoring/monitoring'
***REMOVED***

resource "helm_release" "monitoring" {
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "REDACTED_d8074874"
  namespace        = "monitoring"
  create_namespace = true
  version          = "79.1.1"

  timeout = 900  # Large chart needs more time

  values = [
    yamlencode({
      # Prometheus configuration
      prometheus = {
        prometheusSpec = {
          retention          = var.prometheus_retention
          retentionSize      = "190GB"
          scrapeInterval     = "30s"
          evaluationInterval = "30s"

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

          resources = {
            requests = {
              memory = "2Gi"
              cpu    = "500m"
            }
            limits = {
              memory = "4Gi"
              cpu    = "2"
            }
          }
        }

        service = {
          type     = "NodePort"
          nodePort = 30090
        }
      }

      # Grafana configuration
      grafana = {
        enabled       = true
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

        # Disable sidecar auto-reload (as per your current config)
        sidecar = {
          dashboards = {
            enabled = false
          }
          datasources = {
            enabled = false
          }
        }
      }

      # Alertmanager configuration
      alertmanager = {
        alertmanagerSpec = {
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
        }
      }

      # Node Exporter - DaemonSet on all nodes
      nodeExporter = {
        enabled = true
      }

      # Kube State Metrics
      kubeStateMetrics = {
        enabled = true
      }

      # Disable components that need special access
      kubeEtcd = {
        enabled = false
      }
      kubeControllerManager = {
        enabled = false
      }
      kubeScheduler = {
        enabled = false
      }
    })
  ]

  depends_on = [helm_release.nfs_provisioner]
}
