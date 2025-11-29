***REMOVED***
# Variables for Monitoring Module
***REMOVED***

variable "common_labels" {
  description = "Common labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "1095d"
}

variable "REDACTED_6a2724e6" {
  description = "Prometheus PVC size"
  type        = string
  default     = "200Gi"
}

# NOTE: grafana_admin_password removed - now sourced from OpenBao via ExternalSecret

variable "grafana_storage_size" {
  description = "Grafana PVC size"
  type        = string
  default     = "20Gi"
}
