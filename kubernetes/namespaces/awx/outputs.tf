***REMOVED***
# AWX Module Outputs
***REMOVED***

output "namespace" {
  description = "AWX namespace name"
  value       = kubernetes_namespace.awx.metadata[0].name
}

output "postgres_pv" {
  description = "PostgreSQL PV name"
  value       = REDACTED_912a6d18.awx_postgres.metadata[0].name
}

output "projects_pv" {
  description = "Projects PV name"
  value       = REDACTED_912a6d18.awx_projects.metadata[0].name
}

output "storage_class" {
  description = "AWX storage class name"
  value       = REDACTED_5a69a0fb.nfs_sc.metadata[0].name
}
