variable "common_labels" {
  description = "Common labels applied to created resources"
  type        = map(string)
  default     = {}
}

variable "chart_version" {
  description = "CloudNativePG Helm chart version (chart 0.29.0 = operator 1.30.0)"
  type        = string
  default     = "0.29.0"
}

variable "operator_replicas" {
  description = "CNPG operator replica count (HA: >1 with leader election)"
  type        = number
  default     = 2
}

variable "REDACTED_46d876c8" {
  description = "Enable the CNPG PodMonitor (requires the kube-prometheus PodMonitor CRD)"
  type        = bool
  default     = true
}
