variable "k8s_host" {
  description = "Kubernetes API server URL"
  type        = string
}

variable "k8s_token" {
  description = "Service account token"
  type        = string
  sensitive   = true
}

variable "k8s_ca_cert" {
  description = "Cluster CA certificate (base64 encoded)"
  type        = string
  sensitive   = true
}

variable "pihole_password" {
  description = "Pi-hole web admin password"
  type        = string
  sensitive   = true
  default     = "changeme123"
}
