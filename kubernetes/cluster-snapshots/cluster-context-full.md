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

**Generated:** 2026-07-30 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | CRITICAL | ⚠️ |
| Unhealthy Pods | 43 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 3230 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.19.5 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 193 |

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
velero                   argocd-default-kopia-maintain-job-1785379647500-kpk2r             0/1   Error       0                  13m
velero                   argocd-default-kopia-maintain-job-1785380138142-d285g             0/1   Error       0                  5m18s
velero                   argocd-default-kopia-maintain-job-1785380389525-h7s7n             0/1   Error       0                  67s
velero                   awx-default-kopia-maintain-job-1785379374367-drrlp                0/1   Error       0                  18m
velero                   awx-default-kopia-maintain-job-1785379672675-mv87n                0/1   Error       0                  13m
velero                   awx-default-kopia-maintain-job-1785380159225-6gtgr                0/1   Error       0                  4m57s
velero                   cilium-spire-default-kopia-maintain-job-1785379814546-ftzpz       0/1   Error       0                  10m
velero                   cilium-spire-default-kopia-maintain-job-1785380027586-j29ch       0/1   Error       0                  7m9s
velero                   cilium-spire-default-kopia-maintain-job-1785380287973-gf8hz       0/1   Error       0                  2m48s
velero                   gatus-default-kopia-maintain-job-1785379564956-lttm2              0/1   Error       0                  14m
velero                   gatus-default-kopia-maintain-job-1785380041763-k98kc              0/1   Error       0                  6m55s
velero                   gatus-default-kopia-maintain-job-1785380298089-m6wp7              0/1   Error       0                  2m38s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1785379701k2b57   0/1   Error       0                  12m
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1785379864wqw94   0/1   Error       0                  9m52s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1785380179hlnn7   0/1   Error       0                  4m37s
velero                   logging-default-kopia-maintain-job-1785379725858-7rwbc            0/1   Error       0                  12m
velero                   logging-default-kopia-maintain-job-1785379889029-zccz8            0/1   Error       0                  9m27s
velero                   logging-default-kopia-maintain-job-1785380198448-96vss            0/1   Error       0                  4m18s
velero                   monitoring-default-kopia-maintain-job-1785379747999-gd2tm         0/1   Error       0                  11m
velero                   monitoring-default-kopia-maintain-job-1785379913100-nt9db         0/1   Error       0                  9m3s
velero                   monitoring-default-kopia-maintain-job-1785380218511-wddwq         0/1   Error       0                  3m58s
velero                   nfs-provisioner-default-kopia-maintain-job-1785379577053-lqcxx    0/1   Error       0                  14m
velero                   nfs-provisioner-default-kopia-maintain-job-1785380054854-jsnj6    0/1   Error       0                  6m42s
velero                   nfs-provisioner-default-kopia-maintain-job-1785380308206-cbmr7    0/1   Error       0                  2m28s
velero                   pihole-default-kopia-maintain-job-1785379759136-mzqsj             0/1   Error       0                  11m
velero                   pihole-default-kopia-maintain-job-1785379941168-glrh6             0/1   Error       0                  8m35s
velero                   pihole-default-kopia-maintain-job-1785380229575-swdgp             0/1   Error       0                  3m47s
velero                   REDACTED_00313366-maintain-job-1785379768296-zwqzb          0/1   Error       0                  11m
velero                   REDACTED_00313366-maintain-job-1785379961254-xbtw5          0/1   Error       0                  8m15s
velero                   REDACTED_00313366-maintain-job-1785380239667-dxxfc          0/1   Error       0                  3m37s
velero                   synology-csi-default-kopia-maintain-job-1785379587164-pjpjj       0/1   Error       0                  14m
velero                   synology-csi-default-kopia-maintain-job-1785380076931-p6jjl       0/1   Error       0                  6m20s
velero                   synology-csi-default-kopia-maintain-job-1785380326288-xj87h       0/1   Error       0                  2m10s
velero                   velero-resttest-default-kopia-maintain-job-1785379789440-76b57    0/1   Error       0                  11m
velero                   velero-resttest-default-kopia-maintain-job-1785379991369-kkqd4    0/1   Error       0                  7m45s
velero                   velero-resttest-default-kopia-maintain-job-1785380259796-th4dx    0/1   Error       0                  3m17s
velero                   velero-rt-default-kopia-maintain-job-1785379797408-q7vbb          0/1   Error       0                  10m
velero                   velero-rt-default-kopia-maintain-job-1785380007518-bqmp6          0/1   Error       0                  7m29s
velero                   velero-rt-default-kopia-maintain-job-1785380266878-fd7m6          0/1   Error       0                  3m10s
velero                   well-known-default-kopia-maintain-job-1785379621373-4qnss         0/1   Error       0                  13m
velero                   well-known-default-kopia-maintain-job-1785380104068-hvpfw         0/1   Error       0                  5m52s
velero                   well-known-default-kopia-maintain-job-1785380359382-v4q2f         0/1   Error       0                  97s
```

#### Unhealthy Pod Details

**velero/argocd-default-kopia-maintain-job-1785379647500-kpk2r:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  13m   default-scheduler  Successfully assigned velero/argocd-default-kopia-maintain-job-1785379647500-kpk2r to nlk8s-node01
  Normal  Pulled     13m   kubelet            Container image "velero/velero:v1.17.1" already present on machine
  Normal  Created    13m   kubelet            Created container: velero-repo-maintenance-container
  Normal  Started    13m   kubelet            Started container velero-repo-maintenance-container
```

**velero/argocd-default-kopia-maintain-job-1785380138142-d285g:**
```
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  5m18s  default-scheduler  Successfully assigned velero/argocd-default-kopia-maintain-job-1785380138142-d285g to nlk8s-node01
  Normal  Pulled     5m19s  kubelet            Container image "velero/velero:v1.17.1" already present on machine
  Normal  Created    5m18s  kubelet            Created container: velero-repo-maintenance-container
  Normal  Started    5m18s  kubelet            Started container velero-repo-maintenance-container
```

**velero/argocd-default-kopia-maintain-job-1785380389525-h7s7n:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  67s   default-scheduler  Successfully assigned velero/argocd-default-kopia-maintain-job-1785380389525-h7s7n to nlk8s-node01
  Normal  Pulled     67s   kubelet            Container image "velero/velero:v1.17.1" already present on machine
  Normal  Created    67s   kubelet            Created container: velero-repo-maintenance-container
  Normal  Started    67s   kubelet            Started container velero-repo-maintenance-container
```

**velero/awx-default-kopia-maintain-job-1785379374367-drrlp:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  18m   default-scheduler  Successfully assigned velero/awx-default-kopia-maintain-job-1785379374367-drrlp to nlk8s-node01
  Normal  Pulled     17m   kubelet            Container image "velero/velero:v1.17.1" already present on machine
  Normal  Created    17m   kubelet            Created container: velero-repo-maintenance-container
  Normal  Started    17m   kubelet            Started container velero-repo-maintenance-container
```

**velero/awx-default-kopia-maintain-job-1785379672675-mv87n:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  13m   default-scheduler  Successfully assigned velero/awx-default-kopia-maintain-job-1785379672675-mv87n to nlk8s-node01
  Normal  Pulled     13m   kubelet            Container image "velero/velero:v1.17.1" already present on machine
  Normal  Created    13m   kubelet            Created container: velero-repo-maintenance-container
  Normal  Started    13m   kubelet            Started container velero-repo-maintenance-container
```

### High Restart Pods (>3 restarts)
- argocd/argocd-repo-server-7dfc645f84-qxz64: 5 restarts
- argocd/argocd-server-64dd47d8bf-fkr26: 35 restarts
- awx/awx-operator-controller-manager-6ffdf98f6-hwvqf: 19 restarts
- cilium-spire/spire-agent-49g4h: 28 restarts
- cilium-spire/spire-agent-mdslp: 8 restarts
- cilium-spire/spire-server-0: 17 restarts
- REDACTED_01b50c5d/REDACTED_ab04b573-v2-8c85f5d4b-ng8lb: 24 restarts
- ingress-nginx/ingress-nginx-controller-8445475547-mxdrc: 16 restarts
- kube-system/cilium-operator-6cdbfb68d7-z6v2x: 5 restarts
- kube-system/clustermesh-apiserver-6c96779765-rmrzt: 41 restarts
- kube-system/etcd-nlk8s-ctrl01: 64 restarts
- kube-system/hubble-ui-6bb97d8894-nnkx5: 21 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 1996 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 58 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 14 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 108 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 37 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 92 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 37 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 34 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 38 restarts
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
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956jjmld: 49 restarts
- seaweedfs/seaweedfs-filer-0: 31 restarts
- seaweedfs/seaweedfs-filer-1: 42 restarts
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
NAMESPACE                LAST SEEN   TYPE      REASON                 OBJECT                                                              MESSAGE
velero                   108m        Warning   BackoffLimitExceeded   job/well-known-default-kopia-maintain-job-1785373919297             Job has reached the specified backoff limit
velero                   108m        Warning   BackoffLimitExceeded   job/argocd-default-kopia-maintain-job-1785373937379                 Job has reached the specified backoff limit
velero                   108m        Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1785373952430                    Job has reached the specified backoff limit
velero                   107m        Warning   BackoffLimitExceeded   job/REDACTED_d97cef76-default-kopia-maintain-job-1785373970548   Job has reached the specified backoff limit
velero                   107m        Warning   BackoffLimitExceeded   job/logging-default-kopia-maintain-job-1785373987624                Job has reached the specified backoff limit
velero                   107m        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1785374004689             Job has reached the specified backoff limit
velero                   107m        Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1785374011849                 Job has reached the specified backoff limit
velero                   107m        Warning   BackoffLimitExceeded   job/REDACTED_00313366-maintain-job-1785374016969              Job has reached the specified backoff limit
velero                   104m        Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1785374164943                    Job has reached the specified backoff limit
velero                   104m        Warning   BackoffLimitExceeded   job/REDACTED_d97cef76-default-kopia-maintain-job-1785374182014   Job has reached the specified backoff limit
velero                   104m        Warning   BackoffLimitExceeded   job/logging-default-kopia-maintain-job-1785374199103                Job has reached the specified backoff limit
velero                   103m        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1785374217161             Job has reached the specified backoff limit
velero                   103m        Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1785374225224                 Job has reached the specified backoff limit
velero                   103m        Warning   BackoffLimitExceeded   job/REDACTED_00313366-maintain-job-1785374230283              Job has reached the specified backoff limit
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
nlk8s-ctrl01   1237m        30%      3069Mi          39%         
nlk8s-ctrl02   1694m        42%      3400Mi          42%         
nlk8s-ctrl03   359m         8%       3178Mi          40%         
nlk8s-node01    470m         5%       5372Mi          68%         
nlk8s-node02    589m         7%       6114Mi          78%         
nlk8s-node03    466m         5%       6405Mi          81%         
nlk8s-node04    778m         9%       4284Mi          54%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-1                428m         1964Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 411m         1566Mi          
kube-system              tetragon-mdsn9                                                    358m         656Mi           
kube-system              etcd-nlk8s-ctrl02                                           255m         154Mi           
kube-system              cilium-64v2f                                                      200m         198Mi           
logging                  promtail-m2gzm                                                    197m         72Mi            
monitoring               prometheus-REDACTED_6dfbe9fc-0                186m         1758Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 154m         1566Mi          
seaweedfs                seaweedfs-volume-0                                                116m         825Mi           
seaweedfs                seaweedfs-volume-1                                                110m         1162Mi          
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-1                428m         1964Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                186m         1758Mi          
awx                      my-awx-task-756d768868-k9sdd                                      20m          1593Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 154m         1566Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 411m         1566Mi          
awx                      my-awx-web-55ccb47b58-m95v8                                       5m           1487Mi          
seaweedfs                seaweedfs-filer-0                                                 63m          1481Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 75m          1402Mi          
seaweedfs                seaweedfs-filer-1                                                 44m          1285Mi          
seaweedfs                seaweedfs-volume-1                                                110m         1162Mi          
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
argocd            argocd-application-controller                     1               N/A               0                     244d
argocd            argocd-applicationset-controller                  1               N/A               0                     244d
argocd            argocd-redis                                      1               N/A               0                     244d
argocd            argocd-repo-server                                1               N/A               1                     244d
argocd            argocd-server                                     1               N/A               1                     244d
awx               awx-postgres-pdb                                  1               N/A               0                     244d
awx               awx-task-pdb                                      1               N/A               0                     244d
awx               awx-web-pdb                                       1               N/A               0                     244d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     244d
kube-system       coredns-pdb                                       1               N/A               1                     244d
kube-system       metrics-server-pdb                                1               N/A               0                     244d
monitoring        monitoring-grafana                                1               N/A               1                     109d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     109d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     109d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     244d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     130d
seaweedfs         seaweedfs-master                                  2               N/A               1                     130d
seaweedfs         seaweedfs-volume                                  1               N/A               1                     130d
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
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   266d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               235d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 243d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                241d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 243d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 243d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   246d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        245d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        242d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        136d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   225d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        230d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        229d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        234d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        245d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        229d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        230d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        247d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        231d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        231d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        246d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   224d
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   247d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   267d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   244d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   244d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   244d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   244d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   244d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   244d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   244d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   244d
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
daily-backup    Enabled   0 2 * * *   61m          246d   
weekly-backup   Enabled   0 3 * * 0   4d           246d   
```

### Recent Backups (last 5)
```
daily-backup-20260718020019    36h
daily-backup-20260715020016    36h
daily-backup-20260714020015    36h
daily-backup-20260721020023    36h
daily-backup-20260729020005    25h
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
monitoring          	monitoring            	20      	2026-07-27 01:38:18.157238752 +0000 UTC	deployed	REDACTED_d8074874-79.12.0         	v0.86.2    
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
argocd                   Active   246d
awx                      Active   267d
bentopdf                 Active   242d
cert-manager             Active   241d
cilium-secrets           Active   243d
cilium-spire             Active   243d
default                  Active   268d
echo-server              Active   136d
external-secrets         Active   242d
gatus                    Active   225d
REDACTED_01b50c5d   Active   247d
ingress-nginx            Active   266d
kube-node-lease          Active   268d
kube-public              Active   268d
kube-system              Active   268d
REDACTED_d97cef76     Active   229d
logging                  Active   241d
monitoring               Active   267d
nfs-provisioner          Active   266d
opentofu-ns              Active   266d
pihole                   Active   247d
production               Active   247d
seaweedfs                Active   231d
synology-csi             Active   244d
velero                   Active   246d
well-known               Active   224d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           246d
argocd                   argocd-notifications-controller                   1/1     1            1           137d
argocd                   argocd-redis                                      1/1     1            1           246d
argocd                   argocd-repo-server                                2/2     2            2           246d
argocd                   argocd-server                                     2/2     2            2           246d
awx                      awx-operator-controller-manager                   1/1     1            1           267d
awx                      my-awx-task                                       1/1     1            1           267d
awx                      my-awx-web                                        1/1     1            1           267d
bentopdf                 bentopdf                                          1/1     1            1           242d
cert-manager             cert-manager                                      1/1     1            1           241d
cert-manager             cert-manager-cainjector                           1/1     1            1           241d
cert-manager             cert-manager-webhook                              1/1     1            1           241d
echo-server              echo-server                                       1/1     1            1           136d
external-secrets         external-secrets                                  1/1     1            1           242d
external-secrets         external-secrets-cert-controller                  1/1     1            1           242d
external-secrets         external-secrets-webhook                          1/1     1            1           242d
gatus                    gatus                                             1/1     1            1           225d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           247d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           266d
kube-system              cilium-operator                                   1/1     1            1           243d
kube-system              clustermesh-apiserver                             1/1     1            1           235d
kube-system              coredns                                           2/2     2            2           268d
kube-system              hubble-relay                                      1/1     1            1           243d
kube-system              hubble-ui                                         1/1     1            1           243d
kube-system              metrics-server                                    1/1     1            1           267d
kube-system              tetragon-operator                                 1/1     1            1           222d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           229d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           229d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           229d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           229d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           229d
monitoring               bgpalerter                                        1/1     1            1           227d
monitoring               monitoring-grafana                                2/2     2            2           109d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           109d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           109d
monitoring               snmp-exporter                                     1/1     1            1           229d
monitoring               thanos-query                                      2/2     2            2           230d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           266d
pihole                   pihole                                            1/1     1            1           242d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           230d
velero                   velero                                            1/1     1            1           246d
velero                   velero-ui                                         1/1     1            1           246d
well-known               well-known                                        1/1     1            1           224d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     246d
awx            my-awx-postgres-15                                     1/1     267d
cilium-spire   spire-server                                           1/1     243d
logging        loki                                                   1/1     222d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     109d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     109d
monitoring     thanos-compactor                                       1/1     230d
monitoring     thanos-store                                           2/2     230d
seaweedfs      seaweedfs-filer                                        2/2     231d
seaweedfs      seaweedfs-master                                       3/3     231d
seaweedfs      seaweedfs-volume                                       2/2     231d
synology-csi   synology-csi-controller                                1/1     244d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   243d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   243d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   243d
kube-system    tetragon                              7         7         7       7            7           <none>                   222d
logging        loki-canary                           4         4         4       4            4           <none>                   230d
logging        promtail                              7         7         7       7            7           <none>                   241d
monitoring     goldpinger                            7         7         7       7            7           <none>                   234d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   109d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   244d
velero         node-agent                            4         4         4       4            4           <none>                   37h
```

---

*Full cluster context dump - v3.1.0*
