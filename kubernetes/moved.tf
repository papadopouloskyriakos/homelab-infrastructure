# State-address migrations for the NL<->GR mirror canonicalization.
# moved blocks are declarative and idempotent; prune once both repos have
# applied them.

moved {
  from = module.well_known.kubernetes_manifest.REDACTED_72c40b12
  to   = module.well_known.kubernetes_manifest.REDACTED_72c40b12[0]
}
