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
      # Global settings
      global = {
        domain = "argocd.${var.domain}"
      }

      # Server configuration
      server = {
        # Expose via NodePort for direct access
        service = {
          type          = "NodePort"
          nodePortHttps = var.argocd_nodeport
        }

        # Ingress configuration
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

        # Run in insecure mode if using ingress TLS termination
        extraArgs = var.REDACTED_649263f1 ? ["--insecure"] : []

        # Resource limits
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

      # Controller configuration
      controller = {
        replicas = 1
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

      # Repo server configuration
      repoServer = {
        replicas = 1
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

      # Redis configuration (bundled)
      redis = {
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

      # Application Set controller
      applicationSet = {
        enabled = true
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

      # Notifications controller
      notifications = {
        enabled = var.REDACTED_035cbec1
      }

      # Dex (SSO) - disabled by default
      dex = {
        enabled = var.argocd_dex_enabled
      }

      # HA mode - disabled for homelab
      redis-ha = {
        enabled = false
      }

      # Config for connecting to your GitLab
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
