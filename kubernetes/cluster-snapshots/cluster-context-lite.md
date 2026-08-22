# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-08-22 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: CRITICAL ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 24 |
| Pending PVCs | 0 |
| Total Restarts | 559 |

## Topology

- **K8s:** v1.36.3 | **CNI:** Cilium 1.20.0
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 179

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
velero                   argocd-default-kopia-maintain-job-1787366927597-qlrsx             0/1   Error       0                 12m
velero                   argocd-default-kopia-maintain-job-1787367289410-7h8pk             0/1   Error       0                 6m16s
velero                   argocd-default-kopia-maintain-job-1787367527514-c85wp             0/1   Error       0                 2m18s
velero                   awx-default-kopia-maintain-job-1787366990109-s9ktq                0/1   Error       0                 11m
velero                   awx-default-kopia-maintain-job-1787367248947-c9fnd                0/1   Error       0                 6m57s
velero                   awx-default-kopia-maintain-job-1787367589873-7szj2                0/1   Error       0                 76s
velero                   cilium-spire-default-kopia-maintain-job-1787366943744-xjksj       0/1   Error       0                 12m
velero                   cilium-spire-default-kopia-maintain-job-1787367306438-rql2w       0/1   Error       0                 5m59s
velero                   cilium-spire-default-kopia-maintain-job-1787367544769-ml9k6       0/1   Error       0                 2m1s
velero                   gatus-default-kopia-maintain-job-1787367008875-rvmfj              0/1   Error       0                 10m
velero                   gatus-default-kopia-maintain-job-1787367266101-x9ndx              0/1   Error       0                 6m39s
velero                   gatus-default-kopia-maintain-job-1787367607020-ltqcl              0/1   Error       0                 58s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787367014kx4qh   0/1   Error       0                 10m
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787367271q4ml2   0/1   Error       0                 6m34s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787367613l46tt   0/1   Error       0                 52s
velero                   logging-default-kopia-maintain-job-1787366948977-td9k8            0/1   Error       0                 11m
velero                   logging-default-kopia-maintain-job-1787367310490-r5g4s            0/1   Error       0                 5m55s
velero                   logging-default-kopia-maintain-job-1787367550300-xdrmw            0/1   Error       0                 115s
velero                   monitoring-default-kopia-maintain-job-1787366966446-79hpf         0/1   Error       0                 11m
velero                   monitoring-default-kopia-maintain-job-1787367227514-mv5vz         0/1   Error       0                 7m18s
velero                   monitoring-default-kopia-maintain-job-1787367567364-6bc5p         0/1   Error       0                 98s
velero                   well-known-default-kopia-maintain-job-1787366971532-mq86c         0/1   Error       0                 11m
velero                   well-known-default-kopia-maintain-job-1787367232902-qmtnc         0/1   Error       0                 7m13s
velero                   well-known-default-kopia-maintain-job-1787367572760-brhfr         0/1   Error       0                 93s
```

### High Restart Pods (>3)
ingress-nginx/ingress-nginx-controller-8445475547-6zqqc: 29 restarts
ingress-nginx/ingress-nginx-controller-8445475547-kr7kz: 30 restarts
kube-system/clustermesh-apiserver-6c8cd7bb6f-ctst4: 51 restarts
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
monitoring/monitoring-grafana-6c7c5dfd7b-xfrlh: 43 restarts
monitoring/monitoring-kube-prometheus-operator-67d8d4c647-vwbbr: 10 restarts
monitoring/monitoring-kube-state-metrics-75f9fff55b-4vfg6: 23 restarts
monitoring/monitoring-prometheus-node-exporter-6dl8r: 175 restarts
monitoring/monitoring-prometheus-node-exporter-6sc8j: 9 restarts
monitoring/monitoring-prometheus-node-exporter-vgp6b: 4 restarts
monitoring/monitoring-prometheus-node-exporter-wmcb8: 46 restarts
monitoring/prometheus-REDACTED_6dfbe9fc-0: 45 restarts
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
velero          77s         Warning   BackoffLimitExceeded   job/well-known-default-kopia-maintain-job-1787367572760             Job has reached the specified backoff limit
velero          60s         Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1787367589873                    Job has reached the specified backoff limit
velero          54s         Warning   BackoffLimitExceeded   job/gatus-default-kopia-maintain-job-1787367607020                  Job has reached the specified backoff limit
velero          34s         Warning   BackoffLimitExceeded   job/REDACTED_d97cef76-default-kopia-maintain-job-1787367613298   Job has reached the specified backoff limit
kube-system     23s         Warning   Unhealthy              pod/kube-apiserver-nlk8s-ctrl01                               Liveness probe failed: HTTP probe failed with statuscode: 500
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
