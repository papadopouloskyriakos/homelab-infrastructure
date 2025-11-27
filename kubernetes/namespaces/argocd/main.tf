***REMOVED***
# Argo CD - GitOps Continuous Delivery
***REMOVED***
# Provides declarative GitOps for Kubernetes applications
# UI accessible via NodePort or Ingress
***REMOVED***

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"

    labels = merge(var.common_labels, {
      "app.kubernetes.io/name"    = "argocd"
      "app.kubernetes.io/part-of" = "argocd"
    })
  }
}

# -----------------------------------------------------------------------------
# Argo CD Helm Release
# -----------------------------------------------------------------------------
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = var.REDACTED_be8b31fd
  timeout    = 600
  wait       = true

  values = [
    yamlencode({
      global = {
        domain = "argocd.${var.domain}"
      }

      server = {
        replicas = 2

        pdb = {
          enabled      = true
          minAvailable = 1
        }

        service = {
          type          = "NodePort"
          nodePortHttps = var.argocd_nodeport
        }

        ingress = {
          enabled          = var.REDACTED_84146aee
          ingressClassName = "nginx"
          hostname         = "argocd.${var.domain}"
          annotations = {
            "nginx.ingress.kubernetes.io/ssl-passthrough"  = "true"
            "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
          }
          tls = var.REDACTED_84146aee
        }

        extraArgs = var.REDACTED_649263f1 ? ["--insecure"] : []

        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      controller = {
        replicas = 1

        pdb = {
          enabled      = true
          minAvailable = 1
        }

        resources = {
          requests = {
            cpu    = "250m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "1"
            memory = "1Gi"
          }
        }
      }

      repoServer = {
        replicas = 2

        pdb = {
          enabled      = true
          minAvailable = 1
        }

        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      redis = {
        pdb = {
          enabled      = true
          minAvailable = 1
        }

        resources = {
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "128Mi"
          }
        }
      }

      applicationSet = {
        enabled  = true
        replicas = 1

        pdb = {
          enabled      = true
          minAvailable = 1
        }

        resources = {
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }

      notifications = {
        enabled = var.REDACTED_035cbec1
      }

      dex = {
        enabled = var.argocd_dex_enabled
      }

      redis-ha = {
        enabled = false
      }

      configs = {
        repositories = var.argocd_repositories

        ssh = {
          knownHosts = var.argocd_ssh_known_hosts
        }

        rbac = {
          "policy.default" = "role:readonly"
          "policy.csv"     = <<-EOT
            g, admins, role:admin
          EOT
        }

        params = {
          "server.insecure" = var.REDACTED_649263f1
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}
