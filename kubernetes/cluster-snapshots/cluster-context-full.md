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

**Generated:** 2026-08-25 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | CRITICAL | ⚠️ |
| Unhealthy Pods | 10 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 672 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.36.3 |
| CNI | Cilium 1.20.0 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 166 |

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
- **CPU:** 8 | **Memory:** 16246548Ki
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
- **CPU:** 8 | **Memory:** 12117776Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01


---

## Anomalies & Issues

### Unhealthy Pods
```
kube-system              kube-proxy-qn8md                                                  0/1   Error       182 (5m29s ago)   8d
velero                   awx-default-kopia-maintain-job-1787626089072-hvl9j                0/1   Error       0                 12m
velero                   awx-default-kopia-maintain-job-1787626389072-j479z                0/1   Error       0                 7m45s
velero                   awx-default-kopia-maintain-job-1787626689073-kjvx8                0/1   Error       0                 2m45s
velero                   monitoring-default-kopia-maintain-job-1787626093100-kksnr         0/1   Error       0                 12m
velero                   monitoring-default-kopia-maintain-job-1787626393102-nsjhp         0/1   Error       0                 7m41s
velero                   monitoring-default-kopia-maintain-job-1787626694102-pz94f         0/1   Error       0                 2m40s
velero                   pihole-default-kopia-maintain-job-1787626097137-wr6cz             0/1   Error       0                 12m
velero                   pihole-default-kopia-maintain-job-1787626397129-bbz2j             0/1   Error       0                 7m37s
velero                   pihole-default-kopia-maintain-job-1787626698132-ndxc2             0/1   Error       0                 2m36s
```

#### Unhealthy Pod Details

**kube-system/kube-proxy-qn8md:**
```
Events:
  Type     Reason   Age                    From     Message
  ----     ------   ----                   ----     -------
  Warning  BackOff  4m12s (x800 over 15h)  kubelet  spec.containers{kube-proxy}: Back-off restarting failed container kube-proxy in pod kube-proxy-qn8md_kube-system(70ae08f5-7949-459c-9670-ac69c6b03a55)
  Normal   Pulled   21s (x182 over 15h)    kubelet  spec.containers{kube-proxy}: Container image "registry.k8s.io/kube-proxy:v1.36.3" already present on machine and can be accessed by the pod
```

**velero/awx-default-kopia-maintain-job-1787626089072-hvl9j:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  12m   default-scheduler  Successfully assigned velero/awx-default-kopia-maintain-job-1787626089072-hvl9j to nlk8s-node04
  Normal  Pulled     12m   kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    12m   kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    12m   kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

**velero/awx-default-kopia-maintain-job-1787626389072-j479z:**
```
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  7m46s  default-scheduler  Successfully assigned velero/awx-default-kopia-maintain-job-1787626389072-j479z to nlk8s-node04
  Normal  Pulled     7m46s  kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    7m46s  kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    7m46s  kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

**velero/awx-default-kopia-maintain-job-1787626689073-kjvx8:**
```
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m46s  default-scheduler  Successfully assigned velero/awx-default-kopia-maintain-job-1787626689073-kjvx8 to nlk8s-node04
  Normal  Pulled     2m46s  kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    2m46s  kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    2m45s  kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

**velero/monitoring-default-kopia-maintain-job-1787626093100-kksnr:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  12m   default-scheduler  Successfully assigned velero/monitoring-default-kopia-maintain-job-1787626093100-kksnr to nlk8s-node04
  Normal  Pulled     12m   kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    12m   kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    12m   kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

### High Restart Pods (>3 restarts)
- awx/my-awx-task-756d768868-bslc2: 6 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 4 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 6 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 4 restarts
- kube-system/kube-proxy-qn8md: 182 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 5 restarts
- kube-system/tetragon-5gk99: 9 restarts
- kube-system/tetragon-75hdg: 10 restarts
- kube-system/tetragon-878gv: 8 restarts
- kube-system/tetragon-jz2b6: 8 restarts
- kube-system/tetragon-mdsn9: 27 restarts
- kube-system/tetragon-tbcc7: 10 restarts
- kube-system/tetragon-vbs6v: 16 restarts
- logging/promtail-5jr9j: 6 restarts
- logging/promtail-hp5sc: 8 restarts
- logging/promtail-m2gzm: 4 restarts
- logging/promtail-ng69s: 6 restarts
- monitoring/monitoring-prometheus-node-exporter-6dl8r: 176 restarts
- monitoring/monitoring-prometheus-node-exporter-6sc8j: 10 restarts
- monitoring/monitoring-prometheus-node-exporter-88hp8: 4 restarts
- monitoring/monitoring-prometheus-node-exporter-vgp6b: 4 restarts
- monitoring/monitoring-prometheus-node-exporter-wmcb8: 47 restarts
- synology-csi/synology-csi-node-4nxcz: 8 restarts
- synology-csi/synology-csi-node-kxrjb: 17 restarts
- synology-csi/synology-csi-node-l72f8: 9 restarts
- synology-csi/synology-csi-node-ptwb8: 10 restarts
- synology-csi/synology-csi-node-sfdmg: 8 restarts
- synology-csi/synology-csi-node-zch7n: 27 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE     LAST SEEN   TYPE      REASON                 OBJECT                                                    MESSAGE
monitoring    60m         Warning   Unhealthy              pod/monitoring-kube-state-metrics-75f9fff55b-prwns        Liveness probe failed: HTTP probe failed with statuscode: 503
kube-system   60m         Warning   Unhealthy              pod/kube-controller-manager-nlk8s-ctrl01            Liveness probe failed: Get "https://127.0.0.1:10257/healthz": dial tcp 127.0.0.1:10257: connect: connection refused
kube-system   60m         Warning   Unhealthy              pod/etcd-nlk8s-ctrl01                               Readiness probe failed: Get "http://127.0.0.1:2381/readyz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
velero        57m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1787623389066          Job has reached the specified backoff limit
velero        57m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1787623393238   Job has reached the specified backoff limit
velero        57m         Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1787623398298       Job has reached the specified backoff limit
velero        52m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1787623689067          Job has reached the specified backoff limit
velero        52m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1787623693106   Job has reached the specified backoff limit
velero        52m         Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1787623698165       Job has reached the specified backoff limit
awx           52m         Warning   FailedKillPod          pod/automation-job-37074-zj6k9                            error killing pod: failed to "KillContainer" for "worker" with KillContainerError: "rpc error: code = Unknown desc = failed to stop container \"5618eb2e19ba7f8b1e5b2e1bcb1cc1573a44090cb55545dd2f9e738446bfb9b9\": ttrpc: closed"
velero        47m         Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1787623989067       Job has reached the specified backoff limit
velero        47m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1787623997102          Job has reached the specified backoff limit
velero        47m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1787624002133   Job has reached the specified backoff limit
velero        42m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1787624289067          Job has reached the specified backoff limit
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
nlk8s-ctrl01   1431m        35%      3248Mi          41%         
nlk8s-ctrl02   629m         15%      3502Mi          43%         
nlk8s-ctrl03   419m         10%      3402Mi          43%         
nlk8s-node01    970m         12%      9231Mi          58%         
nlk8s-node02    657m         8%       5258Mi          53%         
nlk8s-node03    788m         9%       5470Mi          55%         
nlk8s-node04    93m          1%       1895Mi          16%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                306m         2609Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                303m         3777Mi          
kube-system              tetragon-mdsn9                                                    281m         472Mi           
kube-system              kube-apiserver-nlk8s-ctrl03                                 260m         1758Mi          
seaweedfs                seaweedfs-volume-1                                                248m         303Mi           
kube-system              kube-apiserver-nlk8s-ctrl02                                 151m         1420Mi          
kube-system              cilium-c8kqc                                                      141m         325Mi           
logging                  promtail-5jr9j                                                    129m         70Mi            
kube-system              cilium-jfgsw                                                      119m         337Mi           
kube-system              etcd-nlk8s-ctrl03                                           98m          129Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-1                303m         3777Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                306m         2609Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 260m         1758Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 83m          1639Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 151m         1420Mi          
awx                      my-awx-web-f9c4bb98d-wcn4j                                        44m          1389Mi          
awx                      my-awx-task-756d768868-bslc2                                      18m          1188Mi          
seaweedfs                seaweedfs-filer-1                                                 19m          723Mi           
monitoring               bgpalerter-789f984488-2rds8                                       2m           713Mi           
monitoring               monitoring-grafana-7d6c5795b8-6cvtn                               11m          706Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
kube-system: CPU=2260m Mem=672Mi
monitoring: CPU=2160m Mem=10928Mi
awx: CPU=1855m Mem=3552Mi
seaweedfs: CPU=1350m Mem=8000Mi
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
argocd            argocd-application-controller                     1               N/A               0                     270d
argocd            argocd-applicationset-controller                  1               N/A               0                     270d
argocd            argocd-redis                                      1               N/A               0                     270d
argocd            argocd-repo-server                                1               N/A               1                     270d
argocd            argocd-server                                     1               N/A               1                     270d
awx               awx-postgres-pdb                                  1               N/A               0                     270d
awx               awx-task-pdb                                      1               N/A               0                     270d
awx               awx-web-pdb                                       1               N/A               0                     270d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     270d
kube-system       coredns-pdb                                       1               N/A               1                     270d
kube-system       metrics-server-pdb                                1               N/A               0                     270d
monitoring        monitoring-grafana                                1               N/A               1                     135d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     135d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     135d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     270d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     156d
seaweedfs         seaweedfs-filer-meta-primary                      1               N/A               0                     30h
seaweedfs         seaweedfs-master                                  2               N/A               1                     156d
seaweedfs         seaweedfs-volume                                  1               N/A               1                     156d
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
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   292d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               261d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 269d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                267d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 269d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 269d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   272d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        271d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        268d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        162d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   251d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        256d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        255d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        260d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        271d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        255d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        256d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        273d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        257d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        257d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        272d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   250d
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   273d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   293d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   270d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   270d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   270d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   270d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   270d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   270d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   270d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   270d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 4 |
| External Secrets | 20 |
| Certificates | 22 |
| ServiceMonitors | 31 |
| CiliumNetworkPolicies | 4 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE    PAUSED
daily-backup    Enabled   0 2 * * *   61m          272d   false
weekly-backup   Enabled   0 3 * * 0   2d           272d   false
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
ingress-nginx       	ingress-nginx         	14      	2026-07-07 14:07:26.472035985 +0000 UTC	deployed	ingress-nginx-4.15.1                  	1.15.1     
k8s-agent           	REDACTED_01b50c5d	8       	2026-08-16 19:44:19.392287363 +0000 UTC	deployed	gitlab-agent-2.28.0                   	v19.1.0    
REDACTED_d97cef76	REDACTED_d97cef76  	2       	2026-02-25 19:02:27.096604857 +0000 UTC	deployed	REDACTED_d97cef76-7.14.0           	           
loki                	logging               	12      	2026-07-07 13:12:39.944244427 +0000 UTC	deployed	loki-6.55.0                           	3.6.7      
monitoring          	monitoring            	32      	2026-08-24 20:28:22.69983867 +0000 UTC 	deployed	REDACTED_d8074874-79.12.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	9       	2026-08-16 19:44:19.484898096 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail            	logging               	8       	2026-03-14 22:22:09.209112925 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
seaweedfs           	seaweedfs             	17      	2026-08-23 22:17:02.237225062 +0000 UTC	deployed	seaweedfs-4.44.0                      	4.44       
synology-csi        	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
tetragon            	kube-system           	7       	2025-12-20 22:35:40.030282504 +0000 UTC	deployed	tetragon-1.6.0                        	1.6.0      
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   272d
awx                      Active   293d
bentopdf                 Active   268d
cert-manager             Active   267d
cilium-secrets           Active   269d
cilium-spire             Active   269d
cnpg-system              Active   32h
default                  Active   294d
echo-server              Active   162d
external-secrets         Active   268d
gatus                    Active   251d
REDACTED_01b50c5d   Active   273d
ingress-nginx            Active   292d
kube-node-lease          Active   294d
kube-public              Active   294d
kube-system              Active   294d
REDACTED_d97cef76     Active   255d
logging                  Active   267d
monitoring               Active   293d
nfs-provisioner          Active   292d
opentofu-ns              Active   292d
pihole                   Active   273d
production               Active   273d
seaweedfs                Active   257d
synology-csi             Active   270d
velero                   Active   272d
well-known               Active   250d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           272d
argocd                   argocd-notifications-controller                   1/1     1            1           163d
argocd                   argocd-redis                                      1/1     1            1           272d
argocd                   argocd-repo-server                                2/2     2            2           272d
argocd                   argocd-server                                     2/2     2            2           272d
awx                      awx-operator-controller-manager                   1/1     1            1           293d
awx                      my-awx-task                                       1/1     1            1           293d
awx                      my-awx-web                                        1/1     1            1           293d
bentopdf                 bentopdf                                          1/1     1            1           268d
cert-manager             cert-manager                                      1/1     1            1           267d
cert-manager             cert-manager-cainjector                           1/1     1            1           267d
cert-manager             cert-manager-webhook                              1/1     1            1           267d
cnpg-system              cnpg-cloudnative-pg                               2/2     2            2           32h
echo-server              echo-server                                       1/1     1            1           162d
external-secrets         external-secrets                                  1/1     1            1           268d
external-secrets         external-secrets-cert-controller                  1/1     1            1           268d
external-secrets         external-secrets-webhook                          1/1     1            1           268d
gatus                    gatus                                             1/1     1            1           251d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           273d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           292d
kube-system              cilium-operator                                   1/1     1            1           269d
kube-system              clustermesh-apiserver                             1/1     1            1           261d
kube-system              coredns                                           2/2     2            2           294d
kube-system              hubble-relay                                      1/1     1            1           269d
kube-system              hubble-ui                                         1/1     1            1           269d
kube-system              metrics-server                                    1/1     1            1           293d
kube-system              tetragon-operator                                 1/1     1            1           248d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           255d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           255d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           255d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           255d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           255d
monitoring               bgpalerter                                        1/1     1            1           253d
monitoring               monitoring-grafana                                2/2     2            2           135d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           135d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           135d
monitoring               snmp-exporter                                     1/1     1            1           255d
monitoring               thanos-query                                      2/2     2            2           256d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           292d
pihole                   pihole                                            1/1     1            1           268d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           256d
velero                   velero                                            1/1     1            1           272d
velero                   velero-ui                                         1/1     1            1           272d
well-known               well-known                                        1/1     1            1           250d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     272d
awx            my-awx-postgres-15                                     1/1     293d
cilium-spire   spire-server                                           1/1     269d
logging        loki                                                   1/1     248d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     135d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     135d
monitoring     thanos-compactor                                       1/1     256d
monitoring     thanos-store                                           2/2     256d
seaweedfs      seaweedfs-filer                                        2/2     257d
seaweedfs      seaweedfs-master                                       3/3     257d
seaweedfs      seaweedfs-volume                                       2/2     25d
synology-csi   synology-csi-controller                                1/1     270d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   269d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   269d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   269d
kube-system    kube-proxy                            7         7         6       7            6           kubernetes.io/os=linux   8d
kube-system    tetragon                              7         7         7       7            7           <none>                   248d
logging        loki-canary                           4         4         4       4            4           <none>                   256d
logging        promtail                              7         7         7       7            7           <none>                   267d
monitoring     goldpinger                            7         7         7       7            7           <none>                   260d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   135d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   270d
velero         node-agent                            4         4         4       4            4           <none>                   27d
```

---

*Full cluster context dump - v3.1.0*
