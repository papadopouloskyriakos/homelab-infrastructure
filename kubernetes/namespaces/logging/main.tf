***REMOVED***
# Logging Stack - Loki + Promtail
***REMOVED***

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------
resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
    labels = merge(var.common_labels, {
      "app.kubernetes.io/name" = "logging"
    })
  }
}

# -----------------------------------------------------------------------------
# External Secret - Loki MinIO Credentials
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "loki_minio_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "loki-minio-credentials"
      namespace = kubernetes_namespace.logging.metadata[0].name
      labels    = var.common_labels
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "loki-minio-credentials"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "AWS_ACCESS_KEY_ID"
          remoteRef = {
            key      = "ci/loki"
            property = "minio_access_key"
          }
        },
        {
          secretKey = "AWS_SECRET_ACCESS_KEY"
          remoteRef = {
            key      = "ci/loki"
            property = "minio_secret_key"
          }
        }
      ]
    }
  }

  depends_on = [kubernetes_namespace.logging]
}

# -----------------------------------------------------------------------------
# Loki - Log Aggregation
# -----------------------------------------------------------------------------
resource "helm_release" "loki" {
  name       = "loki"
  namespace  = kubernetes_namespace.logging.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = "6.21.0"

  timeout = 600

  values = [yamlencode({
    deploymentMode = "SingleBinary"

    loki = {
      auth_enabled = false

      commonConfig = {
        replication_factor = 1
      }

      storage = {
        type = "s3"
        bucketNames = {
          chunks = var.minio_bucket
          ruler  = var.minio_bucket
          admin  = var.minio_bucket
        }
        s3 = {
          endpoint         = var.minio_endpoint
          region           = "us-east-1"
          accessKeyId      = "$${AWS_ACCESS_KEY_ID}"
          secretAccessKey  = "$${AWS_SECRET_ACCESS_KEY}"
          s3ForcePathStyle = true
          insecure         = true
        }
      }

      schemaConfig = {
        configs = [
          {
            from         = "2024-01-01"
            store        = "tsdb"
            object_store = "s3"
            schema       = "v13"
            index = {
              prefix = "index_"
              period = "24h"
            }
          }
        ]
      }

      limits_config = {
        retention_period        = "${var.loki_retention_days * 24}h"
        max_query_series        = 10000
        ingestion_rate_mb       = 10
        ingestion_burst_size_mb = 20
      }

      compactor = {
        retention_enabled    = true
        delete_request_store = "s3"
      }
    }

    singleBinary = {
      extraArgs = ["-config.expand-env=true"]

      replicas = 1

      extraEnvFrom = [
        {
          secretRef = {
            name = "loki-minio-credentials"
          }
        }
      ]

      persistence = {
        enabled      = true
        size         = var.loki_storage_size
        storageClass = "REDACTED_4f3da73d"
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "1"
          memory = "1Gi"
        }
      }

      affinity = {
        nodeAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = {
            nodeSelectorTerms = [
              {
                matchExpressions = [
                  {
                    key      = "node-role.kubernetes.io/control-plane"
                    operator = "DoesNotExist"
                  }
                ]
              }
            ]
          }
        }
      }
    }

    backend = {
      replicas = 0
    }
    read = {
      replicas = 0
    }
    write = {
      replicas = 0
    }

    gateway = {
      enabled = false
    }

    chunksCache = {
      enabled = false
    }
    resultsCache = {
      enabled = false
    }

    monitoring = {
      selfMonitoring = {
        enabled = false
        grafanaAgent = {
          installOperator = false
        }
      }
      lokiCanary = {
        enabled = false
      }
    }

    test = {
      enabled = false
    }
  })]

  depends_on = [kubernetes_manifest.loki_minio_external_secret]
}

# -----------------------------------------------------------------------------
# Promtail - Log Collector
# -----------------------------------------------------------------------------
resource "helm_release" "promtail" {
  name       = "promtail"
  namespace  = kubernetes_namespace.logging.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = "6.16.6"

  values = [yamlencode({
    config = {
      clients = [
        {
          url = "http://loki.logging.svc.cluster.local:3100/loki/api/v1/push"
        }
      ]

      snippets = {
        extraScrapeConfigs = <<-SCRAPE
          # Syslog receiver for external sources (syslog-ng)
          - job_name: syslog
            syslog:
              listen_address: 0.0.0.0:${var.promtail_syslog_port}
              listen_protocol: tcp
              idle_timeout: 60s
              label_structured_data: yes
              labels:
                job: "syslog"
            relabel_configs:
              - source_labels: ['__syslog_message_hostname']
                target_label: 'host'
              - source_labels: ['__syslog_message_app_name']
                target_label: 'app'
              - source_labels: ['__syslog_message_severity']
                target_label: 'severity'
              - source_labels: ['REDACTED_5ab426f2']
                target_label: 'facility'
        SCRAPE
      }
    }

    extraPorts = {
      syslog = {
        name          = "syslog"
        containerPort = var.promtail_syslog_port
        protocol      = "TCP"
      }
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

    tolerations = [
      {
        key      = "node-role.kubernetes.io/control-plane"
        operator = "Exists"
        effect   = "NoSchedule"
      }
    ]

    serviceMonitor = {
      enabled = true
    }
  })]

  depends_on = [helm_release.loki]
}

# -----------------------------------------------------------------------------
# LoadBalancer Service for Syslog Receiver
# -----------------------------------------------------------------------------
resource "kubernetes_service" "promtail_syslog" {
  metadata {
    name      = "promtail-syslog"
    namespace = kubernetes_namespace.logging.metadata[0].name
    labels = merge(var.common_labels, {
      "app.kubernetes.io/name" = "promtail-syslog"
    })
  }

  spec {
    type = "LoadBalancer"

    selector = {
      "app.kubernetes.io/name"     = "promtail"
      "app.kubernetes.io/instance" = "promtail"
    }

    port {
      name        = "syslog"
      port        = 514
      target_port = var.promtail_syslog_port
      protocol    = "TCP"
    }
  }

  depends_on = [helm_release.promtail]
}
