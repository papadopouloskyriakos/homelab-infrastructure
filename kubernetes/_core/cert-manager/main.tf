***REMOVED***
# cert-manager
***REMOVED***

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "app.kubernetes.io/managed-by" = "opentofu"
    }
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.chart_version

  values = [yamlencode({
    installCRDs = true

    prometheus = {
      enabled = true
      servicemonitor = {
        enabled   = var.REDACTED_46d876c8
        namespace = "monitoring"
      }
    }

    resources = {
      requests = {
        cpu    = "50m"
        memory = "128Mi"
      }
      limits = {
        memory = "256Mi"
      }
    }
  })]
}

***REMOVED***
# Cloudflare API Token (via External Secrets)
***REMOVED***

resource "kubernetes_manifest" "REDACTED_cad964aa" {
  depends_on = [kubernetes_namespace.cert_manager]

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "REDACTED_fb8d60db"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "openbao"
      }
      target = {
        name = "REDACTED_fb8d60db"
      }
      data = [
        {
          secretKey = "api-token"
          remoteRef = {
            key      = "cloudflare"
            property = "api-token"
          }
        }
      ]
    }
  }
}
