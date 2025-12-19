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
resource "kubernetes_manifest" "REDACTED_4d3fed8e" {
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "loki-s3-credentials"
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
        name           = "loki-s3-credentials"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "AWS_ACCESS_KEY_ID"
          remoteRef = {
            key      = "ci/loki"
            property = "s3_access_key"
          }
        },
        {
          secretKey = "AWS_SECRET_ACCESS_KEY"
          remoteRef = {
            key      = "ci/loki"
            property = "s3_secret_key"
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
  version    = "6.46.0"

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
          chunks = var.s3_bucket
          ruler  = var.s3_bucket
          admin  = var.s3_bucket
        }
        s3 = {
          endpoint         = var.s3_endpoint
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
            name = "loki-s3-credentials"
          }
        }
      ]

      persistence = {
        enabled      = true
        size         = var.loki_storage_size
        storageClass = "REDACTED_4f3da73d"
      }

      # Prevent PVC deletion when scaling down - only delete when StatefulSet is deleted
      REDACTED_33feff97RetentionPolicy = {
        whenDeleted = "Delete"
        whenScaled  = "Retain"
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

  depends_on = [kubernetes_manifest.REDACTED_4d3fed8e]
}

# -----------------------------------------------------------------------------
# Promtail - Log Collector
# -----------------------------------------------------------------------------
resource "helm_release" "promtail" {
  name       = "promtail"
  namespace  = kubernetes_namespace.logging.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  version    = "6.17.1"

  values = [yamlencode({
    config = {
      clients = [
        {
          url = "http://loki.logging.svc.cluster.local:3100/loki/api/v1/push"
        }
      ]

      snippets = {
        extraScrapeConfigs = <<-SCRAPE
          # =================================================================
          # Syslog receiver for external sources (syslog-ng)
          # =================================================================
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

          # =================================================================
          # Tetragon Security Events
          # =================================================================
          # Scrapes JSON logs from Tetragon runtime security tool
          # Events include: process exec, file access, privilege escalation
          # =================================================================
          - job_name: tetragon
            static_configs:
              - targets:
                  - localhost
                labels:
                  job: tetragon
                  __path__: REDACTED_fa94d8bd/*.log
            pipeline_stages:
              # Parse JSON logs from Tetragon
              - json:
                  expressions:
                    time: time
                    process_exec: process_exec
                    process_exit: process_exit
                    process_kprobe: process_kprobe
              # Determine event type for filtering
              - template:
                  source: event_type
                  template: '{{ if .process_exec }}process_exec{{ else if .process_exit }}process_exit{{ else if .process_kprobe }}process_kprobe{{ else }}unknown{{ end }}'
              - labels:
                  event_type:
              # Extract namespace for filtering
              - template:
                  source: namespace
                  template: '{{ if .process_exec }}{{ .process_exec.process.pod.namespace }}{{ else if .process_kprobe }}{{ .process_kprobe.process.pod.namespace }}{{ end }}'
              - labels:
                  namespace:
              # Extract pod name
              - template:
                  source: pod
                  template: '{{ if .process_exec }}{{ .process_exec.process.pod.name }}{{ else if .process_kprobe }}{{ .process_kprobe.process.pod.name }}{{ end }}'
              - labels:
                  pod:
              # Extract binary name for security analysis
              - template:
                  source: binary
                  template: '{{ if .process_exec }}{{ .process_exec.process.binary }}{{ else if .process_kprobe }}{{ .process_kprobe.process.binary }}{{ end }}'
              - labels:
                  binary:
        SCRAPE
      }
    }

    # Syslog port with LoadBalancer service (chart-managed)
    extraPorts = {
      syslog = {
        containerPort = var.promtail_syslog_port
        protocol      = "TCP"
        service = {
          type           = "LoadBalancer"
          loadBalancerIP = "10.0.X.X"
          port           = 514
        }
      }
    }

    # =========================================================================
    # Extra Volumes - Mount Tetragon export directory
    # =========================================================================
    extraVolumes = [
      {
        name = "tetragon-export"
        hostPath = {
          path = "REDACTED_fa94d8bd"
          type = "DirectoryOrCreate"
        }
      }
    ]

    extraVolumeMounts = [
      {
        name      = "tetragon-export"
        mountPath = "REDACTED_fa94d8bd"
        readOnly  = true
      }
    ]

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
      },
      # Edge nodes toleration (for full Tetragon coverage)
      {
        key      = "node-type"
        operator = "Equal"
        value    = "edge"
        effect   = "NoSchedule"
      }
    ]

    serviceMonitor = {
      enabled = true
    }
  })]

  depends_on = [helm_release.loki]
}
