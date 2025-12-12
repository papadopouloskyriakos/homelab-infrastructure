variable "dashboard_version" {
  description = "Kubernetes Dashboard Helm chart version"
  type        = string
  default     = "7.14.0"
}

variable "dashboard_hostname" {
  description = "Hostname for dashboard ingress"
  type        = string
}
