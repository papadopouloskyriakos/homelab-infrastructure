***REMOVED***
# Pod Disruption Budgets - Core Services
***REMOVED***

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
resource "REDACTED_e0540b90" "metrics_server" {
  metadata {
    name      = "metrics-server-pdb"
    namespace = "kube-system"
    labels    = var.common_labels
  }

  spec {
    min_available = "1"
    selector {
      match_labels = {
        "k8s-app" = "metrics-server"
      }
    }
  }
}
