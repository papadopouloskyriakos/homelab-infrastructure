variable "loki_ruler_enabled" {
  description = "Enable the Loki ruler (log-based alerting). Rules come from ConfigMaps labelled `loki_rule` via the chart's rules sidecar, so storage is the local directory rather than the S3 bucket nobody writes rules to; alerts go to this cluster's own Alertmanager. ⚠ The matching egress rule in network-policy.tf is LOAD-BEARING: without it the ruler evaluates rules and cannot deliver a single alert, which looks configured and fires nothing."
  type        = bool
  default     = false
}

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

variable "s3_secret_path" {
  description = "OpenBao KV path with the S3 credentials for the primary (`s3`) store. ci/loki for SeaweedFS; REDACTED_218b2888 for the crypt gateway."
  type        = string
  default     = "ci/loki"
}

variable "s3_secret_access_key_property" {
  description = "Property name of the access key at s3_secret_path (s3_access_key at ci/loki, access_key at REDACTED_218b2888)"
  type        = string
  default     = "s3_access_key"
}

variable "s3_secret_secret_key_property" {
  description = "Property name of the secret key at s3_secret_path (s3_secret_key at ci/loki, secret_key at REDACTED_218b2888)"
  type        = string
  default     = "s3_secret_key"
}

variable "s3_legacy_endpoint" {
  description = "Endpoint of the `legacy` named store holding chunks written before s3_cutover_date (the old cluster-local SeaweedFS). Only read when s3_cutover_date is set."
  type        = string
  default     = "seaweedfs-s3.seaweedfs.svc.cluster.local:8333"
}

variable "s3_cutover_date" {
  description = "UTC day (YYYY-MM-DD) from which chunks go to the `s3` store; earlier days stay in `legacy`. Empty = single store, no cut-over."
  type        = string
  default     = ""
}

