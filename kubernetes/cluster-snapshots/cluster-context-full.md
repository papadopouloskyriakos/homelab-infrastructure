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

**Generated:** 2026-08-19 03:00:02 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | CRITICAL | ⚠️ |
| Unhealthy Pods | 24 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 476 | ⚠️ |

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
velero                   argocd-default-kopia-maintain-job-1787107794068-7qg22             0/1   Error       0                 11m
velero                   argocd-default-kopia-maintain-job-1787107995426-869gr             0/1   Error       0                 7m52s
velero                   argocd-default-kopia-maintain-job-1787108295427-gxm9p             0/1   Error       0                 2m52s
velero                   awx-default-kopia-maintain-job-1787107733770-g2rng                0/1   Error       0                 12m
velero                   awx-default-kopia-maintain-job-1787108049716-rcv99                0/1   Error       0                 6m58s
velero                   awx-default-kopia-maintain-job-1787108347807-5n2nk                0/1   Error       0                 2m
velero                   cilium-spire-default-kopia-maintain-job-1787107695425-xt9vf       0/1   Error       0                 12m
velero                   cilium-spire-default-kopia-maintain-job-1787108013506-rmq92       0/1   Error       0                 7m34s
velero                   cilium-spire-default-kopia-maintain-job-1787108313479-j7v4q       0/1   Error       0                 2m34s
velero                   gatus-default-kopia-maintain-job-1787107702505-6p6vh              0/1   Error       0                 12m
velero                   gatus-default-kopia-maintain-job-1787108020542-ftdz9              0/1   Error       0                 7m27s
velero                   gatus-default-kopia-maintain-job-1787108319528-n2pbm              0/1   Error       0                 2m28s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-17871077558dvps   0/1   Error       0                 11m
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787108068khz7x   0/1   Error       0                 6m39s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787108365bxjvp   0/1   Error       0                 102s
velero                   logging-default-kopia-maintain-job-1787107708542-r6jwn            0/1   Error       0                 12m
velero                   logging-default-kopia-maintain-job-1787108025589-smx5g            0/1   Error       0                 7m22s
velero                   logging-default-kopia-maintain-job-1787108325647-8s5vj            0/1   Error       0                 2m22s
velero                   monitoring-default-kopia-maintain-job-1787107726604-kht58         0/1   Error       0                 12m
velero                   monitoring-default-kopia-maintain-job-1787108043630-pmc4f         0/1   Error       0                 7m4s
velero                   monitoring-default-kopia-maintain-job-1787108342704-xttfn         0/1   Error       0                 2m5s
velero                   well-known-default-kopia-maintain-job-1787107775979-p2gd4         0/1   Error       0                 11m
velero                   well-known-default-kopia-maintain-job-1787108088784-99hth         0/1   Error       0                 6m19s
velero                   well-known-default-kopia-maintain-job-1787108382897-whskp         0/1   Error       0                 85s
```

#### Unhealthy Pod Details

**velero/argocd-default-kopia-maintain-job-1787107794068-7qg22:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  11m   default-scheduler  Successfully assigned velero/argocd-default-kopia-maintain-job-1787107794068-7qg22 to nlk8s-node04
  Normal  Pulled     11m   kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    11m   kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    11m   kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

**velero/argocd-default-kopia-maintain-job-1787107995426-869gr:**
```
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  7m51s  default-scheduler  Successfully assigned velero/argocd-default-kopia-maintain-job-1787107995426-869gr to nlk8s-node04
  Normal  Pulled     7m51s  kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    7m51s  kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    7m51s  kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

**velero/argocd-default-kopia-maintain-job-1787108295427-gxm9p:**
```
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  2m52s  default-scheduler  Successfully assigned velero/argocd-default-kopia-maintain-job-1787108295427-gxm9p to nlk8s-node04
  Normal  Pulled     2m51s  kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    2m51s  kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    2m51s  kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

**velero/awx-default-kopia-maintain-job-1787107733770-g2rng:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  12m   default-scheduler  Successfully assigned velero/awx-default-kopia-maintain-job-1787107733770-g2rng to nlk8s-node04
  Normal  Pulled     12m   kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    12m   kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    12m   kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

**velero/awx-default-kopia-maintain-job-1787108049716-rcv99:**
```
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  6m58s  default-scheduler  Successfully assigned velero/awx-default-kopia-maintain-job-1787108049716-rcv99 to nlk8s-node04
  Normal  Pulled     6m56s  kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    6m56s  kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    6m56s  kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

### High Restart Pods (>3 restarts)
- ingress-nginx/ingress-nginx-controller-8445475547-6zqqc: 14 restarts
- ingress-nginx/ingress-nginx-controller-8445475547-kr7kz: 17 restarts
- kube-system/clustermesh-apiserver-6c8cd7bb6f-ctst4: 23 restarts
- kube-system/tetragon-5gk99: 7 restarts
- kube-system/tetragon-75hdg: 8 restarts
- kube-system/tetragon-878gv: 8 restarts
- kube-system/tetragon-jz2b6: 6 restarts
- kube-system/tetragon-mdsn9: 23 restarts
- kube-system/tetragon-tbcc7: 8 restarts
- kube-system/tetragon-vbs6v: 16 restarts
- logging/promtail-5jr9j: 4 restarts
- logging/promtail-hp5sc: 8 restarts
- logging/promtail-ng69s: 5 restarts
- monitoring/monitoring-grafana-6c7c5dfd7b-xfrlh: 14 restarts
- monitoring/monitoring-kube-prometheus-operator-67d8d4c647-vwbbr: 4 restarts
- monitoring/monitoring-kube-state-metrics-75f9fff55b-4vfg6: 8 restarts
- monitoring/monitoring-prometheus-node-exporter-6dl8r: 175 restarts
- monitoring/monitoring-prometheus-node-exporter-6sc8j: 9 restarts
- monitoring/monitoring-prometheus-node-exporter-vgp6b: 4 restarts
- monitoring/monitoring-prometheus-node-exporter-wmcb8: 46 restarts
- monitoring/prometheus-REDACTED_6dfbe9fc-0: 17 restarts
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
NAMESPACE                LAST SEEN   TYPE      REASON                 OBJECT                                                              MESSAGE
kube-system              60m         Warning   Unhealthy              pod/kube-apiserver-nlk8s-ctrl01                               Readiness probe failed: HTTP probe failed with statuscode: 500
default                  57m         Warning   SystemOOM              node/nlk8s-node04                                              System OOM encountered, victim process: prometheus, pid: 967770
monitoring               57m         Warning   Unhealthy              pod/prometheus-REDACTED_6dfbe9fc-0              Readiness probe failed: Get "http://10.0.0.82:9090/-/ready": dial tcp 10.0.0.82:9090: connect: connection refused
velero                   57m         Warning   BackoffLimitExceeded   job/logging-default-kopia-maintain-job-1787104995416                Job has reached the specified backoff limit
velero                   57m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1787105017478             Job has reached the specified backoff limit
velero                   57m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1787105022586                    Job has reached the specified backoff limit
velero                   56m         Warning   BackoffLimitExceeded   job/REDACTED_d97cef76-default-kopia-maintain-job-1787105040624   Job has reached the specified backoff limit
velero                   56m         Warning   BackoffLimitExceeded   job/well-known-default-kopia-maintain-job-1787105056658             Job has reached the specified backoff limit
velero                   56m         Warning   BackoffLimitExceeded   job/argocd-default-kopia-maintain-job-1787105072712                 Job has reached the specified backoff limit
velero                   56m         Warning   BackoffLimitExceeded   job/cilium-spire-default-kopia-maintain-job-1787105088755           Job has reached the specified backoff limit
velero                   56m         Warning   BackoffLimitExceeded   job/gatus-default-kopia-maintain-job-1787105092793                  Job has reached the specified backoff limit
default                  54m         Warning   SystemOOM              node/nlk8s-node04                                              System OOM encountered, victim process: clustermesh-api, pid: 967456
default                  54m         Warning   SystemOOM              node/nlk8s-node04                                              System OOM encountered, victim process: grafana, pid: 977706
default                  54m         Warning   SystemOOM              node/nlk8s-node04                                              System OOM encountered, victim process: clustermesh-api, pid: 967525
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
nlk8s-ctrl01   1281m        32%      3079Mi          39%         
nlk8s-ctrl02   1382m        34%      2973Mi          36%         
nlk8s-ctrl03   442m         11%      2875Mi          36%         
nlk8s-node01    1181m        14%      5847Mi          74%         
nlk8s-node02    698m         8%       4796Mi          61%         
nlk8s-node03    620m         7%       4309Mi          55%         
nlk8s-node04    2292m        28%      6706Mi          85%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                866m         3543Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                485m         2926Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 384m         1468Mi          
kube-system              etcd-nlk8s-ctrl02                                           303m         118Mi           
kube-system              tetragon-mdsn9                                                    268m         174Mi           
kube-system              cilium-7rvww                                                      206m         223Mi           
kube-system              cilium-g5h5t                                                      206m         185Mi           
kube-system              kube-apiserver-nlk8s-ctrl03                                 163m         1493Mi          
logging                  promtail-94tkz                                                    153m         74Mi            
kube-system              cilium-qw7d6                                                      129m         218Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                866m         3543Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                485m         2926Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 72m          1518Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 163m         1493Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 384m         1468Mi          
awx                      my-awx-task-756d768868-bslc2                                      26m          1429Mi          
awx                      my-awx-web-55ccb47b58-nzk8w                                       6m           1390Mi          
seaweedfs                seaweedfs-volume-1                                                64m          971Mi           
seaweedfs                seaweedfs-filer-1                                                 66m          842Mi           
logging                  loki-0                                                            72m          824Mi           
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
argocd            argocd-application-controller                     1               N/A               0                     264d
argocd            argocd-applicationset-controller                  1               N/A               0                     264d
argocd            argocd-redis                                      1               N/A               0                     264d
argocd            argocd-repo-server                                1               N/A               1                     264d
argocd            argocd-server                                     1               N/A               1                     264d
awx               awx-postgres-pdb                                  1               N/A               0                     264d
awx               awx-task-pdb                                      1               N/A               0                     264d
awx               awx-web-pdb                                       1               N/A               0                     264d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     264d
kube-system       coredns-pdb                                       1               N/A               1                     264d
kube-system       metrics-server-pdb                                1               N/A               0                     264d
monitoring        monitoring-grafana                                1               N/A               1                     129d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     129d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     129d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     264d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     150d
seaweedfs         seaweedfs-master                                  2               N/A               1                     150d
seaweedfs         seaweedfs-volume                                  1               N/A               1                     150d
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
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   286d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               255d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 263d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                261d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 263d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 263d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   266d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        265d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        262d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        156d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   245d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        250d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        249d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        254d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        265d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        249d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        250d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        267d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        251d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        251d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        266d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   244d
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   267d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   287d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   264d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   264d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   264d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   264d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   264d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   264d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   264d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   264d
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
daily-backup    Enabled   0 2 * * *   61m          266d   false
weekly-backup   Enabled   0 3 * * 0   3d           266d   false
```

### Recent Backups (last 5)
```
weekly-backup-20260816030042   3d
weekly-backup-20260705030004   2d3h
daily-backup-20260817020015    2d1h
cb-20260728141353              46h
daily-backup-20260818020016    25h
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
argocd                   Active   266d
awx                      Active   287d
bentopdf                 Active   262d
cert-manager             Active   261d
cilium-secrets           Active   263d
cilium-spire             Active   263d
default                  Active   288d
echo-server              Active   156d
external-secrets         Active   262d
gatus                    Active   245d
REDACTED_01b50c5d   Active   267d
ingress-nginx            Active   286d
kube-node-lease          Active   288d
kube-public              Active   288d
kube-system              Active   288d
REDACTED_d97cef76     Active   249d
logging                  Active   261d
monitoring               Active   287d
nfs-provisioner          Active   286d
opentofu-ns              Active   286d
pihole                   Active   267d
production               Active   267d
seaweedfs                Active   251d
synology-csi             Active   264d
velero                   Active   266d
well-known               Active   244d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           266d
argocd                   argocd-notifications-controller                   1/1     1            1           157d
argocd                   argocd-redis                                      1/1     1            1           266d
argocd                   argocd-repo-server                                2/2     2            2           266d
argocd                   argocd-server                                     2/2     2            2           266d
awx                      awx-operator-controller-manager                   1/1     1            1           287d
awx                      my-awx-task                                       1/1     1            1           287d
awx                      my-awx-web                                        1/1     1            1           287d
bentopdf                 bentopdf                                          1/1     1            1           262d
cert-manager             cert-manager                                      1/1     1            1           261d
cert-manager             cert-manager-cainjector                           1/1     1            1           261d
cert-manager             cert-manager-webhook                              1/1     1            1           261d
echo-server              echo-server                                       1/1     1            1           156d
external-secrets         external-secrets                                  1/1     1            1           262d
external-secrets         external-secrets-cert-controller                  1/1     1            1           262d
external-secrets         external-secrets-webhook                          1/1     1            1           262d
gatus                    gatus                                             1/1     1            1           245d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           267d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           286d
kube-system              cilium-operator                                   1/1     1            1           263d
kube-system              clustermesh-apiserver                             1/1     1            1           255d
kube-system              coredns                                           2/2     2            2           288d
kube-system              hubble-relay                                      1/1     1            1           263d
kube-system              hubble-ui                                         1/1     1            1           263d
kube-system              metrics-server                                    1/1     1            1           287d
kube-system              tetragon-operator                                 1/1     1            1           242d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           249d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           249d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           249d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           249d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           249d
monitoring               bgpalerter                                        1/1     1            1           247d
monitoring               monitoring-grafana                                2/2     2            2           129d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           129d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           129d
monitoring               snmp-exporter                                     1/1     1            1           249d
monitoring               thanos-query                                      2/2     2            2           250d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           286d
pihole                   pihole                                            1/1     1            1           262d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           250d
velero                   velero                                            1/1     1            1           266d
velero                   velero-ui                                         1/1     1            1           266d
well-known               well-known                                        1/1     1            1           244d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     266d
awx            my-awx-postgres-15                                     1/1     287d
cilium-spire   spire-server                                           1/1     263d
logging        loki                                                   1/1     242d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     129d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     129d
monitoring     thanos-compactor                                       1/1     250d
monitoring     thanos-store                                           2/2     250d
seaweedfs      seaweedfs-filer                                        2/2     251d
seaweedfs      seaweedfs-master                                       3/3     251d
seaweedfs      seaweedfs-volume                                       2/2     19d
synology-csi   synology-csi-controller                                1/1     264d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   263d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   263d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   263d
kube-system    kube-proxy                            7         7         7       7            7           kubernetes.io/os=linux   2d11h
kube-system    tetragon                              7         7         7       7            7           <none>                   242d
logging        loki-canary                           4         4         4       4            4           <none>                   250d
logging        promtail                              7         7         7       7            7           <none>                   261d
monitoring     goldpinger                            7         7         7       7            7           <none>                   254d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   129d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   264d
velero         node-agent                            4         4         4       4            4           <none>                   21d
```

---

*Full cluster context dump - v3.1.0*
