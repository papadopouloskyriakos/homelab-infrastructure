# =============================================================================
# CloudNativePG backup janitor (IFRNLLEI01PRD-2850, 2026-09-21)
#
# CNPG v1.30 never moves a Backup out of `walArchivingFailing`, and a
# ScheduledBackup waits forever on any child that is not done (upstream
# #10385/#10745, both open). On 2026-09-11 one such object on notrf01 stopped
# omoikane-main and litellm backing up for 10 days; barman retention then pruned
# nothing, cnpg-omoikane grew ~7 GB/day on nl-s3, and nl-s3 filled on 09-21.
# meshsat-hub had carried a per-namespace fix since 09-11 (its backup-unwedge
# CronJob); this is the canonical, cluster-wide version, on every site, for every
# CNPG cluster including the SeaweedFS filer-meta ones.
#
# Hourly: release latched Backups (re-read + resourceVersion precondition, so a
# Backup that just changed is never deleted), then FAIL the Job if any
# non-suspended ScheduledBackup has not fired, or its cluster has not backed up,
# within 30h. The page is REDACTED_4c435e3b (seaweedfs-capacity-alerts.tf) on
# the CronJob's last successful run, which also covers a janitor that never runs.
# Logic + tests: cnpg_janitor.py, tests/test_cnpg_janitor.py (canonical).
# =============================================================================

locals {
  labels = merge(var.common_labels, {
    "app.kubernetes.io/name"      = "cnpg-janitor"
    "app.kubernetes.io/component" = "backup-janitor"
  })
}

resource "REDACTED_4ad9fc99_v1" "cnpg_janitor" {
  metadata {
    name      = "cnpg-janitor"
    namespace = var.namespace
    labels    = local.labels
  }
}

# Narrowest role that works: it can list and release Backups and read the two
# kinds it checks. It cannot create a backup, read a secret or touch a Cluster.
resource "REDACTED_1f297da4" "cnpg_janitor" {
  metadata {
    name   = "cnpg-janitor"
    labels = local.labels
  }
  rule {
    api_groups = ["postgresql.cnpg.io"]
    resources  = ["backups"]
    verbs      = ["get", "list", "delete"]
  }
  rule {
    api_groups = ["postgresql.cnpg.io"]
    resources  = ["scheduledbackups", "clusters"]
    verbs      = ["get", "list"]
  }
}

resource "REDACTED_2b73dc4c_v1" "cnpg_janitor" {
  metadata {
    name   = "cnpg-janitor"
    labels = local.labels
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = REDACTED_1f297da4.cnpg_janitor.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = REDACTED_4ad9fc99_v1.cnpg_janitor.metadata[0].name
    namespace = var.namespace
  }
}

resource "REDACTED_a9df2e77_v1" "cnpg_janitor_script" {
  metadata {
    name      = "cnpg-janitor-script"
    namespace = var.namespace
    labels    = local.labels
  }
  data = {
    "cnpg_janitor.py" = file("${path.module}/cnpg_janitor.py")
  }
}

resource "kubernetes_manifest" "cnpg_janitor_cronjob" {
  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name      = "cnpg-janitor"
      namespace = var.namespace
      labels    = local.labels
    }
    spec = {
      schedule                   = var.schedule
      concurrencyPolicy          = "Forbid"
      startingDeadlineSeconds    = 600
      successfulJobsHistoryLimit = 3
      failedJobsHistoryLimit     = 3
      jobTemplate = {
        spec = {
          backoffLimit            = 0
          activeDeadlineSeconds   = 600
          ttlSecondsAfterFinished = 86400
          template = {
            metadata = {
              labels = local.labels
              annotations = {
                # roll the pod template when the script changes
                "REDACTED_4b046445" = sha256(file("${path.module}/cnpg_janitor.py"))
              }
            }
            spec = {
              serviceAccountName = REDACTED_4ad9fc99_v1.cnpg_janitor.metadata[0].name
              restartPolicy      = "Never"
              securityContext = {
                runAsNonRoot   = true
                runAsUser      = 65534
                runAsGroup     = 65534
                seccompProfile = { type = "RuntimeDefault" }
              }
              containers = [
                {
                  name            = "janitor"
                  image           = var.image
                  imagePullPolicy = "IfNotPresent"
                  command         = ["python3", "-u", "/janitor/cnpg_janitor.py"]
                  env = [
                    { name = "MIN_AGE_SECONDS", value = tostring(var.REDACTED_1f1d9073) },
                    { name = "STUCK_RUNNING_SECONDS", value = tostring(var.stuck_running_seconds) },
                    { name = "MAX_AGE_HOURS", value = tostring(var.max_age_hours) },
                  ]
                  securityContext = {
                    allowPrivilegeEscalation = false
                    readOnlyRootFilesystem   = true
                    capabilities             = { drop = ["ALL"] }
                  }
                  resources = {
                    requests = { cpu = "10m", memory = "48Mi" }
                    limits   = { memory = "128Mi" }
                  }
                  volumeMounts = [{ name = "script", mountPath = "/janitor", readOnly = true }]
                }
              ]
              volumes = [
                { name = "script", configMap = { name = REDACTED_a9df2e77_v1.cnpg_janitor_script.metadata[0].name } }
              ]
            }
          }
        }
      }
    }
  }
}
