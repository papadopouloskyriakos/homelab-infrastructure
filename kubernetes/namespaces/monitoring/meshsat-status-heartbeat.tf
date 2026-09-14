# =============================================================================
# status.meshsat.net -- dead man's switch for the monitoring pipeline
# (MESHSAT-1134, 2026-09-14)
#
# The public status page (Kener on nldmz01) draws every component from
# THIS Prometheus. If Prometheus, the blackbox exporter or the DMZ's route to
# the NL ingress dies, every Kener monitor flips to its errorStatus (DEGRADED)
# and the page cannot tell "we cannot see" from "it is fine but slow". This
# CronJob beats a Kener HEARTBEAT monitor once a minute, and only after
# Prometheus itself answered /-/healthy -- so a silent monitoring pipeline shows
# on the page as a named component ("Monitoring") going DEGRADED after 5 min and
# DOWN after 10, rather than as eleven components quietly going grey.
#
# NL-only (the page reads NL Prometheus), so this file is on the mirror
# exemption manifest. The secret is one OpenBao property the Kener seed also
# reads; rotating it is a `bao kv put` and the next reconcile.
# =============================================================================

resource "kubernetes_manifest" "meshsat_status_heartbeat_externalsecret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "meshsat-status-heartbeat"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/name"       = "meshsat-status"
        "app.kubernetes.io/component"  = "heartbeat"
        "app.kubernetes.io/managed-by" = "opentofu"
        "environment"                  = "production"
      }
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef  = { name = "openbao", kind = "ClusterSecretStore" }
      target          = { name = "meshsat-status-heartbeat", creationPolicy = "Owner", deletionPolicy = "Retain" }
      data = [
        { secretKey = "HEARTBEAT_SECRET", remoteRef = { key = "ci/meshsat-status", property = "HEARTBEAT_SECRET" } },
      ]
    }
  }
}

resource "kubernetes_manifest" "REDACTED_aa26710d" {
  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name      = "meshsat-status-heartbeat"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/name"       = "meshsat-status"
        "app.kubernetes.io/component"  = "heartbeat"
        "app.kubernetes.io/managed-by" = "opentofu"
        "environment"                  = "production"
      }
    }
    spec = {
      schedule                   = "* * * * *"
      concurrencyPolicy          = "Forbid"
      successfulJobsHistoryLimit = 1
      failedJobsHistoryLimit     = 3
      jobTemplate = {
        spec = {
          backoffLimit          = 0
          activeDeadlineSeconds = 50
          template = {
            metadata = {
              labels = { "app.kubernetes.io/name" = "meshsat-status-heartbeat" }
            }
            spec = {
              restartPolicy = "Never"
              securityContext = {
                runAsNonRoot   = true
                runAsUser      = 65532
                seccompProfile = { type = "RuntimeDefault" }
              }
              containers = [
                {
                  name  = "beat"
                  image = "curlimages/curl:8.14.1"
                  # The beat is conditional on Prometheus answering: a heartbeat
                  # that fires while the thing it vouches for is dead is worse
                  # than no heartbeat. -f makes any non-2xx a failure; the secret
                  # never leaves the URL, and `-sS` keeps it out of the job log.
                  command = ["/bin/sh", "-ec"]
                  args = [
                    "curl -fsS --max-time 10 -o /dev/null http://REDACTED_6dfbe9fc.monitoring.svc:9090/-/healthy && curl -fsS --max-time 15 -o /dev/null \"https://status.meshsat.net/ext/heartbeat/monitoring/$${HEARTBEAT_SECRET}\" && echo beat",
                  ]
                  env = [
                    { name = "HEARTBEAT_SECRET", valueFrom = { REDACTED_5dfff400 = { name = "meshsat-status-heartbeat", key = "HEARTBEAT_SECRET" } } },
                  ]
                  securityContext = {
                    allowPrivilegeEscalation = false
                    readOnlyRootFilesystem   = true
                    capabilities             = { drop = ["ALL"] }
                  }
                  resources = {
                    requests = { cpu = "10m", memory = "16Mi" }
                    limits   = { memory = "64Mi" }
                  }
                }
              ]
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_manifest.meshsat_status_heartbeat_externalsecret]
}
