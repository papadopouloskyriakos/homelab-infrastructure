***REMOVED***
# Outputs for Logging Module
***REMOVED***

output "loki_endpoint" {
  description = "Loki endpoint for Grafana datasource"
  value       = "http://loki.logging.svc.cluster.local:3100"
}

output "REDACTED_4e7b07ba" {
  description = "Promtail syslog receiver service"
  value       = "promtail-syslog.logging.svc.cluster.local:${var.promtail_syslog_port}"
}
