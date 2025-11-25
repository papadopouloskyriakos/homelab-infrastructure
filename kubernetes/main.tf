***REMOVED***
# Main Orchestrator - Calls Core and Namespace Modules
***REMOVED***

terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "REDACTED_1158da07"
      version = "~> 2.35.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16.1"
    }
  }

  backend "http" {}
}

# -----------------------------------------------------------------------------
# Common Labels
# -----------------------------------------------------------------------------
locals {
  common_labels = {
    environment = "production"
    managed-by  = "opentofu"
    repository  = "REDACTED_25022d4e"
  }
}

***REMOVED***
# CORE INFRASTRUCTURE MODULES
***REMOVED***

module "nfs_provisioner" {
  source = "./_core/nfs-provisioner"

  nfs_server = var.nfs_server
  nfs_path   = var.nfs_path
}

module "ingress_nginx" {
  source = "./_core/ingress-nginx"
}

module "gitlab_agent" {
  source = "./_core/gitlab-agent"

  REDACTED_b6136a28 = REDACTED_305df36d
}

***REMOVED***
# APPLICATION NAMESPACE MODULES
***REMOVED***

module "awx" {
  source = "./namespaces/awx"

  common_labels = local.common_labels

  nfs_server                = var.nfs_server
  nfs_path                  = var.nfs_path
  REDACTED_3e5e811f = var.REDACTED_3e5e811f
  REDACTED_12032801 = var.REDACTED_12032801
}

module "minio" {
  source = "./namespaces/minio"

  common_labels = local.common_labels

  minio_root_user     = var.minio_root_user
  minio_root_password = var.minio_root_password
  minio_storage_size  = var.minio_storage_size
  minio_version       = var.minio_version
  domain              = var.domain
}

module "monitoring" {
  source = "./namespaces/monitoring"

  common_labels = local.common_labels

  prometheus_retention    = var.prometheus_retention
  REDACTED_6a2724e6 = var.REDACTED_6a2724e6
  grafana_admin_password  = var.grafana_admin_password
  grafana_storage_size    = var.grafana_storage_size

  depends_on = [module.nfs_provisioner]
}

module "pihole" {
  source = "./namespaces/pihole"

  common_labels = local.common_labels

  pihole_password = var.pihole_password
}

module "velero" {
  source = "./namespaces/velero"

  common_labels = local.common_labels

  # Pass MinIO credentials for S3 backend
  minio_root_user     = var.minio_root_user
  minio_root_password = var.minio_root_password
  domain              = var.domain

  depends_on = [module.minio]
}
