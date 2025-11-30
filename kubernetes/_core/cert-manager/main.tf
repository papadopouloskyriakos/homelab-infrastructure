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
    installCRDs                   = false
    dns01RecursiveNameservers     = "1.1.1.1:53,1.0.0.1:53"
    dns01RecursiveNameserversOnly = true
    prometheus = {
      enabled = true
      servicemonitor = {
        enabled   = var.REDACTED_46d876c8
        namespace = "monitoring"
        labels = {
          release = "monitoring"
        }
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
            key      = "ci/cloudflare"
            property = "api-token"
          }
        }
      ]
    }
  }
}
***REMOVED***
# ClusterIssuer - Let's Encrypt Production
***REMOVED***
resource "kubernetes_manifest" "letsencrypt_prod" {
  depends_on = [helm_release.cert_manager]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.acme_email
        privateKeySecretRef = {
          name = "REDACTED_47c187d7"
        }
        solvers = [
          {
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = "REDACTED_fb8d60db"
                  key  = "api-token"
                }
              }
            }
          }
        ]
      }
    }
  }
}
***REMOVED***
# Wildcard Certificate
***REMOVED***
resource "kubernetes_manifest" "wildcard_cert" {
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_0d82b4df"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_0d82b4df-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.example.net",
        "example.net"
      ]
    }
  }
}
