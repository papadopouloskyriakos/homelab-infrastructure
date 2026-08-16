# ========================================================================
# Cilium Cluster Mesh - remote cluster connection
# ========================================================================
# REMOVED: ExternalSecret for cilium-clustermesh
#
# With KVStoreMesh enabled, Cilium agents connect to the LOCAL
# clustermesh-apiserver (clustermesh-apiserver.kube-system.svc:2379),
# NOT directly to the remote cluster.
#
# Architecture:
#   - cilium-clustermesh secret: Managed by Helm, points to LOCAL service
#   - cilium-kvstoremesh secret: Managed by Helm, contains remote cluster config
#   - hostAliases in clustermesh-apiserver: Resolves remote hostnames for KVStoreMesh
#
# The OpenBao secrets (secret/k8s/cilium/clustermesh-*) are NOT needed for
# the KVStoreMesh architecture. Remote cluster config is handled via Helm
# values in main.tf, fed from var.clustermesh_remote_cluster_name and
# var.REDACTED_9b1272d3:
#   clustermesh.config.clusters[].name
#   clustermesh.config.clusters[].ips
#   clustermesh.config.domain
# ========================================================================

# No resources needed - Helm manages all clustermesh secrets with KVStoreMesh
