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

**Generated:** 2026-08-04 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | DEGRADED | ⚠️ |
| Unhealthy Pods | 1 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 3195 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.19.5 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 192 |

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
```
ingress-nginx            ingress-nginx-controller-8445475547-cz8k2                         0/1   OOMKilled   0                  27d
```

#### Unhealthy Pod Details

**ingress-nginx/ingress-nginx-controller-8445475547-cz8k2:**
```
Events:                      <none>
```

### High Restart Pods (>3 restarts)
- argocd/argocd-repo-server-7dfc645f84-qxz64: 5 restarts
- argocd/argocd-server-64dd47d8bf-fkr26: 35 restarts
- awx/awx-operator-controller-manager-6ffdf98f6-hwvqf: 19 restarts
- cilium-spire/spire-agent-49g4h: 28 restarts
- cilium-spire/spire-agent-mdslp: 8 restarts
- cilium-spire/spire-server-0: 17 restarts
- REDACTED_01b50c5d/REDACTED_ab04b573-v2-8c85f5d4b-ng8lb: 24 restarts
- ingress-nginx/ingress-nginx-controller-8445475547-bwczk: 19 restarts
- ingress-nginx/ingress-nginx-controller-8445475547-mxdrc: 30 restarts
- kube-system/cilium-operator-6cdbfb68d7-z6v2x: 6 restarts
- kube-system/clustermesh-apiserver-6c96779765-rmrzt: 42 restarts
- kube-system/etcd-nlk8s-ctrl01: 64 restarts
- kube-system/hubble-ui-6bb97d8894-nnkx5: 21 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 1999 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 58 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 14 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 108 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 37 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 93 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 37 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 35 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 39 restarts
- kube-system/tetragon-75hdg: 6 restarts
- kube-system/tetragon-878gv: 4 restarts
- kube-system/tetragon-mdsn9: 18 restarts
- kube-system/tetragon-tbcc7: 4 restarts
- kube-system/tetragon-vbs6v: 14 restarts
- REDACTED_d97cef76/REDACTED_d97cef76-kong-5c7f96dd9b-fgxd9: 14 restarts
- logging/promtail-hp5sc: 7 restarts
- logging/promtail-ng69s: 4 restarts
- monitoring/goldpinger-25hf5: 44 restarts
- monitoring/goldpinger-6dj9l: 25 restarts
- monitoring/goldpinger-n2fzm: 8 restarts
- monitoring/goldpinger-zxtb9: 6 restarts
- monitoring/monitoring-kube-prometheus-operator-67d8d4c647-5955s: 38 restarts
- monitoring/monitoring-kube-state-metrics-75f9fff55b-6cc8x: 7 restarts
- monitoring/monitoring-prometheus-node-exporter-6dl8r: 174 restarts
- monitoring/monitoring-prometheus-node-exporter-6sc8j: 7 restarts
- monitoring/monitoring-prometheus-node-exporter-wmcb8: 42 restarts
- monitoring/prometheus-REDACTED_6dfbe9fc-0: 14 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956jjmld: 51 restarts
- synology-csi/synology-csi-node-577mq: 10 restarts
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
NAMESPACE      LAST SEEN   TYPE      REASON      OBJECT                                                     MESSAGE
monitoring     58m         Warning   Unhealthy   pod/monitoring-kube-state-metrics-75f9fff55b-6cc8x         Liveness probe failed: HTTP probe failed with statuscode: 503
kube-system    58m         Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl02                      Readiness probe failed: HTTP probe failed with statuscode: 500
kube-system    58m         Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl02                      Liveness probe failed: HTTP probe failed with statuscode: 500
monitoring     54m         Warning   Unhealthy   pod/monitoring-kube-prometheus-operator-67d8d4c647-5955s   Readiness probe failed: Get "https://10.0.3.94:10250/healthz": net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
cilium-spire   54m         Warning   Unhealthy   pod/spire-agent-49g4h                                      Readiness probe failed: Get "http://10.0.X.X:4251/ready": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
monitoring     14m         Warning   Unhealthy   pod/bgpalerter-789f984488-jpkvh                            Readiness probe failed: Get "http://10.0.6.70:8011/status": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
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
- PVC: data-seaweedfs-volume-0 (1000Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-volume-1 (1000Gi, Bound, sc:REDACTED_b280aec5)

**Secrets:**
- ExternalSecret: seaweedfs-s3-config (SecretSynced)

### Namespace: `synology-csi`

- **StatefulSet: synology-csi-controller** (1/1)

### Namespace: `velero`

1/- **Deployment: velero** (1) → Svc:velero-metrics (ClusterIP) → Ingress:velero.example.net
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
nlk8s-ctrl01   1349m        33%      2780Mi          35%         
nlk8s-ctrl02   1722m        43%      3419Mi          42%         
nlk8s-ctrl03   302m         7%       3061Mi          39%         
nlk8s-node01    361m         4%       5211Mi          66%         
nlk8s-node02    480m         6%       4270Mi          54%         
nlk8s-node03    398m         4%       6334Mi          81%         
nlk8s-node04    779m         9%       5331Mi          68%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              kube-apiserver-nlk8s-ctrl02                                 591m         1699Mi          
kube-system              etcd-nlk8s-ctrl02                                           300m         176Mi           
kube-system              cilium-8v6d6                                                      237m         213Mi           
kube-system              cilium-64v2f                                                      236m         182Mi           
kube-system              tetragon-mdsn9                                                    223m         651Mi           
logging                  promtail-hp5sc                                                    179m         220Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-1                122m         1676Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 117m         1583Mi          
kube-system              etcd-nlk8s-ctrl03                                           98m          142Mi           
kube-system              cilium-8prx7                                                      92m          222Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                58m          1775Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 591m         1699Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                122m         1676Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 117m         1583Mi          
seaweedfs                seaweedfs-filer-1                                                 25m          1570Mi          
awx                      my-awx-task-756d768868-k9sdd                                      18m          1528Mi          
awx                      my-awx-web-55ccb47b58-m95v8                                       5m           1512Mi          
seaweedfs                seaweedfs-volume-0                                                31m          1126Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 51m          984Mi           
logging                  loki-0                                                            72m          757Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
monitoring: CPU=2160m Mem=10928Mi
kube-system: CPU=2060m Mem=472Mi
awx: CPU=1855m Mem=3552Mi
ingress-nginx: CPU=1500m Mem=1536Mi
seaweedfs: CPU=1200m Mem=7424Mi
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
argocd            argocd-application-controller                     1               N/A               0                     249d
argocd            argocd-applicationset-controller                  1               N/A               0                     249d
argocd            argocd-redis                                      1               N/A               0                     249d
argocd            argocd-repo-server                                1               N/A               1                     249d
argocd            argocd-server                                     1               N/A               1                     249d
awx               awx-postgres-pdb                                  1               N/A               0                     249d
awx               awx-task-pdb                                      1               N/A               0                     249d
awx               awx-web-pdb                                       1               N/A               0                     249d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     249d
kube-system       coredns-pdb                                       1               N/A               1                     249d
kube-system       metrics-server-pdb                                1               N/A               0                     249d
monitoring        monitoring-grafana                                1               N/A               1                     114d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     114d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     114d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     249d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     135d
seaweedfs         seaweedfs-master                                  2               N/A               1                     135d
seaweedfs         seaweedfs-volume                                  1               N/A               1                     135d
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
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   271d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               240d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 248d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                246d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 248d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 248d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   251d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        250d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        247d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        141d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   230d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        235d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        234d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        239d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        250d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        234d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        235d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        252d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        236d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        236d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        251d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   229d
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   252d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   272d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   249d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   249d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   249d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   249d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   249d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   249d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   249d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   249d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 4 |
| External Secrets | 16 |
| Certificates | 21 |
| ServiceMonitors | 28 |
| CiliumNetworkPolicies | 4 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE    PAUSED
daily-backup    Enabled   0 2 * * *   61m          251d   false
weekly-backup   Enabled   0 3 * * 0   2d           251d   false
```

### Recent Backups (last 5)
```
verify-after-2090-fix          4d8h
daily-backup-20260801020015    3d1h
daily-backup-20260802020016    2d1h
weekly-backup-20260802030016   2d
daily-backup-20260803020017    25h
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
monitoring          	monitoring            	22      	2026-08-03 20:44:40.513485353 +0000 UTC	deployed	REDACTED_d8074874-79.12.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	8       	2025-11-29 02:18:25.900770326 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail            	logging               	8       	2026-03-14 22:22:09.209112925 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
seaweedfs           	seaweedfs             	15      	2026-08-01 04:01:07.781707084 +0000 UTC	deployed	seaweedfs-4.0.401                     	4.01       
synology-csi        	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
tetragon            	kube-system           	7       	2025-12-20 22:35:40.030282504 +0000 UTC	deployed	tetragon-1.6.0                        	1.6.0      
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   251d
awx                      Active   272d
bentopdf                 Active   247d
cert-manager             Active   246d
cilium-secrets           Active   248d
cilium-spire             Active   248d
default                  Active   273d
echo-server              Active   141d
external-secrets         Active   247d
gatus                    Active   230d
REDACTED_01b50c5d   Active   252d
ingress-nginx            Active   271d
kube-node-lease          Active   273d
kube-public              Active   273d
kube-system              Active   273d
REDACTED_d97cef76     Active   234d
logging                  Active   246d
monitoring               Active   272d
nfs-provisioner          Active   271d
opentofu-ns              Active   271d
pihole                   Active   252d
production               Active   252d
seaweedfs                Active   236d
synology-csi             Active   249d
velero                   Active   251d
well-known               Active   229d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           251d
argocd                   argocd-notifications-controller                   1/1     1            1           142d
argocd                   argocd-redis                                      1/1     1            1           251d
argocd                   argocd-repo-server                                2/2     2            2           251d
argocd                   argocd-server                                     2/2     2            2           251d
awx                      awx-operator-controller-manager                   1/1     1            1           272d
awx                      my-awx-task                                       1/1     1            1           272d
awx                      my-awx-web                                        1/1     1            1           272d
bentopdf                 bentopdf                                          1/1     1            1           247d
cert-manager             cert-manager                                      1/1     1            1           246d
cert-manager             cert-manager-cainjector                           1/1     1            1           246d
cert-manager             cert-manager-webhook                              1/1     1            1           246d
echo-server              echo-server                                       1/1     1            1           141d
external-secrets         external-secrets                                  1/1     1            1           247d
external-secrets         external-secrets-cert-controller                  1/1     1            1           247d
external-secrets         external-secrets-webhook                          1/1     1            1           247d
gatus                    gatus                                             1/1     1            1           230d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           252d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           271d
kube-system              cilium-operator                                   1/1     1            1           248d
kube-system              clustermesh-apiserver                             1/1     1            1           240d
kube-system              coredns                                           2/2     2            2           273d
kube-system              hubble-relay                                      1/1     1            1           248d
kube-system              hubble-ui                                         1/1     1            1           248d
kube-system              metrics-server                                    1/1     1            1           272d
kube-system              tetragon-operator                                 1/1     1            1           227d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           234d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           234d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           234d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           234d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           234d
monitoring               bgpalerter                                        1/1     1            1           232d
monitoring               monitoring-grafana                                2/2     2            2           114d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           114d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           114d
monitoring               snmp-exporter                                     1/1     1            1           234d
monitoring               thanos-query                                      2/2     2            2           235d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           271d
pihole                   pihole                                            1/1     1            1           247d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           235d
velero                   velero                                            1/1     1            1           251d
velero                   velero-ui                                         1/1     1            1           251d
well-known               well-known                                        1/1     1            1           229d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     251d
awx            my-awx-postgres-15                                     1/1     272d
cilium-spire   spire-server                                           1/1     248d
logging        loki                                                   1/1     227d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     114d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     114d
monitoring     thanos-compactor                                       1/1     235d
monitoring     thanos-store                                           2/2     235d
seaweedfs      seaweedfs-filer                                        2/2     236d
seaweedfs      seaweedfs-master                                       3/3     236d
seaweedfs      seaweedfs-volume                                       2/2     4d11h
synology-csi   synology-csi-controller                                1/1     249d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   248d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   248d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   248d
kube-system    tetragon                              7         7         7       7            7           <none>                   227d
logging        loki-canary                           4         4         4       4            4           <none>                   235d
logging        promtail                              7         7         7       7            7           <none>                   246d
monitoring     goldpinger                            7         7         7       7            7           <none>                   239d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   114d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   249d
velero         node-agent                            4         4         4       4            4           <none>                   6d13h
```

---

*Full cluster context dump - v3.1.0*
