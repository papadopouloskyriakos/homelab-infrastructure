***REMOVED***
# Tetragon - eBPF Runtime Security Observability
***REMOVED***
# Cilium sub-project providing kernel-level security monitoring
# Exports events to JSON files for Promtail/Loki ingestion
***REMOVED***

resource "helm_release" "tetragon" {
  name             = "tetragon"
  namespace        = "kube-system"
  repository       = "https://helm.cilium.io"
  chart            = "tetragon"
  version          = var.tetragon_version
  create_namespace = false

  timeout = 600

  values = [yamlencode({
    # =========================================================================
    # Export Directory - Top level setting for Tetragon agent
    # =========================================================================
    exportDirectory = "/var/log/tetragon"

    # =========================================================================
    # Tetragon Agent Configuration
    # =========================================================================
    tetragon = {
      # Export settings for JSON file output
      exportFilename       = "tetragon.log"
      exportFileMaxSizeMB  = 50
      exportFileMaxBackups = 2
      exportFileCompress   = false
      exportFilePerm       = "600"
      exportRateLimit      = 60000

      # Export filters - newline-separated JSON objects (NOT arrays)
      # Deny noisy events: health checks and host/cilium namespace
      exportDenyList = "{\"health_check\":true}\n{\"namespace\":[\"\",\"cilium\"]}"

      # Allow all standard event types
      exportAllowList = "{\"event_set\":[\"PROCESS_EXEC\",\"PROCESS_EXIT\",\"PROCESS_KPROBE\",\"PROCESS_UPROBE\",\"PROCESS_TRACEPOINT\",\"PROCESS_LSM\"]}"

      # Container awareness - required for proper process attribution
      # Connects to containerd CRI socket for container metadata
      cri = {
        enabled        = true
        socketHostPath = "/run/containerd/containerd.sock"
      }

      # Use cgroup IDs for pod association (requires CRI)
      cgidmap = {
        enabled = true
      }

      # Enable process ancestors tracking for exec/kprobe/tracepoint events
      processAncestors = {
        enabled = "base,kprobe,tracepoint"
      }

      # Enable BPF filesystem for persistence
      enableMsgHandlingLatency = false

      # Prometheus metrics
      prometheus = {
        enabled = true
        port    = 2112
        serviceMonitor = {
          enabled = true
          labelsOverride = {
            release = "monitoring"
          }
        }
      }
    }

    # =========================================================================
    # Export Configuration - File-based JSON for Promtail
    # =========================================================================
    export = {
      mode = "file"
      securityContext = {
        runAsUser  = 0
        runAsGroup = 0
      }

      filenames = {
        basePath       = "/var/log/tetragon"
        exportFilename = "tetragon.log"
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

    # =========================================================================
    # Tetragon Operator
    # =========================================================================
    tetragonOperator = {
      enabled = true

      # Prometheus metrics for operator
      prometheus = {
        enabled = true
        port    = 2113
        serviceMonitor = {
          enabled = true
          labelsOverride = {
            release = "monitoring"
          }
        }
      }

      resources = {
        requests = {
          cpu    = "10m"
          memory = "32Mi"
        }
        limits = {
          cpu    = "100m"
          memory = "128Mi"
        }
      }
    }

    # =========================================================================
    # DaemonSet Configuration
    # =========================================================================
    # Run on ALL nodes including control-plane and edge nodes
    tolerations = [
      {
        key      = "node-role.kubernetes.io/control-plane"
        operator = "Exists"
        effect   = "NoSchedule"
      },
      {
        key      = "node-role.kubernetes.io/master"
        operator = "Exists"
        effect   = "NoSchedule"
      },
      {
        key      = "node-type"
        operator = "Equal"
        value    = "edge"
        effect   = "NoSchedule"
      }
    ]

    # Resource limits for Tetragon agent
    resources = {
      requests = {
        cpu    = var.REDACTED_c5d74212
        memory = var.REDACTED_6e37ecf0
      }
      limits = {
        cpu    = var.tetragon_cpu_limit
        memory = var.tetragon_memory_limit
      }
    }

    # Update strategy
    updateStrategy = {
      type = "RollingUpdate"
      rollingUpdate = {
        maxUnavailable = 1
      }
    }

    # Priority class for critical infrastructure
    priorityClassName = "REDACTED_e2c3c514"
  })]
}
