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

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_cad964aa
  to   = module.cert_manager.kubernetes_manifest.REDACTED_cad964aa[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.letsencrypt_prod
  to   = module.cert_manager.kubernetes_manifest.letsencrypt_prod[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.wildcard_cert
  to   = module.cert_manager.kubernetes_manifest.wildcard_cert[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_501d268e
  to   = module.cert_manager.kubernetes_manifest.REDACTED_501d268e[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_c7e1769b
  to   = module.cert_manager.kubernetes_manifest.REDACTED_c7e1769b[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_52b9873f
  to   = module.cert_manager.kubernetes_manifest.REDACTED_52b9873f[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_b497be54
  to   = module.cert_manager.kubernetes_manifest.REDACTED_b497be54[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_8e7851d8
  to   = module.cert_manager.kubernetes_manifest.REDACTED_8e7851d8[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_cbe107a9
  to   = module.cert_manager.kubernetes_manifest.REDACTED_cbe107a9[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_62f27f39
  to   = module.cert_manager.kubernetes_manifest.REDACTED_62f27f39[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_a6df7556
  to   = module.cert_manager.kubernetes_manifest.REDACTED_a6df7556[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_56d1f068
  to   = module.cert_manager.kubernetes_manifest.REDACTED_56d1f068[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_af7e0fe5
  to   = module.cert_manager.kubernetes_manifest.REDACTED_af7e0fe5[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_93434549
  to   = module.cert_manager.kubernetes_manifest.REDACTED_93434549[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_5e8d96e9
  to   = module.cert_manager.kubernetes_manifest.REDACTED_5e8d96e9[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_79a1dc6b
  to   = module.cert_manager.kubernetes_manifest.REDACTED_79a1dc6b[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_b082092e
  to   = module.cert_manager.kubernetes_manifest.REDACTED_b082092e[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_8ca647ff
  to   = module.cert_manager.kubernetes_manifest.REDACTED_8ca647ff[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_233e2f0b
  to   = module.cert_manager.kubernetes_manifest.REDACTED_233e2f0b[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_7a64a702
  to   = module.cert_manager.kubernetes_manifest.REDACTED_7a64a702[0]
}

moved {
  from = module.cert_manager.kubernetes_manifest.REDACTED_13c92cba
  to   = module.cert_manager.kubernetes_manifest.REDACTED_13c92cba[0]
}

moved {
  from = module.cert_manager.kubernetes_role.awx_cert_reader
  to   = module.cert_manager.kubernetes_role.awx_cert_reader[0]
}

moved {
  from = module.cert_manager.REDACTED_80c0cfc6.awx_cert_reader
  to   = module.cert_manager.REDACTED_80c0cfc6.awx_cert_reader[0]
}

moved {
  from = module.monitoring.kubernetes_manifest.tg_ingest_token
  to   = module.monitoring.kubernetes_manifest.tg_ingest_token[0]
}
