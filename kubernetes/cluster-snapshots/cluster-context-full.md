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

**Generated:** 2025-12-06 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | DEGRADED | ⚠️ |
| Unhealthy Pods | 2 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 270 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.18.4 |
| Nodes | 8 total (3 control-plane, 5 workers) |
| Total Pods | 111 |

### Node Details (with Taints & Labels)

#### nlk8s-ctrl01
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 3795Mi
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=

#### nlk8s-ctrl02
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 3996Mi
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=

#### nlk8s-ctrl03
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 3886092Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=

#### nlk8s-node01
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006756Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker

#### nlk8s-node02
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006748Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker

#### nlk8s-node03
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006740Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker

#### nlk8s-node04
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006752Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker

#### notrf01k8s-node01
- **Role:** worker
- **IP:** 185.125.171.172
- **Status:** True
- **CPU:** 2 | **Memory:** 3907488Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux


---

## Anomalies & Issues

### Unhealthy Pods
```
cilium-spire             spire-agent-8n2ff                                                 0/1   Init:0/1           5 (2m33s ago)    9m25s
velero                   velero-node-agent-fbdfq                                           0/1   CrashLoopBackOff   6 (72s ago)      8m58s
```

#### Unhealthy Pod Details

**cilium-spire/spire-agent-8n2ff:**
```
Events:
  Type     Reason     Age                 From               Message
  ----     ------     ----                ----               -------
  Normal   Scheduled  9m24s               default-scheduler  Successfully assigned cilium-spire/spire-agent-8n2ff to notrf01k8s-node01
  Normal   Pulling    9m21s               kubelet            Pulling image "docker.io/library/busybox:1.37.0@sha256:e3652a00a2fabd16ce889f0aa32c38eec347b997e73bd09e69c962ec7f8732ee"
  Normal   Pulled     9m8s                kubelet            Successfully pulled image "docker.io/library/busybox:1.37.0@sha256:e3652a00a2fabd16ce889f0aa32c38eec347b997e73bd09e69c962ec7f8732ee" in 2.498s (12.764s including waiting). Image size: 2224358 bytes.
  Warning  BackOff    73s (x13 over 7m)   kubelet            Back-off restarting failed container init in pod spire-agent-8n2ff_cilium-spire(3f8eefc4-a263-4385-9750-01760a4d1dbf)
  Normal   Created    58s (x6 over 9m8s)  kubelet            Created container: init
  Normal   Started    58s (x6 over 9m8s)  kubelet            Started container init
  Normal   Pulled     58s (x5 over 8m3s)  kubelet            Container image "docker.io/library/busybox:1.37.0@sha256:e3652a00a2fabd16ce889f0aa32c38eec347b997e73bd09e69c962ec7f8732ee" already present on machine
```

**velero/velero-node-agent-fbdfq:**
```
Events:
  Type     Reason     Age                    From               Message
  ----     ------     ----                   ----               -------
  Normal   Scheduled  8m58s                  default-scheduler  Successfully assigned velero/velero-node-agent-fbdfq to notrf01k8s-node01
  Normal   Pulling    8m56s                  kubelet            Pulling image "velero/velero:v1.17.1"
  Normal   Pulled     8m51s                  kubelet            Successfully pulled image "velero/velero:v1.17.1" in 4.499s (5.215s including waiting). Image size: 80895593 bytes.
  Warning  BackOff    107s (x26 over 7m56s)  kubelet            Back-off restarting failed container node-agent in pod velero-node-agent-fbdfq_velero(d36ab493-1887-4554-a32b-4cba8c39f99d)
  Normal   Created    81s (x7 over 8m51s)    kubelet            Created container: node-agent
  Normal   Started    81s (x7 over 8m51s)    kubelet            Started container node-agent
  Normal   Pulled     81s (x6 over 8m7s)     kubelet            Container image "velero/velero:v1.17.1" already present on machine
```

### High Restart Pods (>3 restarts)
- awx/awx-operator-controller-manager-79499d9678-hr474: 6 restarts
- awx/my-awx-web-694487457f-9r975: 7 restarts
- kube-system/cilium-envoy-ntrv6: 4 restarts
- kube-system/cilium-operator-67ff4f447c-7zv95: 5 restarts
- kube-system/cilium-x58c7: 4 restarts
- kube-system/etcd-nlk8s-ctrl01: 7 restarts
- kube-system/etcd-nlk8s-ctrl02: 5 restarts
- kube-system/etcd-nlk8s-ctrl03: 4 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 24 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 5 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 5 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 22 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 10 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 14 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 17 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 12 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 13 restarts
- logging/promtail-j42hf: 4 restarts
- monitoring/monitoring-prometheus-node-exporter-95m6x: 5 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-855bd85b44jwmvk: 4 restarts
- synology-csi/synology-csi-node-465rx: 10 restarts
- synology-csi/synology-csi-node-5sj22: 8 restarts
- synology-csi/synology-csi-node-5tmgb: 10 restarts
- synology-csi/synology-csi-node-7ssk7: 10 restarts
- synology-csi/synology-csi-node-hmvnt: 14 restarts
- synology-csi/synology-csi-node-jw295: 8 restarts
- synology-csi/synology-csi-node-mx7bm: 8 restarts
- velero/velero-node-agent-fbdfq: 6 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE      LAST SEEN   TYPE      REASON             OBJECT                                          MESSAGE
kube-system    9m25s       Warning   FailedScheduling   pod/cilium-envoy-77slm                          0/8 nodes are available: 1 node(s) didn't match pod affinity rules, 7 node(s) didn't satisfy plugin(s) [NodeAffinity]. no new claims to deallocate, preemption: 0/8 nodes are available: 8 Preemption is not helpful for scheduling.
kube-system    25m         Warning   Unhealthy          pod/kube-apiserver-nlk8s-ctrl01           Readiness probe failed: HTTP probe failed with statuscode: 500
velero         108s        Warning   BackOff            pod/velero-node-agent-fbdfq                     Back-off restarting failed container node-agent in pod velero-node-agent-fbdfq_velero(d36ab493-1887-4554-a32b-4cba8c39f99d)
kube-system    86s         Warning   DNSConfigForming   pod/cilium-fvklh                                Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
kube-system    78s         Warning   DNSConfigForming   pod/cilium-envoy-77slm                          Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
cilium-spire   74s         Warning   BackOff            pod/spire-agent-8n2ff                           Back-off restarting failed container init in pod spire-agent-8n2ff_cilium-spire(3f8eefc4-a263-4385-9750-01760a4d1dbf)
monitoring     37s         Warning   DNSConfigForming   pod/monitoring-prometheus-node-exporter-9m8bt   Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
synology-csi   6s          Warning   DNSConfigForming   pod/synology-csi-node-w4rrp                     Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
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

### Namespace: `REDACTED_01b50c5d`

2/- **Deployment: REDACTED_ab04b573-v2** (2)

### Namespace: `ingress-nginx`

2/- **Deployment: ingress-nginx-controller** (2)

### Namespace: `REDACTED_d97cef76`

1/- **Deployment: dashboard-metrics-scraper** (1) → Svc:dashboard-metrics-scraper (ClusterIP) → Ingress:k8s.example.net
1/- **Deployment: REDACTED_d97cef76** (1) → Svc:REDACTED_d97cef76 (NodePort) → Ingress:k8s.example.net

### Namespace: `logging`

- **StatefulSet: loki** (1/1)

**Storage:**
- PVC: storage-loki-0 (10Gi, Bound, sc:REDACTED_4f3da73d)

**Secrets:**
- ExternalSecret: loki-minio-credentials (SecretSynced)

### Namespace: `minio`

1/- **Deployment: minio** (1) → Svc:minio-api (NodePort) → Ingress:minio.example.net

**Storage:**
- PVC: minio-data-csi (1Ti, Bound, sc:REDACTED_b280aec5)

**Secrets:**
- ExternalSecret: minio-credentials (SecretSynced)
- ExternalSecret: minio-snapshot-credentials (SecretSynced)

### Namespace: `monitoring`

2/- **Deployment: monitoring-grafana** (2) → Ingress:grafana.example.net
1/- **Deployment: monitoring-kube-prometheus-operator** (1) → Ingress:grafana.example.net
1/- **Deployment: monitoring-kube-state-metrics** (1) → Ingress:grafana.example.net
- **StatefulSet: alertmanager-monitoring-kube-prometheus-alertmanager** (2/2)
- **StatefulSet: prometheus-REDACTED_6dfbe9fc** (2/2)

**Storage:**
- PVC: alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-0 (10Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-1 (10Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: monitoring-grafana (20Gi, Bound, sc:nfs-client)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-0 (200Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-1 (200Gi, Bound, sc:REDACTED_4f3da73d)

**Secrets:**
- ExternalSecret: monitoring-grafana (SecretSynced)

### Namespace: `nfs-provisioner`

1/- **Deployment: nfs-provisioner-REDACTED_5fef70be** (1)

### Namespace: `pihole`

1/- **Deployment: pihole** (1) → Svc:pihole-dns-lb (LoadBalancer 10.0.X.X) → Ingress:pihole.example.net

**Storage:**
- PVC: pihole-data (1Gi, Bound, sc:nfs-client)

**Secrets:**
- ExternalSecret: pihole-credentials (SecretSynced)

### Namespace: `synology-csi`

- **StatefulSet: synology-csi-controller** (1/1)

### Namespace: `velero`

1/- **Deployment: velero** (1) → Svc:velero-ui (NodePort) → Ingress:velero.example.net
1/- **Deployment: velero-ui** (1) → Svc:velero-ui (NodePort) → Ingress:velero.example.net

**Secrets:**
- ExternalSecret: velero-repo-credentials (SecretSynced)
- ExternalSecret: velero-s3-credentials (SecretSynced)


---

## Resource Analysis

### Node Utilization
```
NAME                 CPU(cores)   CPU(%)      MEMORY(bytes)   MEMORY(%)   
nlk8s-ctrl01   1401m        35%         1958Mi          51%         
nlk8s-ctrl02   759m         18%         2293Mi          57%         
nlk8s-ctrl03   266m         6%          2125Mi          56%         
nlk8s-node01    171m         2%          2480Mi          31%         
nlk8s-node02    176m         2%          2397Mi          30%         
nlk8s-node03    187m         2%          4143Mi          52%         
nlk8s-node04    252m         3%          4443Mi          56%         
notrf01k8s-node01    <unknown>    <unknown>   <unknown>       <unknown>   
chzrh01k8s-node01    <unknown>    <unknown>   <unknown>       <unknown>   
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              kube-apiserver-nlk8s-ctrl02                                 242m         963Mi           
kube-system              etcd-nlk8s-ctrl02                                           196m         121Mi           
kube-system              kube-apiserver-nlk8s-ctrl03                                 167m         1257Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 128m         820Mi           
kube-system              cilium-88kc5                                                      114m         380Mi           
kube-system              cilium-l2lvv                                                      105m         394Mi           
kube-system              hubble-ui-576dcd986f-wthq8                                        82m          107Mi           
kube-system              etcd-nlk8s-ctrl03                                           67m          117Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-1                64m          1064Mi          
kube-system              cilium-x58c7                                                      63m          232Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
awx                      my-awx-task-665479ff65-rns8g                                      19m          1343Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 167m         1257Mi          
awx                      my-awx-web-694487457f-9r975                                       5m           1211Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                64m          1064Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 242m         963Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-0                37m          888Mi           
monitoring               monitoring-grafana-6ff995d97c-hsfcm                               10m          873Mi           
monitoring               monitoring-grafana-6ff995d97c-f8rwv                               10m          863Mi           
kube-system              kube-apiserver-nlk8s-ctrl01                                 128m         820Mi           
kube-system              cilium-l2lvv                                                      105m         394Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
kube-system: CPU=2050m Mem=440Mi
awx: CPU=1855m Mem=3552Mi
monitoring: CPU=1200m Mem=4496Mi
ingress-nginx: CPU=1000m Mem=1024Mi
argocd: CPU=750m Mem=1664Mi
velero: CPU=650m Mem=832Mi
logging: CPU=500m Mem=768Mi
minio: CPU=100m Mem=256Mi
pihole: CPU=100m Mem=256Mi
bentopdf: CPU=50m Mem=64Mi
```

---

## Network & Security

### PodDisruptionBudgets
```
NAMESPACE         NAME                                              MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
argocd            argocd-application-controller                     1               N/A               0                     8d
argocd            argocd-applicationset-controller                  1               N/A               0                     8d
argocd            argocd-redis                                      1               N/A               0                     8d
argocd            argocd-repo-server                                1               N/A               1                     8d
argocd            argocd-server                                     1               N/A               1                     8d
awx               awx-postgres-pdb                                  1               N/A               0                     8d
awx               awx-task-pdb                                      1               N/A               0                     8d
awx               awx-web-pdb                                       1               N/A               0                     8d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     8d
kube-system       coredns-pdb                                       1               N/A               1                     8d
kube-system       metrics-server-pdb                                1               N/A               0                     8d
minio             minio-pdb                                         1               N/A               0                     8d
monitoring        monitoring-grafana                                1               N/A               1                     8d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     8d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     8d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     8d
```

### CiliumNetworkPolicies
- CiliumNetworkPolicies: 2
- CiliumClusterwideNetworkPolicies: 0

**Policies by namespace:**
- logging: 1 policies
- pihole: 1 policies

### Services by Type
| Type | Count |
|------|-------|
| ClusterIP | 47 |
| NodePort | 9 |
| LoadBalancer | 5 |

### LoadBalancer Services
```
NAMESPACE       NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   30d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 7d6h
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                5d1h
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 7d5h
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 7d5h
```

### Ingresses
```
NAMESPACE              NAME                   CLASS   HOSTS                          ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx   argocd.example.net     10.0.X.X   80, 443   10d
awx                    awx                    nginx   awx.example.net        10.0.X.X   80        9d
bentopdf               bentopdf               nginx   bentopdf.example.net   10.0.X.X   80        6d12h
kube-system            hubble-ui              nginx   hubble.example.net     10.0.X.X   80, 443   7d12h
REDACTED_d97cef76   REDACTED_d97cef76   nginx   k8s.example.net        10.0.X.X   80        9d
minio                  minio-console          nginx   minio.example.net      10.0.X.X   80        11d
monitoring             grafana                nginx   grafana.example.net    10.0.X.X   80        9d
pihole                 pihole-ingress         nginx   pihole.example.net     10.0.X.X   80        11d
velero                 velero-ui              nginx   velero.example.net     10.0.X.X   80        10d
```

---

#***REMOVED***

| Metric | Count |
|--------|-------|
| StorageClasses | 10 |
| PersistentVolumes | 14 |
| PersistentVolumeClaims | 11 |

##***REMOVED***Classes
```
NAME                                      PROVISIONER                                                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   11d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   31d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   8d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   8d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   8d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   8d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   8d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   8d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   8d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   8d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 3 |
| External Secrets | 12 |
| Certificates | 1 |
| ServiceMonitors | 21 |
| CiliumNetworkPolicies | 2 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE   PAUSED
daily-backup    Enabled   0 2 * * *   61m          10d   
weekly-backup   Enabled   0 3 * * 0   6d           10d   
```

### Recent Backups (last 5)
```
daily-backup-20251201020003    5d1h
daily-backup-20251202020008    4d1h
daily-backup-20251203020009    3d1h
daily-backup-20251204020010    2d1h
daily-backup-20251205020011    25h
```

---

## Helm Releases
```
NAME            	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd          	argocd                	3       	2025-11-29 02:18:52.98547378 +0000 UTC 	deployed	argo-cd-7.7.10                        	v2.13.2    
cert-manager    	cert-manager          	3       	2025-11-30 21:22:09.520251302 +0000 UTC	deployed	cert-manager-v1.17.1                  	v1.17.1    
cilium          	kube-system           	8       	2025-12-02 22:13:01.778472201 +0000 UTC	deployed	cilium-1.18.4                         	1.18.4     
external-secrets	external-secrets      	1       	2025-11-29 19:53:58.182715236 +0000 UTC	deployed	external-secrets-0.12.1               	v0.12.1    
ingress-nginx   	ingress-nginx         	6       	2025-11-30 20:29:39.171185711 +0000 UTC	deployed	ingress-nginx-4.14.0                  	1.14.0     
k8s-agent       	REDACTED_01b50c5d	6       	2025-11-29 02:18:29.271243252 +0000 UTC	deployed	gitlab-agent-2.21.1                   	v18.6.1    
loki            	logging               	2       	2025-12-01 01:16:24.090060483 +0000 UTC	deployed	loki-6.46.0                           	3.5.7      
monitoring      	monitoring            	17      	2025-12-01 21:21:45.662633308 +0000 UTC	deployed	REDACTED_d8074874-79.10.0         	v0.86.2    
nfs-provisioner 	nfs-provisioner       	8       	2025-11-29 02:18:25.900770326 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail        	logging               	4       	2025-12-01 01:45:36.092885959 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
synology-csi    	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   10d
awx                      Active   31d
bentopdf                 Active   6d12h
cert-manager             Active   5d7h
cilium-secrets           Active   7d13h
cilium-spire             Active   7d3h
default                  Active   32d
external-secrets         Active   6d7h
REDACTED_01b50c5d   Active   11d
ingress-nginx            Active   30d
kube-node-lease          Active   32d
kube-public              Active   32d
kube-system              Active   32d
REDACTED_d97cef76     Active   31d
logging                  Active   5d13h
minio                    Active   11d
monitoring               Active   31d
nfs-provisioner          Active   30d
opentofu-ns              Active   30d
pihole                   Active   11d
production               Active   11d
synology-csi             Active   8d
velero                   Active   10d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           10d
argocd                   argocd-redis                                      1/1     1            1           10d
argocd                   argocd-repo-server                                2/2     2            2           10d
argocd                   argocd-server                                     2/2     2            2           10d
awx                      awx-operator-controller-manager                   1/1     1            1           31d
awx                      my-awx-task                                       1/1     1            1           31d
awx                      my-awx-web                                        1/1     1            1           31d
bentopdf                 bentopdf                                          1/1     1            1           6d12h
cert-manager             cert-manager                                      1/1     1            1           5d7h
cert-manager             cert-manager-cainjector                           1/1     1            1           5d7h
cert-manager             cert-manager-webhook                              1/1     1            1           5d7h
external-secrets         external-secrets                                  1/1     1            1           6d7h
external-secrets         external-secrets-cert-controller                  1/1     1            1           6d7h
external-secrets         external-secrets-webhook                          1/1     1            1           6d7h
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           11d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           30d
kube-system              cilium-operator                                   1/1     1            1           7d13h
kube-system              coredns                                           2/2     2            2           32d
kube-system              hubble-relay                                      1/1     1            1           7d13h
kube-system              hubble-ui                                         1/1     1            1           7d13h
kube-system              metrics-server                                    1/1     1            1           31d
REDACTED_d97cef76     dashboard-metrics-scraper                         1/1     1            1           30d
REDACTED_d97cef76     REDACTED_d97cef76                              1/1     1            1           30d
minio                    minio                                             1/1     1            1           11d
monitoring               monitoring-grafana                                2/2     2            2           8d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           30d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           30d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           30d
pihole                   pihole                                            1/1     1            1           6d9h
velero                   velero                                            1/1     1            1           10d
velero                   velero-ui                                         1/1     1            1           10d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     10d
awx            my-awx-postgres-15                                     1/1     31d
cilium-spire   spire-server                                           1/1     7d3h
logging        loki                                                   1/1     5d12h
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     8d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     8d
synology-csi   synology-csi-controller                                1/1     8d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           9         9         7       9            7           <none>                   7d3h
kube-system    cilium                                9         9         8       9            8           kubernetes.io/os=linux   7d13h
kube-system    cilium-envoy                          9         9         8       9            8           kubernetes.io/os=linux   7d13h
logging        promtail                              8         8         8       8            8           <none>                   5d12h
monitoring     monitoring-prometheus-node-exporter   8         8         8       8            8           kubernetes.io/os=linux   30d
synology-csi   synology-csi-node                     9         9         8       9            8           <none>                   8d
velero         velero-node-agent                     5         5         4       5            4           <none>                   10d
```

---

*Full cluster context dump - v3.1.0*
