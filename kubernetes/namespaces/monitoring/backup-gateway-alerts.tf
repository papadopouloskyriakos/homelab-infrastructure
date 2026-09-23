# =============================================================================
# Backup gateway alerts (IFRNLLEI01PRD-2850, 2026-09-23)
#
# The gateway (namespaces/backup-gateway) is the ONLY path from the estate to
# Hetzner Object Storage, and the rule it enforces is "nothing reaches Hetzner
# unencrypted". Two things therefore page: the gateway being gone (every
# backup, metrics and log writer fails behind it), and the layout assertion
# finding something on Hetzner that did not come through the gateway.
#
# Canonical (identical on NL/GR/NO): every site runs its own gateway and its
# own CronJobs, so each rule fires per site against local series only.
# Invert-tested on NL before shipping (see the MR).
# =============================================================================

resource "kubernetes_manifest" "REDACTED_1c38f1c8" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_c522d930"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "prometheus"                = "monitoring"
        "role"                      = "alert-rules"
        "release"                   = "monitoring"
      }
    }

    spec = {
      groups = [
        {
          name     = "backup-gateway"
          interval = "1m"
          rules = [
            {
              alert = "BackupGatewayDown"
              expr  = "kube_deployment_status_replicas_available{namespace=\"backup-gateway\", deployment=\"backup-gateway\"} == 0 and on () (kube_deployment_spec_replicas{namespace=\"backup-gateway\", deployment=\"backup-gateway\"} > 0)"
              for   = "5m"
              labels = {
                severity  = "critical"
                tier      = "1" # pages: every off-estate backup, metrics block and log chunk writer fails behind it
                category  = "storage-offsite"
                service   = "backup-gateway"
                namespace = "backup-gateway"
              }
              annotations = {
                summary     = "Backup gateway has no available replica — nothing is reaching Hetzner"
                description = "The rclone crypt gateway Deployment has 0 available replicas for 5 minutes. Velero, CNPG barman WAL archiving, Thanos uploads, Loki chunk flushes and the filer-meta backups all write through it and are failing now. Check: kubectl -n backup-gateway get pods; kubectl -n backup-gateway logs deploy/backup-gateway. Common causes: the ExternalSecret REDACTED_3e2f7d3c not synced (OpenBao role backup-gateway or the REDACTED_336e5cad ClusterSecretStore), or a bad rclone.conf render (the auth pair must be CSV-quoted)."
                impact      = "Every consumer of Hetzner Object Storage is write-dead; CNPG WAL piles up on the instance PVs; Prometheus sidecars retain blocks locally for only 24 h."
              }
            },
            {
              alert = "REDACTED_c95e2714"
              expr  = "count((kube_job_status_failed{namespace=\"backup-gateway\", job_name=~\"REDACTED_54583949-.+\"} > 0) and on (job_name) ((time() - kube_job_status_start_time{namespace=\"backup-gateway\", job_name=~\"REDACTED_54583949-.+\"}) < 43200)) >= 1"
              for   = "5m"
              labels = {
                severity  = "critical"
                tier      = "1" # pages: the rule 'nothing reaches Hetzner unencrypted' is measurably broken
                category  = "storage-offsite"
                service   = "backup-gateway"
                namespace = "backup-gateway"
              }
              annotations = {
                summary     = "Hetzner holds something that did not come through the crypt gateway"
                description = "The REDACTED_54583949 Job failed: the project lists a bucket other than ours, or a directory/object name under it is not crypt-shaped (rclone crypt standard names are unpadded base32hex, 0-9a-v). Read the log: kubectl -n backup-gateway logs job/<latest REDACTED_54583949-*>. Find the consumer that was pointed at Hetzner directly, repoint it at the gateway, delete the plaintext objects, and rotate the Hetzner credential if anything outside the gateway ever held it."
                impact      = "Unencrypted estate data on a third party's storage."
              }
            },
            {
              alert = "REDACTED_2fa52528"
              expr  = "count((kube_job_status_failed{namespace=\"backup-gateway\", job_name=~\"REDACTED_4e0a8ed8-.+\"} > 0) and on (job_name) ((time() - kube_job_status_start_time{namespace=\"backup-gateway\", job_name=~\"REDACTED_4e0a8ed8-.+\"}) < 43200)) >= 1"
              for   = "10m"
              labels = {
                severity  = "critical"
                tier      = "2" # quiet topic: the gateway answers but a real write/read through it failed
                category  = "storage-offsite"
                service   = "backup-gateway"
                namespace = "backup-gateway"
              }
              annotations = {
                summary     = "Backup gateway canary FAILED — a real write/read through the gateway did not round-trip"
                description = "The 6-hourly canary could not PUT/GET/DELETE its 1 MiB or 64 MiB object through the gateway with the local key. Read the log: kubectl -n backup-gateway logs job/<latest REDACTED_4e0a8ed8-*>. A 64 MiB failure with the 1 MiB one passing = the multipart/streaming path to Hetzner (rclone.conf upload settings, Hetzner-side errors); both failing = auth or the crypt remote."
                impact      = "Consumers may be failing the same way; Velero/CNPG/Thanos/Loki rules will follow within hours."
              }
            },
            {
              alert = "REDACTED_5f871b37"
              expr  = "(time() - max(kube_job_status_completion_time{namespace=\"backup-gateway\", job_name=~\"REDACTED_4e0a8ed8-.+\"}) > 50400) or absent(kube_job_status_completion_time{namespace=\"backup-gateway\", job_name=~\"REDACTED_4e0a8ed8-.+\"})"
              for   = "30m"
              labels = {
                severity  = "warning"
                category  = "storage-offsite"
                service   = "backup-gateway"
                namespace = "backup-gateway"
              }
              annotations = {
                summary     = "Backup gateway canary has not completed in >14h (or has never run)"
                description = "No REDACTED_4e0a8ed8 Job completion in 14 hours (schedule every 6 h), or the metric is absent. A canary that is not running certifies nothing."
                impact      = "The Hetzner write path is unmonitored while this fires."
              }
            },
            {
              alert = "REDACTED_02856b73"
              expr  = "(time() - max(kube_job_status_completion_time{namespace=\"backup-gateway\", job_name=~\"REDACTED_54583949-.+\"}) > 50400) or absent(kube_job_status_completion_time{namespace=\"backup-gateway\", job_name=~\"REDACTED_54583949-.+\"})"
              for   = "30m"
              labels = {
                severity  = "warning"
                category  = "storage-offsite"
                service   = "backup-gateway"
                namespace = "backup-gateway"
              }
              annotations = {
                summary     = "Hetzner layout assertion has not completed in >14h (or has never run)"
                description = "The rule 'nothing reaches Hetzner unencrypted' is only as good as the Job that checks it; it has not succeeded in 14 h. Check the CronJob REDACTED_54583949 in namespace backup-gateway."
                impact      = "A consumer bypassing the gateway would go unnoticed."
              }
            },
            {
              alert = "REDACTED_9b71c03c"
              expr  = "min(up{namespace=\"backup-gateway\"}) == 0 or absent(up{namespace=\"backup-gateway\"})"
              for   = "15m"
              labels = {
                severity  = "critical"
                tier      = "2" # quiet topic
                category  = "storage-offsite"
                service   = "backup-gateway"
                namespace = "backup-gateway"
              }
              annotations = {
                summary     = "Backup gateway metrics are not being scraped"
                description = "Prometheus has no up=1 target in namespace backup-gateway for 15 minutes: the ServiceMonitor, the metrics port (:9090, --metrics-addr) or the pods are gone. BackupGatewayDown keys on kube-state-metrics and still works; rclone's own transfer/error metrics do not."
                impact      = "Gateway throughput and error counters are blind."
              }
            },
          ]
        },
      ]
    }
  }
}
