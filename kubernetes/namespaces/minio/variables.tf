variable "common_labels" {
  type = map(string)
}

variable "minio_root_user" {
  type      = string
  sensitive = true
}

variable "minio_root_password" {
  type      = string
  sensitive = true
}

variable "minio_storage_size" {
  type    = string
  default = "100Gi"
}

variable "minio_version" {
  type    = string
  default = "latest"
}

variable "domain" {
  type = string
}

# -----------------------------------------------------------------------------
# Cluster Snapshots Service Account
# -----------------------------------------------------------------------------
variable "minio_snapshot_access_key" {
  description = "Access key for cluster snapshot service account"
  type        = string
  sensitive   = true
  default     = "snapshot-admin"
}

variable "minio_snapshot_secret_key" {
  description = "Secret key for cluster snapshot service account"
  type        = string
  sensitive   = true
}
