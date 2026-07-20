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

**Generated:** 2026-07-20 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | HEALTHY | ✅ |
| Unhealthy Pods | 0 | ✅ |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 2815 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.19.5 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 149 |

### Node Details (with Taints & Labels)

#### nlk8s-ctrl01
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 8005928Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-ctrl02
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 8092Mi
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-ctrl03
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 8006944Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node01
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8005712Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node02
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006756Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node03
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006732Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node04
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006740Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01


---

## Anomalies & Issues

### Unhealthy Pods
_None - all pods are Running or Completed_

### High Restart Pods (>3 restarts)
- awx/awx-operator-controller-manager-6ffdf98f6-hwvqf: 4 restarts
- cilium-spire/spire-agent-mdslp: 8 restarts
- kube-system/etcd-nlk8s-ctrl01: 64 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 1992 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 58 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 14 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 105 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 36 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 90 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 37 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 33 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 36 restarts
- kube-system/tetragon-75hdg: 6 restarts
- kube-system/tetragon-878gv: 4 restarts
- kube-system/tetragon-mdsn9: 18 restarts
- kube-system/tetragon-tbcc7: 4 restarts
- kube-system/tetragon-vbs6v: 14 restarts
- logging/promtail-hp5sc: 7 restarts
- logging/promtail-ng69s: 4 restarts
- monitoring/goldpinger-6dj9l: 25 restarts
- monitoring/goldpinger-zxtb9: 6 restarts
- monitoring/monitoring-prometheus-node-exporter-6dl8r: 174 restarts
- monitoring/monitoring-prometheus-node-exporter-wmcb8: 6 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956jjmld: 7 restarts
- synology-csi/synology-csi-node-577mq: 10 restarts
- synology-csi/synology-csi-node-kxrjb: 14 restarts
- synology-csi/synology-csi-node-l72f8: 4 restarts
- synology-csi/synology-csi-node-ptwb8: 4 restarts
- synology-csi/synology-csi-node-zch7n: 18 restarts
- velero/velero-node-agent-mwfzv: 4 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE     LAST SEEN   TYPE      REASON      OBJECT                                  MESSAGE
kube-system   60m         Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Liveness probe failed: HTTP probe failed with statuscode: 500
kube-system   51s         Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Readiness probe failed: HTTP probe failed with statuscode: 500
```

---

## Workload Map

### Namespace: `argocd`

1/- **Deployment: argocd-applicationset-controller** (1) → Svc:argocd-applicationset-controller (ClusterIP) → Ingress:argocd.example.net
1/- **Deployment: argocd-notifications-controller** (1) → Ingress:argocd.example.net
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

### Namespace: `default`


### Namespace: `echo-server`

1/- **Deployment: echo-server** (1) → Svc:echo-server (ClusterIP) → Ingress:echo.example.net

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
- ExternalSecret: monitoring-finops-db-ro (SecretSynced)
- ExternalSecret: monitoring-grafana (SecretSynced)
- ExternalSecret: tg-ingest-token (SecretSynced)
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
nlk8s-ctrl01   1285m        32%      2988Mi          38%         
nlk8s-ctrl02   1440m        36%      3269Mi          40%         
nlk8s-ctrl03   339m         8%       2956Mi          37%         
nlk8s-node01    496m         6%       3415Mi          43%         
nlk8s-node02    675m         8%       6062Mi          77%         
nlk8s-node03    466m         5%       6491Mi          83%         
nlk8s-node04    602m         7%       4170Mi          53%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              kube-apiserver-nlk8s-ctrl02                                 336m         1405Mi          
kube-system              etcd-nlk8s-ctrl02                                           248m         133Mi           
kube-system              cilium-8v6d6                                                      227m         195Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-0                198m         1669Mi          
kube-system              tetragon-mdsn9                                                    197m         660Mi           
logging                  promtail-ng69s                                                    185m         169Mi           
kube-system              cilium-64v2f                                                      179m         171Mi           
kube-system              kube-apiserver-nlk8s-ctrl03                                 157m         1477Mi          
logging                  loki-0                                                            138m         1004Mi          
kube-system              etcd-nlk8s-ctrl03                                           89m          134Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-1                43m          1722Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                198m         1669Mi          
awx                      my-awx-task-756d768868-k9sdd                                      19m          1644Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 157m         1477Mi          
awx                      my-awx-web-55ccb47b58-876cl                                       5m           1441Mi          
seaweedfs                seaweedfs-filer-0                                                 25m          1407Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 336m         1405Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 86m          1389Mi          
logging                  loki-0                                                            138m         1004Mi          
monitoring               bgpalerter-5c8b566bbd-gbl6p                                       2m           730Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
monitoring: CPU=2160m Mem=9904Mi
kube-system: CPU=2060m Mem=472Mi
awx: CPU=1855m Mem=3552Mi
seaweedfs: CPU=1200m Mem=3968Mi
ingress-nginx: CPU=1000m Mem=1024Mi
logging: CPU=850m Mem=2944Mi
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
argocd            argocd-application-controller                     1               N/A               0                     234d
argocd            argocd-applicationset-controller                  1               N/A               0                     234d
argocd            argocd-redis                                      1               N/A               0                     234d
argocd            argocd-repo-server                                1               N/A               1                     234d
argocd            argocd-server                                     1               N/A               1                     234d
awx               awx-postgres-pdb                                  1               N/A               0                     234d
awx               awx-task-pdb                                      1               N/A               0                     234d
awx               awx-web-pdb                                       1               N/A               0                     234d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     234d
kube-system       coredns-pdb                                       1               N/A               1                     234d
kube-system       metrics-server-pdb                                1               N/A               0                     234d
monitoring        monitoring-grafana                                1               N/A               1                     99d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     99d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     99d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     234d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     120d
seaweedfs         seaweedfs-master                                  2               N/A               1                     120d
seaweedfs         seaweedfs-volume                                  1               N/A               1                     120d
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
| ClusterIP | 71 |
| NodePort | 6 |
| LoadBalancer | 6 |

### LoadBalancer Services
```
NAMESPACE       NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   256d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               225d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 233d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                231d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 233d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 233d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   236d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        235d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        232d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        126d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   215d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        220d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        219d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        224d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        235d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        219d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        220d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        237d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        221d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        221d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        236d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   214d
```

---

## Storage

| Metric | Count |
|--------|-------|
| StorageClasses | 10 |
| PersistentVolumes | 22 |
| PersistentVolumeClaims | 21 |

### StorageClasses
```
NAME                                      PROVISIONER                                                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   237d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   257d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   234d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   234d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   234d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   234d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   234d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   234d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   234d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   234d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 4 |
| External Secrets | 16 |
| Certificates | 20 |
| ServiceMonitors | 27 |
| CiliumNetworkPolicies | 4 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE    PAUSED
daily-backup    Enabled   0 2 * * *   60m          236d   
weekly-backup   Enabled   0 3 * * 0   24h          236d   
```

### Recent Backups (last 5)
```
daily-backup-20260714020015    6d1h
daily-backup-20260715020016    5d1h
daily-backup-20260716020017    4d1h
daily-backup-20260718020019    2d1h
weekly-backup-20260719030020   24h
```

---

## Helm Releases
```
NAME                	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd              	argocd                	9       	2026-03-15 17:16:45.748376325 +0000 UTC	deployed	argo-cd-7.7.10                        	v2.13.2    
cert-manager        	cert-manager          	3       	2025-11-30 21:22:09.520251302 +0000 UTC	deployed	cert-manager-v1.17.1                  	v1.17.1    
cilium              	kube-system           	21      	2026-07-07 13:27:42.463449823 +0000 UTC	deployed	cilium-1.19.5                         	1.19.5     
external-secrets    	external-secrets      	2       	2025-12-16 13:20:23.175188029 +0000 UTC	deployed	external-secrets-1.1.1                	v1.1.1     
ingress-nginx       	ingress-nginx         	14      	2026-07-07 14:07:26.472035985 +0000 UTC	deployed	ingress-nginx-4.15.1                  	1.15.1     
k8s-agent           	REDACTED_01b50c5d	7       	2026-07-07 14:02:10.666450172 +0000 UTC	deployed	gitlab-agent-2.28.0                   	v19.1.0    
REDACTED_d97cef76	REDACTED_d97cef76  	2       	2026-02-25 19:02:27.096604857 +0000 UTC	deployed	REDACTED_d97cef76-7.14.0           	           
loki                	logging               	12      	2026-07-07 13:12:39.944244427 +0000 UTC	deployed	loki-6.55.0                           	3.6.7      
monitoring          	monitoring            	17      	2026-07-17 14:59:37.52907132 +0000 UTC 	deployed	REDACTED_d8074874-79.12.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	8       	2025-11-29 02:18:25.900770326 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail            	logging               	8       	2026-03-14 22:22:09.209112925 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
seaweedfs           	seaweedfs             	9       	2026-07-07 02:57:34.790670101 +0000 UTC	deployed	seaweedfs-4.0.401                     	4.01       
synology-csi        	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
tetragon            	kube-system           	7       	2025-12-20 22:35:40.030282504 +0000 UTC	deployed	tetragon-1.6.0                        	1.6.0      
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   236d
awx                      Active   257d
bentopdf                 Active   232d
cert-manager             Active   231d
cilium-secrets           Active   233d
cilium-spire             Active   233d
default                  Active   258d
echo-server              Active   126d
external-secrets         Active   232d
gatus                    Active   215d
REDACTED_01b50c5d   Active   237d
ingress-nginx            Active   256d
kube-node-lease          Active   258d
kube-public              Active   258d
kube-system              Active   258d
REDACTED_d97cef76     Active   219d
logging                  Active   231d
monitoring               Active   257d
nfs-provisioner          Active   256d
opentofu-ns              Active   256d
pihole                   Active   237d
production               Active   237d
seaweedfs                Active   221d
synology-csi             Active   234d
velero                   Active   236d
well-known               Active   214d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           236d
argocd                   argocd-notifications-controller                   1/1     1            1           127d
argocd                   argocd-redis                                      1/1     1            1           236d
argocd                   argocd-repo-server                                2/2     2            2           236d
argocd                   argocd-server                                     2/2     2            2           236d
awx                      awx-operator-controller-manager                   1/1     1            1           257d
awx                      my-awx-task                                       1/1     1            1           257d
awx                      my-awx-web                                        1/1     1            1           257d
bentopdf                 bentopdf                                          1/1     1            1           232d
cert-manager             cert-manager                                      1/1     1            1           231d
cert-manager             cert-manager-cainjector                           1/1     1            1           231d
cert-manager             cert-manager-webhook                              1/1     1            1           231d
echo-server              echo-server                                       1/1     1            1           126d
external-secrets         external-secrets                                  1/1     1            1           232d
external-secrets         external-secrets-cert-controller                  1/1     1            1           232d
external-secrets         external-secrets-webhook                          1/1     1            1           232d
gatus                    gatus                                             1/1     1            1           215d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           237d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           256d
kube-system              cilium-operator                                   1/1     1            1           233d
kube-system              clustermesh-apiserver                             1/1     1            1           225d
kube-system              coredns                                           2/2     2            2           258d
kube-system              hubble-relay                                      1/1     1            1           233d
kube-system              hubble-ui                                         1/1     1            1           233d
kube-system              metrics-server                                    1/1     1            1           257d
kube-system              tetragon-operator                                 1/1     1            1           212d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           219d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           219d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           219d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           219d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           219d
monitoring               bgpalerter                                        1/1     1            1           217d
monitoring               monitoring-grafana                                2/2     2            2           99d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           99d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           99d
monitoring               snmp-exporter                                     1/1     1            1           219d
monitoring               thanos-query                                      2/2     2            2           220d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           256d
pihole                   pihole                                            1/1     1            1           232d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           220d
velero                   velero                                            1/1     1            1           236d
velero                   velero-ui                                         1/1     1            1           236d
well-known               well-known                                        1/1     1            1           214d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     236d
awx            my-awx-postgres-15                                     1/1     257d
cilium-spire   spire-server                                           1/1     233d
logging        loki                                                   1/1     212d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     99d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     99d
monitoring     thanos-compactor                                       1/1     220d
monitoring     thanos-store                                           2/2     220d
seaweedfs      seaweedfs-filer                                        2/2     221d
seaweedfs      seaweedfs-master                                       3/3     221d
seaweedfs      seaweedfs-volume                                       2/2     221d
synology-csi   synology-csi-controller                                1/1     234d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   233d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   233d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   233d
kube-system    tetragon                              7         7         7       7            7           <none>                   212d
logging        loki-canary                           4         4         4       4            4           <none>                   220d
logging        promtail                              7         7         7       7            7           <none>                   231d
monitoring     goldpinger                            7         7         7       7            7           <none>                   224d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   99d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   234d
velero         velero-node-agent                     4         4         4       4            4           <none>                   236d
```

---

*Full cluster context dump - v3.1.0*
