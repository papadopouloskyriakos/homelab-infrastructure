# ========================================================================
# Cilium Cluster Mesh - GR Cluster Connection
# ========================================================================
# Connects NL cluster (ID: 1) to GR cluster (ID: 2) via clustermesh
# Certificates stored in OpenBao, fetched via External Secrets
# ========================================================================

# -----------------------------------------------------------------------------
# ExternalSecret creates cilium-clustermesh directly with template
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_8d90a97d" {
  count = var.REDACTED_0333f99b ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "cilium-clustermesh"
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
        name           = "cilium-clustermesh"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
        template = {
          engineVersion = "v2"
          data = {
            "grcl01k8s"        = <<-EOT
              endpoints:
              - ${var.REDACTED_f0726f1d}
              ca-file: /var/lib/cilium/clustermesh/grcl01k8s-ca.crt
              key-file: /var/lib/cilium/clustermesh/grcl01k8s.key
              cert-file: /var/lib/cilium/clustermesh/grcl01k8s.crt
            EOT
            "grcl01k8s-ca.crt" = "{{ .ca_crt }}"
            "grcl01k8s.crt"    = "{{ .tls_crt }}"
            "grcl01k8s.key"    = "{{ .tls_key }}"
          }
        }
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
        }
      ]
    }
  }
}
