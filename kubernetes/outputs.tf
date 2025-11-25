***REMOVED***
# Outputs
***REMOVED***

***REMOVED***
output "nfs_storage_class" {
  description = "Default storage class name"
  value       = "nfs-client"
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

# Pihole
output "pihole_web_url" {
  description = "Pi-hole admin URL (NodePort)"
  value       = "http://<node-ip>:30666/admin"
}

output "pihole_ingress_url" {
  description = "Pi-hole admin URL (Ingress)"
  value       = "http://pihole.example.net/admin"
}

# Dashboard
output "REDACTED_8dc96658" {
  description = "Command to get dashboard admin token"
  value       = "kubectl -n REDACTED_d97cef76 get secret REDACTED_c48f3618 -o jsonpath='{.data.token}' | base64 -d"
}

# Summary
output "deployment_summary" {
  sensitive   = true
  description = "Summary of deployed workloads"
  value       = <<-EOF
    
    ============================================
    Kubernetes Infrastructure Deployment Summary
    ============================================
    
    Storage:
    - NFS Provisioner: nfs-client (default StorageClass)
    
    Networking:
    - Ingress NGINX: Deployed
    - Pihole DNS: NodePort 30666
    
    Monitoring:
    - Prometheus: NodePort 30090
    - Grafana: NodePort 30000
    - Alertmanager: Deployed
    
    CI/CD:
    - GitLab Agent (k8s-agent): ${REDACTED_305df36d != "" ? "Deployed" : "Skipped (no token)"}
    - GitLab Runner: ${var.gitlab_runner_token != "" ? "Deployed" : "Skipped (no token)"}
    
    Applications:
    - Kubernetes Dashboard: Deployed
    - AWX: PVs created (apply CR separately)
    - Pihole: NodePort 30666, Ingress pihole.example.net
    
    Next Steps for AWX:
    1. Install operator: kubectl apply -k awx-install-clean/
    2. Apply AWX CR:     kubectl apply -f awx-install-clean/my-awx.yaml
    
  EOF
}

***REMOVED***
# Velero & MinIO Outputs - Add these to your existing outputs.tf
***REMOVED***

# -----------------------------------------------------------------------------
# MinIO Outputs
# -----------------------------------------------------------------------------
output "minio_console_url" {
  description = "MinIO Console URL (NodePort)"
  value       = "http://<node-ip>:30010"
}

output "minio_api_url" {
  description = "MinIO API URL (NodePort)"
  value       = "http://<node-ip>:30011"
}

output "minio_console_ingress" {
  description = "MinIO Console Ingress URL"
  value       = "https://minio.${var.domain}"
}

# -----------------------------------------------------------------------------
# Velero Outputs
# -----------------------------------------------------------------------------
output "velero_ui_url" {
  description = "Velero UI URL (NodePort)"
  value       = "http://<node-ip>:30012"
}

output "velero_ui_ingress" {
  description = "Velero UI Ingress URL"
  value       = "https://velero.${var.domain}"
}

output "velero_backup_schedule" {
  description = "Velero backup schedules"
  value = {
    daily  = "2 AM daily, 30 days retention"
    weekly = "3 AM Sunday, 90 days retention"
  }
}

output "velero_commands" {
  description = "Useful Velero CLI commands"
  value = {
    list_backups   = "velero backup get"
    create_backup  = "velero backup create my-backup --include-namespaces pihole,monitoring"
    restore_backup = "velero restore create --from-backup <backup-name>"
    get_schedules  = "velero schedule get"
  }
}

***REMOVED***
# Argo CD Outputs
***REMOVED***

output "argocd_url_nodeport" {
  description = "Argo CD URL (NodePort)"
  value       = "https://<node-ip>:${var.argocd_nodeport}"
}

output "argocd_url_ingress" {
  description = "Argo CD URL (Ingress)"
  value       = var.REDACTED_84146aee ? "https://argocd.${var.domain}" : null
}

output "REDACTED_3a519042" {
  description = "Command to get Argo CD initial admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "argocd_cli_commands" {
  description = "Useful Argo CD CLI commands"
  value = {
    install_cli  = "curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && sudo install argocd /usr/local/bin/"
    login        = "argocd login argocd.${var.domain} --username admin --grpc-web"
    list_apps    = "argocd app list"
    sync_app     = "argocd app sync <app-name>"
    get_password = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  }
}
