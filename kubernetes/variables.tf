***REMOVED***
# Kubernetes Connection
***REMOVED***

variable "k8s_host" {
  description = "Kubernetes API server URL"
  type        = string
}

variable "k8s_token" {
  description = "Service account token for K8s API"
  type        = string
  sensitive   = true
}

variable "k8s_ca_cert" {
  description = "Cluster CA certificate (base64 encoded)"
  type        = string
  sensitive   = true
}

***REMOVED***
# NFS Storage
***REMOVED***

variable "nfs_server" {
  description = "NFS server IP address"
  type        = string
  default     = "10.0.X.X"
}

variable "nfs_path" {
  description = "NFS export path"
  type        = string
  default     = "/volume1/k8s"
}

***REMOVED***
# Pihole
***REMOVED***

variable "pihole_password" {
  description = "Pi-hole web admin password"
  type        = string
  sensitive   = true
  default     = "changeme123"
}

***REMOVED***
# Monitoring
***REMOVED***

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "changeme123"
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "1095d"
}

variable "REDACTED_6a2724e6" {
  description = "Prometheus PVC size"
  type        = string
  default     = "200Gi"
}

variable "grafana_storage_size" {
  description = "Grafana PVC size"
  type        = string
  default     = "20Gi"
}

***REMOVED***
# GitLab
***REMOVED***

variable "gitlab_url" {
  description = "GitLab instance URL"
  type        = string
  default     = "https://gitlab.example.net"
}

variable "gitlab_runner_token" {
  description = "GitLab Runner registration token"
  type        = string
  sensitive   = true
  default     = ""
}

variable "REDACTED_b6136a28" {
  description = "GitLab Agent token for k8s-agent"
  type        = string
  sensitive   = true
  default     = ""
}

***REMOVED***
# AWX
***REMOVED***

variable "REDACTED_3e5e811f" {
  description = "AWX PostgreSQL PVC size"
  type        = string
  default     = "50Gi"
}

variable "REDACTED_12032801" {
  description = "AWX Projects PVC size"
  type        = string
  default     = "50Gi"
}
