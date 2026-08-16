# =============================================================================
# SITE-SPECIFIC STORAGE BACKEND — MIRROR-EXEMPT FILE
# =============================================================================
# This file is deliberately DIFFERENT between the NL and GR repos (like
# namespaces/monitoring/scrape-estate.tf). Each site runs its own CSI
# backend: NL = Synology DS1621+ iSCSI via synology-csi, GR = democratic-csi
# against the GR NAS ZFS pool. The mirror-diff job must exempt
# site-storage.tf; every OTHER root .tf file is byte-identical between repos.
#
# Ordering note: the CSI depends_on edges the pre-canonical roots carried
# (seaweedfs/monitoring/awx -> CSI module) cannot live in the canonical
# main.tf because the module name differs per site. On an existing cluster
# this is plan-neutral; on a from-scratch bootstrap, apply this module first
# (targeted apply) or expect one retry pass.
# =============================================================================

module "nl-nas01_csi" {
  source = "./_core/nl-nas01-csi"

  synology_host        = var.nl-nas01_csi_host
  synology_username    = var.REDACTED_6177f7df
  synology_password    = REDACTED_97ec5898
  REDACTED_add7f998 = var.REDACTED_cd98d00a
  chart_version        = var.REDACTED_bf874266

  enable_velero_integration = false
}
