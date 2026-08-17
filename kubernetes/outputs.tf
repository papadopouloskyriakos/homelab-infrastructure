# =============================================================================
# Outputs — CANONICAL FILE (byte-identical NL <-> GR). Values are var-driven,
# so each repo renders its own site's endpoints. No secrets referenced.
# =============================================================================

# Networking
output "ingress_nginx_external_ip" {
  description = "External IP of the ingress-nginx LoadBalancer"
  value       = module.ingress_nginx.external_ip
}

# Storage
output "nfs_storage_class" {
  description = "NFS storage class name (null when nfs_enabled = false)"
  value       = one(module.nfs_provisioner[*].storage_class_name)
}

output "storage_class_retain" {
  description = "iSCSI storage class name (Retain policy; per-site CSI backend)"
  value       = var.storage_class_retain
}

output "storage_class_delete" {
  description = "iSCSI storage class name (Delete policy; per-site CSI backend)"
  value       = var.storage_class_delete
}

# Secrets
output "cluster_secret_store" {
  description = "ClusterSecretStore name for OpenBao"
  value       = module.external_secrets.cluster_secret_store_name
}

# Monitoring
output "grafana_url" {
  description = "Grafana dashboard URL (NodePort)"
  value       = "http://<node-ip>:30000"
}

output "prometheus_url" {
  description = "Prometheus UI URL (NodePort)"
  value       = "http://<node-ip>:30090"
}

output "thanos_query_url" {
  description = "Thanos Query URL"
  value       = "https://${var.REDACTED_928c2d3a}"
}

# Logging
output "loki_endpoint" {
  description = "Loki endpoint for Grafana datasource"
  value       = module.logging.loki_endpoint
}

output "REDACTED_337e6630" {
  description = "Promtail syslog LoadBalancer IP"
  value       = module.logging.REDACTED_337e6630
}

# =============================================================================
# Deployment Summary
# =============================================================================

output "deployment_summary" {
  description = "Quick reference for cluster access and services"
  value       = <<-EOT
    === ${var.site_code} Kubernetes Deployment Summary ===

    Cluster:    ${var.cluster_name} (ID: ${var.cluster_id})
    API:        https://${var.k8s_api_host}:6443

    Services:
      Grafana:     https://${var.grafana_hostname}
      Prometheus:  https://${var.prometheus_hostname}
      Thanos:      https://${var.REDACTED_928c2d3a}
      ArgoCD:      https://${var.argocd_hostname} (NodePort ${var.argocd_nodeport})
      Dashboard:   https://${var.dashboard_hostname}
      Status:      https://${var.gatus_hostname}

    Storage Classes:
      NFS (RWX):   nfs-client
      iSCSI (ret): ${var.storage_class_retain}
      iSCSI (del): ${var.storage_class_delete}

    Useful Commands:
      Dashboard token: kubectl -n REDACTED_d97cef76 get secret REDACTED_c48f3618 -o jsonpath='{.data.token}' | base64 -d
      Grafana pw:      kubectl -n monitoring get secret monitoring-grafana -o jsonpath='{.data.admin-password}' | base64 -d
  EOT
}
