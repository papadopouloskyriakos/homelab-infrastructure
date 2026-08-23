# =============================================================================
# SeaweedFS filer metadata store — shared CNPG Postgres (IFRNLLEI01PRD-2605)
#
# Why: per-filer leveldb2 stores are the root enabler of the 2026 object-
# corruption class (IFRNLLEI01PRD-2090 signatures). Two filers with private
# embedded stores, reconciled by the async meta-aggregator, can commit
# inconsistent chunk lists under stalled-PUT client retries; leveldb has no
# crash story (gr filer leveldb damage, 2026-08-16). One shared postgres2
# store makes both filers stateless readers of a single transactional truth —
# the upstream-supported multi-filer pattern.
#
# Sequencing: enable filer_meta_db_enabled and verify this cluster healthy
# BEFORE flipping filer_store = "postgres2" (values.yaml.tpl). The CNPG CRDs
# must already exist (cnpg_enabled) or kubernetes_manifest fails at PLAN time
# (greenfield lesson, IFRNLLEI01PRD-2403).
#
# Replication is 2-instance ASYNC (no minSyncReplicas): with only one replica,
# synchronous commit would block ALL S3 metadata writes whenever the replica
# is down — an availability trade this store cannot afford. Failover RPO is
# milliseconds, strictly better than the leveldb crash story it replaces.
#
# Backup: barman base+WAL to the OTHER site's S3 — never into the S3 this DB
# serves (a filer-meta restore must not depend on the filer being up).
# =============================================================================

resource "kubernetes_manifest" "filer_meta_cluster" {
  count = var.filer_meta_db_enabled ? 1 : 0

  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name      = "seaweedfs-filer-meta"
      namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
      labels = {
        "app.kubernetes.io/name"       = "seaweedfs"
        "app.kubernetes.io/component"  = "filer-meta"
        "app.kubernetes.io/managed-by" = "opentofu"
        "environment"                  = "production"
      }
    }
    spec = merge(
      {
        instances             = 2
        primaryUpdateStrategy = "unsupervised"
        bootstrap = {
          initdb = {
            database = "seaweedfs_filer"
            owner    = "filer"
          }
        }
        storage = {
          size         = "10Gi"
          storageClass = var.storage_class_retain
        }
        resources = {
          requests = {
            cpu    = "50m"
            memory = "256Mi"
          }
          limits = {
            memory = "1Gi"
          }
        }
        affinity = {
          enablePodAntiAffinity = true
          topologyKey           = "kubernetes.io/hostname"
        }
      },
      var.REDACTED_5c69828e != "" ? {
        backup = {
          barmanObjectStore = {
            destinationPath = "s3://${var.REDACTED_5514fdd1}"
            endpointURL     = var.REDACTED_5c69828e
            s3Credentials = {
              accessKeyId = {
                name = "REDACTED_073f5849"
                key  = "ACCESS_KEY_ID"
              }
              secretAccessKey = {
                name = "REDACTED_073f5849"
                key  = "ACCESS_SECRET_KEY"
              }
            }
            wal = {
              compression = "gzip"
            }
          }
          retentionPolicy = "14d"
        }
      } : {}
    )
  }

  depends_on = [REDACTED_46569c16.seaweedfs]
}

# Nightly base backup at 01:30 UTC — before the 02:00 velero window, so the
# cross-site WAN transfer does not stack on the backup pile-up.
resource "kubernetes_manifest" "REDACTED_fe4f6c90" {
  count = var.filer_meta_db_enabled && var.REDACTED_5c69828e != "" ? 1 : 0

  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "ScheduledBackup"
    metadata = {
      name      = "REDACTED_e70fed1b"
      namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
      labels = {
        "app.kubernetes.io/name"       = "seaweedfs"
        "app.kubernetes.io/component"  = "filer-meta"
        "app.kubernetes.io/managed-by" = "opentofu"
        "environment"                  = "production"
      }
    }
    spec = {
      schedule             = "0 30 1 * * *"
      backupOwnerReference = "self"
      cluster = {
        name = "seaweedfs-filer-meta"
      }
    }
  }

  depends_on = [kubernetes_manifest.filer_meta_cluster]
}

# Cross-site S3 credentials for barman (OpenBao REDACTED_86ac77cc;
# the identity itself belongs in the TARGET site's canonical s3-credentials JSON —
# never live-only, per the 2026-08-19 vanished-barman-identity lesson).
resource "kubernetes_manifest" "REDACTED_8eb77a2b" {
  count = var.filer_meta_db_enabled && var.REDACTED_5c69828e != "" ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "REDACTED_073f5849"
      namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
      labels = {
        "app.kubernetes.io/name"       = "seaweedfs"
        "app.kubernetes.io/component"  = "filer-meta"
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
        name           = "REDACTED_073f5849"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "ACCESS_KEY_ID"
          remoteRef = {
            key      = "REDACTED_86ac77cc"
            property = "ACCESS_KEY_ID"
          }
        },
        {
          secretKey = "ACCESS_SECRET_KEY"
          remoteRef = {
            key      = "REDACTED_86ac77cc"
            property = "ACCESS_SECRET_KEY"
          }
        }
      ]
    }
  }

  depends_on = [REDACTED_46569c16.seaweedfs]
}
