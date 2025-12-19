# ========================================================================
# Tetragon Module Outputs
# ========================================================================

output "tetragon_version" {
  description = "Deployed Tetragon Helm chart version"
  value       = helm_release.tetragon.version
}

output "tetragon_namespace" {
  description = "Namespace where Tetragon is deployed"
  value       = helm_release.tetragon.namespace
}

output "REDACTED_98fcd60a" {
  description = "Directory where Tetragon exports JSON logs"
  value       = "REDACTED_fa94d8bd"
}

output "tetragon_metrics_port" {
  description = "Port exposing Tetragon Prometheus metrics"
  value       = 2112
}

output "tetragon_operator_metrics_port" {
  description = "Port exposing Tetragon Operator Prometheus metrics"
  value       = 2113
}

output "enabled_policies" {
  description = "List of enabled TracingPolicies"
  value = compact([
    var.REDACTED_8a8d8279 ? "REDACTED_de85e9d6" : "",
    var.REDACTED_ca9faf45 ? "REDACTED_8cae118b" : "",
    var.REDACTED_f45ec1ce ? "REDACTED_bbe670ef" : "",
    var.REDACTED_936fa359 ? "REDACTED_e2274e6a" : "",
    var.REDACTED_073bcdbd ? "network-connection-monitor" : "",
  ])
}

output "grafana_dashboard_enabled" {
  description = "Whether Grafana dashboard is deployed"
  value       = var.enable_grafana_dashboard
}
