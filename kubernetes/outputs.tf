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
    
    Monitoring:
    - Prometheus: NodePort 30090
    - Grafana: NodePort 30000
    - Alertmanager: Deployed
    
    CI/CD:
    - GitLab Agent (k8s-agent): ${REDACTED_305df36d != "" ? "Deployed" : "Skipped (no token)"}
    - GitLab Runner: ${var.gitlab_runner_token != "" ? "Deployed" : "Skipped (no token)"}
    
    GitOps:
    - Argo CD: Deployed (manages application workloads)
    - Velero: Managed by Argo CD (argocd-apps/velero/)
    - Pi-hole: Managed by Argo CD (argocd-apps/pihole/)
    
    Applications:
    - Kubernetes Dashboard: Deployed
    - AWX: PVs created (apply CR separately)
    
    Next Steps for AWX:
    1. Install operator: kubectl apply -k awx-install-clean/
    2. Apply AWX CR:     kubectl apply -f awx-install-clean/my-awx.yaml
    
  EOF
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
