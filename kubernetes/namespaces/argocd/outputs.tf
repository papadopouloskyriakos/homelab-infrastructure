***REMOVED***
# Argo CD Outputs
***REMOVED***

output "namespace" {
  description = "Namespace where Argo CD is deployed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "chart_version" {
  description = "Deployed Argo CD Helm chart version"
  value       = helm_release.argocd.metadata[0].version
}

output "server_nodeport" {
  description = "NodePort for Argo CD server HTTPS"
  value       = var.argocd_nodeport
}

output "server_url_nodeport" {
  description = "Argo CD URL via NodePort"
  value       = "https://<node-ip>:${var.argocd_nodeport}"
}

output "server_url_ingress" {
  description = "Argo CD URL via Ingress"
  value       = var.REDACTED_84146aee ? "https://argocd.${var.domain}" : null
}

output "REDACTED_913cfbf9" {
  description = "Command to retrieve initial admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}
