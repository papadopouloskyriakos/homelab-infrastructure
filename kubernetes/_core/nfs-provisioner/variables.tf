variable "nfs_server" {
  description = "NFS server address"
  type        = string
}

variable "nfs_path" {
  description = "NFS export path"
  type        = string
}

variable "archive_on_delete" {
  description = "StorageClass parameter archiveOnDelete. IMMUTABLE on the live SC — must match the cluster's existing nfs-client SC (NL: false, GR: true). Changing it requires SC delete+recreate."
  type        = bool
  default     = false # NL live value (NL = content source of truth); GR root passes true
}
