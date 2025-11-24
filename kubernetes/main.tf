terraform {
  required_providers {
    kubernetes = {
      source  = "REDACTED_1158da07"
      version = "~> 2.0"
    }
  }
  
  backend "http" {
    # GitLab configures this automatically
  }
}

# Variables from GitLab CI/CD
variable "k8s_host" {
  description = "Kubernetes API server"
  type        = string
}

variable "k8s_token" {
  description = "Service account token"
  type        = string
  sensitive   = true
}

variable "k8s_ca_cert" {
  description = "Cluster CA certificate (base64)"
  type        = string
  sensitive   = true
}

variable "pihole_password" {
  description = "Pi-hole admin password"
  type        = string
  sensitive   = true
  default     = "changeme123"  # Change this!
}

provider "kubernetes" {
  host                   = var.k8s_host
  token                  = var.k8s_token
  cluster_ca_certificate = base64decode(var.k8s_ca_cert)
}

# Production namespace
resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
    labels = {
      environment = "production"
      managed-by  = "gitlab-ci"
    }
  }
}

# Pi-hole namespace (separate for DNS services)
resource "kubernetes_namespace" "pihole" {
  metadata {
    name = "pihole"
    labels = {
      environment = "production"
      managed-by  = "gitlab-ci"
      app         = "pihole"
    }
  }
}

# ConfigMap for Pi-hole custom DNS
resource "kubernetes_config_map" "pihole_custom_dns" {
  metadata {
    name      = "pihole-custom-dns"
    namespace = kubernetes_namespace.pihole.metadata[0].name
  }

  data = {
    "02-custom.conf" = <<-EOF
      # Custom DNS entries
      # Example: address=/myservice.local/10.0.X.X
    EOF
  }
}

# PersistentVolumeClaim for Pi-hole data
resource "REDACTED_912a6d18_claim" "pihole_data" {
  metadata {
    name      = "pihole-data"
    namespace = kubernetes_namespace.pihole.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

# Pi-hole Deployment
resource "kubernetes_deployment" "pihole" {
  metadata {
    name      = "pihole"
    namespace = kubernetes_namespace.pihole.metadata[0].name
    labels = {
      app = "pihole"
    }
  }

  spec {
    replicas = 1  # Pi-hole should run single instance

    selector {
      match_labels = {
        app = "pihole"
      }
    }

    template {
      metadata {
        labels = {
          app = "pihole"
        }
      }

      spec {
        container {
          name  = "pihole"
          image = "pihole/pihole:latest"

          env {
            name  = "TZ"
            value = "Europe/Amsterdam"
          }

          env {
            name  = "WEBPASSWORD"
            value = var.pihole_password
          }

          env {
            name  = "DNSMASQ_LISTENING"
            value = "all"
          }

          env {
            name  = "PIHOLE_DNS_"
            value = "8.8.8.8;8.8.4.4"
          }

          port {
            name           = "dns-tcp"
            container_port = 53
            protocol       = "TCP"
          }

          port {
            name           = "dns-udp"
            container_port = 53
            protocol       = "UDP"
          }

          port {
            name           = "web"
            container_port = 80
            protocol       = "TCP"
          }

          port {
            name           = "dhcp"
            container_port = 67
            protocol       = "UDP"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/admin/"
              port = 80
            }
            initial_delay_seconds = 60
            period_seconds        = 30
          }

          readiness_probe {
            http_get {
              path = "/admin/"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          volume_mount {
            name       = "pihole-data"
            mount_path = "/etc/pihole"
            sub_path   = "pihole"
          }

          volume_mount {
            name       = "pihole-data"
            mount_path = "/etc/dnsmasq.d"
            sub_path   = "dnsmasq.d"
          }

          volume_mount {
            name       = "custom-dns"
            mount_path = "/etc/dnsmasq.d/02-custom.conf"
            sub_path   = "02-custom.conf"
          }

          security_context {
            capabilities {
              add = ["NET_ADMIN"]
            }
          }
        }

        volume {
          name = "pihole-data"
          persistent_volume_claim {
            claim_name = REDACTED_912a6d18_claim.pihole_data.metadata[0].name
          }
        }

        volume {
          name = "custom-dns"
          config_map {
            name = kubernetes_config_map.pihole_custom_dns.metadata[0].name
          }
        }
      }
    }
  }
}

# Service for Pi-hole web interface
resource "kubernetes_service" "pihole_web" {
  metadata {
    name      = "pihole-web"
    namespace = kubernetes_namespace.pihole.metadata[0].name
  }

  spec {
    selector = {
      app = "pihole"
    }

    port {
      name        = "web"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# Service for Pi-hole DNS (TCP)
resource "kubernetes_service" "pihole_dns_tcp" {
  metadata {
    name      = "pihole-dns-tcp"
    namespace = kubernetes_namespace.pihole.metadata[0].name
  }

  spec {
    selector = {
      app = "pihole"
    }

    port {
      name        = "dns-tcp"
      port        = 53
      target_port = 53
      protocol    = "TCP"
    }

    type = "LoadBalancer"  # Change to NodePort if LoadBalancer not available
  }
}

# Service for Pi-hole DNS (UDP)
resource "kubernetes_service" "pihole_dns_udp" {
  metadata {
    name      = "pihole-dns-udp"
    namespace = kubernetes_namespace.pihole.metadata[0].name
  }

  spec {
    selector = {
      app = "pihole"
    }

    port {
      name        = "dns-udp"
      port        = 53
      target_port = 53
      protocol    = "UDP"
    }

    type = "LoadBalancer"  # Change to NodePort if LoadBalancer not available
  }
}

# Ingress for Pi-hole web interface (optional)
resource "kubernetes_ingress_v1" "pihole_ingress" {
  metadata {
    name      = "pihole-ingress"
    namespace = kubernetes_namespace.pihole.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"  # Change based on your ingress controller
    }
  }

  spec {
    rule {
      host = "pihole.example.net"  # Change to your domain

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.pihole_web.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# Outputs
output "namespaces" {
  description = "Created namespaces"
  value = {
    production = kubernetes_namespace.production.metadata[0].name
    pihole     = kubernetes_namespace.pihole.metadata[0].name
  }
}

output "pihole_info" {
  description = "Pi-hole connection information"
  value = {
    web_service_name = kubernetes_service.pihole_web.metadata[0].name
    dns_tcp_service  = kubernetes_service.pihole_dns_tcp.metadata[0].name
    dns_udp_service  = kubernetes_service.pihole_dns_udp.metadata[0].name
    namespace        = kubernetes_namespace.pihole.metadata[0].name
    admin_url        = "http://pihole.example.net/admin"
  }
}
