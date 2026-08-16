# State-address migrations for the NL<->GR mirror canonicalization.
# moved blocks are declarative and idempotent; prune once both repos have
# applied them.

moved {
  from = module.well_known.kubernetes_manifest.REDACTED_72c40b12
  to   = module.well_known.kubernetes_manifest.REDACTED_72c40b12[0]
}

moved {
  from = module.gatus.kubernetes_manifest.gatus_certificate
  to   = module.gatus.kubernetes_manifest.gatus_certificate[0]
}

moved {
  from = module.argocd.kubernetes_manifest.gitlab_repo_creds
  to   = module.argocd.kubernetes_manifest.repo_credentials["gitlab-repo-creds"]
}
