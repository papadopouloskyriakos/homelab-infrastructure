output "namespace" {
  value = helm_release.nfs_provisioner.metadata[0].namespace
}

output "chart_version" {
  value = helm_release.nfs_provisioner.metadata[0].version
}
