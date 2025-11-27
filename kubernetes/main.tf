# ========================================================================
# Main Orchestrator - Calls Core and Namespace Modules
# ========================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "REDACTED_1158da07"
      version = "~> 2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }
  }

  backend "http" {}
}

# -------------------------------------------------------------------------
# Common Labels
# -------------------------------------------------------------------------
locals {
  common_labels = {
    environment = "production"
    managed-by  = "opentofu"
    repository  = "REDACTED_25022d4e"
  }
}

# ========================================================================
# CORE INFRASTRUCTURE MODULES
# ========================================================================

module "nfs_provisioner" {
  source = "./_core/nfs-provisioner"

  nfs_server = var.nfs_server
  nfs_path   = var.nfs_path
}

module "metallb" {
  source = "./_core/metallb"
}

module "ingress_nginx" {
  source = "./_core/ingress-nginx"

  depends_on = [module.metallb]
}

module "gitlab_agent" {
  source = "./_core/gitlab-agent"

  REDACTED_b6136a28 = REDACTED_305df36d
}

# ========================================================================
# APPLICATION NAMESPACE MODULES
# ========================================================================


module "minio" {
  source = "./namespaces/minio"

  common_labels = local.common_labels

  minio_root_user     = var.minio_root_user
  minio_root_password = var.minio_root_password
  minio_storage_size  = var.minio_storage_size
  minio_version       = var.minio_version
  domain                    = var.domain
  minio_snapshot_access_key = var.minio_snapshot_access_key
  minio_snapshot_secret_key = var.minio_snapshot_secret_key
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

# NOTE: Velero has been migrated to Argo CD management (apps/velero/)

module "argocd" {
  source = "./namespaces/argocd"

  common_labels = local.common_labels
  domain        = var.domain

  REDACTED_be8b31fd         = var.REDACTED_be8b31fd
  argocd_nodeport              = var.argocd_nodeport
  REDACTED_84146aee       = var.REDACTED_84146aee
  REDACTED_649263f1         = var.REDACTED_649263f1
  REDACTED_035cbec1 = var.REDACTED_035cbec1
  argocd_dex_enabled           = var.argocd_dex_enabled
  argocd_repositories          = var.argocd_repositories
  argocd_ssh_known_hosts       = var.argocd_ssh_known_hosts

  depends_on = [module.ingress_nginx]
}

module "awx" {
  source = "./namespaces/awx"

  common_labels = local.common_labels
  domain        = var.domain

  nfs_server                = var.nfs_server
  nfs_path                  = var.nfs_path
  REDACTED_3e5e811f = var.REDACTED_3e5e811f
  REDACTED_12032801 = var.REDACTED_12032801
}
