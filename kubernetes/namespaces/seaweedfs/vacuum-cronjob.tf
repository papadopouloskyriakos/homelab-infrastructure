# =============================================================================
# SeaweedFS scheduled vacuum (IFRNLLEI01PRD-2831, 2026-09-10)
#
# Reclamation on this cluster used to depend on ONE mechanism: the master's
# background GC, gated by master.garbageThreshold (0.10 since MR !435). That loop
# has two properties that made it a no-op exactly when it mattered:
#   1. It only compacts a volume whose garbage ratio exceeds the threshold, so
#      slow accumulation across many volumes (each below 10 %) is never touched.
#   2. A volume server below -minFreeSpacePercent REFUSES to compact, so once the
#      disk is nearly full the loop cannot dig it out (the 2052/2831 deadlock).
# This CronJob runs an explicit `weed shell` pass on a schedule, independent of
# the background loop: vacuum with the same 0.10 threshold, then delete empty
# volumes that have been quiet for a day (freeing volume SLOTS as well as bytes —
# NL hit -max slot exhaustion on 2026-08-26, IFRNLLEI01PRD-2605).
#
# `lock` is mandatory: weed shell silently ignores mutating commands without it
# and exits 0 (memory feedback_seaweedfs_lowspace_deadlock). The master answers
# "Vacuum is already running" if its own loop is mid-pass; that is benign and the
# next weekly run catches up. Throttled by the volume servers' -compactionMBps.
#
# Canonical (byte-identical in NL/GR/NO): the master addresses are the chart's
# fixed StatefulSet DNS names inside the namespace, so nothing here is per-site.
# =============================================================================

resource "REDACTED_a9df2e77_v1" "vacuum_script" {
  metadata {
    name      = "REDACTED_9dfc13bc"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
    labels = {
      "app.kubernetes.io/name"       = "seaweedfs"
      "app.kubernetes.io/component"  = "vacuum"
      "app.kubernetes.io/managed-by" = "opentofu"
      "environment"                  = "production"
    }
  }
  data = {
    "vacuum.sh" = <<-SHEOF
      #!/bin/sh
      # Explicit reclaim pass. Output is the job log (kubectl logs job/...).
      set -u
      MASTERS="seaweedfs-master-0.seaweedfs-master:9333,seaweedfs-master-1.seaweedfs-master:9333,seaweedfs-master-2.seaweedfs-master:9333"
      echo "== $(date -u +%FT%TZ) seaweedfs vacuum pass start (garbageThreshold=$GARBAGE_THRESHOLD)"
      printf 'lock\nvolume.list -v 0\nvolume.vacuum -garbageThreshold %s\nvolume.deleteEmpty -quietFor 24h -force\nvolume.list -v 0\nunlock\n' "$GARBAGE_THRESHOLD" \
        | weed shell -master="$MASTERS" 2>&1 | grep -vE '^\s*$'
      rc=$?
      echo "== $(date -u +%FT%TZ) seaweedfs vacuum pass end rc=$rc"
      exit $rc
    SHEOF
  }
}

resource "kubernetes_manifest" "vacuum_cronjob" {
  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name      = "seaweedfs-vacuum"
      namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
      labels = {
        "app.kubernetes.io/name"       = "seaweedfs"
        "app.kubernetes.io/component"  = "vacuum"
        "app.kubernetes.io/managed-by" = "opentofu"
        "environment"                  = "production"
      }
    }
    spec = {
      # Weekly, Sunday 04:10 UTC — after the daily CNPG/Velero/etcd backup windows
      # (01:30–03:15 UTC) so their deletions of expired objects are already garbage.
      schedule                   = "10 4 * * 0"
      concurrencyPolicy          = "Forbid"
      successfulJobsHistoryLimit = 4
      failedJobsHistoryLimit     = 4
      jobTemplate = {
        spec = {
          backoffLimit          = 0
          activeDeadlineSeconds = 21600
          template = {
            metadata = {
              labels = { "app.kubernetes.io/name" = "seaweedfs-vacuum" }
            }
            spec = {
              restartPolicy = "Never"
              containers = [
                {
                  name    = "vacuum"
                  image   = "chrislusf/seaweedfs:${var.REDACTED_a4f42897}"
                  command = ["/bin/sh", "/vacuum/vacuum.sh"]
                  env = [
                    { name = "GARBAGE_THRESHOLD", value = var.REDACTED_fbcee600 },
                  ]
                  resources = {
                    requests = { cpu = "50m", memory = "64Mi" }
                    limits   = { memory = "256Mi" }
                  }
                  volumeMounts = [{ name = "script", mountPath = "/vacuum" }]
                }
              ]
              volumes = [
                { name = "script", configMap = { name = "REDACTED_9dfc13bc" } }
              ]
            }
          }
        }
      }
    }
  }
  depends_on = [REDACTED_a9df2e77_v1.vacuum_script, helm_release.seaweedfs]
}
