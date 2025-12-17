***REMOVED***
# Thanos - Long-term Metrics Storage & Global Query
***REMOVED***
# Deploys Thanos components for:
# - Long-term metric storage in SeaweedFS S3
# - Cross-site metric federation via Thanos Query
# - Data compaction and downsampling
#
# Architecture:
#   Prometheus (existing) + Thanos Sidecar → SeaweedFS (thanos-{site})
#   Thanos Query → queries local + remote Store Gateways
#   Thanos Store Gateway → serves historical data from S3
#   Thanos Compactor → compacts and downsamples blocks
***REMOVED***

# -----------------------------------------------------------------------------
# ExternalSecret - Thanos S3 Credentials from OpenBao
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_fb3d2492" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "REDACTED_5f4971dc"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/name"      = "thanos"
        "app.kubernetes.io/component" = "objstore"
        environment                   = "production"
        "managed-by"                  = "opentofu"
      }
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "REDACTED_5f4971dc"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
        template = {
          engineVersion = "v2"
          data = {
            "objstore.yml" = <<-EOT
type: S3
config:
  bucket: ${var.thanos_bucket_name}
  endpoint: ${var.thanos_s3_endpoint}
  access_key: "{{ .access_key }}"
  secret_key: "{{ .secret_key }}"
  insecure: true
  signature_version2: false
  http_config:
    idle_conn_timeout: 1m30s
    response_header_timeout: 2m
    insecure_skip_verify: true
EOT
          }
        }
      }
      data = [
        {
          secretKey = "access_key"
          remoteRef = {
            key      = var.thanos_openbao_secret_path
            property = "access_key"
          }
        },
        {
          secretKey = "secret_key"
          remoteRef = {
            key      = var.thanos_openbao_secret_path
            property = "secret_key"
          }
        }
      ]
    }
  }

  depends_on = [helm_release.monitoring]
}

# -----------------------------------------------------------------------------
# Thanos Query - Global Query Layer (HA)
# -----------------------------------------------------------------------------
# Queries both local Prometheus/Sidecar and Store Gateways for unified view
resource "REDACTED_08d34ae1" "thanos_query" {
  metadata {
    name      = "thanos-query"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "query"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
  }

  spec {
    replicas = var.REDACTED_7a9cbd6c

    selector {
      match_labels = {
        "app.kubernetes.io/name"      = "thanos"
        "app.kubernetes.io/component" = "query"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"      = "thanos"
          "app.kubernetes.io/component" = "query"
          environment                   = "production"
          "managed-by"                  = "opentofu"
        }
      }

      spec {
        service_account_name = "thanos-query"

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }
              }
            }
          }
          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100
              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app.kubernetes.io/component"
                    operator = "In"
                    values   = ["query"]
                  }
                }
                topology_key = "kubernetes.io/hostname"
              }
            }
          }
        }

        container {
          name  = "thanos-query"
          image = "quay.io/thanos/thanos:${var.thanos_version}"

          args = [
            "query",
            "--log.level=info",
            "--log.format=logfmt",
            "--http-address=0.0.0.0:9090",
            "--grpc-address=0.0.0.0:10901",
            "--query.replica-label=prometheus_replica",
            "--query.replica-label=rule_replica",
            # Local Prometheus sidecars (discovered via headless service)
            "--endpoint=dnssrv+_grpc._tcp.REDACTED_e135e9ed.monitoring.svc.cluster.local",
            # Local Store Gateway
            "--endpoint=dnssrv+_grpc._tcp.thanos-store.monitoring.svc.cluster.local",
            # Remote site Store Gateway (via Cluster Mesh)
            "--endpoint=${var.thanos_remote_store_endpoint}",
            "--query.auto-downsampling",
          ]

          port {
            name           = "http"
            container_port = 9090
            protocol       = "TCP"
          }

          port {
            name           = "grpc"
            container_port = 10901
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu    = var.REDACTED_30f368b4
              memory = var.REDACTED_0cfb68ff
            }
            limits = {
              cpu    = var.REDACTED_e802136b
              memory = var.REDACTED_bd9f12e7
            }
          }

          liveness_probe {
            http_get {
              path = "/-/healthy"
              port = 9090
            }
            initial_delay_seconds = 30
            period_seconds        = 30
            timeout_seconds       = 10
            failure_threshold     = 4
          }

          readiness_probe {
            http_get {
              path = "/-/ready"
              port = 9090
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 10
            failure_threshold     = 20
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 65534
          }
        }
      }
    }
  }

  depends_on = [helm_release.monitoring]
}

# -----------------------------------------------------------------------------
# Thanos Query Service
# -----------------------------------------------------------------------------
resource "kubernetes_service_v1" "thanos_query" {
  metadata {
    name      = "thanos-query"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "query"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "query"
    }

    port {
      name        = "http"
      port        = 9090
      target_port = 9090
      protocol    = "TCP"
    }

    port {
      name        = "grpc"
      port        = 10901
      target_port = 10901
      protocol    = "TCP"
    }
  }
}

# -----------------------------------------------------------------------------
# Thanos Query ServiceAccount
# -----------------------------------------------------------------------------
resource "REDACTED_4ad9fc99_v1" "thanos_query" {
  metadata {
    name      = "thanos-query"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "query"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
  }
}

# -----------------------------------------------------------------------------
# Thanos Store Gateway - Serves Historical Data from S3 (HA)
# -----------------------------------------------------------------------------
resource "REDACTED_2f6bdfa2" "thanos_store" {
  metadata {
    name      = "thanos-store"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "store"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
  }

  spec {
    replicas     = var.REDACTED_63d297ac
    service_name = "thanos-store"

    selector {
      match_labels = {
        "app.kubernetes.io/name"      = "thanos"
        "app.kubernetes.io/component" = "store"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"      = "thanos"
          "app.kubernetes.io/component" = "store"
          environment                   = "production"
          "managed-by"                  = "opentofu"
        }
      }

      spec {
        service_account_name = "thanos-store"
        security_context {
          fs_group = 65534
        }

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }
              }
            }
          }
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_expressions {
                  key      = "app.kubernetes.io/component"
                  operator = "In"
                  values   = ["store"]
                }
              }
              topology_key = "kubernetes.io/hostname"
            }
          }
        }

        container {
          name  = "thanos-store"
          image = "quay.io/thanos/thanos:${var.thanos_version}"

          args = [
            "store",
            "--log.level=info",
            "--log.format=logfmt",
            "--http-address=0.0.0.0:10902",
            "--grpc-address=0.0.0.0:10901",
            "REDACTED_10d484ca",
            "--objstore.config-file=/etc/thanos/objstore.yml",
          ]

          port {
            name           = "http"
            container_port = 10902
            protocol       = "TCP"
          }

          port {
            name           = "grpc"
            container_port = 10901
            protocol       = "TCP"
          }

          volume_mount {
            name       = "objstore-config"
            mount_path = "/etc/thanos"
            read_only  = true
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/thanos/store"
          }

          resources {
            requests = {
              cpu    = var.REDACTED_04db0b8f
              memory = var.REDACTED_4e106564
            }
            limits = {
              cpu    = var.REDACTED_cd0ed526
              memory = var.REDACTED_b0098842
            }
          }

          liveness_probe {
            http_get {
              path = "/-/healthy"
              port = 10902
            }
            initial_delay_seconds = 30
            period_seconds        = 30
            timeout_seconds       = 10
            failure_threshold     = 8
          }

          readiness_probe {
            http_get {
              path = "/-/ready"
              port = 10902
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 10
            failure_threshold     = 20
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 65534
          }
        }

        volume {
          name = "objstore-config"
          secret {
            secret_name = "REDACTED_5f4971dc"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "data"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = var.thanos_storage_class
        resources {
          requests = {
            storage = var.thanos_store_storage_size
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.REDACTED_fb3d2492]
}

# -----------------------------------------------------------------------------
# Thanos Store Headless Service (for DNS discovery)
# -----------------------------------------------------------------------------
resource "kubernetes_service_v1" "thanos_store" {
  metadata {
    name      = "thanos-store"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "store"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
  }

  spec {
    type       = "ClusterIP"
    cluster_ip = "None" # Headless

    selector = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "store"
    }

    port {
      name        = "grpc"
      port        = 10901
      target_port = 10901
      protocol    = "TCP"
    }

    port {
      name        = "http"
      port        = 10902
      target_port = 10902
      protocol    = "TCP"
    }
  }
}

# -----------------------------------------------------------------------------
# Thanos Store ServiceAccount
# -----------------------------------------------------------------------------
resource "REDACTED_4ad9fc99_v1" "thanos_store" {
  metadata {
    name      = "thanos-store"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "store"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
  }
}

# -----------------------------------------------------------------------------
# Thanos Compactor - Compacts and Downsamples Blocks (Single Replica)
# -----------------------------------------------------------------------------
resource "REDACTED_2f6bdfa2" "thanos_compactor" {
  metadata {
    name      = "thanos-compactor"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "compactor"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
  }

  spec {
    replicas     = 1 # Must be 1 - no HA for compactor
    service_name = "thanos-compactor"

    selector {
      match_labels = {
        "app.kubernetes.io/name"      = "thanos"
        "app.kubernetes.io/component" = "compactor"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name"      = "thanos"
          "app.kubernetes.io/component" = "compactor"
          environment                   = "production"
          "managed-by"                  = "opentofu"
        }
      }

      spec {
        service_account_name = "thanos-compactor"
        security_context {
          fs_group = 65534
        }

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }
              }
            }
          }
        }

        container {
          name  = "thanos-compactor"
          image = "quay.io/thanos/thanos:${var.thanos_version}"

          args = [
            "compact",
            "--log.level=info",
            "--log.format=logfmt",
            "--http-address=0.0.0.0:10902",
            "REDACTED_1400316d",
            "--objstore.config-file=/etc/thanos/objstore.yml",
            "--retention.resolution-raw=${var.thanos_retention_raw}",
            "--retention.resolution-5m=${var.thanos_retention_5m}",
            "--retention.resolution-1h=${var.thanos_retention_1h}",
            "--compact.concurrency=1",
            "--downsample.concurrency=1",
            "--delete-delay=48h",
            "--wait",
          ]

          port {
            name           = "http"
            container_port = 10902
            protocol       = "TCP"
          }

          volume_mount {
            name       = "objstore-config"
            mount_path = "/etc/thanos"
            read_only  = true
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/thanos/compact"
          }

          resources {
            requests = {
              cpu    = var.REDACTED_ec35f0bf
              memory = var.REDACTED_2e15f782
            }
            limits = {
              cpu    = var.REDACTED_4851f004
              memory = var.REDACTED_7479c0fd
            }
          }

          liveness_probe {
            http_get {
              path = "/-/healthy"
              port = 10902
            }
            initial_delay_seconds = 30
            period_seconds        = 30
            timeout_seconds       = 10
            failure_threshold     = 4
          }

          readiness_probe {
            http_get {
              path = "/-/ready"
              port = 10902
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 10
            failure_threshold     = 20
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 65534
          }
        }

        volume {
          name = "objstore-config"
          secret {
            secret_name = "REDACTED_5f4971dc"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "data"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = var.thanos_storage_class
        resources {
          requests = {
            storage = var.REDACTED_fd3fdc21
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.REDACTED_fb3d2492]
}

# -----------------------------------------------------------------------------
# Thanos Compactor Service
# -----------------------------------------------------------------------------
resource "kubernetes_service_v1" "thanos_compactor" {
  metadata {
    name      = "thanos-compactor"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "compactor"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "compactor"
    }

    port {
      name        = "http"
      port        = 10902
      target_port = 10902
      protocol    = "TCP"
    }
  }
}

# -----------------------------------------------------------------------------
# Thanos Compactor ServiceAccount
# -----------------------------------------------------------------------------
resource "REDACTED_4ad9fc99_v1" "thanos_compactor" {
  metadata {
    name      = "thanos-compactor"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "compactor"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
  }
}

# -----------------------------------------------------------------------------
# Thanos Sidecar Service (for Query discovery)
# -----------------------------------------------------------------------------
# This headless service allows Thanos Query to discover Prometheus sidecars
resource "kubernetes_service_v1" "thanos_sidecar" {
  metadata {
    name      = "REDACTED_e135e9ed"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "sidecar"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
  }

  spec {
    type       = "ClusterIP"
    cluster_ip = "None" # Headless

    selector = {
      "app.kubernetes.io/name"      = "prometheus"
      "operator.prometheus.io/name" = "REDACTED_6dfbe9fc"
    }

    port {
      name        = "grpc"
      port        = 10901
      target_port = 10901
      protocol    = "TCP"
    }

    port {
      name        = "http"
      port        = 10902
      target_port = 10902
      protocol    = "TCP"
    }
  }

  depends_on = [helm_release.monitoring]
}

# -----------------------------------------------------------------------------
# ServiceMonitor - Thanos Components Metrics
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_99efe840" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "thanos"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/name" = "thanos"
        environment              = "production"
        "managed-by"             = "opentofu"
        release                  = "monitoring"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "thanos"
        }
      }
      namespaceSelector = {
        matchNames = ["monitoring"]
      }
      endpoints = [
        {
          port     = "http"
          path     = "/metrics"
          interval = "30s"
        }
      ]
    }
  }

  depends_on = [helm_release.monitoring]
}

# -----------------------------------------------------------------------------
# Ingress - Thanos Query UI
# -----------------------------------------------------------------------------
resource "kubernetes_ingress_v1" "thanos_query" {
  count = var.REDACTED_844fade0 ? 1 : 0

  metadata {
    name      = "thanos-query"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "query"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.REDACTED_928c2d3a

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.thanos_query.metadata[0].name
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
# Global Service for Cross-Site Query (Cilium Cluster Mesh)
# -----------------------------------------------------------------------------
resource "kubernetes_service_v1" "thanos_store_global" {
  metadata {
    name      = "thanos-store-${var.site_code}"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "store"
      "app.kubernetes.io/instance"  = "thanos-${var.site_code}"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
    annotations = {
      "service.cilium.io/global" = "true"
      "service.cilium.io/shared" = "true"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "store"
    }

    port {
      name        = "grpc"
      port        = 10901
      target_port = 10901
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [REDACTED_2f6bdfa2.thanos_store]
}

# -----------------------------------------------------------------------------
# Stub Service for Remote Site's Store Gateway (via Cluster Mesh)
# -----------------------------------------------------------------------------
resource "kubernetes_service_v1" "thanos_store_remote" {
  metadata {
    name      = "thanos-store-${var.remote_site_code}"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name"      = "thanos"
      "app.kubernetes.io/component" = "store"
      "app.kubernetes.io/instance"  = "thanos-${var.remote_site_code}"
      "cilium.io/cluster-mesh"      = "remote-stub"
      environment                   = "production"
      "managed-by"                  = "opentofu"
    }
    annotations = {
      "service.cilium.io/global" = "true"
      "service.cilium.io/shared" = "true"
      "description"              = "Stub service for ${var.remote_site_code} Thanos Store - endpoints via Cluster Mesh"
    }
  }

  spec {
    # NO selector - endpoints come from remote cluster via Cluster Mesh

    port {
      name        = "grpc"
      port        = 10901
      target_port = "10901"
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
