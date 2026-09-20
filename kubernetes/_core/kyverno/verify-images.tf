# Image provenance at admission (CIS 5.5, MESHSAT-1216 -> MESHSAT-1204).
#
# CI signs every Hub image BY DIGEST with a key pair and attests its SBOM
# (meshsat-hub .gitlab-ci.yml, job `sign`); the public half is committed there
# as cosign.pub and repeated here verbatim. This policy makes the CLUSTER check
# that signature when a Hub pod is admitted, so an image that did not come
# out of that pipeline -- or was re-tagged after it -- is refused at admission.
# It went in as Audit first, like every other policy in this module, and was
# flipped to Enforce only once the reports said PASS on the real image and
# FAIL on an unsigned one (see below).
#
# Kyverno reads the signature manifests from ghcr with the same read-only pull
# credential the Hub pods use, delivered by ExternalSecret from OpenBao into
# this namespace. Measured on 2026-09-18: the engine-wide
# `existingImagePullSecrets` (--imagePullSecrets) is loaded at start but the
# VERIFIER does not use it -- every fetch went out anonymous and ghcr answered
# UNAUTHORIZED -- and only the rule's own `imageRegistryCredentials` makes it
# authenticate. Both are set; the rule-level one is the load-bearing one.
#
# Measured before Enforce, in Audit, on the live cluster:
#   - the running Hub image (cosign-3 bundle as an OCI referrer, key pair, no
#     transparency log): verdict pass, with type SigstoreBundle;
#   - an image carrying ONLY that bundle (no legacy .sig tag): pass -- so CI
#     stays on cosign 3 and its bundle output;
#   - a pre-signing digest of the same image: verdict fail.
# That is the evidence the Enforce below rests on.

resource "kubernetes_manifest" "REDACTED_f4f340c4" {
  count = var.REDACTED_da51e7e0 ? 1 : 0
  manifest = {
    apiVersion = "external-secrets.io/v1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "registry-meshsat"
      namespace = var.namespace
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef  = { name = "openbao", kind = "ClusterSecretStore" }
      target = {
        name           = "registry-meshsat"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
        template = {
          type = "kubernetes.io/dockerconfigjson"
          data = { ".dockerconfigjson" = "{\"auths\":{\"ghcr.io\":{\"auth\":\"{{ .ghcr_auth }}\"}}}" }
        }
      }
      data = [{
        secretKey = "ghcr_auth"
        remoteRef = { key = "REDACTED_8d834264", property = "ghcr_auth" }
      }]
    }
  }
  depends_on = [helm_release.kyverno]
}

resource "kubernetes_manifest" "REDACTED_7410777b" {
  count = var.REDACTED_da51e7e0 ? 1 : 0
  # The policy was patched by hand with kubectl while it was being measured
  # in Audit (type, credential); those patches left a second field manager on
  # the object and the first Enforce apply hit a conflict. OpenTofu owns this
  # object; take the fields back.
  field_manager {
    force_conflicts = true
  }
  manifest = {
    apiVersion = "kyverno.io/v1"
    kind       = "ClusterPolicy"
    metadata = {
      name = "REDACTED_1357bd2a"
      annotations = {
        "policies.kyverno.io/title"       = "Verify the MeshSat Hub image signature"
        "policies.kyverno.io/category"    = "Software Supply Chain Security"
        "policies.kyverno.io/severity"    = "high"
        "policies.kyverno.io/subject"     = "Pod"
        "policies.kyverno.io/description" = "Every ghcr.io/meshsat/meshsat-hub image admitted into meshsat-hub must carry a cosign signature by the MeshSat CI signing key (cosign.pub in the meshsat-hub repository). Enforced since 2026-09-18 after the Audit reports proved pass on the real image and fail on an unsigned one."
      }
    }
    spec = {
      background            = false
      failurePolicy         = "Ignore"
      webhookTimeoutSeconds = 30
      rules = [{
        name  = "REDACTED_a9acb6b4"
        match = { any = [{ resources = { kinds = ["Pod"], namespaces = ["meshsat-hub"] } }] }
        verifyImages = [{
          # The Hub image ONLY: by tag or by digest. A bare "meshsat-hub*" also
          # matched ghcr.io/meshsat/meshsat-hub-verify, the nightly's image,
          # which is not signed -- caught in Audit on the first nightly after
          # the policy landed, before it could refuse the nightly under Enforce.
          imageReferences = ["ghcr.io/meshsat/meshsat-hub:*", "ghcr.io/meshsat/meshsat-hub@*"]
          type            = "SigstoreBundle"
          failureAction   = "Enforce"
          required        = true
          # The rule-level credential the verifier actually uses (see header).
          imageRegistryCredentials = { secrets = ["registry-meshsat"] }
          # kustomize pins the digest already; a mutation here would only make
          # Argo see drift on every pod.
          mutateDigest = false
          verifyDigest = true
          attestors = [{
            count = 1
            entries = [{
              keys = {
                publicKeys = var.REDACTED_9ffc3663
                rekor      = { ignoreTlog = true }
                ctlog      = { ignoreSCT = true }
              }
            }]
          }]
        }]
      }]
    }
  }
  depends_on = [helm_release.kyverno_policies]
}

# count{} added 2026-09-20 (IFRNLLEI01PRD-2876) so this module can be canonical
# in all three repos while only notrf01 instantiates the cosign policy. The
# policy below is the ONLY Enforce rule in this module - everything in
# policies.tf is Audit - and it is scoped to ghcr.io/meshsat/meshsat-hub, an
# image that exists only at notrf01. NL/GR therefore run kyverno AUDIT-ONLY.
moved {
  from = kubernetes_manifest.REDACTED_f4f340c4
  to   = kubernetes_manifest.REDACTED_f4f340c4[0]
}

moved {
  from = kubernetes_manifest.REDACTED_7410777b
  to   = kubernetes_manifest.REDACTED_7410777b[0]
}
