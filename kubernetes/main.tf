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
      version = "~> 3.1.0"
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

# NOTE: MetalLB removed - replaced by Cilium LB-IPAM + BGP
# Cilium CNI installed via CLI: cilium install --set REDACTED_fd61d0fe=true

module "cilium_bgp" {
  source = "./_core/cilium"

  lb_pool_start = var.REDACTED_08cea5a5
  lb_pool_stop  = var.cilium_lb_pool_stop
  local_asn     = var.cilium_local_asn
  peer_asn      = var.cilium_peer_asn
  peer_address  = var.cilium_peer_address
  # Disable old ExternalSecret - using Helm-managed clustermesh.config.clusters
  REDACTED_0333f99b = false
}

module "ingress_nginx" {
  source = "./_core/ingress-nginx"

  depends_on = [module.cilium_bgp]
}

module "gitlab_agent" {
  source = "./_core/gitlab-agent"

  REDACTED_b6136a28 = REDACTED_305df36d
}

module "REDACTED_279a43a7" {
  source        = "./_core/REDACTED_b9c50d9a"
  common_labels = local.common_labels
}

module "nl-nas01_csi" {
  source = "./_core/nl-nas01-csi"

  synology_host        = var.nl-nas01_csi_host
  synology_username    = var.REDACTED_6177f7df
  synology_password    = REDACTED_97ec5898
  REDACTED_add7f998 = var.REDACTED_cd98d00a
  chart_version        = var.REDACTED_bf874266

  enable_velero_integration = false
}

module "cert_manager" {
  source = "./_core/cert-manager"
}

# ========================================================================
# APPLICATION NAMESPACE MODULES
# ========================================================================

module "monitoring" {
  source = "./namespaces/monitoring"

  common_labels = local.common_labels

  prometheus_retention    = var.prometheus_retention
  REDACTED_6a2724e6 = var.REDACTED_6a2724e6
  grafana_storage_size    = var.grafana_storage_size

  snmp_community = var.snmp_community
  depends_on     = [module.nfs_provisioner]
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


module "external_secrets" {
  source = "./_core/external-secrets"

  openbao_address = var.openbao_address
  openbao_ca_cert = var.openbao_ca_cert
}

***REMOVED***
# Logging Stack
***REMOVED***
module "logging" {
  source = "./namespaces/logging"

  common_labels        = local.common_labels
  loki_storage_size    = var.loki_storage_size
  loki_retention_days  = var.loki_retention_days
  s3_endpoint          = var.loki_s3_endpoint
  s3_bucket            = var.loki_s3_bucket
  promtail_syslog_port = var.promtail_syslog_port
}

***REMOVED***
# SeaweedFS - Distributed Object Storage (MinIO Replacement)
***REMOVED***
module "seaweedfs" {
  source = "./namespaces/seaweedfs"

  common_labels = local.common_labels

  storage_class           = "REDACTED_b280aec5"
  REDACTED_c1342204 = var.REDACTED_c1342204
  volume_storage_size     = var.REDACTED_a8217c41
  master_storage_size     = var.seaweedfs_master_storage_size
  filer_storage_size      = var.REDACTED_b907bdb5
  cluster_name            = "nlcl01k8s"
  node_region             = "nl-lei"

  # Cross-site replication settings
  site_code                     = "nl"
  remote_site_code              = "gr"
  REDACTED_4bbaa453 = true
  depends_on                    = [module.nl-nas01_csi, module.external_secrets]
}

# Kubernetes Dashboard
module "REDACTED_ac4dcdf5" {
  source = "./_core/REDACTED_d97cef76"

  dashboard_hostname = "nl-k8s.example.net"
}

***REMOVED***
# Gatus - Status Page
***REMOVED***
module "gatus" {
  source = "./namespaces/gatus"

  depends_on = [module.ingress_nginx, module.cert_manager]
}
