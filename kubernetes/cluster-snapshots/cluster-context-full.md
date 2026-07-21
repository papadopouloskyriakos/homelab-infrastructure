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

**Generated:** 2026-07-21 03:00:01 UTC  
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
kube-system   18m         Warning   Unhealthy   pod/etcd-nlk8s-ctrl01             Readiness probe failed: HTTP probe failed with statuscode: 503
kube-system   13m         Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Liveness probe failed: HTTP probe failed with statuscode: 500
kube-system   46s         Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Readiness probe failed: HTTP probe failed with statuscode: 500
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
nlk8s-ctrl01   1244m        31%      2940Mi          37%         
nlk8s-ctrl02   1682m        42%      3192Mi          39%         
nlk8s-ctrl03   292m         7%       2821Mi          36%         
nlk8s-node01    198m         2%       3331Mi          42%         
nlk8s-node02    605m         7%       5627Mi          71%         
nlk8s-node03    576m         7%       6884Mi          88%         
nlk8s-node04    1236m        15%      4358Mi          55%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              kube-apiserver-nlk8s-ctrl02                                 426m         1328Mi          
kube-system              tetragon-mdsn9                                                    319m         637Mi           
kube-system              etcd-nlk8s-ctrl02                                           282m         130Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-0                264m         1497Mi          
kube-system              cilium-64v2f                                                      257m         178Mi           
awx                      my-awx-task-756d768868-k9sdd                                      214m         1795Mi          
logging                  promtail-br4rf                                                    199m         90Mi            
kube-system              cilium-8v6d6                                                      171m         199Mi           
logging                  loki-0                                                            145m         1113Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 118m         1368Mi          
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
awx                      my-awx-task-756d768868-k9sdd                                      214m         1795Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                48m          1649Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                264m         1497Mi          
awx                      my-awx-web-55ccb47b58-876cl                                       12m          1423Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 118m         1368Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 62m          1344Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 426m         1328Mi          
seaweedfs                seaweedfs-filer-1                                                 42m          1244Mi          
seaweedfs                seaweedfs-filer-0                                                 33m          1123Mi          
logging                  loki-0                                                            145m         1113Mi          
Metrics server not available
```

### Resource Requests/Limits Summary
```
monitoring: CPU=2160m Mem=9904Mi
awx: CPU=2105m Mem=3652Mi
kube-system: CPU=2060m Mem=472Mi
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
argocd            argocd-application-controller                     1               N/A               0                     235d
argocd            argocd-applicationset-controller                  1               N/A               0                     235d
argocd            argocd-redis                                      1               N/A               0                     235d
argocd            argocd-repo-server                                1               N/A               1                     235d
argocd            argocd-server                                     1               N/A               1                     235d
awx               awx-postgres-pdb                                  1               N/A               0                     235d
awx               awx-task-pdb                                      1               N/A               0                     235d
awx               awx-web-pdb                                       1               N/A               0                     235d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     235d
kube-system       coredns-pdb                                       1               N/A               1                     235d
kube-system       metrics-server-pdb                                1               N/A               0                     235d
monitoring        monitoring-grafana                                1               N/A               1                     100d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     100d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     100d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     235d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     121d
seaweedfs         seaweedfs-master                                  2               N/A               1                     121d
seaweedfs         seaweedfs-volume                                  1               N/A               1                     121d
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
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   257d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               226d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 234d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                232d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 234d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 234d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   237d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        236d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        233d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        127d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   216d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        221d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        220d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        225d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        236d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        220d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        221d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        238d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        222d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        222d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        237d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   215d
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   238d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   258d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   235d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   235d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   235d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   235d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   235d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   235d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   235d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   235d
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
daily-backup    Enabled   0 2 * * *   61m          237d   
weekly-backup   Enabled   0 3 * * 0   2d           237d   
```

### Recent Backups (last 5)
```
daily-backup-20260715020016    6d1h
daily-backup-20260716020017    5d1h
daily-backup-20260718020019    3d1h
weekly-backup-20260719030020   2d
daily-backup-20260720020021    25h
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
argocd                   Active   237d
awx                      Active   258d
bentopdf                 Active   233d
cert-manager             Active   232d
cilium-secrets           Active   234d
cilium-spire             Active   234d
default                  Active   259d
echo-server              Active   127d
external-secrets         Active   233d
gatus                    Active   216d
REDACTED_01b50c5d   Active   238d
ingress-nginx            Active   257d
kube-node-lease          Active   259d
kube-public              Active   259d
kube-system              Active   259d
REDACTED_d97cef76     Active   220d
logging                  Active   232d
monitoring               Active   258d
nfs-provisioner          Active   257d
opentofu-ns              Active   257d
pihole                   Active   238d
production               Active   238d
seaweedfs                Active   222d
synology-csi             Active   235d
velero                   Active   237d
well-known               Active   215d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           237d
argocd                   argocd-notifications-controller                   1/1     1            1           128d
argocd                   argocd-redis                                      1/1     1            1           237d
argocd                   argocd-repo-server                                2/2     2            2           237d
argocd                   argocd-server                                     2/2     2            2           237d
awx                      awx-operator-controller-manager                   1/1     1            1           258d
awx                      my-awx-task                                       1/1     1            1           258d
awx                      my-awx-web                                        1/1     1            1           258d
bentopdf                 bentopdf                                          1/1     1            1           233d
cert-manager             cert-manager                                      1/1     1            1           232d
cert-manager             cert-manager-cainjector                           1/1     1            1           232d
cert-manager             cert-manager-webhook                              1/1     1            1           232d
echo-server              echo-server                                       1/1     1            1           127d
external-secrets         external-secrets                                  1/1     1            1           233d
external-secrets         external-secrets-cert-controller                  1/1     1            1           233d
external-secrets         external-secrets-webhook                          1/1     1            1           233d
gatus                    gatus                                             1/1     1            1           216d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           238d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           257d
kube-system              cilium-operator                                   1/1     1            1           234d
kube-system              clustermesh-apiserver                             1/1     1            1           226d
kube-system              coredns                                           2/2     2            2           259d
kube-system              hubble-relay                                      1/1     1            1           234d
kube-system              hubble-ui                                         1/1     1            1           234d
kube-system              metrics-server                                    1/1     1            1           258d
kube-system              tetragon-operator                                 1/1     1            1           213d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           220d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           220d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           220d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           220d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           220d
monitoring               bgpalerter                                        1/1     1            1           218d
monitoring               monitoring-grafana                                2/2     2            2           100d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           100d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           100d
monitoring               snmp-exporter                                     1/1     1            1           220d
monitoring               thanos-query                                      2/2     2            2           221d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           257d
pihole                   pihole                                            1/1     1            1           233d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           221d
velero                   velero                                            1/1     1            1           237d
velero                   velero-ui                                         1/1     1            1           237d
well-known               well-known                                        1/1     1            1           215d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     237d
awx            my-awx-postgres-15                                     1/1     258d
cilium-spire   spire-server                                           1/1     234d
logging        loki                                                   1/1     213d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     100d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     100d
monitoring     thanos-compactor                                       1/1     221d
monitoring     thanos-store                                           2/2     221d
seaweedfs      seaweedfs-filer                                        2/2     222d
seaweedfs      seaweedfs-master                                       3/3     222d
seaweedfs      seaweedfs-volume                                       2/2     222d
synology-csi   synology-csi-controller                                1/1     235d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   234d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   234d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   234d
kube-system    tetragon                              7         7         7       7            7           <none>                   213d
logging        loki-canary                           4         4         4       4            4           <none>                   221d
logging        promtail                              7         7         7       7            7           <none>                   232d
monitoring     goldpinger                            7         7         7       7            7           <none>                   225d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   100d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   235d
velero         velero-node-agent                     4         4         4       4            4           <none>                   237d
```

---

*Full cluster context dump - v3.1.0*
