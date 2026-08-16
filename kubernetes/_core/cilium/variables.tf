# ========================================================================
# Cilium Module Variables
# ========================================================================
# Defaults are the NL values; the GR root call overrides the site-specific
# ones (cluster_name/cluster_id, k8s_api_host, pod_cidr, BGP/LB addresses,
# clustermesh remote, hubble_hostname).
# ========================================================================

variable "cilium_version" {
  description = "Cilium Helm chart version"
  type        = string
  default     = "1.20.0"
}

variable "cluster_name" {
  description = "Cilium cluster name (must be unique across mesh)"
  type        = string
  default     = "nlcl01k8s"
}

variable "cluster_id" {
  description = "Cilium cluster ID (must be unique across mesh, 1-255)"
  type        = number
  default     = 1
}

variable "k8s_api_host" {
  description = "Kubernetes API server hostname"
  type        = string
  default     = "api-k8s.example.net"
}

variable "pod_cidr" {
  description = "Cluster-pool pod IPv4 CIDR (NL 10.0.0.0/16, GR 10.1.0.0/16 — must not overlap across the mesh)"
  type        = string
  default     = "10.0.0.0/16"
}

# ------------------------------------------------------------------------
# BGP Configuration
# ------------------------------------------------------------------------

variable "lb_pool_start" {
  description = "Start IP of LoadBalancer IP pool"
  type        = string
  default     = "10.0.X.X"
}

variable "lb_pool_stop" {
  description = "End IP of LoadBalancer IP pool"
  type        = string
  default     = "10.0.X.X"
}

variable "local_asn" {
  description = "Local BGP AS number for Kubernetes nodes"
  type        = number
  default     = 65001
}

variable "peer_asn" {
  description = "Peer BGP AS number (ASA/router)"
  type        = number
  default     = 65000
}

variable "peer_address" {
  description = "BGP peer IP address (ASA/router)"
  type        = string
  default     = "10.0.X.X"
}

# ------------------------------------------------------------------------
# Cluster Mesh - remote cluster connection
# ------------------------------------------------------------------------

variable "clustermesh_remote_cluster_name" {
  description = "Remote cluster name in ClusterMesh (NL peers with GR and vice versa)"
  type        = string
  default     = "grcl01k8s"
}

variable "REDACTED_9b1272d3" {
  description = "Remote clustermesh-apiserver endpoint as <ip>:<port>"
  type        = string
  default     = "10.0.X.X:2379"
}

# ------------------------------------------------------------------------
# Storage
# ------------------------------------------------------------------------

variable "spire_storage_class" {
  description = "Storage class for SPIRE server data"
  type        = string
  default     = "nfs-client"
}

# ------------------------------------------------------------------------
# Monitoring
# ------------------------------------------------------------------------

variable "REDACTED_46d876c8" {
  description = "Enable ServiceMonitors for Prometheus (requires REDACTED_d8074874)"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------
# Hubble UI
# ------------------------------------------------------------------------

variable "hubble_hostname" {
  description = "Ingress hostname for the Hubble UI"
  type        = string
  default     = "nl-hubble.example.net"
}
