# ========================================================================
# Cilium BGP Module Variables
# ========================================================================

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
