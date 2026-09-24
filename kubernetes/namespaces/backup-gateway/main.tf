# =============================================================================
# Backup gateway: rclone `serve s3` over a `crypt` remote on Hetzner Object Storage
# (IFRNLLEI01PRD-2850, 2026-09-23)
#
# nl-s3 (SeaweedFS on two Synology iSCSI LUNs) filled four times since July and
# latched read-only three times since August; the estate's backups, metrics
# history and logs all rode it. They now go to Hetzner Object Storage (fsn1)
# under ONE rule, decided by the operator on 2026-09-23:
#
#   NOTHING REACHES HETZNER UNENCRYPTED, NOW OR FOR ANY FUTURE CONSUMER, AND
#   EXACTLY ONE HETZNER CREDENTIAL EXISTS IN THE ESTATE, HELD ONLY BY THIS GATEWAY.
#
# How the rule is structural rather than a convention:
#   * The Hetzner key and the crypt key live at OpenBao secret/k8s/backup-gateway/
#     {hetzner,crypt}. The general `external-secrets` policy carries an explicit
#     deny on both; only the OpenBao role `backup-gateway` (bound to the SA
#     backup-gateway-eso in this namespace, reached through the dedicated
#     ClusterSecretStore `REDACTED_336e5cad` below) can read them.
#   * Consumers (Velero, CNPG barman, Thanos, Loki, filer-meta) talk plain S3 to
#     the ClusterIP Service backup-gateway:8080 with the gateway's LOCAL key pair
#     (secret/REDACTED_218b2888), which means nothing outside the cluster.
#   * The gateway serves `crypt:` (NaCl secretbox, filename + directory-name
#     encryption). There is no plaintext path through it.
#   * The `REDACTED_54583949` CronJob lists the bucket as Hetzner sees it and
#     fails if any name is not crypt-shaped or any other bucket exists
#     (REDACTED_c95e2714, tier 1).
#
# One shared crypt key for all sites, so any surviving site can restore any
# other site's backups. Escrow: OpenBao + Vaultwarden. Losing the crypt key
# loses every backup.
#
# Adding a consumer (checklist, also in k8s/CLAUDE.md):
#   1. endpoint = http://backup-gateway.backup-gateway.svc.cluster.local:8080, path-style
#   2. credentials = ExternalSecret from REDACTED_218b2888 (access_key/secret_key)
#   3. its namespace in REDACTED_ff855352 (tfvars)
#      (a HOST-level consumer instead needs REDACTED_ea08c35b = true)
#   4. its own CiliumNetworkPolicy, if any, allows egress to backup-gateway:8080
#   5. NO new OpenBao path, tfvars value or CI variable that references Hetzner
# =============================================================================

locals {
  labels = merge(var.common_labels, {
    "app.kubernetes.io/name"      = "backup-gateway"
    "app.kubernetes.io/component" = "crypt-gateway"
  })
  selector = {
    "app.kubernetes.io/name" = "backup-gateway"
  }
  gateway_url = "http://backup-gateway.${var.namespace}.svc.cluster.local:8080"
}

# -----------------------------------------------------------------------------
# Namespace + the ONLY identity that may read the Hetzner credential
# -----------------------------------------------------------------------------
resource "REDACTED_46569c16" "backup_gateway" {
  metadata {
    name = var.namespace
    labels = merge(local.labels, {
      name                                 = var.namespace
      "pod-security.kubernetes.io/enforce" = "restricted"
    })
  }
}

resource "REDACTED_4ad9fc99_v1" "eso" {
  metadata {
    name      = "backup-gateway-eso"
    namespace = REDACTED_46569c16.backup_gateway.metadata[0].name
    labels    = local.labels
  }
}

# Dedicated store: same OpenBao, a different role. `conditions.namespaces` means
# an ExternalSecret outside this namespace cannot even reference it.
resource "kubernetes_manifest" "cluster_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ClusterSecretStore"
    metadata = {
      name   = "REDACTED_336e5cad"
      labels = local.labels
    }
    spec = {
      conditions = [{ namespaces = [var.namespace] }]
      provider = {
        vault = {
          server   = var.openbao_address
          path     = "secret"
          version  = "v2"
          caBundle = var.openbao_ca_cert
          auth = {
            kubernetes = {
              mountPath = var.eso_auth_mount_path
              role      = var.openbao_role
              serviceAccountRef = {
                name      = REDACTED_4ad9fc99_v1.eso.metadata[0].name
                namespace = REDACTED_46569c16.backup_gateway.metadata[0].name
              }
            }
          }
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# rclone.conf + the local S3 key pair, rendered by ESO from three OpenBao paths.
# The Hetzner remote is `provider = Ceph` (Hetzner Object Storage is Ceph RGW),
# path-style, multipart from 64 MiB in 16 MiB chunks. The crypt remote sits on
# the bucket, so bucket names as consumers see them are encrypted directories.
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "rclone_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "REDACTED_3e2f7d3c"
      namespace = REDACTED_46569c16.backup_gateway.metadata[0].name
      labels    = local.labels
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef  = { name = "REDACTED_336e5cad", kind = "ClusterSecretStore" }
      target = {
        name           = "REDACTED_3e2f7d3c"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
        template = {
          engineVersion = "v2"
          data = {
            "rclone.conf" = <<-EOT
              [hetzner]
              type = s3
              provider = Ceph
              endpoint = {{ .hz_endpoint }}
              region = ${var.hetzner_region}
              force_path_style = true
              access_key_id = {{ .hz_access_key }}
              secret_access_key = {{ .hz_secret_key }}
              chunk_size = 16M
              upload_concurrency = 4
              upload_cutoff = 64M

              [crypt]
              type = crypt
              remote = hetzner:{{ .hz_bucket }}
              filename_encryption = standard
              directory_name_encryption = true
              password = {{ .cr_password }}
              password2 = {{ .cr_password2 }}
            EOT
            # rclone parses list flags from the environment as CSV, so the pair is
            # CSV-quoted: without the quotes it splits at the comma and refuses to
            # start ("expecting a single comma", first apply 2026-09-23).
            auth_key      = "\"{{ .gw_access_key }},{{ .gw_secret_key }}\""
            bucket        = "{{ .hz_bucket }}"
            gw_access_key = "{{ .gw_access_key }}"
            gw_secret_key = "{{ .gw_secret_key }}"
          }
        }
      }
      data = [
        { secretKey = "hz_access_key", remoteRef = { key = var.hetzner_secret_path, property = "access_key" } },
        { secretKey = "hz_secret_key", remoteRef = { key = var.hetzner_secret_path, property = "secret_key" } },
        { secretKey = "hz_endpoint", remoteRef = { key = var.hetzner_secret_path, property = "endpoint" } },
        { secretKey = "hz_bucket", remoteRef = { key = var.hetzner_secret_path, property = "bucket" } },
        { secretKey = "cr_password", remoteRef = { key = var.crypt_secret_path, property = "password" } },
        { secretKey = "cr_password2", remoteRef = { key = var.crypt_secret_path, property = "password2" } },
        { secretKey = "gw_access_key", remoteRef = { key = var.auth_secret_path, property = "access_key" } },
        { secretKey = "gw_secret_key", remoteRef = { key = var.auth_secret_path, property = "secret_key" } },
      ]
    }
  }
  depends_on = [kubernetes_manifest.cluster_secret_store]
}

# -----------------------------------------------------------------------------
# The gateway. Stateless (crypt is deterministic from the key), so replicas are
# interchangeable; the Service pins a client to one replica so its multipart
# parts and its list-after-write land on the same rclone process.
# -----------------------------------------------------------------------------
resource "REDACTED_08d34ae1" "gateway" {
  metadata {
    name      = "backup-gateway"
    namespace = REDACTED_46569c16.backup_gateway.metadata[0].name
    labels    = local.labels
    annotations = {
      # Reloader restarts the pods when ESO re-renders the Secret (key rotation).
      "reloader.stakater.com/auto" = "true"
    }
  }

  spec {
    replicas = var.replicas

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = 0
        max_surge       = 1
      }
    }

    selector {
      match_labels = local.selector
    }

    template {
      metadata {
        labels = merge(local.labels, local.selector)
      }

      spec {
        service_account_name             = "default"
        automount_service_account_token  = false
        termination_grace_period_seconds = 120

        security_context {
          run_as_non_root = true
          run_as_user     = 65534
          run_as_group    = 65534
          fs_group        = 65534
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        affinity {
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                topology_key = "kubernetes.io/hostname"
                label_selector {
                  match_labels = local.selector
                }
              }
            }
          }
        }

        container {
          name  = "rclone"
          image = var.image
          # `serve s3` streams multipart parts into one upload with the VFS cache
          # off, so a 20 GB barman base backup never touches local disk. The
          # auth key pair comes from the environment, never from argv.
          args = [
            "serve", "s3", "crypt:",
            "--addr", ":8080",
            "--vfs-cache-mode", "off",
            "--dir-cache-time", "30s",
            "--buffer-size", "8M",
            "REDACTED_17750a50", "8M",
            "REDACTED_17750a50-limit", "256M",
            "--transfers", "8",
            "--checkers", "8",
            "--cache-dir", "/tmp/rclone",
            "--log-level", "INFO",
            "--log-format", "json",
            "--metrics-addr", ":9090",
          ]

          env {
            name  = "RCLONE_CONFIG"
            value = "/config/rclone.conf"
          }
          env {
            name  = "HOME"
            value = "/tmp"
          }
          env {
            name = "RCLONE_AUTH_KEY"
            value_from {
              secret_key_ref {
                name = "REDACTED_3e2f7d3c"
                key  = "auth_key"
              }
            }
          }

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }
          port {
            name           = "metrics"
            container_port = 9090
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              memory = var.memory_limit
            }
          }

          liveness_probe {
            tcp_socket {
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 20
          }
          readiness_probe {
            tcp_socket {
              port = "http"
            }
            initial_delay_seconds = 3
            period_seconds        = 10
          }

          security_context {
            # The provider writes runAsNonRoot=false when this is omitted at the
            # container level, and the restricted PSA rejects that (apply 2026-09-23).
            run_as_non_root            = true
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/config"
            read_only  = true
          }
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }

        volume {
          name = "config"
          secret {
            secret_name  = "REDACTED_3e2f7d3c"
            default_mode = "0440"
            items {
              key  = "rclone.conf"
              path = "rclone.conf"
            }
          }
        }
        volume {
          name = "tmp"
          empty_dir {}
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.rclone_secret]
}

resource "kubernetes_service_v1" "gateway" {
  metadata {
    name      = "backup-gateway"
    namespace = REDACTED_46569c16.backup_gateway.metadata[0].name
    labels    = local.labels
  }
  spec {
    type     = "ClusterIP"
    selector = local.selector
    # A client's multipart parts and its list-after-write must reach ONE replica
    # (per-replica directory cache, in-flight streaming upload).
    session_affinity = "ClientIP"
    session_affinity_config {
      client_ip {
        timeout_seconds = 10800
      }
    }
    port {
      name        = "http"
      port        = 8080
      target_port = "http"
      protocol    = "TCP"
    }
    port {
      name        = "metrics"
      port        = 9090
      target_port = "metrics"
      protocol    = "TCP"
    }
  }
}

resource "REDACTED_e0540b90" "gateway" {
  count = var.replicas > 1 ? 1 : 0
  metadata {
    name      = "backup-gateway"
    namespace = REDACTED_46569c16.backup_gateway.metadata[0].name
    labels    = local.labels
  }
  spec {
    min_available = 1
    selector {
      match_labels = local.selector
    }
  }
}

resource "kubernetes_manifest" "service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "backup-gateway"
      namespace = REDACTED_46569c16.backup_gateway.metadata[0].name
      labels    = merge(local.labels, { release = "monitoring" })
    }
    spec = {
      selector          = { matchLabels = local.selector }
      namespaceSelector = { matchNames = [var.namespace] }
      endpoints         = [{ port = "metrics", interval = "60s", path = "/metrics" }]
    }
  }
  depends_on = [kubernetes_service_v1.gateway]
}

# -----------------------------------------------------------------------------
# Network policy: only listed namespaces may talk to the gateway; the gateway may
# talk only to DNS and the internet on 443 (Hetzner).
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "network_policy" {
  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "CiliumNetworkPolicy"
    metadata = {
      name      = "REDACTED_d5ee61f4"
      namespace = REDACTED_46569c16.backup_gateway.metadata[0].name
      labels    = local.labels
    }
    spec = {
      endpointSelector = { matchLabels = local.selector }
      ingress = concat(
        [
          for ns in distinct(concat(var.allowed_namespaces, [var.namespace])) : {
            fromEndpoints = [{ matchLabels = { "k8s:io.kubernetes.pod.namespace" = ns } }]
            toPorts       = [{ ports = [{ port = "8080", protocol = "TCP" }] }]
          }
        ],
        [
          {
            fromEndpoints = [{
              matchLabels = {
                "k8s:io.kubernetes.pod.namespace" = "monitoring"
                "app.kubernetes.io/name"          = "prometheus"
              }
            }]
            toPorts = [{ ports = [{ port = "9090", protocol = "TCP" }] }]
          }
        ],
        var.allow_host_ingress ? [
          {
            fromEntities = ["host", "remote-node"]
            toPorts      = [{ ports = [{ port = "8080", protocol = "TCP" }] }]
          }
        ] : []
      )
      egress = [
        {
          toEndpoints = [{
            matchLabels = {
              "k8s:io.kubernetes.pod.namespace" = "kube-system"
              "k8s-app"                         = "kube-dns"
            }
          }]
          toPorts = [{ ports = [{ port = "53", protocol = "UDP" }, { port = "53", protocol = "TCP" }] }]
        },
        {
          toEntities = ["world"]
          toPorts    = [{ ports = [{ port = "443", protocol = "TCP" }] }]
        }
      ]
    }
  }
}

# -----------------------------------------------------------------------------
# Canary: a real write/read/delete through the gateway every 6 h, with the LOCAL
# key only. 64 MiB crosses the gateway's multipart cutoff, so the streaming
# path to Hetzner is exercised, not just the small-object path.
# -----------------------------------------------------------------------------
resource "REDACTED_a9df2e77_v1" "canary_script" {
  metadata {
    name      = "REDACTED_4e0a8ed8-script"
    namespace = REDACTED_46569c16.backup_gateway.metadata[0].name
    labels    = local.labels
  }
  data = {
    "canary.py" = file("${path.module}/canary.py")
  }
}

resource "kubernetes_manifest" "canary_cronjob" {
  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name      = "REDACTED_4e0a8ed8"
      namespace = REDACTED_46569c16.backup_gateway.metadata[0].name
      labels    = local.labels
    }
    spec = {
      schedule                   = var.canary_schedule
      concurrencyPolicy          = "Forbid"
      successfulJobsHistoryLimit = 2
      failedJobsHistoryLimit     = 3
      jobTemplate = {
        spec = {
          ttlSecondsAfterFinished = 172800
          backoffLimit            = 1
          activeDeadlineSeconds   = 1200
          template = {
            metadata = {
              labels = merge(local.labels, { "app.kubernetes.io/name" = "REDACTED_4e0a8ed8" })
              annotations = {
                "REDACTED_6711b17a" = sha256(file("${path.module}/canary.py"))
              }
            }
            spec = {
              restartPolicy                = "Never"
              automountServiceAccountToken = false
              securityContext = {
                runAsNonRoot   = true
                runAsUser      = 65534
                runAsGroup     = 65534
                seccompProfile = { type = "RuntimeDefault" }
              }
              containers = [{
                name    = "canary"
                image   = var.canary_image
                command = ["python3", "/canary/canary.py"]
                env = [
                  { name = "S3_ENDPOINT", value = local.gateway_url },
                  { name = "S3_BUCKET", value = "backup-canary" },
                  { name = "ACCESS_KEY_ID", valueFrom = { REDACTED_5dfff400 = { name = "REDACTED_3e2f7d3c", key = "gw_access_key" } } },
                  { name = "ACCESS_SECRET_KEY", valueFrom = { REDACTED_5dfff400 = { name = "REDACTED_3e2f7d3c", key = "gw_secret_key" } } },
                ]
                securityContext = {
                  allowPrivilegeEscalation = false
                  readOnlyRootFilesystem   = true
                  capabilities             = { drop = ["ALL"] }
                }
                resources = {
                  requests = { cpu = "50m", memory = "128Mi" }
                  limits   = { memory = "512Mi" }
                }
                volumeMounts = [{ name = "script", mountPath = "/canary" }]
              }]
              volumes = [{ name = "script", configMap = { name = "REDACTED_4e0a8ed8-script" } }]
            }
          }
        }
      }
    }
  }
  depends_on = [REDACTED_a9df2e77_v1.canary_script, kubernetes_manifest.rclone_secret]
}

# -----------------------------------------------------------------------------
# The rule's enforcement: what does Hetzner actually hold? Runs in the only
# namespace that may hold the Hetzner key. Fails on any bucket other than ours
# or any object/directory name that is not crypt-shaped (unpadded base32hex, 0-9a-v).
# -----------------------------------------------------------------------------
resource "REDACTED_a9df2e77_v1" "REDACTED_8ad76e58" {
  metadata {
    name      = "REDACTED_54583949-script"
    namespace = REDACTED_46569c16.backup_gateway.metadata[0].name
    labels    = local.labels
  }
  data = {
    "layout-assert.sh" = file("${path.module}/layout-assert.sh")
  }
}

resource "kubernetes_manifest" "REDACTED_42824e41" {
  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name      = "REDACTED_54583949"
      namespace = REDACTED_46569c16.backup_gateway.metadata[0].name
      labels    = local.labels
    }
    spec = {
      schedule                   = var.assert_schedule
      concurrencyPolicy          = "Forbid"
      successfulJobsHistoryLimit = 2
      failedJobsHistoryLimit     = 3
      jobTemplate = {
        spec = {
          ttlSecondsAfterFinished = 172800
          backoffLimit            = 1
          activeDeadlineSeconds   = 900
          template = {
            metadata = {
              labels = merge(local.labels, { "app.kubernetes.io/name" = "REDACTED_54583949" })
              annotations = {
                "REDACTED_6711b17a" = sha256(file("${path.module}/layout-assert.sh"))
              }
            }
            spec = {
              restartPolicy                = "Never"
              automountServiceAccountToken = false
              securityContext = {
                runAsNonRoot   = true
                runAsUser      = 65534
                runAsGroup     = 65534
                fsGroup        = 65534
                seccompProfile = { type = "RuntimeDefault" }
              }
              containers = [{
                name    = "assert"
                image   = var.image
                command = ["/bin/sh", "/assert/layout-assert.sh"]
                env = [
                  { name = "RCLONE_CONFIG", value = "/config/rclone.conf" },
                  { name = "HOME", value = "/tmp" },
                  { name = "HZ_BUCKET", valueFrom = { REDACTED_5dfff400 = { name = "REDACTED_3e2f7d3c", key = "bucket" } } },
                ]
                securityContext = {
                  allowPrivilegeEscalation = false
                  readOnlyRootFilesystem   = true
                  capabilities             = { drop = ["ALL"] }
                }
                resources = {
                  requests = { cpu = "50m", memory = "64Mi" }
                  limits   = { memory = "256Mi" }
                }
                volumeMounts = [
                  { name = "script", mountPath = "/assert" },
                  { name = "config", mountPath = "/config", readOnly = true },
                  { name = "tmp", mountPath = "/tmp" },
                ]
              }]
              volumes = [
                { name = "script", configMap = { name = "REDACTED_54583949-script" } },
                { name = "config", secret = { secretName = "REDACTED_3e2f7d3c", defaultMode = 288, items = [{ key = "rclone.conf", path = "rclone.conf" }] } },
                { name = "tmp", emptyDir = {} },
              ]
            }
          }
        }
      }
    }
  }
  depends_on = [REDACTED_a9df2e77_v1.REDACTED_8ad76e58, kubernetes_manifest.rclone_secret]
}
