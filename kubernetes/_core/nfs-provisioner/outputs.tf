output "storage_class_name" {
  description = "Name of the NFS storage class"
  value       = "nfs-client"
}

output "namespace" {
  description = "Namespace where NFS provisioner is installed"
  value       = "nfs-provisioner"
}
