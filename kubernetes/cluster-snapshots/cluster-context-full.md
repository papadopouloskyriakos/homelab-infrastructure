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

**Generated:** 2026-09-16 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | CRITICAL | ⚠️ |
| Unhealthy Pods | 13 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 8440 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.36.3 |
| CNI | Cilium 1.20.0 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 179 |

### Node Details (with Taints & Labels)

#### nlk8s-ctrl01
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 8002696Ki
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
- **CPU:** 4 | **Memory:** 8003704Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node01
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 10054396Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node02
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 10054404Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node03
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 10054404Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node04
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 10053376Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01


---

## Anomalies & Issues

### Unhealthy Pods
```
kube-system              kube-proxy-qn8md                                                  0/1   CrashLoopBackOff   6341 (4m48s ago)   30d
monitoring               meshsat-status-heartbeat-29823650-br6zj                           0/1   Error              0                  30h
monitoring               meshsat-status-heartbeat-29823651-g9znh                           0/1   Error              0                  30h
monitoring               meshsat-status-heartbeat-29823652-l8dsg                           0/1   Error              0                  30h
velero                   awx-default-kopia-maintain-job-1789526807466-tcmvv                0/1   Error              0                  14m
velero                   awx-default-kopia-maintain-job-1789527114497-lrwp4                0/1   Error              0                  9m3s
velero                   awx-default-kopia-maintain-job-1789527407468-chrcb                0/1   Error              0                  4m10s
velero                   monitoring-default-kopia-maintain-job-1789526815486-5q665         0/1   Error              0                  14m
velero                   monitoring-default-kopia-maintain-job-1789527118527-jj6bw         0/1   Error              0                  8m59s
velero                   monitoring-default-kopia-maintain-job-1789527411503-g7t8v         0/1   Error              0                  4m6s
velero                   pihole-default-kopia-maintain-job-1789526829839-n2w4f             0/1   Error              0                  13m
velero                   pihole-default-kopia-maintain-job-1789527107467-nvfqd             0/1   Error              0                  9m10s
velero                   pihole-default-kopia-maintain-job-1789527415524-796q8             0/1   Error              0                  4m2s
```

#### Unhealthy Pod Details

**kube-system/kube-proxy-qn8md:**
```
Events:
  Type     Reason          Age                    From     Message
  ----     ------          ----                   ----     -------
  Normal   Pulled          37m (x6334 over 22d)   kubelet  spec.containers{kube-proxy}: Container image "registry.k8s.io/kube-proxy:v1.36.3" already present on machine and can be accessed by the pod
  Warning  BackOff         35m (x28218 over 22d)  kubelet  spec.containers{kube-proxy}: Back-off restarting failed container kube-proxy in pod kube-proxy-qn8md_kube-system(70ae08f5-7949-459c-9670-ac69c6b03a55)
  Normal   SandboxChanged  16m                    kubelet  Pod sandbox changed, it will be killed and re-created.
  Normal   Pulled          4m49s (x7 over 16m)    kubelet  spec.containers{kube-proxy}: Container image "registry.k8s.io/kube-proxy:v1.36.3" already present on machine and can be accessed by the pod
  Normal   Created         4m49s (x7 over 16m)    kubelet  spec.containers{kube-proxy}: Container created
  Normal   Started         4m49s (x7 over 16m)    kubelet  spec.containers{kube-proxy}: Container started
  Warning  BackOff         81s (x15 over 16m)     kubelet  spec.containers{kube-proxy}: Back-off restarting failed container kube-proxy in pod kube-proxy-qn8md_kube-system(70ae08f5-7949-459c-9670-ac69c6b03a55)
```

**monitoring/meshsat-status-heartbeat-29823650-br6zj:**
```
Events:                      <none>
```

**monitoring/meshsat-status-heartbeat-29823651-g9znh:**
```
Events:                      <none>
```

**monitoring/meshsat-status-heartbeat-29823652-l8dsg:**
```
Events:                      <none>
```

**velero/awx-default-kopia-maintain-job-1789526807466-tcmvv:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  14m   default-scheduler  Successfully assigned velero/awx-default-kopia-maintain-job-1789526807466-tcmvv to nlk8s-node01
  Normal  Pulled     14m   kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    14m   kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    14m   kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

### High Restart Pods (>3 restarts)
- awx/my-awx-task-756d768868-bslc2: 6 restarts
- cilium-spire/spire-agent-2xj9z: 258 restarts
- cilium-spire/spire-agent-bf7g7: 262 restarts
- cilium-spire/spire-agent-hpld8: 259 restarts
- cilium-spire/spire-agent-sm9xs: 259 restarts
- cilium-spire/spire-agent-xk8cl: 258 restarts
- cilium-spire/spire-agent-zqpt4: 262 restarts
- kube-system/cilium-operator-84c4fb58c7-jlhkp: 4 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 9 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 7 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 4 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 4 restarts
- kube-system/kube-proxy-qn8md: 6341 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 6 restarts
- kube-system/tetragon-5gk99: 9 restarts
- kube-system/tetragon-75hdg: 14 restarts
- kube-system/tetragon-878gv: 8 restarts
- kube-system/tetragon-jz2b6: 10 restarts
- kube-system/tetragon-mdsn9: 30 restarts
- kube-system/tetragon-tbcc7: 10 restarts
- kube-system/tetragon-vbs6v: 16 restarts
- logging/loki-canary-bbplf: 5 restarts
- logging/promtail-5jr9j: 6 restarts
- logging/promtail-br4rf: 4 restarts
- logging/promtail-hp5sc: 8 restarts
- logging/promtail-m2gzm: 5 restarts
- logging/promtail-ng69s: 8 restarts
- monitoring/goldpinger-fjpnh: 4 restarts
- monitoring/monitoring-prometheus-node-exporter-6dl8r: 178 restarts
- monitoring/monitoring-prometheus-node-exporter-6sc8j: 10 restarts
- monitoring/monitoring-prometheus-node-exporter-88hp8: 5 restarts
- monitoring/monitoring-prometheus-node-exporter-8bq88: 4 restarts
- monitoring/monitoring-prometheus-node-exporter-vgp6b: 4 restarts
- monitoring/monitoring-prometheus-node-exporter-wmcb8: 47 restarts
- synology-csi/synology-csi-node-4nxcz: 8 restarts
- synology-csi/synology-csi-node-kxrjb: 17 restarts
- synology-csi/synology-csi-node-l72f8: 9 restarts
- synology-csi/synology-csi-node-mrqzg: 6 restarts
- synology-csi/synology-csi-node-ptwb8: 10 restarts
- synology-csi/synology-csi-node-sfdmg: 10 restarts
- synology-csi/synology-csi-node-zch7n: 30 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE                LAST SEEN   TYPE      REASON                 OBJECT                                                                MESSAGE
seaweedfs                16m         Warning   FailedScheduling       pod/seaweedfs-filer-0                                                 0/7 nodes are available: 3 Insufficient memory, 4 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 3 No preemption victims found for incoming pod, 4 Preemption is not helpful for scheduling.
seaweedfs                16m         Warning   FailedScheduling       pod/seaweedfs-filer-0                                                 0/7 nodes are available: 3 Insufficient memory, 4 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 3 No preemption victims found for incoming pod, 4 Preemption is not helpful for scheduling.
velero                   74m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1789523204194                      Job has reached the specified backoff limit
velero                   74m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1789523210221               Job has reached the specified backoff limit
velero                   74m         Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1789523215249                   Job has reached the specified backoff limit
monitoring               71m         Warning   Unhealthy              pod/alertmanager-monitoring-kube-prometheus-alertmanager-0            Readiness probe failed: Get "http://10.0.2.180:9093/-/ready": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
monitoring               71m         Warning   Unhealthy              pod/alertmanager-monitoring-kube-prometheus-alertmanager-0            Liveness probe failed: Get "http://10.0.2.180:9093/-/healthy": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
velero                   69m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1789523504195                      Job has reached the specified backoff limit
velero                   69m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1789523510224               Job has reached the specified backoff limit
velero                   69m         Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1789523515257                   Job has reached the specified backoff limit
monitoring               66m         Warning   Unhealthy              pod/bgpalerter-789f984488-kjgw8                                       Liveness probe failed: Get "http://10.0.2.80:8011/status": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
velero                   64m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1789523804195                      Job has reached the specified backoff limit
velero                   64m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1789523809224               Job has reached the specified backoff limit
velero                   64m         Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1789523813254                   Job has reached the specified backoff limit
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
- ExternalSecret: awx-pg-dump-s3 (SecretSynced)
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

### Namespace: `cnpg-system`

2/- **Deployment: cnpg-cloudnative-pg** (2)

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
- **StatefulSet: thanos-compactor** (/0)
- **StatefulSet: thanos-store** (2/2)

**Storage:**
- PVC: alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-0 (10Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-1 (10Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: data-thanos-compactor-0 (100Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: data-thanos-store-0 (20Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: data-thanos-store-1 (20Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: monitoring-grafana (20Gi, Bound, sc:nfs-client)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-0 (200Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-1 (200Gi, Bound, sc:REDACTED_4f3da73d)

**Secrets:**
- ExternalSecret: meshsat-status-heartbeat (SecretSynced)
- ExternalSecret: monitoring-finops-db-ro (SecretSynced)
- ExternalSecret: monitoring-grafana (SecretSynced)
- ExternalSecret: monitoring-openobserve-ro (SecretSynced)
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

### Namespace: `reloader`

1/- **Deployment: reloader-reloader** (1)

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
- PVC: seaweedfs-filer-meta-1 (10Gi, Bound, sc:REDACTED_b280aec5)
- PVC: seaweedfs-filer-meta-2 (10Gi, Bound, sc:REDACTED_b280aec5)

**Secrets:**
- ExternalSecret: REDACTED_073f5849 (SecretSynced)
- ExternalSecret: seaweedfs-read-canary-s3 (SecretSynced)
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
nlk8s-ctrl01   1408m        35%      2965Mi          37%         
nlk8s-ctrl02   430m         10%      3376Mi          41%         
nlk8s-ctrl03   390m         9%       3338Mi          42%         
nlk8s-node01    171m         2%       2308Mi          23%         
nlk8s-node02    463m         5%       5683Mi          57%         
nlk8s-node03    1262m        15%      7918Mi          80%         
nlk8s-node04    881m         11%      6969Mi          70%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-1                751m         3515Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                538m         3742Mi          
kube-system              tetragon-mdsn9                                                    243m         175Mi           
logging                  promtail-br4rf                                                    149m         74Mi            
kube-system              kube-apiserver-nlk8s-ctrl03                                 134m         1705Mi          
kube-system              cilium-7rvww                                                      126m         356Mi           
kube-system              kube-apiserver-nlk8s-ctrl01                                 110m         1396Mi          
kube-system              cilium-jfgsw                                                      95m          350Mi           
kube-system              etcd-nlk8s-ctrl03                                           91m          127Mi           
kube-system              cilium-qw7d6                                                      86m          357Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                538m         3742Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                751m         3515Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 134m         1705Mi          
awx                      my-awx-task-756d768868-bslc2                                      29m          1439Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 110m         1396Mi          
awx                      my-awx-web-f9c4bb98d-wcn4j                                        9m           1390Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 76m          937Mi           
logging                  loki-0                                                            34m          787Mi           
kube-system              cilium-g5h5t                                                      40m          764Mi           
monitoring               monitoring-grafana-7d6c5795b8-bl4zl                               9m           692Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
kube-system: CPU=2210m Mem=536Mi
monitoring: CPU=2200m Mem=10736Mi
awx: CPU=1855m Mem=3552Mi
seaweedfs: CPU=1650m Mem=8384Mi
ingress-nginx: CPU=1000m Mem=1024Mi
logging: CPU=850m Mem=2944Mi
argocd: CPU=750m Mem=1664Mi
velero: CPU=550m Mem=832Mi
REDACTED_d97cef76: CPU=400m Mem=800Mi
cert-manager: CPU=100m Mem=224Mi
```

---

## Network & Security

### PodDisruptionBudgets
```
NAMESPACE         NAME                                              MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
argocd            argocd-application-controller                     1               N/A               0                     292d
argocd            argocd-applicationset-controller                  1               N/A               0                     292d
argocd            argocd-redis                                      1               N/A               0                     292d
argocd            argocd-repo-server                                1               N/A               1                     292d
argocd            argocd-server                                     1               N/A               1                     292d
awx               awx-postgres-pdb                                  1               N/A               0                     292d
awx               awx-task-pdb                                      1               N/A               0                     292d
awx               awx-web-pdb                                       1               N/A               0                     292d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     292d
kube-system       coredns-pdb                                       1               N/A               1                     292d
kube-system       metrics-server-pdb                                1               N/A               0                     13h
monitoring        monitoring-grafana                                1               N/A               1                     157d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     157d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     157d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     292d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     178d
seaweedfs         seaweedfs-filer-meta-primary                      1               N/A               0                     23d
seaweedfs         seaweedfs-master                                  2               N/A               1                     178d
seaweedfs         seaweedfs-volume                                  1               N/A               1                     178d
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
| ClusterIP | 79 |
| NodePort | 6 |
| LoadBalancer | 6 |

### LoadBalancer Services
```
NAMESPACE       NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   314d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               283d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 291d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                289d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 291d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 291d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   294d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        293d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        290d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        184d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   273d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        278d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        277d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        282d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        293d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        277d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        278d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        295d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        279d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        279d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        294d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   272d
```

---

## Storage

| Metric | Count |
|--------|-------|
| StorageClasses | 10 |
| PersistentVolumes | 25 |
| PersistentVolumeClaims | 23 |

### StorageClasses
```
NAME                                      PROVISIONER                                                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   295d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   315d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   292d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   292d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   292d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   292d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   292d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   292d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   292d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   292d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 4 |
| External Secrets | 21 |
| Certificates | 22 |
| ServiceMonitors | 32 |
| CiliumNetworkPolicies | 4 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE    PAUSED
daily-backup    Enabled   0 2 * * *   60m          294d   false
weekly-backup   Enabled   0 3 * * 0   3d           294d   false
```

### Recent Backups (last 5)
```

```

---

## Helm Releases
```
NAME                	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd              	argocd                	10      	2026-08-22 21:03:45.885765007 +0000 UTC	deployed	argo-cd-7.7.10                        	v2.13.2    
cert-manager        	cert-manager          	4       	2026-08-16 20:22:17.02474649 +0000 UTC 	deployed	cert-manager-v1.17.1                  	v1.17.1    
cilium              	kube-system           	23      	2026-08-16 19:52:42.423404071 +0000 UTC	deployed	cilium-1.20.0                         	1.20.0     
cnpg                	cnpg-system           	1       	2026-08-23 18:35:22.841169369 +0000 UTC	deployed	cloudnative-pg-0.29.0                 	1.30.0     
external-secrets    	external-secrets      	3       	2026-08-16 19:44:17.756739716 +0000 UTC	deployed	external-secrets-1.1.1                	v1.1.1     
ingress-nginx       	ingress-nginx         	16      	2026-09-11 15:51:51.079021102 +0000 UTC	deployed	ingress-nginx-4.15.1                  	1.15.1     
k8s-agent           	REDACTED_01b50c5d	8       	2026-08-16 19:44:19.392287363 +0000 UTC	deployed	gitlab-agent-2.28.0                   	v19.1.0    
REDACTED_d97cef76	REDACTED_d97cef76  	2       	2026-02-25 19:02:27.096604857 +0000 UTC	deployed	REDACTED_d97cef76-7.14.0           	           
loki                	logging               	14      	2026-09-15 17:26:08.780337956 +0000 UTC	deployed	loki-6.55.0                           	3.6.7      
metrics-server      	kube-system           	1       	2026-09-15 13:27:45.896794695 +0000 UTC	deployed	metrics-server-3.14.0                 	0.9.0      
monitoring          	monitoring            	35      	2026-08-25 22:59:17.970226763 +0000 UTC	deployed	REDACTED_d8074874-79.12.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	9       	2026-08-16 19:44:19.484898096 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail            	logging               	8       	2026-03-14 22:22:09.209112925 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
reloader            	reloader              	1       	2026-09-15 00:36:24.969024643 +0000 UTC	deployed	reloader-2.2.17                       	v1.4.22    
seaweedfs           	seaweedfs             	22      	2026-09-15 17:30:22.895666703 +0000 UTC	deployed	seaweedfs-4.44.0                      	4.44       
synology-csi        	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
tetragon            	kube-system           	7       	2025-12-20 22:35:40.030282504 +0000 UTC	deployed	tetragon-1.6.0                        	1.6.0      
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   294d
awx                      Active   315d
bentopdf                 Active   290d
cert-manager             Active   289d
cilium-secrets           Active   291d
cilium-spire             Active   291d
cnpg-system              Active   23d
default                  Active   316d
echo-server              Active   184d
external-secrets         Active   290d
gatus                    Active   273d
REDACTED_01b50c5d   Active   295d
ingress-nginx            Active   314d
kube-node-lease          Active   316d
kube-public              Active   316d
kube-system              Active   316d
REDACTED_d97cef76     Active   277d
logging                  Active   289d
monitoring               Active   315d
nfs-provisioner          Active   314d
opentofu-ns              Active   314d
pihole                   Active   295d
production               Active   295d
reloader                 Active   26h
seaweedfs                Active   279d
synology-csi             Active   292d
velero                   Active   294d
well-known               Active   272d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           294d
argocd                   argocd-notifications-controller                   1/1     1            1           185d
argocd                   argocd-redis                                      1/1     1            1           294d
argocd                   argocd-repo-server                                2/2     2            2           294d
argocd                   argocd-server                                     2/2     2            2           294d
awx                      awx-operator-controller-manager                   1/1     1            1           315d
awx                      my-awx-task                                       1/1     1            1           315d
awx                      my-awx-web                                        1/1     1            1           315d
bentopdf                 bentopdf                                          1/1     1            1           290d
cert-manager             cert-manager                                      1/1     1            1           289d
cert-manager             cert-manager-cainjector                           1/1     1            1           289d
cert-manager             cert-manager-webhook                              1/1     1            1           289d
cnpg-system              cnpg-cloudnative-pg                               2/2     2            2           23d
echo-server              echo-server                                       1/1     1            1           184d
external-secrets         external-secrets                                  1/1     1            1           290d
external-secrets         external-secrets-cert-controller                  1/1     1            1           290d
external-secrets         external-secrets-webhook                          1/1     1            1           290d
gatus                    gatus                                             1/1     1            1           273d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           295d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           314d
kube-system              cilium-operator                                   1/1     1            1           291d
kube-system              clustermesh-apiserver                             1/1     1            1           283d
kube-system              coredns                                           2/2     2            2           316d
kube-system              hubble-relay                                      1/1     1            1           291d
kube-system              hubble-ui                                         1/1     1            1           291d
kube-system              metrics-server                                    1/1     1            1           13h
kube-system              tetragon-operator                                 1/1     1            1           270d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           277d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           277d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           277d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           277d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           277d
monitoring               bgpalerter                                        1/1     1            1           275d
monitoring               monitoring-grafana                                2/2     2            2           157d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           157d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           157d
monitoring               snmp-exporter                                     1/1     1            1           277d
monitoring               thanos-query                                      2/2     2            2           278d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           314d
pihole                   pihole                                            1/1     1            1           290d
reloader                 reloader-reloader                                 1/1     1            1           26h
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           278d
velero                   velero                                            1/1     1            1           294d
velero                   velero-ui                                         1/1     1            1           294d
well-known               well-known                                        1/1     1            1           272d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     294d
awx            my-awx-postgres-15                                     1/1     315d
cilium-spire   spire-server                                           1/1     291d
logging        loki                                                   1/1     270d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     157d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     157d
monitoring     thanos-compactor                                       0/0     9h
monitoring     thanos-store                                           2/2     278d
seaweedfs      seaweedfs-filer                                        2/2     279d
seaweedfs      seaweedfs-master                                       3/3     279d
seaweedfs      seaweedfs-volume                                       2/2     47d
synology-csi   synology-csi-controller                                1/1     292d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   291d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   291d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   291d
kube-system    kube-proxy                            7         7         6       7            6           kubernetes.io/os=linux   30d
kube-system    tetragon                              7         7         7       7            7           <none>                   270d
logging        loki-canary                           4         4         4       4            4           <none>                   278d
logging        promtail                              7         7         7       7            7           <none>                   289d
monitoring     goldpinger                            7         7         7       7            7           <none>                   282d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   157d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   292d
velero         node-agent                            4         4         4       4            4           <none>                   49d
```

---

*Full cluster context dump - v3.1.0*
