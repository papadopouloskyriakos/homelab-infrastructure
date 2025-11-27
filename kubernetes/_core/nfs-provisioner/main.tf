***REMOVED***
# NFS Subdir External Provisioner
***REMOVED***
# Provides dynamic NFS-based storage provisioning
***REMOVED***Class: nfs-client
***REMOVED***

variable "nfs_server" {
  description = "NFS server address"
  type        = string
}

variable "nfs_path" {
  description = "NFS export path"
  type        = string
}

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
        create = false
      }

      replicaCount = 1

      podDisruptionBudget = {
        enabled      = true
        minAvailable = 1
      }
    })
  ]
}
