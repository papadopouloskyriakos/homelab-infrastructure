terraform {
  required_version = ">= 1.6.0"
  required_providers {
    kubernetes = {
      source  = "REDACTED_1158da07"
      version = "~> 2.35"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
  }
  
  # Backend configured via environment in CI
  # For local use, create backend.tf with: backend "local" {}
  backend "http" {}
}

provider "kubernetes" {
  host                   = var.k8s_host
  token                  = var.k8s_token
  cluster_ca_certificate = base64decode(var.k8s_ca_cert)
}

provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    token                  = var.k8s_token
    cluster_ca_certificate = base64decode(var.k8s_ca_cert)
  }
}
