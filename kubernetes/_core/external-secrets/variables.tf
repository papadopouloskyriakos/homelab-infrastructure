variable "chart_version" {
  description = "External Secrets Operator Helm chart version"
  type        = string
  default     = "1.1.1"
}

variable "REDACTED_46d876c8" {
  description = "Enable Prometheus ServiceMonitor"
  type        = bool
  default     = true
}

variable "openbao_address" {
  description = "OpenBao server address"
  type        = string
  default     = "https://openbao.example.net:8200"
}

variable "openbao_role" {
  description = "OpenBao Kubernetes auth role"
  type        = string
  default     = "external-secrets"
}

variable "eso_auth_mount_path" {
  description = "OpenBao Kubernetes auth mount path for this cluster (NL: kubernetes, GR: kubernetes-gr)"
  type        = string
  default     = "kubernetes"
}

variable "openbao_ca_cert" {
  description = "OpenBao CA certificate (base64-encoded PEM, used as ClusterSecretStore caBundle)"
  type        = string
  sensitive   = true
}
