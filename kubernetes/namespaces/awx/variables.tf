***REMOVED***
# AWX Module Variables
***REMOVED***

variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
}

variable "nfs_server" {
  description = "NFS server address"
  type        = string
}

variable "nfs_path" {
  description = "NFS base path"
  type        = string
}

variable "domain" {
  description = "Base domain for ingress URLs"
  type        = string
  default     = "example.net"
}

variable "REDACTED_3e5e811f" {
  description = "PostgreSQL storage size"
  type        = string
  default     = "50Gi"
}

variable "REDACTED_12032801" {
  description = "Projects storage size"
  type        = string
  default     = "50Gi"
}
