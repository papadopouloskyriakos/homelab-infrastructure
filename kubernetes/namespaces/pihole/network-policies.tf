# ========================================================================
# Pi-hole Network Policies
# ========================================================================
# Cilium Network Policy for Pi-hole DNS server
# ========================================================================

resource "kubernetes_manifest" "pihole_network_policy" {
  manifest = {
    apiVersion = "cilium.io/v2"
    kind       = "CiliumNetworkPolicy"
    metadata = {
      name      = "pihole-policy"
      namespace = kubernetes_namespace.pihole.metadata[0].name
    }
    spec = {
      endpointSelector = {
        matchLabels = {
          app = "pihole"
        }
      }

      # Ingress rules
      ingress = [
        {
          # Allow DNS from anywhere (UDP)
          fromEntities = ["all"]
          toPorts = [
            {
              ports = [
                { port = "53", protocol = "UDP" }
              ]
            }
          ]
        },
        {
          # Allow DNS from anywhere (TCP)
          fromEntities = ["all"]
          toPorts = [
            {
              ports = [
                { port = "53", protocol = "TCP" }
              ]
            }
          ]
        },
        {
          # Allow Web UI from ingress-nginx controller
          fromEndpoints = [
            {
              matchLabels = {
                "k8s:io.kubernetes.pod.namespace" = "ingress-nginx"
                "app.kubernetes.io/name"          = "ingress-nginx"
              }
            }
          ]
          toPorts = [
            {
              ports = [
                { port = "80", protocol = "TCP" }
              ]
            }
          ]
        },
        {
          # Allow Prometheus scraping from monitoring namespace
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
                { port = "80", protocol = "TCP" }
              ]
            }
          ]
        }
      ]

      # Egress rules
      egress = [
        {
          # Allow DNS forwarding to upstream servers
          toEntities = ["world"]
          toPorts = [
            {
              ports = [
                { port = "53", protocol = "UDP" },
                { port = "53", protocol = "TCP" },
                { port = "853", protocol = "TCP" }
              ]
            }
          ]
        },
        {
          # Allow cluster DNS lookups (CoreDNS)
          toEndpoints = [
            {
              matchLabels = {
                "k8s:io.kubernetes.pod.namespace" = "kube-system"
                "k8s-app"                         = "kube-dns"
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
        {
          # Allow HTTPS for blocklist updates
          toEntities = ["world"]
          toPorts = [
            {
              ports = [
                { port = "443", protocol = "TCP" },
                { port = "80", protocol = "TCP" }
              ]
            }
          ]
        }
      ]
    }
  }
}
