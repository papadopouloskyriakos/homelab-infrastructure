# =============================================================================
# SeaweedFS Variables
# =============================================================================

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
# Storage Configuration
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
  default     = "1000Gi" # 2 volume servers x 1000Gi = 2TB total
}

# When free space on a volume server drops below this percentage, the server marks
# EVERY volume it holds read-only and also refuses to compact. That second half is a
# deadlock: vacuum is the tool that would reclaim the space, and it is disabled by the
# same condition it would fix. On 2026-07-30 volume-1 sat at 6.99% free against the
# chart default of 7 and took cv.omoikane.coach down for 12h, while Thanos/Loki/Tempo
# writes failed silently (IFRNLLEI01PRD-2052).
# Held at 5 to keep a compaction margin below the ~7% the cluster operates near.
# Raise back toward 7 only after the volume PVs are expanded — see the issue.
variable "REDACTED_0a7b20f8" {
  description = "SeaweedFS volume server minFreeSpacePercent (below this, volumes go read-only AND compaction is refused)"
  type        = number
  default     = 5
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
  default     = "2Gi"
}

# -----------------------------------------------------------------------------
# filer.sync Resume-Offset Override (stale-checkpoint recovery)
# -----------------------------------------------------------------------------
# When the SeaweedFS change-log volumes referenced by a persisted sync offset
# get GC'd/compacted, filer.sync enters a tight retry loop ("failed to get next
# log entry ... volume N not found") and replication stalls. The upstream
# `-{a,b}.fromTsMs` flag overrides the persisted offset only when the override
# is greater than the stored value, so a one-time non-zero setting acts as a
# permanent recovery floor: once normal sync advances past it, the flag is
# silently no-op'd on every subsequent restart.
#
# IMPORTANT: SeaweedFS v4.01 has counter-intuitive flag semantics. Verified
# against upstream weed/command/filer_sync.go @ tag 4.01 (the a->b goroutine
# consumes syncOptions.bFromTsMs; the b->a goroutine consumes aFromTsMs):
#   -a.fromTsMs controls direction b->a  (sync where filer A is the SINK)
#   -b.fromTsMs controls direction a->b  (sync where filer B is the SINK)
# In our deployment, -a points at the local site filer and -b at the remote.
# So REDACTED_d063ac2f recovers REMOTE -> LOCAL replication, and
# REDACTED_88d37e0b recovers LOCAL -> REMOTE replication.
#
# Set to 0 (default) to use the persisted offset (normal operation).
# Set to a recent ms timestamp to skip past missing change-log entries.
# Reference event: 2026-05-05 b->a (GR->NL) reset past stale 2025-12-11 offset.

variable "REDACTED_d063ac2f" {
  description = "Override starting timestamp (ms) for filer.sync direction B->A (REMOTE->LOCAL — counter-intuitive upstream naming). 0 = use persisted offset."
  type        = number
  default     = 0
}

variable "REDACTED_88d37e0b" {
  description = "Override starting timestamp (ms) for filer.sync direction A->B (LOCAL->REMOTE — counter-intuitive upstream naming). 0 = use persisted offset."
  type        = number
  default     = 0
}
