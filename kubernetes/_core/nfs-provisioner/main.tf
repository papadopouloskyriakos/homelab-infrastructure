# =============================================================================
# NFS Subdir External Provisioner
# =============================================================================
# Provides dynamic NFS-based storage provisioning
# StorageClass: nfs-client — chart-managed on BOTH sites since the 2026-08
# NL<->GR mirror campaign. NL's live SC was created out-of-band on 2025-11-25
# (kubectl apply) and was ADOPTED into this Helm release: it carries
# meta.helm.sh/release-name/-namespace annotations + the
# app.kubernetes.io/managed-by=Helm label. Do not remove those, and do not
# flip storageClass.create back to false — Helm would then delete the SC on
# upgrade.
#
# ⚠ StorageClass `parameters` are IMMUTABLE in the Kubernetes API.
# archiveOnDelete differs per site for historical reasons (NL "false",
# GR "true" — the chart default at GR install time). It is parameterized via
# var.archive_on_delete and MUST match each cluster's live SC, otherwise the
# helm upgrade fails trying to patch an immutable field. Converging the two
# sites would require deleting + recreating one SC (safe for existing bound
# PVs, but deliberately deferred — see the mirror-campaign report).
# =============================================================================

resource "helm_release" "nfs_provisioner" {
  name             = "nfs-provisioner"
  repository       = "https://kubernetes-sigs.github.io/REDACTED_5fef70be"
  chart            = "REDACTED_5fef70be"
  namespace        = "nfs-provisioner"
  create_namespace = true
  version          = "4.0.18"

  values = [
    yamlencode({
      nfs = {
        server = var.nfs_server
        path   = var.nfs_path
      }

      storageClass = {
        create               = true
        name                 = "nfs-client"
        defaultClass         = false
        allowVolumeExpansion = true
        reclaimPolicy        = "Delete"
        archiveOnDelete      = var.archive_on_delete
      }

      replicaCount = 1

      podDisruptionBudget = {
        enabled      = true
        minAvailable = 1
      }

      resources = {
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
      }
    })
  ]
}
