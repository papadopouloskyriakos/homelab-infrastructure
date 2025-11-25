# Deploy Velero backup system (manifest-based, not Helm)

***REMOVED***
# Velero - Kubernetes Backup & Disaster Recovery
***REMOVED***
# Backs up K8s resources and persistent volumes
# Uses MinIO as S3-compatible storage backend
# Deployed via kubernetes_manifest (not Helm) to avoid chart issues
***REMOVED***

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------
resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
    labels = merge(var.common_labels, {
      "app.kubernetes.io/name" = "velero"
    })
  }
}

# -----------------------------------------------------------------------------
# Velero S3 Credentials Secret
# -----------------------------------------------------------------------------
resource "kubernetes_secret" "velero_s3_credentials" {
  metadata {
    name      = "velero-s3-credentials"
    namespace = kubernetes_namespace.velero.metadata[0].name
    labels    = var.common_labels
  }

  data = {
    cloud = <<-EOT
[default]
aws_access_key_id=${var.minio_root_user}
aws_secret_access_key=${var.minio_root_password}
EOT
  }

  type = "Opaque"
}

# -----------------------------------------------------------------------------
# Install Velero CRDs
# -----------------------------------------------------------------------------
data "http" "velero_crds" {
  url = "https://raw.githubusercontent.com/vmware-tanzu/velero/v1.14.1/config/crd/v1/crds.yaml"
}

# Split CRDs and apply them
locals {
  velero_crds = [for doc in split("---", data.http.velero_crds.response_body) : yamldecode(doc) if length(regexall("(?m)^kind:\\s*CustomResourceDefinition", doc)) > 0]
}

resource "kubernetes_manifest" "velero_crds" {
  for_each = { for idx, crd in local.velero_crds : crd.metadata.name => crd }

  manifest = each.value

  field_manager {
    force_conflicts = true
  }
}

# -----------------------------------------------------------------------------
# Velero ServiceAccount
# -----------------------------------------------------------------------------
resource "REDACTED_4ad9fc99" "velero" {
  metadata {
    name      = "velero"
    namespace = kubernetes_namespace.velero.metadata[0].name
    labels    = var.common_labels
  }

  depends_on = [kubernetes_manifest.velero_crds]
}

# -----------------------------------------------------------------------------
# Velero ClusterRoleBinding
# -----------------------------------------------------------------------------
resource "REDACTED_2b73dc4c" "velero" {
  metadata {
    name   = "velero"
    labels = var.common_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = REDACTED_4ad9fc99.velero.metadata[0].name
    namespace = kubernetes_namespace.velero.metadata[0].name
  }
}

# -----------------------------------------------------------------------------
# Velero BackupStorageLocation
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "velero_backup_location" {
  manifest = {
    apiVersion = "velero.io/v1"
    kind       = "BackupStorageLocation"
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.velero.metadata[0].name
      labels    = var.common_labels
    }
    spec = {
      provider = "aws"
      default  = true
      objectStorage = {
        bucket = "velero"
      }
      config = {
        region           = "minio"
        s3ForcePathStyle = "true"
        s3Url            = "http://minio-api.minio.svc.cluster.local:9000"
      }
    }
  }

  depends_on = [kubernetes_manifest.velero_crds]
}

# -----------------------------------------------------------------------------
# Velero VolumeSnapshotLocation
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "velero_snapshot_location" {
  manifest = {
    apiVersion = "velero.io/v1"
    kind       = "VolumeSnapshotLocation"
    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.velero.metadata[0].name
      labels    = var.common_labels
    }
    spec = {
      provider = "aws"
      config = {
        region = "minio"
      }
    }
  }

  depends_on = [kubernetes_manifest.velero_crds]
}

# -----------------------------------------------------------------------------
# Velero Deployment
# -----------------------------------------------------------------------------
resource "kubernetes_deployment" "velero" {
  metadata {
    name      = "velero"
    namespace = kubernetes_namespace.velero.metadata[0].name
    labels = merge(var.common_labels, {
      "app.kubernetes.io/name" = "velero"
    })
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "velero"
      }
    }

    template {
      metadata {
        labels = merge(var.common_labels, {
          "app.kubernetes.io/name" = "velero"
        })
      }

      spec {
        service_account_name = REDACTED_4ad9fc99.velero.metadata[0].name

        init_container {
          name  = "velero-plugin-for-aws"
          image = "velero/velero-plugin-for-aws:v1.10.0"

          volume_mount {
            name       = "plugins"
            mount_path = "/target"
          }
        }

        container {
          name  = "velero"
          image = "velero/velero:v1.14.1"

          command = ["/velero"]
          args = [
            "server",
            "--uploader-type=kopia"
          ]

          port {
            name           = "metrics"
            container_port = 8085
          }

          env {
            name  = "VELERO_SCRATCH_DIR"
            value = "/scratch"
          }

          env {
            name  = "VELERO_NAMESPACE"
            value = kubernetes_namespace.velero.metadata[0].name
          }

          env {
            name  = "LD_LIBRARY_PATH"
            value = "/plugins"
          }

          env {
            name  = "AWS_SHARED_CREDENTIALS_FILE"
            value = "/credentials/cloud"
          }

          volume_mount {
            name       = "plugins"
            mount_path = "/plugins"
          }

          volume_mount {
            name       = "scratch"
            mount_path = "/scratch"
          }

          volume_mount {
            name       = "cloud-credentials"
            mount_path = "/credentials"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }

        volume {
          name = "plugins"
          empty_dir {}
        }

        volume {
          name = "scratch"
          empty_dir {}
        }

        volume {
          name = "cloud-credentials"
          secret {
            secret_name = kubernetes_secret.velero_s3_credentials.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    REDACTED_4ad9fc99.velero,
    REDACTED_2b73dc4c.velero,
    kubernetes_manifest.velero_backup_location,
    kubernetes_manifest.velero_snapshot_location,
  ]
}

# -----------------------------------------------------------------------------
# Velero Node Agent DaemonSet (for PV backups)
# -----------------------------------------------------------------------------
resource "kubernetes_daemonset" "velero_node_agent" {
  metadata {
    name      = "velero-node-agent"
    namespace = kubernetes_namespace.velero.metadata[0].name
    labels = merge(var.common_labels, {
      "app.kubernetes.io/name" = "velero-node-agent"
    })
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "velero-node-agent"
      }
    }

    template {
      metadata {
        labels = merge(var.common_labels, {
          "app.kubernetes.io/name" = "velero-node-agent"
        })
      }

      spec {
        service_account_name = REDACTED_4ad9fc99.velero.metadata[0].name

        container {
          name  = "node-agent"
          image = "velero/velero:v1.14.1"

          command = ["/velero"]
          args = [
            "node-agent",
            "server"
          ]

          env {
            name  = "VELERO_NAMESPACE"
            value = kubernetes_namespace.velero.metadata[0].name
          }

          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name  = "VELERO_SCRATCH_DIR"
            value = "/scratch"
          }

          env {
            name  = "AWS_SHARED_CREDENTIALS_FILE"
            value = "/credentials/cloud"
          }

          volume_mount {
            name              = "host-pods"
            mount_path        = "/host_pods"
            mount_propagation = "HostToContainer"
          }

          volume_mount {
            name       = "scratch"
            mount_path = "/scratch"
          }

          volume_mount {
            name       = "cloud-credentials"
            mount_path = "/credentials"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          security_context {
            privileged  = true
            run_as_user = 0
          }
        }

        volume {
          name = "host-pods"
          host_path {
            path = "/var/lib/kubelet/pods"
          }
        }

        volume {
          name = "scratch"
          empty_dir {}
        }

        volume {
          name = "cloud-credentials"
          secret {
            secret_name = kubernetes_secret.velero_s3_credentials.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.velero]
}

# -----------------------------------------------------------------------------
# Velero Backup Schedules
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "velero_schedule_daily" {
  manifest = {
    apiVersion = "velero.io/v1"
    kind       = "Schedule"
    metadata = {
      name      = "daily-backup"
      namespace = kubernetes_namespace.velero.metadata[0].name
      labels    = var.common_labels
    }
    spec = {
      schedule = "0 2 * * *" # 2 AM daily
      template = {
        ttl                      = "720h" # 30 days
        includedNamespaces       = ["*"]
        excludedNamespaces       = ["kube-system", "velero", "minio"]
        includeClusterResources  = true
        storageLocation          = "default"
        volumeSnapshotLocations  = ["default"]
        defaultVolumesToFsBackup = true
      }
    }
  }

  depends_on = [kubernetes_deployment.velero]
}

resource "kubernetes_manifest" "velero_schedule_weekly" {
  manifest = {
    apiVersion = "velero.io/v1"
    kind       = "Schedule"
    metadata = {
      name      = "weekly-backup"
      namespace = kubernetes_namespace.velero.metadata[0].name
      labels    = var.common_labels
    }
    spec = {
      schedule = "0 3 * * 0" # 3 AM Sunday
      template = {
        ttl                      = "2160h" # 90 days
        includedNamespaces       = ["*"]
        excludedNamespaces       = ["kube-system", "velero", "minio"]
        includeClusterResources  = true
        storageLocation          = "default"
        volumeSnapshotLocations  = ["default"]
        defaultVolumesToFsBackup = true
      }
    }
  }

  depends_on = [kubernetes_deployment.velero]
}

# -----------------------------------------------------------------------------
# Velero UI - Third-party Web Interface
# -----------------------------------------------------------------------------
resource "kubernetes_deployment" "velero_ui" {
  metadata {
    name      = "velero-ui"
    namespace = kubernetes_namespace.velero.metadata[0].name
    labels = merge(var.common_labels, {
      "app.kubernetes.io/name" = "velero-ui"
    })
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "velero-ui"
      }
    }

    template {
      metadata {
        labels = merge(var.common_labels, {
          "app.kubernetes.io/name" = "velero-ui"
        })
      }

      spec {
        service_account_name = REDACTED_4ad9fc99.velero.metadata[0].name

        container {
          name  = "velero-ui"
          image = "docker.io/otwld/velero-ui:latest"

          port {
            name           = "http"
            container_port = 3000
            protocol       = "TCP"
          }

          env {
            name  = "VELERO_NAMESPACE"
            value = kubernetes_namespace.velero.metadata[0].name
          }

          env {
            name  = "NEXT_PUBLIC_VELERO_API_URL"
            value = ""
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.velero]
}

# -----------------------------------------------------------------------------
# Velero UI Service - NodePort for NPM access
# -----------------------------------------------------------------------------
resource "kubernetes_service" "velero_ui" {
  metadata {
    name      = "velero-ui"
    namespace = kubernetes_namespace.velero.metadata[0].name
    labels    = var.common_labels
  }

  spec {
    type = "NodePort"

    selector = {
      "app.kubernetes.io/name" = "velero-ui"
    }

    port {
      name        = "http"
      port        = 3000
      target_port = 3000
      node_port   = 30012
      protocol    = "TCP"
    }
  }
}

# -----------------------------------------------------------------------------
# Velero UI Ingress (optional - for NPM)
# -----------------------------------------------------------------------------
resource "kubernetes_ingress_v1" "velero_ui" {
  metadata {
    name      = "velero-ui"
    namespace = kubernetes_namespace.velero.metadata[0].name
    labels    = var.common_labels
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "velero.${var.domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.velero_ui.metadata[0].name
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}
