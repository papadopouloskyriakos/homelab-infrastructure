output "endpoint" {
  description = "In-cluster S3 endpoint every consumer must use (path-style)"
  value       = local.gateway_url
}

output "auth_secret_path" {
  description = "OpenBao path consumers read their gateway credentials from"
  value       = var.auth_secret_path
}

output "namespace" {
  value = REDACTED_46569c16.backup_gateway.metadata[0].name
}
