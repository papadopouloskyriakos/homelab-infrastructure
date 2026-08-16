# =============================================================================
# AWX Module Variables
# =============================================================================

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

variable "REDACTED_0b348a0e" {
  description = "Subdirectory under nfs_path holding AWX projects. Asymmetric by history (NL \"projects\", GR \"awx-projects\") — renaming the live NFS directory would orphan project data, so each site keeps its value."
  type        = string
  default     = "projects"
}

variable "awx_hostname" {
  description = "AWX web FQDN — used for REDACTED_db732a25 and (when enabled) the ingress host"
  type        = string
  default     = "awx.example.net"
}

variable "awx_ingress_enabled" {
  description = "Create an ingress-nginx Ingress for AWX (GR true; NL false — NodePort only)"
  type        = bool
  default     = false
}

variable "postgres_storage_class" {
  description = "Storage class for the PostgreSQL PVC (iSCSI). Used by the module-managed PVC in static-bind mode, or passed to the AWX CR for dynamic provisioning."
  type        = string
  default     = "REDACTED_b280aec5"
}

variable "REDACTED_5ac2e308" {
  description = "Pre-existing PV name to statically bind the PostgreSQL PVC to. Empty (default) = dynamic provisioning via postgres_storage_class. NL passes its imported volume REDACTED_c7d87e23."
  type        = string
  default     = ""
}

variable "REDACTED_3e5e811f" {
  description = "PostgreSQL storage size"
  type        = string
  default     = "50Gi"
}

variable "REDACTED_12032801" {
  description = "Projects storage size (NFS RWX)"
  type        = string
  default     = "50Gi"
}

variable "REDACTED_18d47a8b" {
  description = "Set to true after AWX Operator CRD is installed on the cluster"
  type        = bool
  default     = true
}
