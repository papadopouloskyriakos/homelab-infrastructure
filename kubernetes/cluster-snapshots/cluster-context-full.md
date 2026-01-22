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

**Generated:** 2026-01-22 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | HEALTHY | ✅ |
| Unhealthy Pods | 0 | ✅ |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 738 | ⚠️ |

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
- kube-system/etcd-nlk8s-ctrl01: 13 restarts
- kube-system/etcd-nlk8s-ctrl02: 38 restarts
- kube-system/etcd-nlk8s-ctrl03: 4 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 94 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 55 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 12 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 83 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 21 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 69 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 20 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 21 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 18 restarts
- kube-system/tetragon-mdsn9: 16 restarts
- logging/loki-0: 10 restarts
- logging/promtail-rxt6j: 8 restarts
- monitoring/bgpalerter-596d7b756b-pxcb5: 8 restarts
- monitoring/goldpinger-4fvxd: 9 restarts
- monitoring/goldpinger-qs5xt: 4 restarts
- monitoring/monitoring-grafana-9ccf6f977-mhjwg: 34 restarts
- monitoring/monitoring-grafana-9ccf6f977-w47db: 30 restarts
- monitoring/monitoring-kube-state-metrics-74d579585b-6cprn: 10 restarts
- monitoring/monitoring-prometheus-node-exporter-d5wkz: 8 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956swwjx: 13 restarts
- seaweedfs/seaweedfs-filer-0: 29 restarts
- seaweedfs/seaweedfs-filer-1: 25 restarts
- synology-csi/synology-csi-node-zch7n: 16 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE     LAST SEEN   TYPE      REASON      OBJECT                                  MESSAGE
kube-system   9m19s       Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Readiness probe failed: HTTP probe failed with statuscode: 500
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
nlk8s-ctrl01   1533m        38%      1902Mi          50%         
nlk8s-ctrl02   884m         22%      2357Mi          59%         
nlk8s-ctrl03   357m         8%       2318Mi          61%         
nlk8s-node01    464m         5%       3429Mi          43%         
nlk8s-node02    650m         8%       4539Mi          58%         
nlk8s-node03    320m         4%       4190Mi          53%         
nlk8s-node04    439m         5%       5545Mi          70%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
logging                  loki-0                                                            308m         1614Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 210m         1113Mi          
kube-system              hubble-ui-576dcd986f-wthq8                                        168m         615Mi           
kube-system              etcd-nlk8s-ctrl02                                           167m         201Mi           
kube-system              kube-apiserver-nlk8s-ctrl03                                 161m         1270Mi          
kube-system              cilium-mvsq5                                                      154m         171Mi           
kube-system              cilium-22zgh                                                      137m         272Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-1                133m         1268Mi          
kube-system              tetragon-vbs6v                                                    126m         134Mi           
kube-system              tetragon-mdsn9                                                    124m         168Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
logging                  loki-0                                                            308m         1614Mi          
awx                      my-awx-task-6f8f46478-wkz6j                                       29m          1565Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                63m          1334Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 161m         1270Mi          
awx                      my-awx-web-7bc5ccfbf4-bkrlp                                       9m           1269Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                133m         1268Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 210m         1113Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 85m          879Mi           
monitoring               monitoring-grafana-9ccf6f977-w47db                                12m          720Mi           
monitoring               monitoring-grafana-9ccf6f977-mhjwg                                13m          708Mi           
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
argocd            argocd-application-controller                     1               N/A               0                     55d
argocd            argocd-applicationset-controller                  1               N/A               0                     55d
argocd            argocd-redis                                      1               N/A               0                     55d
argocd            argocd-repo-server                                1               N/A               1                     55d
argocd            argocd-server                                     1               N/A               1                     55d
awx               awx-postgres-pdb                                  1               N/A               0                     55d
awx               awx-task-pdb                                      1               N/A               0                     55d
awx               awx-web-pdb                                       1               N/A               0                     55d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     55d
kube-system       coredns-pdb                                       1               N/A               1                     55d
kube-system       metrics-server-pdb                                1               N/A               0                     55d
monitoring        monitoring-grafana                                1               N/A               1                     55d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     55d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     55d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     55d
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
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   77d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               46d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 54d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                52d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 54d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 54d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   57d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        56d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        53d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   36d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        41d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        40d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        45d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        56d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        40d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        41d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        58d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        42d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        42d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        57d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   35d
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   58d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   78d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   55d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   55d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   55d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   55d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   55d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   55d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   55d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   55d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 3 |
| External Secrets | 14 |
| Certificates | 5 |
| ServiceMonitors | 31 |
| CiliumNetworkPolicies | 4 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE   PAUSED
daily-backup    Enabled   0 2 * * *   61m          57d   
weekly-backup   Enabled   0 3 * * 0   4d           57d   
```

### Recent Backups (last 5)
```
daily-backup-20260118020013    4d1h
weekly-backup-20260118030014   4d
daily-backup-20260119020015    3d1h
daily-backup-20260120020016    2d1h
daily-backup-20260121020017    25h
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
argocd                   Active   57d
awx                      Active   78d
bentopdf                 Active   53d
cert-manager             Active   52d
cilium-secrets           Active   54d
cilium-spire             Active   54d
default                  Active   79d
external-secrets         Active   53d
gatus                    Active   36d
REDACTED_01b50c5d   Active   58d
ingress-nginx            Active   77d
kube-node-lease          Active   79d
kube-public              Active   79d
kube-system              Active   79d
REDACTED_d97cef76     Active   40d
logging                  Active   52d
monitoring               Active   78d
nfs-provisioner          Active   77d
opentofu-ns              Active   77d
pihole                   Active   58d
production               Active   58d
seaweedfs                Active   42d
synology-csi             Active   55d
velero                   Active   57d
well-known               Active   35d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           57d
argocd                   argocd-redis                                      1/1     1            1           57d
argocd                   argocd-repo-server                                2/2     2            2           57d
argocd                   argocd-server                                     2/2     2            2           57d
awx                      awx-operator-controller-manager                   1/1     1            1           78d
awx                      my-awx-task                                       1/1     1            1           78d
awx                      my-awx-web                                        1/1     1            1           78d
bentopdf                 bentopdf                                          1/1     1            1           53d
cert-manager             cert-manager                                      1/1     1            1           52d
cert-manager             cert-manager-cainjector                           1/1     1            1           52d
cert-manager             cert-manager-webhook                              1/1     1            1           52d
external-secrets         external-secrets                                  1/1     1            1           53d
external-secrets         external-secrets-cert-controller                  1/1     1            1           53d
external-secrets         external-secrets-webhook                          1/1     1            1           53d
gatus                    gatus                                             1/1     1            1           36d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           58d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           77d
kube-system              cilium-operator                                   1/1     1            1           54d
kube-system              clustermesh-apiserver                             1/1     1            1           46d
kube-system              coredns                                           2/2     2            2           79d
kube-system              hubble-relay                                      1/1     1            1           54d
kube-system              hubble-ui                                         1/1     1            1           54d
kube-system              metrics-server                                    1/1     1            1           78d
kube-system              tetragon-operator                                 1/1     1            1           33d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           40d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           40d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           40d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           40d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           40d
monitoring               bgpalerter                                        1/1     1            1           38d
monitoring               monitoring-grafana                                2/2     2            2           55d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           77d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           77d
monitoring               snmp-exporter                                     1/1     1            1           40d
monitoring               thanos-query                                      2/2     2            2           41d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           77d
pihole                   pihole                                            1/1     1            1           53d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           41d
velero                   velero                                            1/1     1            1           57d
velero                   velero-ui                                         1/1     1            1           57d
well-known               well-known                                        1/1     1            1           35d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     57d
awx            my-awx-postgres-15                                     1/1     78d
cilium-spire   spire-server                                           1/1     54d
logging        loki                                                   1/1     33d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     55d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     55d
monitoring     thanos-compactor                                       1/1     41d
monitoring     thanos-store                                           2/2     41d
seaweedfs      seaweedfs-filer                                        2/2     42d
seaweedfs      seaweedfs-master                                       3/3     42d
seaweedfs      seaweedfs-volume                                       2/2     42d
synology-csi   synology-csi-controller                                1/1     55d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   54d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   54d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   54d
kube-system    tetragon                              7         7         7       7            7           <none>                   33d
logging        loki-canary                           4         4         4       4            4           <none>                   41d
logging        promtail                              7         7         7       7            7           <none>                   52d
monitoring     goldpinger                            7         7         7       7            7           <none>                   45d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   77d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   55d
velero         velero-node-agent                     4         4         4       4            4           <none>                   57d
```

---

*Full cluster context dump - v3.1.0*
