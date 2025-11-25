***REMOVED***
# MinIO - S3-Compatible Object Storage for Velero Backups
***REMOVED***
# Provides S3-compatible storage for Velero backups
# Web Console: http://<node-ip>:30010
# API Endpoint: http://<node-ip>:30011
***REMOVED***

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------
resource "kubernetes_namespace" "minio" {
  metadata {
    name = "minio"
    labels = merge(local.common_labels, {
      "app.kubernetes.io/name" = "minio"
    })
  }
}

# -----------------------------------------------------------------------------
# MinIO Credentials Secret
# -----------------------------------------------------------------------------
resource "kubernetes_secret" "minio_credentials" {
  metadata {
    name      = "minio-credentials"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels    = local.common_labels
  }

  data = {
    root-user     = var.minio_root_user
    root-password = var.minio_root_password
  }

  type = "Opaque"
}

# -----------------------------------------------------------------------------
# MinIO PVC - Uses existing NFS StorageClass
# -----------------------------------------------------------------------------
resource "REDACTED_912a6d18_claim" "minio_data" {
  metadata {
    name      = "minio-data"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs-client"

    resources {
      requests = {
        storage = var.minio_storage_size
      }
    }
  }
}

# -----------------------------------------------------------------------------
# MinIO Deployment
# -----------------------------------------------------------------------------
resource "kubernetes_deployment" "minio" {
  metadata {
    name      = "minio"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels = merge(local.common_labels, {
      "app.kubernetes.io/name" = "minio"
    })
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "minio"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = merge(local.common_labels, {
          "app.kubernetes.io/name" = "minio"
        })
      }

      spec {
        container {
          name  = "minio"
          image = "minio/minio:${var.minio_version}"

          args = ["server", "/data", "--console-address", ":9001"]

          port {
            name           = "api"
            container_port = 9000
            protocol       = "TCP"
          }

          port {
            name           = "console"
            container_port = 9001
            protocol       = "TCP"
          }

          env {
            name = "MINIO_ROOT_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio_credentials.metadata[0].name
                key  = "root-user"
              }
            }
          }

          env {
            name = "MINIO_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio_credentials.metadata[0].name
                key  = "root-password"
              }
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/minio/health/live"
              port = 9000
            }
            initial_delay_seconds = 30
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/minio/health/ready"
              port = 9000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = REDACTED_912a6d18_claim.minio_data.metadata[0].name
          }
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# MinIO Services - NodePort for NPM access
# -----------------------------------------------------------------------------
resource "kubernetes_service" "minio_api" {
  metadata {
    name      = "minio-api"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    type = "NodePort"

    selector = {
      "app.kubernetes.io/name" = "minio"
    }

    port {
      name        = "api"
      port        = 9000
      target_port = 9000
      node_port   = 30011
      protocol    = "TCP"
    }
  }
}

resource "kubernetes_service" "minio_console" {
  metadata {
    name      = "minio-console"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    type = "NodePort"

    selector = {
      "app.kubernetes.io/name" = "minio"
    }

    port {
      name        = "console"
      port        = 9001
      target_port = 9001
      node_port   = 30010
      protocol    = "TCP"
    }
  }
}

# -----------------------------------------------------------------------------
# MinIO Ingress (optional - for NPM)
# -----------------------------------------------------------------------------
resource "kubernetes_ingress_v1" "minio_console" {
  metadata {
    name      = "minio-console"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels    = local.common_labels
    annotations = {
      "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "minio.${var.domain}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.minio_console.metadata[0].name
              port {
                number = 9001
              }
            }
          }
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Create Velero Bucket (using Kubernetes Job)
# -----------------------------------------------------------------------------
resource "kubernetes_job" "minio_create_bucket" {
  metadata {
    name      = "minio-create-velero-bucket"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    ttl_seconds_after_finished = 300

    template {
      metadata {
        labels = local.common_labels
      }

      spec {
        restart_policy = "OnFailure"

        container {
          name  = "mc"
          image = "minio/mc:latest"

          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
            sleep 10
            mc alias set myminio http://minio-api:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD
            mc mb myminio/velero --ignore-existing
            mc anonymous set download myminio/velero
            echo "Bucket 'velero' created successfully"
            EOT
          ]

          env {
            name = "MINIO_ROOT_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio_credentials.metadata[0].name
                key  = "root-user"
              }
            }
          }

          env {
            name = "MINIO_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.minio_credentials.metadata[0].name
                key  = "root-password"
              }
            }
          }
        }
      }
    }
  }

  wait_for_completion = false

  depends_on = [
    kubernetes_deployment.minio,
    kubernetes_service.minio_api
  ]
}
