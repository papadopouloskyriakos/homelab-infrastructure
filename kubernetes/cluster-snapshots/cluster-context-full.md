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

**Generated:** 2026-03-27 03:00:12 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | DEGRADED | ⚠️ |
| Unhealthy Pods | 5 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 1387 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.18.4 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 157 |

### Node Details (with Taints & Labels)

#### nlk8s-ctrl01
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8005572Ki
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
```
default                  node-debugger-nlk8s-node01-drblb                             0/1   Error              0                10h
default                  node-debugger-nlk8s-node02-5wkqg                             0/1   Error              0                10h
default                  node-debugger-nlk8s-node03-jjmv9                             0/1   Error              0                10h
default                  node-debugger-nlk8s-node04-zmc56                             0/1   Error              0                10h
kube-system              kube-apiserver-nlk8s-ctrl01                                 0/1   CrashLoopBackOff   519 (55s ago)    120d
```

#### Unhealthy Pod Details

**default/node-debugger-nlk8s-node01-drblb:**
```
Events:                      <none>
```

**default/node-debugger-nlk8s-node02-5wkqg:**
```
Events:                      <none>
```

**default/node-debugger-nlk8s-node03-jjmv9:**
```
Events:                      <none>
```

**default/node-debugger-nlk8s-node04-zmc56:**
```
Events:                      <none>
```

**kube-system/kube-apiserver-nlk8s-ctrl01:**
```
Events:
  Type     Reason     Age                     From     Message
  ----     ------     ----                    ----     -------
  Warning  Unhealthy  14m (x595 over 44h)     kubelet  Liveness probe failed: HTTP probe failed with statuscode: 500
  Warning  Unhealthy  13m (x2719 over 44h)    kubelet  Readiness probe failed: HTTP probe failed with statuscode: 500
  Normal   Killing    12m (x33 over 44h)      kubelet  Container kube-apiserver failed liveness probe, will be restarted
  Warning  Unhealthy  10m (x2828 over 44h)    kubelet  Readiness probe failed: Get "https://10.0.X.X:6443/readyz": dial tcp 10.0.X.X:6443: connect: connection refused
  Warning  Failed     2m20s (x13 over 4m56s)  kubelet  Error: failed to reserve container name "kube-apiserver_kube-apiserver-nlk8s-ctrl01_kube-system_e6c71440b6c04026167886206323b860_518": name "kube-apiserver_kube-apiserver-nlk8s-ctrl01_kube-system_e6c71440b6c04026167886206323b860_518" is reserved for "8959b620ebe6ba5a3d718ea00c8f137594a59614250416cda78c16c106d3b9d3"
  Normal   Pulled     91s (x51 over 44h)      kubelet  Container image "registry.k8s.io/kube-apiserver:v1.34.2" already present on machine
  Normal   Created    82s (x32 over 44h)      kubelet  Created container: kube-apiserver
  Normal   Started    78s (x32 over 44h)      kubelet  Started container kube-apiserver
```

### High Restart Pods (>3 restarts)
- cert-manager/cert-manager-75944f484-4v6qh: 15 restarts
- cert-manager/cert-manager-cainjector-56b4cf957-s7xd9: 13 restarts
- cilium-spire/spire-agent-xwbn2: 9 restarts
- cilium-spire/spire-server-0: 4 restarts
- kube-system/cilium-22zgh: 9 restarts
- kube-system/cilium-envoy-mmfnj: 9 restarts
- kube-system/cilium-operator-6b94496fcd-l6cjl: 100 restarts
- kube-system/etcd-nlk8s-ctrl01: 89 restarts
- kube-system/etcd-nlk8s-ctrl02: 39 restarts
- kube-system/etcd-nlk8s-ctrl03: 6 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 519 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 57 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 14 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 92 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 30 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 80 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 29 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 27 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 26 restarts
- kube-system/tetragon-878gv: 4 restarts
- kube-system/tetragon-mdsn9: 18 restarts
- kube-system/tetragon-vbs6v: 4 restarts
- logging/loki-0: 7 restarts
- monitoring/goldpinger-4fvxd: 10 restarts
- monitoring/goldpinger-b44g9: 4 restarts
- monitoring/goldpinger-cjzc4: 5 restarts
- monitoring/goldpinger-f72lw: 4 restarts
- monitoring/goldpinger-qs5xt: 5 restarts
- monitoring/goldpinger-vtfpx: 5 restarts
- monitoring/monitoring-grafana-777dc75f9-85gdv: 18 restarts
- monitoring/monitoring-grafana-777dc75f9-hl9fb: 12 restarts
- monitoring/monitoring-kube-state-metrics-74d579585b-6cprn: 19 restarts
- monitoring/monitoring-prometheus-node-exporter-d5wkz: 9 restarts
- monitoring/monitoring-prometheus-node-exporter-f2fld: 6 restarts
- monitoring/thanos-compactor-0: 7 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956swwjx: 30 restarts
- synology-csi/synology-csi-node-kxrjb: 4 restarts
- synology-csi/synology-csi-node-l72f8: 4 restarts
- synology-csi/synology-csi-node-zch7n: 18 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE                LAST SEEN   TYPE      REASON                  OBJECT                                                       MESSAGE
kube-system              14m         Warning   Unhealthy               pod/kube-apiserver-nlk8s-ctrl01                        Liveness probe failed: HTTP probe failed with statuscode: 500
kube-system              14m         Warning   Unhealthy               pod/metrics-server-56fb9549f4-n2lpf                          Liveness probe failed: Get "https://10.0.2.94:10250/livez": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
kube-system              13m         Warning   Unhealthy               pod/cilium-envoy-cfv8x                                       Liveness probe failed: Get "http://127.0.0.1:9878/healthz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
kube-system              13m         Warning   Unhealthy               pod/metrics-server-56fb9549f4-n2lpf                          Liveness probe failed: Get "https://10.0.2.94:10250/livez": context deadline exceeded
kube-system              13m         Warning   Unhealthy               pod/kube-scheduler-nlk8s-ctrl01                        Readiness probe failed: Get "https://127.0.0.1:10259/readyz": net/http: request canceled (Client.Timeout exceeded while awaiting headers)
ingress-nginx            13m         Warning   Unhealthy               pod/ingress-nginx-controller-76d94fd664-6kpks                Readiness probe failed: Get "http://10.0.2.174:10254/healthz": EOF (Client.Timeout exceeded while awaiting headers)
monitoring               13m         Warning   Unhealthy               pod/monitoring-prometheus-node-exporter-hc6cl                Liveness probe failed: Get "http://10.0.X.X:9100/": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
argocd                   13m         Warning   Unhealthy               pod/argocd-repo-server-7dfc645f84-m8vmz                      Liveness probe failed: Get "http://10.0.2.177:8084/healthz?full=true": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
kube-system              13m         Warning   Unhealthy               pod/hubble-relay-8577574994-968m4                            Liveness probe failed: timeout: health rpc did not complete within 10s
kube-system              13m         Warning   Unhealthy               pod/metrics-server-56fb9549f4-n2lpf                          Readiness probe failed: Get "https://10.0.2.94:10250/readyz": net/http: request canceled (Client.Timeout exceeded while awaiting headers)
kube-system              13m         Warning   Unhealthy               pod/kube-scheduler-nlk8s-ctrl03                        Startup probe failed: Get "https://127.0.0.1:10259/livez": net/http: TLS handshake timeout
kube-system              13m         Warning   Unhealthy               pod/kube-controller-manager-nlk8s-ctrl01               Liveness probe failed: Get "https://127.0.0.1:10257/healthz": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
kube-system              13m         Warning   Unhealthy               pod/metrics-server-56fb9549f4-n2lpf                          Readiness probe failed: Get "https://10.0.2.94:10250/readyz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
kube-system              13m         Warning   Unhealthy               pod/tetragon-operator-f674b87f4-42p9n                        Liveness probe failed: Get "http://10.0.2.12:8081/healthz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
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
nlk8s-ctrl01   1241m        15%      2387Mi          30%         
nlk8s-ctrl02   1024m        25%      3061Mi          37%         
nlk8s-ctrl03   295m         7%       3557Mi          45%         
nlk8s-node01    904m         11%      3985Mi          50%         
nlk8s-node02    502m         6%       4373Mi          55%         
nlk8s-node03    305m         3%       4893Mi          62%         
nlk8s-node04    285m         3%       4701Mi          60%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              cilium-kghrg                                                      274m         214Mi           
monitoring               bgpalerter-596d7b756b-256bk                                       262m         590Mi           
kube-system              kube-apiserver-nlk8s-ctrl02                                 253m         1325Mi          
kube-system              etcd-nlk8s-ctrl02                                           236m         154Mi           
kube-system              tetragon-mdsn9                                                    209m         496Mi           
kube-system              cilium-mvsq5                                                      204m         234Mi           
kube-system              cilium-gz5mp                                                      180m         397Mi           
kube-system              cilium-22zgh                                                      155m         291Mi           
kube-system              tetragon-vbs6v                                                    153m         148Mi           
kube-system              kube-apiserver-nlk8s-ctrl03                                 128m         1581Mi          
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              kube-apiserver-nlk8s-ctrl03                                 128m         1581Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 253m         1325Mi          
awx                      my-awx-web-7b5c595b4b-pg7v7                                       5m           1284Mi          
seaweedfs                seaweedfs-volume-0                                                12m          1254Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                48m          1252Mi          
awx                      my-awx-task-756d768868-k9sdd                                      18m          1229Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                105m         1219Mi          
logging                  loki-0                                                            38m          768Mi           
monitoring               monitoring-grafana-777dc75f9-85gdv                                40m          740Mi           
monitoring               monitoring-grafana-777dc75f9-hl9fb                                47m          710Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
monitoring: CPU=2120m Mem=7600Mi
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
argocd            argocd-application-controller                     1               N/A               0                     119d
argocd            argocd-applicationset-controller                  1               N/A               0                     119d
argocd            argocd-redis                                      1               N/A               0                     119d
argocd            argocd-repo-server                                1               N/A               1                     119d
argocd            argocd-server                                     1               N/A               1                     119d
awx               awx-postgres-pdb                                  1               N/A               0                     119d
awx               awx-task-pdb                                      1               N/A               0                     119d
awx               awx-web-pdb                                       1               N/A               0                     119d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     119d
kube-system       coredns-pdb                                       1               N/A               1                     119d
kube-system       metrics-server-pdb                                1               N/A               0                     119d
monitoring        monitoring-grafana                                1               N/A               1                     119d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     119d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     119d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     119d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     5d15h
seaweedfs         seaweedfs-master                                  2               N/A               1                     5d15h
seaweedfs         seaweedfs-volume                                  1               N/A               1                     5d15h
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
| ClusterIP | 70 |
| NodePort | 6 |
| LoadBalancer | 6 |

### LoadBalancer Services
```
NAMESPACE       NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   141d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               110d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 118d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                116d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 118d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 118d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   121d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        120d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        117d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        11d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   100d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        105d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        104d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        109d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        120d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        104d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        105d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        122d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        106d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        106d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        121d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   99d
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   122d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   142d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   119d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   119d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   119d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   119d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   119d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   119d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   119d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   119d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 4 |
| External Secrets | 14 |
| Certificates | 12 |
| ServiceMonitors | 26 |
| CiliumNetworkPolicies | 4 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE    PAUSED
daily-backup    Enabled   0 2 * * *   72m          121d   
weekly-backup   Enabled   0 3 * * 0   5d           121d   
```

### Recent Backups (last 5)
```
weekly-backup-20260322030048   5d
daily-backup-20260323020049    4d1h
daily-backup-20260324020050    3d1h
daily-backup-20260325020010    2d1h
daily-backup-20260326020025    25h
```

---

## Helm Releases
```
NAME                	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd              	argocd                	9       	2026-03-15 17:16:45.748376325 +0000 UTC	deployed	argo-cd-7.7.10                        	v2.13.2    
cert-manager        	cert-manager          	3       	2025-11-30 21:22:09.520251302 +0000 UTC	deployed	cert-manager-v1.17.1                  	v1.17.1    
cilium              	kube-system           	20      	2025-12-12 16:06:57.516153767 +0000 UTC	deployed	cilium-1.18.4                         	1.18.4     
external-secrets    	external-secrets      	2       	2025-12-16 13:20:23.175188029 +0000 UTC	deployed	external-secrets-1.1.1                	v1.1.1     
ingress-nginx       	ingress-nginx         	9       	2026-03-11 00:24:34.420335322 +0000 UTC	deployed	ingress-nginx-4.14.0                  	1.14.0     
k8s-agent           	REDACTED_01b50c5d	6       	2025-11-29 02:18:29.271243252 +0000 UTC	deployed	gitlab-agent-2.21.1                   	v18.6.1    
REDACTED_d97cef76	REDACTED_d97cef76  	2       	2026-02-25 19:02:27.096604857 +0000 UTC	deployed	REDACTED_d97cef76-7.14.0           	           
loki                	logging               	11      	2026-03-18 12:53:15.398191575 +0000 UTC	deployed	loki-6.46.0                           	3.5.7      
monitoring          	monitoring            	32      	2026-03-25 02:52:13.79941075 +0000 UTC 	deployed	REDACTED_d8074874-79.10.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	8       	2025-11-29 02:18:25.900770326 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail            	logging               	8       	2026-03-14 22:22:09.209112925 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
seaweedfs           	seaweedfs             	4       	2026-03-24 23:55:06.526656769 +0000 UTC	deployed	seaweedfs-4.0.401                     	4.01       
synology-csi        	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
tetragon            	kube-system           	7       	2025-12-20 22:35:40.030282504 +0000 UTC	deployed	tetragon-1.6.0                        	1.6.0      
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   121d
awx                      Active   142d
bentopdf                 Active   117d
cert-manager             Active   116d
cilium-secrets           Active   118d
cilium-spire             Active   118d
default                  Active   143d
echo-server              Active   11d
external-secrets         Active   117d
gatus                    Active   100d
REDACTED_01b50c5d   Active   122d
ingress-nginx            Active   141d
kube-node-lease          Active   143d
kube-public              Active   143d
kube-system              Active   143d
REDACTED_d97cef76     Active   104d
logging                  Active   116d
monitoring               Active   142d
nfs-provisioner          Active   141d
opentofu-ns              Active   141d
pihole                   Active   122d
production               Active   122d
seaweedfs                Active   106d
synology-csi             Active   119d
velero                   Active   121d
well-known               Active   99d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           121d
argocd                   argocd-notifications-controller                   1/1     1            1           12d
argocd                   argocd-redis                                      1/1     1            1           121d
argocd                   argocd-repo-server                                2/2     2            2           121d
argocd                   argocd-server                                     2/2     2            2           121d
awx                      awx-operator-controller-manager                   1/1     1            1           142d
awx                      my-awx-task                                       1/1     1            1           142d
awx                      my-awx-web                                        1/1     1            1           142d
bentopdf                 bentopdf                                          1/1     1            1           117d
cert-manager             cert-manager                                      1/1     1            1           116d
cert-manager             cert-manager-cainjector                           1/1     1            1           116d
cert-manager             cert-manager-webhook                              1/1     1            1           116d
echo-server              echo-server                                       1/1     1            1           11d
external-secrets         external-secrets                                  1/1     1            1           117d
external-secrets         external-secrets-cert-controller                  1/1     1            1           117d
external-secrets         external-secrets-webhook                          1/1     1            1           117d
gatus                    gatus                                             1/1     1            1           100d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           122d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           141d
kube-system              cilium-operator                                   1/1     1            1           118d
kube-system              clustermesh-apiserver                             1/1     1            1           110d
kube-system              coredns                                           2/2     2            2           143d
kube-system              hubble-relay                                      1/1     1            1           118d
kube-system              hubble-ui                                         1/1     1            1           118d
kube-system              metrics-server                                    1/1     1            1           142d
kube-system              tetragon-operator                                 1/1     1            1           97d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           104d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           104d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           104d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           104d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           104d
monitoring               bgpalerter                                        1/1     1            1           102d
monitoring               monitoring-grafana                                2/2     2            2           119d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           141d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           141d
monitoring               snmp-exporter                                     1/1     1            1           104d
monitoring               thanos-query                                      2/2     2            2           105d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           141d
pihole                   pihole                                            1/1     1            1           117d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           105d
velero                   velero                                            1/1     1            1           121d
velero                   velero-ui                                         1/1     1            1           121d
well-known               well-known                                        1/1     1            1           99d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     121d
awx            my-awx-postgres-15                                     1/1     142d
cilium-spire   spire-server                                           1/1     118d
logging        loki                                                   1/1     97d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     119d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     119d
monitoring     thanos-compactor                                       1/1     105d
monitoring     thanos-store                                           2/2     105d
seaweedfs      seaweedfs-filer                                        2/2     106d
seaweedfs      seaweedfs-master                                       3/3     106d
seaweedfs      seaweedfs-volume                                       2/2     106d
synology-csi   synology-csi-controller                                1/1     119d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   118d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   118d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   118d
kube-system    tetragon                              7         7         7       7            7           <none>                   97d
logging        loki-canary                           4         4         4       4            4           <none>                   105d
logging        promtail                              7         7         7       7            7           <none>                   116d
monitoring     goldpinger                            7         7         7       7            7           <none>                   109d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   141d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   119d
velero         velero-node-agent                     4         4         4       4            4           <none>                   121d
```

---

*Full cluster context dump - v3.1.0*
