variable "metallb_chart_version" {
  description = "MetalLB Helm chart version"
  type        = string
  default     = "0.14.9"
}

variable "metallb_ip_range" {
  description = "IP range(s) for LoadBalancer services"
  type        = list(string)
  default     = ["10.0.X.X-10.0.X.X"]
}

variable "metallb_asn" {
  description = "BGP AS number for MetalLB"
  type        = number
  default     = 65001
}

variable "asa_asn" {
  description = "BGP AS number for Cisco ASA"
  type        = number
  default     = 65000
}

variable "asa_peer_ip" {
  description = "Cisco ASA IP for BGP peering"
  type        = string
  default     = "10.0.X.X"
}
