# Pod Security Standards as Kyverno policies, from the project's own chart
# (kyverno-policies, same version line as the engine). Phase 1: EVERY policy is
# Audit with failurePolicy Ignore and NO exclusions. That is deliberate:
#   - Audit + background scan produces a PolicyReport per namespace listing
#     what WOULD be refused, on existing pods as well as new ones. The
#     exceptions (edge-relay's hostNetwork, wg-easy's NET_ADMIN, apprise's
#     startup useradd, tor's key-seeding init) are then written from what the
#     reports show, not from memory -- a control is not shipped until
#     something has been observed to fail because of it.
#   - Ignore: a crashlooping engine must not be able to stop pod creation for
#     every namespace on the cluster.
# Phase 2 flips individual policies to Enforce ONLY in the MeshSat namespaces
# (validationFailureActionOverrides), leaving the rest of the cluster in Audit.
#
# policyType is the legacy ClusterPolicy rather than the CEL ValidatingPolicy
# the chart now defaults to: exclusions are per policy with a label selector,
# which is what per-workload exceptions need, and the deprecation is a
# migration for later, not a reason to hand-write fifteen CEL policies now.
locals {
  # One workload, one namespace, by the label its controller stamps on pods.
  # Autogen carries the same selector onto the controller kinds.
  exclude_edge_relay = { any = [{ resources = { kinds = ["Pod"], namespaces = ["meshsat-hub"], selector = { matchLabels = { "app.kubernetes.io/name" = "meshsat-edge-relay" } } } }] }
  exclude_wg_easy    = { any = [{ resources = { kinds = ["Pod"], namespaces = ["meshsat-hub"], selector = { matchLabels = { "app.kubernetes.io/name" = "wg-easy" } } } }] }
  exclude_wg_easy_tor = { any = [
    { resources = { kinds = ["Pod"], namespaces = ["meshsat-hub"], selector = { matchLabels = { "app.kubernetes.io/name" = "wg-easy" } } } },
    { resources = { kinds = ["Pod"], namespaces = ["meshsat-hub"], selector = { matchLabels = { "app.kubernetes.io/name" = "tor" } } } },
  ] }
  exclude_wg_easy_tor_apprise = { any = [
    { resources = { kinds = ["Pod"], namespaces = ["meshsat-hub"], selector = { matchLabels = { "app.kubernetes.io/name" = "wg-easy" } } } },
    { resources = { kinds = ["Pod"], namespaces = ["meshsat-hub"], selector = { matchLabels = { "app.kubernetes.io/name" = "tor" } } } },
    { resources = { kinds = ["Pod"], namespaces = ["meshsat-hub"], selector = { matchLabels = { "app.kubernetes.io/name" = "apprise" } } } },
  ] }
}

resource "helm_release" "kyverno_policies" {
  name       = "kyverno-policies"
  namespace  = var.namespace
  repository = "https://kyverno.github.io/kyverno/"
  chart      = "kyverno-policies"
  version    = var.kyverno_version
  wait       = true
  timeout    = 300

  depends_on = [helm_release.kyverno]

  values = [yamlencode({
    policyType          = "ClusterPolicy"
    policyKind          = "ClusterPolicy"
    podSecurityStandard = "restricted"
    podSecuritySeverity = "medium"

    validationFailureAction           = "Audit"
    failurePolicy                     = "Ignore"
    background                        = true
    validationAllowExistingViolations = true

    # Phase 1c: every exclusion below is one the PolicyReports named on
    # 2026-09-18 and that was then measured on the pod, never guessed. Each
    # is pinned to ONE workload by label in ONE namespace, so it exempts that
    # workload and nothing else; a new pod with the same defect is refused.
    policyExclude = {
      # The front door: a hostNetwork DaemonSet with hostPorts, because
      # Cilium's NodePort does not answer traffic arriving through the VPS
      # xfrm tunnels. Architectural; the path out is a namespace of its own.
      "REDACTED_07a81da5" = local.exclude_edge_relay
      "disallow-host-ports"      = local.exclude_edge_relay
      # wg-easy: NET_ADMIN + NET_RAW as uid 0 (iptables, a WireGuard
      # interface). Measured with the image; no narrower set works.
      "disallow-capabilities" = local.exclude_wg_easy
      # tor's seed-identity init runs as uid 0 with CHOWN/DAC_OVERRIDE/FOWNER
      # to hand the onion key to uid 100; apprise's image does a useradd at
      # startup; wg-easy as above.
      "REDACTED_50d055ab" = local.exclude_wg_easy_tor_apprise
      "require-run-as-nonroot"       = local.exclude_wg_easy_tor_apprise
      "require-run-as-non-root-user" = local.exclude_wg_easy_tor
    }

    # Phase 2: ENFORCE, but only where this programme owns the workloads. The
    # rest of the cluster stays Audit (its findings are real -- kube-system,
    # velero, seaweedfs -- but they are not this programme's to break).
    validationFailureActionOverrides = {
      all = [{
        action     = "Enforce"
        namespaces = ["meshsat-hub", "meshsat-hub-db", "meshsat-tak", "meshsat-tak-db"]
      }]
    }
  })]
}
