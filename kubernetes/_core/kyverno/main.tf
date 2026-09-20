# Kyverno — per-workload admission policy (MESHSAT-1204, chosen 2026-09-17).
#
# WHY IT EXISTS. Pod Security Admission is NAMESPACE-scoped and that is the
# whole problem: meshsat-hub holds two workloads that legitimately need
# privileges PSA `baseline` forbids (meshsat-edge-relay: hostNetwork + hostPorts;
# wg-easy: NET_ADMIN), so the namespace can never `enforce`, and CIS 5.2 sits at
# 0.5 for a Kubernetes granularity limit rather than a gap in the design. PSA's
# only exemption mechanism is cluster-wide (by namespace, user or runtimeClass),
# never per-workload. Kyverno expresses exactly the per-workload exception PSA
# cannot, and it also closes CIS 5.5 (Extensible Admission Control), which is at
# 0.0 — so it moves two scorecard rows, not one.
#
# ⚠ PHASE 1 IS AUDIT-ONLY, BY DESIGN. Two per-POLICY fields make that true and
# both must stay on every ClusterPolicy until its report has been watched
# against real admissions (checked against the 3.9.1 chart: the chart itself
# sets neither — Kyverno registers its webhooks at runtime from the policies,
# so there is no Helm value for this and a value here would be silently ignored):
#   - spec.failurePolicy: Ignore — if the admission controller is down, pods are
#     admitted, not refused. A misconfigured or crashlooping engine must not be
#     able to stop pod creation for EVERY namespace on the cluster, including
#     the CNPG cluster holding the gapless invoice series.
#   - spec.validationFailureAction: Audit — PolicyReports then show what WOULD
#     have been refused, and each policy is flipped to Enforce individually once
#     its report has been clean for real traffic.
# This is the same discipline as ModSecurity DetectionOnly -> On, and for the
# same reason: an engine that has never been observed to refuse the right thing
# is indistinguishable from one that refuses everything.
#
# NOT installed: the reports server, the cleanup controller and background
# scanning are off. They are useful later; they are attack surface and CPU now,
# and a satellite site with 155 GiB shared roots does not need a second store.
resource "helm_release" "kyverno" {
  name             = "kyverno"
  namespace        = var.namespace
  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  version          = var.kyverno_version
  create_namespace = true
  timeout          = 600
  # wait = true here on purpose, unlike cilium: an admission webhook that is
  # registered but not yet serving is the one state that can wedge the cluster,
  # so the apply should not report success until the controller is Ready.
  wait = true

  values = [yamlencode({
    admissionController = {
      replicas = var.replicas
      container = {
        resources = {
          requests = { cpu = "50m", memory = "128Mi" }
          limits   = { memory = "512Mi" }
        }
      }
    }
    config = {
      webhooks = {
        namespaceSelector = {
          # Never adjudicate the control plane's own namespaces or Kyverno itself:
          # a policy bug there is a self-inflicted lockout.
          matchExpressions = [{
            key      = "kubernetes.io/metadata.name"
            operator = "NotIn"
            values   = ["kube-system", "kube-public", "kube-node-lease", var.namespace, "cilium-spire"]
          }]
        }
      }
    }
    features = {
      admissionReports = { enabled = true }
      policyReports    = { enabled = true }
      # Background scan is what turns "what would be refused" into a
      # PolicyReport for pods that already exist; without it Audit mode only
      # ever reports admissions that happen after the policy landed.
      backgroundScan = { enabled = true }
    }
    backgroundController = { enabled = false }
    cleanupController    = { enabled = false }
    # Read-only ghcr credential for verifyImages (see verify-images.tf).
    existingImagePullSecrets = ["registry-meshsat"]

    reportsController = {
      enabled  = true
      replicas = 1
      resources = {
        requests = { cpu = "20m", memory = "64Mi" }
        limits   = { memory = "256Mi" }
      }
    }
    # No securityContext override: the chart's admissionController.container
    # .securityContext already runs as 65534 with drop ALL, no privilege
    # escalation, a read-only root and RuntimeDefault seccomp — i.e. it passes
    # the restricted profile it will judge others against. Verified in the
    # 3.9.1 values.yaml rather than assumed; a top-level `securityContext` key,
    # which is what a first draft had, is not a chart value at all and would
    # have been ignored without error.
  })]
}
