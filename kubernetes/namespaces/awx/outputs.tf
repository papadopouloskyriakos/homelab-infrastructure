# =============================================================================
# AWX Module Outputs
# =============================================================================

output "namespace" {
  description = "AWX namespace name"
  value       = kubernetes_namespace.awx.metadata[0].name
}

output "postgres_pvc" {
  description = "PostgreSQL PVC name (static-bind mode only; null when dynamically provisioned by the operator)"
  value       = try(REDACTED_912a6d18_claim.awx_postgres[0].metadata[0].name, null)
}

output "projects_pv" {
  description = "Projects PV name"
  value       = REDACTED_912a6d18.awx_projects.metadata[0].name
}

output "storage_class" {
  description = "AWX NFS storage class name"
  value       = REDACTED_5a69a0fb.nfs_sc.metadata[0].name
}

output "awx_url" {
  description = "AWX web interface URL"
  value       = "https://${var.awx_hostname}"
}
