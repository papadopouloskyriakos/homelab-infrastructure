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
