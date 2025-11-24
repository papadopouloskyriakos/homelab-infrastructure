***REMOVED***
# Ingress NGINX Controller
***REMOVED***
# Provides Ingress controller for HTTP/HTTPS traffic routing
#
# Import command:
# tofu import 'helm_release.ingress_nginx' 'ingress-nginx/ingress-nginx'
***REMOVED***

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.12.1"

  values = [
    yamlencode({
      controller = {
        service = {
          type = "NodePort"  # No LoadBalancer without MetalLB
        }
        metrics = {
          enabled = true
        }
      }
    })
  ]
}
