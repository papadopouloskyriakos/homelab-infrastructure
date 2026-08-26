# ========================================================================
# Main Orchestrator - Calls Core and Namespace Modules
# ========================================================================
# CANONICAL FILE — byte-identical in the NL and GR repos (mirror campaign
# 2026-08-16). Every site-specific value is a var.* fed from this repo's
# terraform.tfvars (or the Atlantis TF_VAR_* environment for secrets).
# The site-specific CSI storage backend lives in site-storage.tf, which is
# the ONLY mirror-exempt root file (like namespaces/monitoring/scrape-estate.tf).
# ========================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "REDACTED_1158da07"
      version = "~> 3.2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.2.0"
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
    repository  = var.repository_label
    site        = var.site
  }
}

# ========================================================================
# CORE INFRASTRUCTURE MODULES
# ========================================================================

# Gated for third-site readiness (IFRNLLEI01PRD-2403): a site without a NAS
# passes nfs_enabled = false. moved{} keeps NL/GR state on the new [0] address.
moved {
  from = module.nfs_provisioner
  to   = module.nfs_provisioner[0]
}

module "nfs_provisioner" {
  count  = var.nfs_enabled ? 1 : 0
  source = "./_core/nfs-provisioner"

  nfs_server        = var.nfs_server
  nfs_path          = var.nfs_path
  archive_on_delete = var.archive_on_delete
}

# NOTE: MetalLB removed - replaced by Cilium LB-IPAM + BGP
# Cilium CNI installed via CLI: cilium install --set REDACTED_fd61d0fe=true

module "cilium_bgp" {
  source = "./_core/cilium"

  # Site identity
  cluster_name = var.cluster_name
  cluster_id   = var.cluster_id
  k8s_api_host = var.k8s_api_host
  pod_cidr     = var.pod_cidr

  # BGP Configuration
  lb_pool_start = var.REDACTED_08cea5a5
  lb_pool_stop  = var.cilium_lb_pool_stop
  local_asn     = var.cilium_local_asn
  peer_asn      = var.cilium_peer_asn
  peer_address  = var.cilium_peer_address

  # ClusterMesh - remote cluster connection
  clustermesh_remote_cluster_name = var.clustermesh_remote_cluster_name
  REDACTED_9b1272d3     = var.REDACTED_9b1272d3

  # Third-site gates (IFRNLLEI01PRD-2403) — NL/GR pass true/true/1350,
  # preserving the historical rendering byte-for-byte.
  clustermesh_enabled          = var.clustermesh_enabled
  cilium_bgp_enabled           = var.cilium_bgp_enabled
  cilium_lb_ipam_enabled       = var.cilium_lb_ipam_enabled
  spire_storage_class          = var.spire_storage_class
  cilium_mtu                   = var.cilium_mtu
  cilium_devices               = var.cilium_devices
  REDACTED_9c9808e4 = var.REDACTED_9c9808e4

  # Hubble UI
  hubble_hostname = var.hubble_hostname
}

module "tetragon" {
  source = "./_core/tetragon"

  # Disable policies for initial deploy - CRDs installed by Helm
  # Re-enable after Tetragon is running
  REDACTED_8a8d8279         = false
  REDACTED_ca9faf45      = true
  REDACTED_f45ec1ce = true
  REDACTED_936fa359         = true

  # ServiceMonitor for Prometheus
  REDACTED_46d876c8 = true

  # Rate limit exports (events per second)
  export_rate_limit = 1000

  depends_on = [module.cilium_bgp]
}

module "ingress_nginx" {
  source = "./_core/ingress-nginx"

  REDACTED_3b82c3d6 = var.REDACTED_af8c15ba
  csp_header              = var.ingress_csp_header

  depends_on = [module.cilium_bgp]
}

module "gitlab_agent" {
  source = "./_core/gitlab-agent"

  gitlab_agent_token = REDACTED_305df36d
  agent_name         = var.gitlab_agent_name
  kas_address        = var.gitlab_kas_address

  depends_on = [module.external_secrets]
}

module "REDACTED_279a43a7" {
  source        = "./_core/pod-disruption-budgets"
  common_labels = local.common_labels

  metrics_server_selector = var.metrics_server_selector
}

# NOTE: the per-site CSI storage backend (NL: module "nl-nas01_csi",
# GR: module "democratic_csi") is declared in site-storage.tf — the only
# mirror-exempt root file.

module "cert_manager" {
  source = "./_core/cert-manager"

  acme_issuer_enabled = var.acme_issuer_enabled
  install_crds        = var.install_crds

  depends_on = [module.external_secrets]
}

# ========================================================================
# APPLICATION NAMESPACE MODULES
# ========================================================================

module "monitoring" {
  source = "./namespaces/monitoring"

  common_labels = local.common_labels

  REDACTED_6a2724e6       = var.REDACTED_6a2724e6
  grafana_storage_size          = var.grafana_storage_size
  grafana_storage_class         = var.grafana_storage_class
  grafana_replicas              = var.grafana_replicas
  node_exporter_port            = var.node_exporter_port
  alertmanager_storage_size     = var.alertmanager_storage_size
  thanos_store_storage_size     = var.thanos_store_storage_size
  REDACTED_fd3fdc21 = var.REDACTED_fd3fdc21
  REDACTED_bf135212     = var.REDACTED_bf135212
  snmp_community                = var.snmp_community

  # --- site identity ---
  # monitoring's cluster_name is the SHORT site code (nl/gr),
  # not the full kubeadm cluster name — hence var.site_code here.
  site         = var.site
  cluster_name = var.site_code
  node_region  = var.node_region

  # --- storage (MUST match live StatefulSet templates — immutable) ---
  REDACTED_cdb3d821   = var.REDACTED_cdb3d821
  alertmanager_storage_class = var.alertmanager_storage_class
  thanos_storage_class       = var.thanos_storage_class

  # --- alerting ---
  alert_webhook_url      = var.alert_webhook_url
  paging_bridge_url      = var.paging_bridge_url
  tg_webhook_url         = var.tg_webhook_url
  wal_healer_webhook_url = var.wal_healer_webhook_url

  # --- scrape targets ---
  # estate_scrape_enabled must be true on exactly ONE Prometheus (NL) —
  # see namespaces/monitoring/scrape-estate.tf (mirror-exempt, GR stub).
  estate_scrape_enabled       = var.estate_scrape_enabled
  asa_snmp_enabled            = var.asa_snmp_enabled
  snmp_asa_target             = var.snmp_asa_target
  snmp_asa_device             = var.snmp_asa_device
  snmp_syno_target            = var.snmp_syno_target
  snmp_syno_community         = var.snmp_syno_community
  etcd_endpoints              = var.etcd_endpoints
  frr_route_reflector_targets = var.frr_route_reflector_targets
  pve_hosts                   = var.pve_hosts
  frr_edge_targets            = var.frr_edge_targets
  ipsec_edge_targets          = var.ipsec_edge_targets

  # --- thanos cross-site identity ---
  site_code                      = var.site_code
  remote_site_code               = var.remote_site_code
  thanos_bucket_name             = var.thanos_bucket_name
  REDACTED_52f9638b          = var.REDACTED_52f9638b
  thanos_remote_store_endpoint   = var.thanos_remote_store_endpoint
  REDACTED_d312035b = var.REDACTED_d312035b
  REDACTED_928c2d3a          = var.REDACTED_928c2d3a

  # --- prometheus remote-write (third-site hub/satellite; defaults render nothing) ---
  prometheus_remote_write_url              = var.prometheus_remote_write_url
  REDACTED_923cce14 = var.REDACTED_923cce14

  # --- ingress hostnames ---
  prometheus_hostname = var.prometheus_hostname
  grafana_hostname    = var.grafana_hostname
  goldpinger_hostname = var.goldpinger_hostname

  depends_on = [module.nfs_provisioner, module.external_secrets]
}

# NOTE: Velero has been migrated to Argo CD management (apps/velero/)

module "argocd" {
  source = "./namespaces/argocd"

  common_labels = local.common_labels

  site            = var.site
  argocd_hostname = var.argocd_hostname

  REDACTED_be8b31fd         = var.REDACTED_be8b31fd
  argocd_nodeport              = var.argocd_nodeport
  REDACTED_84146aee       = var.REDACTED_84146aee
  REDACTED_649263f1         = var.REDACTED_649263f1
  REDACTED_7ce225ce       = var.REDACTED_7ce225ce
  argocd_repo_server_replicas  = var.argocd_repo_server_replicas
  REDACTED_035cbec1 = var.REDACTED_035cbec1
  REDACTED_2f84acaa   = var.REDACTED_2f84acaa
  argocd_dex_enabled           = var.argocd_dex_enabled
  argocd_repositories          = var.argocd_repositories
  argocd_ssh_known_hosts       = var.argocd_ssh_known_hosts
  argocd_matrix_token          = var.argocd_matrix_token
  REDACTED_9360424f      = var.REDACTED_9360424f

  depends_on = [module.external_secrets, module.ingress_nginx]
}

# Gated for third-site readiness (IFRNLLEI01PRD-2403): a site without AWX
# passes awx_enabled = false. moved{} keeps NL/GR state on the new [0] address.
moved {
  from = module.awx
  to   = module.awx[0]
}

module "awx" {
  count  = var.awx_enabled ? 1 : 0
  source = "./namespaces/awx"

  common_labels = local.common_labels

  nfs_server                = var.nfs_server
  nfs_path                  = var.nfs_path
  REDACTED_3e5e811f = var.REDACTED_3e5e811f
  REDACTED_12032801 = var.REDACTED_12032801

  # Asymmetric by history — NL's live NFS dir is "projects", GR's is
  # "awx-projects". Renaming the live directory would orphan project data.
  REDACTED_0b348a0e = var.REDACTED_0b348a0e

  # Postgres provisioning mode: NL statically binds the imported Synology-CSI
  # PV (CSI migration 2024-11-27) via REDACTED_28b716ba; GR passes ""
  # (operator provisions dynamically on REDACTED_4c1f6c62).
  postgres_storage_class = var.REDACTED_4c1f6c62
  REDACTED_5ac2e308   = var.REDACTED_28b716ba

  awx_ingress_enabled = var.awx_ingress_enabled
  awx_hostname        = var.awx_hostname

  depends_on = [module.nfs_provisioner]
}

module "external_secrets" {
  source = "./_core/external-secrets"

  openbao_address     = var.openbao_address
  openbao_ca_cert     = var.openbao_ca_cert
  eso_auth_mount_path = var.eso_auth_mount_path
}

# CloudNativePG operator — DB tier (platform-only: operator + CRDs; Cluster CRs
# are app-tier). Gated: only sites running an in-cluster Postgres tier enable it
# (notrf01 = true for the omoikane migration; NL/GR = false). New module, so no
# moved{} block is needed — count=0 sites simply never create it.
module "cnpg_operator" {
  count  = var.cnpg_enabled ? 1 : 0
  source = "./_core/cnpg-operator"

  common_labels           = local.common_labels
  REDACTED_46d876c8 = var.REDACTED_6b820d0e
}

# =============================================================================
# Logging Stack
# =============================================================================
module "logging" {
  source = "./namespaces/logging"

  common_labels         = local.common_labels
  loki_storage_size     = var.loki_storage_size
  loki_storage_class    = var.loki_storage_class
  loki_retention_days   = var.loki_retention_days
  s3_endpoint           = var.loki_s3_endpoint
  s3_bucket             = var.loki_s3_bucket
  promtail_syslog_port  = var.promtail_syslog_port
  REDACTED_337e6630 = var.REDACTED_337e6630

  depends_on = [module.seaweedfs, module.external_secrets]
}

# =============================================================================
# SeaweedFS - Distributed Object Storage (MinIO Replacement)
# =============================================================================
module "seaweedfs" {
  source = "./namespaces/seaweedfs"

  common_labels = local.common_labels

  storage_class_retain          = var.storage_class_retain
  REDACTED_c1342204       = var.REDACTED_c1342204
  REDACTED_a4f42897       = var.REDACTED_a4f42897
  filer_store                   = var.seaweedfs_filer_store
  filer_meta_db_enabled         = var.seaweedfs_filer_meta_db_enabled
  REDACTED_5c69828e    = var.REDACTED_8bee20b3
  REDACTED_5514fdd1      = var.REDACTED_0bd01d17
  canary_s3_endpoint            = var.REDACTED_b3642cef
  volume_storage_size           = var.REDACTED_a8217c41
  REDACTED_0a7b20f8 = var.REDACTED_6930756b
  master_storage_size           = var.seaweedfs_master_storage_size
  filer_storage_size            = var.REDACTED_b907bdb5
  node_region                   = var.node_region

  master_hostname  = var.seaweedfs_master_hostname
  s3_hostname      = var.s3_hostname
  repository_label = var.repository_label

  # Cross-site replication settings. NL runs the single bidirectional
  # filer.sync deployment (REDACTED_4bbaa453 = true); GR is
  # identity-only (false).
  site_code                     = var.site_code
  remote_site_code              = var.remote_site_code
  REDACTED_4bbaa453 = var.REDACTED_4bbaa453

  # filer.sync resume-offset override (stale-checkpoint recovery floor).
  #
  # IMPORTANT: SeaweedFS v4.01 has counter-intuitive flag semantics. The
  # `-a.fromTsMs` flag controls the b->a goroutine (sync where filer A is the
  # SINK), and `-b.fromTsMs` controls a->b (sync where filer B is the SINK).
  # Verified empirically and against upstream filer_sync.go @ tag 4.01:
  # the a->b goroutine consumes syncOptions.bFromTsMs, b->a consumes aFromTsMs.
  #
  # 2026-05-05 incident: b->a (GR->NL) was stuck at 2025-12-11 19:07:15 UTC
  # because the change-log volumes from that day had been GC'd. NL's tfvars
  # override forces b->a to start at 2026-05-05 14:31:50 UTC. Once the new
  # offset is persisted (~1 min after pod start), the flag silently no-ops on
  # subsequent restarts because override < stored, acting as a permanent floor.
  # REDACTED_88d37e0b was set in the same incident to add the same floor
  # for a->b (a->b was healthy at the time, but the floor is harmless).
  # GR passes 0/0 (no override; the sync deployment does not run there).
  REDACTED_d063ac2f = var.REDACTED_d063ac2f
  REDACTED_88d37e0b = var.REDACTED_88d37e0b

  depends_on = [module.external_secrets]
}

# Kubernetes Dashboard
module "REDACTED_ac4dcdf5" {
  source = "./_core/REDACTED_d97cef76"

  dashboard_hostname = var.dashboard_hostname
}

# =============================================================================
# Gatus - Status Page
# =============================================================================
module "gatus" {
  source     = "./namespaces/gatus"
  depends_on = [module.ingress_nginx, module.cert_manager, module.monitoring]

  # Site identity (gatus's site_code is the short site tag "nl"/"gr")
  site_code = var.site
  site_name = var.site_name
  timezone  = var.timezone

  # Site endpoints / thresholds
  gatus_hostname               = var.gatus_hostname
  prometheus_hostname          = var.prometheus_hostname
  REDACTED_9246ffd6    = var.REDACTED_9246ffd6
  REDACTED_1c1562d0 = var.REDACTED_1c1562d0

  # Storage / TLS (NL issues its own ACME cert; GR serves the NL wildcard)
  storage_class_delete = var.storage_class_delete
  acme_issuer_enabled  = var.acme_issuer_enabled
  tls_secret_name      = var.gatus_tls_secret_name

  # Paging: native ntfy provider (2026-08-25 cutover — Twilio + the dead
  # GitLab-pipeline provider removed). Arms only when all three gatus_ntfy_*
  # values are present (NL: TF_VAR_gatus_ntfy_* in the Atlantis env +
  # OpenBao ci/gatus-ntfy for drift-CI; GR/NO deliberately unset = silent).
  ntfy_url   = var.gatus_ntfy_url
  ntfy_topic = var.gatus_ntfy_topic
  ntfy_token = var.gatus_ntfy_token

  haproxy_stats_auth = var.haproxy_stats_auth
}

# =============================================================================
# Well-Known Endpoints (security.txt, etc.)
# =============================================================================
module "well_known" {
  source = "./namespaces/well-known"

  # Domains to serve .well-known endpoints — same on both sites
  # (active-active via DNS round-robin / BGP anycast)
  domains = [
    "status.example.net",
    "kyriakos.papadopoulos.tech",
  ]

  # cert-manager Certificate via ClusterIssuer letsencrypt-prod on NL only;
  # GR (acme_issuer_enabled = false) serves the NL-issued wildcard from OpenBao.
  acme_issuer_enabled = var.acme_issuer_enabled
  cert_issuer_name    = "letsencrypt-prod"
  cert_issuer_kind    = "ClusterIssuer"

  depends_on = [module.ingress_nginx, module.cert_manager]
}
