variable "common_labels" {
  description = "Labels applied to every resource"
  type        = map(string)
  default     = {}
}

variable "namespace" {
  description = "Namespace of the gateway; also the ONLY namespace allowed to reference the dedicated ClusterSecretStore."
  type        = string
  default     = "backup-gateway"
}

variable "replicas" {
  description = "Gateway replicas. Stateless; 2 on production sites, 1 where the cluster is being kept small."
  type        = number
  default     = 2
}

variable "image" {
  description = "rclone image, pinned. Must be a release whose `serve s3` streams multipart uploads (>= 1.70)."
  type        = string
  default     = "docker.io/rclone/rclone:1.75.1"
}

variable "canary_image" {
  description = "Python image for the canary; standard library only."
  type        = string
  default     = "docker.io/library/python:3.12-alpine"
}

variable "allowed_namespaces" {
  description = "Namespaces whose pods may reach the gateway on 8080 (every consumer must be listed; the checklist in main.tf)."
  type        = list(string)
  default     = ["velero", "monitoring", "logging", "seaweedfs"]
}

variable "openbao_address" {
  description = "OpenBao address for the dedicated ClusterSecretStore"
  type        = string
}

variable "openbao_ca_cert" {
  description = "OpenBao CA, base64 PEM (same value the general store uses)"
  type        = string
  sensitive   = true
}

variable "eso_auth_mount_path" {
  description = "Kubernetes auth mount for this site (kubernetes / kubernetes-gr / kubernetes-notrf01)"
  type        = string
}

variable "openbao_role" {
  description = "OpenBao role bound to the backup-gateway-eso ServiceAccount; the only role that can read the Hetzner credential."
  type        = string
  default     = "backup-gateway"
}

variable "hetzner_secret_path" {
  description = "OpenBao KV path holding access_key, secret_key, endpoint, bucket for Hetzner Object Storage"
  type        = string
  default     = "REDACTED_5fad4bd0"
}

variable "hetzner_region" {
  description = "Hetzner Object Storage location, used as the S3 region string"
  type        = string
  default     = "fsn1"
}

variable "crypt_secret_path" {
  description = "OpenBao KV path holding the rclone-obscured crypt password and password2 (salt)"
  type        = string
  default     = "REDACTED_0f78fd04"
}

variable "auth_secret_path" {
  description = "OpenBao KV path holding the gateway's LOCAL S3 key pair (access_key, secret_key) that consumers use"
  type        = string
  default     = "REDACTED_218b2888"
}

variable "canary_schedule" {
  description = "Cron schedule of the write/read/delete canary through the gateway"
  type        = string
  default     = "41 */6 * * *"
}

variable "assert_schedule" {
  description = "Cron schedule of the Hetzner layout assertion (the rule's enforcement)"
  type        = string
  default     = "11 */6 * * *"
}

variable "cpu_request" {
  type    = string
  default = "250m"
}

variable "memory_request" {
  type    = string
  default = "768Mi"
}

variable "memory_limit" {
  description = "Each in-flight upload holds chunk_size x upload_concurrency (64 MiB) plus out-of-order multipart parts; ten concurrent streams fit in 2 GiB."
  type        = string
  default     = "2Gi"
}
