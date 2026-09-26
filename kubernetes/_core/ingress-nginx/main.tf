# =============================================================================
# Ingress NGINX Controller - ULTRA-HARDENED Configuration
# =============================================================================
# Provides HTTP/HTTPS ingress for Kubernetes services
# Includes comprehensive security hardening:
# - TLS 1.2/1.3 only with modern cipher suite
# - ModSecurity WAF with OWASP CRS (DetectionOnly mode)
# - Anti-Slowloris timeout configuration
# - Global security headers
# - Real IP propagation from edge proxies
# - JSON structured logging
# =============================================================================

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.15.1"
  wait             = false
  timeout          = 300

  values = [
    yamlencode({
      controller = {
        replicaCount = 2

        extraArgs = {
          default-ssl-certificate = var.REDACTED_3b82c3d6
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
          enable-real-ip        = "true"
          use-forwarded-headers = "true"
          # The BACKEND receives X-Forwarded-For = $remote_addr: the ONE client
          # address the realip walk below resolved, not the whole chain. With
          # compute-full-forwarded-for on, nginx sent
          # "<client>, <client>, $realip_remote_addr", and that last element is
          # the peer BEFORE realip, i.e. the node's cilium_host router address
          # on the SNAT'd relay hop. authentik reads the LAST element of the
          # header (measured 2026-09-26 with a crafted chain against
          # auth-server), so every sign-up and every login event was stamped
          # with a 10.2.x node address. IFRNLLEI01PRD-2833 fixed what ingress
          # itself logged; this fixes what it hands on (MESHSAT-1080). One
          # address is what every backend behind this controller reads right.
          compute-full-forwarded-for = "false"
          forwarded-for-header       = "X-Forwarded-For"

          # Trust edge VPS proxies (CH, NO, TX), their tunnel subnets and the
          # notrf01 edge-relay worker nodes (a TCP relay without PROXY protocol:
          # ingress sees the relay node as the peer, XFF carries the real client).
          # Estate-global (same edge fronts every site) - intentionally not per-site
          #
          # The relay node addresses alone were NOT enough (IFRNLLEI01PRD-2833,
          # 2026-09-11). The relay is hostNetwork on 10.255.4.11/5.11/10.11, but
          # Cilium SNATs a host-to-ClusterIP connection to the node's cilium_host
          # router address, so ingress sees a 10.2.x peer that was not trusted,
          # stopped walking the XFF chain there, and handed the BACKEND its own
          # router IP as the client. authentik recorded 10.2.0.235 as every
          # signup's source address, and CrowdSec was rate-limiting and banning
          # the same handful of addresses for the whole cluster.
          #
          # These are the six notrf01 CiliumInternalIPs (kubectl get ciliumnodes).
          # /32s, not the pod CIDR, deliberately: only the nodes own these, so an
          # arbitrary pod still cannot forge X-Forwarded-For. They change if a
          # node is rebuilt - the symptom is a 10.2.x address turning up as a
          # client IP again. Inert on NL (pod CIDR 10.0/16) and GR (10.1/16).
          proxy-real-ip-cidr = "198.51.100.X/32,198.51.100.X/32,185.121.169.27/32,10.255.2.0/24,10.255.3.0/24,10.255.6.0/24,10.255.4.11/32,10.255.5.11/32,10.255.10.11/32,10.2.0.235/32,10.2.1.174/32,10.2.2.70/32,10.2.3.13/32,10.2.4.92/32,10.2.5.119/32"

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
          # The MODE IS PER-SITE: var.REDACTED_f03c8bab, with any extra
          # SecRule lines in var.REDACTED_14740f3f. Read both variable
          # descriptions before changing either; the short version is below.
          #
          # notrf01 runs "On" (MESHSAT-1207, enforcing since 2026-09-17). Its
          # tuning window showed two things. First that the engine works at all,
          # which is worth checking because "zero audit records in 24 h" reads
          # identically to a WAF that is not evaluating anything: a harmless
          # `?q=<script>` produced CRS 941100/941110/941160/941390 plus the 949110
          # anomaly rule and a JSON audit record. Second that across 24 h of
          # production traffic those were the ONLY matches. It is quiet because the
          # VPS CrowdSec AppSec engine blocks probe traffic (1.19M processed, 2.68k
          # blocked) before it reaches here, so this is defence-in-depth for a
          # bypassed edge, not the primary control.
          #
          # NL and GR stay "DetectionOnly", deliberately. Their ingress carries only
          # internal ops names behind the ASA and is not routed from the internet, so
          # the bypass case above does not exist for them, while their traffic is
          # machine-to-machine (S3 sigv4 PUTs of binary objects, Prometheus
          # remote-write protobuf, ArgoCD gRPC) which is exactly what CRS is worst
          # at. This is not hypothetical here: the seaweedfs-s3 ingress already
          # carries enable-modsecurity=false because ModSecurity's body filter
          # truncated a 2 GB barman restore at exactly 512 MiB, and production DB
          # backups were not restorable through that gateway until it was turned off.
          # ⚠ Do not flip either to "On" without explicit operator instruction
          # (root CLAUDE.md, Things to Never Do).
          enable-modsecurity           = "true"
          enable-owasp-modsecurity-crs = "true"
          # SecAuditLog -> /dev/stdout (was /var/log/modsec_audit.log): the serial audit
          # file had NO rotation and grew unbounded (33.6G on one controller, 2026-06-24
          # -> node02 ephemeral-storage eviction). stdout is kubelet-rotated (~50Mi cap)
          # and flows to Loki.
          #
          # The two rules notrf01 supplies via REDACTED_14740f3f, and why they are
          # site values rather than canonical content:
          #   id:1000 holds /api/webhook/ in DetectionOnly PERMANENTLY. That prefix is
          #     where a satellite MO message arrives (Cloudloop, RockBLOCK/Ground
          #     Control, Globalstar, inbound SMS) and an SOS arrives on exactly those
          #     paths. The sender is a third party's ground station that cannot
          #     interpret a 403 and will not retry intelligently, so a CRS false
          #     positive on a binary or base64 payload would silently drop an emergency
          #     message. /api/webhook/stripe/{secret} rides the same carve-out: its real
          #     control is the raw-body HMAC signature.
          #   id:1001 applies ctl:ruleRemoveById=911100 because CRS ships
          #     tx.allowed_methods without PUT or DELETE and the Hub REST API uses both;
          #     within an hour of the flip every PUT and DELETE to hub.meshsat.net got an
          #     HTML 403. ⚠ It must NOT be canonical: on a DetectionOnly site it would
          #     silently pre-authorise a permissive method policy for the day that site
          #     ever flips to On.
          modsecurity-snippet = trimspace(<<-EOT
            SecRuleEngine ${var.REDACTED_f03c8bab}
            SecAuditLog /dev/stdout
            SecAuditLogFormat JSON
            SecAuditEngine RelevantOnly
            ${var.REDACTED_14740f3f}
          EOT
          )

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
        addHeaders = merge({
          # HIGH: Prevents clickjacking attacks
          X-Frame-Options = "SAMEORIGIN"

          # HIGH: Prevents MIME-type sniffing attacks
          X-Content-Type-Options = "nosniff"


          # MEDIUM: Controls referrer information sent with requests
          Referrer-Policy = "strict-origin-when-cross-origin"

          # MEDIUM: Restricts browser features/APIs
          Permissions-Policy = "geolocation=(), microphone=(), camera=(), payment=(), usb=(), magnetometer=(), gyroscope=(), accelerometer=()"

          # MEDIUM: Cross-domain policy for Flash/PDF plugins
          X-Permitted-Cross-Domain-Policies = "none"
          }, var.csp_header == "" ? {} : {
          # HIGH: Content Security Policy - Prevents XSS and data injection
          # (site-tunable: an empty csp_header omits the header entirely —
          # sites whose apps set their own CSP must not get a second one)
          Content-Security-Policy = var.csp_header
        })

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
            cpu                 = "500m"
            memory              = "512Mi"
            "ephemeral-storage" = "1Gi"
          }
          limits = {
            cpu    = "2000m"
            memory = "1Gi"
            # Bounds runaway disk (modsec audit regrowth / client-body temp leak) so the kubelet
            # evicts this pod BEFORE the node fills (2 replicas + PDB minAvailable=1 cover the roll).
            "ephemeral-storage" = "4Gi"
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

# Data source to get the LoadBalancer IP after deployment
data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }

  depends_on = [helm_release.ingress_nginx]
}
