# =============================================================================
# Variables for Monitoring Module
# =============================================================================

variable "common_labels" {
  description = "Common labels to apply to resources (root supplies environment/managed-by/repository/site)"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Site Identity
# -----------------------------------------------------------------------------
variable "site" {
  description = "Short site identifier for metric labels (nl or gr)"
  type        = string
  default     = "nl"
}

variable "cluster_name" {
  description = "Cluster name for Prometheus externalLabels (Thanos deduplication)"
  type        = string
  default     = "nl"
}

variable "node_region" {
  description = "topology.kubernetes.io/region value for node selection (nl-lei or gr-skg)"
  type        = string
  default     = "nl-lei"
}

# -----------------------------------------------------------------------------
# Prometheus / Alertmanager / Grafana
# -----------------------------------------------------------------------------
variable "prometheus_retention" {
  description = "Prometheus LOCAL TSDB retention. Long-term storage is Thanos's job, not Prometheus's (see k8s/CLAUDE.md — the old 1095d default here was never true of the local TSDB and misled a capacity investigation on 2026-07-30)."
  type        = string
  default     = "24h"
}

variable "REDACTED_6a2724e6" {
  description = "Prometheus PVC size"
  type        = string
  default     = "200Gi"
}

variable "REDACTED_cdb3d821" {
  description = "StorageClass for the Prometheus volumeClaimTemplate. MUST match the live StatefulSet template per side — volumeClaimTemplates are immutable, so a mismatch fails the helm upgrade rather than resizing/reclassing."
  type        = string
  default     = "REDACTED_4f3da73d"
}

variable "alertmanager_storage_class" {
  description = "StorageClass for the Alertmanager volumeClaimTemplate (same immutability caveat as REDACTED_cdb3d821)."
  type        = string
  default     = "REDACTED_4f3da73d"
}

variable "alertmanager_storage_size" {
  description = "Alertmanager PVC size (volumeClaimTemplate — immutable live; keep matching the deployed value)"
  type        = string
  default     = "10Gi"
}

variable "prometheus_remote_write_url" {
  description = "Prometheus remote_write target URL. \"\" (default) omits the remoteWrite key from the rendered Helm values entirely — the historical behavior."
  type        = string
  default     = ""
}

variable "REDACTED_923cce14" {
  description = "Enable prometheusSpec.enableRemoteWriteReceiver. false (default) omits the key from the rendered Helm values entirely — the historical behavior."
  type        = bool
  default     = false
}

# NOTE: grafana_admin_password removed - now sourced from OpenBao via ExternalSecret

variable "grafana_storage_size" {
  description = "Grafana PVC size"
  type        = string
  default     = "20Gi"
}

# -----------------------------------------------------------------------------
# Alertmanager Receivers (site-gated: empty string disables the receiver+route)
# -----------------------------------------------------------------------------
variable "alert_webhook_url" {
  description = "n8n Prometheus Alert Receiver webhook URL (default receiver webhook-n8n)"
  type        = string
  default     = "https://n8n.example.net/webhook/prometheus-alert"
}

variable "twilio_bridge_url" {
  description = "Twilio SMS bridge URL for the tier-1 paging path. Empty string disables the twilio-tier1 receiver and route."
  type        = string
  default     = "http://10.0.X.X:9106/alert"
}

variable "tg_webhook_url" {
  description = "Territory Grounder ingest URL (NL-estate single instance). Empty string disables the webhook-tg receiver/route AND the tg-ingest-token ExternalSecret + Alertmanager secret mount."
  type        = string
  default     = "https://territory-grounder.example.net/api/v1/ingest/prometheus-alertmanager"
}

variable "wal_healer_webhook_url" {
  description = "n8n WAL-healer webhook URL for PrometheusTSDBCompactionsFailing self-heal. Empty string disables the webhook-wal-healer receiver and route."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Thanos Version & Image
# -----------------------------------------------------------------------------
variable "thanos_version" {
  description = "Thanos container image version (also used by the Prometheus sidecar)"
  type        = string
  default     = "v0.42.4"
}

# -----------------------------------------------------------------------------
# Site Configuration (for Cluster Mesh)
# -----------------------------------------------------------------------------
variable "site_code" {
  description = "Short site identifier (nl or gr) — used in cross-site Thanos service NAMES; do not change on a live cluster"
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
  description = "SeaweedFS bucket name for Thanos blocks (thanos-nl / thanos-gr)"
  type        = string
  default     = "thanos-nl"
}

variable "thanos_s3_endpoint" {
  description = "SeaweedFS S3 endpoint"
  type        = string
  default     = "seaweedfs-s3.seaweedfs.svc.cluster.local:8333"
}

variable "thanos_openbao_secret_path" {
  description = "OpenBao secret path for Thanos S3 credentials"
  type        = string
  default     = "REDACTED_3baa4bde"
}

# -----------------------------------------------------------------------------
# Storage Configuration
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
variable "REDACTED_52f9638b" {
  description = "Include the remote site's store + sidecar endpoints in Thanos Query args (requires ClusterMesh). false omits the two --endpoint args; true renders the historical arg list byte-identically."
  type        = bool
  default     = true
}

variable "thanos_remote_store_endpoint" {
  description = "Remote site's Thanos Store Gateway endpoint"
  type        = string
  default     = "dnssrv+_grpc._tcp.thanos-store-gr.monitoring.svc.cluster.local"
}

variable "REDACTED_d312035b" {
  description = "Remote site's Thanos Sidecar endpoint (via Cluster Mesh)"
  type        = string
  default     = "dnssrv+_grpc._tcp.thanos-sidecar-gr.monitoring.svc.cluster.local"
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

variable "grafana_ingress_enabled" {
  description = "Enable ingress for Grafana"
  type        = bool
  default     = true
}

variable "grafana_hostname" {
  description = "Hostname for Grafana ingress"
  type        = string
  default     = "grafana.example.net"
}

variable "goldpinger_hostname" {
  description = "Hostname for Goldpinger ingress"
  type        = string
  default     = "goldpinger.example.net"
}

# =============================================================================
# Network Monitoring
# =============================================================================

variable "snmp_community" {
  description = "SNMP community string for ASA firewalls"
  type        = string
  sensitive   = true
}

variable "asa_snmp_enabled" {
  description = "Deploy the ASA SNMP exporter resources (snmp-exporter.tf) and emit the snmp-asa scrape job. false = site has no ASA; true renders the historical config byte-identically."
  type        = bool
  default     = true
}

variable "snmp_asa_target" {
  description = "Local-site ASA firewall SNMP target IP (each cluster scrapes ONLY its own ASA)"
  type        = string
  default     = "10.0.X.X"
}

variable "snmp_asa_device" {
  description = "Device label for the local-site ASA SNMP scrape job"
  type        = string
  default     = "nlfw01"
}

variable "snmp_syno_target" {
  description = "Local-site Synology NAS SNMP target IP (IFRNLLEI01PRD-2605). Empty string = site has no NAS to scrape; the snmp-syno job is not emitted."
  type        = string
  default     = ""
}

variable "snmp_syno_device" {
  description = "Device label for the local-site NAS SNMP scrape job"
  type        = string
  default     = "nl-nas01"
}

# =============================================================================
# FRR / IPsec Exporter Targets
# =============================================================================

variable "frr_route_reflector_targets" {
  description = "FRR exporter targets for route reflector VMs"
  type        = list(string)
  default = [
    "10.0.X.X:9342", # NL-FRR01 (DMZ)
    "10.0.X.X:9342", # NL-FRR02 (DMZ)
    "10.0.X.X:9342",  # GR-FRR01 (DMZ)
    "10.0.X.X:9342",  # GR-FRR02 (DMZ)
  ]
}

variable "frr_edge_targets" {
  description = "FRR exporter targets for edge nodes"
  type        = list(string)
  default = [
    "10.255.2.11:9342", # CH Edge
    "10.255.3.11:9342", # NO Edge
    "10.255.6.11:9342", # TX Edge
  ]
}

variable "ipsec_edge_targets" {
  description = "IPsec exporter targets for edge nodes"
  type        = list(string)
  default = [
    "10.255.2.11:9536", # CH Edge
    "10.255.3.11:9536", # NO Edge
    "10.255.6.11:9536", # TX Edge
  ]
}

# =============================================================================
# Estate Scrape Jobs (NL-only estate targets — see scrape-estate.tf)
# =============================================================================

variable "estate_scrape_enabled" {
  description = "Emit the NL-estate additionalScrapeConfigs jobs (chatops, omoikane, crowdsec, fisha, iot, edge node_exporter, frr-dmz). Exactly one cluster (NL) scrapes these targets; enabling on both would double-scrape the estate."
  type        = bool
  default     = true
}

# =============================================================================
# etcd Scrape Endpoints (control-plane node IPs)
# =============================================================================

variable "etcd_endpoints" {
  description = "Control-plane node IPs for the kubeEtcd scrape (client port :2379, mTLS)"
  type        = list(string)
  default     = ["10.0.X.X", "10.0.X.X", "10.0.X.X"]
}

variable "grafana_storage_class" {
  description = "Grafana PVC storage class (RWX-capable for 2 replicas; single-replica sites can use a local RWO class)"
  type        = string
  default     = "nfs-client"
}

variable "grafana_replicas" {
  description = "Grafana replica count (2 with RWX storage; 1 on RWO/local-PV sites)"
  type        = number
  default     = 2
}

variable "node_exporter_port" {
  description = "In-cluster node-exporter port (9100 = chart default, rendered only when different — for hosts already serving 9100)"
  type        = number
  default     = 9100
}
