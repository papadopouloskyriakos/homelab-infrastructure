***REMOVED***
# Variables for Well-Known Endpoints Service
***REMOVED***

# -----------------------------------------------------------------------------
# security.txt Configuration (RFC 9116)
# -----------------------------------------------------------------------------
variable "REDACTED_7a948b08" {
  description = "Email address for security vulnerability reports"
  type        = string
}

variable "REDACTED_8d68a21d" {
  description = "Optional URL for security reports (e.g., GitHub security advisories)"
  type        = string
  default     = ""
}

variable "security_txt_expires" {
  description = "Expiration date for security.txt (ISO 8601 format)"
  type        = string
  default     = "2026-12-31T23:59:59.000Z"
}

variable "preferred_languages" {
  description = "Preferred languages for security reports"
  type        = list(string)
  default     = ["en"]
}

variable "security_policy_url" {
  description = "Optional URL to security policy documentation"
  type        = string
  default     = ""
}

variable "acknowledgments_url" {
  description = "Optional URL to security researchers acknowledgments page"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Domain Configuration
# -----------------------------------------------------------------------------
variable "domains" {
  description = "List of domains to serve .well-known endpoints for"
  type        = list(string)
}

variable "primary_hostname" {
  description = "Primary hostname for canonical security.txt URL"
  type        = string
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
