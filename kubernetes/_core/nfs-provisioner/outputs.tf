output "namespace" {
  value = helm_release.nfs_provisioner.metadata.namespace
}
output "chart_version" {
  value = helm_release.nfs_provisioner.metadata.version
}
