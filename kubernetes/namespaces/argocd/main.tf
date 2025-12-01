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
# ExternalSecret for GitLab Repository Credentials
# -----------------------------------------------------------------------------
# Creates the repository secret BEFORE Helm release
# ArgoCD auto-discovers secrets with the repository label
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "gitlab_repo_creds" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "gitlab-repo-creds"
      namespace = kubernetes_namespace.argocd.metadata[0].name
      labels = {
        environment  = "production"
        "managed-by" = "opentofu"
      }
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "gitlab-repo-creds"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
        template = {
          metadata = {
            labels = {
              # This label is required for ArgoCD to recognize it as a repository secret
              "argocd.argoproj.io/secret-type" = "repository"
            }
          }
        }
      }
      data = [
        {
          secretKey = "username"
          remoteRef = {
            key      = "REDACTED_79b33008"
            property = "username"
          }
        },
        {
          secretKey = "password"
          remoteRef = {
            key      = "REDACTED_79b33008"
            property = "password"
          }
        },
        {
          secretKey = "url"
          remoteRef = {
            key      = "REDACTED_79b33008"
            property = "url"
          }
        },
        {
          secretKey = "type"
          remoteRef = {
            key      = "REDACTED_79b33008"
            property = "type"
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_namespace.argocd]
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

  # Ensure ExternalSecret creates the repo credentials first
  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_manifest.gitlab_repo_creds
  ]

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
}

# -----------------------------------------------------------------------------
# ExternalSecret for ArgoCD Redis Password
# -----------------------------------------------------------------------------
# Redis password stored in OpenBao for persistence across reboots
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "argocd_redis_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "argocd-redis"
      namespace = kubernetes_namespace.argocd.metadata[0].name
      labels = {
        environment  = "production"
        "managed-by" = "opentofu"
      }
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "argocd-redis"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "auth"
          remoteRef = {
            key      = "REDACTED_e4fc5799"
            property = "auth"
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_namespace.argocd]
}
