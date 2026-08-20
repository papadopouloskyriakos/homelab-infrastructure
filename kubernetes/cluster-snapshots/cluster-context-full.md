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

**Generated:** 2026-08-20 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | CRITICAL | ⚠️ |
| Unhealthy Pods | 24 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 503 | ⚠️ |

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
- **CPU:** 8 | **Memory:** 8001304Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node02
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8002312Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node03
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8002312Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node04
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8002308Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01


---

## Anomalies & Issues

### Unhealthy Pods
```
velero                   argocd-default-kopia-maintain-job-1787194151012-7f9hn             0/1   Error       0                 11m
velero                   argocd-default-kopia-maintain-job-1787194447840-sv2vj             0/1   Error       0                 6m57s
velero                   argocd-default-kopia-maintain-job-1787194751946-z2l65             0/1   Error       0                 113s
velero                   awx-default-kopia-maintain-job-1787194101824-4x2c5                0/1   Error       0                 12m
velero                   awx-default-kopia-maintain-job-1787194395680-68bk9                0/1   Error       0                 7m49s
velero                   awx-default-kopia-maintain-job-1787194700821-87x9q                0/1   Error       0                 2m44s
velero                   cilium-spire-default-kopia-maintain-job-1787194169045-6kx54       0/1   Error       0                 11m
velero                   cilium-spire-default-kopia-maintain-job-1787194465918-nzfxz       0/1   Error       0                 6m38s
velero                   cilium-spire-default-kopia-maintain-job-1787194769006-wfb59       0/1   Error       0                 95s
velero                   gatus-default-kopia-maintain-job-1787194174087-h5smr              0/1   Error       0                 11m
velero                   gatus-default-kopia-maintain-job-1787194471960-t9tdb              0/1   Error       0                 6m33s
velero                   gatus-default-kopia-maintain-job-1787194774040-nbgvp              0/1   Error       0                 90s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787194118pksf2   0/1   Error       0                 12m
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787194413mzz64   0/1   Error       0                 7m31s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787194717bm5cz   0/1   Error       0                 2m27s
velero                   logging-default-kopia-maintain-job-1787194179137-dl7gm            0/1   Error       0                 11m
velero                   logging-default-kopia-maintain-job-1787194477008-7fbgd            0/1   Error       0                 6m27s
velero                   logging-default-kopia-maintain-job-1787194779077-qdcnn            0/1   Error       0                 85s
velero                   monitoring-default-kopia-maintain-job-1787194095680-8pffm         0/1   Error       0                 12m
velero                   monitoring-default-kopia-maintain-job-1787194493079-whkn7         0/1   Error       0                 6m11s
velero                   monitoring-default-kopia-maintain-job-1787194695681-gvspx         0/1   Error       0                 2m49s
velero                   well-known-default-kopia-maintain-job-1787194134917-gqz7s         0/1   Error       0                 12m
velero                   well-known-default-kopia-maintain-job-1787194430784-j59p4         0/1   Error       0                 7m14s
velero                   well-known-default-kopia-maintain-job-1787194734881-rkjsd         0/1   Error       0                 2m10s
```

#### Unhealthy Pod Details

**velero/argocd-default-kopia-maintain-job-1787194151012-7f9hn:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  11m   default-scheduler  Successfully assigned velero/argocd-default-kopia-maintain-job-1787194151012-7f9hn to nlk8s-node04
  Normal  Pulled     11m   kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    11m   kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    11m   kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

**velero/argocd-default-kopia-maintain-job-1787194447840-sv2vj:**
```
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  6m56s  default-scheduler  Successfully assigned velero/argocd-default-kopia-maintain-job-1787194447840-sv2vj to nlk8s-node04
  Normal  Pulled     6m55s  kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    6m55s  kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    6m55s  kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

**velero/argocd-default-kopia-maintain-job-1787194751946-z2l65:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  112s  default-scheduler  Successfully assigned velero/argocd-default-kopia-maintain-job-1787194751946-z2l65 to nlk8s-node04
  Normal  Pulled     111s  kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    111s  kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    111s  kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

**velero/awx-default-kopia-maintain-job-1787194101824-4x2c5:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  12m   default-scheduler  Successfully assigned velero/awx-default-kopia-maintain-job-1787194101824-4x2c5 to nlk8s-node04
  Normal  Pulled     12m   kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    12m   kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    12m   kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

**velero/awx-default-kopia-maintain-job-1787194395680-68bk9:**
```
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  7m49s  default-scheduler  Successfully assigned velero/awx-default-kopia-maintain-job-1787194395680-68bk9 to nlk8s-node04
  Normal  Pulled     7m48s  kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    7m48s  kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    7m48s  kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

### High Restart Pods (>3 restarts)
- ingress-nginx/ingress-nginx-controller-8445475547-6zqqc: 19 restarts
- ingress-nginx/ingress-nginx-controller-8445475547-kr7kz: 20 restarts
- kube-system/clustermesh-apiserver-6c8cd7bb6f-ctst4: 33 restarts
- kube-system/tetragon-5gk99: 7 restarts
- kube-system/tetragon-75hdg: 8 restarts
- kube-system/tetragon-878gv: 8 restarts
- kube-system/tetragon-jz2b6: 6 restarts
- kube-system/tetragon-mdsn9: 23 restarts
- kube-system/tetragon-tbcc7: 8 restarts
- kube-system/tetragon-vbs6v: 16 restarts
- logging/promtail-5jr9j: 5 restarts
- logging/promtail-hp5sc: 8 restarts
- logging/promtail-ng69s: 5 restarts
- monitoring/monitoring-grafana-6c7c5dfd7b-xfrlh: 24 restarts
- monitoring/monitoring-kube-prometheus-operator-67d8d4c647-vwbbr: 5 restarts
- monitoring/monitoring-kube-state-metrics-75f9fff55b-4vfg6: 14 restarts
- monitoring/monitoring-prometheus-node-exporter-6dl8r: 175 restarts
- monitoring/monitoring-prometheus-node-exporter-6sc8j: 9 restarts
- monitoring/monitoring-prometheus-node-exporter-vgp6b: 4 restarts
- monitoring/monitoring-prometheus-node-exporter-wmcb8: 46 restarts
- monitoring/prometheus-REDACTED_6dfbe9fc-0: 41 restarts
- monitoring/prometheus-REDACTED_6dfbe9fc-1: 10 restarts
- synology-csi/synology-csi-node-4nxcz: 6 restarts
- synology-csi/synology-csi-node-577mq: 12 restarts
- synology-csi/synology-csi-node-kxrjb: 17 restarts
- synology-csi/synology-csi-node-l72f8: 9 restarts
- synology-csi/synology-csi-node-ptwb8: 8 restarts
- synology-csi/synology-csi-node-sfdmg: 6 restarts
- synology-csi/synology-csi-node-zch7n: 24 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE       LAST SEEN   TYPE      REASON                 OBJECT                                                              MESSAGE
kube-system     60m         Warning   Unhealthy              pod/kube-apiserver-nlk8s-ctrl01                               Liveness probe failed: HTTP probe failed with statuscode: 500
velero          57m         Warning   BackoffLimitExceeded   job/cilium-spire-default-kopia-maintain-job-1787191395672           Job has reached the specified backoff limit
velero          57m         Warning   BackoffLimitExceeded   job/gatus-default-kopia-maintain-job-1787191400742                  Job has reached the specified backoff limit
velero          57m         Warning   BackoffLimitExceeded   job/logging-default-kopia-maintain-job-1787191405848                Job has reached the specified backoff limit
velero          57m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1787191423894             Job has reached the specified backoff limit
velero          56m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1787191430042                    Job has reached the specified backoff limit
velero          56m         Warning   BackoffLimitExceeded   job/REDACTED_d97cef76-default-kopia-maintain-job-1787191449109   Job has reached the specified backoff limit
velero          56m         Warning   BackoffLimitExceeded   job/well-known-default-kopia-maintain-job-1787191467245             Job has reached the specified backoff limit
velero          56m         Warning   BackoffLimitExceeded   job/argocd-default-kopia-maintain-job-1787191485343                 Job has reached the specified backoff limit
default         55m         Warning   SystemOOM              node/nlk8s-node04                                              System OOM encountered, victim process: grafana, pid: 1066872
default         55m         Warning   SystemOOM              node/nlk8s-node04                                              System OOM encountered, victim process: prometheus, pid: 1534002
monitoring      55m         Warning   Unhealthy              pod/prometheus-REDACTED_6dfbe9fc-0              Readiness probe failed: Get "http://10.0.0.82:9090/-/ready": dial tcp 10.0.0.82:9090: connect: connection refused
monitoring      55m         Warning   Unhealthy              pod/prometheus-REDACTED_6dfbe9fc-0              Liveness probe failed: Get "http://10.0.0.82:9090/-/healthy": dial tcp 10.0.0.82:9090: connect: connection refused
default         53m         Warning   SystemOOM              node/nlk8s-node04                                              System OOM encountered, victim process: grafana, pid: 1556347
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
nlk8s-ctrl01   1481m        37%      3107Mi          39%         
nlk8s-ctrl02   1853m        46%      3013Mi          37%         
nlk8s-ctrl03   437m         10%      3145Mi          40%         
nlk8s-node01    1182m        14%      6225Mi          79%         
nlk8s-node02    906m         11%      4978Mi          63%         
nlk8s-node03    752m         9%       4144Mi          53%         
nlk8s-node04    2372m        29%      6983Mi          89%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                789m         3596Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 446m         1391Mi          
kube-system              etcd-nlk8s-ctrl02                                           403m         180Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-1                364m         3174Mi          
kube-system              cilium-7rvww                                                      330m         229Mi           
kube-system              cilium-g5h5t                                                      265m         181Mi           
kube-system              tetragon-mdsn9                                                    256m         174Mi           
ingress-nginx            ingress-nginx-controller-8445475547-kr7kz                         236m         117Mi           
seaweedfs                seaweedfs-volume-0                                                208m         660Mi           
seaweedfs                seaweedfs-volume-1                                                201m         749Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                789m         3596Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                364m         3174Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 157m         1548Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 119m         1467Mi          
awx                      my-awx-task-756d768868-bslc2                                      27m          1445Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 446m         1391Mi          
awx                      my-awx-web-55ccb47b58-nzk8w                                       6m           1378Mi          
logging                  loki-0                                                            68m          953Mi           
seaweedfs                seaweedfs-filer-0                                                 142m         763Mi           
seaweedfs                seaweedfs-volume-1                                                201m         749Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
kube-system: CPU=2260m Mem=672Mi
monitoring: CPU=2160m Mem=10928Mi
awx: CPU=1855m Mem=3552Mi
seaweedfs: CPU=1200m Mem=7424Mi
ingress-nginx: CPU=1000m Mem=1024Mi
logging: CPU=850m Mem=2944Mi
argocd: CPU=750m Mem=1664Mi
velero: CPU=550m Mem=704Mi
REDACTED_d97cef76: CPU=400m Mem=800Mi
cert-manager: CPU=100m Mem=224Mi
```

---

## Network & Security

### PodDisruptionBudgets
```
NAMESPACE         NAME                                              MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
argocd            argocd-application-controller                     1               N/A               0                     265d
argocd            argocd-applicationset-controller                  1               N/A               0                     265d
argocd            argocd-redis                                      1               N/A               0                     265d
argocd            argocd-repo-server                                1               N/A               1                     265d
argocd            argocd-server                                     1               N/A               1                     265d
awx               awx-postgres-pdb                                  1               N/A               0                     265d
awx               awx-task-pdb                                      1               N/A               0                     265d
awx               awx-web-pdb                                       1               N/A               0                     265d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     265d
kube-system       coredns-pdb                                       1               N/A               1                     265d
kube-system       metrics-server-pdb                                1               N/A               0                     265d
monitoring        monitoring-grafana                                1               N/A               1                     130d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     130d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     130d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     265d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     151d
seaweedfs         seaweedfs-master                                  2               N/A               1                     151d
seaweedfs         seaweedfs-volume                                  1               N/A               1                     151d
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
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   287d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               256d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 264d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                262d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 264d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 264d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   267d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        266d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        263d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        157d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   246d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        251d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        250d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        255d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        266d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        250d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        251d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        268d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        252d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        252d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        267d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   245d
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   268d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   288d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   265d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   265d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   265d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   265d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   265d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   265d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   265d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   265d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 4 |
| External Secrets | 17 |
| Certificates | 21 |
| ServiceMonitors | 28 |
| CiliumNetworkPolicies | 4 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE    PAUSED
daily-backup    Enabled   0 2 * * *   61m          267d   false
weekly-backup   Enabled   0 3 * * 0   4d           267d   false
```

### Recent Backups (last 5)
```
weekly-backup-20260705030004   3d3h
daily-backup-20260817020015    3d1h
cb-20260728141353              2d22h
daily-backup-20260818020016    2d1h
daily-backup-20260819020018    25h
```

---

## Helm Releases
```
NAME                	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd              	argocd                	9       	2026-03-15 17:16:45.748376325 +0000 UTC	deployed	argo-cd-7.7.10                        	v2.13.2    
cert-manager        	cert-manager          	4       	2026-08-16 20:22:17.02474649 +0000 UTC 	deployed	cert-manager-v1.17.1                  	v1.17.1    
cilium              	kube-system           	23      	2026-08-16 19:52:42.423404071 +0000 UTC	deployed	cilium-1.20.0                         	1.20.0     
external-secrets    	external-secrets      	3       	2026-08-16 19:44:17.756739716 +0000 UTC	deployed	external-secrets-1.1.1                	v1.1.1     
ingress-nginx       	ingress-nginx         	14      	2026-07-07 14:07:26.472035985 +0000 UTC	deployed	ingress-nginx-4.15.1                  	1.15.1     
k8s-agent           	REDACTED_01b50c5d	8       	2026-08-16 19:44:19.392287363 +0000 UTC	deployed	gitlab-agent-2.28.0                   	v19.1.0    
REDACTED_d97cef76	REDACTED_d97cef76  	2       	2026-02-25 19:02:27.096604857 +0000 UTC	deployed	REDACTED_d97cef76-7.14.0           	           
loki                	logging               	12      	2026-07-07 13:12:39.944244427 +0000 UTC	deployed	loki-6.55.0                           	3.6.7      
monitoring          	monitoring            	29      	2026-08-18 18:04:32.800582493 +0000 UTC	deployed	REDACTED_d8074874-79.12.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	9       	2026-08-16 19:44:19.484898096 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
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
argocd                   Active   267d
awx                      Active   288d
bentopdf                 Active   263d
cert-manager             Active   262d
cilium-secrets           Active   264d
cilium-spire             Active   264d
default                  Active   289d
echo-server              Active   157d
external-secrets         Active   263d
gatus                    Active   246d
REDACTED_01b50c5d   Active   268d
ingress-nginx            Active   287d
kube-node-lease          Active   289d
kube-public              Active   289d
kube-system              Active   289d
REDACTED_d97cef76     Active   250d
logging                  Active   262d
monitoring               Active   288d
nfs-provisioner          Active   287d
opentofu-ns              Active   287d
pihole                   Active   268d
production               Active   268d
seaweedfs                Active   252d
synology-csi             Active   265d
velero                   Active   267d
well-known               Active   245d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           267d
argocd                   argocd-notifications-controller                   1/1     1            1           158d
argocd                   argocd-redis                                      1/1     1            1           267d
argocd                   argocd-repo-server                                2/2     2            2           267d
argocd                   argocd-server                                     2/2     2            2           267d
awx                      awx-operator-controller-manager                   1/1     1            1           288d
awx                      my-awx-task                                       1/1     1            1           288d
awx                      my-awx-web                                        1/1     1            1           288d
bentopdf                 bentopdf                                          1/1     1            1           263d
cert-manager             cert-manager                                      1/1     1            1           262d
cert-manager             cert-manager-cainjector                           1/1     1            1           262d
cert-manager             cert-manager-webhook                              1/1     1            1           262d
echo-server              echo-server                                       1/1     1            1           157d
external-secrets         external-secrets                                  1/1     1            1           263d
external-secrets         external-secrets-cert-controller                  1/1     1            1           263d
external-secrets         external-secrets-webhook                          1/1     1            1           263d
gatus                    gatus                                             1/1     1            1           246d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           268d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           287d
kube-system              cilium-operator                                   1/1     1            1           264d
kube-system              clustermesh-apiserver                             1/1     1            1           256d
kube-system              coredns                                           2/2     2            2           289d
kube-system              hubble-relay                                      1/1     1            1           264d
kube-system              hubble-ui                                         1/1     1            1           264d
kube-system              metrics-server                                    1/1     1            1           288d
kube-system              tetragon-operator                                 1/1     1            1           243d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           250d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           250d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           250d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           250d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           250d
monitoring               bgpalerter                                        1/1     1            1           248d
monitoring               monitoring-grafana                                2/2     2            2           130d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           130d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           130d
monitoring               snmp-exporter                                     1/1     1            1           250d
monitoring               thanos-query                                      2/2     2            2           251d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           287d
pihole                   pihole                                            1/1     1            1           263d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           251d
velero                   velero                                            1/1     1            1           267d
velero                   velero-ui                                         1/1     1            1           267d
well-known               well-known                                        1/1     1            1           245d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     267d
awx            my-awx-postgres-15                                     1/1     288d
cilium-spire   spire-server                                           1/1     264d
logging        loki                                                   1/1     243d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     130d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     130d
monitoring     thanos-compactor                                       1/1     251d
monitoring     thanos-store                                           2/2     251d
seaweedfs      seaweedfs-filer                                        2/2     252d
seaweedfs      seaweedfs-master                                       3/3     252d
seaweedfs      seaweedfs-volume                                       2/2     20d
synology-csi   synology-csi-controller                                1/1     265d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   264d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   264d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   264d
kube-system    kube-proxy                            7         7         7       7            7           kubernetes.io/os=linux   3d11h
kube-system    tetragon                              7         7         7       7            7           <none>                   243d
logging        loki-canary                           4         4         4       4            4           <none>                   251d
logging        promtail                              7         7         7       7            7           <none>                   262d
monitoring     goldpinger                            7         7         7       7            7           <none>                   255d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   130d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   265d
velero         node-agent                            4         4         4       4            4           <none>                   22d
```

---

*Full cluster context dump - v3.1.0*
