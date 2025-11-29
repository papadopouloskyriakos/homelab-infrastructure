# ========================================================================
# Synology CSI Driver Module - nl-nas01 (DS1621+)
# ========================================================================
# Deploys Synology CSI driver for iSCSI block storage
# Uses community Helm chart: christian-schlichtherle/synology-csi-chart
# ========================================================================

terraform {
  required_providers {
    kubernetes = {
      source  = "REDACTED_1158da07"
      version = ">= 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
  }
}

# -------------------------------------------------------------------------
# Namespace
# -------------------------------------------------------------------------
resource "kubernetes_namespace" "synology_csi" {
  metadata {
    name = "synology-csi"

    labels = {
      "app.kubernetes.io/name"             = "synology-csi"
      "app.kubernetes.io/managed-by"       = "opentofu"
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

# -------------------------------------------------------------------------
# Secret for DSM Connection
# -------------------------------------------------------------------------
resource "kubernetes_secret" "client_info" {
  metadata {
    name      = "client-info-secret"
    namespace = kubernetes_namespace.synology_csi.metadata[0].name
  }

  data = {
    "client-info.yaml" = yamlencode({
      clients = [
        {
          host     = var.synology_host
          port     = var.synology_port
          https    = var.synology_https
          username = var.synology_username
          password = var.synology_password
        }
      ]
    })
  }
}

# -------------------------------------------------------------------------
# Helm Release - Synology CSI Driver
# -------------------------------------------------------------------------
resource "helm_release" "synology_csi" {
  name       = "synology-csi"
  namespace  = kubernetes_namespace.synology_csi.metadata[0].name
  repository = "https://christian-schlichtherle.github.io/synology-csi-chart"
  chart      = "synology-csi"
  version    = var.chart_version

  wait    = true
  timeout = 600

  set = [
    {
      name  = "clientInfoSecret.name"
      value = kubernetes_secret.client_info.metadata[0].name
    },
  ]

  values = [
    yamlencode({
      storageClasses = {
        "nl-nas01-iscsi-retain" = {
          isDefault     = false
          reclaimPolicy = "Retain"
          parameters = {
            fsType   = var.fs_type
            dsm      = var.synology_host
            location = var.REDACTED_add7f998
          }
        }
        "nl-nas01-iscsi-delete" = {
          isDefault     = false
          reclaimPolicy = "Delete"
          parameters = {
            fsType   = var.fs_type
            dsm      = var.synology_host
            location = var.REDACTED_add7f998
          }
        }
      }

      volumeSnapshotClasses = var.enable_snapshots ? {
        "nl-nas01-snapclass" = {
          isDefault      = false
          deletionPolicy = "Delete"
        }
      } : {}

      controller = {
        replicaCount = 1
      }

      node = {
        tolerations = [
          {
            operator = "Exists"
          }
        ]
      }
    })
  ]

  depends_on = [kubernetes_secret.client_info]
}

# -------------------------------------------------------------------------
# VolumeSnapshotClass for Velero Integration
# -------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_95129f63" {
  count = var.enable_snapshots && var.enable_velero_integration ? 1 : 0

  manifest = {
    apiVersion = "snapshot.storage.k8s.io/v1"
    kind       = "VolumeSnapshotClass"
    metadata = {
      name = "nl-nas01-velero-snapclass"
      labels = {
        "velero.io/csi-volumesnapshot-class" = "true"
      }
    }
    driver         = "csi.san.synology.com"
    deletionPolicy = "Retain"
    parameters = {
      description = "Kubernetes CSI Snapshot for Velero"
    }
  }

  depends_on = [helm_release.synology_csi]
}
