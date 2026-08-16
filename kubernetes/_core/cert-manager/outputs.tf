output "namespace" {
  description = "cert-manager namespace"
  value       = kubernetes_namespace.cert_manager.metadata[0].name
}

output "REDACTED_2c664c73" {
  description = "Name of the wildcard TLS secret (same on both roles: issued by cert-manager on the issuer cluster, materialised from OpenBao on the consumer cluster)"
  value       = "REDACTED_0d82b4df-tls"
}
