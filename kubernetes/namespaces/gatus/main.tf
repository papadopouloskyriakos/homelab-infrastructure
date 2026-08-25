# Alerting: native ntfy provider since 2026-08-25 (Twilio + GitLab-pipeline providers removed). See IFRNLLEI01PRD-802 history.
# =============================================================================
# Gatus - Status Page with Cross-Site Monitoring
# =============================================================================
# Public status page served via BGP anycast
# Monitors both NL and GR sites from each location
# Includes Prometheus-based network health checks for AS214304
#
# CANONICAL NL<->GR MIRROR MODULE (2026-08-16 campaign): this file is
# byte-identical in both repos. Site-specific values come in via variables
# (NL defaults, GR overrides in the root call). The endpoint list is the
# UNION of both sites' sets — both vantages monitor the shared estate; only
# ntfy paging (NL-armed) and the cert-manager pieces are gated per site.
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
  # ntfy paging (2026-08-25 cutover — replaced the Twilio custom provider and
  # the long-dead GitLab-pipeline provider). Arms only when all three ntfy
  # values are present; on NL these arrive as TF_VAR_gatus_ntfy_* in Atlantis's
  # env (/srv/atlantis/ntfy.env) + OpenBao ci/gatus-ntfy for the drift job.
  # GR/NO leave them empty -> alerting = null (deliberately silent).
  ntfy_enabled = var.ntfy_url != "" && var.ntfy_topic != "" && var.ntfy_token != ""
}

# -----------------------------------------------------------------------------
# Secret - ntfy publish token (mounted as env var in the Gatus pod; the config
# references it as ${NTFY_TOKEN} via Gatus env substitution)
# -----------------------------------------------------------------------------
resource "kubernetes_secret_v1" "gatus_ntfy" {
  count = local.ntfy_enabled ? 1 : 0

  metadata {
    name      = "gatus-ntfy"
    namespace = REDACTED_46569c16.gatus.metadata[0].name
    labels = {
      "app.kubernetes.io/name" = "gatus"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  type = "Opaque"
  data = {
    NTFY_TOKEN = var.ntfy_token
  }
}

# -----------------------------------------------------------------------------
# ConfigMap - Gatus Configuration
# -----------------------------------------------------------------------------
# Source of truth is this file (GitOps); Atlantis apply rolls the Deployment's
# checksum/config annotation automatically. (GR note 2026-04-24: detect_k8s_drift
# pipelines #6387..#6406 flagged live-vs-module divergence — reconciled here.)
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

      alerting = local.ntfy_enabled ? {
        # Native ntfy provider (Gatus >= 5.3; token field supported; v5.36.0
        # deployed). Publishes to the alrt-tier1 topic on the Matrix-stack ntfy —
        # the same topic the paging bridge uses, so the phone has ONE
        # subscription. ${NTFY_TOKEN} is Gatus env substitution from the
        # gatus-ntfy Secret (HCL-escaped $${...} passes it through literally).
        ntfy = {
          url      = var.ntfy_url
          topic    = var.ntfy_topic
          token    = "$${NTFY_TOKEN}"
          priority = 5
          default-alert = {
            enabled           = true
            send-on-resolved  = true
            failure-threshold = 2
            success-threshold = 3
          }
        }
      } : null

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
            alerts = local.ntfy_enabled ? [{
              type        = "ntfy"
              description = "K8s-NL-API-down"
            }] : []
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
            alerts = []
          },
          # notrf01 dead-man (IFRNLLEI01PRD-2403) — pre-wired DISABLED; armed
          # in Phase 7 once the NO cluster serves its API. No Twilio entry.
          {
            name     = "NO Kubernetes API"
            group    = "🔧 Core Platform"
            enabled  = true
            url      = "https://no-api-k8s.example.net:6443/healthz"
            client   = { insecure = true }
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[BODY] == ok"
            ]
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
          },
          # --- Edge Node Health ---
          # NOTE (GR vantage): the *-int hostnames resolve to the VPS overlay
          # loopbacks (10.255.2-3.0/24). A GR note from 2026-04 said GR K8s
          # could not reach those (routed via NL RRs only) and probed the
          # public IPs instead. Canonical keeps the NL internal-stats form —
          # verify GR->10.255.2-3.0/24 reachability when merging on GR.
          {
            name     = "Edge: Zürich (CH)"
            group    = "🌐 Network (AS214304)"
            url      = "http://chzrh01vps01-int.example.net:8404/stats;csv"
            interval = "60s"
            headers = {
              Authorization = "Basic ${var.haproxy_stats_auth}"
            }
            conditions = [
              "[STATUS] == 200",
              "[BODY] == pat(*,UP,*)"
            ]
            alerts = []
          },
          {
            name     = "Edge: Sandefjord (NO)"
            group    = "🌐 Network (AS214304)"
            url      = "http://notrf01vps01-int.example.net:8404/stats;csv"
            interval = "60s"
            headers = {
              Authorization = "Basic ${var.haproxy_stats_auth}"
            }
            conditions = [
              "[STATUS] == 200",
              "[BODY] == pat(*,UP,*)"
            ]
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
          }
        ],

        # =====================================================================
        # 🔒 SECURITY & SECRETS
        # =====================================================================
        # cert-manager health via Prometheus. Gated: only meaningful where
        # ACME issuance runs (NL). GR consumes the NL wildcard secret and has
        # no certmanager_* series — an ungated check would sit red forever
        # (which is why GR historically commented this block out).
        var.acme_issuer_enabled ? [
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
            alerts = []
          }
          # NOTE: OpenBao is internal-only, add when ingress/metrics are available
        ] : [],

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
            alerts = []
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
            alerts = []
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
            alerts = []
          },
          # notrf01 monitoring dead-man (IFRNLLEI01PRD-2413) — ARMED 2026-08-18
          # (OMOIKANE-1623 cutover complete). Path: FreeIPA A records
          # no-prometheus -> the three NO worker mesh IPs (round-robin) ->
          # the omoikane edge-relay hostNetwork :8443 (the ONLY route into
          # the NO ingress from xfrm sources — Cilium NodePort RSTs them) ->
          # ingress-nginx (valid *.example.net default cert) ->
          # /-/healthy. Shared-fate caveat: this also fails if ALL THREE
          # edge-relay pods die — a broader outage worth paging for anyway.
          {
            name     = "Prometheus (NO)"
            group    = "📊 Observability"
            enabled  = true
            url      = "https://no-prometheus.example.net:8443/-/healthy"
            interval = "60s"
            # Operator ruling 2026-08-18: operation-critical checks resolve
            # via FreeIPA DIRECTLY (the zone authority), not the piholes —
            # kills the pihole dependency + its NXDOMAIN negative-cache
            # class. Gatus takes exactly one resolver: the NL IPA (same
            # site); if that dies this check false-fires, which is itself
            # page-worthy.
            client = { "dns-resolver" = "udp://10.0.X.X:53" }
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
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
            alerts = []
          }
        ],

        # =====================================================================
        # 📱 APPLICATIONS
        # =====================================================================
        [
          {
            name     = "Kyriakos Portfolio"
            group    = "📱 Applications"
            url      = "https://kyriakos.papadopoulos.tech"
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 2000"
            ]
            alerts = []
          },
          {
            name     = "Ellizg Portfolio"
            group    = "📱 Applications"
            url      = "https://portfolio.ellizg.com"
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = []
          },
          {
            name     = "Zafeiridis Portfolio"
            group    = "📱 Applications"
            url      = "https://george.zafeiridis.com"
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = []
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
            alerts = []
          },
          {
            name  = "Home Assistant"
            group = "📱 Applications"
            # NOTE: homeassistant.example.net resolves to TWO A-records
            # (nlnpm01 10.0.X.X + grnpm01 10.0.X.X), so this
            # check transitively tests DNS + BOTH NPMs + the intersite path + HA
            # itself. When either NPM is dark the probe burns ~6-8 s failing over
            # to the live one and trips RESPONSE_TIME while HA is healthy (seen
            # 2026-08-25: gr-pve01 hang → grnpm01 dark → "HA-down" SMS
            # with HAHA fully up). Hence the alert label names the URL path, not
            # "HA", and carries the reporting site.
            url      = "https://homeassistant.example.net"
            interval = "60s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = local.ntfy_enabled ? [{
              type        = "ntfy"
              description = "HA-ext-URL-via-NPM-slow-or-down-from-${var.site_name}"
            }] : []
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
            alerts = local.ntfy_enabled ? [{
              type        = "ntfy"
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
            alerts = local.ntfy_enabled ? [{
              type        = "ntfy"
              description = "file02-down"
            }] : []
          },
          # NL history note 2026-04-30 (FISHA endpoints): earlier removal
          # incorrectly blamed K8s→inside_mgmt routing; actual cause was an
          # HTTP-protocol mismatch in the exporter. See exporter IaC for the
          # fix. From GR these checks double-monitor NL-hosted services —
          # accepted by the mirror campaign (paging stays NL-gated).
          # --- Public product sites (GR-origin set, canonical union) ---
          {
            name     = "CubeOS"
            group    = "📱 Applications"
            url      = "https://get.cubeos.app"
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = []
          },
          {
            name     = "MeshSat"
            group    = "📱 Applications"
            url      = "https://meshsat.net"
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = []
          },
          {
            name     = "MeshSat Hub"
            group    = "📱 Applications"
            url      = "https://hub.meshsat.net"
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = []
          },
          {
            name     = "Mulecube"
            group    = "📱 Applications"
            url      = "https://mulecube.com"
            interval = "30s"
            conditions = [
              "[STATUS] == 200",
              "[RESPONSE_TIME] < 3000"
            ]
            alerts = []
          }
        ],

        # Additional custom endpoints from the root call
        var.additional_endpoints
      )
    })
  }
}

# -----------------------------------------------------------------------------
# PersistentVolumeClaim - SQLite storage for history
# -----------------------------------------------------------------------------
resource "REDACTED_912a6d18_claim_v1" "gatus_data" {
  # WaitForFirstConsumer storage (local-PV sites) binds only when the pod
  # schedules — waiting for Bound here deadlocks the greenfield apply.
  wait_until_bound = false

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
    storage_class_name = var.storage_class_delete

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

    # gatus-data is a RWO iSCSI PVC and there is a single replica, so use
    # Recreate: on a config change the old pod is terminated (releasing the
    # volume) BEFORE the new one starts. The default RollingUpdate surges the
    # new pod first, which then dead-locks on a Multi-Attach error for the RWO
    # volume and the rollout hangs ~10m until the old pod is manually deleted.
    strategy {
      type = "Recreate"
    }

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

          # ntfy publish token for the alerting provider — only injected
          # when local.ntfy_enabled (Gatus substitutes ${NTFY_TOKEN} in config).
          dynamic "env" {
            for_each = local.ntfy_enabled ? toset(["NTFY_TOKEN"]) : toset([])
            content {
              name = env.value
              value_from {
                secret_key_ref {
                  name = kubernetes_secret_v1.gatus_ntfy[0].metadata[0].name
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
# TLS secret is site-specific: NL uses the gated per-host Certificate below
# ("gatus-tls"); GR points at the wildcard secret synced from NL.
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
      secret_name = var.tls_secret_name
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
# Certificate (cert-manager) — only where ACME issuance runs (NL)
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "gatus_certificate" {
  count = var.acme_issuer_enabled ? 1 : 0

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
              { port = "8404", protocol = "TCP" }, # HAProxy stats
              { port = "9101", protocol = "TCP" }, # nfs-stale-fh-exporter on FISHA file01/02
              { port = "8443", protocol = "TCP" }  # notrf01 omoikane edge-relay (Prometheus (NO) dead-man path, OMOIKANE-1623)
            ]
          }]
        },
        {
          toEntities = ["cluster"]
        },
        # Operator ruling 2026-08-18: operation-critical checks resolve via
        # FreeIPA directly (per-endpoint client.dns-resolver), bypassing the
        # piholes and their NXDOMAIN negative cache. The kube-dns rule above
        # does not cover this path — scope :53 to exactly the two IPA
        # servers (NL + GR replica).
        {
          toCIDR = ["10.0.X.X/32", "10.0.X.X/32"]
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
