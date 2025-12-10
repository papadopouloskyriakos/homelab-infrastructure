***REMOVED***
# SeaweedFS - Distributed Object Storage
***REMOVED***
# Replaces MinIO with HA cross-site capable S3 storage
# S3 API: http://seaweedfs-filer.seaweedfs.svc.cluster.local:8333
***REMOVED***

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------
resource "kubernetes_namespace" "seaweedfs" {
  metadata {
    name = "seaweedfs"
    labels = merge(var.common_labels, {
      "app.kubernetes.io/name" = "seaweedfs"
    })
  }
}

# -----------------------------------------------------------------------------
# S3 Credentials Secret (via External Secrets Operator)
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "seaweedfs_s3_credentials" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "seaweedfs-s3-config"
      namespace = kubernetes_namespace.seaweedfs.metadata[0].name
      labels    = var.common_labels
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "seaweedfs-s3-config"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "admin_access_key_id"
          remoteRef = {
            key      = "secret/REDACTED_65baa84d"
            property = "admin-access-key"
          }
        },
        {
          secretKey = "admin_secret_access_key"
          remoteRef = {
            key      = "secret/REDACTED_65baa84d"
            property = "admin-secret-key"
          }
        }
      ]
    }
  }
}

# -----------------------------------------------------------------------------
# SeaweedFS Helm Release
# -----------------------------------------------------------------------------
resource "helm_release" "seaweedfs" {
  name       = "seaweedfs"
  namespace  = kubernetes_namespace.seaweedfs.metadata[0].name
  repository = "https://seaweedfs.github.io/seaweedfs/helm"
  chart      = "seaweedfs"
  version    = var.REDACTED_c1342204

  timeout = 600
  wait    = true

  depends_on = [kubernetes_manifest.seaweedfs_s3_credentials]

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      storage_class       = var.storage_class
      master_storage_size = var.master_storage_size
      volume_storage_size = var.volume_storage_size
      filer_storage_size  = var.filer_storage_size
      node_region         = var.node_region
    })
  ]
}

# -----------------------------------------------------------------------------
# ServiceMonitor for Prometheus
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_f7ae41ec" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "seaweedfs"
      namespace = kubernetes_namespace.seaweedfs.metadata[0].name
      labels = merge(var.common_labels, {
        release = "monitoring"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "seaweedfs"
        }
      }
      endpoints = [
        {
          port     = "metrics"
          path     = "/metrics"
          interval = "30s"
        }
      ]
    }
  }

  depends_on = [helm_release.seaweedfs]
}
