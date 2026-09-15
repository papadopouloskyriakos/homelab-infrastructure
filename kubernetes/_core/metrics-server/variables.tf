# ========================================================================
# metrics-server Module Variables
# ========================================================================

variable "namespace" {
  description = "Kubernetes namespace for metrics-server (the APIService expects kube-system)"
  type        = string
  default     = "kube-system"
}

variable "metrics_server_version" {
  description = "metrics-server Helm chart version (kubernetes-sigs; 3.14.0 = app v0.9.0)"
  type        = string
  default     = "3.14.0"
}

variable "cpu_request" {
  description = "CPU request for metrics-server"
  type        = string
  default     = "50m"
}

variable "memory_request" {
  description = "Memory request for metrics-server"
  type        = string
  default     = "64Mi"
}

variable "memory_limit" {
  description = "Memory limit for metrics-server"
  type        = string
  default     = "256Mi"
}
