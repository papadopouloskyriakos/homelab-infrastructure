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

variable "minio_storage_size" {
  type    = string
  default = "100Gi"
}

variable "minio_version" {
  type    = string
  default = "latest"
}

variable "domain" {
  type = string
}
