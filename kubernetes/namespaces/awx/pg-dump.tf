# =============================================================================
# AWX Postgres dump lane (IFRNLLEI01PRD-2605 phase 5)
#
# The AWX operator's CRD exposes no path to annotate the postgres StatefulSet
# pod template, so the opt-in Velero flip would silently drop the one precious
# AWX volume (job history, credentials, inventories). Instead: a nightly
# application-consistent pg_dump to the site S3 bucket awx-pg-dumps
# (identity awx-pg-dumps in the canonical seaweedfs s3-credentials JSON;
# creds at OpenBao k8s/awx/pg-dump-s3), keep newest 14.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_7d10896b" {
  count = var.REDACTED_18d47a8b ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "awx-pg-dump-s3"
      namespace = kubernetes_namespace.awx.metadata[0].name
      labels    = var.common_labels
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "awx-pg-dump-s3"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "ACCESS_KEY_ID"
          remoteRef = {
            key      = "k8s/awx/pg-dump-s3"
            property = "ACCESS_KEY_ID"
          }
        },
        {
          secretKey = "ACCESS_SECRET_KEY"
          remoteRef = {
            key      = "k8s/awx/pg-dump-s3"
            property = "ACCESS_SECRET_KEY"
          }
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "awx_pg_dump_cronjob" {
  count = var.REDACTED_18d47a8b ? 1 : 0

  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name      = "awx-pg-dump"
      namespace = kubernetes_namespace.awx.metadata[0].name
      labels    = var.common_labels
    }
    spec = {
      # 04:15 UTC — outside the 01:15-03:30 backup pile-up window.
      schedule                   = "15 4 * * *"
      concurrencyPolicy          = "Forbid"
      successfulJobsHistoryLimit = 3
      failedJobsHistoryLimit     = 3
      jobTemplate = {
        spec = {
          backoffLimit          = 2
          activeDeadlineSeconds = 1800
          template = {
            metadata = {
              labels = { "app.kubernetes.io/name" = "awx-pg-dump" }
            }
            spec = {
              restartPolicy = "Never"
              volumes       = [{ name = "work", emptyDir = {} }]
              initContainers = [
                {
                  name    = "dump"
                  image   = "postgres:15-alpine"
                  command = ["sh", "-ec", "pg_dump -Fc -f /work/awx-$(date +%Y%m%d-%H%M).dump && ls -la /work"]
                  env = [
                    { name = "PGHOST", valueFrom = { REDACTED_5dfff400 = { name = "REDACTED_31fbdf51", key = "host" } } },
                    { name = "PGPORT", valueFrom = { REDACTED_5dfff400 = { name = "REDACTED_31fbdf51", key = "port" } } },
                    { name = "PGDATABASE", valueFrom = { REDACTED_5dfff400 = { name = "REDACTED_31fbdf51", key = "database" } } },
                    { name = "PGUSER", valueFrom = { REDACTED_5dfff400 = { name = "REDACTED_31fbdf51", key = "username" } } },
                    { name = "PGPASSWORD", valueFrom = { REDACTED_5dfff400 = { name = "REDACTED_31fbdf51", key = "password" } } },
                  ]
                  volumeMounts = [{ name = "work", mountPath = "/work" }]
                }
              ]
              containers = [
                {
                  name  = "upload"
                  image = "amazon/aws-cli:2.17.16"
                  command = ["sh", "-ec", <<-EOS
                    aws --endpoint-url "$S3_ENDPOINT" s3 cp /work/ "s3://awx-pg-dumps/" --recursive --exclude "*" --include "*.dump"
                    aws --endpoint-url "$S3_ENDPOINT" s3 ls "s3://awx-pg-dumps/" | awk '{print $4}' | grep '\.dump$' | sort | head -n -14 | while read -r f; do
                      aws --endpoint-url "$S3_ENDPOINT" s3 rm "s3://awx-pg-dumps/$f"
                    done
                    echo "dump uploaded; retained newest 14"
                  EOS
                  ]
                  env = [
                    { name = "S3_ENDPOINT", value = "http://seaweedfs-s3.seaweedfs.svc.cluster.local:8333" },
                    { name = "AWS_DEFAULT_REGION", value = "seaweedfs" },
                    { name = "AWS_ACCESS_KEY_ID", valueFrom = { REDACTED_5dfff400 = { name = "awx-pg-dump-s3", key = "ACCESS_KEY_ID" } } },
                    { name = "AWS_SECRET_ACCESS_KEY", valueFrom = { REDACTED_5dfff400 = { name = "awx-pg-dump-s3", key = "ACCESS_SECRET_KEY" } } },
                  ]
                  volumeMounts = [{ name = "work", mountPath = "/work" }]
                }
              ]
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.REDACTED_7d10896b]
}
