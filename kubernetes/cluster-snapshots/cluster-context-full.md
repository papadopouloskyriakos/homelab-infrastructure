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

**Generated:** 2026-08-24 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | CRITICAL | ⚠️ |
| Unhealthy Pods | 35 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 700 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.36.3 |
| CNI | Cilium 1.20.0 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 192 |

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
default                  fence-probe                                                       0/1   Error              0                 4h47m
logging                  loki-0                                                            1/2   CrashLoopBackOff   22 (101s ago)     7d10h
monitoring               bgpalerter-789f984488-b2fpj                                       0/1   Pending            0                 3h37m
monitoring               prometheus-REDACTED_6dfbe9fc-0                2/3   CrashLoopBackOff   92 (2m53s ago)    6d4h
monitoring               thanos-compactor-0                                                0/1   CrashLoopBackOff   38 (2m59s ago)    3d17h
seaweedfs                seaweedfs-read-canary-29792183-4ccsh                              0/1   Error              0                 157m
seaweedfs                seaweedfs-read-canary-29792183-6vxxw                              0/1   Error              0                 157m
velero                   argocd-default-kopia-maintain-job-1787514854153-66z9r             0/1   Error              0                 7h6m
velero                   argocd-default-kopia-maintain-job-1787515627611-gfzr9             0/1   Error              0                 6h53m
velero                   argocd-default-kopia-maintain-job-1787516396098-kfvr6             0/1   Error              0                 6h41m
velero                   awx-default-kopia-maintain-job-1787537477433-rv7vs                0/1   Error              0                 49m
velero                   awx-default-kopia-maintain-job-1787537785465-d5sjn                0/1   Error              0                 44m
velero                   awx-default-kopia-maintain-job-1787538077435-qxh8v                0/1   Error              0                 39m
velero                   cilium-spire-default-kopia-maintain-job-1787515004231-l44tg       0/1   Error              0                 7h4m
velero                   cilium-spire-default-kopia-maintain-job-1787515777659-xwvst       0/1   Error              0                 6h51m
velero                   cilium-spire-default-kopia-maintain-job-1787516547163-8fwlz       0/1   Error              0                 6h38m
velero                   gatus-default-kopia-maintain-job-1787514699898-pglfv              0/1   Error              0                 7h9m
velero                   gatus-default-kopia-maintain-job-1787515473456-vw8hr              0/1   Error              0                 6h56m
velero                   gatus-default-kopia-maintain-job-1787516238890-tsm8n              0/1   Error              0                 6h43m
velero                   REDACTED_d97cef76-default-kopia-maintain-job-17875147046nf6r   0/1   Error              0                 7h9m
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787515478zh6jd   0/1   Error              0                 6h56m
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787516245rj97k   0/1   Error              0                 6h43m
velero                   logging-default-kopia-maintain-job-1787515010277-kjjpk            0/1   Error              0                 7h4m
velero                   logging-default-kopia-maintain-job-1787515787734-nncqk            0/1   Error              0                 6h51m
velero                   logging-default-kopia-maintain-job-1787516552197-fbjtl            0/1   Error              0                 6h38m
velero                   monitoring-default-kopia-maintain-job-1787537485542-pftlg         0/1   Error              0                 49m
velero                   monitoring-default-kopia-maintain-job-1787537795509-cr2zg         0/1   Error              0                 44m
velero                   monitoring-default-kopia-maintain-job-1787539075485-nr7nj         0/1   Error              0                 23m
velero                   pihole-default-kopia-maintain-job-1787537205849-vzxbx             0/1   Error              0                 54m
velero                   pihole-default-kopia-maintain-job-1787537494574-v6pq7             0/1   Error              0                 49m
velero                   pihole-default-kopia-maintain-job-1787537777435-5x6kn             0/1   Error              0                 44m
velero                   well-known-default-kopia-maintain-job-1787514401817-t764g         0/1   Error              0                 7h14m
velero                   well-known-default-kopia-maintain-job-1787515168357-6hg2p         0/1   Error              0                 7h1m
velero                   well-known-default-kopia-maintain-job-1787515941813-z8k5h         0/1   Error              0                 6h48m
velero                   well-known-default-kopia-maintain-job-1787516706278-fndcj         0/1   Error              0                 6h35m
```

#### Unhealthy Pod Details

**default/fence-probe:**
```
Events:                      <none>
```

**logging/loki-0:**
```
Events:
  Type     Reason     Age                    From     Message
  ----     ------     ----                   ----     -------
  Warning  Unhealthy  81m (x73 over 5d)      kubelet  spec.containers{loki}: Readiness probe failed: Get "http://10.0.2.102:3100/ready": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
  Normal   Created    53m (x11 over 7d10h)   kubelet  spec.containers{loki}: Container created
  Normal   Started    53m (x11 over 7d10h)   kubelet  spec.containers{loki}: Container started
  Normal   Pulled     102s (x21 over 7d10h)  kubelet  spec.containers{loki}: Container image "docker.io/grafana/loki:3.6.7" already present on machine and can be accessed by the pod
  Warning  BackOff    100s (x77 over 79m)    kubelet  spec.containers{loki}: Back-off restarting failed container loki in pod loki-0_logging(86a641f5-9caf-42e8-b4a3-0c78239b8296)
```

**monitoring/bgpalerter-789f984488-b2fpj:**
```
Events:
  Type     Reason            Age                  From               Message
  ----     ------            ----                 ----               -------
  Warning  FailedScheduling  34m (x48 over 178m)  default-scheduler  0/7 nodes are available: 3 node(s) had untolerated taint(s), 4 Insufficient memory. no new claims to deallocate, preemption: 0/7 nodes are available: 3 Preemption is not helpful for scheduling, 4 No preemption victims found for incoming pod.
```

**monitoring/prometheus-REDACTED_6dfbe9fc-0:**
```
Events:
  Type     Reason   Age                      From     Message
  ----     ------   ----                     ----     -------
  Normal   Created  126m (x22 over 5h40m)    kubelet  spec.containers{prometheus}: Container created
  Warning  BackOff  4m17s (x246 over 3h21m)  kubelet  spec.containers{prometheus}: Back-off restarting failed container prometheus in pod prometheus-REDACTED_6dfbe9fc-0_monitoring(4e11d479-c4da-4d23-b55b-6156d31191c9)
  Normal   Pulled   2m53s (x46 over 5h40m)   kubelet  spec.containers{prometheus}: Container image "quay.io/prometheus/prometheus:v3.8.0" already present on machine and can be accessed by the pod
```

**monitoring/thanos-compactor-0:**
```
Events:
  Type     Reason   Age                     From     Message
  ----     ------   ----                    ----     -------
  Normal   Created  54m (x29 over 3d17h)    kubelet  spec.containers{thanos-compactor}: Container created
  Warning  BackOff  4m31s (x206 over 174m)  kubelet  spec.containers{thanos-compactor}: Back-off restarting failed container thanos-compactor in pod thanos-compactor-0_monitoring(a9d9acff-f6d2-40da-8b5c-0b6136d55a8a)
  Normal   Pulled   2m59s (x39 over 3d17h)  kubelet  spec.containers{thanos-compactor}: Container image "quay.io/thanos/thanos:v0.42.4" already present on machine and can be accessed by the pod
```

### High Restart Pods (>3 restarts)
- ingress-nginx/ingress-nginx-controller-8445475547-6zqqc: 47 restarts
- ingress-nginx/ingress-nginx-controller-8445475547-kr7kz: 43 restarts
- kube-system/clustermesh-apiserver-6c8cd7bb6f-ctst4: 101 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 4 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 4 restarts
- kube-system/tetragon-5gk99: 7 restarts
- kube-system/tetragon-75hdg: 8 restarts
- kube-system/tetragon-878gv: 8 restarts
- kube-system/tetragon-jz2b6: 6 restarts
- kube-system/tetragon-mdsn9: 23 restarts
- kube-system/tetragon-tbcc7: 8 restarts
- kube-system/tetragon-vbs6v: 16 restarts
- logging/loki-0: 22 restarts
- logging/promtail-5jr9j: 5 restarts
- logging/promtail-hp5sc: 8 restarts
- logging/promtail-ng69s: 5 restarts
- monitoring/monitoring-grafana-7d6c5795b8-9tq4w: 25 restarts
- monitoring/monitoring-kube-prometheus-operator-67d8d4c647-vwbbr: 20 restarts
- monitoring/monitoring-kube-state-metrics-75f9fff55b-4vfg6: 44 restarts
- monitoring/monitoring-prometheus-node-exporter-6dl8r: 175 restarts
- monitoring/monitoring-prometheus-node-exporter-6sc8j: 9 restarts
- monitoring/monitoring-prometheus-node-exporter-vgp6b: 4 restarts
- monitoring/monitoring-prometheus-node-exporter-wmcb8: 46 restarts
- monitoring/prometheus-REDACTED_6dfbe9fc-0: 92 restarts
- monitoring/prometheus-REDACTED_6dfbe9fc-1: 21 restarts
- monitoring/thanos-compactor-0: 38 restarts
- seaweedfs/seaweedfs-filer-0: 8 restarts
- seaweedfs/seaweedfs-filer-1: 8 restarts
- synology-csi/synology-csi-node-4nxcz: 6 restarts
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
NAMESPACE       LAST SEEN   TYPE      REASON                 OBJECT                                                    MESSAGE
monitoring      34m         Warning   FailedScheduling       pod/bgpalerter-789f984488-b2fpj                           0/7 nodes are available: 3 node(s) had untolerated taint(s), 4 Insufficient memory. no new claims to deallocate, preemption: 0/7 nodes are available: 3 Preemption is not helpful for scheduling, 4 No preemption victims found for incoming pod.
velero          118m        Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1787532077599          Job has reached the specified backoff limit
logging         117m        Warning   Unhealthy              pod/promtail-m2gzm                                        Readiness probe failed: Get "http://10.0.5.169:3101/ready": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
monitoring      117m        Warning   Unhealthy              pod/goldpinger-rb96x                                      Liveness probe failed: Get "http://10.0.5.34:8080/healthz": dial tcp 10.0.5.34:8080: connect: connection refused
monitoring      117m        Warning   Unhealthy              pod/goldpinger-rb96x                                      Readiness probe failed: Get "http://10.0.5.34:8080/healthz": dial tcp 10.0.5.34:8080: connect: connection refused
argocd          114m        Warning   Unhealthy              pod/argocd-repo-server-7dfc645f84-v5pqx                   Liveness probe failed: Get "http://10.0.6.237:8084/healthz?full=true": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
seaweedfs       103m        Warning   Unhealthy              pod/seaweedfs-filer-meta-1                                Liveness probe failed: Get "https://10.0.2.127:8000/healthz": context deadline exceeded
seaweedfs       103m        Warning   Unhealthy              pod/seaweedfs-filer-meta-1                                Liveness probe failed: Get "https://10.0.2.127:8000/healthz": net/http: request canceled (Client.Timeout exceeded while awaiting headers)
monitoring      99m         Warning   Unhealthy              pod/prometheus-REDACTED_6dfbe9fc-1    Readiness probe failed: Get "http://10.0.2.253:9090/-/ready": dial tcp 10.0.2.253:9090: connect: connection refused
kube-system     91m         Warning   Unhealthy              pod/etcd-nlk8s-ctrl02                               Readiness probe failed: Get "http://127.0.0.1:2381/readyz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
seaweedfs       89m         Warning   Unhealthy              pod/seaweedfs-filer-0                                     Liveness probe failed: Get "http://10.0.3.32:8888/": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
monitoring      87m         Warning   Unhealthy              pod/monitoring-prometheus-node-exporter-88hp8             Readiness probe failed: Get "http://10.0.X.X:9100/": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
monitoring      87m         Warning   Unhealthy              pod/goldpinger-rb96x                                      Liveness probe failed: Get "http://10.0.5.34:8080/healthz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
monitoring      87m         Warning   Unhealthy              pod/goldpinger-rb96x                                      Readiness probe failed: Get "http://10.0.5.34:8080/healthz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
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

- **StatefulSet: loki** (/1)

**Storage:**
- PVC: storage-loki-0 (100Gi, Bound, sc:REDACTED_4f3da73d)

**Secrets:**
- ExternalSecret: loki-s3-credentials (SecretSynced)

### Namespace: `monitoring`

0/- **Deployment: bgpalerter** (1) → Svc:bgpalerter (ClusterIP) → Ingress:goldpinger.example.net
2/- **Deployment: monitoring-grafana** (2) → Ingress:goldpinger.example.net
1/- **Deployment: monitoring-kube-prometheus-operator** (1) → Ingress:goldpinger.example.net
1/- **Deployment: monitoring-kube-state-metrics** (1) → Ingress:goldpinger.example.net
1/- **Deployment: snmp-exporter** (1) → Svc:snmp-exporter (ClusterIP) → Ingress:goldpinger.example.net
2/- **Deployment: thanos-query** (2) → Ingress:goldpinger.example.net
- **StatefulSet: alertmanager-monitoring-kube-prometheus-alertmanager** (2/2)
- **StatefulSet: prometheus-REDACTED_6dfbe9fc** (1/2)
- **StatefulSet: thanos-compactor** (/1)
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
nlk8s-ctrl01   677m         16%      3034Mi          38%         
nlk8s-ctrl02   962m         24%      2675Mi          33%         
nlk8s-ctrl03   390m         9%       3571Mi          45%         
nlk8s-node01    179m         2%       4905Mi          62%         
nlk8s-node02    395m         4%       4724Mi          60%         
nlk8s-node03    333m         4%       3725Mi          47%         
nlk8s-node04    471m         5%       4410Mi          56%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              kube-apiserver-nlk8s-ctrl02                                 340m         1092Mi          
kube-system              etcd-nlk8s-ctrl02                                           183m         178Mi           
kube-system              tetragon-mdsn9                                                    135m         190Mi           
kube-system              etcd-nlk8s-ctrl03                                           129m         184Mi           
kube-system              kube-apiserver-nlk8s-ctrl03                                 126m         1662Mi          
kube-system              cilium-g5h5t                                                      125m         187Mi           
seaweedfs                seaweedfs-filer-sync-58946967c9-4lklt                             76m          200Mi           
kube-system              cilium-7rvww                                                      70m          247Mi           
kube-system              cilium-jfgsw                                                      69m          252Mi           
kube-system              kube-apiserver-nlk8s-ctrl01                                 68m          1448Mi          
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-1                43m          2720Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 126m         1662Mi          
awx                      my-awx-task-756d768868-bslc2                                      31m          1459Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 68m          1448Mi          
awx                      my-awx-web-f9c4bb98d-4v8mp                                        6m           1406Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 340m         1092Mi          
monitoring               monitoring-grafana-7d6c5795b8-bsvkj                               15m          886Mi           
monitoring               monitoring-grafana-7d6c5795b8-9tq4w                               10m          688Mi           
seaweedfs                seaweedfs-filer-0                                                 50m          523Mi           
argocd                   argocd-application-controller-0                                   20m          489Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
kube-system: CPU=2260m Mem=672Mi
monitoring: CPU=2160m Mem=10928Mi
awx: CPU=1855m Mem=3552Mi
seaweedfs: CPU=1450m Mem=8128Mi
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
argocd            argocd-application-controller                     1               N/A               0                     269d
argocd            argocd-applicationset-controller                  1               N/A               0                     269d
argocd            argocd-redis                                      1               N/A               0                     269d
argocd            argocd-repo-server                                1               N/A               1                     269d
argocd            argocd-server                                     1               N/A               1                     269d
awx               awx-postgres-pdb                                  1               N/A               0                     269d
awx               awx-task-pdb                                      1               N/A               0                     269d
awx               awx-web-pdb                                       1               N/A               0                     269d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     269d
kube-system       coredns-pdb                                       1               N/A               1                     269d
kube-system       metrics-server-pdb                                1               N/A               0                     269d
monitoring        monitoring-grafana                                1               N/A               1                     134d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     134d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     134d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     269d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     155d
seaweedfs         seaweedfs-filer-meta-primary                      1               N/A               0                     6h44m
seaweedfs         seaweedfs-master                                  2               N/A               1                     155d
seaweedfs         seaweedfs-volume                                  1               N/A               1                     155d
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
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   291d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               260d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 268d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                266d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 268d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 268d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   271d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        270d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        267d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        161d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   250d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        255d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        254d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        259d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        270d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        254d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        255d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        272d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        256d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        256d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        271d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   249d
```

---

## Storage

| Metric | Count |
|--------|-------|
| StorageClasses | 10 |
| PersistentVolumes | 24 |
| PersistentVolumeClaims | 23 |

### StorageClasses
```
NAME                                      PROVISIONER                                                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   272d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   292d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   269d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   269d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   269d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   269d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   269d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   269d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   269d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   269d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 4 |
| External Secrets | 20 |
| Certificates | 21 |
| ServiceMonitors | 31 |
| CiliumNetworkPolicies | 4 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE    PAUSED
daily-backup    Enabled   0 2 * * *   61m          271d   false
weekly-backup   Enabled   0 3 * * 0   24h          271d   false
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
monitoring          	monitoring            	31      	2026-08-23 20:16:45.769249202 +0000 UTC	deployed	REDACTED_d8074874-79.12.0         	v0.86.2    
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
argocd                   Active   271d
awx                      Active   292d
bentopdf                 Active   267d
cert-manager             Active   266d
cilium-secrets           Active   268d
cilium-spire             Active   268d
cnpg-system              Active   8h
default                  Active   293d
echo-server              Active   161d
external-secrets         Active   267d
gatus                    Active   250d
REDACTED_01b50c5d   Active   272d
ingress-nginx            Active   291d
kube-node-lease          Active   293d
kube-public              Active   293d
kube-system              Active   293d
REDACTED_d97cef76     Active   254d
logging                  Active   266d
monitoring               Active   292d
nfs-provisioner          Active   291d
opentofu-ns              Active   291d
pihole                   Active   272d
production               Active   272d
seaweedfs                Active   256d
synology-csi             Active   269d
velero                   Active   271d
well-known               Active   249d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           271d
argocd                   argocd-notifications-controller                   1/1     1            1           162d
argocd                   argocd-redis                                      1/1     1            1           271d
argocd                   argocd-repo-server                                2/2     2            2           271d
argocd                   argocd-server                                     2/2     2            2           271d
awx                      awx-operator-controller-manager                   1/1     1            1           292d
awx                      my-awx-task                                       1/1     1            1           292d
awx                      my-awx-web                                        1/1     1            1           292d
bentopdf                 bentopdf                                          1/1     1            1           267d
cert-manager             cert-manager                                      1/1     1            1           266d
cert-manager             cert-manager-cainjector                           1/1     1            1           266d
cert-manager             cert-manager-webhook                              1/1     1            1           266d
cnpg-system              cnpg-cloudnative-pg                               2/2     2            2           8h
echo-server              echo-server                                       1/1     1            1           161d
external-secrets         external-secrets                                  1/1     1            1           267d
external-secrets         external-secrets-cert-controller                  1/1     1            1           267d
external-secrets         external-secrets-webhook                          1/1     1            1           267d
gatus                    gatus                                             1/1     1            1           250d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           272d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           291d
kube-system              cilium-operator                                   1/1     1            1           268d
kube-system              clustermesh-apiserver                             1/1     1            1           260d
kube-system              coredns                                           2/2     2            2           293d
kube-system              hubble-relay                                      1/1     1            1           268d
kube-system              hubble-ui                                         1/1     1            1           268d
kube-system              metrics-server                                    1/1     1            1           292d
kube-system              tetragon-operator                                 1/1     1            1           247d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           254d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           254d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           254d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           254d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           254d
monitoring               bgpalerter                                        0/1     1            0           252d
monitoring               monitoring-grafana                                2/2     2            2           134d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           134d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           134d
monitoring               snmp-exporter                                     1/1     1            1           254d
monitoring               thanos-query                                      2/2     2            2           255d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           291d
pihole                   pihole                                            1/1     1            1           267d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           255d
velero                   velero                                            1/1     1            1           271d
velero                   velero-ui                                         1/1     1            1           271d
well-known               well-known                                        1/1     1            1           249d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     271d
awx            my-awx-postgres-15                                     1/1     292d
cilium-spire   spire-server                                           1/1     268d
logging        loki                                                   0/1     247d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     134d
monitoring     prometheus-REDACTED_6dfbe9fc       1/2     134d
monitoring     thanos-compactor                                       0/1     255d
monitoring     thanos-store                                           2/2     255d
seaweedfs      seaweedfs-filer                                        2/2     256d
seaweedfs      seaweedfs-master                                       3/3     256d
seaweedfs      seaweedfs-volume                                       2/2     24d
synology-csi   synology-csi-controller                                1/1     269d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   268d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   268d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   268d
kube-system    kube-proxy                            7         7         7       7            7           kubernetes.io/os=linux   7d11h
kube-system    tetragon                              7         7         7       7            7           <none>                   247d
logging        loki-canary                           4         4         4       4            4           <none>                   255d
logging        promtail                              7         7         7       7            7           <none>                   266d
monitoring     goldpinger                            7         7         7       7            7           <none>                   259d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   134d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   269d
velero         node-agent                            4         4         4       4            4           <none>                   26d
```

---

*Full cluster context dump - v3.1.0*
