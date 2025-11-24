resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.14.0"
  wait             = false # Don't wait for LoadBalancer IP
  timeout          = 300

  values = [
    yamlencode({
      controller = {
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
