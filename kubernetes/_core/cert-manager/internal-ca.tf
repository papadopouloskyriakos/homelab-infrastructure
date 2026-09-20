# An internal certificate authority for cluster-internal TLS (MESHSAT-1194,
# posture V12): the first consumer is the NATS cluster (route) port in
# meshsat-hub, whose members authenticate with a shared credential since
# 2026-09-18 but still speak plaintext to each other. Nothing outside the
# cluster ever sees these certificates, so no ACME and no public CA -- a
# self-signed root, kept in cert-manager's namespace, issuing through a CA
# ClusterIssuer that any namespace may request from.
#
# Bootstrap chain, the standard cert-manager shape:
#   REDACTED_0aeb0676 (ClusterIssuer, SelfSigned)
#     -> meshsat-internal-ca (Certificate, isCA, 10 years, in cert-manager ns)
#       -> meshsat-internal-ca (ClusterIssuer, kind CA, from that secret)
# Leaf certificates are short (90 days) and rotated by cert-manager; the pods
# that mount them reload on change (the NATS config reloader watches the files).

resource "kubernetes_manifest" "REDACTED_3d7a4cce" {
  count      = var.internal_ca_enabled ? 1 : 0
  depends_on = [helm_release.cert_manager]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata   = { name = "REDACTED_0aeb0676" }
    spec       = { selfSigned = {} }
  }
}

resource "kubernetes_manifest" "internal_ca_certificate" {
  count      = var.internal_ca_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.REDACTED_3d7a4cce]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "meshsat-internal-ca"
      namespace = kubernetes_namespace.cert_manager.metadata[0].name
    }
    spec = {
      isCA       = true
      commonName = "MeshSat internal CA"
      secretName = "meshsat-internal-ca"
      duration   = "87600h" # 10 years; the leaves rotate, the root does not
      privateKey = { algorithm = "ECDSA", size = 256 }
      issuerRef  = { name = "REDACTED_0aeb0676", kind = "ClusterIssuer", group = "cert-manager.io" }
    }
  }
}

resource "kubernetes_manifest" "internal_ca_issuer" {
  count      = var.internal_ca_enabled ? 1 : 0
  depends_on = [kubernetes_manifest.internal_ca_certificate]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata   = { name = "meshsat-internal-ca" }
    spec       = { ca = { secretName = "meshsat-internal-ca" } }
  }
}

# count{} was added 2026-09-20 so this file can be canonical in all three repos
# while only the site with a consumer instantiates it. moved{} keeps notrf01's
# existing state on the new [0] addresses; on NL/GR the sources do not exist in
# state and these are no-ops.
moved {
  from = kubernetes_manifest.REDACTED_3d7a4cce
  to   = kubernetes_manifest.REDACTED_3d7a4cce[0]
}

moved {
  from = kubernetes_manifest.internal_ca_certificate
  to   = kubernetes_manifest.internal_ca_certificate[0]
}

moved {
  from = kubernetes_manifest.internal_ca_issuer
  to   = kubernetes_manifest.internal_ca_issuer[0]
}
