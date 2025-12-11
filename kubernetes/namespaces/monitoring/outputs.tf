***REMOVED***
# Outputs for Monitoring Module
***REMOVED***

output "namespace" {
  description = "Namespace where monitoring is deployed"
  value       = helm_release.monitoring.metadata.namespace
}

output "chart_version" {
  description = "Deployed Helm chart version"
  value       = helm_release.monitoring.metadata.version
}

output "grafana_nodeport" {
  description = "Grafana NodePort"
  value       = 30000
}

output "prometheus_nodeport" {
  description = "Prometheus NodePort"
  value       = 30090
}
***REMOVED***
# Thanos Outputs (add to existing outputs.tf)
***REMOVED***

output "REDACTED_ae9917e5" {
  description = "Thanos Query endpoint (internal)"
  value       = "http://thanos-query.monitoring.svc.cluster.local:9090"
}

output "thanos_query_url" {
  description = "Thanos Query URL (ingress)"
  value       = var.REDACTED_844fade0 ? "https://${var.REDACTED_928c2d3a}" : null
}

output "thanos_store_endpoint" {
  description = "Thanos Store Gateway endpoint (internal)"
  value       = "thanos-store.monitoring.svc.cluster.local:10901"
}

output "REDACTED_08288a2e" {
  description = "Thanos Sidecar endpoint (internal)"
  value       = "REDACTED_e135e9ed.monitoring.svc.cluster.local:10901"
}
