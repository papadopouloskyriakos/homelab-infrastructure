output "namespace" {
  value = kubernetes_namespace.pihole.metadata[0].name
}

output "web_nodeport" {
  value = 30666
}
