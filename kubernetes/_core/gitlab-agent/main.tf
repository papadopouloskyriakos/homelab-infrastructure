***REMOVED***
# GitLab Kubernetes Agent
***REMOVED***
# Provides secure cluster connectivity to GitLab for kubectl access
***REMOVED***

variable "REDACTED_b6136a28" {
  description = "GitLab Agent token for k8s-agent"
  type        = string
  sensitive   = true
}

resource "helm_release" "gitlab_agent_k8s" {
  count = REDACTED_305df36d != "" ? 1 : 0

  name             = "k8s-agent"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-agent"
  namespace        = "REDACTED_01b50c5d"
  create_namespace = true
  version          = "2.21.0"

  values = [
    yamlencode({
      replicas = 2

      podDisruptionBudget = {
        enabled      = true
        minAvailable = 1
      }

      config = {
        token      = REDACTED_305df36d
        kasAddress = "wss://gitlab.example.net/-/kubernetes-agent/"
      }

      image = {
        tag = "v18.6.0"
      }
    })
  ]
}
