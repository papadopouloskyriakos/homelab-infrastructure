output "namespace" {
  value = "monitoring"
}

output "helm_release" {
  value = helm_release.monitoring.metadata[0].name
}
