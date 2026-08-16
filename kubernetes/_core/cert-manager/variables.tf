variable "chart_version" {
  description = "cert-manager Helm chart version"
  type        = string
  default     = "1.17.1"
}

variable "REDACTED_46d876c8" {
  description = "Enable Prometheus ServiceMonitor"
  type        = bool
  default     = true
}

variable "acme_email" {
  description = "Email for Let's Encrypt notifications"
  type        = string
  default     = "viqufzhj@mail.example.net"
}

variable "acme_issuer_enabled" {
  description = "Role gate. true (NL): run the ACME issuer stack — ClusterIssuer, Cloudflare ExternalSecret, all Certificates, PushSecret to OpenBao, AWX RBAC. false (GR): consume the wildcard cert from OpenBao via ExternalSecret instead."
  type        = bool
  default     = true
}

variable "install_crds" {
  description = <<-EOT
    Whether the Helm release renders/owns the cert-manager CRDs (crds.enabled).
    ASYMMETRIC-BY-HISTORY — do NOT align the two sites:
      NL = false: CRDs were installed out-of-band at bootstrap and are NOT
                  helm-owned; enabling would make helm try to adopt/own them.
      GR = true:  the release was installed with crds.enabled=true, so the
                  CRDs are helm-owned there; disabling would drop them from
                  the rendered manifest set on the next upgrade (deletion is
                  only prevented by crds.keep=true, pinned in main.tf).
  EOT
  type        = bool
  default     = false
}

variable "wildcard_cert_path" {
  description = "Path to wildcard certificate in OpenBao (consumer role: ExternalSecret remoteRef.key). The issuer-side PushSecret writes the ESO-relative form REDACTED_b018f6b2 of this same path."
  type        = string
  default     = "REDACTED_2812d784"
}
