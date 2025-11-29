output "namespace" {
  value = length(helm_release.gitlab_agent_k8s) > 0 ? helm_release.gitlab_agent_k8s[0].metadata.namespace : null
}
output "deployed" {
  value = length(helm_release.gitlab_agent_k8s) > 0
}
