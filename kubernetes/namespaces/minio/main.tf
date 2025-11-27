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
    labels = merge(var.common_labels, {
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
    labels    = var.common_labels
  }

  data = {
    root-user     = var.minio_root_user
    root-password = var.minio_root_password
  }

  type = "Opaque"
}

# -----------------------------------------------------------------------------
# Snapshot Service Account Credentials Secret
# -----------------------------------------------------------------------------
resource "kubernetes_secret" "snapshot_credentials" {
  metadata {
    name      = "minio-snapshot-credentials"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels    = var.common_labels
  }

  data = {
    access-key = var.minio_snapshot_access_key
    secret-key = var.minio_snapshot_secret_key
  }

  type = "Opaque"
}

# -----------------------------------------------------------------------------
# MinIO PVC - Synology CSI iSCSI Storage
# -----------------------------------------------------------------------------
resource "REDACTED_912a6d18_claim" "minio_data" {
  metadata {
    name      = "minio-data-csi"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels    = var.common_labels
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "REDACTED_b280aec5"

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
    labels = merge(var.common_labels, {
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
        labels = merge(var.common_labels, {
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
    labels    = var.common_labels
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
    labels    = var.common_labels
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
    labels    = var.common_labels
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
# MinIO Init Job - Creates Buckets and Service Account
# -----------------------------------------------------------------------------
resource "kubernetes_job" "minio_init" {
  metadata {
    name      = "minio-init-buckets"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels    = var.common_labels
  }

  spec {
    ttl_seconds_after_finished = 300

    template {
      metadata {
        labels = var.common_labels
      }

      spec {
        restart_policy = "OnFailure"

        container {
          name  = "mc"
          image = "minio/mc:latest"

          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
            set -e
            echo "Waiting for MinIO to be ready..."
            sleep 15
            
            # Configure MinIO client
            mc alias set myminio http://minio-api:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD
            
            # Create buckets
            echo "Creating buckets..."
            mc mb myminio/velero --ignore-existing
            mc mb myminio/cluster-snapshots --ignore-existing
            
            # Create snapshot-admin user
            echo "Creating snapshot-admin user..."
            mc admin user add myminio $SNAPSHOT_ACCESS_KEY $SNAPSHOT_SECRET_KEY 2>/dev/null || echo "User may already exist"
            
            # Create policy for cluster-snapshots bucket (read/write)
            echo "Creating snapshot policy..."
            cat > /tmp/snapshot-policy.json << 'POLICY'
            {
              "Version": "2012-10-17",
              "Statement": [
                {
                  "Effect": "Allow",
                  "Action": [
                    "s3:GetBucketLocation",
                    "s3:ListBucket",
                    "s3:ListBucketMultipartUploads"
                  ],
                  "Resource": ["arn:aws:s3:::cluster-snapshots"]
                },
                {
                  "Effect": "Allow",
                  "Action": [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:DeleteObject",
                    "s3:ListMultipartUploadParts",
                    "s3:AbortMultipartUpload"
                  ],
                  "Resource": ["arn:aws:s3:::cluster-snapshots/*"]
                }
              ]
            }
            POLICY
            
            mc admin policy create myminio snapshot-readwrite /tmp/snapshot-policy.json 2>/dev/null || echo "Policy may already exist"
            mc admin policy attach myminio snapshot-readwrite --user $SNAPSHOT_ACCESS_KEY 2>/dev/null || echo "Policy may already be attached"
            
            echo "=== MinIO initialization complete ==="
            echo "Buckets:"
            mc ls myminio/
            echo ""
            echo "Users:"
            mc admin user list myminio
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

          env {
            name = "SNAPSHOT_ACCESS_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.snapshot_credentials.metadata[0].name
                key  = "access-key"
              }
            }
          }

          env {
            name = "SNAPSHOT_SECRET_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.snapshot_credentials.metadata[0].name
                key  = "secret-key"
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

# -----------------------------------------------------------------------------
# MinIO Pod Disruption Budget
# -----------------------------------------------------------------------------
resource "REDACTED_e0540b90" "minio" {
  metadata {
    name      = "minio-pdb"
    namespace = kubernetes_namespace.minio.metadata[0].name
    labels    = var.common_labels
  }

  spec {
    min_available = "1"
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "minio"
      }
    }
  }
}
