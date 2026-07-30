# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-07-30 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: CRITICAL ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 42 |
| Pending PVCs | 0 |
| Total Restarts | 3230 |

## Topology

- **K8s:** v1.34.2 | **CNI:** Cilium 1.19.5
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 193

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:8005928Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8006944Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:8005712Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:8006756Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:8006732Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:8006740Ki | Taints:none

## Anomalies

### Unhealthy Pods
```
velero                   argocd-default-kopia-maintain-job-1785379356263-54qfg             0/1   Error       0                  18m
velero                   argocd-default-kopia-maintain-job-1785379647500-kpk2r             0/1   Error       0                  13m
velero                   argocd-default-kopia-maintain-job-1785380138142-d285g             0/1   Error       0                  5m13s
velero                   awx-default-kopia-maintain-job-1785379374367-drrlp                0/1   Error       0                  17m
velero                   awx-default-kopia-maintain-job-1785379672675-mv87n                0/1   Error       0                  12m
velero                   awx-default-kopia-maintain-job-1785380159225-6gtgr                0/1   Error       0                  4m52s
velero                   cilium-spire-default-kopia-maintain-job-1785379814546-ftzpz       0/1   Error       0                  10m
velero                   cilium-spire-default-kopia-maintain-job-1785380027586-j29ch       0/1   Error       0                  7m4s
velero                   cilium-spire-default-kopia-maintain-job-1785380287973-gf8hz       0/1   Error       0                  2m43s
velero                   gatus-default-kopia-maintain-job-1785379564956-lttm2              0/1   Error       0                  14m
velero                   gatus-default-kopia-maintain-job-1785380041763-k98kc              0/1   Error       0                  6m50s
velero                   gatus-default-kopia-maintain-job-1785380298089-m6wp7              0/1   Error       0                  2m33s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1785379701k2b57   0/1   Error       0                  12m
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1785379864wqw94   0/1   Error       0                  9m47s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1785380179hlnn7   0/1   Error       0                  4m32s
velero                   logging-default-kopia-maintain-job-1785379725858-7rwbc            0/1   Error       0                  12m
velero                   logging-default-kopia-maintain-job-1785379889029-zccz8            0/1   Error       0                  9m22s
velero                   logging-default-kopia-maintain-job-1785380198448-96vss            0/1   Error       0                  4m13s
velero                   monitoring-default-kopia-maintain-job-1785379747999-gd2tm         0/1   Error       0                  11m
velero                   monitoring-default-kopia-maintain-job-1785379913100-nt9db         0/1   Error       0                  8m58s
velero                   monitoring-default-kopia-maintain-job-1785380218511-wddwq         0/1   Error       0                  3m53s
velero                   nfs-provisioner-default-kopia-maintain-job-1785379577053-lqcxx    0/1   Error       0                  14m
velero                   nfs-provisioner-default-kopia-maintain-job-1785380054854-jsnj6    0/1   Error       0                  6m37s
velero                   nfs-provisioner-default-kopia-maintain-job-1785380308206-cbmr7    0/1   Error       0                  2m23s
velero                   pihole-default-kopia-maintain-job-1785379759136-mzqsj             0/1   Error       0                  11m
velero                   pihole-default-kopia-maintain-job-1785379941168-glrh6             0/1   Error       0                  8m30s
velero                   pihole-default-kopia-maintain-job-1785380229575-swdgp             0/1   Error       0                  3m42s
velero                   REDACTED_00313366-maintain-job-1785379768296-zwqzb          0/1   Error       0                  11m
velero                   REDACTED_00313366-maintain-job-1785379961254-xbtw5          0/1   Error       0                  8m10s
velero                   REDACTED_00313366-maintain-job-1785380239667-dxxfc          0/1   Error       0                  3m32s
velero                   synology-csi-default-kopia-maintain-job-1785379587164-pjpjj       0/1   Error       0                  14m
velero                   synology-csi-default-kopia-maintain-job-1785380076931-p6jjl       0/1   Error       0                  6m15s
velero                   synology-csi-default-kopia-maintain-job-1785380326288-xj87h       0/1   Error       0                  2m5s
velero                   velero-resttest-default-kopia-maintain-job-1785379789440-76b57    0/1   Error       0                  11m
velero                   velero-resttest-default-kopia-maintain-job-1785379991369-kkqd4    0/1   Error       0                  7m40s
velero                   velero-resttest-default-kopia-maintain-job-1785380259796-th4dx    0/1   Error       0                  3m12s
velero                   velero-rt-default-kopia-maintain-job-1785379797408-q7vbb          0/1   Error       0                  10m
velero                   velero-rt-default-kopia-maintain-job-1785380007518-bqmp6          0/1   Error       0                  7m24s
velero                   velero-rt-default-kopia-maintain-job-1785380266878-fd7m6          0/1   Error       0                  3m5s
velero                   well-known-default-kopia-maintain-job-1785379621373-4qnss         0/1   Error       0                  13m
velero                   well-known-default-kopia-maintain-job-1785380104068-hvpfw         0/1   Error       0                  5m47s
velero                   well-known-default-kopia-maintain-job-1785380359382-v4q2f         0/1   Error       0                  92s
```

### High Restart Pods (>3)
argocd/argocd-repo-server-7dfc645f84-qxz64: 5 restarts
argocd/argocd-server-64dd47d8bf-fkr26: 35 restarts
awx/awx-operator-controller-manager-6ffdf98f6-hwvqf: 19 restarts
cilium-spire/spire-agent-49g4h: 28 restarts
cilium-spire/spire-agent-mdslp: 8 restarts
cilium-spire/spire-server-0: 17 restarts
REDACTED_01b50c5d/REDACTED_ab04b573-v2-8c85f5d4b-ng8lb: 24 restarts
ingress-nginx/ingress-nginx-controller-8445475547-mxdrc: 16 restarts
kube-system/cilium-operator-6cdbfb68d7-z6v2x: 5 restarts
kube-system/clustermesh-apiserver-6c96779765-rmrzt: 41 restarts
kube-system/etcd-nlk8s-ctrl01: 64 restarts
kube-system/hubble-ui-6bb97d8894-nnkx5: 21 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 1996 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 58 restarts
kube-system/kube-apiserver-nlk8s-ctrl03: 14 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 108 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 37 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 92 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 37 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 34 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 38 restarts
kube-system/tetragon-75hdg: 6 restarts
kube-system/tetragon-878gv: 4 restarts
kube-system/tetragon-mdsn9: 18 restarts
kube-system/tetragon-tbcc7: 4 restarts
kube-system/tetragon-vbs6v: 14 restarts
REDACTED_d97cef76/REDACTED_d97cef76-kong-5c7f96dd9b-fgxd9: 14 restarts
logging/promtail-hp5sc: 7 restarts
logging/promtail-ng69s: 4 restarts
monitoring/goldpinger-25hf5: 44 restarts
monitoring/goldpinger-6dj9l: 25 restarts
monitoring/goldpinger-n2fzm: 8 restarts
monitoring/goldpinger-zxtb9: 6 restarts
monitoring/monitoring-kube-prometheus-operator-67d8d4c647-5955s: 38 restarts
monitoring/monitoring-kube-state-metrics-75f9fff55b-6cc8x: 7 restarts
monitoring/monitoring-prometheus-node-exporter-6dl8r: 174 restarts
monitoring/monitoring-prometheus-node-exporter-6sc8j: 7 restarts
monitoring/monitoring-prometheus-node-exporter-wmcb8: 42 restarts
monitoring/prometheus-REDACTED_6dfbe9fc-0: 14 restarts
nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956jjmld: 49 restarts
seaweedfs/seaweedfs-filer-0: 31 restarts
seaweedfs/seaweedfs-filer-1: 42 restarts
synology-csi/synology-csi-node-577mq: 10 restarts
synology-csi/synology-csi-node-kxrjb: 14 restarts
synology-csi/synology-csi-node-l72f8: 4 restarts
synology-csi/synology-csi-node-ptwb8: 4 restarts
synology-csi/synology-csi-node-zch7n: 18 restarts

### Recent Warnings (5)
```
velero                   2m25s       Warning   BackoffLimitExceeded   job/gatus-default-kopia-maintain-job-1785380298089                  Job has reached the specified backoff limit
velero                   2m7s        Warning   BackoffLimitExceeded   job/nfs-provisioner-default-kopia-maintain-job-1785380308206        Job has reached the specified backoff limit
velero                   94s         Warning   BackoffLimitExceeded   job/synology-csi-default-kopia-maintain-job-1785380326288           Job has reached the specified backoff limit
velero                   64s         Warning   BackoffLimitExceeded   job/well-known-default-kopia-maintain-job-1785380359382             Job has reached the specified backoff limit
monitoring               16s         Warning   Unhealthy              pod/prometheus-REDACTED_6dfbe9fc-0              Readiness probe failed: Get "http://10.0.3.203:9090/-/ready": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
```

## Key Resources

### LoadBalancer Services
```
ingress-nginx/ingress-nginx-controller: 10.0.X.X -> 80:31689/TCP,443:30327/TCP
kube-system/clustermesh-apiserver: 10.0.X.X -> 2379:30462/TCP
kube-system/hubble-relay-lb: 10.0.X.X -> 80:30629/TCP
logging/promtail-syslog: 10.0.X.X -> 514:30623/TCP
pihole/pihole-dns-lb: 10.0.X.X -> 53:31803/UDP
pihole/pihole-dns-tcp-lb: 10.0.X.X -> 53:30438/TCP
```

### Ingresses
- argocd.example.net → argocd/argocd-server
- awx.example.net → awx/awx
- bentopdf.example.net → bentopdf/bentopdf
- echo.example.net → echo-server/echo-server
- nl-gatus.example.net → gatus/gatus
- nl-hubble.example.net → kube-system/hubble-ui
- nl-k8s.example.net → REDACTED_d97cef76/REDACTED_d97cef76
- goldpinger.example.net → monitoring/goldpinger
- grafana.example.net → monitoring/grafana
- nl-prometheus.example.net → monitoring/prometheus
- nl-thanos.example.net → monitoring/thanos-query
- pihole.example.net → pihole/pihole-ingress
- nl-seaweedfs.example.net → seaweedfs/seaweedfs-master
- nl-s3.example.net → seaweedfs/seaweedfs-s3
- velero.example.net → velero/velero-ui
- status.example.net,kyriakos.papadopoulos.tech → well-known/well-known

### Helm Releases
- argocd (argo-cd-7.7.10) in argocd
- cert-manager (cert-manager-v1.17.1) in cert-manager
- cilium (cilium-1.19.5) in kube-system
- external-secrets (external-secrets-1.1.1) in external-secrets
- ingress-nginx (ingress-nginx-4.15.1) in ingress-nginx
- k8s-agent (gitlab-agent-2.28.0) in REDACTED_01b50c5d
- REDACTED_d97cef76 (REDACTED_d97cef76-7.14.0) in REDACTED_d97cef76
- loki (loki-6.55.0) in logging
- monitoring (REDACTED_d8074874-79.12.0) in monitoring
- nfs-provisioner (REDACTED_5fef70be-4.0.18) in nfs-provisioner
- promtail (promtail-6.17.1) in logging
- seaweedfs (seaweedfs-4.0.401) in seaweedfs
- synology-csi (synology-csi-0.10.1) in synology-csi
- tetragon (tetragon-1.6.0) in kube-system

---
*Lite version - see cluster-context-full.md for complete details*
