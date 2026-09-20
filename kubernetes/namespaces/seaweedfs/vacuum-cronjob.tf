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
    name      = "seaweedfs-vacuum-script"
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
      #
      # Two guards here, both added 2026-09-20 after IFRNLLEI01PRD-2848 showed the
      # failure they catch. Do not collapse them back into a one-liner.
      set -u
      MASTERS="seaweedfs-master-0.seaweedfs-master:9333,seaweedfs-master-1.seaweedfs-master:9333,seaweedfs-master-2.seaweedfs-master:9333"
      FLOOR_BYTES=10737418240   # 10 GiB: below this a no-op pass is not worth alerting on
      echo "== $(date -u +%FT%TZ) seaweedfs vacuum pass start (garbageThreshold=$GARBAGE_THRESHOLD)"

      # GUARD 1: assert the threshold can select at least one volume BEFORE running.
      # volume.vacuum is per-VOLUME, so a cluster can hold a lot of garbage and still
      # have no single volume above the threshold - in which case every pass is a
      # guaranteed no-op that still exits 0 and still looks like a healthy run.
      # notrf01 sat that way for 20 consecutive passes while garbage grew to 85 GiB,
      # and SeaweedFSVacuumJobNotRunning could not see it, because the job DID run.
      # NOTE: `volume.list -v 0` prints only the topology summary, with no per-volume
      # garbage, so the assertion needs the full listing.
      PRE=$(mktemp)
      printf 'lock\nvolume.list\nunlock\n' | weed shell -master="$MASTERS" > "$PRE" 2>&1
      STATS=$(awk -v TH="$GARBAGE_THRESHOLD" '
        /volume Id:/ {
          id=""; size=0; del=0; n=split($0, a, ",")
          for (i=1;i<=n;i++) {
            if (a[i] ~ /volume Id:/)          { sub(/.*volume Id:/,"",a[i]);          id=a[i]+0 }
            else if (a[i] ~ /DeletedByteCount:/) { sub(/.*DeletedByteCount:/,"",a[i]); del=a[i]+0 }
            else if (a[i] ~ /Size:/)          { sub(/.*Size:/,"",a[i]);               size=a[i]+0 }
          }
          # replicas repeat the same volume id; keep the largest copy
          if (size > 0 && size > S[id]) { S[id]=size; D[id]=del }
        }
        END {
          tot=0; garb=0; sel=0; nv=0
          for (k in S) { nv++; tot+=S[k]; garb+=D[k]; if (S[k] > 0 && D[k]/S[k] >= TH) sel++ }
          printf "%d %d %d %d", tot, garb, sel, nv
        }' "$PRE")
      rm -f "$PRE"
      TOT=$(echo "$STATS" | cut -d" " -f1); GARB=$(echo "$STATS" | cut -d" " -f2)
      SEL=$(echo "$STATS" | cut -d" " -f3); NVOL=$(echo "$STATS" | cut -d" " -f4)
      echo "   pre-pass: volumes=$NVOL total=$TOT bytes garbage=$GARB bytes selectable_at_$GARBAGE_THRESHOLD=$SEL"
      NOOP=0
      if [ "$${SEL:-0}" -eq 0 ] && [ "$${GARB:-0}" -gt "$FLOOR_BYTES" ]; then
        echo "   ERROR: garbageThreshold=$GARBAGE_THRESHOLD selects ZERO of $NVOL volumes while $GARB bytes of garbage exist."
        echo "   ERROR: this pass cannot reclaim anything. Lower the threshold (and master.garbageThreshold with it)."
        NOOP=1
      fi

      # GUARD 2: capture weed shell's OWN exit status. This used to read `rc=$?`
      # after a `| grep` pipe stage, so it recorded grep's status and a failed
      # vacuum exited 0 (same class as feedback_pipe_into_log_loop_hides_failures).
      OUT=$(mktemp)
      printf 'lock\nvolume.list -v 0\nvolume.vacuum -garbageThreshold %s\nvolume.deleteEmpty -quietFor 24h -force\nvolume.list -v 0\nunlock\n' "$GARBAGE_THRESHOLD" \
        | weed shell -master="$MASTERS" > "$OUT" 2>&1
      rc=$?
      grep -vE '^[[:space:]]*$' "$OUT" || true
      rm -f "$OUT"

      echo "== $(date -u +%FT%TZ) seaweedfs vacuum pass end rc=$rc noop=$NOOP"
      [ "$rc" -ne 0 ] && exit "$rc"
      exit "$NOOP"
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
          # Finished Jobs are garbage-collected after seven days so a failed run from
          # weeks ago cannot keep KubeJobFailed (and the canary rule) latched.
          ttlSecondsAfterFinished = 604800
          backoffLimit            = 0
          activeDeadlineSeconds   = 21600
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
                { name = "script", configMap = { name = "seaweedfs-vacuum-script" } }
              ]
            }
          }
        }
      }
    }
  }
  depends_on = [REDACTED_a9df2e77_v1.vacuum_script, helm_release.seaweedfs]
}
