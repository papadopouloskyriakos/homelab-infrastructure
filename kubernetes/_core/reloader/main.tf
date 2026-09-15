# =============================================================================
# Reloader - roll a workload when a Secret or ConfigMap it references changes
# =============================================================================
# Every Deployment that reads a Secret as env at start keeps the old value in
# memory until something restarts it. With External Secrets repopulating
# Secrets from OpenBao on a timer, a rotation therefore "did nothing" until a
# person ran `kubectl rollout restart` -- the MeshSat Hub sat 121 minutes with
# the right Secret mounted and the wrong key in use (MESHSAT-1150). Reloader
# watches Secrets and ConfigMaps and, for a workload annotated
# `reloader.stakater.com/auto: "true"`, bumps a pod-template annotation so the
# controller performs an ordinary RollingUpdate that honours the PDB.
#
# Opt-in only (autoReloadAll=false): a workload that wants this says so in its
# own manifest. The `annotations` strategy is chosen over the default env-var
# one so the rollout shows up as a template change and not as a phantom env.
# =============================================================================

resource "helm_release" "reloader" {
  name             = "reloader"
  namespace        = var.namespace
  repository       = "https://stakater.github.io/stakater-charts"
  chart            = "reloader"
  version          = var.reloader_version
  create_namespace = true

  timeout = 300

  values = [yamlencode({
    reloader = {
      autoReloadAll    = false
      reloadOnCreate   = false
      syncAfterRestart = true
      reloadStrategy   = "annotations"
      watchGlobally    = true
      deployment = {
        resources = {
          requests = { cpu = var.cpu_request, memory = var.memory_request }
          limits   = { memory = var.memory_limit }
        }
      }
    }
  })]
}
