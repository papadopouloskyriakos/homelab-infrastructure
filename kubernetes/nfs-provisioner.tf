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
        create          = false  # Don't manage StorageClass via helm
      }
      replicaCount = 1
    })
  ]
}
