***REMOVED***
# Outputs for Gatus Module
***REMOVED***

output "namespace" {
  description = "Namespace where Gatus is deployed"
  value       = REDACTED_46569c16.gatus.metadata[0].name
}

output "service_name" {
  description = "Gatus service name"
  value       = kubernetes_service_v1.gatus.metadata[0].name
}

output "service_endpoint" {
  description = "Gatus internal service endpoint"
  value       = "${kubernetes_service_v1.gatus.metadata[0].name}.${REDACTED_46569c16.gatus.metadata[0].name}.svc.cluster.local"
}

output "ingress_hostname" {
  description = "Gatus ingress hostname"
  value       = var.gatus_hostname
}

output "ingress_url" {
  description = "Gatus public URL"
  value       = "https://${var.gatus_hostname}"
}

output "served_by" {
  description = "Site serving this instance"
  value       = var.site_name
}

output "metrics_endpoint" {
  description = "Prometheus metrics endpoint"
  value       = "http://${kubernetes_service_v1.gatus.metadata[0].name}.${REDACTED_46569c16.gatus.metadata[0].name}.svc.cluster.local/metrics"
}
