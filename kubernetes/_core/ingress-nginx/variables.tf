# =============================================================================
# Variables for Ingress NGINX Controller
# =============================================================================

variable "REDACTED_3b82c3d6" {
  description = "Default SSL certificate for ingress (namespace/secret-name)"
  type        = string
  default     = "REDACTED_f89271df"
}

variable "csp_header" {
  description = "Content-Security-Policy value for the global addHeaders block. Empty string omits the header (for sites whose applications own their CSP). frame-ancestors includes matrix.example.net for Grafana embedding (single estate-wide instance)."
  type        = string
  default     = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' wss:; frame-ancestors 'self' https://matrix.example.net vector://vector; base-uri 'self'; form-action 'self';"
}
