output "namespace" {
  description = "Namespace where GitLab Agent is installed (null when not deployed)"
  value       = length(helm_release.gitlab_agent_k8s) > 0 ? helm_release.gitlab_agent_k8s[0].metadata.namespace : null
}

output "deployed" {
  description = "Whether the GitLab Agent helm release is deployed"
  value       = length(helm_release.gitlab_agent_k8s) > 0
}
