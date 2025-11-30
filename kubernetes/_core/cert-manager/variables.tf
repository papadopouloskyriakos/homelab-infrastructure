variable "chart_version" {
  description = "cert-manager Helm chart version"
  type        = string
  default     = "1.17.1"
}

variable "REDACTED_46d876c8" {
  description = "Enable Prometheus ServiceMonitor"
  type        = bool
  default     = true
}
