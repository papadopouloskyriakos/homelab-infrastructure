# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-08-23 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: CRITICAL ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 24 |
| Pending PVCs | 0 |
| Total Restarts | 618 |

## Topology

- **K8s:** v1.36.3 | **CNI:** Cilium 1.20.0
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 180

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:8002696Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8003704Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:8001304Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:8002312Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:8002312Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:8002308Ki | Taints:none

## Anomalies

### Unhealthy Pods
```
velero                   argocd-default-kopia-maintain-job-1787453380969-4pdlh             0/1   Error       0                 11m
velero                   argocd-default-kopia-maintain-job-1787453627773-wrv4c             0/1   Error       0                 7m9s
velero                   argocd-default-kopia-maintain-job-1787453927774-rxpvx             0/1   Error       0                 2m9s
velero                   awx-default-kopia-maintain-job-1787453343807-2jczf                0/1   Error       0                 11m
velero                   awx-default-kopia-maintain-job-1787453687051-cwd2w                0/1   Error       0                 6m9s
velero                   awx-default-kopia-maintain-job-1787453986039-tb6jb                0/1   Error       0                 70s
velero                   cilium-spire-default-kopia-maintain-job-1787453396996-cstbh       0/1   Error       0                 10m
velero                   cilium-spire-default-kopia-maintain-job-1787453644804-zfq82       0/1   Error       0                 6m52s
velero                   cilium-spire-default-kopia-maintain-job-1787453945808-5gn89       0/1   Error       0                 111s
velero                   gatus-default-kopia-maintain-job-1787453359848-j87xq              0/1   Error       0                 11m
velero                   gatus-default-kopia-maintain-job-1787453703088-q8mbf              0/1   Error       0                 5m53s
velero                   gatus-default-kopia-maintain-job-1787454005223-4zrmn              0/1   Error       0                 51s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787453364s2r62   0/1   Error       0                 11m
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787453708vmg8s   0/1   Error       0                 5m48s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787454013twtkt   0/1   Error       0                 43s
velero                   logging-default-kopia-maintain-job-1787453402059-l2pwm            0/1   Error       0                 10m
velero                   logging-default-kopia-maintain-job-1787453649852-24t77            0/1   Error       0                 6m47s
velero                   logging-default-kopia-maintain-job-1787453949842-4jp9f            0/1   Error       0                 107s
velero                   monitoring-default-kopia-maintain-job-1787453418118-gstwb         0/1   Error       0                 10m
velero                   monitoring-default-kopia-maintain-job-1787453665895-vwn4r         0/1   Error       0                 6m31s
velero                   monitoring-default-kopia-maintain-job-1787453965879-j6x52         0/1   Error       0                 91s
velero                   well-known-default-kopia-maintain-job-1787453327772-nb468         0/1   Error       0                 12m
velero                   well-known-default-kopia-maintain-job-1787453671016-nkhz4         0/1   Error       0                 6m25s
velero                   well-known-default-kopia-maintain-job-1787453969997-b8j27         0/1   Error       0                 86s
```

### High Restart Pods (>3)
ingress-nginx/ingress-nginx-controller-8445475547-6zqqc: 42 restarts
ingress-nginx/ingress-nginx-controller-8445475547-kr7kz: 41 restarts
kube-system/clustermesh-apiserver-6c8cd7bb6f-ctst4: 64 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 4 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 4 restarts
kube-system/tetragon-5gk99: 7 restarts
kube-system/tetragon-75hdg: 8 restarts
kube-system/tetragon-878gv: 8 restarts
kube-system/tetragon-jz2b6: 6 restarts
kube-system/tetragon-mdsn9: 23 restarts
kube-system/tetragon-tbcc7: 8 restarts
kube-system/tetragon-vbs6v: 16 restarts
logging/promtail-5jr9j: 5 restarts
logging/promtail-hp5sc: 8 restarts
logging/promtail-ng69s: 5 restarts
monitoring/monitoring-grafana-6c7c5dfd7b-xfrlh: 58 restarts
monitoring/monitoring-kube-prometheus-operator-67d8d4c647-vwbbr: 12 restarts
monitoring/monitoring-kube-state-metrics-75f9fff55b-4vfg6: 30 restarts
monitoring/monitoring-prometheus-node-exporter-6dl8r: 175 restarts
monitoring/monitoring-prometheus-node-exporter-6sc8j: 9 restarts
monitoring/monitoring-prometheus-node-exporter-vgp6b: 4 restarts
monitoring/monitoring-prometheus-node-exporter-wmcb8: 46 restarts
monitoring/prometheus-REDACTED_6dfbe9fc-0: 46 restarts
monitoring/prometheus-REDACTED_6dfbe9fc-1: 10 restarts
synology-csi/synology-csi-node-4nxcz: 6 restarts
synology-csi/synology-csi-node-577mq: 12 restarts
synology-csi/synology-csi-node-kxrjb: 17 restarts
synology-csi/synology-csi-node-l72f8: 9 restarts
synology-csi/synology-csi-node-ptwb8: 8 restarts
synology-csi/synology-csi-node-sfdmg: 6 restarts
synology-csi/synology-csi-node-zch7n: 24 restarts

### Recent Warnings (5)
```
velero          87s         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1787453965879             Job has reached the specified backoff limit
velero          71s         Warning   BackoffLimitExceeded   job/well-known-default-kopia-maintain-job-1787453969997             Job has reached the specified backoff limit
monitoring      53s         Warning   Unhealthy              pod/monitoring-prometheus-node-exporter-88hp8                       Liveness probe failed: Get "http://10.0.X.X:9100/": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
velero          52s         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1787453986039                    Job has reached the specified backoff limit
velero          44s         Warning   BackoffLimitExceeded   job/gatus-default-kopia-maintain-job-1787454005223                  Job has reached the specified backoff limit
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
- cilium (cilium-1.20.0) in kube-system
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
