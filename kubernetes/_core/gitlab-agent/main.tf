# =============================================================================
# GitLab Kubernetes Agent
# =============================================================================
# Provides secure cluster connectivity to GitLab for kubectl access
# Token passed via TF_VAR_* from Atlantis start script (site-specific root var)
# =============================================================================

resource "helm_release" "gitlab_agent_k8s" {
  count = var.gitlab_agent_token != "" ? 1 : 0

  name             = var.agent_name
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-agent"
  namespace        = "gitlab-agent-${var.agent_name}"
  create_namespace = true
  version          = "2.28.0"

  values = [
    yamlencode({
      replicas = 2

      podDisruptionBudget = {
        enabled      = true
        minAvailable = 1
      }

      config = {
        token      = var.gitlab_agent_token
        kasAddress = var.kas_address
      }

      image = {
        tag = "v18.6.0"
      }

      resources = {
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
      }
    })
  ]
}
