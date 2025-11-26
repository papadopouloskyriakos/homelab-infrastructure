output "namespace" {
  value = helm_release.metallb.metadata[0].namespace
}

output "chart_version" {
  value = helm_release.metallb.metadata[0].version
}

output "ip_pool" {
  value = var.metallb_ip_range
}
