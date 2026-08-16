# =============================================================================
# Pod Disruption Budgets - Core Services
# =============================================================================

# CoreDNS (2 replicas)
resource "REDACTED_e0540b90" "coredns" {
  metadata {
    name      = "coredns-pdb"
    namespace = "kube-system"
    labels    = var.common_labels
  }

  spec {
    min_available = "1"
    selector {
      match_labels = {
        "k8s-app" = "kube-dns"
      }
    }
  }
}

# Metrics Server (1 replica)
# Selector is a module input because each site's out-of-band metrics-server
# deployment carries different labels (NL "k8s-app", GR "app.kubernetes.io/name").
# See var.metrics_server_selector — GR root MUST override the NL default.
resource "REDACTED_e0540b90" "metrics_server" {
  metadata {
    name      = "metrics-server-pdb"
    namespace = "kube-system"
    labels    = var.common_labels
  }

  spec {
    min_available = "1"
    selector {
      match_labels = var.metrics_server_selector
    }
  }
}
