output "namespace" {
  value = kubernetes_namespace.minio.metadata[0].name
}

output "api_service" {
  value = kubernetes_service.minio_api.metadata[0].name
}

output "console_service" {
  value = kubernetes_service.minio_console.metadata[0].name
}
