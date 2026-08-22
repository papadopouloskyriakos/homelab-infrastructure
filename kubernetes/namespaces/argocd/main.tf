# =============================================================================
# Argo CD - GitOps Continuous Delivery
# =============================================================================
# Provides declarative GitOps for Kubernetes applications
# UI accessible via NodePort or Ingress
#
# NOTE (NL, 2026-03-15): a runtime patch created the `argocd-secret`
# server.secretkey on NL — it is generated at install and lives outside this
# module; do not "adopt" or rotate it via TF (rotating invalidates sessions).
# =============================================================================

locals {
  # Notifier/template/trigger blocks only render when notifications are on AND
  # a Matrix token is present — an empty token would ship a dead webhook.
  argocd_notifications_active = var.REDACTED_035cbec1 && var.argocd_matrix_token != ""
}

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"

    labels = merge(var.common_labels, {
      "app.kubernetes.io/name"    = "argocd"
      "app.kubernetes.io/part-of" = "argocd"
    })
  }
}

# -----------------------------------------------------------------------------
# ExternalSecrets for GitLab Repository Credentials (one per map entry)
# -----------------------------------------------------------------------------
# Creates the repository secrets BEFORE the Helm release. ArgoCD auto-discovers
# secrets carrying the argocd.argoproj.io/secret-type=repository label and
# matches them to applications by EXACT repo URL — hence url_override for
# entries whose OpenBao-stored url points at a different repo (found 2026-08-16
# deploying velero on GR: apps sourcing gr-gitlab.../gr/production.git
# failed "REDACTED_6fa691d2 required" because the shared secret's url resolved to
# the NL repo; IFRNLLEI01PRD-2374).
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "repo_credentials" {
  for_each = var.REDACTED_9360424f

  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = each.key
      namespace = kubernetes_namespace.argocd.metadata[0].name
      labels = {
        environment  = "production"
        site         = var.site
        "managed-by" = "opentofu"
      }
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      # The two target shapes have inconsistent object types, which a bare HCL
      # ternary rejects — each branch goes through jsonencode/jsondecode.
      target = jsondecode(each.value.url_override == null ? jsonencode({
        name           = each.key
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
        template = {
          metadata = {
            labels = {
              # This label is required for ArgoCD to recognize it as a repository secret
              "argocd.argoproj.io/secret-type" = "repository"
            }
          }
        }
        }) : jsonencode({
        name           = each.key
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
        template = {
          engineVersion = "v2"
          metadata = {
            labels = {
              "argocd.argoproj.io/secret-type" = "repository"
            }
          }
          data = {
            username = "{{ .username }}"
            password = "{{ .password }}"
            url      = each.value.url_override
            type     = "git"
          }
        }
      }))
      data = [
        for property in(each.value.url_override == null ? ["username", "password", "url", "type"] : ["username", "password"]) : {
          secretKey = property
          remoteRef = {
            key      = each.value.openbao_path
            property = property
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_namespace.argocd]
}

# -----------------------------------------------------------------------------
# Argo CD Helm Release
# -----------------------------------------------------------------------------
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = var.REDACTED_be8b31fd
  timeout    = 600
  wait       = true

  # Ensure ExternalSecrets create the repo credentials first
  depends_on = [
    kubernetes_namespace.argocd,
    kubernetes_manifest.repo_credentials
  ]

  values = [
    yamlencode({
      global = {
        domain = var.argocd_hostname
        # Force Helm upgrade to deploy notifications controller (2026-03-14)
        revisionHistoryLimit = 3
      }

      server = {
        replicas = var.REDACTED_7ce225ce

        # OMOIKANE-1657 — see the controller block.
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }

        pdb = {
          enabled      = true
          minAvailable = 1
        }

        service = {
          type          = "NodePort"
          nodePortHttps = var.argocd_nodeport
        }

        ingress = {
          enabled          = var.REDACTED_84146aee
          ingressClassName = "nginx"
          hostname         = var.argocd_hostname
          annotations = {
            "nginx.ingress.kubernetes.io/ssl-passthrough"  = "true"
            "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
          }
          tls = var.REDACTED_84146aee
        }

        extraArgs = var.REDACTED_649263f1 ? ["--insecure"] : []

        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      controller = {
        replicas = 1

        # OMOIKANE-1657 — the controller ALWAYS serves /metrics on :8082;
        # what was missing estate-wide is the Service + ServiceMonitor, so
        # Prometheus held ZERO argocd_* series and every argocd_app_info
        # alert in custom-alerts.tf was decorative. REDACTED_d8074874
        # scrapes all ServiceMonitors (nil selector in monitoring/main.tf),
        # so enabling these is the whole fix. Keys verified against chart
        # argo-cd 7.7.10 values (metrics.enabled + metrics.serviceMonitor).
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }

        pdb = {
          enabled      = true
          minAvailable = 1
        }

        resources = {
          requests = {
            cpu    = "250m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "1"
            memory = "1Gi"
          }
        }
      }

      repoServer = {
        replicas = var.argocd_repo_server_replicas

        # OMOIKANE-1657 — see the controller block.
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
          }
        }

        pdb = {
          enabled      = true
          minAvailable = 1
        }

        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      redis = {
        pdb = {
          enabled      = true
          minAvailable = 1
        }

        resources = {
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "128Mi"
          }
        }
      }

      applicationSet = {
        enabled  = true
        replicas = 1

        pdb = {
          enabled      = true
          minAvailable = 1
        }

        resources = {
          requests = {
            cpu    = "50m"
            memory = "64Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }

      notifications = {
        enabled = var.REDACTED_035cbec1

        notifiers = local.argocd_notifications_active ? {
          "service.webhook.matrix-alerts" = <<-EOT
            url: https://matrix.example.net/_matrix/client/v3/rooms/!xeNxtpScJWCmaFjeCL:matrix.example.net/send/m.room.message/argocd-$${time.Now.Unix}
            headers:
            - name: Authorization
              value: Bearer ${var.argocd_matrix_token}
            - name: Content-Type
              value: application/json
          EOT
        } : {}

        subscriptions = local.argocd_notifications_active ? [
          {
            recipients = ["webhook:matrix-alerts"]
            triggers   = ["on-health-degraded", "on-sync-failed", "on-sync-status-unknown"]
          }
        ] : []

        templates = local.argocd_notifications_active ? {
          "template.app-health-degraded"     = <<-EOT
            webhook:
              matrix-alerts:
                method: PUT
                body: |
                  {"msgtype":"m.text","body":"${var.REDACTED_2f84acaa} {{.app.metadata.name}} health DEGRADED\nStatus: {{.app.status.health.status}}\nSync: {{.app.status.sync.status}}\nURL: https://${var.argocd_hostname}/applications/{{.app.metadata.name}}"}
          EOT
          "template.app-sync-failed"         = <<-EOT
            webhook:
              matrix-alerts:
                method: PUT
                body: |
                  {"msgtype":"m.text","body":"${var.REDACTED_2f84acaa} {{.app.metadata.name}} sync FAILED\nError: {{.app.status.operationState.message}}\nURL: https://${var.argocd_hostname}/applications/{{.app.metadata.name}}"}
          EOT
          "template.app-sync-status-unknown" = <<-EOT
            webhook:
              matrix-alerts:
                method: PUT
                body: |
                  {"msgtype":"m.text","body":"${var.REDACTED_2f84acaa} {{.app.metadata.name}} sync status UNKNOWN\nURL: https://${var.argocd_hostname}/applications/{{.app.metadata.name}}"}
          EOT
          "template.app-sync-succeeded"      = <<-EOT
            webhook:
              matrix-alerts:
                method: PUT
                body: |
                  {"msgtype":"m.text","body":"${var.REDACTED_2f84acaa} {{.app.metadata.name}} synced successfully\nRevision: {{.app.status.sync.revision}}\nURL: https://${var.argocd_hostname}/applications/{{.app.metadata.name}}"}
          EOT
        } : {}

        triggers = local.argocd_notifications_active ? {
          "trigger.on-health-degraded"     = <<-EOT
            - description: Application health degraded
              send:
              - app-health-degraded
              when: app.status.health.status == 'Degraded'
          EOT
          "trigger.on-sync-failed"         = <<-EOT
            - description: Application sync failed
              send:
              - app-sync-failed
              when: app.status.operationState != nil and app.status.operationState.phase in ['Error', 'Failed']
          EOT
          "trigger.on-sync-status-unknown" = <<-EOT
            - description: Application sync status unknown
              send:
              - app-sync-status-unknown
              when: app.status.sync.status == 'Unknown'
          EOT
          "trigger.on-sync-succeeded"      = <<-EOT
            - description: Application synced successfully
              oncePer: app.status.sync.revision
              send:
              - app-sync-succeeded
              when: app.status.operationState != nil and app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'
          EOT
        } : {}
      }

      dex = {
        enabled = var.argocd_dex_enabled
      }

      redis-ha = {
        enabled = false
      }

      configs = {
        repositories = var.argocd_repositories

        ssh = {
          knownHosts = var.argocd_ssh_known_hosts
        }

        rbac = {
          "policy.default" = "role:readonly"
          "policy.csv"     = <<-EOT
            g, admins, role:admin
          EOT
        }

        params = {
          "server.insecure" = var.REDACTED_649263f1
        }

        cm = {
          # Velero CRs churn constantly (backups/restores) — excluding them
          # fixed the chronic velero app OutOfSync (NL MR !230)
          "resource.exclusions" = yamlencode([
            {
              apiGroups = ["velero.io"]
              kinds     = ["Backup", "Restore", "DeleteBackupRequest", "PodVolumeBackup", "PodVolumeRestore", "BackupRepository"]
              clusters  = ["*"]
            }
          ])
        }
      }
    })
  ]
}

# -----------------------------------------------------------------------------
# ExternalSecret for ArgoCD Redis Password
# -----------------------------------------------------------------------------
# Redis password stored in OpenBao for persistence across reboots
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "argocd_redis_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "argocd-redis"
      namespace = kubernetes_namespace.argocd.metadata[0].name
      labels = {
        environment  = "production"
        site         = var.site
        "managed-by" = "opentofu"
      }
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "argocd-redis"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "auth"
          remoteRef = {
            key      = "REDACTED_e4fc5799"
            property = "auth"
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_namespace.argocd]
}
