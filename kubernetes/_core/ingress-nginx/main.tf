***REMOVED***
# Ingress NGINX Controller - ULTRA-HARDENED Configuration
***REMOVED***
# Provides HTTP/HTTPS ingress for Kubernetes services
# Includes comprehensive security hardening:
# - TLS 1.2/1.3 only with modern cipher suite
# - ModSecurity WAF with OWASP CRS (DetectionOnly mode)
# - Anti-Slowloris timeout configuration
# - Global security headers
# - Real IP propagation from edge proxies
# - JSON structured logging
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
        # ULTRA-HARDENED Security Configuration
        # =====================================================================
        config = {
          # === TLS HARDENING ===
          # Only allow TLS 1.2 and 1.3 - blocks downgrade attacks
          ssl-protocols = "TLSv1.2 TLSv1.3"

          # Modern cipher suite - prioritizes ECDHE for forward secrecy
          ssl-ciphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384"

          ssl-prefer-server-ciphers = "true"

          # Disable session tickets for better forward secrecy
          ssl-session-tickets    = "false"
          ssl-session-timeout    = "1d"
          ssl-session-cache-size = "10m"

          # === HSTS ===
          # Forces HTTPS for all connections
          hsts                    = "true"
          hsts-include-subdomains = "true"
          hsts-max-age            = "31536000"
          hsts-preload            = "true"

          # === SERVER HARDENING ===
          # Hide server version information
          server-tokens = "false"

          # Disable potentially dangerous snippet annotations
          allow-snippet-annotations = "false"

          # === REAL IP FROM EDGE PROXIES ===
          # Enables accurate client IP logging through VPS edge proxies
          enable-real-ip             = "true"
          use-forwarded-headers      = "true"
          compute-full-forwarded-for = "true"
          forwarded-for-header       = "X-Forwarded-For"

          # Trust edge VPS proxies (CH and NO) and their tunnel subnets
          proxy-real-ip-cidr = "185.44.82.32/32,185.125.171.172/32,10.255.2.0/24,10.255.3.0/24"

          # === RATE LIMITING ===
          # Return 429 Too Many Requests for rate-limited connections
          limit-req-status-code  = "429"
          limit-conn-status-code = "429"

          # === REQUEST SIZE LIMITS ===
          # Prevents buffer overflow and DoS attacks
          proxy-body-size             = "50m"
          client-header-buffer-size   = "1k"
          client-body-buffer-size     = "16k"
          large-client-header-buffers = "4 8k"

          # === TIMEOUT HARDENING (Anti-Slowloris) ===
          # Aggressive timeouts prevent slow connection attacks
          proxy-connect-timeout = "10"
          proxy-read-timeout    = "60"
          proxy-send-timeout    = "60"
          client-body-timeout   = "10"
          client-header-timeout = "10"
          keep-alive            = "75"
          keep-alive-requests   = "1000"

          # === PROXY BUFFER LIMITS ===
          # Prevents memory exhaustion attacks
          proxy-buffer-size       = "8k"
          proxy-buffers-number    = "4"
          proxy-busy-buffers-size = "16k"

          # === SECURITY MISC ===
          # Hide additional server headers
          hide-headers = "X-Powered-By,Server"

          # === ModSecurity WAF ===
          # OWASP Core Rule Set - DetectionOnly mode for initial deployment
          # Change to "SecRuleEngine On" after tuning (1-2 weeks monitoring)
          enable-modsecurity           = "true"
          enable-owasp-modsecurity-crs = "true"
          modsecurity-snippet          = "SecRuleEngine DetectionOnly\nSecAuditLog /var/log/modsec_audit.log\nSecAuditLogFormat JSON\nSecAuditEngine RelevantOnly"

          # === JSON STRUCTURED LOGGING ===
          # Better for SIEM integration and log analysis
          log-format-escape-json = "true"
          log-format-upstream    = "{\"time\":\"$time_iso8601\",\"remote_addr\":\"$remote_addr\",\"x_forwarded_for\":\"$proxy_add_x_forwarded_for\",\"request_id\":\"$req_id\",\"bytes_sent\":$bytes_sent,\"request_time\":$request_time,\"status\":$status,\"host\":\"$host\",\"request_proto\":\"$server_protocol\",\"uri\":\"$uri\",\"request_length\":$request_length,\"method\":\"$request_method\",\"http_referrer\":\"$http_referer\",\"http_user_agent\":\"$http_user_agent\",\"upstream_addr\":\"$upstream_addr\",\"upstream_status\":\"$upstream_status\",\"upstream_response_time\":\"$upstream_response_time\"}"
        }

        # =====================================================================
        # Global Response Headers
        # =====================================================================
        # NOTE: COOP/COEP/CORP headers intentionally NOT included globally
        # as they may break embedded content in apps like Grafana, ArgoCD.
        # Add per-ingress annotation for apps needing strict isolation.
        # =====================================================================
        addHeaders = {
          # HIGH: Prevents clickjacking attacks
          X-Frame-Options = "SAMEORIGIN"

          # HIGH: Prevents MIME-type sniffing attacks
          X-Content-Type-Options = "nosniff"

          # HIGH: Content Security Policy - Prevents XSS and data injection
          Content-Security-Policy = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' wss:; frame-ancestors 'self'; base-uri 'self'; form-action 'self';"

          # MEDIUM: Controls referrer information sent with requests
          Referrer-Policy = "strict-origin-when-cross-origin"

          # MEDIUM: Restricts browser features/APIs
          Permissions-Policy = "geolocation=(), microphone=(), camera=(), payment=(), usb=(), magnetometer=(), gyroscope=(), accelerometer=()"

          # MEDIUM: Cross-domain policy for Flash/PDF plugins
          X-Permitted-Cross-Domain-Policies = "none"
        }

        # =====================================================================
        # Pod Disruption Budget
        # =====================================================================
        podDisruptionBudget = {
          enabled      = true
          minAvailable = 1
        }

        # =====================================================================
        # Pod Anti-Affinity
        # =====================================================================
        # Prefers scheduling replicas on different nodes for HA
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

        # =====================================================================
        # Service Configuration
        # =====================================================================
        service = {
          type = "LoadBalancer"
        }

        # =====================================================================
        # Resource Management
        # =====================================================================
        resources = {
          requests = {
            cpu    = "500m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "2000m"
            memory = "1Gi"
          }
        }

        # =====================================================================
        # Prometheus Metrics
        # =====================================================================
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }
      }
    })
  ]
}
