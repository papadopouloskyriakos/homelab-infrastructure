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

**Generated:** 2026-09-08 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | CRITICAL | ⚠️ |
| Unhealthy Pods | 14 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 6164 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.36.3 |
| CNI | Cilium 1.20.0 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 174 |

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
- **Status:** Unknown
- **CPU:** 8 | **Memory:** 16246548Ki
- **Taints:** node.kubernetes.io/unreachable=:NoSchedule, node.cilium.io/agent-not-ready=:NoSchedule, node.kubernetes.io/unreachable=:NoExecute
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
awx                      awx-operator-controller-manager-6ffdf98f6-m9gvc                   2/2   Terminating        2 (13d ago)        14d
cnpg-system              cnpg-cloudnative-pg-6d8bdc546d-xtt94                              1/1   Terminating        1 (13d ago)        14d
kube-system              kube-proxy-qn8md                                                  0/1   CrashLoopBackOff   4102 (4m46s ago)   22d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be-75b84759cfskglb   1/1   Terminating        2 (13d ago)        14d
velero                   awx-default-kopia-maintain-job-1788835596318-6z2jd                0/1   Error              0                  14m
velero                   awx-default-kopia-maintain-job-1788835900343-2t44b                0/1   Error              0                  9m6s
velero                   awx-default-kopia-maintain-job-1788836197306-trt8n                0/1   Error              0                  4m9s
velero                   monitoring-default-kopia-maintain-job-1788835600346-vf8bn         0/1   Error              0                  14m
velero                   monitoring-default-kopia-maintain-job-1788835892278-njhng         0/1   Error              0                  9m14s
velero                   monitoring-default-kopia-maintain-job-1788836202341-gxcm2         0/1   Error              0                  4m4s
velero                   node-agent-55hgg                                                  1/1   Terminating        1 (14d ago)        14d
velero                   pihole-default-kopia-maintain-job-1788835592277-4rgrq             0/1   Error              0                  14m
velero                   pihole-default-kopia-maintain-job-1788835896306-gfrfr             0/1   Error              0                  9m10s
velero                   pihole-default-kopia-maintain-job-1788836192279-nbsfz             0/1   Error              0                  4m14s
```

#### Unhealthy Pod Details

**awx/awx-operator-controller-manager-6ffdf98f6-m9gvc:**
```
Events:                      <none>
```

**cnpg-system/cnpg-cloudnative-pg-6d8bdc546d-xtt94:**
```
Events:                      <none>
```

**kube-system/kube-proxy-qn8md:**
```
Events:
  Type     Reason   Age                     From     Message
  ----     ------   ----                    ----     -------
  Normal   Created  56m (x4092 over 14d)    kubelet  spec.containers{kube-proxy}: Container created
  Normal   Pulled   4m47s (x4102 over 14d)  kubelet  spec.containers{kube-proxy}: Container image "registry.k8s.io/kube-proxy:v1.36.3" already present on machine and can be accessed by the pod
  Warning  BackOff  24s (x18309 over 14d)   kubelet  spec.containers{kube-proxy}: Back-off restarting failed container kube-proxy in pod kube-proxy-qn8md_kube-system(70ae08f5-7949-459c-9670-ac69c6b03a55)
```

**nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-75b84759cfskglb:**
```
Events:                      <none>
```

**velero/awx-default-kopia-maintain-job-1788835596318-6z2jd:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  14m   default-scheduler  Successfully assigned velero/awx-default-kopia-maintain-job-1788835596318-6z2jd to nlk8s-node04
  Normal  Pulled     14m   kubelet            spec.containers{velero-repo-maintenance-container}: Container image "velero/velero:v1.17.1" already present on machine and can be accessed by the pod
  Normal  Created    14m   kubelet            spec.containers{velero-repo-maintenance-container}: Container created
  Normal  Started    14m   kubelet            spec.containers{velero-repo-maintenance-container}: Container started
```

### High Restart Pods (>3 restarts)
- awx/my-awx-task-756d768868-bslc2: 6 restarts
- cilium-spire/spire-agent-2xj9z: 258 restarts
- cilium-spire/spire-agent-bf7g7: 261 restarts
- cilium-spire/spire-agent-hpld8: 259 restarts
- cilium-spire/spire-agent-sm9xs: 259 restarts
- cilium-spire/spire-agent-xk8cl: 258 restarts
- cilium-spire/spire-agent-zqpt4: 261 restarts
- kube-system/cilium-operator-84c4fb58c7-jlhkp: 4 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 9 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 6 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 4 restarts
- kube-system/kube-proxy-qn8md: 4102 restarts
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
velero        94m         Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1788830792266       Job has reached the specified backoff limit
velero        94m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1788830796285          Job has reached the specified backoff limit
velero        94m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1788830801310   Job has reached the specified backoff limit
velero        89m         Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1788831092267       Job has reached the specified backoff limit
velero        89m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1788831096291          Job has reached the specified backoff limit
velero        89m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1788831100313   Job has reached the specified backoff limit
velero        84m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1788831392268   Job has reached the specified backoff limit
velero        84m         Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1788831397440       Job has reached the specified backoff limit
velero        84m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1788831401472          Job has reached the specified backoff limit
velero        79m         Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1788831692268       Job has reached the specified backoff limit
velero        79m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1788831696289          Job has reached the specified backoff limit
velero        79m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1788831700312   Job has reached the specified backoff limit
velero        74m         Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1788831992269       Job has reached the specified backoff limit
velero        74m         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1788831996289          Job has reached the specified backoff limit
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
NAME                 CPU(cores)   CPU(%)      MEMORY(bytes)   MEMORY(%)   
nlk8s-ctrl01   1683m        42%         2786Mi          35%         
nlk8s-ctrl02   575m         14%         3693Mi          45%         
nlk8s-ctrl03   432m         10%         3159Mi          40%         
nlk8s-node02    767m         9%          6588Mi          67%         
nlk8s-node03    1820m        22%         7697Mi          78%         
nlk8s-node04    792m         9%          7616Mi          64%         
nlk8s-node01    <unknown>    <unknown>   <unknown>       <unknown>   
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                820m         3525Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                544m         3448Mi          
kube-system              cilium-7rvww                                                      290m         340Mi           
seaweedfs                seaweedfs-volume-1                                                273m         257Mi           
kube-system              tetragon-mdsn9                                                    246m         559Mi           
logging                  loki-0                                                            223m         1381Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 217m         1529Mi          
logging                  promtail-hp5sc                                                    181m         126Mi           
seaweedfs                seaweedfs-filer-meta-2                                            123m         277Mi           
kube-system              etcd-nlk8s-ctrl03                                           118m         127Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                820m         3525Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                544m         3448Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 96m          1727Mi          
awx                      my-awx-task-756d768868-bslc2                                      19m          1535Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 217m         1529Mi          
awx                      my-awx-web-f9c4bb98d-wcn4j                                        6m           1383Mi          
logging                  loki-0                                                            223m         1381Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 76m          1231Mi          
monitoring               monitoring-grafana-7d6c5795b8-6cvtn                               12m          683Mi           
monitoring               monitoring-grafana-7d6c5795b8-6rh4q                               12m          680Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
kube-system: CPU=2260m Mem=672Mi
monitoring: CPU=2160m Mem=10928Mi
awx: CPU=1910m Mem=3648Mi
seaweedfs: CPU=1450m Mem=8128Mi
ingress-nginx: CPU=1000m Mem=1024Mi
logging: CPU=850m Mem=2944Mi
argocd: CPU=750m Mem=1664Mi
velero: CPU=550m Mem=832Mi
REDACTED_d97cef76: CPU=400m Mem=800Mi
cnpg-system: CPU=150m Mem=384Mi
```

---

## Network & Security

### PodDisruptionBudgets
```
NAMESPACE         NAME                                              MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
argocd            argocd-application-controller                     1               N/A               0                     284d
argocd            argocd-applicationset-controller                  1               N/A               0                     284d
argocd            argocd-redis                                      1               N/A               0                     284d
argocd            argocd-repo-server                                1               N/A               1                     284d
argocd            argocd-server                                     1               N/A               1                     284d
awx               awx-postgres-pdb                                  1               N/A               0                     284d
awx               awx-task-pdb                                      1               N/A               0                     284d
awx               awx-web-pdb                                       1               N/A               0                     284d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     284d
kube-system       coredns-pdb                                       1               N/A               1                     284d
kube-system       metrics-server-pdb                                1               N/A               0                     284d
monitoring        monitoring-grafana                                1               N/A               1                     149d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     149d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     149d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     284d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     170d
seaweedfs         seaweedfs-filer-meta-primary                      1               N/A               0                     15d
seaweedfs         seaweedfs-master                                  2               N/A               1                     170d
seaweedfs         seaweedfs-volume                                  1               N/A               1                     170d
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
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   306d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               275d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 283d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                281d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 283d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 283d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   286d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        285d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        282d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        176d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   265d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        270d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        269d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        274d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        285d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        269d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        270d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        287d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        271d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        271d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        286d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   264d
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   287d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   307d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   284d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   284d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   284d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   284d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   284d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   284d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   284d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   284d
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
daily-backup    Enabled   0 2 * * *   60m          286d   false
weekly-backup   Enabled   0 3 * * 0   2d           286d   false
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
ingress-nginx       	ingress-nginx         	15      	2026-09-08 00:40:21.227304525 +0000 UTC	deployed	ingress-nginx-4.15.1                  	1.15.1     
k8s-agent           	REDACTED_01b50c5d	8       	2026-08-16 19:44:19.392287363 +0000 UTC	deployed	gitlab-agent-2.28.0                   	v19.1.0    
REDACTED_d97cef76	REDACTED_d97cef76  	2       	2026-02-25 19:02:27.096604857 +0000 UTC	deployed	REDACTED_d97cef76-7.14.0           	           
loki                	logging               	12      	2026-07-07 13:12:39.944244427 +0000 UTC	deployed	loki-6.55.0                           	3.6.7      
monitoring          	monitoring            	35      	2026-08-25 22:59:17.970226763 +0000 UTC	deployed	REDACTED_d8074874-79.12.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	9       	2026-08-16 19:44:19.484898096 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail            	logging               	8       	2026-03-14 22:22:09.209112925 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
seaweedfs           	seaweedfs             	18      	2026-08-26 15:19:20.669096641 +0000 UTC	deployed	seaweedfs-4.44.0                      	4.44       
synology-csi        	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
tetragon            	kube-system           	7       	2025-12-20 22:35:40.030282504 +0000 UTC	deployed	tetragon-1.6.0                        	1.6.0      
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   286d
awx                      Active   307d
bentopdf                 Active   282d
cert-manager             Active   281d
cilium-secrets           Active   283d
cilium-spire             Active   283d
cnpg-system              Active   15d
default                  Active   308d
echo-server              Active   176d
external-secrets         Active   282d
gatus                    Active   265d
REDACTED_01b50c5d   Active   287d
ingress-nginx            Active   306d
kube-node-lease          Active   308d
kube-public              Active   308d
kube-system              Active   308d
REDACTED_d97cef76     Active   269d
logging                  Active   281d
monitoring               Active   307d
nfs-provisioner          Active   306d
opentofu-ns              Active   306d
pihole                   Active   287d
production               Active   287d
seaweedfs                Active   271d
synology-csi             Active   284d
velero                   Active   286d
well-known               Active   264d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           286d
argocd                   argocd-notifications-controller                   1/1     1            1           177d
argocd                   argocd-redis                                      1/1     1            1           286d
argocd                   argocd-repo-server                                2/2     2            2           286d
argocd                   argocd-server                                     2/2     2            2           286d
awx                      awx-operator-controller-manager                   1/1     1            1           307d
awx                      my-awx-task                                       1/1     1            1           307d
awx                      my-awx-web                                        1/1     1            1           307d
bentopdf                 bentopdf                                          1/1     1            1           282d
cert-manager             cert-manager                                      1/1     1            1           281d
cert-manager             cert-manager-cainjector                           1/1     1            1           281d
cert-manager             cert-manager-webhook                              1/1     1            1           281d
cnpg-system              cnpg-cloudnative-pg                               2/2     2            2           15d
echo-server              echo-server                                       1/1     1            1           176d
external-secrets         external-secrets                                  1/1     1            1           282d
external-secrets         external-secrets-cert-controller                  1/1     1            1           282d
external-secrets         external-secrets-webhook                          1/1     1            1           282d
gatus                    gatus                                             1/1     1            1           265d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           287d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           306d
kube-system              cilium-operator                                   1/1     1            1           283d
kube-system              clustermesh-apiserver                             1/1     1            1           275d
kube-system              coredns                                           2/2     2            2           308d
kube-system              hubble-relay                                      1/1     1            1           283d
kube-system              hubble-ui                                         1/1     1            1           283d
kube-system              metrics-server                                    1/1     1            1           307d
kube-system              tetragon-operator                                 1/1     1            1           262d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           269d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           269d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           269d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           269d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           269d
monitoring               bgpalerter                                        1/1     1            1           267d
monitoring               monitoring-grafana                                2/2     2            2           149d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           149d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           149d
monitoring               snmp-exporter                                     1/1     1            1           269d
monitoring               thanos-query                                      2/2     2            2           270d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           306d
pihole                   pihole                                            1/1     1            1           282d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           270d
velero                   velero                                            1/1     1            1           286d
velero                   velero-ui                                         1/1     1            1           286d
well-known               well-known                                        1/1     1            1           264d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     286d
awx            my-awx-postgres-15                                     1/1     307d
cilium-spire   spire-server                                           1/1     283d
logging        loki                                                   1/1     262d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     149d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     149d
monitoring     thanos-compactor                                       1/1     270d
monitoring     thanos-store                                           2/2     270d
seaweedfs      seaweedfs-filer                                        2/2     271d
seaweedfs      seaweedfs-master                                       3/3     271d
seaweedfs      seaweedfs-volume                                       2/2     39d
synology-csi   synology-csi-controller                                1/1     284d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           6         6         6       6            6           <none>                   283d
kube-system    cilium                                7         7         6       7            6           kubernetes.io/os=linux   283d
kube-system    cilium-envoy                          7         7         6       7            6           kubernetes.io/os=linux   283d
kube-system    kube-proxy                            7         7         5       7            5           kubernetes.io/os=linux   22d
kube-system    tetragon                              6         6         6       6            6           <none>                   262d
logging        loki-canary                           3         3         3       3            3           <none>                   270d
logging        promtail                              6         6         6       6            6           <none>                   281d
monitoring     goldpinger                            6         6         6       6            6           <none>                   274d
monitoring     monitoring-prometheus-node-exporter   6         6         6       6            6           kubernetes.io/os=linux   149d
synology-csi   synology-csi-node                     7         7         6       7            6           <none>                   284d
velero         node-agent                            3         3         3       2            3           <none>                   41d
```

---

*Full cluster context dump - v3.1.0*
