variable "common_labels" {
  type = map(string)
}

variable "pihole_password" {
  type      = string
  sensitive = true
}
