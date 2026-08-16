variable "gitlab_agent_token" {
  description = "GitLab Agent token for this cluster's agent (deploy skipped when empty)"
  type        = string
  sensitive   = true
}

variable "agent_name" {
  description = "Helm release name for the GitLab agent — LIVE OBJECT NAME, never change on an existing site (NL: k8s-agent, GR: gr-k8s-agent). Namespace derives as gitlab-agent-<agent_name>."
  type        = string
  default     = "k8s-agent"
}

variable "kas_address" {
  description = "GitLab KAS (Kubernetes Agent Server) address"
  type        = string
  default     = "wss://gitlab.example.net/-/kubernetes-agent/"
}
