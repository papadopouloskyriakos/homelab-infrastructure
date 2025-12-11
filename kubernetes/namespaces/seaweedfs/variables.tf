***REMOVED***
# SeaweedFS Variables
***REMOVED***

variable "common_labels" {
  description = "Common labels to apply to resources"
  type        = map(string)
}

# -----------------------------------------------------------------------------
# Chart Configuration
# -----------------------------------------------------------------------------
variable "REDACTED_c1342204" {
  description = "SeaweedFS Helm chart version"
  type        = string
  default     = "4.0.401"
}

# -----------------------------------------------------------------------------
***REMOVED*** Configuration
# -----------------------------------------------------------------------------
variable "storage_class" {
  description = "Storage class for SeaweedFS PVCs"
  type        = string
  default     = "REDACTED_b280aec5"
}

variable "master_storage_size" {
  description = "Storage size for master metadata"
  type        = string
  default     = "10Gi"
}

variable "volume_storage_size" {
  description = "Storage size per volume server (main data storage)"
  type        = string
  default     = "500Gi" # 2 volume servers x 500Gi = 1TB total
}

variable "filer_storage_size" {
  description = "Storage size for filer metadata"
  type        = string
  default     = "20Gi"
}

# -----------------------------------------------------------------------------
# Cluster Mesh
# -----------------------------------------------------------------------------
variable "cluster_name" {
  description = "Cluster name for cross-site identification"
  type        = string
  default     = "nlcl01k8s"
}

# -----------------------------------------------------------------------------
# Node Selection
# -----------------------------------------------------------------------------
variable "node_region" {
  description = "Region label to select local nodes only"
  type        = string
  default     = "nl-lei"
}

# -----------------------------------------------------------------------------
# Cross-Site Replication (Cluster Mesh)
# -----------------------------------------------------------------------------
variable "REDACTED_4bbaa453" {
  description = "Enable filer.sync deployment for cross-site replication"
  type        = bool
  default     = false
}

variable "site_code" {
  description = "Short site identifier for this cluster (nl or gr)"
  type        = string
  default     = "nl"
}

variable "remote_site_code" {
  description = "Short site identifier for the remote cluster"
  type        = string
  default     = "gr"
}

variable "REDACTED_a4f42897" {
  description = "SeaweedFS container image version for filer.sync"
  type        = string
  default     = "4.01"
}

# -----------------------------------------------------------------------------
# filer.sync Resource Allocation
# -----------------------------------------------------------------------------
variable "REDACTED_11f97ee2" {
  description = "CPU request for filer.sync container"
  type        = string
  default     = "100m"
}

variable "REDACTED_8e93a7d2" {
  description = "Memory request for filer.sync container"
  type        = string
  default     = "128Mi"
}

variable "REDACTED_7c4dc246" {
  description = "CPU limit for filer.sync container"
  type        = string
  default     = "500m"
}

variable "REDACTED_5bbf190b" {
  description = "Memory limit for filer.sync container"
  type        = string
  default     = "512Mi"
}
