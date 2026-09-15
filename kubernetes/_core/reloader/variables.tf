# ========================================================================
# Reloader Module Variables
# ========================================================================

variable "namespace" {
  description = "Kubernetes namespace for Reloader"
  type        = string
  default     = "reloader"
}

variable "reloader_version" {
  description = "Reloader Helm chart version (stakater-charts; 2.2.17 = app v1.4.22)"
  type        = string
  default     = "2.2.17"
}

variable "cpu_request" {
  description = "CPU request for the Reloader controller"
  type        = string
  default     = "10m"
}

variable "memory_request" {
  description = "Memory request for the Reloader controller"
  type        = string
  default     = "64Mi"
}

variable "memory_limit" {
  description = "Memory limit for the Reloader controller"
  type        = string
  default     = "256Mi"
}
