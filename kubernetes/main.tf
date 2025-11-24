terraform {
  required_providers {
    kubernetes = {
      source  = "REDACTED_1158da07"
      version = "~> 2.0"
    }
  }
}

# Variables from GitLab
variable "k8s_host" {}
variable "k8s_token" { sensitive = true }
variable "k8s_ca_cert" { sensitive = true }

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

# Your production apps here
resource "kubernetes_deployment" "myapp" {
  metadata {
    name      = "myapp"
    namespace = kubernetes_namespace.production.metadata[0].name
  }
  
  spec {
    replicas = 3  # HA for production
    
    selector {
      match_labels = { app = "myapp" }
    }
    
    template {
      metadata {
        labels = { app = "myapp" }
      }
      
      spec {
        container {
          name  = "myapp"
          image = "myapp:v1.0.0"
          
          resources {
            requests = {
              cpu    = "500m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "1Gi"
            }
          }
          
          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
          }
          
          readiness_probe {
            http_get {
              path = "/ready"
              port = 8080
            }
          }
        }
      }
    }
  }
}