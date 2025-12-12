***REMOVED***
# Variables for Monitoring Module
***REMOVED***

variable "common_labels" {
  description = "Common labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "1095d"
}

variable "REDACTED_6a2724e6" {
  description = "Prometheus PVC size"
  type        = string
  default     = "200Gi"
}

# NOTE: grafana_admin_password removed - now sourced from OpenBao via ExternalSecret

variable "grafana_storage_size" {
  description = "Grafana PVC size"
  type        = string
  default     = "20Gi"
}
***REMOVED***
# Thanos Variables (add to existing variables.tf)
***REMOVED***

# -----------------------------------------------------------------------------
# Thanos Version & Image
# -----------------------------------------------------------------------------
variable "thanos_version" {
  description = "Thanos container image version"
  type        = string
  default     = "v0.37.2"
}

# -----------------------------------------------------------------------------
# Site Configuration (for Cluster Mesh)
# -----------------------------------------------------------------------------
variable "site_code" {
  description = "Short site identifier (nl or gr)"
  type        = string
  default     = "nl"
}

variable "remote_site_code" {
  description = "Short identifier for remote site"
  type        = string
  default     = "gr"
}

# -----------------------------------------------------------------------------
# S3 Object Storage Configuration
# -----------------------------------------------------------------------------
variable "thanos_bucket_name" {
  description = "SeaweedFS bucket name for Thanos blocks"
  type        = string
  default     = "thanos-nl" # GR site uses "thanos-gr"
}

variable "thanos_s3_endpoint" {
  description = "SeaweedFS S3 endpoint"
  type        = string
  default     = "seaweedfs-filer.seaweedfs.svc.cluster.local:8333"
}

variable "thanos_openbao_secret_path" {
  description = "OpenBao secret path for Thanos S3 credentials"
  type        = string
  default     = "REDACTED_3baa4bde"
}

# -----------------------------------------------------------------------------
***REMOVED*** Configuration
# -----------------------------------------------------------------------------
variable "thanos_storage_class" {
  description = "Storage class for Thanos PVCs"
  type        = string
  default     = "REDACTED_4f3da73d"
}

variable "thanos_store_storage_size" {
  description = "Storage size for Thanos Store Gateway cache"
  type        = string
  default     = "20Gi"
}

variable "REDACTED_fd3fdc21" {
  description = "Storage size for Thanos Compactor working directory"
  type        = string
  default     = "50Gi"
}

# -----------------------------------------------------------------------------
# Retention Configuration
# -----------------------------------------------------------------------------
variable "thanos_retention_raw" {
  description = "Retention for raw resolution data"
  type        = string
  default     = "30d"
}

variable "thanos_retention_5m" {
  description = "Retention for 5-minute downsampled data"
  type        = string
  default     = "120d"
}

variable "thanos_retention_1h" {
  description = "Retention for 1-hour downsampled data"
  type        = string
  default     = "365d"
}

# -----------------------------------------------------------------------------
# Replica Configuration
# -----------------------------------------------------------------------------
variable "REDACTED_7a9cbd6c" {
  description = "Number of Thanos Query replicas"
  type        = number
  default     = 2
}

variable "REDACTED_63d297ac" {
  description = "Number of Thanos Store Gateway replicas"
  type        = number
  default     = 2
}

# -----------------------------------------------------------------------------
# Resource Configuration - Query
# -----------------------------------------------------------------------------
variable "REDACTED_30f368b4" {
  description = "CPU request for Thanos Query"
  type        = string
  default     = "100m"
}

variable "REDACTED_0cfb68ff" {
  description = "Memory request for Thanos Query"
  type        = string
  default     = "256Mi"
}

variable "REDACTED_e802136b" {
  description = "CPU limit for Thanos Query"
  type        = string
  default     = "500m"
}

variable "REDACTED_bd9f12e7" {
  description = "Memory limit for Thanos Query"
  type        = string
  default     = "1Gi"
}

# -----------------------------------------------------------------------------
# Resource Configuration - Store Gateway
# -----------------------------------------------------------------------------
variable "REDACTED_04db0b8f" {
  description = "CPU request for Thanos Store Gateway"
  type        = string
  default     = "100m"
}

variable "REDACTED_4e106564" {
  description = "Memory request for Thanos Store Gateway"
  type        = string
  default     = "512Mi"
}

variable "REDACTED_cd0ed526" {
  description = "CPU limit for Thanos Store Gateway"
  type        = string
  default     = "1"
}

variable "REDACTED_b0098842" {
  description = "Memory limit for Thanos Store Gateway"
  type        = string
  default     = "2Gi"
}

# -----------------------------------------------------------------------------
# Resource Configuration - Compactor
# -----------------------------------------------------------------------------
variable "REDACTED_ec35f0bf" {
  description = "CPU request for Thanos Compactor"
  type        = string
  default     = "100m"
}

variable "REDACTED_2e15f782" {
  description = "Memory request for Thanos Compactor"
  type        = string
  default     = "512Mi"
}

variable "REDACTED_4851f004" {
  description = "CPU limit for Thanos Compactor"
  type        = string
  default     = "1"
}

variable "REDACTED_7479c0fd" {
  description = "Memory limit for Thanos Compactor"
  type        = string
  default     = "2Gi"
}

# -----------------------------------------------------------------------------
# Remote Site Configuration
# -----------------------------------------------------------------------------
variable "thanos_remote_store_endpoint" {
  description = "Remote site's Thanos Store Gateway endpoint"
  type        = string
  default     = "dnssrv+_grpc._tcp.thanos-store-gr.monitoring.svc.cluster.local"
}

# -----------------------------------------------------------------------------
# Ingress Configuration
# -----------------------------------------------------------------------------
variable "REDACTED_844fade0" {
  description = "Enable ingress for Thanos Query UI"
  type        = bool
  default     = true
}

variable "REDACTED_928c2d3a" {
  description = "Hostname for Thanos Query ingress"
  type        = string
  default     = "nl-thanos.example.net"
}
***REMOVED***
# Network Monitoring - ADD TO variables.tf
***REMOVED***

variable "snmp_community" {
  description = "SNMP community string for ASA firewalls"
  type        = string
  sensitive   = true
}

***REMOVED***
# FRR Exporter Targets
***REMOVED***

variable "frr_route_reflector_targets" {
  description = "FRR exporter targets for route reflector VMs"
  type        = list(string)
  default = [
    "10.0.X.X:9342", # NL-FRR01
    "10.0.X.X:9342", # NL-FRR02
    "10.0.X.X:9342", # GR-FRR01
    "10.0.X.X:9342", # GR-FRR02
  ]
}

variable "frr_edge_targets" {
  description = "FRR exporter targets for edge nodes"
  type        = list(string)
  default = [
    "10.255.2.11:9342", # CH Edge
    "10.255.3.11:9342", # NO Edge
  ]
}

***REMOVED***
# IPsec Exporter Targets
***REMOVED***

variable "ipsec_edge_targets" {
  description = "IPsec exporter targets for edge nodes"
  type        = list(string)
  default = [
    "10.255.2.11:9536", # CH Edge
    "10.255.3.11:9536", # NO Edge
  ]
}

***REMOVED***
# SNMP Targets
***REMOVED***

variable "snmp_asa_targets" {
  description = "ASA firewall SNMP targets"
  type        = list(string)
  default = [
    "10.0.X.X", # NL ASA
    "10.0.X.X", # GR ASA
  ]
}

***REMOVED***
# Prometheus Ingress
***REMOVED***

variable "REDACTED_4c06acbb" {
  description = "Enable ingress for Prometheus"
  type        = bool
  default     = true
}

variable "prometheus_hostname" {
  description = "Hostname for Prometheus ingress"
  type        = string
  default     = "nl-prometheus.example.net"
}
