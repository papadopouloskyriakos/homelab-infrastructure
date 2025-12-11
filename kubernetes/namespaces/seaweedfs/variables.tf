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
