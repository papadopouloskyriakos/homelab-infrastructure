# ========================================================================
# Synology CSI Variables - nl-nas01 (DS1621+)
# ========================================================================

variable "synology_host" {
  description = "Synology NAS IP address or hostname"
  type        = string
}

variable "synology_port" {
  description = "Synology DSM port (5000 for HTTP, 5001 for HTTPS)"
  type        = number
  default     = 5001
}

variable "synology_https" {
  description = "Use HTTPS to connect to DSM"
  type        = bool
  default     = true
}

variable "synology_username" {
  description = "Synology DSM username with admin privileges"
  type        = string
  sensitive   = true
}

variable "synology_password" {
  description = "Synology DSM password"
  type        = string
  sensitive   = true
}

variable "REDACTED_add7f998" {
  description = "Synology volume path for LUN creation (e.g., /volume1)"
  type        = string
  default     = "/volume1"
}

variable "chart_version" {
  description = "Synology CSI Helm chart version"
  type        = string
  default     = "0.10.1"
}

variable "fs_type" {
  description = "Filesystem type for volumes (ext4 or btrfs)"
  type        = string
  default     = "ext4"
}

variable "enable_snapshots" {
  description = "Enable VolumeSnapshotClass for CSI snapshots"
  type        = bool
  default     = true
}

variable "enable_velero_integration" {
  description = "Create additional VolumeSnapshotClass labeled for Velero"
  type        = bool
  default     = true
}
