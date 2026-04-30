# Atlantis re-apply trigger 2026-04-30: pick up TF_VAR_gatus_twilio_* now that Atlantis env has them. See IFRNLLEI01PRD-802.
# =============================================================================
# Gatus - Status Page with Cross-Site Monitoring
# =============================================================================
# Public status page served via BGP anycast
# Monitors both NL and GR sites from each location
# Includes Prometheus-based network health checks for AS214304
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
# Locals — derived values for alerting providers
# -----------------------------------------------------------------------------
locals {
  twilio_enabled = var.twilio_account_sid != "" && var.twilio_api_key_sid != "" && var.REDACTED_4dd179f5 != "" && var.twilio_to_number != ""
  # Pre-compute Basic-auth header content. Twilio accepts API-Key auth as
  # HTTP Basic where username=API_KEY_SID and password=REDACTED_4eae29e3.
  # Computed at plan time (sensitive); injected into Gatus pod via Secret.
  twilio_basic_auth = local.twilio_enabled ? base64encode("${var.twilio_api_key_sid}:${var.REDACTED_4dd179f5}") : ""
}

# -----------------------------------------------------------------------------
# Secret - Twilio credentials (mounted as env vars in Gatus pod)
# -----------------------------------------------------------------------------
resource "kubernetes_secret_v1" "gatus_twilio" {
  count = local.twilio_enabled ? 1 : 0

  metadata {
    name      = "gatus-twilio"
    namespace = REDACTED_46569c16.gatus.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "gatus"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  type = "Opaque"
  data = {
    TWILIO_ACCOUNT_SID = var.twilio_account_sid
    TWILIO_BASIC_AUTH  = local.twilio_basic_auth
    TWILIO_FROM        = var.twilio_from_number
    TWILIO_TO          = var.twilio_to_number
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
      metrics = true

      storage = {
        type = "sqlite"
        path = "/data/data.db"
      }

      alerting = local.twilio_enabled ? {
        # Twilio SMS for tier-1 endpoints. Uses Gatus's built-in twilio
        # provider via custom-style HTTP POST so we can authenticate with
        # API-Key auth (no master Auth Token required). Pre-computed Basic
        # auth header is injected via Secret.
        # Refs: IFRNLLEI01PRD-802; recipe matches scripts/freedom-qos-toggle.sh.
        custom = {
          url    = "https://api.twilio.com/2010-04-01/Accounts/$${TWILIO_ACCOUNT_SID}/Messages.json"
          method = "POST"
          headers = {
            "Content-Type"  = "REDACTED_c71c8610"
            "Authorization" = "Basic $${TWILIO_BASIC_AUTH}"
          }
          # [ALERT_DESCRIPTION] is the per-endpoint short description (URL-safe
          # short slug like 'HA-down'). [ALERT_TRIGGERED_OR_RESOLVED] resolves
          # to "TRIGGERED" or "RESOLVED" depending on event.
          body = "From=$${TWILIO_FROM}&To=$${TWILIO_TO}&Body=Gatus+%5B[ALERT_TRIGGERED_OR_RESOLVED]%5D+%5B[ALERT_DESCRIPTION]%5D"
          default-alert = {
            enabled           = true
            send-on-resolved  = true
            failure-threshold = 2
            success-threshold = 3
          }
        }
        } : (var.REDACTED_4f32e8a8 != "" ? {
          custom = {
            url    = "https://gitlab.example.net/api/v4/projects/${var.REDACTED_680664be}/trigger/pipeline"
            method = "POST"
            headers = {
              "Content-Type" = "REDACTED_c71c8610"
            }
            body = "token=${var.REDACTED_4f32e8a8}&ref=main&variables[TRIGGER_SOURCE]=gatus"
            default-alert = {
              enabled           = true
              send-on-resolved  = true
              failure-threshold = 2
              success-threshold = 3
            }
          }
      } : null)

      ui = {
        title       = var.gatus_ui_title
        description = "Multi-Site Infrastructure Health | AS214304 | ${var.site_name}"
        header      = var.gatus_ui_header
        logo        = ""
        link        = var.gatus_ui_link
      }

      endpoints = concat(
        # =====================================================================
        # 🔧 CORE PLATFORM - Kubernetes Clusters
        # =====================================================================
        [
          {
            name     = "NL Kubernetes API"
            group    = "🔧 Core Platform"
            url      = "https://api-k8s.example.net:6443/healthz"
            client   = { insecure = true }
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[BODY] == ok"
            ]
            alerts = local.twilio_enabled ? [{
              type        = "custom"
              description = "K8s-NL-API-down"
            }] : (var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : [])
          },
          {
            name     = "GR Kubernetes API"
            group    = "🔧 Core Platform"
            url      = "https://gr-api-k8s.example.net:6443/healthz"
            client   = { insecure = true }
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[BODY] == ok"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Cilium CNI (NL)"
            group    = "🔧 Core Platform"
            url      = "https://nl-hubble.example.net/api/v1/flows"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 5000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Cilium CNI (GR)"
            group    = "🔧 Core Platform"
            url      = "https://gr-hubble.example.net/api/v1/flows"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 5000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          }
        ],

        # =====================================================================
        # 🌐 NETWORK (AS214304) - BGP, IPsec, Edge Nodes
        # =====================================================================
        [
          # --- Prometheus-based BGP & IPsec Checks ---
          {
            name     = "FRR BGP Sessions"
            group    = "🌐 Network (AS214304)"
            url      = "https://${var.prometheus_hostname}/api/v1/query?query=count(frr_bgp_peer_state==1)"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[BODY].status == success",
              "[BODY].data.result[0].value[1] >= ${var.REDACTED_9246ffd6}"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Cilium BGP Sessions"
            group    = "🌐 Network (AS214304)"
            url      = "https://${var.prometheus_hostname}/api/v1/query?query=count(cilium_bgp_control_plane_session_state==1)"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[BODY].status == success",
              "[BODY].data.result[0].value[1] >= ${var.REDACTED_1c1562d0}"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "IPsec Tunnels"
            group    = "🌐 Network (AS214304)"
            url      = "https://${var.prometheus_hostname}/api/v1/query?query=count(ipsec_up==1)"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[BODY].status == success",
              "[BODY].data.result[0].value[1] >= ${var.expected_ipsec_tunnels}"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          # --- Edge Node Health ---
          {
            name     = "Edge: Zürich (CH)"
            group    = "🌐 Network (AS214304)"
            url      = "http://chzrh01vps01-int.example.net:8404/stats;csv"
            interval = "60s"
            headers = {
              Authorization = "Basic YWRtaW46SHhReGkwRVpTNlp4cmxSM0lHbE1uUT09"
            }
            conditions = [
              "[STATUS] == 200",
              "[BODY] == pat(*,UP,*)"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Edge: Sandefjord (NO)"
            group    = "🌐 Network (AS214304)"
            url      = "http://notrf01vps01-int.example.net:8404/stats;csv"
            interval = "60s"
            headers = {
              Authorization = "Basic YWRtaW46SHhReGkwRVpTNlp4cmxSM0lHbE1uUT09"
            }
            conditions = [
              "[STATUS] == 200",
              "[BODY] == pat(*,UP,*)"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          }
        ],

        # =====================================================================
        # 🔄 GITOPS & AUTOMATION
        # =====================================================================
        [
          {
            name     = "GitLab"
            group    = "🔄 GitOps & Automation"
            url      = "https://gitlab.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "GitLab (GR Mirror)"
            group    = "🔄 GitOps & Automation"
            url      = "https://gr-gitlab.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "ArgoCD (NL)"
            group    = "🔄 GitOps & Automation"
            url      = "https://argocd.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "ArgoCD (GR)"
            group    = "🔄 GitOps & Automation"
            url      = "https://gr-argocd.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Atlantis (NL)"
            group    = "🔄 GitOps & Automation"
            url      = "https://atlantis.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Atlantis (GR)"
            group    = "🔄 GitOps & Automation"
            url      = "https://gr-atlantis.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "AWX"
            group    = "🔄 GitOps & Automation"
            url      = "https://awx.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 5000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          }
        ],

        # =====================================================================
        # 🔒 SECURITY & SECRETS
        # =====================================================================
        [
          # cert-manager health via Prometheus
          {
            name     = "cert-manager"
            group    = "🔒 Security & Secrets"
            url      = "https://${var.prometheus_hostname}/api/v1/query?query=sum(certmanager_certificate_ready_status)"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[BODY].status == success",
              "[BODY].data.result[0].value[1] >= 1"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          }
          # NOTE: OpenBao is internal-only, add when ingress/metrics are available
        ],

        # =====================================================================
        # 📊 OBSERVABILITY
        # =====================================================================
        [
          {
            name     = "Grafana"
            group    = "📊 Observability"
            url      = "https://grafana.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Prometheus (NL)"
            group    = "📊 Observability"
            url      = "https://nl-prometheus.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Prometheus (GR)"
            group    = "📊 Observability"
            url      = "https://gr-prometheus.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Thanos (NL)"
            group    = "📊 Observability"
            url      = "https://nl-thanos.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Thanos (GR)"
            group    = "📊 Observability"
            url      = "https://gr-thanos.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          # Loki health via Prometheus metric existence
          {
            name     = "Loki"
            group    = "📊 Observability"
            url      = "https://${var.prometheus_hostname}/api/v1/query?query=loki_internal_log_messages_total"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[BODY].status == success"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Hubble UI (NL)"
            group    = "📊 Observability"
            url      = "https://nl-hubble.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Hubble UI (GR)"
            group    = "📊 Observability"
            url      = "https://gr-hubble.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "K8s Dashboard (NL)"
            group    = "📊 Observability"
            url      = "https://nl-k8s.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "K8s Dashboard (GR)"
            group    = "📊 Observability"
            url      = "https://gr-k8s.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Goldpinger (NL)"
            group    = "📊 Observability"
            url      = "https://goldpinger.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Goldpinger (GR)"
            group    = "📊 Observability"
            url      = "https://gr-goldpinger.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          }
        ],

        # =====================================================================
        # 💾 STORAGE & BACKUP
        # =====================================================================
        [
          {
            name     = "SeaweedFS Master (NL)"
            group    = "💾 Storage & Backup"
            url      = "https://nl-seaweedfs.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "SeaweedFS Master (GR)"
            group    = "💾 Storage & Backup"
            url      = "https://gr-seaweedfs.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "SeaweedFS S3 (NL)"
            group    = "💾 Storage & Backup"
            url      = "https://nl-s3.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "SeaweedFS S3 (GR)"
            group    = "💾 Storage & Backup"
            url      = "https://gr-s3.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] < 500",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Velero UI"
            group    = "💾 Storage & Backup"
            url      = "https://velero.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          }
        ],

        # =====================================================================
        # 📱 APPLICATIONS
        # =====================================================================
        [
          {
            name     = "Portfolio"
            group    = "📱 Applications"
            url      = "https://kyriakos.papadopoulos.tech"
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 2000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Nextcloud"
            group    = "📱 Applications"
            url      = "https://nextcloud.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 5000"
            ]
            alerts = var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : []
          },
          {
            name     = "Home Assistant"
            group    = "📱 Applications"
            url      = "https://homeassistant.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = local.twilio_enabled ? [{
              type        = "custom"
              description = "HA-down"
            }] : (var.REDACTED_4f32e8a8 != "" ? [{ type = "custom" }] : [])
          },
          {
            # FISHA file01 NFS server liveness — probes the stale-fh exporter
            # (port 9101) as a cheap proxy for "OS up + NIC routable + Python
            # services running". Re-added 2026-04-30 after fixing the actual
            # root cause: the exporter responded HTTP/1.0 (Python http.server
            # default) and Gatus's HTTP/1.1+keep-alive Go client deadlocked on
            # connection reuse, causing 10s timeouts. Setting
            # `protocol_version = "HTTP/1.1"` on the exporter handler (and
            # adding do_HEAD) fixed it. Refs IFRNLLEI01PRD-805.
            name     = "FISHA file01"
            group    = "📱 Applications"
            url      = "http://10.0.X.X:9101/metrics"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[BODY] == pat(*nfs_stale_fh_responses_total*)"
            ]
            alerts = local.twilio_enabled ? [{
              type        = "custom"
              description = "file01-down"
            }] : []
          },
          {
            name     = "FISHA file02"
            group    = "📱 Applications"
            url      = "http://10.0.X.X:9101/metrics"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[BODY] == pat(*nfs_stale_fh_responses_total*)"
            ]
            alerts = local.twilio_enabled ? [{
              type        = "custom"
              description = "file02-down"
            }] : []
          }
          # End of endpoints. Original removal note 2026-04-30: I incorrectly
          # blamed K8s→inside_mgmt routing; actual cause was an HTTP-protocol
          # mismatch in the exporter. See exporter IaC for the fix.
          # Twilio). Re-add here once K8s pod network has a route to
          # 10.0.X.X/24, or move the exporter to a node-internal service.
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

          # Twilio creds for the custom alerting provider — only injected
          # when local.twilio_enabled. Each env block is conditional via
          # a dynamic block keyed off twilio_enabled.
          dynamic "env" {
            for_each = local.twilio_enabled ? toset(["TWILIO_ACCOUNT_SID", "TWILIO_BASIC_AUTH", "TWILIO_FROM", "TWILIO_TO"]) : toset([])
            content {
              name = env.value
              value_from {
                secret_key_ref {
                  name = kubernetes_secret_v1.gatus_twilio[0].metadata[0].name
                  key  = env.value
                }
              }
            }
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
              { port = "6443", protocol = "TCP" },
              { port = "8404", protocol = "TCP" } # HAProxy stats
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
