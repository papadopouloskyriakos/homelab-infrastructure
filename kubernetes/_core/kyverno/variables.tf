variable "namespace" {
  description = "Kubernetes namespace for Kyverno"
  type        = string
  default     = "kyverno"
}

variable "kyverno_version" {
  description = "Kyverno Helm chart version (kyverno.github.io/kyverno; 3.9.1 = app v1.19.1, released 2026-09-10)"
  type        = string
  default     = "3.9.1"
}

variable "replicas" {
  description = "Admission controller replicas. 1 on a satellite site; the webhook has failurePolicy Ignore for the first phase, so a single replica cannot block pod creation cluster-wide while it restarts."
  type        = number
  default     = 1
}
variable "REDACTED_9ffc3663" {
  description = "cosign public key that signs ghcr.io/meshsat/meshsat-hub (meshsat-hub repo, cosign.pub; private half in OpenBao secret/ci-no/apps/meshsat-hub/cosign)"
  type        = string
  default     = <<-EOT
    -----BEGIN PUBLIC KEY-----
    MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEam06dcyKDKx5Dimg9L+ylZiQ4ryC
    wZiyZDgkjTYWKKIOCA4CB22LD+PoOOAremJaljHMbegmPKjPSKzG4fd1mw==
    -----END PUBLIC KEY-----
  EOT
}

variable "REDACTED_da51e7e0" {
  description = "Create the cosign image-verification policy and its registry pull secret. This is the module's ONLY Enforce policy (everything in policies.tf is Audit) and it is scoped to ghcr.io/meshsat/meshsat-hub, which exists only at notrf01. Keep false elsewhere: kyverno then runs audit-only, which is the whole point of enabling it on a cluster that has not validated an enforcing policy."
  type        = bool
  default     = false
}
