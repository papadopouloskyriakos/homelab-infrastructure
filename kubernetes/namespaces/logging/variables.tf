***REMOVED***
# Variables for Logging Module
***REMOVED***

variable "common_labels" {
  description = "Common labels to apply to resources"
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

variable "minio_endpoint" {
  description = "MinIO S3 endpoint for Loki storage"
  type        = string
  default     = "minio.minio.svc.cluster.local:9000"
}

variable "minio_bucket" {
  description = "MinIO bucket name for Loki"
  type        = string
  default     = "loki"
}

variable "promtail_syslog_port" {
  description = "Port for Promtail syslog receiver"
  type        = number
  default     = 1514
}
