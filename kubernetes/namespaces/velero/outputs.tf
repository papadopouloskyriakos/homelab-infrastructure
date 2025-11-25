output "namespace" {
  value = kubernetes_namespace.velero.metadata[0].name
}
