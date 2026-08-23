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
variable "storage_class_retain" {
  description = "Retain-policy storage class for SeaweedFS PVCs"
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
# Node Selection
# -----------------------------------------------------------------------------
variable "node_region" {
  description = "Region label to select local nodes only"
  type        = string
  default     = "nl-lei"
}

# -----------------------------------------------------------------------------
# Ingress Hostnames
# -----------------------------------------------------------------------------
variable "master_hostname" {
  description = "Hostname for the SeaweedFS master web UI ingress"
  type        = string
  default     = "nl-seaweedfs.example.net"
}

variable "s3_hostname" {
  description = "Hostname for the SeaweedFS S3 API ingress"
  type        = string
  default     = "nl-s3.example.net"
}

# -----------------------------------------------------------------------------
# Observability
# -----------------------------------------------------------------------------
variable "repository_label" {
  description = "Value of the 'repository' label on monitoring resources (which repo manages this cluster)"
  type        = string
  default     = "REDACTED_25022d4e"
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
  # 128Mi -> 512Mi 2026-07-31 (OMOIKANE-1547): 14d peak working set 528Mi during sync catch-up;
  # the request must cover it so the scheduler reserves what the container actually holds.
  default = "512Mi"
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

# -----------------------------------------------------------------------------
# Filer metadata store selection (IFRNLLEI01PRD-2605)
#
# "leveldb2" = the chart-default per-pod embedded store. "postgres2" = the
# shared CNPG cluster below (values.yaml.tpl wires WEED_POSTGRES2_* env).
# The per-pod leveldb2 topology (2 filers + async meta-aggregator) is
# upstream-documented as unsupported for shared-truth HA and is the root
# enabler of the 2026 object-corruption class (IFRNLLEI01PRD-2090).
# -----------------------------------------------------------------------------
variable "filer_store" {
  description = "Filer metadata store: leveldb2 (embedded per pod) or postgres2 (shared CNPG cluster)"
  type        = string
  default     = "leveldb2"
  validation {
    condition     = contains(["leveldb2", "postgres2"], var.filer_store)
    error_message = "filer_store must be leveldb2 or postgres2."
  }
}

variable "filer_meta_db_enabled" {
  description = "Create the seaweedfs-filer-meta CNPG cluster (requires cnpg_enabled CRDs; enable BEFORE flipping filer_store)"
  type        = bool
  default     = false
}

variable "REDACTED_5c69828e" {
  description = "S3 endpoint for filer-meta barman backups — MUST be the OTHER site's S3 (never the S3 this DB serves); empty disables backup"
  type        = string
  default     = ""
}

variable "REDACTED_5514fdd1" {
  description = "Bucket on REDACTED_5c69828e for barman base+WAL"
  type        = string
  default     = ""
}

variable "canary_s3_endpoint" {
  description = "S3 endpoint the read canary tests — the path this site's real consumers use (NL/GR: the public ingress; notrf01: the cluster-local service, no-s3 has no DNS)"
  type        = string
  default     = "http://seaweedfs-s3.seaweedfs.svc.cluster.local:8333"
}
