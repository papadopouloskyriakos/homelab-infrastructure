# =============================================================================
# SeaweedFS Module
# =============================================================================
# Distributed storage for S3-compatible object storage
# Replaces MinIO for HA cross-site replication
# Filer memory limit: 2Gi (increased from 1Gi, failed Helm release cleaned up 2026-03-15)
# =============================================================================

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

# =============================================================================
# Namespace
# =============================================================================
resource "REDACTED_46569c16" "seaweedfs" {
  metadata {
    name = "seaweedfs"
    labels = {
      "app.kubernetes.io/name"             = "seaweedfs"
      "app.kubernetes.io/managed-by"       = "opentofu"
      "environment"                        = "production"
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

# =============================================================================
# ExternalSecret - S3 Credentials from OpenBao
# =============================================================================
resource "kubernetes_manifest" "seaweedfs_externalsecret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "seaweedfs-s3-config"
      namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
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
  depends_on = [REDACTED_46569c16.seaweedfs]
}

# =============================================================================
# Helm Release - SeaweedFS
# =============================================================================
resource "helm_release" "seaweedfs" {
  name       = "seaweedfs"
  namespace  = REDACTED_46569c16.seaweedfs.metadata[0].name
  repository = "https://seaweedfs.github.io/seaweedfs/helm"
  chart      = "seaweedfs"
  version    = var.REDACTED_c1342204

  timeout = 600
  wait    = true

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      storage_class                 = var.storage_class_retain
      master_storage_size           = var.master_storage_size
      volume_storage_size           = var.volume_storage_size
      REDACTED_0a7b20f8 = var.REDACTED_0a7b20f8
      filer_storage_size            = var.filer_storage_size
      node_region                   = var.node_region
      filer_store                   = var.filer_store
    })
  ]

  depends_on = [
    REDACTED_46569c16.seaweedfs,
    kubernetes_manifest.seaweedfs_externalsecret
  ]
}

# =============================================================================
# ServiceMonitor - Prometheus Metrics
# =============================================================================
resource "kubernetes_manifest" "REDACTED_f7ae41ec" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "seaweedfs"
      namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
      labels = {
        "release"     = "monitoring"
        "environment" = "production"
        "managed-by"  = "opentofu"
        "repository"  = var.repository_label
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

# =============================================================================
# PodDisruptionBudgets — protect availability during voluntary disruptions
# =============================================================================
resource "REDACTED_e0540b90" "seaweedfs_master" {
  metadata {
    name      = "seaweedfs-master"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
    labels = {
      "app.kubernetes.io/name"       = "seaweedfs"
      "app.kubernetes.io/component"  = "master"
      "app.kubernetes.io/managed-by" = "opentofu"
      "environment"                  = "production"
    }
  }
  spec {
    min_available = "2"
    selector {
      match_labels = {
        "app.kubernetes.io/name"      = "seaweedfs"
        "app.kubernetes.io/component" = "master"
        "app.kubernetes.io/instance"  = "seaweedfs"
      }
    }
  }
  depends_on = [helm_release.seaweedfs]
}

resource "REDACTED_e0540b90" "seaweedfs_filer" {
  metadata {
    name      = "seaweedfs-filer"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
    labels = {
      "app.kubernetes.io/name"       = "seaweedfs"
      "app.kubernetes.io/component"  = "filer"
      "app.kubernetes.io/managed-by" = "opentofu"
      "environment"                  = "production"
    }
  }
  spec {
    min_available = "1"
    selector {
      match_labels = {
        "app.kubernetes.io/name"      = "seaweedfs"
        "app.kubernetes.io/component" = "filer"
        "app.kubernetes.io/instance"  = "seaweedfs"
      }
    }
  }
  depends_on = [helm_release.seaweedfs]
}

resource "REDACTED_e0540b90" "seaweedfs_volume" {
  metadata {
    name      = "seaweedfs-volume"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
    labels = {
      "app.kubernetes.io/name"       = "seaweedfs"
      "app.kubernetes.io/component"  = "volume"
      "app.kubernetes.io/managed-by" = "opentofu"
      "environment"                  = "production"
    }
  }
  spec {
    min_available = "1"
    selector {
      match_labels = {
        "app.kubernetes.io/name"      = "seaweedfs"
        "app.kubernetes.io/component" = "volume"
        "app.kubernetes.io/instance"  = "seaweedfs"
      }
    }
  }
  depends_on = [helm_release.seaweedfs]
}

# =============================================================================
# Ingress for Web UI access
# =============================================================================
resource "kubernetes_ingress_v1" "seaweedfs_master" {
  metadata {
    name      = "seaweedfs-master"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  spec {
    rule {
      host = var.master_hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "seaweedfs-master"
              port {
                number = 9333
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "seaweedfs_s3" {
  metadata {
    name      = "seaweedfs-s3"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                 = "nginx"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
      # IFRNLLEI01PRD-2605 — stream S3 bodies, do not spool them in nginx.
      # With default response buffering, GETs of large objects (the 2GB barman
      # base tars) were spooled to nginx temp files and TRUNCATED at variable
      # power-of-two-ish offsets with a clean EOF — the barman restore drill
      # failed on it from both sides while direct-to-filer streamed the full
      # object. Request buffering off likewise takes nginx temp spooling out
      # of the upload path (barman/velero/etcd-snapshot writers ride this
      # hostname). Timeouts sized for slow cross-site WAN restores.
      # ModSecurity's body filter TRUNCATES large streamed responses (proven
      # 2026-08-23: the 2GB barman base tar cut at exactly 512MiB with ModSec
      # on, complete in 43s with it off — "DetectionOnly" is not passive on
      # the data plane). Its CRS web rules only produce noise on sigv4
      # machine traffic; the WAF stays on for every other vhost.
      "nginx.ingress.kubernetes.io/enable-modsecurity"       = "false"
      "nginx.ingress.kubernetes.io/proxy-buffering"          = "off"
      "nginx.ingress.kubernetes.io/proxy-request-buffering"  = "off"
      "nginx.ingress.kubernetes.io/proxy-max-temp-file-size" = "0"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"       = "1800"
      "nginx.ingress.kubernetes.io/proxy-send-timeout"       = "1800"
      # OMOIKANE-1510 — pin every s3 request to ONE filer replica.
      #
      # seaweedfs-filer fronts filer-0 and filer-1, which keep their own leveldb2
      # metadata and reconcile asynchronously via meta_aggregator. Round-robin
      # therefore lets restic DELETE a lock through one replica and LIST through
      # the other before the aggregator has caught up, so `restic unlock` reports
      # a clean repo while the lock is still visible — the false all-clear behind
      # OMOIKANE-1489's 81-day silent retention outage.
      #
      # Hashing on a constant ($host) makes the choice deterministic instead of
      # per-request. nginx still fails over if the chosen replica is unavailable,
      # so this costs redundancy only during the failover itself. Measured before
      # and after on 20 requests: both replicas served (315/125) before, one
      # served and the other took zero after.
      "nginx.ingress.kubernetes.io/upstream-hash-by" = "$host"
    }
  }
  spec {
    rule {
      host = var.s3_hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "seaweedfs-filer"
              port {
                number = 8333
              }
            }
          }
        }
      }
    }
  }
}
