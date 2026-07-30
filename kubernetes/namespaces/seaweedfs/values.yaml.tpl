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
  # The master's background vacuum only compacts a volume whose garbage ratio
  # exceeds this. The chart default is null -> weed's built-in 0.3, and NO volume
  # in this cluster has ever exceeded 30% garbage, so automatic GC has been a
  # permanent no-op since install. ~68 GiB of reclaimable garbage accumulated
  # (thanos-nl 54.9 GiB @ 11.1%, loki 11.0 GiB @ 13.0%) and the disks reached 92-93%,
  # which tripped minFreeSpacePercent and took the S3 write path down for 12h
  # (IFRNLLEI01PRD-2052). 0.10 sits below both collections' observed ratios so GC
  # actually reclaims. Compaction is throttled by the volume servers' -compactionMBps=50.
  garbageThreshold: "0.10"
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
  # Below this free-space percentage the server marks all volumes read-only AND
  # refuses compaction — see the variable comment in variables.tf.
  minFreeSpacePercent: ${REDACTED_0a7b20f8}
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
      # 512Mi -> 2Gi 2026-07-31 (OMOIKANE-1547): the filers were being KERNEL-OOM-killed ~20x/day
      # at ~2GiB actual use — far below their own limit — because the 512Mi request let the
      # scheduler pack node02/03 to 94% on memory the filers already held. 14d peak working set:
      # filer-0 2.86Gi, filer-1 1.40Gi. Request must cover the real working set so the scheduler
      # reserves it; the limit below stays the burst ceiling.
      memory: 2Gi
    limits:
      cpu: "1"
      # 2Gi -> 4Gi: filer-0 OOMKilled x5 under sync/compaction spikes (IFRNLLEI01PRD-1113, 2026-06-17)
      # 4Gi -> 4.5Gi 2026-06-24: filer-0 OOMKilled again at 04:40 (node pressure + sync spike), small headroom
      memory: 4.5Gi
  # GOMEMLIMIT: soft Go heap ceiling (~0.8x the 4.5Gi hard limit) so the runtime GC reclaims
  # BEFORE the cgroup OOM-kills the filer. Root fix for the recurring OOM (filer-0 restartCount=12,
  # 2026-06-25): spiky Go heap at the hard cap under the reactive-resume delete storm + thanos
  # multipart uploads + cross-site filer.sync. Raising the HARD limit alone never bounded heap
  # GROWTH (whack-a-mole 2Gi->4Gi->4.5Gi); the 4.5Gi limit stays as the true safety ceiling.
  extraEnvironmentVars:
    GOMEMLIMIT: "3686MiB"
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
