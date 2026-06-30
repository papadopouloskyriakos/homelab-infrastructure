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

**Generated:** 2026-06-30 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | HEALTHY | ✅ |
| Unhealthy Pods | 0 | ✅ |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 2947 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.18.4 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 151 |

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
- **CPU:** 8 | **Memory:** 8005716Ki
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
- argocd/argocd-server-64dd47d8bf-mcx86: 20 restarts
- awx/awx-operator-controller-manager-f84fc744-czzgj: 31 restarts
- cert-manager/cert-manager-75944f484-htnps: 6 restarts
- cilium-spire/spire-agent-26mm7: 9 restarts
- cilium-spire/spire-agent-9whrn: 5 restarts
- cilium-spire/spire-agent-jn2zt: 5 restarts
- cilium-spire/spire-agent-lvrj5: 7 restarts
- cilium-spire/spire-agent-xwbn2: 9 restarts
- REDACTED_01b50c5d/k8s-agent-gitlabREDACTED_be72e5155ntt6: 13 restarts
- kube-system/cilium-22zgh: 9 restarts
- kube-system/cilium-envoy-cfv8x: 7 restarts
- kube-system/cilium-envoy-mmfnj: 9 restarts
- kube-system/cilium-gz5mp: 7 restarts
- kube-system/cilium-operator-6b94496fcd-qwll4: 43 restarts
- kube-system/clustermesh-apiserver-55b4c7cf6d-ltjjr: 12 restarts
- kube-system/etcd-nlk8s-ctrl01: 64 restarts
- kube-system/hubble-relay-8577574994-88mcm: 6 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 1991 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 58 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 14 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 103 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 34 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 88 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 36 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 32 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 34 restarts
- kube-system/tetragon-75hdg: 4 restarts
- kube-system/tetragon-878gv: 4 restarts
- kube-system/tetragon-mdsn9: 18 restarts
- kube-system/tetragon-tbcc7: 4 restarts
- kube-system/tetragon-vbs6v: 14 restarts
- REDACTED_d97cef76/REDACTED_d97cef76-kong-5c7f96dd9b-p5nq5: 19 restarts
- logging/loki-0: 75 restarts
- logging/loki-canary-7shdd: 5 restarts
- logging/promtail-hp5sc: 7 restarts
- monitoring/bgpalerter-596d7b756b-kngvb: 17 restarts
- monitoring/goldpinger-4fvxd: 10 restarts
- monitoring/goldpinger-b44g9: 6 restarts
- monitoring/goldpinger-cjzc4: 5 restarts
- monitoring/goldpinger-f72lw: 42 restarts
- monitoring/goldpinger-qs5xt: 14 restarts
- monitoring/goldpinger-vtfpx: 10 restarts
- monitoring/monitoring-prometheus-node-exporter-6dl8r: 27 restarts
- monitoring/monitoring-prometheus-node-exporter-wmcb8: 6 restarts
- monitoring/thanos-compactor-0: 8 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b495697mkm: 5 restarts
- synology-csi/synology-csi-node-577mq: 8 restarts
- synology-csi/synology-csi-node-kxrjb: 14 restarts
- synology-csi/synology-csi-node-l72f8: 4 restarts
- synology-csi/synology-csi-node-ptwb8: 4 restarts
- synology-csi/synology-csi-node-zch7n: 18 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE                LAST SEEN   TYPE      REASON              OBJECT                                               MESSAGE
seaweedfs                15m         Warning   Unhealthy           pod/seaweedfs-volume-0                               Readiness probe failed: HTTP probe failed with statuscode: 503
argocd                   15m         Warning   Unhealthy           pod/argocd-server-64dd47d8bf-mcx86                   Readiness probe failed: Get "https://10.0.2.219:8080/healthz": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
monitoring               15m         Warning   Unhealthy           pod/goldpinger-f72lw                                 Liveness probe failed: Get "http://10.0.2.38:8080/healthz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
argocd                   14m         Warning   Unhealthy           pod/argocd-server-64dd47d8bf-mcx86                   Liveness probe failed: Get "https://10.0.2.219:8080/healthz?full=true": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
awx                      14m         Warning   Unhealthy           pod/awx-operator-controller-manager-f84fc744-czzgj   Liveness probe failed: Get "http://10.0.2.95:6789/healthz": dial tcp 10.0.2.95:6789: connect: connection refused
awx                      14m         Warning   Unhealthy           pod/awx-operator-controller-manager-f84fc744-czzgj   Readiness probe failed: Get "http://10.0.2.95:6789/readyz": dial tcp 10.0.2.95:6789: connect: connection refused
argocd                   14m         Warning   Unhealthy           pod/argocd-server-64dd47d8bf-mcx86                   Readiness probe failed: Get "https://10.0.2.219:8080/healthz": context deadline exceeded
kube-system              14m         Warning   Unhealthy           pod/hubble-relay-8577574994-88mcm                    Readiness probe failed: timeout: health rpc did not complete within 3s
monitoring               13m         Warning   Unhealthy           pod/goldpinger-f72lw                                 Readiness probe failed: Get "http://10.0.2.38:8080/healthz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
awx                      13m         Warning   Unhealthy           pod/awx-operator-controller-manager-f84fc744-czzgj   Readiness probe failed: Get "http://10.0.2.95:6789/readyz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
kube-system              13m         Warning   Unhealthy           pod/cilium-envoy-pzh8c                               Liveness probe failed: Get "http://127.0.0.1:9878/healthz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
logging                  13m         Warning   Unhealthy           pod/loki-canary-7shdd                                Readiness probe failed: Get "http://10.0.2.141:3500/metrics": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
argocd                   13m         Warning   Unhealthy           pod/argocd-server-64dd47d8bf-mcx86                   Readiness probe failed: Get "http://10.0.2.219:8080/healthz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
REDACTED_d97cef76     13m         Warning   Unhealthy           pod/REDACTED_d97cef76-kong-5c7f96dd9b-p5nq5       Liveness probe failed: Get "http://10.0.2.165:8100/status": dial tcp 10.0.2.165:8100: connect: connection refused
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
nlk8s-ctrl01   1411m        35%      2895Mi          37%         
nlk8s-ctrl02   1328m        33%      3353Mi          41%         
nlk8s-ctrl03   328m         8%       2712Mi          34%         
nlk8s-node01    381m         4%       3827Mi          48%         
nlk8s-node02    581m         7%       4642Mi          59%         
nlk8s-node03    651m         8%       6618Mi          84%         
nlk8s-node04    1217m        15%      5483Mi          70%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              kube-apiserver-nlk8s-ctrl02                                 333m         1473Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                296m         1561Mi          
kube-system              etcd-nlk8s-ctrl02                                           247m         145Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-1                219m         1622Mi          
logging                  promtail-5jr9j                                                    198m         84Mi            
kube-system              cilium-22zgh                                                      182m         278Mi           
kube-system              tetragon-mdsn9                                                    169m         571Mi           
kube-system              kube-apiserver-nlk8s-ctrl03                                 144m         1327Mi          
kube-system              tetragon-vbs6v                                                    103m         147Mi           
kube-system              cilium-kghrg                                                      98m          293Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
logging                  loki-0                                                            70m          2179Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                219m         1622Mi          
seaweedfs                seaweedfs-filer-1                                                 58m          1618Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                296m         1561Mi          
awx                      my-awx-task-756d768868-k9sdd                                      20m          1517Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 333m         1473Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 144m         1327Mi          
awx                      my-awx-web-55ccb47b58-876cl                                       11m          1278Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 73m          1242Mi          
seaweedfs                seaweedfs-filer-0                                                 26m          1151Mi          
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
argocd            argocd-application-controller                     1               N/A               0                     214d
argocd            argocd-applicationset-controller                  1               N/A               0                     214d
argocd            argocd-redis                                      1               N/A               0                     214d
argocd            argocd-repo-server                                1               N/A               1                     214d
argocd            argocd-server                                     1               N/A               1                     214d
awx               awx-postgres-pdb                                  1               N/A               0                     214d
awx               awx-task-pdb                                      1               N/A               0                     214d
awx               awx-web-pdb                                       1               N/A               0                     214d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     214d
kube-system       coredns-pdb                                       1               N/A               1                     214d
kube-system       metrics-server-pdb                                1               N/A               0                     214d
monitoring        monitoring-grafana                                1               N/A               1                     79d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     79d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     79d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     214d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     100d
seaweedfs         seaweedfs-master                                  2               N/A               1                     100d
seaweedfs         seaweedfs-volume                                  1               N/A               1                     100d
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
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   236d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               205d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 213d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                211d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 213d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 213d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   216d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        215d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        212d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        106d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   195d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        200d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        199d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        204d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        215d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        199d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        200d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        217d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        201d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        201d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        216d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   194d
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   217d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   237d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   214d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   214d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   214d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   214d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   214d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   214d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   214d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   214d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 4 |
| External Secrets | 15 |
| Certificates | 17 |
| ServiceMonitors | 27 |
| CiliumNetworkPolicies | 4 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE    PAUSED
daily-backup    Enabled   0 2 * * *   60m          216d   
weekly-backup   Enabled   0 3 * * 0   2d           216d   
```

### Recent Backups (last 5)
```
daily-backup-20260626020053    4d1h
daily-backup-20260627020055    3d1h
daily-backup-20260628020056    2d1h
weekly-backup-20260628030056   2d
daily-backup-20260629020057    25h
```

---

## Helm Releases
```
NAME                	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd              	argocd                	9       	2026-03-15 17:16:45.748376325 +0000 UTC	deployed	argo-cd-7.7.10                        	v2.13.2    
cert-manager        	cert-manager          	3       	2025-11-30 21:22:09.520251302 +0000 UTC	deployed	cert-manager-v1.17.1                  	v1.17.1    
cilium              	kube-system           	20      	2025-12-12 16:06:57.516153767 +0000 UTC	deployed	cilium-1.18.4                         	1.18.4     
external-secrets    	external-secrets      	2       	2025-12-16 13:20:23.175188029 +0000 UTC	deployed	external-secrets-1.1.1                	v1.1.1     
ingress-nginx       	ingress-nginx         	11      	2026-06-24 20:11:35.381051147 +0000 UTC	deployed	ingress-nginx-4.14.0                  	1.14.0     
k8s-agent           	REDACTED_01b50c5d	6       	2025-11-29 02:18:29.271243252 +0000 UTC	deployed	gitlab-agent-2.21.1                   	v18.6.1    
REDACTED_d97cef76	REDACTED_d97cef76  	2       	2026-02-25 19:02:27.096604857 +0000 UTC	deployed	REDACTED_d97cef76-7.14.0           	           
loki                	logging               	11      	2026-03-18 12:53:15.398191575 +0000 UTC	deployed	loki-6.46.0                           	3.5.7      
monitoring          	monitoring            	14      	2026-06-27 18:38:05.543993606 +0000 UTC	deployed	REDACTED_d8074874-79.10.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	8       	2025-11-29 02:18:25.900770326 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail            	logging               	8       	2026-03-14 22:22:09.209112925 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
seaweedfs           	seaweedfs             	7       	2026-06-25 16:11:58.816286654 +0000 UTC	deployed	seaweedfs-4.0.401                     	4.01       
synology-csi        	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
tetragon            	kube-system           	7       	2025-12-20 22:35:40.030282504 +0000 UTC	deployed	tetragon-1.6.0                        	1.6.0      
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   216d
awx                      Active   237d
bentopdf                 Active   212d
cert-manager             Active   211d
cilium-secrets           Active   213d
cilium-spire             Active   213d
default                  Active   238d
echo-server              Active   106d
external-secrets         Active   212d
gatus                    Active   195d
REDACTED_01b50c5d   Active   217d
ingress-nginx            Active   236d
kube-node-lease          Active   238d
kube-public              Active   238d
kube-system              Active   238d
REDACTED_d97cef76     Active   199d
logging                  Active   211d
monitoring               Active   237d
nfs-provisioner          Active   236d
opentofu-ns              Active   236d
pihole                   Active   217d
production               Active   217d
seaweedfs                Active   201d
synology-csi             Active   214d
velero                   Active   216d
well-known               Active   194d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           216d
argocd                   argocd-notifications-controller                   1/1     1            1           107d
argocd                   argocd-redis                                      1/1     1            1           216d
argocd                   argocd-repo-server                                2/2     2            2           216d
argocd                   argocd-server                                     2/2     2            2           216d
awx                      awx-operator-controller-manager                   1/1     1            1           237d
awx                      my-awx-task                                       1/1     1            1           237d
awx                      my-awx-web                                        1/1     1            1           237d
bentopdf                 bentopdf                                          1/1     1            1           212d
cert-manager             cert-manager                                      1/1     1            1           211d
cert-manager             cert-manager-cainjector                           1/1     1            1           211d
cert-manager             cert-manager-webhook                              1/1     1            1           211d
echo-server              echo-server                                       1/1     1            1           106d
external-secrets         external-secrets                                  1/1     1            1           212d
external-secrets         external-secrets-cert-controller                  1/1     1            1           212d
external-secrets         external-secrets-webhook                          1/1     1            1           212d
gatus                    gatus                                             1/1     1            1           195d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           217d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           236d
kube-system              cilium-operator                                   1/1     1            1           213d
kube-system              clustermesh-apiserver                             1/1     1            1           205d
kube-system              coredns                                           2/2     2            2           238d
kube-system              hubble-relay                                      1/1     1            1           213d
kube-system              hubble-ui                                         1/1     1            1           213d
kube-system              metrics-server                                    1/1     1            1           237d
kube-system              tetragon-operator                                 1/1     1            1           192d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           199d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           199d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           199d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           199d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           199d
monitoring               bgpalerter                                        1/1     1            1           197d
monitoring               monitoring-grafana                                2/2     2            2           79d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           79d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           79d
monitoring               snmp-exporter                                     1/1     1            1           199d
monitoring               thanos-query                                      2/2     2            2           200d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           236d
pihole                   pihole                                            1/1     1            1           212d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           200d
velero                   velero                                            1/1     1            1           216d
velero                   velero-ui                                         1/1     1            1           216d
well-known               well-known                                        1/1     1            1           194d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     216d
awx            my-awx-postgres-15                                     1/1     237d
cilium-spire   spire-server                                           1/1     213d
logging        loki                                                   1/1     192d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     79d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     79d
monitoring     thanos-compactor                                       1/1     200d
monitoring     thanos-store                                           2/2     200d
seaweedfs      seaweedfs-filer                                        2/2     201d
seaweedfs      seaweedfs-master                                       3/3     201d
seaweedfs      seaweedfs-volume                                       2/2     201d
synology-csi   synology-csi-controller                                1/1     214d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   213d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   213d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   213d
kube-system    tetragon                              7         7         7       7            7           <none>                   192d
logging        loki-canary                           4         4         4       4            4           <none>                   200d
logging        promtail                              7         7         7       7            7           <none>                   211d
monitoring     goldpinger                            7         7         7       7            7           <none>                   204d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   79d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   214d
velero         velero-node-agent                     4         4         4       4            4           <none>                   216d
```

---

*Full cluster context dump - v3.1.0*
