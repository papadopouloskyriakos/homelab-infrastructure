# =============================================================================
# Import blocks — TRANSIENT. Delete each one once it has been applied.
# =============================================================================
# Same pattern as commit 7008f131 (adopting the live out-of-band monitoring
# grafana ingress): a resource that already exists in the cluster cannot simply
# be added to the config, because the create collides with the live object.
# An import block adopts it instead, so the plan reads "1 to import, 0 to add"
# and the apply converges in place rather than destroying anything.
#
# k8s/CLAUDE.md records that the previous imports.tf was "spent and deleted".
# Do the same here: once this has applied cleanly, remove the file.
#
# NL ONLY. This file is not part of the canonical mirror: the certificate
# resource itself is gated `count = var.acme_issuer_enabled ? 1 : 0`, which is
# false on the GR and NO twins, so there is nothing for them to import.
# -----------------------------------------------------------------------------

# wildcard-ellizg-com: hand-applied 2026-07-14, undeclared in every repo until
# now. Renewing normally (Ready, renewalTime 2026-09-12, notAfter 2026-10-12),
# so this adopts a healthy object — it must NOT be recreated or re-issued.
import {
  to = kubernetes_manifest.REDACTED_1c3fab10[0]
  id = "apiVersion=cert-manager.io/v1,kind=Certificate,namespace=cert-manager,name=wildcard-ellizg-com"
}
