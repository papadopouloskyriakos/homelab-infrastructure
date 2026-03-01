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
    apiVersion = "external-secrets.io/v1"
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

***REMOVED***
# Wildcard Certificate - papadopoulos.tech
***REMOVED***
resource "kubernetes_manifest" "REDACTED_501d268e" {
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_e5e9325b"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_e5e9325b-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.papadopoulos.tech",
        "papadopoulos.tech"
      ]
    }
  }
}

***REMOVED***
# Wildcard Certificate - mulecube.com
***REMOVED***
resource "kubernetes_manifest" "REDACTED_c7e1769b" {
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_e8f1187c"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_e8f1187c-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.mulecube.com",
        "mulecube.com"
      ]
    }
  }
}

***REMOVED***
# Wildcard Certificate - cubeos.app
***REMOVED***
resource "kubernetes_manifest" "REDACTED_52b9873f" {
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "wildcard-cubeos-app"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_e905fc27"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.cubeos.app",
        "cubeos.app"
      ]
    }
  }
}

***REMOVED***
# RBAC for AWX to read TLS secrets
***REMOVED***
resource "kubernetes_role" "awx_cert_reader" {
  metadata {
    name      = "awx-cert-reader"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list"]
  }
}

resource "REDACTED_80c0cfc6" "awx_cert_reader" {
  metadata {
    name      = "awx-cert-reader"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.awx_cert_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "my-awx"
    namespace = "awx"
  }
}

***REMOVED***
# PushSecret - Sync wildcard certs to OpenBao for cross-cluster consumption
***REMOVED***
# NL cert-manager renews wildcard certs. These PushSecrets automatically push
# the renewed cert+key to OpenBao so the GR cluster can pull them via
# ExternalSecret. This closes the automation gap that previously required
# manual cert uploads to OpenBao after each renewal.
#
# OpenBao path: secret/REDACTED_b018f6b2 -> *.example.net
#
# Prerequisites:
#   - OpenBao policy "external-secrets" must have create/update on
#     secret/data/k8s/shared/*
***REMOVED***

resource "kubernetes_manifest" "REDACTED_13c92cba" {
  depends_on = [kubernetes_manifest.wildcard_cert]

  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "REDACTED_d5bc0c60"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
      labels = {
        "app.kubernetes.io/component"  = "cert-sync"
        "app.kubernetes.io/managed-by" = "opentofu"
      }
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRefs = [
        {
          name = "openbao"
          kind = "ClusterSecretStore"
        }
      ]
      selector = {
        secret = {
          name = "REDACTED_0d82b4df-tls"
        }
      }
      data = [
        {
          match = {
            secretKey = "tls.crt"
            remoteRef = {
              remoteKey = "REDACTED_b018f6b2"
              property  = "tls.crt"
            }
          }
        },
        {
          match = {
            secretKey = "tls.key"
            remoteRef = {
              remoteKey = "REDACTED_b018f6b2"
              property  = "tls.key"
            }
          }
        }
      ]
    }
  }
}
