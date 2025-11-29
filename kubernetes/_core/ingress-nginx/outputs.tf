output "namespace" {
  value = helm_release.ingress_nginx.metadata.namespace
}
output "chart_version" {
  value = helm_release.ingress_nginx.metadata.version
}
