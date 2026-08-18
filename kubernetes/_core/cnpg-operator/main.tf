# =============================================================================
# CloudNativePG (CNPG) operator
# =============================================================================
# Manages the PostgreSQL DB tier. This module installs ONLY the operator + CRDs
# (platform). The actual `Cluster` CRs (the omoikane databases + data) are
# app-tier and live in the daemon repo / are applied by the app-migration
# session — never TF-managed here, per the platform-only convention.
#
# HA of the OPERATOR: replicaCount>1 + leader election + soft anti-affinity, so
# a node loss never leaves the estate without a reconciler. (Note CNPG is
# designed so running Clusters survive operator downtime via the in-pod instance
# manager — operator HA is defence in depth, not a data-availability dependency.)
# HA of the DATABASE is a property of each Cluster CR (instances>=3, synchronous
# replication, pod anti-affinity across the DB-tier nodes) — the ready-to-use HA
# Cluster template is documented in the running site's k8s/CLAUDE.md (DB tier).

resource "kubernetes_namespace" "cnpg_system" {
  metadata {
    name = "cnpg-system"
    labels = merge(var.common_labels, {
      "app.kubernetes.io/managed-by" = "opentofu"
    })
  }
}

resource "helm_release" "cnpg" {
  name       = "cnpg"
  namespace  = kubernetes_namespace.cnpg_system.metadata[0].name
  repository = "https://cloudnative-pg.github.io/charts"
  chart      = "cloudnative-pg"
  version    = var.chart_version

  values = [yamlencode({
    replicaCount = var.operator_replicas
    crds         = { create = true }

    monitoring = {
      podMonitorEnabled = var.REDACTED_46d876c8
      grafanaDashboard  = { create = false }
    }

    # HA: spread operator replicas across nodes.
    affinity = {
      podAntiAffinity = {
        preferredDuringSchedulingIgnoredDuringExecution = [{
          weight = 100
          podAffinityTerm = {
            topologyKey = "kubernetes.io/hostname"
            labelSelector = {
              matchLabels = { "app.kubernetes.io/name" = "cloudnative-pg" }
            }
          }
        }]
      }
    }

    resources = {
      requests = { cpu = "50m", memory = "128Mi" }
      limits   = { memory = "256Mi" }
    }
  })]
}
