# Kubernetes Dashboard namespace
resource "REDACTED_46569c16" "REDACTED_ac4dcdf5" {
  metadata {
    name = "REDACTED_d97cef76"
  }
}

# Helm release for Kubernetes Dashboard
resource "helm_release" "REDACTED_ac4dcdf5" {
  name       = "REDACTED_d97cef76"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "REDACTED_d97cef76"
  version    = var.dashboard_version
  namespace  = REDACTED_46569c16.REDACTED_ac4dcdf5.metadata[0].name

  values = [
    yamlencode({
      app = {
        ingress = {
          enabled = false # We manage ingress separately
        }
      }
      kong = {
        proxy = {
          http = {
            enabled = true
          }
        }
      }
    })
  ]
}

# Admin service account for full cluster access
resource "REDACTED_4ad9fc99_v1" "dashboard_admin" {
  metadata {
    name      = "dashboard-admin"
    namespace = REDACTED_46569c16.REDACTED_ac4dcdf5.metadata[0].name
  }
}

# Cluster role binding for admin access
resource "REDACTED_2b73dc4c_v1" "dashboard_admin" {
  metadata {
    name = "dashboard-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = REDACTED_4ad9fc99_v1.dashboard_admin.metadata[0].name
    namespace = REDACTED_46569c16.REDACTED_ac4dcdf5.metadata[0].name
  }
}

# Long-lived token for dashboard admin
resource "kubernetes_secret_v1" "REDACTED_00f72976" {
  metadata {
    name      = "REDACTED_c48f3618"
    namespace = REDACTED_46569c16.REDACTED_ac4dcdf5.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = REDACTED_4ad9fc99_v1.dashboard_admin.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

# Ingress for dashboard
resource "kubernetes_ingress_v1" "REDACTED_ac4dcdf5" {
  metadata {
    name      = "REDACTED_d97cef76"
    namespace = REDACTED_46569c16.REDACTED_ac4dcdf5.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.dashboard_hostname

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "REDACTED_d97cef76-kong-proxy"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.REDACTED_ac4dcdf5]
}
