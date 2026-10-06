# =============================================================================
# paops (personal assistant voice stack on nlpaops01) alert rules.
#
# Mirror of:
#   claude-gateway prometheus/alert-rules/paops.yml
# When adding / changing / removing an alert, edit BOTH files. This .tf is
# the deployed truth; the YAML is the test+doc copy and is consumed by
# scripts/qa/suites/test-726-prom-alert-rules.sh (promtool test rules).
#
# Metric source (node_exporter textfile collector on nlpaops01,
# scraped by the chatops-node job in scrape-estate.tf):
#   products/paops ops/write-paops-metrics.sh (paops-metrics.timer, */5)
#   -> /var/lib/node_exporter/textfile_collector/paops.prom
#   paops-contacts / paops-postcall containers -> paops_contacts.prom, paops_postcall.prom
# Lines: Twilio (+3197006531641, registered over TCP via the Ireland edge),
# FRITZ!Box 6850 LTE = nlcellgw01 (the mobile number; the alert is gated
# by paops_fritz_expected until the box is on the LAN). Tracking: YouTrack PAOPS-2.
# =============================================================================

resource "kubernetes_manifest" "paops_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "paops-alert-rules"
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
          name     = "paops-voice-line"
          interval = "1m"
          rules = [
            {
              alert = "REDACTED_e8849976"
              expr  = "paops_registration{line=\"twilio\"} == 0"
              for   = "10m"
              labels = {
                severity = "warning"
                category = "paops"
              }
              annotations = {
                summary     = "paops: the Twilio line is not registered"
                description = "Asterisk on nlpaops01 has no registration to the Twilio SIP domain, so calls to +3197006531641 fail. Check 'pjsip show registrations' in the paops-asterisk container, the TCP path through nlfw01, and the credential in OpenBao secret/paops/twilio-sip. Runbook: products/paops docs/RUNBOOK.md."
              }
            },
            {
              alert = "REDACTED_9b6674ea"
              expr  = "paops_registration{line=\"fritzbox\"} == 0 and on() paops_fritz_expected == 1"
              for   = "10m"
              labels = {
                severity = "critical"
                category = "paops"
              }
              annotations = {
                summary     = "paops: the FRITZ!Box line is not registered, the mobile number is dead"
                description = "Asterisk is not registered as IP phone 620 on nlcellgw01 (10.0.X.X), so the operator's mobile number takes no calls. Check the box, the SIM/VoLTE state and 'pjsip show registrations'. Fallback: docs/runbooks/sim-back-to-phone.md."
              }
            },
            {
              alert = "REDACTED_1a0e75fb"
              expr  = "paops_asterisk_healthy == 0"
              for   = "5m"
              labels = {
                severity = "critical"
                category = "paops"
              }
              annotations = {
                summary     = "paops: the Asterisk container is unhealthy"
                description = "The paops-asterisk container health check fails on nlpaops01. Every line is down. 'docker ps', 'docker logs paops-asterisk', ops/voice-line.sh status."
              }
            },
            {
              alert = "PaopsHostDown"
              expr  = "up{instance=\"nlpaops01\"} == 0"
              for   = "5m"
              labels = {
                severity = "critical"
                category = "paops"
              }
              annotations = {
                summary     = "paops: nlpaops01 is unreachable"
                description = "node_exporter on nlpaops01 (10.0.X.X) does not answer; the voice assistant and every line are down. QEMU 104101202 on nlpve04."
              }
            },
            {
              alert = "PaopsMetricsStale"
              expr  = "time() - paops_metrics_last_run_timestamp_seconds > 1200"
              for   = "10m"
              labels = {
                severity = "warning"
                category = "paops"
              }
              annotations = {
                summary     = "paops: the host metrics have not been rewritten for 20 min"
                description = "paops-metrics.timer on nlpaops01 is not producing paops.prom, so the line alerts are blind. 'systemctl status paops-metrics.timer'."
              }
            },
          ]
        },
        {
          name     = "paops-pipeline"
          interval = "1m"
          rules = [
            {
              alert = "REDACTED_79e99561"
              expr  = "paops_jobs_failed > 0"
              for   = "15m"
              labels = {
                severity = "warning"
                category = "paops"
              }
              annotations = {
                summary     = "paops: {{ $value }} post-call job(s) in failed/"
                description = "A call's transcript/summary/email did not get through after three attempts. Jobs under /srv/paops/recordings/jobs/failed on nlpaops01; 'docker logs paops-postcall'. Move the file back to jobs/ to retry."
              }
            },
            {
              alert = "PaopsPostcallBacklog"
              expr  = "paops_jobs_pending > 3"
              for   = "30m"
              labels = {
                severity = "warning"
                category = "paops"
              }
              annotations = {
                summary     = "paops: post-call jobs are piling up ({{ $value }} pending)"
                description = "The paops-postcall watcher is not draining jobs/ on nlpaops01. Check the container, ElevenLabs Scribe and LiteLLM reachability."
              }
            },
            {
              alert = "REDACTED_62599e86"
              expr  = "paops_contacts_last_sync_ok == 0 or (time() - paops_contacts_last_sync_timestamp_seconds) > 3600"
              for   = "15m"
              labels = {
                severity = "warning"
                category = "paops"
              }
              annotations = {
                summary     = "paops: the Nextcloud contacts cache is stale"
                description = "paops-contacts has not completed a CardDAV sync for over an hour (or its last sync failed), so caller names, languages and the blocked list drift. 'docker logs paops-contacts' on nlpaops01; credential in OpenBao secret/paops/nextcloud."
              }
            },
          ]
        },
      ]
    }
  }
}
