***REMOVED***
# SeaweedFS - Distributed Object Storage
***REMOVED***
# Replaces MinIO with HA cross-site capable S3 storage
# S3 API: http://seaweedfs-filer.seaweedfs.svc.cluster.local:8333
***REMOVED***

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------
resource "kubernetes_namespace" "seaweedfs" {
  metadata {
    name = "seaweedfs"
    labels = merge(var.common_labels, {
      "app.kubernetes.io/name" = "seaweedfs"
    })
  }
}

# -----------------------------------------------------------------------------
# S3 Credentials Secret (via External Secrets Operator)
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "seaweedfs_s3_credentials" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "seaweedfs-s3-config"
      namespace = kubernetes_namespace.seaweedfs.metadata[0].name
      labels    = var.common_labels
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "openbao"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "seaweedfs-s3-config"
        creationPolicy = "Owner"
        deletionPolicy = "Retain"
      }
      data = [
        {
          secretKey = "admin_access_key_id"
          remoteRef = {
            key      = "secret/REDACTED_65baa84d"
            property = "admin-access-key"
          }
        },
        {
          secretKey = "admin_secret_access_key"
          remoteRef = {
            key      = "secret/REDACTED_65baa84d"
            property = "admin-secret-key"
          }
        }
      ]
    }
  }
}

# -----------------------------------------------------------------------------
# SeaweedFS Helm Release
# -----------------------------------------------------------------------------
resource "helm_release" "seaweedfs" {
  name       = "seaweedfs"
  namespace  = kubernetes_namespace.seaweedfs.metadata[0].name
  repository = "https://seaweedfs.github.io/seaweedfs/helm"
  chart      = "seaweedfs"
  version    = var.REDACTED_c1342204

  timeout = 600
  wait    = true

  depends_on = [kubernetes_manifest.seaweedfs_s3_credentials]

  set = [
    # =========================================================================
    # MASTER SERVERS - Raft consensus (3 replicas)
    # =========================================================================
    { name = "master.replicas", value = "3" },
    { name = "master.port", value = "9333" },
    { name = "master.grpcPort", value = "19333" },
    { name = "master.persistence.enabled", value = "true" },
    { name = "master.persistence.storageClass", value = var.storage_class },
    { name = "master.persistence.size", value = var.master_storage_size },
    { name = "master.resources.requests.cpu", value = "100m" },
    { name = "master.resources.requests.memory", value = "256Mi" },
    { name = "master.resources.limits.cpu", value = "500m" },
    { name = "master.resources.limits.memory", value = "512Mi" },
    
    # Master node affinity - local nodes only
    { name = "master.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key", value = "topology.kubernetes.io/region" },
    { name = "master.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator", value = "In" },
    { name = "master.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]", value = var.node_region },
    
    # Master anti-affinity - spread across nodes
    { name = "master.affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].labelSelector.matchLabels.app\\.kubernetes\\.io/component", value = "master" },
    { name = "master.affinity.podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution[0].topologyKey", value = "kubernetes.io/hostname" },

    # =========================================================================
    # VOLUME SERVERS - Data storage (2 replicas)
    # =========================================================================
    { name = "volume.replicas", value = "2" },
    { name = "volume.port", value = "8080" },
    { name = "volume.grpcPort", value = "18080" },
    { name = "volume.persistence.enabled", value = "true" },
    { name = "volume.persistence.storageClass", value = var.storage_class },
    { name = "volume.persistence.size", value = var.volume_storage_size },
    { name = "volume.resources.requests.cpu", value = "200m" },
    { name = "volume.resources.requests.memory", value = "512Mi" },
    { name = "volume.resources.limits.cpu", value = "1" },
    { name = "volume.resources.limits.memory", value = "2Gi" },
    
    # Volume node affinity - local nodes only
    { name = "volume.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key", value = "topology.kubernetes.io/region" },
    { name = "volume.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator", value = "In" },
    { name = "volume.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]", value = var.node_region },
    
    # Volume anti-affinity - spread across nodes (preferred)
    { name = "volume.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight", value = "100" },
    { name = "volume.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchLabels.app\\.kubernetes\\.io/component", value = "volume" },
    { name = "volume.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey", value = "kubernetes.io/hostname" },

    # =========================================================================
    # FILER SERVERS - S3 API Gateway (2 replicas)
    # =========================================================================
    { name = "filer.replicas", value = "2" },
    { name = "filer.port", value = "8888" },
    { name = "filer.grpcPort", value = "18888" },
    { name = "filer.persistence.enabled", value = "true" },
    { name = "filer.persistence.storageClass", value = var.storage_class },
    { name = "filer.persistence.size", value = var.filer_storage_size },
    { name = "filer.resources.requests.cpu", value = "200m" },
    { name = "filer.resources.requests.memory", value = "512Mi" },
    { name = "filer.resources.limits.cpu", value = "1" },
    { name = "filer.resources.limits.memory", value = "1Gi" },
    
    # Filer node affinity - local nodes only
    { name = "filer.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key", value = "topology.kubernetes.io/region" },
    { name = "filer.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator", value = "In" },
    { name = "filer.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0]", value = var.node_region },
    
    # Filer anti-affinity - spread across nodes (preferred)
    { name = "filer.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].weight", value = "100" },
    { name = "filer.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.labelSelector.matchLabels.app\\.kubernetes\\.io/component", value = "filer" },
    { name = "filer.affinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution[0].podAffinityTerm.topologyKey", value = "kubernetes.io/hostname" },

    # =========================================================================
    # S3 API Configuration
    # =========================================================================
    { name = "filer.s3.enabled", value = "true" },
    { name = "filer.s3.port", value = "8333" },
    { name = "filer.s3.enableAuth", value = "true" },
    { name = "filer.s3.existingConfigSecret", value = "seaweedfs-s3-config" },

    # =========================================================================
    # Global Settings
    # =========================================================================
    { name = "global.replicationPlacment", value = "001" },
    { name = "global.enableSecurity", value = "false" },

    # =========================================================================
    # Disable unused components
    # =========================================================================
    { name = "cosi.enabled", value = "false" },
  ]
}

# -----------------------------------------------------------------------------
# ServiceMonitor for Prometheus
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "REDACTED_f7ae41ec" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "seaweedfs"
      namespace = kubernetes_namespace.seaweedfs.metadata[0].name
      labels = merge(var.common_labels, {
        release = "monitoring"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "seaweedfs"
        }
      }
      endpoints = [
        {
          port     = "metrics"
          path     = "/metrics"
          interval = "30s"
        }
      ]
    }
  }

  depends_on = [helm_release.seaweedfs]
}
