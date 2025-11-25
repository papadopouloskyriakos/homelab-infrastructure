***REMOVED***
# Argo CD Variables
***REMOVED***

variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "domain" {
  description = "Base domain for ingress hostnames"
  type        = string
  default     = "example.net"
}

variable "REDACTED_be8b31fd" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "7.7.10"
}

variable "argocd_nodeport" {
  description = "NodePort for Argo CD HTTPS access"
  type        = number
  default     = 30080
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
