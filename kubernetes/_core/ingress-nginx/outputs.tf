output "namespace" {
  value = helm_release.ingress_nginx.metadata[0].namespace
}

output "chart_version" {
  value = helm_release.ingress_nginx.metadata[0].version
}
