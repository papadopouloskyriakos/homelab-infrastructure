# ========================================================================
# Tetragon Module Variables
# ========================================================================

# ========================================================================
# Core Settings
# ========================================================================

variable "tetragon_version" {
  description = "Tetragon Helm chart version"
  type        = string
  default     = "1.6.0"
}

variable "cluster_name" {
  description = "Kubernetes cluster name for event correlation"
  type        = string
  default     = "nlcl01k8s"
}

# ========================================================================
# Resource Limits
# ========================================================================

variable "REDACTED_c5d74212" {
  description = "CPU request for Tetragon agent pods"
  type        = string
  default     = "100m"
}

variable "REDACTED_6e37ecf0" {
  description = "Memory request for Tetragon agent pods"
  type        = string
  default     = "128Mi"
}

variable "tetragon_cpu_limit" {
  description = "CPU limit for Tetragon agent pods"
  type        = string
  default     = "1"
}

variable "tetragon_memory_limit" {
  description = "Memory limit for Tetragon agent pods"
  type        = string
  default     = "512Mi"
}

# ========================================================================
# TracingPolicy Toggles
# ========================================================================
# All policies are observe-only (no enforcement)
# Enable/disable based on noise tolerance and use case
# ========================================================================

variable "REDACTED_8a8d8279" {
  description = "Enable process execution monitoring policy"
  type        = bool
  default     = true
}

variable "REDACTED_ca9faf45" {
  description = "Enable sensitive file access monitoring policy"
  type        = bool
  default     = true
}

variable "REDACTED_f45ec1ce" {
  description = "Enable privilege escalation monitoring policy"
  type        = bool
  default     = true
}

variable "REDACTED_936fa359" {
  description = "Enable kubectl exec monitoring policy"
  type        = bool
  default     = true
}

variable "REDACTED_073bcdbd" {
  description = "Enable network connection monitoring policy (can be noisy)"
  type        = bool
  default     = false
}

# ========================================================================
# Grafana Dashboard
# ========================================================================

variable "enable_grafana_dashboard" {
  description = "Deploy Tetragon Grafana dashboard ConfigMap"
  type        = bool
  default     = true
}

variable "REDACTED_060311fa" {
  description = "Namespace where Grafana is deployed"
  type        = string
  default     = "monitoring"
}

variable "grafana_sidecar_label" {
  description = "Label that Grafana sidecar watches for dashboard ConfigMaps"
  type        = string
  default     = "grafana_dashboard"
}
