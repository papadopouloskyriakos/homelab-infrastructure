terraform {
  required_providers {
    kubernetes = {
      source  = "REDACTED_1158da07"
      version = "~> 2.0"
    }
  }
  
  backend "http" {}
}

provider "kubernetes" {
  host                   = var.k8s_host
  token                  = var.k8s_token
  cluster_ca_certificate = base64decode(var.k8s_ca_cert)
}

resource "kubernetes_namespace" "production" {
  metadata {
    name = "production"
    labels = {
      environment = "production"
      managed-by  = "gitlab-ci"
    }
  }
}

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

resource "kubernetes_deployment" "pihole" {
  metadata {
    name      = "pihole"
    namespace = kubernetes_namespace.pihole.metadata[0].name
    labels = {
      app = "pihole"
    }
  }

  spec {
    replicas = 1

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

    type = "LoadBalancer"
  }
}

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

    type = "LoadBalancer"
  }
}

resource "kubernetes_ingress_v1" "pihole_ingress" {
  metadata {
    name      = "pihole-ingress"
    namespace = kubernetes_namespace.pihole.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = "pihole.example.net"

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
