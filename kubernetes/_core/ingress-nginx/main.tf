***REMOVED***
# Ingress NGINX Controller
***REMOVED***
# Provides HTTP/HTTPS ingress for Kubernetes services
# Includes global security headers for all ingresses
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

        extraArgs = {
          default-ssl-certificate = "REDACTED_f89271df"
        }

        # =====================================================================
        # Global Security Configuration
        # =====================================================================
        # These settings apply to ALL ingresses managed by this controller
        # Addresses Web Check security findings
        # =====================================================================
        config = {
          # MEDIUM: HSTS with preload - Forces HTTPS for all connections
          hsts                    = "true"
          hsts-include-subdomains = "true"
          hsts-max-age            = "31536000"
          hsts-preload            = "true"

          # Hide server version for security
          server-tokens = "false"

          # Security: Disable potentially dangerous snippet annotations
          # (This is why per-ingress snippets failed - it's a security feature)
          allow-snippet-annotations = "false"
        }

        # =====================================================================
        # Global Response Headers
        # =====================================================================
        # These headers are added to ALL responses from all ingresses
        # =====================================================================
        addHeaders = {
          # HIGH: Prevents clickjacking attacks
          X-Frame-Options = "SAMEORIGIN"

          # HIGH: Prevents MIME-type sniffing attacks
          X-Content-Type-Options = "nosniff"

          # HIGH: Content Security Policy - Prevents XSS and data injection
          Content-Security-Policy = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' wss:; frame-ancestors 'self';"

          # MEDIUM: Legacy XSS protection for older browsers
          X-XSS-Protection = "1; mode=block"

          # MEDIUM: Controls referrer information sent with requests
          Referrer-Policy = "strict-origin-when-cross-origin"

          # MEDIUM: Restricts browser features/APIs
          Permissions-Policy = "geolocation=(), microphone=(), camera=(), payment=(), usb=(), magnetometer=(), gyroscope=(), accelerometer=()"
        }

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
