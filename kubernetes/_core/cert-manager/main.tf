# =============================================================================
# cert-manager
# =============================================================================
# Role-gated module (NL<->GR mirror campaign, 2026-08-16):
#   - var.acme_issuer_enabled = true  (NL): this cluster RUNS the ACME issuer
#     stack — ClusterIssuer, Cloudflare ExternalSecret, all Certificates, the
#     PushSecret that publishes the wildcard cert to OpenBao, and the AWX RBAC.
#   - var.acme_issuer_enabled = false (GR): this cluster CONSUMES the wildcard
#     cert from OpenBao via an ExternalSecret (pushed by the NL PushSecret).
# CRD ownership is asymmetric-by-history — see var.install_crds.
# =============================================================================
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "app.kubernetes.io/managed-by" = "opentofu"
    }
  }
}

locals {
  # dns01 recursive-nameserver pinning only matters where the ACME issuer runs
  # (self-check of DNS-01 propagation). Helm values cannot be count-gated, so
  # the keys are merged in conditionally. List-expansion form (not an inline
  # `? {..} : {}` conditional) is deliberate: the inline conditional unifies
  # both branches to map(string) and silently stringifies the bool ("true"),
  # while `[{..}] : []` preserves types.
  acme_dns01_values = var.acme_issuer_enabled ? [{
    dns01RecursiveNameservers     = "1.1.1.1:53,1.0.0.1:53"
    dns01RecursiveNameserversOnly = true
  }] : []
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.chart_version
  values = [yamlencode(merge(
    {
      # Modern chart keys (1.15+). `installCRDs` is the deprecated alias and the
      # chart FAILS if it is combined with any crds.* key — never reintroduce it.
      # keep=true is the chart default, pinned explicitly: it stamps
      # `helm.sh/resource-policy: keep` on rendered CRDs, so even a mistaken
      # flip of install_crds true->false cannot make a helm upgrade delete the
      # CRDs (and with them every Certificate/Issuer in the cluster).
      crds = {
        enabled = var.install_crds
        keep    = true
      }
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
      webhook = {
        resources = {
          requests = {
            cpu    = "25m"
            memory = "32Mi"
          }
        }
      }
      cainjector = {
        resources = {
          requests = {
            cpu    = "25m"
            memory = "64Mi"
          }
        }
      }
    },
    local.acme_dns01_values...
  ))]
}

# =============================================================================
# Cloudflare API Token (via External Secrets) — ACME issuer role only
# =============================================================================
resource "kubernetes_manifest" "REDACTED_cad964aa" {
  count      = var.acme_issuer_enabled ? 1 : 0
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

# =============================================================================
# ClusterIssuer - Let's Encrypt Production — ACME issuer role only
# =============================================================================
resource "kubernetes_manifest" "letsencrypt_prod" {
  count      = var.acme_issuer_enabled ? 1 : 0
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

# =============================================================================
# Wildcard Certificate
# =============================================================================
resource "kubernetes_manifest" "wildcard_cert" {
  count      = var.acme_issuer_enabled ? 1 : 0
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

# =============================================================================
# Wildcard Certificate - papadopoulos.tech
# =============================================================================
resource "kubernetes_manifest" "REDACTED_501d268e" {
  count      = var.acme_issuer_enabled ? 1 : 0
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

# =============================================================================
# Wildcard Certificate - mulecube.com
# =============================================================================
resource "kubernetes_manifest" "REDACTED_c7e1769b" {
  count      = var.acme_issuer_enabled ? 1 : 0
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

# =============================================================================
# Wildcard Certificate - cubeos.app
# =============================================================================
resource "kubernetes_manifest" "REDACTED_52b9873f" {
  count      = var.acme_issuer_enabled ? 1 : 0
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

# =============================================================================
# Wildcard Certificate - meshsat.net
# =============================================================================
resource "kubernetes_manifest" "REDACTED_b497be54" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_6b2b1d03"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_6b2b1d03-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.meshsat.net",
        "meshsat.net"
      ]
    }
  }
}

# =============================================================================
# Wildcard Certificate - meshsat.org
# =============================================================================
resource "kubernetes_manifest" "REDACTED_8e7851d8" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_f751a1db"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_f751a1db-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.meshsat.org",
        "meshsat.org"
      ]
    }
  }
}

# =============================================================================
# Wildcard Certificate - mulecube.net
# =============================================================================
resource "kubernetes_manifest" "REDACTED_cbe107a9" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_b48b36cd"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_b48b36cd-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.mulecube.net",
        "mulecube.net"
      ]
    }
  }
}

# =============================================================================
# Wildcard Certificate - mulecube.org
# =============================================================================
resource "kubernetes_manifest" "REDACTED_62f27f39" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_3afb42ed"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_3afb42ed-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.mulecube.org",
        "mulecube.org"
      ]
    }
  }
}

# =============================================================================
# Wildcard Certificate - mail.example.net
# =============================================================================
resource "kubernetes_manifest" "REDACTED_a6df7556" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "wildcard-mxmx-email"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_7f4f46e4"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.mail.example.net",
        "mail.example.net"
      ]
    }
  }
}

# =============================================================================
# Wildcard Certificate - withelli.com
# =============================================================================
resource "kubernetes_manifest" "REDACTED_56d1f068" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_b2fe5f0b"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_b2fe5f0b-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.withelli.com",
        "withelli.com"
      ]
    }
  }
}

# =============================================================================
# Wildcard Certificate - omoikane.coach
# =============================================================================
resource "kubernetes_manifest" "REDACTED_af7e0fe5" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_eb368cbd"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_eb368cbd-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.omoikane.coach",
        "omoikane.coach"
      ]
    }
  }
}

# =============================================================================
# Wildcard Certificate - omoikane.careers
# =============================================================================
resource "kubernetes_manifest" "REDACTED_93434549" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_21a6c4fc"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_21a6c4fc-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.omoikane.careers",
        "omoikane.careers"
      ]
    }
  }
}

# =============================================================================
# Wildcard Certificate - omoikane.nl
# =============================================================================
resource "kubernetes_manifest" "REDACTED_5e8d96e9" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_b4121ee5"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_b4121ee5-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.omoikane.nl",
        "omoikane.nl"
      ]
    }
  }
}

# =============================================================================
# Wildcard Certificate - omoikane.tech
# =============================================================================
resource "kubernetes_manifest" "REDACTED_79a1dc6b" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_d39fbd43"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_d39fbd43-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.omoikane.tech",
        "omoikane.tech"
      ]
    }
  }
}

# =============================================================================
# Wildcard Certificate - omoikane.gr
# =============================================================================
resource "kubernetes_manifest" "REDACTED_b082092e" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_983d7ee1"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_983d7ee1-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.omoikane.gr",
        "omoikane.gr"
      ]
    }
  }
}

# =============================================================================
# RBAC for AWX to read TLS secrets — ACME issuer role only
# =============================================================================
resource "kubernetes_role" "awx_cert_reader" {
  count = var.acme_issuer_enabled ? 1 : 0
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
  count = var.acme_issuer_enabled ? 1 : 0
  metadata {
    name      = "awx-cert-reader"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.awx_cert_reader[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "my-awx"
    namespace = "awx"
  }
}

# =============================================================================
# PushSecret - Sync wildcard certs to OpenBao for cross-cluster consumption
# =============================================================================
# NL cert-manager renews wildcard certs. These PushSecrets automatically push
# the renewed cert+key to OpenBao so the GR cluster can pull them via
# ExternalSecret. This closes the automation gap that previously required
# manual cert uploads to OpenBao after each renewal.
#
# OpenBao path: REDACTED_2812d784 -> *.example.net
#
# Prerequisites:
#   - OpenBao policy "external-secrets" must have create/update on
#     secret/data/k8s/shared/*
# =============================================================================

resource "kubernetes_manifest" "REDACTED_13c92cba" {
  count      = var.acme_issuer_enabled ? 1 : 0
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

# OMOIKANE-1623 (2026-08-18): the omoikane platform now runs on the notrf01 k8s
# cluster; its ingress-nginx consumes *.omoikane.coach via an ExternalSecret
# reading REDACTED_a359c22f. This PushSecret closes the
# renewal loop: NL cert-manager renews -> OpenBao -> notrf01 ESO -> ingress.
# (The AWX daily cert distribution still feeds the edge VPS HAProxy files.)
resource "kubernetes_manifest" "REDACTED_2663285d" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.wildcard_cert]

  manifest = {
    apiVersion = "external-secrets.io/v1alpha1"
    kind       = "PushSecret"
    metadata = {
      name      = "REDACTED_207ca5bf"
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
          name = "REDACTED_eb368cbd-tls"
        }
      }
      data = [
        {
          match = {
            secretKey = "tls.crt"
            remoteRef = {
              remoteKey = "REDACTED_a359c22f"
              property  = "tls.crt"
            }
          }
        },
        {
          match = {
            secretKey = "tls.key"
            remoteRef = {
              remoteKey = "REDACTED_a359c22f"
              property  = "tls.key"
            }
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "REDACTED_8ca647ff" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_b21912a4"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_b21912a4-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "territorygrounder.ai", "www.territorygrounder.ai",
        "territorygrounder.dev", "www.territorygrounder.dev",
        "territorygrounder.io", "www.territorygrounder.io",
        "territorygrounder.org", "www.territorygrounder.org"
      ]
    }
  }
}

resource "kubernetes_manifest" "REDACTED_233e2f0b" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_7dede78a"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_7dede78a-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.territorygrounder.com",
        "territorygrounder.com"
      ]
    }
  }
}

# Wildcard Certificate - groundnet.net
resource "kubernetes_manifest" "REDACTED_7a64a702" {
  count      = var.acme_issuer_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.letsencrypt_prod]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "REDACTED_9774d43a"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      secretName = "REDACTED_9774d43a-tls"
      issuerRef = {
        name = "letsencrypt-prod"
        kind = "ClusterIssuer"
      }
      dnsNames = [
        "*.groundnet.net",
        "groundnet.net"
      ]
    }
  }
}

# =============================================================================
# ExternalSecret - consume wildcard cert from OpenBao — CONSUMER role only
# =============================================================================
# The issuer cluster's PushSecret (above) publishes the renewed wildcard
# cert+key to OpenBao; the consumer cluster materialises it here as a
# kubernetes.io/tls secret under the same name the issuer cluster uses, so
# every downstream reference (ingress default cert, AWX cert sync, ...) is
# site-agnostic. deletionPolicy Retain: the cert must survive ESO restarts.
# =============================================================================
resource "kubernetes_manifest" "REDACTED_c665cfe3" {
  count = var.acme_issuer_enabled ? 0 : 1
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "wildcard-cert"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        kind = "ClusterSecretStore"
        name = "openbao"
      }
      target = {
        name = "REDACTED_0d82b4df-tls"
        template = {
          type = "kubernetes.io/tls"
          data = {
            "tls.crt" = "{{ .tlscrt }}"
            "tls.key" = "{{ .tlskey }}"
          }
        }
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "tlscrt"
          remoteRef = {
            key      = var.wildcard_cert_path
            property = "tls.crt"
          }
        },
        {
          secretKey = "tlskey"
          remoteRef = {
            key      = var.wildcard_cert_path
            property = "tls.key"
          }
        }
      ]
    }
  }

  depends_on = [helm_release.cert_manager]
}
