output "namespace" {
  description = "Namespace the CNPG operator runs in"
  value       = kubernetes_namespace.cnpg_system.metadata[0].name
}
