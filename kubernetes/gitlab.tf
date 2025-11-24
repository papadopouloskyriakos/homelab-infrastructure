***REMOVED***
# GitLab Kubernetes Agent
***REMOVED***
# Provides secure cluster connectivity to GitLab
# Single agent: k8s-agent (used for CI/CD and kubectl access)
#
# Import command:
# tofu import 'helm_release.gitlab_agent_k8s[0]' 'REDACTED_01b50c5d/k8s-agent'
***REMOVED***

resource "helm_release" "gitlab_agent_k8s" {
  count = REDACTED_305df36d != "" ? 1 : 0

  name             = "k8s-agent"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-agent"
  namespace        = "REDACTED_01b50c5d"
  create_namespace = true
  version          = "2.14.0"

  values = [
    yamlencode({
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

***REMOVED***
# GitLab Runner
***REMOVED***
# Runs CI/CD jobs in Kubernetes
# Deployed in same namespace as the agent
#
# Import command:
# tofu import 'helm_release.gitlab_runner[0]' 'REDACTED_01b50c5d/gitlab-runner'
***REMOVED***

resource "helm_release" "gitlab_runner" {
  count = var.gitlab_runner_token != "" ? 1 : 0

  name             = "gitlab-runner"
  repository       = "https://charts.gitlab.io"
  chart            = "gitlab-runner"
  namespace        = "REDACTED_01b50c5d" # Same namespace as agent
  create_namespace = false                    # Already created by agent
  version          = "0.75.0"

  values = [
    yamlencode({
      gitlabUrl   = var.gitlab_url
      runnerToken = var.gitlab_runner_token

      runners = {
        privileged = true
        tags       = "k8s,nlk8s" # Updated tags

        config = <<-EOF
          [[runners]]
            [runners.kubernetes]
              namespace = "{{.Release.Namespace}}"
              poll_timeout = 180
              cpu_request = "100m"
              memory_request = "128Mi"
        EOF
      }

      certsSecretName = "gitlab-runner-certs"
    })
  ]

  depends_on = [helm_release.gitlab_agent_k8s]
}
