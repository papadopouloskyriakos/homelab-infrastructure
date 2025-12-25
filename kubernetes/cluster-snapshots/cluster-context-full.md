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

**Generated:** 2025-12-25 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | HEALTHY | ✅ |
| Unhealthy Pods | 0 | ✅ |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 492 | ⚠️ |

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
- awx/awx-operator-controller-manager-846b99bbd-t9589: 6 restarts
- cert-manager/cert-manager-75944f484-4v6qh: 7 restarts
- cert-manager/cert-manager-cainjector-56b4cf957-s7xd9: 5 restarts
- cilium-spire/spire-agent-xwbn2: 5 restarts
- kube-system/cilium-22zgh: 5 restarts
- kube-system/cilium-envoy-mmfnj: 5 restarts
- kube-system/cilium-operator-6b94496fcd-l6cjl: 67 restarts
- kube-system/etcd-nlk8s-ctrl01: 8 restarts
- kube-system/etcd-nlk8s-ctrl02: 10 restarts
- kube-system/etcd-nlk8s-ctrl03: 4 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 42 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 10 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 10 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 83 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 17 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 67 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 19 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 17 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 16 restarts
- kube-system/tetragon-mdsn9: 10 restarts
- logging/loki-0: 4 restarts
- logging/promtail-rxt6j: 5 restarts
- monitoring/goldpinger-4fvxd: 6 restarts
- monitoring/goldpinger-qs5xt: 4 restarts
- monitoring/monitoring-grafana-9ccf6f977-mhjwg: 14 restarts
- monitoring/monitoring-grafana-9ccf6f977-w47db: 12 restarts
- monitoring/monitoring-kube-state-metrics-74d579585b-6cprn: 8 restarts
- monitoring/monitoring-prometheus-node-exporter-d5wkz: 5 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956swwjx: 11 restarts
- seaweedfs/seaweedfs-filer-1: 4 restarts
- synology-csi/synology-csi-node-zch7n: 10 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE     LAST SEEN   TYPE      REASON                OBJECT                    MESSAGE
default       7m11s       Warning   InvalidDiskCapacity   node/nlk8s-ctrl02   invalid capacity 0 on image filesystem
default       7m11s       Warning   Rebooted              node/nlk8s-ctrl02   Node nlk8s-ctrl02 has been rebooted, boot id: 2f32a5d0-5ee3-4174-bf9b-b77d3191b47a
kube-system   7m3s        Warning   Unhealthy             pod/cilium-envoy-mmfnj    Startup probe failed: Get "http://127.0.0.1:9878/healthz": dial tcp 127.0.0.1:9878: connect: connection refused
kube-system   6m38s       Warning   BackOff               pod/tetragon-mdsn9        Back-off restarting failed container tetragon in pod tetragon-mdsn9_kube-system(5b39106d-8960-42b0-a67c-6981d2f99f65)
kube-system   6m5s        Warning   Unhealthy             pod/tetragon-mdsn9        Liveness probe failed: timeout: failed to connect service "10.0.X.X:6789" within 1m0s: context deadline exceeded
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
nlk8s-ctrl01   1730m        43%      1831Mi          48%         
nlk8s-ctrl02   132m         3%       3155Mi          78%         
nlk8s-ctrl03   331m         8%       2390Mi          63%         
nlk8s-node01    418m         5%       3678Mi          47%         
nlk8s-node02    414m         5%       4734Mi          60%         
nlk8s-node03    687m         8%       3796Mi          48%         
nlk8s-node04    734m         9%       5225Mi          66%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                243m         1096Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                218m         1245Mi          
kube-system              hubble-ui-576dcd986f-wthq8                                        186m         533Mi           
kube-system              tetragon-vbs6v                                                    144m         108Mi           
kube-system              kube-apiserver-nlk8s-ctrl03                                 142m         1279Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 130m         736Mi           
monitoring               bgpalerter-596d7b756b-pxcb5                                       120m         707Mi           
kube-system              cilium-kghrg                                                      118m         281Mi           
kube-system              cilium-mvsq5                                                      110m         194Mi           
kube-system              etcd-nlk8s-ctrl01                                           108m         154Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
awx                      my-awx-task-6f8f46478-wkz6j                                       31m          1509Mi          
kube-system              cilium-22zgh                                                      20m          1363Mi          
awx                      my-awx-web-7bc5ccfbf4-bkrlp                                       7m           1283Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 142m         1279Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                218m         1245Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                243m         1096Mi          
logging                  loki-0                                                            68m          1060Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 130m         736Mi           
monitoring               monitoring-grafana-9ccf6f977-mhjwg                                9m           723Mi           
monitoring               monitoring-grafana-9ccf6f977-w47db                                23m          718Mi           
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
argocd            argocd-application-controller                     1               N/A               0                     27d
argocd            argocd-applicationset-controller                  1               N/A               0                     27d
argocd            argocd-redis                                      1               N/A               0                     27d
argocd            argocd-repo-server                                1               N/A               1                     27d
argocd            argocd-server                                     1               N/A               1                     27d
awx               awx-postgres-pdb                                  1               N/A               0                     27d
awx               awx-task-pdb                                      1               N/A               0                     27d
awx               awx-web-pdb                                       1               N/A               0                     27d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     27d
kube-system       coredns-pdb                                       1               N/A               1                     27d
kube-system       metrics-server-pdb                                1               N/A               0                     27d
monitoring        monitoring-grafana                                1               N/A               1                     27d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     27d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     27d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     27d
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
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   49d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               18d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 26d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                24d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 26d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 26d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   29d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        28d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        25d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   8d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        13d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        12d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        17d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        28d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        12d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        13d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        30d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        14d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        14d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        29d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   7d13h
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   30d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   50d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   27d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   27d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   27d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   27d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   27d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   27d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   27d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   27d
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
daily-backup    Enabled   0 2 * * *   60m          29d   
weekly-backup   Enabled   0 3 * * 0   4d           29d   
```

### Recent Backups (last 5)
```
daily-backup-20251221020041    4d1h
weekly-backup-20251221030041   4d
daily-backup-20251222020042    3d1h
daily-backup-20251223020044    2d1h
daily-backup-20251224020045    25h
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
monitoring          	monitoring            	23      	2025-12-21 22:15:03.99088521 +0000 UTC 	deployed	REDACTED_d8074874-79.10.0         	v0.86.2    
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
argocd                   Active   29d
awx                      Active   50d
bentopdf                 Active   25d
cert-manager             Active   24d
cilium-secrets           Active   26d
cilium-spire             Active   26d
default                  Active   51d
external-secrets         Active   25d
gatus                    Active   8d
REDACTED_01b50c5d   Active   30d
ingress-nginx            Active   49d
kube-node-lease          Active   51d
kube-public              Active   51d
kube-system              Active   51d
REDACTED_d97cef76     Active   12d
logging                  Active   24d
monitoring               Active   50d
nfs-provisioner          Active   49d
opentofu-ns              Active   49d
pihole                   Active   30d
production               Active   30d
seaweedfs                Active   14d
synology-csi             Active   27d
velero                   Active   29d
well-known               Active   7d13h
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           29d
argocd                   argocd-redis                                      1/1     1            1           29d
argocd                   argocd-repo-server                                2/2     2            2           29d
argocd                   argocd-server                                     2/2     2            2           29d
awx                      awx-operator-controller-manager                   1/1     1            1           50d
awx                      my-awx-task                                       1/1     1            1           50d
awx                      my-awx-web                                        1/1     1            1           50d
bentopdf                 bentopdf                                          1/1     1            1           25d
cert-manager             cert-manager                                      1/1     1            1           24d
cert-manager             cert-manager-cainjector                           1/1     1            1           24d
cert-manager             cert-manager-webhook                              1/1     1            1           24d
external-secrets         external-secrets                                  1/1     1            1           25d
external-secrets         external-secrets-cert-controller                  1/1     1            1           25d
external-secrets         external-secrets-webhook                          1/1     1            1           25d
gatus                    gatus                                             1/1     1            1           8d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           30d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           49d
kube-system              cilium-operator                                   1/1     1            1           26d
kube-system              clustermesh-apiserver                             1/1     1            1           18d
kube-system              coredns                                           2/2     2            2           51d
kube-system              hubble-relay                                      1/1     1            1           26d
kube-system              hubble-ui                                         1/1     1            1           26d
kube-system              metrics-server                                    1/1     1            1           50d
kube-system              tetragon-operator                                 1/1     1            1           5d13h
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           12d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           12d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           12d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           12d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           12d
monitoring               bgpalerter                                        1/1     1            1           10d
monitoring               monitoring-grafana                                2/2     2            2           27d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           49d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           49d
monitoring               snmp-exporter                                     1/1     1            1           12d
monitoring               thanos-query                                      2/2     2            2           13d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           49d
pihole                   pihole                                            1/1     1            1           25d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           13d
velero                   velero                                            1/1     1            1           29d
velero                   velero-ui                                         1/1     1            1           29d
well-known               well-known                                        1/1     1            1           7d12h
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     29d
awx            my-awx-postgres-15                                     1/1     50d
cilium-spire   spire-server                                           1/1     26d
logging        loki                                                   1/1     5d9h
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     27d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     27d
monitoring     thanos-compactor                                       1/1     13d
monitoring     thanos-store                                           2/2     13d
seaweedfs      seaweedfs-filer                                        2/2     14d
seaweedfs      seaweedfs-master                                       3/3     14d
seaweedfs      seaweedfs-volume                                       2/2     14d
synology-csi   synology-csi-controller                                1/1     27d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   26d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   26d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   26d
kube-system    tetragon                              7         7         7       7            7           <none>                   5d13h
logging        loki-canary                           4         4         4       4            4           <none>                   13d
logging        promtail                              7         7         7       7            7           <none>                   24d
monitoring     goldpinger                            7         7         7       7            7           <none>                   17d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   49d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   27d
velero         velero-node-agent                     4         4         4       4            4           <none>                   29d
```

---

*Full cluster context dump - v3.1.0*
