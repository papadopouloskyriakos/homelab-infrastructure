***REMOVED***
# Cilium Network Policy - Logging Namespace
***REMOVED***

resource "kubernetes_manifest" "REDACTED_46f7c9ba" {
  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "CiliumNetworkPolicy"
    metadata = {
      name      = "logging-policy"
      namespace = kubernetes_namespace.logging.metadata[0].name
      labels    = var.common_labels
    }
    spec = {
      # Apply to all pods in logging namespace
      endpointSelector = {}

      ingress = [
        # Allow intra-namespace communication (Promtail -> Loki)
        {
          fromEndpoints = [
            {
              matchLabels = {
                "k8s:io.kubernetes.pod.namespace" = "logging"
              }
            }
          ]
        },
        # Allow Grafana to query Loki
        {
          fromEndpoints = [
            {
              matchLabels = {
                "k8s:io.kubernetes.pod.namespace" = "monitoring"
              }
            }
          ]
          toPorts = [
            {
              ports = [
                { port = "3100", protocol = "TCP" }
              ]
            }
          ]
        },
        # Allow Prometheus to scrape metrics
        {
          fromEndpoints = [
            {
              matchLabels = {
                "app.kubernetes.io/name"          = "prometheus"
                "k8s:io.kubernetes.pod.namespace" = "monitoring"
              }
            }
          ]
          toPorts = [
            {
              ports = [
                { port = "3100", protocol = "TCP" },
                { port = "3101", protocol = "TCP" }
              ]
            }
          ]
        },
        # Allow syslog from external sources (via LoadBalancer)
        {
          fromEntities = ["world"]
          toPorts = [
            {
              ports = [
                { port = tostring(var.promtail_syslog_port), protocol = "TCP" }
              ]
            }
          ]
        }
      ]

      egress = [
        # Allow DNS resolution
        {
          toEndpoints = [
            {
              matchLabels = {
                "k8s-app"                         = "kube-dns"
                "k8s:io.kubernetes.pod.namespace" = "kube-system"
              }
            }
          ]
          toPorts = [
            {
              ports = [
                { port = "53", protocol = "UDP" },
                { port = "53", protocol = "TCP" }
              ]
            }
          ]
        },
        # Allow Promtail to reach Kubernetes API (pod discovery)
        {
          toEntities = ["kube-apiserver"]
          toPorts = [
            {
              ports = [
                { port = "6443", protocol = "TCP" }
              ]
            }
          ]
        },
        # Allow Loki to reach MinIO (S3 storage)
        {
          toEndpoints = [
            {
              matchLabels = {
                "k8s:io.kubernetes.pod.namespace" = "minio"
              }
            }
          ]
          toPorts = [
            {
              ports = [
                { port = "9000", protocol = "TCP" }
              ]
            }
          ]
        },
        # Allow Loki to reach SeaweedFS S3 (new storage backend)
        {
          toEndpoints = [
            {
              matchLabels = {
                "k8s:io.kubernetes.pod.namespace" = "seaweedfs"
              }
            }
          ]
          toPorts = [
            {
              ports = [
                { port = "8333", protocol = "TCP" }
              ]
            }
          ]
        },
        # Allow intra-namespace communication
        {
          toEndpoints = [
            {
              matchLabels = {
                "k8s:io.kubernetes.pod.namespace" = "logging"
              }
            }
          ]
        }
      ]
    }
  }

  depends_on = [kubernetes_namespace.logging]
}
