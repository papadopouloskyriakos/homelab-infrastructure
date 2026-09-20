# =============================================================================
# SeaweedFS Cross-Site Replication via Cilium Cluster Mesh
# =============================================================================
# This file creates:
# 1. Site-specific filer service (seaweedfs-filer-{site_code}) with Cilium global annotation
# 2. Stub service for remote site's filer (endpoints via Cluster Mesh)
# 3. filer.sync deployment for active-active cross-site replication
# =============================================================================

# -----------------------------------------------------------------------------
# Site-Specific Filer Service for Cluster Mesh (LOCAL)
# -----------------------------------------------------------------------------
# This service is marked as global, making it discoverable from the remote cluster
# via Cilium Cluster Mesh. Each site has its own named service.

resource "kubernetes_service_v1" "seaweedfs_filer_site" {
  metadata {
    name      = "seaweedfs-filer-${var.site_code}"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name

    labels = merge(var.common_labels, {
      "app.kubernetes.io/name"      = "seaweedfs"
      "app.kubernetes.io/component" = "filer"
      "app.kubernetes.io/instance"  = "seaweedfs-${var.site_code}"
    })

    annotations = {
      "service.cilium.io/global" = "true"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name"      = "seaweedfs"
      "app.kubernetes.io/component" = "filer"
    }

    port {
      name        = "filer"
      port        = 8888
      target_port = 8888
      protocol    = "TCP"
    }

    port {
      name        = "filer-grpc"
      port        = 18888
      target_port = 18888
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [helm_release.seaweedfs]
}

# -----------------------------------------------------------------------------
# Stub Service for Remote Site's Filer (REMOTE via Cluster Mesh)
# -----------------------------------------------------------------------------
# This service has NO selector - endpoints are synced from the remote cluster
# via Cilium Cluster Mesh's global service mechanism.
# The remote cluster has a matching service with the same name that HAS a selector.

resource "kubernetes_service_v1" "seaweedfs_filer_remote" {
  metadata {
    name      = "seaweedfs-filer-${var.remote_site_code}"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name

    labels = merge(var.common_labels, {
      "app.kubernetes.io/name"      = "seaweedfs"
      "app.kubernetes.io/component" = "filer"
      "app.kubernetes.io/instance"  = "seaweedfs-${var.remote_site_code}"
      "cilium.io/cluster-mesh"      = "remote-stub"
    })

    annotations = {
      # Global service - Cilium merges endpoints from remote cluster
      "service.cilium.io/global" = "true"
      # Description for clarity
      "description" = "Stub service for ${var.remote_site_code} filer - endpoints via Cluster Mesh"
    }
  }

  spec {
    # NO selector - this is a stub service
    # Endpoints come from the remote cluster via Cilium Cluster Mesh

    port {
      name        = "filer"
      port        = 8888
      target_port = 8888
      protocol    = "TCP"
    }

    port {
      name        = "filer-grpc"
      port        = 18888
      target_port = 18888
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [REDACTED_46569c16.seaweedfs]
}

# -----------------------------------------------------------------------------
# filer.sync Deployment for Cross-Site Replication
# -----------------------------------------------------------------------------
# Active-active bidirectional sync between NL and GR sites
# Uses filerProxy mode since volume servers aren't directly reachable cross-site

resource "REDACTED_08d34ae1" "filer_sync" {
  count = var.REDACTED_4bbaa453 ? 1 : 0

  metadata {
    name      = "seaweedfs-filer-sync"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name

    labels = merge(var.common_labels, {
      "app.kubernetes.io/name"      = "seaweedfs"
      "app.kubernetes.io/component" = "filer-sync"
      "app.kubernetes.io/instance"  = "seaweedfs-${var.site_code}"
    })
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name"      = "seaweedfs"
        "app.kubernetes.io/component" = "filer-sync"
      }
    }

    template {
      metadata {
        labels = merge(var.common_labels, {
          "app.kubernetes.io/name"      = "seaweedfs"
          "app.kubernetes.io/component" = "filer-sync"
          "app.kubernetes.io/instance"  = "seaweedfs-${var.site_code}"
        })

        annotations = {
          "prometheus.io/scrape" = "false"
        }
      }

      spec {
        # Run on local nodes only
        node_selector = {
          "topology.kubernetes.io/region" = var.node_region
        }

        restart_policy = "Always"

        container {
          name  = "filer-sync"
          image = "chrislusf/seaweedfs:${var.REDACTED_a4f42897}"

          # Active-Active bidirectional sync
          # -a: local site filer
          # -b: remote site filer (via Cluster Mesh)
          # filerProxy: route data transfers through filers (required for cross-site)
          # -{a,b}.fromTsMs: applied only when override > persisted offset (stale-checkpoint recovery floor)
          args = concat(
            [
              "filer.sync",
              "-a", "seaweedfs-filer-${var.site_code}.seaweedfs.svc.cluster.local:8888",
              "-b", "seaweedfs-filer-${var.remote_site_code}.seaweedfs.svc.cluster.local:8888",
              "-a.filerProxy",
              "-b.filerProxy",
              "-a.path", "/buckets",
              "-b.path", "/buckets",
              "-a.excludePaths", "/buckets/thanos-nl,/buckets/thanos-gr,/buckets/loki,/buckets/loki-gr,/buckets/read-canary",
              "-b.excludePaths", "/buckets/thanos-nl,/buckets/thanos-gr,/buckets/loki,/buckets/loki-gr,/buckets/read-canary",
              "-concurrency", "4",
              "-a.debug",
              "-b.debug",
            ],
            var.REDACTED_d063ac2f > 0 ? ["-a.fromTsMs", tostring(var.REDACTED_d063ac2f)] : [],
            var.REDACTED_88d37e0b > 0 ? ["-b.fromTsMs", tostring(var.REDACTED_88d37e0b)] : [],
            # Telemetry for the replication that carries this site's Velero backups
            # to the twin. Bind 0.0.0.0 so the Service can reach it; the pod is not
            # host-networked and the port is not published. IFRNLLEI01PRD-2879.
            var.REDACTED_5adcfee4 > 0 ? ["-metricsIp", "0.0.0.0", "-metricsPort", tostring(var.REDACTED_5adcfee4)] : [],
          )

          dynamic "port" {
            for_each = var.REDACTED_5adcfee4 > 0 ? [1] : []
            content {
              name           = "metrics"
              container_port = var.REDACTED_5adcfee4
              protocol       = "TCP"
            }
          }

          resources {
            requests = {
              cpu    = var.REDACTED_11f97ee2
              memory = var.REDACTED_8e93a7d2
            }
            limits = {
              cpu    = var.REDACTED_7c4dc246
              memory = var.REDACTED_5bbf190b
            }
          }

          # Health check. NOTE this proves only that the PROCESS exists, never that
          # replication is advancing -- filer.sync can sit in a tight retry loop
          # ("failed to get next log entry ... volume N not found") and still pass.
          # The metrics port above is the signal that actually answers that question.
          liveness_probe {
            exec {
              command = ["pgrep", "-f", "filer.sync"]
            }
            initial_delay_seconds = 30
            period_seconds        = 60
            timeout_seconds       = 5
            failure_threshold     = 3
          }
        }

        termination_grace_period_seconds = 30
      }
    }
  }

  depends_on = [
    helm_release.seaweedfs,
    kubernetes_service_v1.seaweedfs_filer_site,
    kubernetes_service_v1.seaweedfs_filer_remote
  ]
}

# -----------------------------------------------------------------------------
# filer.sync telemetry (IFRNLLEI01PRD-2879)
# -----------------------------------------------------------------------------
# Until 2026-09-20 the cross-site replication that carries this site's Velero
# backups to the twin exported nothing at all, so "is the offsite copy still
# being written?" had no answer short of listing the remote bucket by hand.
# GR was reclassified NON-PRODUCTION the same day, which makes this the one
# control that has to keep working: the backup replica now lives on hardware
# explicitly labelled best-effort.
#
# The scrape is deliberately LOCAL. filer.sync runs at THIS site, so this
# site's Prometheus answers the question without depending on the twin to
# report its own health -- the twin is exactly what we stopped trusting.

resource "kubernetes_service_v1" "filer_sync_metrics" {
  count = var.REDACTED_4bbaa453 && var.REDACTED_5adcfee4 > 0 ? 1 : 0

  metadata {
    name      = "REDACTED_6caea058"
    namespace = REDACTED_46569c16.seaweedfs.metadata[0].name

    labels = merge(var.common_labels, {
      "app.kubernetes.io/name"      = "seaweedfs"
      "app.kubernetes.io/component" = "filer-sync"
      "app.kubernetes.io/instance"  = "seaweedfs-${var.site_code}"
    })
  }

  spec {
    selector = {
      "app.kubernetes.io/name"      = "seaweedfs"
      "app.kubernetes.io/component" = "filer-sync"
    }

    port {
      name        = "metrics"
      port        = var.REDACTED_5adcfee4
      target_port = "metrics"
      protocol    = "TCP"
    }

    # Headless: nothing load-balances a single replica, and this keeps the
    # scrape target pinned to the pod rather than a virtual IP.
    cluster_ip = "None"
    type       = "ClusterIP"
  }

  depends_on = [REDACTED_08d34ae1.filer_sync]
}

resource "kubernetes_manifest" "REDACTED_40168fa8" {
  count = var.REDACTED_4bbaa453 && var.REDACTED_5adcfee4 > 0 ? 1 : 0

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "seaweedfs-filer-sync"
      namespace = REDACTED_46569c16.seaweedfs.metadata[0].name
      labels = merge(var.common_labels, {
        "app.kubernetes.io/name"      = "seaweedfs"
        "app.kubernetes.io/component" = "filer-sync"
        release                       = "monitoring"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/name"      = "seaweedfs"
          "app.kubernetes.io/component" = "filer-sync"
        }
      }
      namespaceSelector = {
        matchNames = [REDACTED_46569c16.seaweedfs.metadata[0].name]
      }
      endpoints = [{
        port          = "metrics"
        path          = "/metrics"
        interval      = "30s"
        scrapeTimeout = "10s"
      }]
    }
  }

  depends_on = [kubernetes_service_v1.filer_sync_metrics]
}
