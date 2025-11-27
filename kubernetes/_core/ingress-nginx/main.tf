***REMOVED***
# Ingress NGINX Controller
***REMOVED***
# Provides HTTP/HTTPS ingress for Kubernetes services
***REMOVED***
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.14.0"
  wait             = false
  timeout          = 300

  values = [
    yamlencode({
      controller = {
        replicaCount = 2

        podDisruptionBudget = {
          enabled      = true
          minAvailable = 1
        }

        affinity = {
          podAntiAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [{
              weight = 100
              podAffinityTerm = {
                labelSelector = {
                  matchExpressions = [{
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values   = ["ingress-nginx"]
                  }]
                }
                topologyKey = "kubernetes.io/hostname"
              }
            }]
          }
        }

        service = {
          type = "LoadBalancer"
        }

        resources = {
          requests = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }
    })
  ]
}
