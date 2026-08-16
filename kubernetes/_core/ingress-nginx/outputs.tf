output "namespace" {
  description = "Namespace where ingress-nginx is deployed"
  value       = helm_release.ingress_nginx.namespace
}

output "chart_version" {
  description = "Helm chart version deployed"
  value       = helm_release.ingress_nginx.version
}

output "release_name" {
  description = "Helm release name"
  value       = helm_release.ingress_nginx.name
}

output "external_ip" {
  description = "External IP of the ingress-nginx LoadBalancer"
  value       = try(data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip, "pending")
}
