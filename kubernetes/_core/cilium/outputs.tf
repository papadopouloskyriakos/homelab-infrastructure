# ========================================================================
# Cilium Module Outputs
# ========================================================================

output "cilium_version" {
  description = "Deployed Cilium version"
  value       = helm_release.cilium.version
}

output "hubble_relay_lb_ip" {
  description = "Hubble Relay LoadBalancer IP"
  value       = kubernetes_service_v1.hubble_relay_lb.status[0].load_balancer[0].ingress[0].ip
}

output "lb_pool_range" {
  description = "LoadBalancer IP pool range"
  value       = "${var.lb_pool_start}-${var.lb_pool_stop}"
}

output "clustermesh_gr_enabled" {
  description = "Whether GR cluster mesh is enabled"
  value       = var.clustermesh_gr_enabled
}
