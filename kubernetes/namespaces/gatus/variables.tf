# =============================================================================
# Variables for Gatus Module
# =============================================================================
# Canonical NL<->GR mirror module (2026-08-16 campaign). Defaults are the NL
# values; the GR root call overrides every site-specific input. Do NOT
# hardcode a site-specific value in main.tf — parameterize it here.
# =============================================================================

# -----------------------------------------------------------------------------
# Site Configuration
# -----------------------------------------------------------------------------
variable "site_code" {
  description = "Short site identifier (nl or gr). Reserved for site labeling; not currently referenced by resources — kept per mirror-campaign variable surface."
  type        = string
  default     = "nl"
}

variable "site_name" {
  description = "Human-readable site name shown in the status-page UI description"
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
  default     = "v5.36.0" # mirror-campaign contract exception: adopt v5.36.0 on both sites
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
  description = "Hostname for Gatus ingress (NL: nl-gatus.*, GR: gr-gatus.*)"
  type        = string
  default     = "nl-gatus.example.net"
}

# -----------------------------------------------------------------------------
# Prometheus Configuration (for network checks)
# -----------------------------------------------------------------------------
variable "prometheus_hostname" {
  description = "Prometheus hostname for API queries (NL: nl-prometheus.*, GR: gr-prometheus.*)"
  type        = string
  default     = "nl-prometheus.example.net"
}

# -----------------------------------------------------------------------------
# Network Monitoring Thresholds (site-specific — GR overrides in root call)
# -----------------------------------------------------------------------------
variable "REDACTED_9246ffd6" {
  description = "Minimum expected FRR BGP sessions (established) as seen from this site's Prometheus"
  type        = number
  default     = 35 # NL: alert if fewer than 35 of ~39 sessions. GR root passes 12.
}

variable "REDACTED_1c1562d0" {
  description = "Minimum expected Cilium BGP sessions (established) as seen from this site's Prometheus"
  type        = number
  default     = 4 # NL: 4. GR root passes 3.
}

variable "expected_ipsec_tunnels" {
  description = "Minimum expected IPsec tunnels (up)"
  type        = number
  default     = 16 # Alert if fewer than 16 of 18 tunnels
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------
variable "storage_class_delete" {
  description = "Delete-reclaim storage class for the Gatus PVC (ephemeral stateful data). NL: REDACTED_4f3da73d, GR: iscsi-ssd-delete."
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
# Certificate / TLS Configuration
# -----------------------------------------------------------------------------
# NL runs cert-manager with a per-host ACME Certificate ("gatus-tls").
# GR consumes the wildcard secret synced from NL (via OpenBao PushSecret) and
# runs NO ACME issuance for this host — so the Certificate resource and the
# cert-manager Prometheus endpoint are both gated on acme_issuer_enabled.
variable "acme_issuer_enabled" {
  description = "Whether cert-manager ACME issuance is active on this cluster (NL true, GR false). Gates the gatus-tls Certificate resource and the cert-manager status endpoint."
  type        = bool
  default     = true
}

variable "cert_issuer_name" {
  description = "cert-manager issuer name (only used when acme_issuer_enabled)"
  type        = string
  default     = "letsencrypt-prod"
}

variable "cert_issuer_kind" {
  description = "cert-manager issuer kind (Issuer or ClusterIssuer)"
  type        = string
  default     = "ClusterIssuer"
}

variable "tls_secret_name" {
  description = "TLS secret name for the ingress. NL: gatus-tls (issued by the gated Certificate). GR: REDACTED_0d82b4df-tls."
  type        = string
  default     = "gatus-tls"
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
variable "gitlab_pipeline_trigger_token" {
  description = "GitLab pipeline trigger token for portfolio status webhook"
  type        = string
  default     = ""
  sensitive   = true
}

variable "gitlab_portfolio_project_id" {
  description = "GitLab project ID for portfolio site"
  type        = string
  default     = "9"
}

# -----------------------------------------------------------------------------
# HAProxy Edge Node Authentication
# -----------------------------------------------------------------------------
variable "haproxy_stats_auth" {
  description = "Base64 encoded HAProxy stats REDACTED_6fa691d2 (user:pass). MUST be supplied by the root (tfvars) — an empty value breaks the two Edge endpoint checks."
  type        = string
  default     = ""
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Twilio SMS — for tier-1 service alerts via Gatus custom provider.
# Closes IFRNLLEI01PRD-802. Empty values disable Twilio alerting.
# Paging additionally gates on twilio_bridge_url (mirror-campaign contract):
# a site with no SMS bridge wired keeps paging off even if creds leak in.
# -----------------------------------------------------------------------------
variable "twilio_bridge_url" {
  description = "Site SMS bridge URL (Alertmanager->Twilio bridge). Used only as the site-level 'paging is wired here' gate for Gatus Twilio alerting — Gatus itself posts to api.twilio.com directly. NL: http://10.0.X.X:9106/alert, GR: http://10.0.X.X:9106/alert. Empty string = paging off."
  type        = string
  default     = "http://10.0.X.X:9106/alert"
}

variable "twilio_account_sid" {
  description = "Twilio Account SID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "twilio_api_key_sid" {
  description = "Twilio API Key SID (used as basic-auth username)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "twilio_api_key_secret" {
  description = "Twilio API Key Secret (used as basic-auth password)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "twilio_from_number" {
  description = "Twilio-owned sender phone number"
  type        = string
  default     = ""
  sensitive   = true
}

variable "twilio_to_number" {
  description = "Operator destination phone number"
  type        = string
  default     = ""
  sensitive   = true
}
