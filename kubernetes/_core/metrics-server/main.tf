# =============================================================================
# metrics-server - resource metrics for `kubectl top` and the HPA API
# =============================================================================
# Declared here since 2026-09-15 (IFRNLLEI01PRD, MeshSat P2 closure). Before
# that it was out of band on two of the three sites and absent on the third:
# NL ran the upstream components.yaml applied by hand (labels `k8s-app`), GR a
# hand-run `helm install` of chart 3.13.0, and notrf01 had none, so
# `kubectl top` answered on two clusters and errored on the one that carries
# the MeshSat Hub. The PDB module already selected it by label, which is how
# the gap was noticed. Adoption on NL and GR was a delete of the hand-applied
# objects followed by the Atlantis apply: Helm refuses to own objects it did
# not create, and no HPA existed on any site, so the gap was `kubectl top`
# only.
#
# --kubelet-insecure-tls is what every hand-applied copy ran: the kubelets'
# serving certificates are self-signed on these clusters (kubeadm default, no
# serverTLSBootstrap), so the API server's CA cannot verify them.
# =============================================================================

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = var.namespace
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.metrics_server_version

  timeout = 300

  values = [yamlencode({
    args = [
      "--kubelet-insecure-tls",
    ]
    # The mirrored PDB module (_core/pod-disruption-budgets) carries the
    # budget, selected by the chart's own app.kubernetes.io/name label.
    podDisruptionBudget = { enabled = false }
    resources = {
      requests = { cpu = var.cpu_request, memory = var.memory_request }
      limits   = { memory = var.memory_limit }
    }
  })]
}
