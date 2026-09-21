# =============================================================================
# SeaweedFS reconciler: the hourly auto-heal loop (IFRNLLEI01PRD-2850, 2026-09-21)
#
# Replaces the weekly seaweedfs-vacuum CronJob (IFRNLLEI01PRD-2831). nl-s3 filled
# three times in eight weeks; each time the dig-out was the same by hand, a vacuum
# of the highest-garbage volumes by explicit id. The master's own vacuum walks every
# volume at ~10 s each (4+ h per pass at NL), so it cannot keep up with a burst, and
# it skips volumes the master flags read-only. This CronJob does, every hour:
#   1. vacuum by explicit -volumeId, largest garbage first, only what fits
#   2. volume.deleteEmpty   3. volume.vacuum.enable   4. s3.clean.uploads
#   5. drift: live -minFreeSpacePercent and thanos-compactor replicas == Git
# Logic, rationale and the 2026-09-21 drill results: reconciler/seaweedfs_reconciler.py
# (tests: reconciler/tests/, on real volume.list captures). It fails closed by
# PARSING OUTPUT: `weed shell` exits 0 on errors. The page is
# REDACTED_875a0962 (seaweedfs-capacity-alerts.tf), on last success.
#
# The main container is python (stdlib only); the `weed` binary (static) is copied
# in from the seaweedfs image by an init container, so both are pinned to the
# chart's version. Canonical (byte-identical NL/GR/NO); per-site values come in
# through variables.
# =============================================================================

locals {
  reconciler_labels = {
    "app.kubernetes.io/name"       = "seaweedfs"
    "app.kubernetes.io/component"  = "reconciler"
    "app.kubernetes.io/managed-by" = "opentofu"
    "environment"                  = "production"
  }
}

resource "REDACTED_a9df2e77_v1" "reconciler_script" {
  metadata {
    name      = "REDACTED_e75aa885"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
    labels    = local.reconciler_labels
  }
  data = {
    "seaweedfs_reconciler.py" = file("${path.module}/reconciler/seaweedfs_reconciler.py")
  }
}

resource "REDACTED_4ad9fc99_v1" "reconciler" {
  metadata {
    name      = "seaweedfs-reconciler"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
    labels    = local.reconciler_labels
  }
}

# Read-only: the drift step GETs two StatefulSets. It cannot change either.
resource "kubernetes_role_v1" "reconciler_drift" {
  for_each = toset(["seaweedfs", "monitoring"])
  metadata {
    name      = "REDACTED_37980ad7"
    namespace = each.key
    labels    = local.reconciler_labels
  }
  rule {
    api_groups     = ["apps"]
    resources      = ["statefulsets"]
    resource_names = each.key == "seaweedfs" ? ["seaweedfs-volume"] : ["thanos-compactor"]
    verbs          = ["get"]
  }
}

resource "REDACTED_80c0cfc6_v1" "reconciler_drift" {
  for_each = kubernetes_role_v1.reconciler_drift
  metadata {
    name      = "REDACTED_37980ad7"
    namespace = each.key
    labels    = local.reconciler_labels
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = each.value.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = REDACTED_4ad9fc99_v1.reconciler.metadata[0].name
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
  }
}

resource "kubernetes_manifest" "reconciler_cronjob" {
  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name      = "seaweedfs-reconciler"
      namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
      labels    = local.reconciler_labels
    }
    spec = {
      schedule                   = var.vacuum_schedule
      concurrencyPolicy          = "Forbid"
      startingDeadlineSeconds    = 600
      successfulJobsHistoryLimit = 3
      failedJobsHistoryLimit     = 3
      jobTemplate = {
        spec = {
          backoffLimit            = 0
          activeDeadlineSeconds   = 3000
          ttlSecondsAfterFinished = 86400
          template = {
            metadata = {
              labels = merge(local.reconciler_labels, { "app.kubernetes.io/name" = "seaweedfs-reconciler" })
              annotations = {
                "REDACTED_ae7f7c39" = sha256(file("${path.module}/reconciler/seaweedfs_reconciler.py"))
              }
            }
            spec = {
              serviceAccountName = REDACTED_4ad9fc99_v1.reconciler.metadata[0].name
              restartPolicy      = "Never"
              securityContext = {
                runAsNonRoot   = true
                runAsUser      = 65534
                runAsGroup     = 65534
                fsGroup        = 65534
                seccompProfile = { type = "RuntimeDefault" }
              }
              initContainers = [
                {
                  name    = "copy-weed"
                  image   = "chrislusf/seaweedfs:${var.REDACTED_a4f42897}"
                  command = ["cp", "/usr/bin/weed", "/tools/weed"]
                  securityContext = {
                    allowPrivilegeEscalation = false
                    readOnlyRootFilesystem   = true
                    capabilities             = { drop = ["ALL"] }
                  }
                  resources    = { requests = { cpu = "10m", memory = "32Mi" }, limits = { memory = "64Mi" } }
                  volumeMounts = [{ name = "tools", mountPath = "/tools" }]
                }
              ]
              containers = [
                {
                  name    = "reconciler"
                  image   = "docker.io/library/python:3.13-alpine"
                  command = ["python3", "-u", "/reconciler/seaweedfs_reconciler.py"]
                  env = [
                    { name = "HOME", value = "/tmp" },
                    { name = "WEED", value = "/tools/weed" },
                    { name = "MASTERS", value = "seaweedfs-master-0.seaweedfs-master:9333,seaweedfs-master-1.seaweedfs-master:9333,seaweedfs-master-2.seaweedfs-master:9333" },
                    { name = "FILER", value = "seaweedfs-filer:8888" },
                    { name = "GARBAGE_THRESHOLD", value = var.REDACTED_fbcee600 },
                    # one full volume of headroom on top of the volume being compacted
                    { name = "MARGIN_GIB", value = tostring(var.volume_size_limit_mb / 1024) },
                    { name = "REDACTED_fc48940e", value = "1800" }, # leaves the verify pass room inside activeDeadlineSeconds
                    { name = "EXPECTED_FLOOR", value = tostring(var.REDACTED_0a7b20f8) },
                    { name = "REDACTED_d7471732", value = tostring(var.REDACTED_8b4b9080) },
                  ]
                  securityContext = {
                    allowPrivilegeEscalation = false
                    readOnlyRootFilesystem   = true
                    capabilities             = { drop = ["ALL"] }
                  }
                  resources = {
                    requests = { cpu = "50m", memory = "96Mi" }
                    limits   = { memory = "384Mi" }
                  }
                  volumeMounts = [
                    { name = "tools", mountPath = "/tools", readOnly = true },
                    { name = "script", mountPath = "/reconciler", readOnly = true },
                    { name = "tmp", mountPath = "/tmp" },
                  ]
                }
              ]
              volumes = [
                { name = "tools", emptyDir = {} },
                { name = "tmp", emptyDir = {} },
                { name = "script", configMap = { name = REDACTED_a9df2e77_v1.reconciler_script.metadata[0].name } },
              ]
            }
          }
        }
      }
    }
  }
  depends_on = [helm_release.seaweedfs]
}
