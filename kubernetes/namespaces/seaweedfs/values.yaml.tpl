# =============================================================================
# SeaweedFS Helm Values
# =============================================================================
# IMPORTANT CHART QUIRKS:
# 1. affinity/tolerations/nodeSelector: STRINGS (using |)
# 2. resources: YAML OBJECTS (NOT strings!)
# 3. persistence: uses data/dataDirs structure, NOT persistence.enabled!
# =============================================================================

# Master servers - Raft consensus (metadata only)
master:
  replicas: 3
  port: 9333
  grpcPort: 19333
  # Replication: 001 = 1 copy on another server in same rack
  defaultReplication: "001"
  # Persistence uses data/logs structure, NOT persistence.enabled
  data:
    type: "REDACTED_33feff97"
    size: "${master_storage_size}"
    storageClass: "${storage_class}"
  logs:
    type: "emptyDir"
  # Resources as YAML object
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi
  # Affinity as STRING
  affinity: |
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: topology.kubernetes.io/region
                operator: In
                values:
                  - "${node_region}"
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app.kubernetes.io/component: master
          topologyKey: kubernetes.io/hostname

# Volume servers - Data storage
volume:
  replicas: 2
  port: 8080
  grpcPort: 18080
  # Volume servers use dataDirs array, NOT persistence.enabled
  dataDirs:
    - name: data
      type: "REDACTED_33feff97"
      size: "${volume_storage_size}"
      storageClass: "${storage_class}"
      maxVolumes: 0  # auto-configure based on disk space
  idx: {}
  logs: {}
  # Resources as YAML object — 4Gi limit needed for compaction of large thanos/loki volumes (700MB+)
  resources:
    requests:
      cpu: 200m
      memory: 1Gi
    limits:
      cpu: "1"
      memory: 4Gi
  # Affinity as STRING
  affinity: |
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: topology.kubernetes.io/region
                operator: In
                values:
                  - "${node_region}"
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchLabels:
                app.kubernetes.io/component: volume
            topologyKey: kubernetes.io/hostname

# Filer servers - S3 API Gateway
filer:
  replicas: 2
  port: 8888
  grpcPort: 18888
  # Match master replication setting
  defaultReplicaPlacement: "001"
  # Filer uses data structure, NOT persistence.enabled
  data:
    type: "REDACTED_33feff97"
    size: "${filer_storage_size}"
    storageClass: "${storage_class}"
  logs:
    type: "emptyDir"
  # Resources as YAML object
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: "1"
      # 2Gi -> 4Gi: filer-0 OOMKilled x5 under sync/compaction spikes (IFRNLLEI01PRD-1113, 2026-06-17)
      # 4Gi -> 4.5Gi 2026-06-24: filer-0 OOMKilled again at 04:40 (node pressure + sync spike), small headroom
      memory: 4.5Gi
  # Affinity as STRING
  affinity: |
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: topology.kubernetes.io/region
                operator: In
                values:
                  - "${node_region}"
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchLabels:
                app.kubernetes.io/component: filer
            topologyKey: kubernetes.io/hostname
  s3:
    enabled: true
    port: 8333
    enableAuth: true
    existingConfigSecret: "seaweedfs-s3-config"

# Global settings
global:
  replicationPlacment: "001"
  enableReplication: true
  enableSecurity: false

# Disable unused components
cosi:
  enabled: false
s3:
  enabled: false
