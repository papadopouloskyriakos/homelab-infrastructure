***REMOVED***
# Outputs for Well-Known Endpoints Service
***REMOVED***

output "namespace" {
  description = "Namespace where well-known service is deployed"
  value       = REDACTED_46569c16.well_known.metadata[0].name
}

output "service_name" {
  description = "Service name"
  value       = kubernetes_service_v1.well_known.metadata[0].name
}

output "service_endpoint" {
  description = "Internal service endpoint"
  value       = "${kubernetes_service_v1.well_known.metadata[0].name}.${REDACTED_46569c16.well_known.metadata[0].name}.svc.cluster.local"
}

output "security_txt_urls" {
  description = "Public URLs for security.txt"
  value       = [for domain in var.domains : "https://${domain}/.well-known/security.txt"]
}

output "domains_served" {
  description = "Domains configured for .well-known endpoints"
  value       = var.domains
}
