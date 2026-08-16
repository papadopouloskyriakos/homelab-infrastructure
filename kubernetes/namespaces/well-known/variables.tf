# =============================================================================
# Variables for Well-Known Endpoints Service
# =============================================================================

# -----------------------------------------------------------------------------
# Domain Configuration
# -----------------------------------------------------------------------------
variable "domains" {
  description = "List of domains to serve .well-known endpoints for"
  type        = list(string)
}

# -----------------------------------------------------------------------------
# Certificate Configuration
# -----------------------------------------------------------------------------
variable "acme_issuer_enabled" {
  description = "Whether a cert-manager ClusterIssuer is available. true (NL): create the multi-domain Certificate and reference its secret in the Ingress. false (GR): skip the Certificate and serve the pre-existing wildcard secrets listed in wildcard_tls_secrets."
  type        = bool
  default     = true
}

variable "cert_issuer_name" {
  description = "cert-manager issuer name (used only when acme_issuer_enabled)"
  type        = string
  default     = "letsencrypt-prod"
}

variable "cert_issuer_kind" {
  description = "cert-manager issuer kind (Issuer or ClusterIssuer; used only when acme_issuer_enabled)"
  type        = string
  default     = "ClusterIssuer"
}

variable "wildcard_tls_secrets" {
  description = "Ordered list of pre-existing wildcard TLS secrets to serve when acme_issuer_enabled is false. Each entry becomes one Ingress tls block. The secrets must already exist in the well-known namespace (copied wildcard certs)."
  type = list(object({
    hosts       = list(string)
    secret_name = string
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Image Configuration
# -----------------------------------------------------------------------------
variable "nginx_version" {
  description = "nginx-unprivileged image version"
  type        = string
  default     = "1.27-alpine"
}

# -----------------------------------------------------------------------------
# Resource Configuration
# -----------------------------------------------------------------------------
variable "cpu_request" {
  description = "CPU request"
  type        = string
  default     = "5m"
}

variable "memory_request" {
  description = "Memory request"
  type        = string
  default     = "16Mi"
}

variable "cpu_limit" {
  description = "CPU limit"
  type        = string
  default     = "50m"
}

variable "memory_limit" {
  description = "Memory limit"
  type        = string
  default     = "32Mi"
}
