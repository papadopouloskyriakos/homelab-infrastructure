variable "common_labels" {
  type = map(string)
}

variable "prometheus_retention" {
  type    = string
  default = "30d"
}

variable "REDACTED_6a2724e6" {
  type    = string
  default = "200Gi"
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}

variable "grafana_storage_size" {
  type    = string
  default = "20Gi"
}
