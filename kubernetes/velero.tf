# Deploy Velero backup system

***REMOVED***
# Velero - Kubernetes Backup & Disaster Recovery
***REMOVED***
# Backs up K8s resources and persistent volumes
# Uses MinIO as S3-compatible storage backend
***REMOVED***

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------
resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
    labels = merge(local.common_labels, {
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
    labels    = local.common_labels
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
# Velero Helm Release
# -----------------------------------------------------------------------------
resource "helm_release" "velero" {
  name       = "velero"
  namespace  = kubernetes_namespace.velero.metadata[0].name
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  version    = var.velero_chart_version

  values = [
    yamlencode({
      # Disable CRD upgrade pre-install job (CRDs installed by Helm)
      upgradeCRDs = {
        enabled = false
      }

      # Velero configuration
      configuration = {
        backupStorageLocation = [{
          name     = "default"
          provider = "aws"
          bucket   = "velero"
          default  = true
          config = {
            region           = "minio"
            s3ForcePathStyle = true
            s3Url            = "http://minio-api.minio.svc.cluster.local:9000"
          }
        }]

        volumeSnapshotLocation = [{
          name     = "default"
          provider = "aws"
          config = {
            region = "minio"
          }
        }]

        # Use Restic/Kopia for PV backups (file-level backup)
        uploaderType = "kopia"
      }

      # Credentials
      credentials = {
        useSecret      = true
        existingSecret = kubernetes_secret.velero_s3_credentials.metadata[0].name
      }

      # Init containers to install plugins
      initContainers = [
        {
          name  = "velero-plugin-for-aws"
          image = "velero/velero-plugin-for-aws:v1.10.0"
          volumeMounts = [{
            name      = "plugins"
            mountPath = "/target"
          }]
        }
      ]

      # Enable node agent for PV backups
      deployNodeAgent = true

      nodeAgent = {
        podVolumePath = "/var/lib/kubelet/pods"
        resources = {
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

      # Velero server resources
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }

      # Scheduled backups
      schedules = {
        daily-backup = {
          disabled = false
          schedule = "0 2 * * *" # 2 AM daily
          template = {
            ttl                      = "720h" # 30 days retention
            includedNamespaces       = ["*"]
            excludedNamespaces       = ["kube-system", "velero", "minio"]
            includeClusterResources  = true
            storageLocation          = "default"
            volumeSnapshotLocations  = ["default"]
            defaultVolumesToFsBackup = true
          }
          useOwnerReferencesInBackup = false
        }

        weekly-backup = {
          disabled = false
          schedule = "0 3 * * 0" # 3 AM every Sunday
          template = {
            ttl                      = "2160h" # 90 days retention
            includedNamespaces       = ["*"]
            excludedNamespaces       = ["kube-system", "velero", "minio"]
            includeClusterResources  = true
            storageLocation          = "default"
            volumeSnapshotLocations  = ["default"]
            defaultVolumesToFsBackup = true
          }
          useOwnerReferencesInBackup = false
        }
      }
    })
  ]

  depends_on = [
    kubernetes_secret.velero_s3_credentials,
    kubernetes_job.minio_create_bucket
  ]
}

# -----------------------------------------------------------------------------
# Velero UI - Third-party Web Interface
# -----------------------------------------------------------------------------
resource "kubernetes_deployment" "velero_ui" {
  metadata {
    name      = "velero-ui"
    namespace = kubernetes_namespace.velero.metadata[0].name
    labels = merge(local.common_labels, {
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
        labels = merge(local.common_labels, {
          "app.kubernetes.io/name" = "velero-ui"
        })
      }

      spec {
        service_account_name = "velero"

        container {
          name  = "velero-ui"
          image = "ghcr.io/otwld/velero-ui:${var.velero_ui_version}"

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

  depends_on = [helm_release.velero]
}

# -----------------------------------------------------------------------------
# Velero UI Service - NodePort for NPM access
# -----------------------------------------------------------------------------
resource "kubernetes_service" "velero_ui" {
  metadata {
    name      = "velero-ui"
    namespace = kubernetes_namespace.velero.metadata[0].name
    labels    = local.common_labels
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
    labels    = local.common_labels
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
