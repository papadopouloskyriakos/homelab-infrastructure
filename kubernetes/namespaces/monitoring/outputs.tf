***REMOVED***
# Outputs for Monitoring Module
***REMOVED***

output "namespace" {
  description = "Namespace where monitoring is deployed"
  value       = helm_release.monitoring.metadata[0].namespace
}

output "chart_version" {
  description = "Deployed Helm chart version"
  value       = helm_release.monitoring.metadata[0].version
}

output "grafana_nodeport" {
  description = "Grafana NodePort"
  value       = 30000
}

output "prometheus_nodeport" {
  description = "Prometheus NodePort"
  value       = 30090
}
