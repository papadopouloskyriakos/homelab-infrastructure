***REMOVED***
# NFS Subdir External Provisioner
***REMOVED***
# Provides dynamic PV provisioning using NFS storage
***REMOVED***Class: nfs-client (default)
#
# Import command:
# tofu import 'helm_release.nfs_provisioner' 'nfs-provisioner/nfs-provisioner'
***REMOVED***

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
        name            = "nfs-client"
        defaultClass    = true
        reclaimPolicy   = "Retain"
        archiveOnDelete = true
      }
      replicaCount = 1
    })
  ]
}
