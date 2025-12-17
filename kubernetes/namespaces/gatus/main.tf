# =============================================================================
# Gatus - Status Page with Cross-Site Monitoring
# =============================================================================
# Public status page served via BGP anycast
# Monitors both NL and GR sites from each location
# =============================================================================

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------
resource "REDACTED_46569c16" "gatus" {
  metadata {
    name = "gatus"
    labels = {
      name                                 = "gatus"
      environment                          = "production"
      "managed-by"                         = "opentofu"
      "pod-security.kubernetes.io/enforce" = "restricted"
    }
  }
}

# -----------------------------------------------------------------------------
# ConfigMap - Gatus Configuration
# -----------------------------------------------------------------------------
resource "REDACTED_a9df2e77_v1" "gatus_config" {
  metadata {
    name      = "gatus-config"
    namespace = REDACTED_46569c16.gatus.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "gatus"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  data = {
    "config.yaml" = yamlencode({
      storage = {
        type = "sqlite"
        path = "/data/data.db"
      }

      ui = {
        title       = var.gatus_ui_title
        description = "Infrastructure Health Dashboard (Served from ${var.site_name})"
        header      = var.gatus_ui_header
        logo        = ""
        link        = var.gatus_ui_link
      }

      endpoints = concat(
        # =====================================================================
        # 🌐 PUBLIC SERVICES
        # =====================================================================
        [
          {
            name     = "Portfolio"
            group    = "🌐 Public"
            url      = "https://kyriakos.papadopoulos.tech"
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 2000"
            ]
          },
          {
            name     = "Status Page"
            group    = "🌐 Public"
            url      = "https://status.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          }
        ],
        # =====================================================================
        # 🇳🇱 NETHERLANDS - CORE INFRASTRUCTURE
        # =====================================================================
        [
          {
            name     = "Kubernetes API"
            group    = "🇳🇱 Netherlands"
            url      = "https://api-k8s.example.net:6443/healthz"
            client   = { insecure = true }
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[BODY] == ok"
            ]
          },
          {
            name     = "ArgoCD"
            group    = "🇳🇱 Netherlands"
            url      = "https://argocd.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "GitLab"
            group    = "🇳🇱 Netherlands"
            url      = "https://gitlab.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "Atlantis"
            group    = "🇳🇱 Netherlands"
            url      = "https://atlantis.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          }
        ],
        # =====================================================================
        # 🇳🇱 NETHERLANDS - OBSERVABILITY
        # =====================================================================
        [
          {
            name     = "Grafana"
            group    = "🇳🇱 NL Observability"
            url      = "https://grafana.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "Prometheus"
            group    = "🇳🇱 NL Observability"
            url      = "https://nl-prometheus.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "Thanos"
            group    = "🇳🇱 NL Observability"
            url      = "https://nl-thanos.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "Hubble UI"
            group    = "🇳🇱 NL Observability"
            url      = "https://nl-hubble.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "K8s Dashboard"
            group    = "🇳🇱 NL Observability"
            url      = "https://nl-k8s.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "Goldpinger"
            group    = "🇳🇱 NL Observability"
            url      = "https://goldpinger.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          }
        ],
        # =====================================================================
        # 🇳🇱 NETHERLANDS - STORAGE & BACKUP
        # =====================================================================
        [
          {
            name     = "SeaweedFS Master"
            group    = "🇳🇱 NL Storage"
            url      = "https://nl-seaweedfs.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "SeaweedFS S3"
            group    = "🇳🇱 NL Storage"
            url      = "https://nl-s3.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "Velero UI"
            group    = "🇳🇱 NL Storage"
            url      = "https://velero.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          }
        ],
        # =====================================================================
        # 🇳🇱 NETHERLANDS - AUTOMATION
        # =====================================================================
        [
          {
            name     = "AWX"
            group    = "🇳🇱 NL Automation"
            url      = "https://awx.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 5000"
            ]
          }
        ],
        # =====================================================================
        # 🇬🇷 GREECE - CORE INFRASTRUCTURE (DR SITE)
        # =====================================================================
        [
          {
            name     = "Kubernetes API"
            group    = "🇬🇷 Greece"
            url      = "https://gr-api-k8s.example.net:6443/healthz"
            client   = { insecure = true }
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[BODY] == ok"
            ]
          },
          {
            name     = "ArgoCD"
            group    = "🇬🇷 Greece"
            url      = "https://gr-argocd.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "GitLab (Mirror)"
            group    = "🇬🇷 Greece"
            url      = "https://gr-gitlab.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "Atlantis"
            group    = "🇬🇷 Greece"
            url      = "https://gr-atlantis.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          }
        ],
        # =====================================================================
        # 🇬🇷 GREECE - OBSERVABILITY
        # =====================================================================
        [
          {
            name     = "Grafana"
            group    = "🇬🇷 GR Observability"
            url      = "https://gr-grafana.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "Prometheus"
            group    = "🇬🇷 GR Observability"
            url      = "https://gr-prometheus.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "Thanos"
            group    = "🇬🇷 GR Observability"
            url      = "https://gr-thanos.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "Hubble UI"
            group    = "🇬🇷 GR Observability"
            url      = "https://gr-hubble.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "K8s Dashboard"
            group    = "🇬🇷 GR Observability"
            url      = "https://gr-k8s.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "Goldpinger"
            group    = "🇬🇷 GR Observability"
            url      = "https://gr-goldpinger.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          }
        ],
        # =====================================================================
        # 🇬🇷 GREECE - STORAGE
        # =====================================================================
        [
          {
            name     = "SeaweedFS Master"
            group    = "🇬🇷 GR Storage"
            url      = "https://gr-seaweedfs.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          },
          {
            name     = "SeaweedFS S3"
            group    = "🇬🇷 GR Storage"
            url      = "https://gr-s3.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 3000"
            ]
          }
        ],
        # =====================================================================
        # 🏠 SHARED SERVICES
        # =====================================================================
        [
          {
            name     = "Nextcloud"
            group    = "🏠 Home Services"
            url      = "https://nextcloud.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 5000"
            ]
          },
          {
            name     = "Home Assistant"
            group    = "🏠 Home Services"
            url      = "https://homeassistant.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
          }
        ],
        # =====================================================================
        # 🔗 EXTERNAL CONNECTIVITY
        # =====================================================================
        [
          {
            name     = "Internet (Cloudflare)"
            group    = "🔗 Connectivity"
            url      = "https://1.1.1.1"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 500"
            ]
          }
        ],
        # Additional custom endpoints from tfvars
        var.additional_endpoints
      )
    })
  }
}

# -----------------------------------------------------------------------------
# PersistentVolumeClaim - SQLite storage for history
# -----------------------------------------------------------------------------
resource "REDACTED_912a6d18_claim_v1" "gatus_data" {
  metadata {
    name      = "gatus-data"
    namespace = REDACTED_46569c16.gatus.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "gatus"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.storage_class

    resources {
      requests = {
        storage = var.gatus_storage_size
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Deployment
# -----------------------------------------------------------------------------
resource "REDACTED_08d34ae1" "gatus" {
  metadata {
    name      = "gatus"
    namespace = REDACTED_46569c16.gatus.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "gatus"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "gatus"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "gatus"
          environment              = "production"
          "managed-by"             = "opentofu"
        }
        annotations = {
          "checksum/config" = sha256(REDACTED_a9df2e77_v1.gatus_config.data["config.yaml"])
        }
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 1000
          run_as_group    = 1000
          fs_group        = 1000
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        container {
          name  = "gatus"
          image = "twinproduction/gatus:${var.gatus_version}"

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          env {
            name  = "TZ"
            value = var.timezone
          }

          env {
            name  = "GATUS_CONFIG_PATH"
            value = "/config/config.yaml"
          }

          resources {
            requests = {
              cpu    = var.gatus_cpu_request
              memory = var.gatus_memory_request
            }
            limits = {
              cpu    = var.gatus_cpu_limit
              memory = var.gatus_memory_limit
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          volume_mount {
            name       = "config"
            mount_path = "/config"
            read_only  = true
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 1000
            capabilities {
              drop = ["ALL"]
            }
          }
        }

        volume {
          name = "config"
          config_map {
            name = REDACTED_a9df2e77_v1.gatus_config.metadata[0].name
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = REDACTED_912a6d18_claim_v1.gatus_data.metadata[0].name
          }
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Service
# -----------------------------------------------------------------------------
resource "kubernetes_service_v1" "gatus" {
  metadata {
    name      = "gatus"
    namespace = REDACTED_46569c16.gatus.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "gatus"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      "app.kubernetes.io/name" = "gatus"
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
# Ingress
# -----------------------------------------------------------------------------
resource "kubernetes_ingress_v1" "gatus" {
  metadata {
    name      = "gatus"
    namespace = REDACTED_46569c16.gatus.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "gatus"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
    annotations = {}
  }

  spec {
    ingress_class_name = "nginx"

    tls {
      hosts       = [var.gatus_hostname]
      secret_name = "gatus-tls"
    }

    rule {
      host = var.gatus_hostname

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.gatus.metadata[0].name
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

# -----------------------------------------------------------------------------
# Certificate (cert-manager)
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "gatus_certificate" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "gatus-tls"
      namespace = REDACTED_46569c16.gatus.metadata[0].name
      labels = {
        "app.kubernetes.io/name" = "gatus"
        environment              = "production"
        "managed-by"             = "opentofu"
      }
    }
    spec = {
      secretName = "gatus-tls"
      issuerRef = {
        name = var.cert_issuer_name
        kind = var.cert_issuer_kind
      }
      dnsNames = [var.gatus_hostname]
    }
  }
}

# -----------------------------------------------------------------------------
# ServiceMonitor - Prometheus autodiscovery
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_ec2c277c" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "gatus"
      namespace = REDACTED_46569c16.gatus.metadata[0].name
      labels = {
        "app.kubernetes.io/name" = "gatus"
        environment              = "production"
        "managed-by"             = "opentofu"
        release                  = "monitoring"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "gatus"
        }
      }
      namespaceSelector = {
        matchNames = ["gatus"]
      }
      endpoints = [{
        port          = "http"
        path          = "/metrics"
        interval      = "30s"
        scrapeTimeout = "10s"
      }]
    }
  }
}

# -----------------------------------------------------------------------------
# CiliumNetworkPolicy - Restrict traffic
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_74a3ea37" {
  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "CiliumNetworkPolicy"
    metadata = {
      name      = "gatus-policy"
      namespace = REDACTED_46569c16.gatus.metadata[0].name
      labels = {
        "app.kubernetes.io/name" = "gatus"
        environment              = "production"
        "managed-by"             = "opentofu"
      }
    }
    spec = {
      endpointSelector = {
        matchLabels = {
          "app.kubernetes.io/name" = "gatus"
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
        },
        {
          fromEndpoints = [{
            matchLabels = {
              "k8s:io.kubernetes.pod.namespace" = "monitoring"
              "app.kubernetes.io/name"          = "prometheus"
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
        },
        {
          toEntities = ["world"]
          toPorts = [{
            ports = [
              { port = "443", protocol = "TCP" },
              { port = "80", protocol = "TCP" },
              { port = "6443", protocol = "TCP" }
            ]
          }]
        },
        {
          toEntities = ["cluster"]
        }
      ]
    }
  }
}
