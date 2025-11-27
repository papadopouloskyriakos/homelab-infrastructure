# ========================================================================
# Synology CSI Outputs - nl-nas01 (DS1621+)
# ========================================================================

output "namespace" {
  description = "Synology CSI namespace"
  value       = kubernetes_namespace.synology_csi.metadata[0].name
}

output "storage_class_retain" {
  description = "Storage class with Retain policy"
  value       = "nl-nas01-iscsi-retain"
}

output "storage_class_delete" {
  description = "Storage class with Delete policy"
  value       = "nl-nas01-iscsi-delete"
}

output "snapshot_class" {
  description = "Volume snapshot class name"
  value       = var.enable_snapshots ? "nl-nas01-snapclass" : null
}
