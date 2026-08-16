# =============================================================================
# Argo CD Variables
# =============================================================================

variable "common_labels" {
  description = "Common labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "site" {
  description = "Site identifier (nl/gr) — stamped as a label on module-managed ExternalSecrets"
  type        = string
  default     = "nl"
}

variable "argocd_hostname" {
  description = "Public FQDN for the Argo CD UI/API (global.domain, ingress host, notification URLs)"
  type        = string
  default     = "argocd.example.net"
}

variable "REDACTED_be8b31fd" {
  description = <<-EOT
    Argo CD Helm chart version. 7.7.10 is what BOTH clusters actually run
    (verified live 2026-08-16 via helm.sh/chart labels on argocd-server in
    NL and GR). NOTE: this module previously defaulted to 7.8.28 while both
    roots overrode it to 7.7.10 — the 7.8.28 figure in k8s/CLAUDE.md is
    stale. Upgrading the chart is a deliberate separate change, not part of
    the NL<->GR mirror no-op.
  EOT
  type        = string
  default     = "7.7.10"
}

variable "argocd_nodeport" {
  description = "NodePort for Argo CD HTTPS access"
  type        = number
  default     = 30085
}

variable "REDACTED_84146aee" {
  description = "Enable ingress for Argo CD"
  type        = bool
  default     = true
}

variable "REDACTED_649263f1" {
  description = "Run Argo CD server in insecure mode"
  type        = bool
  default     = false
}

variable "REDACTED_7ce225ce" {
  description = "Number of Argo CD server replicas (NL 2, GR 1 — DR site)"
  type        = number
  default     = 2
}

variable "argocd_repo_server_replicas" {
  description = "Number of Argo CD repo server replicas (NL 2, GR 1 — DR site)"
  type        = number
  default     = 2
}

variable "REDACTED_035cbec1" {
  description = "Enable Argo CD notifications controller"
  type        = bool
  default     = true
}

variable "REDACTED_2f84acaa" {
  description = "Prefix for Matrix notification messages (NL \"[ArgoCD]\", GR \"[ArgoCD-GR]\")"
  type        = string
  default     = "[ArgoCD]"
}

variable "argocd_dex_enabled" {
  description = "Enable Dex for SSO integration"
  type        = bool
  default     = false
}

variable "argocd_repositories" {
  description = "Git repositories for Argo CD to manage (configs.repositories helm value)"
  type        = map(any)
  default     = {}
}

variable "argocd_ssh_known_hosts" {
  description = "SSH known hosts for Git repositories"
  type        = string
  default     = ""
}

variable "argocd_matrix_token" {
  description = "Matrix bot access token for Argo CD notifications webhook"
  type        = string
  sensitive   = true
  default     = ""
}

variable "REDACTED_9360424f" {
  description = <<-EOT
    Repository-credential ExternalSecrets, one per map entry. Key = the
    ExternalSecret / target Secret name (a live k8s object name — do not
    rename). Value:
      openbao_path — OpenBao KV path holding the credential.
      url_override — optional. When null, username/password/url/type are all
        pulled from openbao_path (the secret's own `url` decides which repo
        it matches). When set, only username/password are pulled and the
        secret's url/type are templated to url_override/"git" — needed when
        one GitLab token must match a DIFFERENT repo URL than the one stored
        in OpenBao (Argo CD matches repository secrets by EXACT URL; see
        IFRNLLEI01PRD-2374, GR velero deploy 2026-08-16).
  EOT
  type = map(object({
    openbao_path = string
    url_override = optional(string)
  }))
  default = {
    "gitlab-repo-creds" = {
      openbao_path = "REDACTED_79b33008"
    }
  }
}
