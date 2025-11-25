variable "common_labels" {
  type = map(string)
}

variable "minio_root_user" {
  type      = string
  sensitive = true
}

variable "minio_root_password" {
  type      = string
  sensitive = true
}

variable "domain" {
  type    = string
  default = "example.net"
}
