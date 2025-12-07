# ========================================================================
# Cilium Cluster Mesh - GR Cluster Connection
# ========================================================================
# Connects NL cluster (ID: 1) to GR cluster (ID: 2) via clustermesh
# Certificates stored in OpenBao, fetched via External Secrets
# ========================================================================

# -----------------------------------------------------------------------------
# ExternalSecret for GR Cluster Certificates
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "clustermesh_gr_external_secret" {
  count = var.REDACTED_0333f99b ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "clustermesh-gr-credentials"
      namespace = "kube-system"
      labels = {
        "app.kubernetes.io/name"       = "cilium-clustermesh"
        "app.kubernetes.io/component"  = "clustermesh"
        "app.kubernetes.io/managed-by" = "opentofu"
      }
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "clustermesh-gr-credentials"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "ca_crt"
          remoteRef = {
            key      = "REDACTED_28041018"
            property = "ca_crt"
          }
        },
        {
          secretKey = "tls_crt"
          remoteRef = {
            key      = "REDACTED_28041018"
            property = "tls_crt"
          }
        },
        {
          secretKey = "tls_key"
          remoteRef = {
            key      = "REDACTED_28041018"
            property = "tls_key"
          }
        },
        {
          secretKey = "endpoint"
          remoteRef = {
            key      = "REDACTED_28041018"
            property = "endpoint"
          }
        }
      ]
    }
  }
}

# -----------------------------------------------------------------------------
# Cilium Clustermesh Secret
# Uses data source to read ExternalSecret-created secret
# -----------------------------------------------------------------------------
data "kubernetes_secret" "clustermesh_gr_credentials" {
  count = var.REDACTED_0333f99b ? 1 : 0

  metadata {
    name      = "clustermesh-gr-credentials"
    namespace = "kube-system"
  }

  depends_on = [kubernetes_manifest.clustermesh_gr_external_secret]
}

resource "kubernetes_secret" "cilium_clustermesh" {
  count = var.REDACTED_0333f99b ? 1 : 0

  metadata {
    name      = "cilium-clustermesh"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"       = "cilium-clustermesh"
      "app.kubernetes.io/managed-by" = "opentofu"
    }
  }

  data = {
    "grcl01k8s" = <<-EOT
      endpoints:
      - ${var.REDACTED_f0726f1d}
      ca-file: /var/lib/cilium/clustermesh/grcl01k8s-ca.crt
      key-file: /var/lib/cilium/clustermesh/grcl01k8s.key
      cert-file: /var/lib/cilium/clustermesh/grcl01k8s.crt
    EOT

    "grcl01k8s-ca.crt" = data.kubernetes_secret.clustermesh_gr_credentials[0].data["ca_crt"]
    "grcl01k8s.crt"    = data.kubernetes_secret.clustermesh_gr_credentials[0].data["tls_crt"]
    "grcl01k8s.key"    = data.kubernetes_secret.clustermesh_gr_credentials[0].data["tls_key"]
  }

  type = "Opaque"

  depends_on = [data.kubernetes_secret.clustermesh_gr_credentials]
}
