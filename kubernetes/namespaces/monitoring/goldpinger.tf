***REMOVED***
# Goldpinger - Cross-node Latency Monitoring
***REMOVED***
# DaemonSet that measures pod-to-pod latency across all nodes
# Includes edge nodes (VPS) for multi-site visibility
***REMOVED***

# -----------------------------------------------------------------------------
# Service Account
# -----------------------------------------------------------------------------
resource "REDACTED_4ad9fc99_v1" "goldpinger" {
  metadata {
    name      = "goldpinger"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name" = "goldpinger"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  depends_on = [helm_release.monitoring]
}

# -----------------------------------------------------------------------------
# ClusterRole - needs to list pods for discovery
# -----------------------------------------------------------------------------
resource "REDACTED_1f297da4" "goldpinger" {
  metadata {
    name = "goldpinger"
    labels = {
      "app.kubernetes.io/name" = "goldpinger"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["list", "get"]
  }
}

# -----------------------------------------------------------------------------
# ClusterRoleBinding
# -----------------------------------------------------------------------------
resource "REDACTED_2b73dc4c_v1" "goldpinger" {
  metadata {
    name = "goldpinger"
    labels = {
      "app.kubernetes.io/name" = "goldpinger"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = REDACTED_1f297da4.goldpinger.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = REDACTED_4ad9fc99_v1.goldpinger.metadata[0].name
    namespace = "monitoring"
  }
}

# -----------------------------------------------------------------------------
# DaemonSet - runs on ALL nodes including edge and control plane
# -----------------------------------------------------------------------------
resource "REDACTED_9bcb792e" "goldpinger" {
  metadata {
    name      = "goldpinger"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name" = "goldpinger"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "goldpinger"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "goldpinger"
          environment              = "production"
          "managed-by"             = "opentofu"
        }
      }

      spec {
        service_account_name = REDACTED_4ad9fc99_v1.goldpinger.metadata[0].name

        # Run on ALL nodes - edge VPS, control plane, workers
        toleration {
          key      = "node-type"
          operator = "Equal"
          value    = "edge"
          effect   = "NoSchedule"
        }

        toleration {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        container {
          name  = "goldpinger"
          image = "bloomberg/goldpinger:v3.10.1"

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          env {
            name  = "HOST"
            value = "0.0.0.0"
          }

          env {
            name  = "PORT"
            value = "8080"
          }

          env {
            name  = "PING_TIMEOUT"
            value = "5s"
          }

          env {
            name  = "CHECK_TIMEOUT"
            value = "10s"
          }

          env {
            name  = "CHECK_ALL_TIMEOUT"
            value = "20s"
          }

          env {
            name = "HOSTNAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "32Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 1000
          }
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Service - for Prometheus scraping and UI access
# -----------------------------------------------------------------------------
resource "kubernetes_service_v1" "goldpinger" {
  metadata {
    name      = "goldpinger"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name" = "goldpinger"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      "app.kubernetes.io/name" = "goldpinger"
    }

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }
  }
}

# -----------------------------------------------------------------------------
# ServiceMonitor - Prometheus autodiscovery
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_96a5dfcb" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "goldpinger"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/name" = "goldpinger"
        environment              = "production"
        "managed-by"             = "opentofu"
        release                  = "monitoring"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "goldpinger"
        }
      }
      namespaceSelector = {
        matchNames = ["monitoring"]
      }
      endpoints = [{
        port          = "http"
        path          = "/metrics"
        interval      = "30s"
        scrapeTimeout = "10s"
      }]
    }
  }

  depends_on = [helm_release.monitoring]
}

# -----------------------------------------------------------------------------
# Ingress - Web UI access
# -----------------------------------------------------------------------------
resource "kubernetes_ingress_v1" "goldpinger" {
  metadata {
    name      = "goldpinger"
    namespace = "monitoring"
    labels = {
      "app.kubernetes.io/name" = "goldpinger"
      environment              = "production"
      "managed-by"             = "opentofu"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "goldpinger.example.net"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.goldpinger.metadata[0].name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}
