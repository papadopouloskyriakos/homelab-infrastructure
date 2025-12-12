output "dashboard_url" {
  description = "Kubernetes Dashboard URL"
  value       = "https://${var.dashboard_hostname}"
}

output "REDACTED_8dc96658" {
  description = "Command to get admin token"
  value       = "kubectl -n REDACTED_d97cef76 get secret REDACTED_c48f3618 -o jsonpath='{.data.token}' | base64 -d"
}
