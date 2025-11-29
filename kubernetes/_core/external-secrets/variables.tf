variable "chart_version" {
  description = "External Secrets Operator Helm chart version"
  type        = string
  default     = "0.12.1"
}

variable "REDACTED_46d876c8" {
  description = "Enable Prometheus ServiceMonitor"
  type        = bool
  default     = true
}

variable "openbao_address" {
  description = "OpenBao server address"
  type        = string
  default     = "http://10.0.X.X:8200"
}

variable "openbao_role" {
  description = "OpenBao Kubernetes auth role"
  type        = string
  default     = "external-secrets"
}
