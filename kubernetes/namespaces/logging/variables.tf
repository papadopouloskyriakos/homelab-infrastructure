# =============================================================================
# Variables for Logging Module
# =============================================================================

variable "common_labels" {
  description = "Common labels to apply to resources (root supplies the site key)"
  type        = map(string)
  default     = {}
}

variable "loki_storage_size" {
  description = "Loki data PVC size (for WAL/cache)"
  type        = string
  default     = "10Gi"
}

variable "loki_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 30
}

variable "loki_storage_class" {
  # storageClassName is IMMUTABLE on the bound loki PVC. NL runs the delete
  # class, GR runs iscsi-ssd-retain (matching live) — GR root MUST pass its
  # retain class; aligning GR onto a delete class is a future migration step
  # (GR-6, PVC recreate required). Do not flip either side here.
  description = "StorageClass for the Loki data PVC (per-site; live PVC storageClassName is immutable)"
  type        = string
  default     = "REDACTED_4f3da73d"
}

variable "s3_endpoint" {
  description = "SeaweedFS S3 endpoint for Loki storage"
  type        = string
  default     = "seaweedfs-s3.seaweedfs.svc.cluster.local:8333"
}

variable "s3_bucket" {
  description = "SeaweedFS S3 bucket name for Loki"
  type        = string
  default     = "loki"
}

variable "promtail_syslog_port" {
  description = "Port for Promtail syslog receiver"
  type        = number
  default     = 1514
}

variable "REDACTED_337e6630" {
  description = "LoadBalancer IP for Promtail syslog receiver"
  type        = string
  default     = "10.0.X.X"
}
