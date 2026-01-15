# Kubernetes Cluster Context (Full)
<!-- 
LLM INSTRUCTIONS:
- Comprehensive cluster snapshot for deep analysis/troubleshooting
- Health Summary: Check first for cluster state
- Anomalies: Items requiring immediate attention
- Workload Map: Deployment → Service → Ingress relationships
- Resource Analysis: Capacity planning data
- Network Policies: Zero-trust security posture
-->

**Generated:** 2026-01-15 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | HEALTHY | ✅ |
| Unhealthy Pods | 0 | ✅ |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 692 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.18.4 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 143 |

### Node Details (with Taints & Labels)

#### nlk8s-ctrl01
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 3795Mi
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-ctrl02
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 3996Mi
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-ctrl03
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 3886092Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node01
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006756Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node02
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006748Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node03
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006740Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node04
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006752Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01


---

## Anomalies & Issues

### Unhealthy Pods
_None - all pods are Running or Completed_

### High Restart Pods (>3 restarts)
- awx/awx-operator-controller-manager-846b99bbd-t9589: 8 restarts
- cert-manager/cert-manager-75944f484-4v6qh: 9 restarts
- cert-manager/cert-manager-cainjector-56b4cf957-s7xd9: 7 restarts
- cilium-spire/spire-agent-xwbn2: 8 restarts
- kube-system/cilium-22zgh: 8 restarts
- kube-system/cilium-envoy-mmfnj: 8 restarts
- kube-system/cilium-operator-6b94496fcd-l6cjl: 73 restarts
- kube-system/etcd-nlk8s-ctrl01: 11 restarts
- kube-system/etcd-nlk8s-ctrl02: 38 restarts
- kube-system/etcd-nlk8s-ctrl03: 4 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 70 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 55 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 12 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 83 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 21 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 69 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 20 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 21 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 18 restarts
- kube-system/tetragon-mdsn9: 16 restarts
- logging/loki-0: 6 restarts
- logging/promtail-rxt6j: 8 restarts
- monitoring/bgpalerter-596d7b756b-pxcb5: 7 restarts
- monitoring/goldpinger-4fvxd: 9 restarts
- monitoring/goldpinger-qs5xt: 4 restarts
- monitoring/monitoring-grafana-9ccf6f977-mhjwg: 26 restarts
- monitoring/monitoring-grafana-9ccf6f977-w47db: 23 restarts
- monitoring/monitoring-kube-state-metrics-74d579585b-6cprn: 10 restarts
- monitoring/monitoring-prometheus-node-exporter-d5wkz: 8 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956swwjx: 13 restarts
- seaweedfs/seaweedfs-filer-0: 19 restarts
- seaweedfs/seaweedfs-filer-1: 16 restarts
- synology-csi/synology-csi-node-zch7n: 16 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE     LAST SEEN   TYPE      REASON      OBJECT                                  MESSAGE
kube-system   22m         Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Readiness probe failed: HTTP probe failed with statuscode: 500
```

---

## Workload Map

### Namespace: `argocd`

1/- **Deployment: argocd-applicationset-controller** (1) → Svc:argocd-applicationset-controller (ClusterIP) → Ingress:argocd.example.net
1/- **Deployment: argocd-redis** (1) → Svc:argocd-redis (ClusterIP) → Ingress:argocd.example.net
2/- **Deployment: argocd-repo-server** (2) → Svc:argocd-repo-server (ClusterIP) → Ingress:argocd.example.net
2/- **Deployment: argocd-server** (2) → Svc:argocd-server (NodePort) → Ingress:argocd.example.net
- **StatefulSet: argocd-application-controller** (1/1)

**Secrets:**
- ExternalSecret: argocd-redis (SecretSynced)
- ExternalSecret: gitlab-common-creds (SecretSynced)
- ExternalSecret: gitlab-repo-creds (SecretSynced)

### Namespace: `awx`

1/- **Deployment: awx-operator-controller-manager** (1) → Ingress:awx.example.net
1/- **Deployment: my-awx-task** (1) → Ingress:awx.example.net
1/- **Deployment: my-awx-web** (1) → Svc:my-awx-service (NodePort) → Ingress:awx.example.net
- **StatefulSet: my-awx-postgres-15** (1/1)

**Storage:**
- PVC: my-awx-projects (50Gi, Bound, sc:nfs-sc)
- PVC: REDACTED_0d7ca6a5 (50Gi, Bound, sc:REDACTED_b280aec5)

**Secrets:**
- ExternalSecret: k8s-api-credentials (SecretSynced)
- ExternalSecret: npm-credentials (SecretSynced)

### Namespace: `bentopdf`

1/- **Deployment: bentopdf** (1) → Svc:bentopdf (ClusterIP) → Ingress:bentopdf.example.net

### Namespace: `cert-manager`

1/- **Deployment: cert-manager** (1) → Svc:cert-manager (ClusterIP)
1/- **Deployment: cert-manager-cainjector** (1)
1/- **Deployment: cert-manager-webhook** (1)

**Secrets:**
- ExternalSecret: REDACTED_fb8d60db (SecretSynced)

### Namespace: `cilium-spire`

- **StatefulSet: spire-server** (1/1)

**Storage:**
- PVC: spire-data-spire-server-0 (1Gi, Bound, sc:nfs-client)

### Namespace: `external-secrets`

1/- **Deployment: external-secrets** (1) → Svc:external-secrets-cert-controller-metrics (ClusterIP)
1/- **Deployment: external-secrets-cert-controller** (1) → Svc:external-secrets-cert-controller-metrics (ClusterIP)
1/- **Deployment: external-secrets-webhook** (1) → Svc:external-secrets-webhook (ClusterIP)

### Namespace: `gatus`

1/- **Deployment: gatus** (1) → Svc:gatus (ClusterIP) → Ingress:nl-gatus.example.net

**Storage:**
- PVC: gatus-data (1Gi, Bound, sc:REDACTED_4f3da73d)

### Namespace: `REDACTED_01b50c5d`

2/- **Deployment: REDACTED_ab04b573-v2** (2)

### Namespace: `ingress-nginx`

2/- **Deployment: ingress-nginx-controller** (2)

### Namespace: `REDACTED_d97cef76`

1/- **Deployment: REDACTED_d97cef76-api** (1) → Svc:REDACTED_d97cef76-api (ClusterIP) → Ingress:nl-k8s.example.net
1/- **Deployment: REDACTED_d97cef76-auth** (1) → Svc:REDACTED_d97cef76-auth (ClusterIP) → Ingress:nl-k8s.example.net
1/- **Deployment: REDACTED_d97cef76-kong** (1) → Ingress:nl-k8s.example.net
1/- **Deployment: REDACTED_d97cef76-metrics-scraper** (1) → Svc:REDACTED_d97cef76-metrics-scraper (ClusterIP) → Ingress:nl-k8s.example.net
1/- **Deployment: REDACTED_d97cef76-web** (1) → Svc:REDACTED_d97cef76-web (ClusterIP) → Ingress:nl-k8s.example.net

### Namespace: `logging`

- **StatefulSet: loki** (1/1)

**Storage:**
- PVC: storage-loki-0 (100Gi, Bound, sc:REDACTED_4f3da73d)

**Secrets:**
- ExternalSecret: loki-s3-credentials (SecretSynced)

### Namespace: `monitoring`

1/- **Deployment: bgpalerter** (1) → Svc:bgpalerter (ClusterIP) → Ingress:goldpinger.example.net
2/- **Deployment: monitoring-grafana** (2) → Ingress:goldpinger.example.net
1/- **Deployment: monitoring-kube-prometheus-operator** (1) → Ingress:goldpinger.example.net
1/- **Deployment: monitoring-kube-state-metrics** (1) → Ingress:goldpinger.example.net
1/- **Deployment: snmp-exporter** (1) → Svc:snmp-exporter (ClusterIP) → Ingress:goldpinger.example.net
2/- **Deployment: thanos-query** (2) → Ingress:goldpinger.example.net
- **StatefulSet: alertmanager-monitoring-kube-prometheus-alertmanager** (2/2)
- **StatefulSet: prometheus-REDACTED_6dfbe9fc** (2/2)
- **StatefulSet: thanos-compactor** (1/1)
- **StatefulSet: thanos-store** (2/2)

**Storage:**
- PVC: alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-0 (10Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-1 (10Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: data-thanos-compactor-0 (50Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: data-thanos-store-0 (20Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: data-thanos-store-1 (20Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: monitoring-grafana (20Gi, Bound, sc:nfs-client)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-0 (200Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-1 (200Gi, Bound, sc:REDACTED_4f3da73d)

**Secrets:**
- ExternalSecret: monitoring-grafana (SecretSynced)
- ExternalSecret: REDACTED_5f4971dc (SecretSynced)

### Namespace: `nfs-provisioner`

1/- **Deployment: nfs-provisioner-REDACTED_5fef70be** (1)

### Namespace: `pihole`

1/- **Deployment: pihole** (1) → Svc:pihole-dns-lb (LoadBalancer 10.0.X.X) → Ingress:pihole.example.net

**Storage:**
- PVC: pihole-data (1Gi, Bound, sc:nfs-client)

**Secrets:**
- ExternalSecret: pihole-credentials (SecretSynced)

### Namespace: `seaweedfs`

1/- **Deployment: seaweedfs-filer-sync** (1) → Ingress:nl-seaweedfs.example.net
- **StatefulSet: seaweedfs-filer** (2/2)
- **StatefulSet: seaweedfs-master** (3/3)
- **StatefulSet: seaweedfs-volume** (2/2)

**Storage:**
- PVC: data-filer-seaweedfs-filer-0 (20Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-filer-seaweedfs-filer-1 (20Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-seaweedfs-master-0 (10Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-seaweedfs-master-1 (10Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-seaweedfs-master-2 (10Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-volume-0 (500Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-volume-1 (500Gi, Bound, sc:REDACTED_b280aec5)

**Secrets:**
- ExternalSecret: seaweedfs-s3-config (SecretSynced)

### Namespace: `synology-csi`

- **StatefulSet: synology-csi-controller** (1/1)

### Namespace: `velero`

1/- **Deployment: velero** (1) → Svc:velero-ui (NodePort) → Ingress:velero.example.net
1/- **Deployment: velero-ui** (1) → Svc:velero-ui (NodePort) → Ingress:velero.example.net

**Secrets:**
- ExternalSecret: velero-repo-credentials (SecretSynced)
- ExternalSecret: velero-s3-credentials (SecretSynced)

### Namespace: `well-known`

1/- **Deployment: well-known** (1) → Svc:well-known (ClusterIP) → Ingress:status.example.net


---

## Resource Analysis

### Node Utilization
```
NAME                 CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
nlk8s-ctrl01   1476m        36%      1787Mi          47%         
nlk8s-ctrl02   962m         24%      2359Mi          59%         
nlk8s-ctrl03   486m         12%      2348Mi          61%         
nlk8s-node01    498m         6%       3583Mi          45%         
nlk8s-node02    490m         6%       4628Mi          59%         
nlk8s-node03    552m         6%       4287Mi          54%         
nlk8s-node04    692m         8%       5449Mi          69%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              hubble-ui-576dcd986f-wthq8                                        229m         717Mi           
kube-system              kube-apiserver-nlk8s-ctrl02                                 210m         1143Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 209m         1349Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                194m         1347Mi          
kube-system              etcd-nlk8s-ctrl02                                           189m         187Mi           
kube-system              cilium-22zgh                                                      172m         268Mi           
kube-system              tetragon-mdsn9                                                    170m         162Mi           
kube-system              cilium-mvsq5                                                      166m         198Mi           
argocd                   argocd-application-controller-0                                   141m         334Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-0                133m         1232Mi          
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
awx                      my-awx-task-6f8f46478-wkz6j                                       36m          1538Mi          
logging                  loki-0                                                            62m          1488Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 209m         1349Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                194m         1347Mi          
awx                      my-awx-web-7bc5ccfbf4-bkrlp                                       7m           1257Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                133m         1232Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 210m         1143Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 85m          807Mi           
monitoring               monitoring-grafana-9ccf6f977-mhjwg                                24m          734Mi           
monitoring               monitoring-grafana-9ccf6f977-w47db                                27m          725Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
monitoring: CPU=2120m Mem=7600Mi
kube-system: CPU=2060m Mem=472Mi
awx: CPU=1855m Mem=3552Mi
seaweedfs: CPU=1200m Mem=2944Mi
ingress-nginx: CPU=1000m Mem=1024Mi
logging: CPU=850m Mem=2496Mi
argocd: CPU=750m Mem=1664Mi
velero: CPU=550m Mem=704Mi
REDACTED_d97cef76: CPU=400m Mem=800Mi
pihole: CPU=100m Mem=256Mi
```

---

## Network & Security

### PodDisruptionBudgets
```
NAMESPACE         NAME                                              MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
argocd            argocd-application-controller                     1               N/A               0                     48d
argocd            argocd-applicationset-controller                  1               N/A               0                     48d
argocd            argocd-redis                                      1               N/A               0                     48d
argocd            argocd-repo-server                                1               N/A               1                     48d
argocd            argocd-server                                     1               N/A               1                     48d
awx               awx-postgres-pdb                                  1               N/A               0                     48d
awx               awx-task-pdb                                      1               N/A               0                     48d
awx               awx-web-pdb                                       1               N/A               0                     48d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     48d
kube-system       coredns-pdb                                       1               N/A               1                     48d
kube-system       metrics-server-pdb                                1               N/A               0                     48d
monitoring        monitoring-grafana                                1               N/A               1                     48d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     48d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     48d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     48d
```

### CiliumNetworkPolicies
- CiliumNetworkPolicies: 4
- CiliumClusterwideNetworkPolicies: 0

**Policies by namespace:**
- gatus: 1 policies
- logging: 1 policies
- pihole: 1 policies
- well-known: 1 policies

### Services by Type
| Type | Count |
|------|-------|
| ClusterIP | 72 |
| NodePort | 6 |
| LoadBalancer | 6 |

### LoadBalancer Services
```
NAMESPACE       NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   70d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               39d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 47d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                45d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 47d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 47d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   50d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        49d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        46d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   29d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        34d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        33d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        38d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        49d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        33d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        34d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        51d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        35d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        35d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        50d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   28d
```

---

#***REMOVED***

| Metric | Count |
|--------|-------|
| StorageClasses | 10 |
| PersistentVolumes | 22 |
| PersistentVolumeClaims | 21 |

##***REMOVED***Classes
```
NAME                                      PROVISIONER                                                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   51d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   71d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   48d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   48d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   48d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   48d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   48d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   48d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   48d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   48d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 3 |
| External Secrets | 14 |
| Certificates | 4 |
| ServiceMonitors | 31 |
| CiliumNetworkPolicies | 4 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE   PAUSED
daily-backup    Enabled   0 2 * * *   61m          50d   
weekly-backup   Enabled   0 3 * * 0   4d           50d   
```

### Recent Backups (last 5)
```
daily-backup-20260111020005    4d1h
weekly-backup-20260111030006   4d
daily-backup-20260112020007    3d1h
daily-backup-20260113020008    2d1h
daily-backup-20260114020009    25h
```

---

## Helm Releases
```
NAME                	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd              	argocd                	3       	2025-11-29 02:18:52.98547378 +0000 UTC 	deployed	argo-cd-7.7.10                        	v2.13.2    
cert-manager        	cert-manager          	3       	2025-11-30 21:22:09.520251302 +0000 UTC	deployed	cert-manager-v1.17.1                  	v1.17.1    
cilium              	kube-system           	20      	2025-12-12 16:06:57.516153767 +0000 UTC	deployed	cilium-1.18.4                         	1.18.4     
external-secrets    	external-secrets      	2       	2025-12-16 13:20:23.175188029 +0000 UTC	deployed	external-secrets-1.1.1                	v1.1.1     
ingress-nginx       	ingress-nginx         	8       	2025-12-17 17:38:33.246089847 +0000 UTC	deployed	ingress-nginx-4.14.0                  	1.14.0     
k8s-agent           	REDACTED_01b50c5d	6       	2025-11-29 02:18:29.271243252 +0000 UTC	deployed	gitlab-agent-2.21.1                   	v18.6.1    
REDACTED_d97cef76	REDACTED_d97cef76  	1       	2025-12-12 11:22:00.351838712 +0000 UTC	deployed	REDACTED_d97cef76-7.14.0           	           
loki                	logging               	10      	2025-12-20 00:53:40.31805239 +0000 UTC 	deployed	loki-6.46.0                           	3.5.7      
monitoring          	monitoring            	25      	2025-12-26 23:00:11.225695324 +0000 UTC	deployed	REDACTED_d8074874-79.10.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	8       	2025-11-29 02:18:25.900770326 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail            	logging               	7       	2025-12-20 00:06:56.11230417 +0000 UTC 	deployed	promtail-6.17.1                       	3.5.1      
seaweedfs           	seaweedfs             	1       	2025-12-11 00:12:58.814719121 +0000 UTC	deployed	seaweedfs-4.0.401                     	4.01       
synology-csi        	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
tetragon            	kube-system           	7       	2025-12-20 22:35:40.030282504 +0000 UTC	deployed	tetragon-1.6.0                        	1.6.0      
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   50d
awx                      Active   71d
bentopdf                 Active   46d
cert-manager             Active   45d
cilium-secrets           Active   47d
cilium-spire             Active   47d
default                  Active   72d
external-secrets         Active   46d
gatus                    Active   29d
REDACTED_01b50c5d   Active   51d
ingress-nginx            Active   70d
kube-node-lease          Active   72d
kube-public              Active   72d
kube-system              Active   72d
REDACTED_d97cef76     Active   33d
logging                  Active   45d
monitoring               Active   71d
nfs-provisioner          Active   70d
opentofu-ns              Active   70d
pihole                   Active   51d
production               Active   51d
seaweedfs                Active   35d
synology-csi             Active   48d
velero                   Active   50d
well-known               Active   28d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           50d
argocd                   argocd-redis                                      1/1     1            1           50d
argocd                   argocd-repo-server                                2/2     2            2           50d
argocd                   argocd-server                                     2/2     2            2           50d
awx                      awx-operator-controller-manager                   1/1     1            1           71d
awx                      my-awx-task                                       1/1     1            1           71d
awx                      my-awx-web                                        1/1     1            1           71d
bentopdf                 bentopdf                                          1/1     1            1           46d
cert-manager             cert-manager                                      1/1     1            1           45d
cert-manager             cert-manager-cainjector                           1/1     1            1           45d
cert-manager             cert-manager-webhook                              1/1     1            1           45d
external-secrets         external-secrets                                  1/1     1            1           46d
external-secrets         external-secrets-cert-controller                  1/1     1            1           46d
external-secrets         external-secrets-webhook                          1/1     1            1           46d
gatus                    gatus                                             1/1     1            1           29d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           51d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           70d
kube-system              cilium-operator                                   1/1     1            1           47d
kube-system              clustermesh-apiserver                             1/1     1            1           39d
kube-system              coredns                                           2/2     2            2           72d
kube-system              hubble-relay                                      1/1     1            1           47d
kube-system              hubble-ui                                         1/1     1            1           47d
kube-system              metrics-server                                    1/1     1            1           71d
kube-system              tetragon-operator                                 1/1     1            1           26d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           33d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           33d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           33d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           33d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           33d
monitoring               bgpalerter                                        1/1     1            1           31d
monitoring               monitoring-grafana                                2/2     2            2           48d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           70d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           70d
monitoring               snmp-exporter                                     1/1     1            1           33d
monitoring               thanos-query                                      2/2     2            2           34d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           70d
pihole                   pihole                                            1/1     1            1           46d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           34d
velero                   velero                                            1/1     1            1           50d
velero                   velero-ui                                         1/1     1            1           50d
well-known               well-known                                        1/1     1            1           28d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     50d
awx            my-awx-postgres-15                                     1/1     71d
cilium-spire   spire-server                                           1/1     47d
logging        loki                                                   1/1     26d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     48d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     48d
monitoring     thanos-compactor                                       1/1     34d
monitoring     thanos-store                                           2/2     34d
seaweedfs      seaweedfs-filer                                        2/2     35d
seaweedfs      seaweedfs-master                                       3/3     35d
seaweedfs      seaweedfs-volume                                       2/2     35d
synology-csi   synology-csi-controller                                1/1     48d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   47d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   47d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   47d
kube-system    tetragon                              7         7         7       7            7           <none>                   26d
logging        loki-canary                           4         4         4       4            4           <none>                   34d
logging        promtail                              7         7         7       7            7           <none>                   45d
monitoring     goldpinger                            7         7         7       7            7           <none>                   38d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   70d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   48d
velero         velero-node-agent                     4         4         4       4            4           <none>                   50d
```

---

*Full cluster context dump - v3.1.0*
