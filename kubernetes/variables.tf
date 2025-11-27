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
# NFS Storage - Changed to NFS VLAN
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

***REMOVED***
# Domain
***REMOVED***

variable "domain" {
  description = "Base domain for ingress hostnames"
  type        = string
  default     = "example.net"
}

***REMOVED***
# MinIO
***REMOVED***

variable "minio_root_user" {
  description = "MinIO root username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "minio_root_password" {
  description = "MinIO root password"
  type        = string
  sensitive   = true
}

variable "minio_storage_size" {
  description = "MinIO storage size"
  type        = string
  default     = "100Gi"
}

variable "minio_version" {
  description = "MinIO Docker image version"
  type        = string
  default     = "RELEASE.2024-11-07T00-52-20Z"
}

***REMOVED***
# Argo CD
***REMOVED***

variable "REDACTED_be8b31fd" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "7.7.10"
}

variable "argocd_nodeport" {
  description = "NodePort for Argo CD HTTPS access"
  type        = number
  default     = 30085
}

variable "REDACTED_84146aee" {
  description = "Enable ingress for Argo CD"
  type        = bool
  default     = true
}

variable "REDACTED_649263f1" {
  description = "Run Argo CD server in insecure mode"
  type        = bool
  default     = false
}

variable "REDACTED_035cbec1" {
  description = "Enable Argo CD notifications controller"
  type        = bool
  default     = false
}

variable "argocd_dex_enabled" {
  description = "Enable Dex for SSO integration"
  type        = bool
  default     = false
}

variable "argocd_repositories" {
  description = "Git repositories for Argo CD to manage"
  type        = map(any)
  default     = {}
}

variable "argocd_ssh_known_hosts" {
  description = "SSH known hosts for Git repositories"
  type        = string
  default     = ""
}

***REMOVED***
# MinIO Snapshot Service Account
***REMOVED***

variable "minio_snapshot_access_key" {
  description = "Access key for cluster snapshot service account"
  type        = string
  sensitive   = true
  default     = "snapshot-admin"
}

variable "minio_snapshot_secret_key" {
  description = "Secret key for cluster snapshot service account"
  type        = string
  sensitive   = true
}
