***REMOVED***
# SeaweedFS Module
***REMOVED***
# Distributed storage for S3-compatible object storage
# Replaces MinIO for HA cross-site replication
***REMOVED***

terraform {
  required_providers {
    kubernetes = {
      source = "REDACTED_1158da07"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

***REMOVED***
# Namespace
***REMOVED***
resource "kubernetes_namespace" "seaweedfs" {
  metadata {
    name = "seaweedfs"
    labels = {
      "app.kubernetes.io/name"       = "seaweedfs"
      "app.kubernetes.io/managed-by" = "opentofu"
      "environment"                  = "production"
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

***REMOVED***
# ExternalSecret - S3 Credentials from OpenBao
***REMOVED***
# IMPORTANT: The secret key MUST be named "seaweedfs_s3_config" and contain
# inline JSON with the S3 identity configuration.
# 
# OpenBao path: secret/REDACTED_65baa84d
# OpenBao key: seaweedfs_s3_config
# Value format: {"identities":[{"name":"admin","credentials":[{"accessKey":"...","secretKey":"..."}],"actions":["Admin","Read","Write"]}]}
***REMOVED***
resource "kubernetes_manifest" "seaweedfs_externalsecret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "seaweedfs-s3-config"
      namespace = kubernetes_namespace.seaweedfs.metadata[0].name
      labels = {
        "app.kubernetes.io/name"       = "seaweedfs"
        "app.kubernetes.io/component"  = "s3"
        "app.kubernetes.io/managed-by" = "opentofu"
        "environment"                  = "production"
      }
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
          secretKey = "seaweedfs_s3_config"
          remoteRef = {
            key      = "REDACTED_65baa84d"
            property = "seaweedfs_s3_config"
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_namespace.seaweedfs]
}

***REMOVED***
# Helm Release - SeaweedFS
***REMOVED***
resource "helm_release" "seaweedfs" {
  name       = "seaweedfs"
  namespace  = kubernetes_namespace.seaweedfs.metadata[0].name
  repository = "https://seaweedfs.github.io/seaweedfs/helm"
  chart      = "seaweedfs"
  version    = var.REDACTED_c1342204

  timeout = 600
  wait    = true

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      storage_class       = var.storage_class
      master_storage_size = var.master_storage_size
      volume_storage_size = var.volume_storage_size
      filer_storage_size  = var.filer_storage_size
      node_region         = var.node_region
    })
  ]

  depends_on = [
    kubernetes_namespace.seaweedfs,
    kubernetes_manifest.seaweedfs_externalsecret
  ]
}

***REMOVED***
# ServiceMonitor - Prometheus Metrics
***REMOVED***
resource "kubernetes_manifest" "REDACTED_f7ae41ec" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "seaweedfs"
      namespace = kubernetes_namespace.seaweedfs.metadata[0].name
      labels = {
        "release"     = "monitoring"
        "environment" = "production"
        "managed-by"  = "opentofu"
        "repository"  = "REDACTED_25022d4e"
      }
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
