***REMOVED***
# Well-Known Endpoints Service
***REMOVED***
# Serves /.well-known/ endpoints (RFC 8615) for all domains
# Currently serves: security.txt (RFC 9116), pgp-key.txt
# Extensible for: change-password, webfinger, nodeinfo, etc.
***REMOVED***

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------
resource "REDACTED_46569c16" "well_known" {
  metadata {
    name = "well-known"
    labels = {
      name                                 = "well-known"
      environment                          = "production"
      "managed-by"                         = "opentofu"
      "pod-security.kubernetes.io/enforce" = "restricted"
    }
  }
}

# -----------------------------------------------------------------------------
# ConfigMap - Well-Known Files Content
# -----------------------------------------------------------------------------
resource "REDACTED_9343442e" "well_known_files" {
  metadata {
    name      = "well-known-files"
    namespace = REDACTED_46569c16.well_known.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "well-known"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  data = {
    # =========================================================================
    # security.txt (RFC 9116) - PGP Signed
    # https://www.rfc-editor.org/rfc/rfc9116
    # =========================================================================
    "security.txt" = <<-EOT
-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Contact: mailto:security@example.net
Expires: 2026-12-31T23:59:59.000Z
Preferred-Languages: en, nl, el
Canonical: https://status.example.net/.well-known/security.txt
Encryption: https://status.example.net/.well-known/pgp-key.txt
-----BEGIN PGP SIGNATURE-----

iJMEARYKADsWIQTlQgNySJ9NfORTEHfoNHyQAJgoJwUCaUK+sB0cc2VjdXJpdHlA
bnVjbGVhcmxpZ2h0ZXJzLm5ldAAKCRDoNHyQAJgoJ/bIAP41Kz0Fzr2xVOyRQL0L
+h1IZrHKvGjtMqjjdUKiDJi8PgD+PWwZx0ixHJGWwcHYXcGKI8L+SPEWNqAiRQDF
64TEnAY=
=LJf+
-----END PGP SIGNATURE-----
EOT

    # =========================================================================
    # PGP Public Key for encrypted security reports
    # =========================================================================
    "pgp-key.txt" = <<-EOT
-----BEGIN PGP PUBLIC KEY BLOCK-----

mDMEaUK+LBYJKwYBBAHaRw8BAQdA4uJ2Xd8+DArgPQqAR979A0dFFqZhiROrX4kY
PCEXoWS0PU51Y2xlYXIgTGlnaHRlcnMgU2VjdXJpdHkgVGVhbSA8c2VjdXJpdHlA
bnVjbGVhcmxpZ2h0ZXJzLm5ldD6IkgQTFgoAOxYhBOVCA3JIn0185FMQd+g0fJAA
mCgnBQJpQr4sAhsDBQsJCAcCAiICBhUKCQgLAgQWAgMBAh4HAheAAAoJEOg0fJAA
mCgnkhIA9RvcIeTcFJhVNLCk1rqCyE0oZA4cquzOBZkqe/pXi7kBAOH4sQiG86VY
Kjsb1FfyFDfBfGOeGCWDH2AjYjAwFTgAuDgEaUK+LBIKKwYBBAGXVQEFAQEHQPyR
amcUvZRW9k2IHtmwXgKKcQn2ZHpIsASbwR5NPpEaAwEIB4h4BBgWCgAgFiEE5UID
ckifTXzkUxB36DR8kACYKCcFAmlCviwCGwwACgkQ6DR8kACYKCejMgEA0/E5K7/N
x/wr2CpAikRm4o8641DIRAbykQlstM94OS4BAPzEQ0wSvNolk/e90TIX1DFnW/Rt
+nk8hGU2Y717XM0K
=znoz
-----END PGP PUBLIC KEY BLOCK-----
EOT

    # =========================================================================
    # nginx.conf - Minimal config to serve .well-known files
    # =========================================================================
    "nginx.conf" = <<-EOT
events {
  worker_connections 128;
}

http {
  server {
    listen 8080;
    server_name _;
    
    # Health check endpoint
    location /healthz {
      return 200 'OK';
      add_header Content-Type text/plain;
    }
    
    # security.txt - serve with and without .well-known prefix
    location = /.well-known/security.txt {
      alias /data/security.txt;
      add_header Content-Type "text/plain; charset=utf-8";
      add_header Cache-Control "public, max-age=86400";
    }
    
    location = /security.txt {
      alias /data/security.txt;
      add_header Content-Type "text/plain; charset=utf-8";
      add_header Cache-Control "public, max-age=86400";
    }
    
    # PGP public key
    location = /.well-known/pgp-key.txt {
      alias /data/pgp-key.txt;
      add_header Content-Type "text/plain; charset=utf-8";
      add_header Cache-Control "public, max-age=86400";
    }
    
    # Future: Add more .well-known endpoints here
    # location = /.well-known/change-password { ... }
    # location = /.well-known/webfinger { ... }
    
    # Default: 404 for everything else
    location / {
      return 404 'Not Found';
      add_header Content-Type text/plain;
    }
  }
}
EOT
  }
}

# -----------------------------------------------------------------------------
# Deployment - Minimal nginx serving .well-known files
# -----------------------------------------------------------------------------
resource "REDACTED_08d34ae1" "well_known" {
  metadata {
    name      = "well-known"
    namespace = REDACTED_46569c16.well_known.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "well-known"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "well-known"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "well-known"
          environment              = "production"
          "managed-by"             = "opentofu"
        }
        annotations = {
          "checksum/config" = sha256(jsonencode(REDACTED_9343442e.well_known_files.data))
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 101 # nginx user
          run_as_group    = 101
          fs_group        = 101
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        container {
          name  = "nginx"
          image = "nginxinc/nginx-unprivileged:${var.nginx_version}"

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 2
            period_seconds        = 10
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path   = "nginx.conf"
            read_only  = true
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
            read_only  = true
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }

          volume_mount {
            name       = "cache"
            mount_path = "/var/cache/nginx"
          }

          volume_mount {
            name       = "run"
            mount_path = "/run"
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 101
            capabilities {
              drop = ["ALL"]
            }
          }
        }

        volume {
          name = "config"
          config_map {
            name = REDACTED_9343442e.well_known_files.metadata[0].name
            items {
              key  = "nginx.conf"
              path = "nginx.conf"
            }
          }
        }

        volume {
          name = "data"
          config_map {
            name = REDACTED_9343442e.well_known_files.metadata[0].name
            items {
              key  = "security.txt"
              path = "security.txt"
            }
            items {
              key  = "pgp-key.txt"
              path = "pgp-key.txt"
            }
          }
        }

        volume {
          name = "tmp"
          empty_dir {}
        }

        volume {
          name = "cache"
          empty_dir {}
        }

        volume {
          name = "run"
          empty_dir {}
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Service
# -----------------------------------------------------------------------------
resource "kubernetes_service_v1" "well_known" {
  metadata {
    name      = "well-known"
    namespace = REDACTED_46569c16.well_known.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "well-known"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      "app.kubernetes.io/name" = "well-known"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }
  }
}

# -----------------------------------------------------------------------------
# Ingress - Serves .well-known for all configured domains
# -----------------------------------------------------------------------------
resource "kubernetes_ingress_v1" "well_known" {
  metadata {
    name      = "well-known"
    namespace = REDACTED_46569c16.well_known.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "well-known"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
    annotations = {
      # Ensure this ingress takes priority for .well-known paths
      "nginx.ingress.kubernetes.io/use-regex" = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = var.domains
      secret_name = "well-known-tls"
    }

    # Create a rule for each domain
    dynamic "rule" {
      for_each = var.domains
      content {
        host = rule.value

        http {
          path {
            path      = "/.well-known"
            path_type = "Prefix"

            backend {
              service {
                name = kubernetes_service_v1.well_known.metadata[0].name
                port {
                  number = 80
                }
              }
            }
          }
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Certificate (cert-manager) - Multi-domain certificate
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_72c40b12" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "well-known-tls"
      namespace = REDACTED_46569c16.well_known.metadata[0].name
      labels = {
        "app.kubernetes.io/name" = "well-known"
        environment              = "production"
        "managed-by"             = "opentofu"
      }
    }
    spec = {
      secretName = "well-known-tls"
      issuerRef = {
        name = var.cert_issuer_name
        kind = var.cert_issuer_kind
      }
      dnsNames = var.domains
    }
  }
}

# -----------------------------------------------------------------------------
# CiliumNetworkPolicy - Restrict traffic
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_42973508" {
  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "CiliumNetworkPolicy"
    metadata = {
      name      = "well-known-policy"
      namespace = REDACTED_46569c16.well_known.metadata[0].name
      labels = {
        "app.kubernetes.io/name" = "well-known"
        environment              = "production"
        "managed-by"             = "opentofu"
      }
    }
    spec = {
      endpointSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "well-known"
        }
      }

      ingress = [
        {
          fromEndpoints = [{
            matchLabels = {
              "k8s:io.kubernetes.pod.namespace" = "ingress-nginx"
              "app.kubernetes.io/name"          = "ingress-nginx"
            }
          }]
          toPorts = [{
            ports = [{
              port     = "8080"
              protocol = "TCP"
            }]
          }]
        }
      ]

      egress = [
        {
          toEndpoints = [{
            matchLabels = {
              "k8s:io.kubernetes.pod.namespace" = "kube-system"
              "k8s-app"                         = "kube-dns"
            }
          }]
          toPorts = [{
            ports = [
              { port = "53", protocol = "UDP" },
              { port = "53", protocol = "TCP" }
            ]
          }]
        }
      ]
    }
  }
}
