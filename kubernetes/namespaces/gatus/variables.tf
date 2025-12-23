***REMOVED***
# Variables for Gatus Module
***REMOVED***

# -----------------------------------------------------------------------------
# Site Configuration
# -----------------------------------------------------------------------------
variable "site_code" {
  description = "Short site identifier (nl or gr)"
  type        = string
  default     = "nl"
}

variable "site_name" {
  description = "Human-readable site name for X-Served-By header"
  type        = string
  default     = "Netherlands"
}

variable "timezone" {
  description = "Timezone for Gatus container"
  type        = string
  default     = "Europe/Amsterdam"
}

# -----------------------------------------------------------------------------
# Gatus Version & Image
# -----------------------------------------------------------------------------
variable "gatus_version" {
  description = "Gatus container image version"
  type        = string
  default     = "v5.33.0"
}

# -----------------------------------------------------------------------------
# UI Configuration
# -----------------------------------------------------------------------------
variable "gatus_ui_title" {
  description = "Title shown on status page"
  type        = string
  default     = "Nuclear Lighters Status"
}

variable "gatus_ui_header" {
  description = "Header text on status page"
  type        = string
  default     = "Nuclear Lighters"
}

variable "gatus_ui_link" {
  description = "Link for logo/header click"
  type        = string
  default     = "https://kyriakos.papadopoulos.tech"
}

# -----------------------------------------------------------------------------
# Hostname Configuration
# -----------------------------------------------------------------------------
variable "gatus_hostname" {
  description = "Hostname for Gatus ingress (BGP anycast)"
  type        = string
  default     = "nl-gatus.example.net"
}

variable "portfolio_hostname" {
  description = "Portfolio site hostname for health checks"
  type        = string
  default     = "kyriakos.papadopoulos.tech"
}

variable "gitlab_hostname" {
  description = "GitLab hostname"
  type        = string
  default     = "gitlab.example.net"
}

variable "argocd_hostname" {
  description = "ArgoCD hostname"
  type        = string
  default     = "argocd.example.net"
}

variable "grafana_hostname" {
  description = "Grafana hostname"
  type        = string
  default     = "grafana.example.net"
}

# -----------------------------------------------------------------------------
# Prometheus Configuration (for network checks)
# -----------------------------------------------------------------------------
variable "prometheus_hostname" {
  description = "Prometheus hostname for API queries"
  type        = string
  default     = "nl-prometheus.example.net"
}

# -----------------------------------------------------------------------------
# Network Monitoring Thresholds
# -----------------------------------------------------------------------------
variable "REDACTED_9246ffd6" {
  description = "Minimum expected FRR BGP sessions (established)"
  type        = number
  default     = 35 # Alert if fewer than 35 of ~39 sessions
}

variable "REDACTED_1c1562d0" {
  description = "Minimum expected Cilium BGP sessions (established)"
  type        = number
  default     = 4
}

variable "expected_ipsec_tunnels" {
  description = "Minimum expected IPsec tunnels (up)"
  type        = number
  default     = 16 # Alert if fewer than 16 of 18 tunnels
}

# -----------------------------------------------------------------------------
# Netherlands Site IPs
# -----------------------------------------------------------------------------
variable "nl_ingress_ip" {
  description = "Netherlands ingress controller IP"
  type        = string
  default     = "10.0.X.X"
}

variable "nl_k8s_api_ip" {
  description = "Netherlands Kubernetes API IP"
  type        = string
  default     = "10.0.X.X"
}

# -----------------------------------------------------------------------------
# Greece Site IPs
# -----------------------------------------------------------------------------
variable "gr_ingress_ip" {
  description = "Greece ingress controller IP"
  type        = string
  default     = "10.0.X.X"
}

variable "gr_k8s_api_ip" {
  description = "Greece Kubernetes API IP"
  type        = string
  default     = "10.0.X.X"
}

# -----------------------------------------------------------------------------
***REMOVED*** Configuration
# -----------------------------------------------------------------------------
variable "storage_class" {
  description = "Storage class for Gatus PVC"
  type        = string
  default     = "REDACTED_4f3da73d"
}

variable "gatus_storage_size" {
  description = "Storage size for Gatus SQLite database"
  type        = string
  default     = "1Gi"
}

# -----------------------------------------------------------------------------
# Resource Configuration
# -----------------------------------------------------------------------------
variable "gatus_cpu_request" {
  description = "CPU request for Gatus"
  type        = string
  default     = "10m"
}

variable "gatus_memory_request" {
  description = "Memory request for Gatus"
  type        = string
  default     = "64Mi"
}

variable "gatus_cpu_limit" {
  description = "CPU limit for Gatus"
  type        = string
  default     = "200m"
}

variable "gatus_memory_limit" {
  description = "Memory limit for Gatus"
  type        = string
  default     = "256Mi"
}

# -----------------------------------------------------------------------------
# Certificate Configuration
# -----------------------------------------------------------------------------
variable "cert_issuer_name" {
  description = "cert-manager issuer name"
  type        = string
  default     = "letsencrypt-prod"
}

variable "cert_issuer_kind" {
  description = "cert-manager issuer kind (Issuer or ClusterIssuer)"
  type        = string
  default     = "ClusterIssuer"
}

# -----------------------------------------------------------------------------
# Additional Endpoints (for site-specific checks)
# -----------------------------------------------------------------------------
variable "additional_endpoints" {
  description = "Additional endpoints to monitor (site-specific)"
  type = list(object({
    name       = string
    group      = string
    url        = string
    interval   = optional(string, "60s")
    conditions = list(string)
    headers    = optional(map(string), {})
    client     = optional(object({ insecure = bool }), null)
    dns        = optional(object({ query-name = string, query-type = string }), null)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Webhook Alerting Configuration
# -----------------------------------------------------------------------------
variable "REDACTED_4f32e8a8" {
  description = "GitLab pipeline trigger token for portfolio status webhook"
  type        = string
  default     = ""
  sensitive   = true
}

variable "REDACTED_680664be" {
  description = "GitLab project ID for portfolio site"
  type        = string
  default     = "9"
}

# -----------------------------------------------------------------------------
# HAProxy Edge Node Authentication
# -----------------------------------------------------------------------------
variable "haproxy_stats_auth" {
  description = "Base64 encoded HAProxy stats authentication (user:pass)"
  type        = string
  default     = ""
  sensitive   = true
}
