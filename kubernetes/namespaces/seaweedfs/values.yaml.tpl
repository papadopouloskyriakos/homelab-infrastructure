***REMOVED***
# SeaweedFS Helm Values
***REMOVED***
# IMPORTANT: This chart has INCONSISTENT value handling:
# - affinity/tolerations/nodeSelector: STRINGS (using |)
# - resources: YAML OBJECTS (NOT strings!)
***REMOVED***

# Master servers - Raft consensus
master:
  replicas: 3
  port: 9333
  grpcPort: 19333
  persistence:
    enabled: true
    storageClass: "${storage_class}"
    size: "${master_storage_size}"
  # Resources as YAML object (NOT string)
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi
  # Affinity as STRING (using |)
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
  persistence:
    enabled: true
    storageClass: "${storage_class}"
    size: "${volume_storage_size}"
  # Resources as YAML object
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: "1"
      memory: 2Gi
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
  persistence:
    enabled: true
    storageClass: "${storage_class}"
    size: "${filer_storage_size}"
  # Resources as YAML object
  resources:
    requests:
      cpu: 200m
      memory: 512Mi
    limits:
      cpu: "1"
      memory: 1Gi
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
  enableSecurity: false

# Disable unused components
cosi:
  enabled: false
