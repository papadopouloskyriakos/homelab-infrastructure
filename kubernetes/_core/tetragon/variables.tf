# ========================================================================
# Tetragon Module Variables
# ========================================================================

# ========================================================================
# Core Settings
# ========================================================================

variable "namespace" {
  description = "Kubernetes namespace for Tetragon"
  type        = string
  default     = "kube-system"
}

variable "tetragon_version" {
  description = "Tetragon Helm chart version"
  type        = string
  default     = "1.6.0"
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
  description = "Enable process execution monitoring policy (disabled on both sites: raw_syscalls tracepoint is high-volume)"
  type        = bool
  default     = false
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
# Export Configuration
# ========================================================================

variable "export_base_path" {
  description = "Base path for Tetragon export files"
  type        = string
  default     = "/var/log/tetragon"
}

variable "export_filename" {
  description = "Filename for Tetragon event exports"
  type        = string
  default     = "tetragon.log"
}

variable "REDACTED_9e291ab8" {
  description = "Maximum size of export file in MB before rotation"
  type        = number
  default     = 50
}

variable "REDACTED_740e128e" {
  description = "Maximum number of backup files to keep"
  type        = number
  default     = 2
}

variable "export_rate_limit" {
  description = "Rate limit for event export (-1 for unlimited)"
  type        = number
  default     = 1000
}

# ========================================================================
# Monitoring
# ========================================================================

variable "REDACTED_46d876c8" {
  description = "Enable Prometheus ServiceMonitor"
  type        = bool
  default     = true
}
