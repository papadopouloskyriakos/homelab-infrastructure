***REMOVED***
# Kubernetes Dashboard
***REMOVED***
# Web UI for Kubernetes cluster management
#
# Import commands:
# tofu import 'helm_release.REDACTED_ac4dcdf5' 'REDACTED_d97cef76/REDACTED_d97cef76'
# tofu import 'REDACTED_4ad9fc99.dashboard_admin' 'REDACTED_d97cef76/dashboard-admin'
# tofu import 'REDACTED_2b73dc4c.dashboard_admin' 'dashboard-admin'
# tofu import 'kubernetes_secret.REDACTED_00f72976' 'REDACTED_d97cef76/REDACTED_c48f3618'
***REMOVED***

resource "helm_release" "REDACTED_ac4dcdf5" {
  name             = "REDACTED_d97cef76"
  repository       = "https://kubernetes.github.io/dashboard"
  chart            = "REDACTED_d97cef76"
  namespace        = "REDACTED_d97cef76"
  create_namespace = true
  version          = "7.12.0"

  values = [
    yamlencode({
      app = {
        ingress = {
          enabled = false
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

# Admin ServiceAccount for dashboard access
resource "REDACTED_4ad9fc99" "dashboard_admin" {
  metadata {
    name      = "dashboard-admin"
    namespace = "REDACTED_d97cef76"
  }

  depends_on = [helm_release.REDACTED_ac4dcdf5]
}

# ClusterRoleBinding for admin access
resource "REDACTED_2b73dc4c" "dashboard_admin" {
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
    name      = "dashboard-admin"
    namespace = "REDACTED_d97cef76"
  }

  depends_on = [REDACTED_4ad9fc99.dashboard_admin]
}

# Secret for long-lived token
resource "kubernetes_secret" "REDACTED_00f72976" {
  metadata {
    name      = "REDACTED_c48f3618"
    namespace = "REDACTED_d97cef76"
    annotations = {
      "kubernetes.io/service-account.name" = "dashboard-admin"
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [REDACTED_4ad9fc99.dashboard_admin]
}
