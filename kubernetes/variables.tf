variable "pihole_password" {
  description = "Pi-hole web admin password"
  type        = string
  sensitive   = true
  default     = "changeme123"
}
