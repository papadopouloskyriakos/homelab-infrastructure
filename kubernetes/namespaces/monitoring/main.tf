# =============================================================================
# Monitoring Stack (Prometheus + Grafana)
# =============================================================================
# Deploys REDACTED_d8074874 with proper node affinity to keep
# Prometheus and Alertmanager OFF control plane nodes
# =============================================================================

# -----------------------------------------------------------------------------
# ExternalSecret for Grafana Admin Credentials
# -----------------------------------------------------------------------------
# Creates the secret BEFORE Helm release so Grafana can use existingSecret
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_9675462a" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "monitoring-grafana"
      namespace = "monitoring"
      labels = merge(var.common_labels, {
        "app.kubernetes.io/name"      = "grafana"
        "app.kubernetes.io/component" = "admin-secret"
      })
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "monitoring-grafana"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "admin-user"
          remoteRef = {
            key      = "REDACTED_f6e2d5a1"
            property = "admin-user"
          }
        },
        {
          secretKey = REDACTED_e7c10ed7
          remoteRef = {
            key      = "REDACTED_f6e2d5a1"
            property = REDACTED_e7c10ed7
          }
        }
      ]
    }
  }
}

# -----------------------------------------------------------------------------
# ExternalSecret for the Territory Grounder ingest bearer token
# -----------------------------------------------------------------------------
# Materializes k8s Secret `tg-ingest-token` (key `token`) from OpenBao
# secret/REDACTED_d7c66005, mounted into Alertmanager via
# alertmanagerSpec.secrets for the webhook-tg receiver's Bearer credentials_file.
# Gated with the webhook-tg receiver: TG is a single NL-estate instance, so
# only the cluster that feeds it (tg_webhook_url != "") creates the token.
resource "kubernetes_manifest" "tg_ingest_token" {
  count = var.tg_webhook_url != "" ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "tg-ingest-token"
      namespace = "monitoring"
      labels = merge(var.common_labels, {
        "app.kubernetes.io/name"      = "territory-grounder"
        "app.kubernetes.io/component" = "ingest-token"
      })
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "tg-ingest-token"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "token"
          remoteRef = {
            key      = "REDACTED_d7c66005"
            property = "token"
          }
        }
      ]
    }
  }
}

# -----------------------------------------------------------------------------
# ExternalSecret for the finops ledger read-only DB password (Grafana datasource)
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "grafana_finops_db_ro" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "monitoring-finops-db-ro"
      namespace = "monitoring"
      labels = merge(var.common_labels, {
        "app.kubernetes.io/name"      = "grafana"
        "app.kubernetes.io/component" = "finops-datasource"
      })
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "monitoring-finops-db-ro"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "password"
          remoteRef = {
            key      = "REDACTED_b284d0f9"
            property = "password"
          }
        }
      ]
    }
  }
}

# -----------------------------------------------------------------------------
# ExternalSecret for the OpenObserve read-only basic-auth password (Grafana
# datasource). Replaces the plaintext password that used to sit inline in the
# additionalDataSources block (mirror-campaign finding D28) — the datasource
# now reads it via $__file from a sidecar-mounted secret.
# OpenBao path: secret/REDACTED_17ddacf8 (property: password)
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "grafana_openobserve_ro" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "monitoring-openobserve-ro"
      namespace = "monitoring"
      labels = merge(var.common_labels, {
        "app.kubernetes.io/name"      = "grafana"
        "app.kubernetes.io/component" = "REDACTED_d2c11099"
      })
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "monitoring-openobserve-ro"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "password"
          remoteRef = {
            key      = "REDACTED_17ddacf8"
            property = "password"
          }
        }
      ]
    }
  }
}

# -----------------------------------------------------------------------------
# Monitoring Helm Release
# -----------------------------------------------------------------------------
resource "helm_release" "monitoring" {
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "REDACTED_d8074874"
  namespace        = "monitoring"
  create_namespace = true
  version          = "79.12.0"
  # 300s is too tight: a values change that rolls grafana's 2 replicas + the full-release
  # `wait` re-check exceeds 300s → atomic rollback (observed 2026-06-24, rev 9 failed/rev 10
  # rollback). 600s gives the readiness wait headroom for any monitoring-stack upgrade.
  timeout         = 600
  wait            = true
  atomic          = true
  cleanup_on_fail = true

  # Ensure ExternalSecrets create the mounted secrets first
  depends_on = [
    kubernetes_manifest.REDACTED_9675462a,
    kubernetes_manifest.grafana_finops_db_ro,
    kubernetes_manifest.grafana_openobserve_ro,
  ]

  # The values list is a concat(): the base document is followed by two
  # OPTIONAL overlay documents (Helm deep-merges later entries over earlier
  # ones). With the defaults (url = "", receiver = false) both overlays are
  # absent and the rendered values are byte-identical to the historical
  # single-document list — remoteWrite / enableRemoteWriteReceiver are only
  # ever ADDED as keys, never emitted empty (an explicit empty key would
  # diff the release against today's state for nothing).
  values = concat([
    yamlencode({
      # =========================================================================
      # PROMETHEUS CONFIGURATION
      # =========================================================================
      prometheus = {
        prometheusSpec = {
          replicas = 2

          # etcd scrape cert mounted at /etc/prometheus/secrets/<name>/ for the kubeEtcd
          # serviceMonitor (mTLS to node-IP:2379). Secret created out-of-band (not in git).
          secrets = ["REDACTED_d8074874-etcd-client-cert"]

          # Scrape all ServiceMonitors and PodMonitors (not just release=monitoring)
          serviceMonitorSelector                  = {}
          serviceMonitorSelectorNilUsesHelmValues = false
          serviceMonitorNamespaceSelector         = {}
          podMonitorSelector                      = {}
          podMonitorSelectorNilUsesHelmValues     = false
          podMonitorNamespaceSelector             = {}

          podDisruptionBudget = {
            enabled      = true
            minAvailable = 1
          }

          retention     = var.prometheus_retention
          retentionSize = "50GB"

          # Thanos sidecar configuration
          thanos = {
            image = "quay.io/thanos/thanos:${var.thanos_version}"
            objectStorageConfig = {
              existingSecret = {
                name = "REDACTED_5f4971dc"
                key  = "objstore.yml"
              }
            }
            resources = {
              requests = {
                cpu    = "50m"
                memory = "128Mi"
              }
              limits = {
                cpu    = "200m"
                memory = "512Mi"
              }
            }
          }

          # External labels for Thanos deduplication
          externalLabels = {
            cluster = var.cluster_name
            site    = var.site
          }

          replicaExternalLabelName = "prometheus_replica"

          # Right-sized 4Gi->6Gi limit / 2Gi->3Gi request 2026-06-27: replica -1 crash-looped on
          # transient ~2.7x memory spikes past the 4Gi ceiling (8x exit-137 OOMKilled, ~9-min loop);
          # steady working set ~1.6 GiB, head series flat ~310k (no cardinality leak — the identical
          # twin replica -0 held at 0 restarts). The 2026-06-26 NL etcd scrape is a plausible driver.
          resources = {
            requests = {
              cpu    = "500m"
              memory = "3Gi"
            }
            limits = {
              cpu    = "2"
              memory = "6Gi"
            }
          }

          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.REDACTED_cdb3d821
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.REDACTED_6a2724e6
                  }
                }
              }
            }
          }

          affinity = {
            nodeAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = {
                nodeSelectorTerms = [{
                  matchExpressions = [{
                    key      = "node-role.kubernetes.io/control-plane"
                    operator = "DoesNotExist"
                  }]
                }]
              }
            }
            podAntiAffinity = {
              preferredDuringSchedulingIgnoredDuringExecution = [{
                weight = 100
                podAffinityTerm = {
                  labelSelector = {
                    matchExpressions = [{
                      key      = "app.kubernetes.io/name"
                      operator = "In"
                      values   = ["prometheus"]
                    }]
                  }
                  topologyKey = "kubernetes.io/hostname"
                }
              }]
            }
          }

          tolerations = []

          # =================================================================
          # Additional Scrape Configs - Network Infrastructure Exporters
          # =================================================================
          # Base jobs (below) run on BOTH clusters with per-site targets.
          # Estate jobs (scrape-estate.tf) are collected by ONE cluster only,
          # gated by var.estate_scrape_enabled.
          additionalScrapeConfigs = concat([
            # FRR BGP Exporters - Route Reflector VMs
            {
              job_name = "frr-route-reflectors"
              static_configs = [{
                targets = var.frr_route_reflector_targets
                labels = {
                  role = "route-reflector"
                }
              }]
              relabel_configs = [
                { source_labels = ["__address__"], regex = "192\\.168\\.192\\.3:.*", target_label = "instance", replacement = "nl-rtr01" },
                { source_labels = ["__address__"], regex = "192\\.168\\.192\\.4:.*", target_label = "instance", replacement = "nl-rtr02" },
                { source_labels = ["__address__"], regex = "192\\.168\\.15\\.3:.*", target_label = "instance", replacement = "gr-rtr01" },
                { source_labels = ["__address__"], regex = "192\\.168\\.15\\.4:.*", target_label = "instance", replacement = "gr-rtr02" },
                { source_labels = ["__address__"], regex = "192\\.168\\.192\\..*", target_label = "site", replacement = "nl" },
                { source_labels = ["__address__"], regex = "192\\.168\\.15\\..*", target_label = "site", replacement = "gr" },
              ]
            },
            # FRR BGP Exporters - Edge Nodes
            {
              job_name = "frr-edge-nodes"
              static_configs = [{
                targets = var.frr_edge_targets
                labels = {
                  role = "edge-node"
                }
              }]
              relabel_configs = [
                { source_labels = ["__address__"], regex = "10\\.255\\.2\\.11:.*", target_label = "instance", replacement = "ch-edge" },
                { source_labels = ["__address__"], regex = "10\\.255\\.2\\.11:.*", target_label = "site", replacement = "ch" },
                { source_labels = ["__address__"], regex = "10\\.255\\.3\\.11:.*", target_label = "instance", replacement = "no-edge" },
                { source_labels = ["__address__"], regex = "10\\.255\\.3\\.11:.*", target_label = "site", replacement = "no" },
                { source_labels = ["__address__"], regex = "10\\.255\\.6\\.11:.*", target_label = "instance", replacement = "tx-edge" },
                { source_labels = ["__address__"], regex = "10\\.255\\.6\\.11:.*", target_label = "site", replacement = "tx" },
              ]
            },
            # IPsec Exporters - Edge Nodes
            {
              job_name = "ipsec-edge-nodes"
              static_configs = [{
                targets = var.ipsec_edge_targets
                labels = {
                  role = "ipsec-gateway"
                }
              }]
              relabel_configs = [
                { source_labels = ["__address__"], regex = "10\\.255\\.2\\.11:.*", target_label = "instance", replacement = "ch-edge" },
                { source_labels = ["__address__"], regex = "10\\.255\\.2\\.11:.*", target_label = "site", replacement = "ch" },
                { source_labels = ["__address__"], regex = "10\\.255\\.3\\.11:.*", target_label = "instance", replacement = "no-edge" },
                { source_labels = ["__address__"], regex = "10\\.255\\.3\\.11:.*", target_label = "site", replacement = "no" },
                { source_labels = ["__address__"], regex = "10\\.255\\.6\\.11:.*", target_label = "instance", replacement = "tx-edge" },
                { source_labels = ["__address__"], regex = "10\\.255\\.6\\.11:.*", target_label = "site", replacement = "tx" },
              ]
            },
            ],
            # SNMP Exporter - Cisco ASA Firewall (local site only). Gated on
            # var.asa_snmp_enabled together with the snmp-exporter.tf
            # resources — a site without an ASA emits neither the job nor
            # the exporter. true renders the historical list byte-identically.
            var.asa_snmp_enabled ? [
              {
                job_name        = "snmp-asa"
                scrape_interval = "60s"
                scrape_timeout  = "55s"
                metrics_path    = "/snmp"
                params = {
                  module = ["cisco_asa"]
                  auth   = ["asa_v2"]
                }
                static_configs = [{
                  targets = [var.snmp_asa_target] # local ASA only - each cluster scrapes its own ASA
                }]
                relabel_configs = [
                  { source_labels = ["__address__"], target_label = "__param_target" },
                  { source_labels = ["__param_target"], target_label = "instance" },
                  { target_label = "device", replacement = var.snmp_asa_device },
                  { target_label = "site", replacement = var.site },
                  { target_label = "__address__", replacement = "snmp-exporter.monitoring.svc:9116" },
                ]
              },
              ] : [], var.snmp_syno_target != "" ? [
              # SNMP - local Synology NAS (IFRNLLEI01PRD-2605): UCD memory/load
              # via the shared snmp-exporter, module `synology`. Gated on the
              # per-site tfvars target — sites without a NAS emit nothing.
              {
                job_name        = "snmp-syno"
                scrape_interval = "60s"
                scrape_timeout  = "55s"
                metrics_path    = "/snmp"
                params = {
                  module = ["synology"]
                  auth   = ["syno_v2"]
                }
                static_configs = [{
                  targets = [var.snmp_syno_target]
                }]
                relabel_configs = [
                  { source_labels = ["__address__"], target_label = "__param_target" },
                  { source_labels = ["__param_target"], target_label = "instance" },
                  { target_label = "device", replacement = var.snmp_syno_device },
                  { target_label = "site", replacement = var.site },
                  { target_label = "__address__", replacement = "snmp-exporter.monitoring.svc:9116" },
                ]
              },
              ] : [], length(var.pve_hosts) > 0 ? [
              # PVE hosts — native prometheus-pve-exporter (:9221). PER-SITE since
              # 2026-08-26: each cluster scrapes its OWN hosts (handed over from
              # the NL estate job when GR Prometheus returned, IFRGRSKG01PRD-313).
              # Every host serves the WHOLE cluster view (?cluster=1&node=0), so
              # cluster-view rules stay NL-only (host-pressure-alerts.tf, single
              # evaluation) while site-local liveness/pressure rules live in
              # pve-host-alerts.tf. Installer + runbook: claude-gateway
              # scripts/pve-host-exporters-install.sh, docs/runbooks/pve-host-exporters.md.
              {
                job_name        = "pve-exporter"
                scrape_interval = "60s"
                scrape_timeout  = "50s"
                metrics_path    = "/pve"
                params = {
                  cluster = ["1"]
                  node    = ["0"]
                }
                static_configs = [for h in var.pve_hosts : {
                  targets = ["${h.ip}:9221"]
                  labels = {
                    instance = h.instance
                    role     = "pve-host"
                    site     = var.site
                  }
                }]
              },
              ] : [], length(var.pve_hosts) > 0 ? [
              # Host-native node_exporter on the same PVE hosts (PSI/zfs collectors).
              {
                job_name = "pve-node-exporter"
                static_configs = [for h in var.pve_hosts : {
                  targets = ["${h.ip}:9100"]
                  labels = {
                    instance = h.instance
                    role     = "pve-host"
                    site     = var.site
                  }
                }]
              },
          ] : [], local.estate_scrape_configs)
        }

        service = {
          type     = "NodePort"
          nodePort = 30090
        }
      }

      # =========================================================================
      # ALERTMANAGER CONFIGURATION
      # =========================================================================
      alertmanager = {
        config = {
          global = {
            resolve_timeout = "5m"
          }
          inhibit_rules = [
            {
              source_matchers = ["severity = critical"]
              target_matchers = ["severity =~ warning|info"]
              equal           = ["namespace", "alertname"]
            },
            {
              source_matchers = ["severity = warning"]
              target_matchers = ["severity = info"]
              equal           = ["namespace", "alertname"]
            },
            {
              source_matchers = ["alertname = InfoInhibitor"]
              target_matchers = ["severity = info"]
            }
          ]
          receivers = concat(
            [
              { name = "null" },
              {
                name = "webhook-n8n"
                webhook_configs = [{
                  url           = var.alert_webhook_url
                  send_resolved = true
                  max_alerts    = 10
                }]
              },
            ],
            # Tier-1 paging path (2026-08-25 ntfy cutover). The paging bridge
            # (claude-gateway/scripts/paging-bridge.py, formerly the Twilio bridge;
            # NL nlclaude01:9106 user unit, GR grclaude01:9106 system unit)
            # pushes every tier-1 critical to ntfy topic alrt-tier1 and SMSes ONLY
            # alerts labeled page="sms" (ULTRA allowlist) + capped ntfy-down
            # fail-over. page-heartbeat feeds the bridge's per-site Prometheus
            # dead-man from the always-firing Watchdog alert.
            # Runbook: claude-gateway docs/runbooks/paging-ntfy.md. Refs IFRNLLEI01PRD-802.
            var.paging_bridge_url != "" ? [
              {
                name = "page-tier1"
                webhook_configs = [{
                  url           = var.paging_bridge_url
                  send_resolved = true
                  max_alerts    = 5
                }]
              },
              {
                name = "page-heartbeat"
                webhook_configs = [{
                  url           = replace(var.paging_bridge_url, "/alert", "/heartbeat")
                  send_resolved = false
                  max_alerts    = 1
                }]
              },
            ] : [],
            # Territory Grounder — governed-autonomy SRE agent. Parallel to webhook-n8n (n8n untouched).
            # Posted over HTTPS to the stable ingress hostname (valid Let's Encrypt *.example.net
            # cert — no tls_config needed), which TLS-protects the bearer in transit. Bearer auth: TG's
            # /v1/ingest can't verify an HMAC from Alertmanager, so a per-source static token (OpenBao
            # secret/REDACTED_d7c66005 -> ExternalSecret tg-ingest-token, mounted via
            # alertmanagerSpec.secrets) is presented as a Bearer credentials_file. TG runs mutation OFF —
            # it triages + proposes only. Single NL-estate instance: gated on tg_webhook_url.
            var.tg_webhook_url != "" ? [
              {
                name = "webhook-tg"
                webhook_configs = [{
                  url           = var.tg_webhook_url
                  send_resolved = true
                  max_alerts    = 10
                  http_config = {
                    authorization = {
                      type             = "Bearer"
                      credentials_file = "REDACTED_0edcce58"
                    }
                  }
                }]
              },
            ] : [],
            # WAL healer — n8n self-heal hook for PrometheusTSDBCompactionsFailing.
            var.wal_healer_webhook_url != "" ? [
              {
                name = "webhook-wal-healer"
                webhook_configs = [{
                  url           = var.wal_healer_webhook_url
                  send_resolved = false
                  max_alerts    = 1
                }]
              },
            ] : [],
          )
          route = {
            receiver        = "webhook-n8n"
            group_by        = ["namespace", "alertname"]
            group_wait      = "30s"
            group_interval  = "5m"
            repeat_interval = "4h"
            routes = concat(
              # Watchdog: the always-firing dead-man heartbeat. With the paging
              # bridge wired it feeds POST /heartbeat every ~2m (per-site liveness;
              # silence >15m -> PrometheusHeartbeatLost from the bridge). Ternary,
              # NOT a plain edit: with paging_bridge_url == "" the receiver
              # page-heartbeat would not exist and prometheus-operator would
              # reject the whole Alertmanager config.
              # (two separate ?:[] conditionals, not one ternary with both
              # branches: HCL rejects branches whose object shapes differ —
              # "Inconsistent conditional result types".)
              var.paging_bridge_url != "" ? [
                {
                  matchers        = ["alertname = Watchdog"]
                  receiver        = "page-heartbeat"
                  group_wait      = "10s"
                  group_interval  = "1m"
                  repeat_interval = "2m"
                },
              ] : [],
              var.paging_bridge_url != "" ? [] : [
                {
                  matchers = ["alertname = Watchdog"]
                  receiver = "null"
                },
              ],
              [
                {
                  matchers = ["alertname = InfoInhibitor"]
                  receiver = "null"
                },
                # KubeAPIErrorBudgetBurn — silenced 2026-04-30 (IFRNLLEI01PRD-768).
                # Root cause is nlk8s-ctrl01 etcd fsync stalls under pve01
                # CPU pressure (load avg 25); IFRNLLEI01PRD-704 addressed memory
                # pressure but CPU overcommit is the new bottleneck. No remediation
                # plan in flight — the alert was creating YT/Matrix noise without
                # actionable diagnostics. Re-enable once a remediation plan exists.
                {
                  matchers = ["alertname = KubeAPIErrorBudgetBurn"]
                  receiver = "null"
                },
              ],
              # WAL healer route — fires the self-heal webhook fast, then continues so the
              # alert still reaches the chat/triage legs below.
              var.wal_healer_webhook_url != "" ? [
                {
                  matchers        = ["alertname = PrometheusTSDBCompactionsFailing"]
                  receiver        = "webhook-wal-healer"
                  group_wait      = "10s"
                  repeat_interval = "6h"
                  continue        = true
                },
              ] : [],
              # Territory Grounder — fan actionable alerts to TG in parallel with n8n. Placed AFTER the
              # null routes so Watchdog/InfoInhibitor/KubeAPIErrorBudgetBurn are consumed first and never
              # reach TG.
              #
              # ⚠ CORRECTED 2026-08-03 — this comment previously claimed `continue = true` means the alert
              # "still falls through to the default receiver (n8n)". THAT IS NOT ALERTMANAGER'S ROUTING
              # SEMANTICS. `continue` only allows evaluation to proceed to the NEXT SIBLING route; a
              # parent's own `receiver` fires ONLY when no child route matched at all. Because
              # `severity =~ "warning|critical"` matches essentially every actionable alert, the default
              # `webhook-n8n` became unreachable the moment this route landed (commit 5031322, 2026-07-17).
              #
              # Effect, measured 2026-08-03: for 17 days EVERY warning/critical in the estate reached
              # Territory Grounder ONLY — the documented n8n → Matrix #infra-nl-prod → k8s-triage.sh
              # → YouTrack pipeline received nothing. Found via REDACTED_96945896, which fired
              # continuously for ~22h (notrf01dmz01 root fs 85→92%, 2026-08-02T16:31Z → 2026-08-03T14:31Z)
              # while Alertmanager's /api/v2/alerts held 0 such alerts and YouTrack had 0 triage issues.
              #
              # The explicit webhook-n8n sibling at the END of this list is what actually implements the
              # "parallel to n8n" intent. Do NOT delete it believing the default receiver covers it.
              var.tg_webhook_url != "" ? [
                {
                  matchers = ["severity =~ \"warning|critical\""]
                  receiver = "webhook-tg"
                  continue = true
                },
              ] : [],
              # Tier-1 critical alerts → paging bridge (ntfy push; SMS only for
              # page="sms" — 2026-08-25 cutover). `continue = true` here lets evaluation reach the
              # explicit webhook-n8n sibling below (NOT the parent default — see the correction above),
              # so a tier-1 critical still reaches Matrix/YouTrack as well as the phone.
              var.paging_bridge_url != "" ? [
                {
                  matchers = ["tier = 1", "severity = critical"]
                  receiver = "page-tier1"
                  continue = true
                  # Independent timing — escalate fast, don't wait for the
                  # 30s/5m group_wait/group_interval used by the chat path.
                  group_wait      = "10s"
                  group_interval  = "1m"
                  repeat_interval = "1h"
                },
              ] : [],
              # The EXPLICIT n8n leg of the fan-out. Terminal (no `continue`) — anything that should also
              # page or reach TG has already matched a sibling above. This route is the ONLY thing that
              # delivers warning/critical alerts to n8n → Matrix → YouTrack triage; it is not redundant
              # with the parent `receiver = "webhook-n8n"`, which is unreachable for these alerts.
              [
                {
                  matchers = ["severity =~ \"warning|critical\""]
                  receiver = "webhook-n8n"
                },
              ],
            )
          }
        }
        alertmanagerSpec = {
          replicas = 2

          # Mount the TG ingest bearer token (ExternalSecret tg-ingest-token) at
          # REDACTED_0edcce58 for the webhook-tg receiver's credentials_file.
          secrets = var.tg_webhook_url != "" ? ["tg-ingest-token"] : []

          # Scrape all ServiceMonitors and PodMonitors (not just release=monitoring)
          serviceMonitorSelector                  = {}
          serviceMonitorSelectorNilUsesHelmValues = false
          serviceMonitorNamespaceSelector         = {}
          podMonitorSelector                      = {}
          podMonitorSelectorNilUsesHelmValues     = false
          podMonitorNamespaceSelector             = {}

          podDisruptionBudget = {
            enabled      = true
            minAvailable = 1
          }

          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.alertmanager_storage_class
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.alertmanager_storage_size
                  }
                }
              }
            }
          }

          resources = {
            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
          }

          affinity = {
            nodeAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = {
                nodeSelectorTerms = [{
                  matchExpressions = [{
                    key      = "node-role.kubernetes.io/control-plane"
                    operator = "DoesNotExist"
                  }]
                }]
              }
            }
            podAntiAffinity = {
              preferredDuringSchedulingIgnoredDuringExecution = [{
                weight = 100
                podAffinityTerm = {
                  labelSelector = {
                    matchExpressions = [{
                      key      = "app.kubernetes.io/name"
                      operator = "In"
                      values   = ["alertmanager"]
                    }]
                  }
                  topologyKey = "kubernetes.io/hostname"
                }
              }]
            }
          }

          tolerations = []
        }
      }

      # =========================================================================
      # GRAFANA CONFIGURATION (NFS for RWX multi-replica support)
      # =========================================================================
      grafana = {
        replicas = var.grafana_replicas

        # Scrape all ServiceMonitors and PodMonitors (not just release=monitoring)
        serviceMonitorSelector                  = {}
        serviceMonitorSelectorNilUsesHelmValues = false
        serviceMonitorNamespaceSelector         = {}
        podMonitorSelector                      = {}
        podMonitorSelectorNilUsesHelmValues     = false
        podMonitorNamespaceSelector             = {}

        podDisruptionBudget = {
          enabled      = true
          minAvailable = 1
        }

        # Use existing secret created by ExternalSecret instead of plaintext password
        admin = {
          existingSecret = "monitoring-grafana"
          userKey        = "admin-user"
          passwordKey    = REDACTED_e7c10ed7
        }

        persistence = {
          enabled          = true
          storageClassName = var.grafana_storage_class
          size             = var.grafana_storage_size
        }

        # Velero opt-in fs-backup (IFRNLLEI01PRD-2605): hand-authored dashboards/
        # orgs beyond the IaC-provisioned set live only on this volume. The
        # annotation value is the pod-spec VOLUME name ("storage"), not the PVC.
        podAnnotations = {
          "backup.velero.io/backup-volumes" = "storage"
        }

        # IFRNLLEI01PRD-2605: the chart's init-chown-data runs chown -R as root
        # with capabilities [drop ALL, add CHOWN] — no DAC_OVERRIDE — so on a
        # LIVED-IN volume it cannot traverse grafana's own 0700 png/csv/pdf
        # dirs and crash-loops (reproduced on notrf01; three kps applies
        # rolled back on it). It only ever succeeds against a fresh empty
        # volume. Ownership is already guaranteed by pod fsGroup=472 (kubelet
        # applies fsGroup on local/iSCSI PVs; the NL/GR NFS volumes are
        # long-established). If a brand-new NFS grafana volume ever appears,
        # chown it once by hand.
        initChownData = {
          enabled = false
        }

        service = {
          type     = "NodePort"
          nodePort = 30000
        }

        "grafana.ini" = {
          security = {
            allow_embedding                  = true
            content_security_policy          = true
            content_security_policy_template = "script-src 'self' 'unsafe-eval' 'unsafe-inline' 'strict-dynamic' $NONCE;object-src 'none';font-src 'self';style-src 'self' 'unsafe-inline' blob:;img-src * data:;base-uri 'self';connect-src 'self' grafana.com ws://$ROOT_PATH wss://$ROOT_PATH;manifest-src 'self';media-src 'none';form-action 'self';frame-ancestors 'self' https://matrix.example.net vector://vector;"
          }
          "auth.anonymous" = {
            enabled  = true
            org_name = "Main Org."
            org_role = "Viewer"
          }
        }

        affinity = {
          nodeAffinity = {
            requiredDuringSchedulingIgnoredDuringExecution = {
              nodeSelectorTerms = [{
                matchExpressions = [{
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }]
              }]
            }
          }
          podAntiAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [{
              weight = 100
              podAffinityTerm = {
                labelSelector = {
                  matchExpressions = [{
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values   = ["grafana"]
                  }]
                }
                topologyKey = "kubernetes.io/hostname"
              }
            }]
          }
        }

        tolerations = []

        # Mount datasource credentials (from ExternalSecrets) for $__file references
        extraSecretMounts = [
          {
            name       = "finops-db-ro"
            secretName = "monitoring-finops-db-ro"
            mountPath  = "REDACTED_c7ec4346"
            readOnly   = true
          },
          {
            name       = "openobserve-ro"
            secretName = "monitoring-openobserve-ro"
            mountPath  = "/etc/secrets/openobserve-ro"
            readOnly   = true
          }
        ]

        sidecar = {
          datasources = {
            defaultDatasourceEnabled = false
          }
          # Memory REQUEST only (no limit): a request lifts the dashboard/datasource
          # sidecars out of BestEffort so they aren't first-killed on node OOM (the
          # ContainerOOMKilled at 2026-06-24 04:40). Do NOT add a memory limit — the
          # sidecars load ALL grafana_dashboard configmaps (chart defaults + custom) at
          # startup, a multi-hundred-MB spike; a 192Mi limit cgroup-OOM-killed them and
          # took grafana down (rev 11). No LimitRange in this ns, so this stays uncapped.
          resources = {
            requests = {
              cpu    = "10m"
              memory = "64Mi"
            }
          }
        }

        additionalDataSources = [
          {
            name      = "Prometheus"
            type      = "prometheus"
            uid       = "prometheus"
            url       = "http://thanos-query.monitoring:9090"
            access    = "proxy"
            isDefault = true
            jsonData = {
              httpMethod   = "POST"
              timeInterval = "30s"
            }
          },
          {
            name      = "Loki"
            type      = "loki"
            url       = "http://loki.logging.svc.cluster.local:3100"
            access    = "proxy"
            isDefault = false
            jsonData = {
              maxLines = 1000
            }
          },
          {
            name          = "OpenObserve"
            type          = "prometheus"
            uid           = "openobserve"
            url           = "http://10.0.X.X:5080/api/default/prometheus"
            access        = "proxy"
            isDefault     = false
            basicAuth     = true
            basicAuthUser = "chatops@mail.example.net"
            secureJsonData = {
              basicAuthPassword = "$__file{/etc/secrets/openobserve-ro/password}"
            }
            jsonData = {
              httpMethod   = "POST"
              timeInterval = "30s"
            }
          },
          {
            name      = "finops-ledger"
            type      = "mysql"
            uid       = "finops-ledger"
            url       = "nlproxysql01.example.net:6033"
            database  = "finops"
            user      = "grafana_ro"
            access    = "proxy"
            isDefault = false
            jsonData = {
              maxOpenConns    = 5
              maxIdleConns    = 2
              connMaxLifetime = 14400
            }
            secureJsonData = {
              password = "$__file{REDACTED_c7ec4346/password}"
            }
          }
        ]
      }

      # =========================================================================
      # KUBE-STATE-METRICS CONFIGURATION
      # =========================================================================
      kube-state-metrics = {
        podDisruptionBudget = {
          enabled      = true
          minAvailable = 1
        }

        affinity = {
          nodeAffinity = {
            requiredDuringSchedulingIgnoredDuringExecution = {
              nodeSelectorTerms = [{
                matchExpressions = [{
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }]
              }]
            }
          }
        }

        tolerations = []
      }

      # =========================================================================
      # PROMETHEUS OPERATOR CONFIGURATION
      # =========================================================================
      prometheusOperator = {
        podDisruptionBudget = {
          enabled      = true
          minAvailable = 1
        }

        affinity = {
          nodeAffinity = {
            requiredDuringSchedulingIgnoredDuringExecution = {
              nodeSelectorTerms = [{
                matchExpressions = [{
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }]
              }]
            }
          }
        }

        tolerations = []
      }

      # =========================================================================
      # NODE EXPORTER - DaemonSet (runs on ALL nodes including control plane)
      # =========================================================================
      prometheus-node-exporter = merge({
        tolerations = [{
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }]
        }, var.node_exporter_port == 9100 ? {} : {
        # Sites whose HOSTS already run a node-exporter on 9100 (the edge DMZ
        # baseline) move the in-cluster DS off the default port.
        service = {
          port = var.node_exporter_port
        }
      })

      # =========================================================================
      # ADDITIONAL SETTINGS
      # =========================================================================
      # Disable monitoring for components that can't be scraped:
      # - kubeProxy: Cilium replaces kube-proxy (no pods exist)
      # - kubeControllerManager: binds to 127.0.0.1:10257, not reachable from Prometheus
      # - kubeScheduler: binds to 127.0.0.1:10259, not reachable from Prometheus
      # These components are healthy but their metrics are not exposed to the pod network.
      #
      # kubeEtcd ENABLED 2026-06-26: NL etcd's dedicated metrics port (:2381) is loopback-only,
      # but the client port (:2379) serves /metrics over mTLS and binds the node IP, so we scrape
      # node-IP:2379 with the etcd healthcheck-client cert (secret REDACTED_d8074874-etcd-client-cert,
      # created out-of-band, mounted via prometheusSpec.secrets). Closes the NL etcd monitoring gap
      # (the -863 apiserver/etcd crash-loop was caught by hand because nothing alerted). Enabling
      # kubeEtcd also pulls in the upstream etcd alert rules.
      kubeEtcd = {
        enabled   = true
        endpoints = var.etcd_endpoints
        service = {
          enabled    = true
          port       = 2379
          targetPort = 2379
        }
        serviceMonitor = {
          scheme             = "https"
          insecureSkipVerify = true
          caFile             = "/etc/prometheus/secrets/REDACTED_d8074874-etcd-client-cert/ca.crt"
          certFile           = "/etc/prometheus/secrets/REDACTED_d8074874-etcd-client-cert/healthcheck-client.crt"
          keyFile            = "/etc/prometheus/secrets/REDACTED_d8074874-etcd-client-cert/healthcheck-client.key"
        }
      }

      kubeControllerManager = {
        enabled = false
      }

      kubeScheduler = {
        enabled = false
      }

      kubeProxy = {
        enabled = false
      }

      # Kubelet: enabled (default). Explicit config forces Helm reconciliation
      # which regenerates the kubelet Service endpoints with current node IPs.
      # Stale endpoints from pre-reIP (192.168.181.x) caused TargetDown alert
      # (IFRNLLEI01PRD-251, firing since 2026-03-14).
      kubelet = {
        enabled = true
        serviceMonitor = {
          interval = "30s"
        }
      }
    })
    ],
    # Overlay 1 — satellite mode: ship every scraped sample to a hub
    # Prometheus via remote_write (notrf01 -> NL). "" = overlay absent.
    var.prometheus_remote_write_url != "" ? [
      yamlencode({
        prometheus = {
          prometheusSpec = {
            remoteWrite = [
              {
                url = var.prometheus_remote_write_url
                # Satellite cardinality guard (2026-08-20, IFRNLLEI01PRD-2423/-2427):
                # the unfiltered notrf01 stream put ~545k series into the NL hub's
                # Prometheus (902k head total on 8 GB nodes) and OOM-looped both hub
                # replicas at their 6.5Gi limit within a day of hub-mode cutover.
                # Histogram buckets were 256k of those series. Drop them at the
                # sender: the satellite's local Prometheus keeps full resolution
                # (buckets included), the hub keeps _sum/_count so cross-site rates
                # and means still work — only cross-site quantiles are lost. The
                # operator's config-reloader hot-reloads this (no pod restart).
                # The hub returns RW-2.0 written-stats headers
                # (X-Prometheus-Remote-Write-Samples-Written) on EVERY 204, hardcoded to
                # 0. Under the default V1.0 message version the sender still reads that
                # header, concludes nothing landed, logs "we got 2xx status code from the
                # Receiver yet statistics indicate some data was not written" and counts
                # EVERY sample failed - measured on notrf01 2026-08-27:
                # samples_failed_total rate == samples_total rate exactly (5237/s each),
                # i.e. a 100% failure reading, while 330,605 site="no" series were live
                # and fresh at the hub. The counter was spurious, and it drove
                # PrometheusRemoteStorageFailures. Speaking V2.0 (both ends are Prometheus
                # v3.8.0 and the hub has enableRemoteWriteReceiver) makes those headers
                # meaningful instead of decorative.
                messageVersion = "V2.0"
                writeRelabelConfigs = [
                  {
                    sourceLabels = ["__name__"]
                    regex        = ".+_bucket"
                    action       = "drop"
                  },
                  # Drop LOCALLY-EVALUATED series: recording-rule outputs (the
                  # level:metric:operation convention always contains a colon) and the
                  # ALERTS/ALERTS_FOR_STATE pair. The hub evaluates the identical
                  # kube-prometheus recording rules over the same remote-written raw
                  # series, so the satellite's copies are redundant - and they were the
                  # ONLY thing failing: on 2026-08-27 the hub logged "Out of order sample
                  # from remote write" against exactly these names (instance:node_cpu:ratio,
                  # count:up1, ALERTS, node_namespace_pod_container:*), 100% site="no",
                  # while every scraped metric landed fine. The hub runs
                  # tsdb.outOfOrderTimeWindow=0s, so a satellite HA pair evaluating the same
                  # rules and writing into one receiver collides by construction. Dropping
                  # them at the sender fixes it without loosening the hub's TSDB or losing
                  # any raw data. Alert DELIVERY is unaffected - that rides Alertmanager to
                  # the NL paging bridge, not this stream.
                  {
                    sourceLabels = ["__name__"]
                    regex        = "ALERTS|ALERTS_FOR_STATE|.*:.*"
                    action       = "drop"
                  }
                ]
              }
            ]
          }
        }
      })
    ] : [],
    # Overlay 2 — hub mode: accept remote_write streams on
    # /api/v1/write (NL receives notrf01). false = overlay absent.
    var.REDACTED_923cce14 ? [
      yamlencode({
        prometheus = {
          prometheusSpec = {
            enableRemoteWriteReceiver = true
          }
        }
      })
    ] : [],
  )
}

# -----------------------------------------------------------------------------
# Prometheus Ingress
# -----------------------------------------------------------------------------
resource "kubernetes_ingress_v1" "prometheus" {
  count = var.REDACTED_4c06acbb ? 1 : 0

  metadata {
    name      = "prometheus"
    namespace = "monitoring"
    labels = merge(var.common_labels, {
      "app.kubernetes.io/name" = "prometheus"
    })
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = var.prometheus_hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "REDACTED_6dfbe9fc"
              port {
                number = 9090
              }
            }
          }
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Grafana Ingress
# -----------------------------------------------------------------------------
resource "kubernetes_ingress_v1" "grafana" {
  count = var.grafana_ingress_enabled ? 1 : 0

  metadata {
    name      = "grafana"
    namespace = "monitoring"
    labels = merge(var.common_labels, {
      "app.kubernetes.io/name" = "grafana"
    })
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.grafana_hostname

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "monitoring-grafana"
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
