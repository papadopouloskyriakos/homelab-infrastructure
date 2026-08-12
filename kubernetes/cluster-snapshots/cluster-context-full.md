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

**Generated:** 2026-08-12 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | CRITICAL | ⚠️ |
| Unhealthy Pods | 18 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 3500 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.19.5 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 191 |

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
- **CPU:** 4 | **Memory:** 8003704Ki
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
- **CPU:** 8 | **Memory:** 8006716Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node03
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006728Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node04
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006716Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01


---

## Anomalies & Issues

### Unhealthy Pods
```
velero                   monitoring-default-kopia-maintain-job-1786502853667-bcw6m         0/1   Error       0                 13m
velero                   monitoring-default-kopia-maintain-job-1786503136322-69xsb         0/1   Error       0                 8m34s
velero                   monitoring-default-kopia-maintain-job-1786503436437-h6cmx         0/1   Error       0                 3m34s
velero                   nfs-provisioner-default-kopia-maintain-job-1786040876571-6bjxq    0/1   Error       0                 5d8h
velero                   nfs-provisioner-default-kopia-maintain-job-1786041167440-x8kbw    0/1   Error       0                 5d8h
velero                   nfs-provisioner-default-kopia-maintain-job-1786041455209-5bhtz    0/1   Error       0                 5d8h
velero                   pihole-default-kopia-maintain-job-1786040852187-99d5q             0/1   Error       0                 5d8h
velero                   pihole-default-kopia-maintain-job-1786041143027-7bfsl             0/1   Error       0                 5d8h
velero                   pihole-default-kopia-maintain-job-1786041487800-cm7xb             0/1   Error       0                 5d8h
velero                   REDACTED_00313366-maintain-job-1786040856243-5mlk6          0/1   Error       0                 5d8h
velero                   REDACTED_00313366-maintain-job-1786041147068-szc9f          0/1   Error       0                 5d8h
velero                   REDACTED_00313366-maintain-job-1786041434895-5md9m          0/1   Error       0                 5d8h
velero                   velero-resttest-default-kopia-maintain-job-1786040860311-rq69r    0/1   Error       0                 5d8h
velero                   velero-resttest-default-kopia-maintain-job-1786041151140-k7b4s    0/1   Error       0                 5d8h
velero                   velero-resttest-default-kopia-maintain-job-1786041438983-fdkgv    0/1   Error       0                 5d8h
velero                   velero-rt-default-kopia-maintain-job-1786040864370-kv498          0/1   Error       0                 5d8h
velero                   velero-rt-default-kopia-maintain-job-1786041155220-whvtw          0/1   Error       0                 5d8h
velero                   velero-rt-default-kopia-maintain-job-1786041443052-pvhfv          0/1   Error       0                 5d8h
```

#### Unhealthy Pod Details

**velero/monitoring-default-kopia-maintain-job-1786502853667-bcw6m:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  13m   default-scheduler  Successfully assigned velero/monitoring-default-kopia-maintain-job-1786502853667-bcw6m to nlk8s-node03
  Normal  Pulled     13m   kubelet            Container image "velero/velero:v1.17.1" already present on machine
  Normal  Created    13m   kubelet            Created container: velero-repo-maintenance-container
  Normal  Started    13m   kubelet            Started container velero-repo-maintenance-container
```

**velero/monitoring-default-kopia-maintain-job-1786503136322-69xsb:**
```
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  8m34s  default-scheduler  Successfully assigned velero/monitoring-default-kopia-maintain-job-1786503136322-69xsb to nlk8s-node03
  Normal  Pulled     8m33s  kubelet            Container image "velero/velero:v1.17.1" already present on machine
  Normal  Created    8m33s  kubelet            Created container: velero-repo-maintenance-container
  Normal  Started    8m33s  kubelet            Started container velero-repo-maintenance-container
```

**velero/monitoring-default-kopia-maintain-job-1786503436437-h6cmx:**
```
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  3m34s  default-scheduler  Successfully assigned velero/monitoring-default-kopia-maintain-job-1786503436437-h6cmx to nlk8s-node03
  Normal  Pulled     3m34s  kubelet            Container image "velero/velero:v1.17.1" already present on machine
  Normal  Created    3m34s  kubelet            Created container: velero-repo-maintenance-container
  Normal  Started    3m34s  kubelet            Started container velero-repo-maintenance-container
```

**velero/nfs-provisioner-default-kopia-maintain-job-1786040876571-6bjxq:**
```
Events:                      <none>
```

**velero/nfs-provisioner-default-kopia-maintain-job-1786041167440-x8kbw:**
```
Events:                      <none>
```

### High Restart Pods (>3 restarts)
- awx/awx-operator-controller-manager-6ffdf98f6-2k2jd: 5 restarts
- awx/my-awx-web-55ccb47b58-m95v8: 122 restarts
- cilium-spire/spire-agent-44qs8: 129 restarts
- cilium-spire/spire-agent-49g4h: 29 restarts
- cilium-spire/spire-agent-6lc7n: 130 restarts
- cilium-spire/spire-agent-mdslp: 133 restarts
- ingress-nginx/ingress-nginx-controller-8445475547-52656: 42 restarts
- ingress-nginx/ingress-nginx-controller-8445475547-lk4fg: 45 restarts
- kube-system/cilium-operator-6cdbfb68d7-z6v2x: 14 restarts
- kube-system/clustermesh-apiserver-6c96779765-f9j6x: 10 restarts
- kube-system/etcd-nlk8s-ctrl01: 64 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 1999 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 58 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 16 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 110 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 40 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 96 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 39 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 35 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 42 restarts
- kube-system/tetragon-5gk99: 5 restarts
- kube-system/tetragon-75hdg: 6 restarts
- kube-system/tetragon-878gv: 6 restarts
- kube-system/tetragon-jz2b6: 4 restarts
- kube-system/tetragon-mdsn9: 18 restarts
- kube-system/tetragon-tbcc7: 6 restarts
- kube-system/tetragon-vbs6v: 14 restarts
- logging/promtail-hp5sc: 7 restarts
- logging/promtail-ng69s: 4 restarts
- monitoring/goldpinger-25hf5: 47 restarts
- monitoring/goldpinger-6dj9l: 25 restarts
- monitoring/goldpinger-n2fzm: 9 restarts
- monitoring/goldpinger-zxtb9: 6 restarts
- monitoring/monitoring-prometheus-node-exporter-6dl8r: 174 restarts
- monitoring/monitoring-prometheus-node-exporter-6sc8j: 8 restarts
- monitoring/monitoring-prometheus-node-exporter-wmcb8: 45 restarts
- seaweedfs/seaweedfs-filer-sync-f7489458c-tgvcj: 5 restarts
- synology-csi/synology-csi-node-4nxcz: 4 restarts
- synology-csi/synology-csi-node-577mq: 10 restarts
- synology-csi/synology-csi-node-kxrjb: 14 restarts
- synology-csi/synology-csi-node-l72f8: 6 restarts
- synology-csi/synology-csi-node-ptwb8: 6 restarts
- synology-csi/synology-csi-node-sfdmg: 4 restarts
- synology-csi/synology-csi-node-zch7n: 18 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE     LAST SEEN   TYPE      REASON                 OBJECT                                                    MESSAGE
velero        148m        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786494736366   Job has reached the specified backoff limit
velero        143m        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786495036453   Job has reached the specified backoff limit
velero        138m        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786495358733   Job has reached the specified backoff limit
velero        133m        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786495636432   Job has reached the specified backoff limit
velero        128m        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786495936304   Job has reached the specified backoff limit
velero        123m        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786496236306   Job has reached the specified backoff limit
velero        118m        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786496536307   Job has reached the specified backoff limit
velero        113m        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786496836338   Job has reached the specified backoff limit
velero        108m        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786497136495   Job has reached the specified backoff limit
velero        103m        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786497436309   Job has reached the specified backoff limit
velero        98m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786497741404   Job has reached the specified backoff limit
velero        93m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786498036311   Job has reached the specified backoff limit
kube-system   90m         Warning   Unhealthy              pod/kube-apiserver-nlk8s-ctrl03                     Readiness probe failed: HTTP probe failed with statuscode: 500
velero        88m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786498336448   Job has reached the specified backoff limit
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
nlk8s-ctrl01   1252m        31%      3116Mi          39%         
nlk8s-ctrl02   1416m        35%      3442Mi          42%         
nlk8s-ctrl03   315m         7%       3835Mi          49%         
nlk8s-node01    458m         5%       6476Mi          82%         
nlk8s-node02    425m         5%       5237Mi          66%         
nlk8s-node03    423m         5%       4591Mi          58%         
nlk8s-node04    384m         4%       3938Mi          50%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              kube-apiserver-nlk8s-ctrl02                                 504m         1617Mi          
kube-system              tetragon-mdsn9                                                    284m         655Mi           
kube-system              etcd-nlk8s-ctrl02                                           230m         133Mi           
kube-system              kube-apiserver-nlk8s-ctrl01                                 164m         1302Mi          
kube-system              cilium-64v2f                                                      156m         199Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-0                132m         1575Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                130m         1634Mi          
logging                  promtail-m2gzm                                                    120m         68Mi            
kube-system              kube-apiserver-nlk8s-ctrl03                                 100m         1436Mi          
kube-system              cilium-5v9vw                                                      97m          295Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-1                130m         1634Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 504m         1617Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                132m         1575Mi          
seaweedfs                seaweedfs-volume-1                                                41m          1479Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 100m         1436Mi          
seaweedfs                seaweedfs-filer-1                                                 50m          1398Mi          
logging                  loki-0                                                            39m          1396Mi          
awx                      my-awx-web-55ccb47b58-m95v8                                       4m           1394Mi          
awx                      my-awx-task-756d768868-xs8gc                                      18m          1370Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 164m         1302Mi          
Metrics server not available
```

### Resource Requests/Limits Summary
```
monitoring: CPU=2160m Mem=10928Mi
kube-system: CPU=2060m Mem=472Mi
awx: CPU=1855m Mem=3552Mi
seaweedfs: CPU=1200m Mem=7424Mi
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
argocd            argocd-application-controller                     1               N/A               0                     257d
argocd            argocd-applicationset-controller                  1               N/A               0                     257d
argocd            argocd-redis                                      1               N/A               0                     257d
argocd            argocd-repo-server                                1               N/A               1                     257d
argocd            argocd-server                                     1               N/A               1                     257d
awx               awx-postgres-pdb                                  1               N/A               0                     257d
awx               awx-task-pdb                                      1               N/A               0                     257d
awx               awx-web-pdb                                       1               N/A               0                     257d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     257d
kube-system       coredns-pdb                                       1               N/A               1                     257d
kube-system       metrics-server-pdb                                1               N/A               0                     257d
monitoring        monitoring-grafana                                1               N/A               1                     122d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     122d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     122d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     257d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     143d
seaweedfs         seaweedfs-master                                  2               N/A               1                     143d
seaweedfs         seaweedfs-volume                                  1               N/A               1                     143d
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
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   279d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               248d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 256d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                254d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 256d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 256d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   259d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        258d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        255d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        149d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   238d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        243d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        242d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        247d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        258d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        242d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        243d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        260d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        244d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        244d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        259d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   237d
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   260d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   280d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   257d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   257d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   257d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   257d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   257d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   257d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   257d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   257d
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
daily-backup    Enabled   0 2 * * *   60m          259d   false
weekly-backup   Enabled   0 3 * * 0   3d           259d   false
```

### Recent Backups (last 5)
```
daily-backup-20260808020022    4d1h
daily-backup-20260809020024    3d1h
weekly-backup-20260809030024   3d
daily-backup-20260810020025    2d1h
daily-backup-20260811020026    25h
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
monitoring          	monitoring            	25      	2026-08-08 11:43:47.608387062 +0000 UTC	deployed	REDACTED_d8074874-79.12.0         	v0.86.2    
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
argocd                   Active   259d
awx                      Active   280d
bentopdf                 Active   255d
cert-manager             Active   254d
cilium-secrets           Active   256d
cilium-spire             Active   256d
default                  Active   281d
echo-server              Active   149d
external-secrets         Active   255d
gatus                    Active   238d
REDACTED_01b50c5d   Active   260d
ingress-nginx            Active   279d
kube-node-lease          Active   281d
kube-public              Active   281d
kube-system              Active   281d
REDACTED_d97cef76     Active   242d
logging                  Active   254d
monitoring               Active   280d
nfs-provisioner          Active   279d
opentofu-ns              Active   279d
pihole                   Active   260d
production               Active   260d
seaweedfs                Active   244d
synology-csi             Active   257d
velero                   Active   259d
well-known               Active   237d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           259d
argocd                   argocd-notifications-controller                   1/1     1            1           150d
argocd                   argocd-redis                                      1/1     1            1           259d
argocd                   argocd-repo-server                                2/2     2            2           259d
argocd                   argocd-server                                     2/2     2            2           259d
awx                      awx-operator-controller-manager                   1/1     1            1           280d
awx                      my-awx-task                                       1/1     1            1           280d
awx                      my-awx-web                                        1/1     1            1           280d
bentopdf                 bentopdf                                          1/1     1            1           255d
cert-manager             cert-manager                                      1/1     1            1           254d
cert-manager             cert-manager-cainjector                           1/1     1            1           254d
cert-manager             cert-manager-webhook                              1/1     1            1           254d
echo-server              echo-server                                       1/1     1            1           149d
external-secrets         external-secrets                                  1/1     1            1           255d
external-secrets         external-secrets-cert-controller                  1/1     1            1           255d
external-secrets         external-secrets-webhook                          1/1     1            1           255d
gatus                    gatus                                             1/1     1            1           238d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           260d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           279d
kube-system              cilium-operator                                   1/1     1            1           256d
kube-system              clustermesh-apiserver                             1/1     1            1           248d
kube-system              coredns                                           2/2     2            2           281d
kube-system              hubble-relay                                      1/1     1            1           256d
kube-system              hubble-ui                                         1/1     1            1           256d
kube-system              metrics-server                                    1/1     1            1           280d
kube-system              tetragon-operator                                 1/1     1            1           235d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           242d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           242d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           242d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           242d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           242d
monitoring               bgpalerter                                        1/1     1            1           240d
monitoring               monitoring-grafana                                2/2     2            2           122d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           122d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           122d
monitoring               snmp-exporter                                     1/1     1            1           242d
monitoring               thanos-query                                      2/2     2            2           243d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           279d
pihole                   pihole                                            1/1     1            1           255d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           243d
velero                   velero                                            1/1     1            1           259d
velero                   velero-ui                                         1/1     1            1           259d
well-known               well-known                                        1/1     1            1           237d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     259d
awx            my-awx-postgres-15                                     1/1     280d
cilium-spire   spire-server                                           1/1     256d
logging        loki                                                   1/1     235d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     122d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     122d
monitoring     thanos-compactor                                       1/1     243d
monitoring     thanos-store                                           2/2     243d
seaweedfs      seaweedfs-filer                                        2/2     244d
seaweedfs      seaweedfs-master                                       3/3     244d
seaweedfs      seaweedfs-volume                                       2/2     12d
synology-csi   synology-csi-controller                                1/1     257d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   256d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   256d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   256d
kube-system    tetragon                              7         7         7       7            7           <none>                   235d
logging        loki-canary                           4         4         4       4            4           <none>                   243d
logging        promtail                              7         7         7       7            7           <none>                   254d
monitoring     goldpinger                            7         7         7       7            7           <none>                   247d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   122d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   257d
velero         node-agent                            4         4         4       4            4           <none>                   14d
```

---

*Full cluster context dump - v3.1.0*
