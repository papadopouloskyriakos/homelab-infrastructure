# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-08-18 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: CRITICAL ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 24 |
| Pending PVCs | 0 |
| Total Restarts | 413 |

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
velero                   argocd-default-kopia-maintain-job-1787021346381-cs2c2             0/1   Error       0               11m
velero                   argocd-default-kopia-maintain-job-1787021674672-q5srf             0/1   Error       0               6m12s
velero                   argocd-default-kopia-maintain-job-1787021946332-d7pwx             0/1   Error       0               100s
velero                   awx-default-kopia-maintain-job-1787021295209-6zkvs                0/1   Error       0               12m
velero                   awx-default-kopia-maintain-job-1787021625462-4bwgh                0/1   Error       0               7m1s
velero                   awx-default-kopia-maintain-job-1787021895169-c8tqr                0/1   Error       0               2m31s
velero                   cilium-spire-default-kopia-maintain-job-1787021363425-f6htz       0/1   Error       0               11m
velero                   cilium-spire-default-kopia-maintain-job-1787021595168-l5j5s       0/1   Error       0               7m31s
velero                   cilium-spire-default-kopia-maintain-job-1787021963369-pq5x8       0/1   Error       0               83s
velero                   gatus-default-kopia-maintain-job-1787021367472-5d8sb              0/1   Error       0               11m
velero                   gatus-default-kopia-maintain-job-1787021599222-scjr9              0/1   Error       0               7m27s
velero                   gatus-default-kopia-maintain-job-1787021968437-tnxwh              0/1   Error       0               78s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-17870213126xjd8   0/1   Error       0               12m
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787021642fm5p6   0/1   Error       0               6m44s
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787021912n9wlh   0/1   Error       0               2m14s
velero                   logging-default-kopia-maintain-job-1787021372521-xz7xk            0/1   Error       0               11m
velero                   logging-default-kopia-maintain-job-1787021604262-sqg9l            0/1   Error       0               7m22s
velero                   logging-default-kopia-maintain-job-1787021973508-g79kq            0/1   Error       0               73s
velero                   monitoring-default-kopia-maintain-job-1787021390564-s9bml         0/1   Error       0               10m
velero                   monitoring-default-kopia-maintain-job-1787021620302-zknbd         0/1   Error       0               7m6s
velero                   monitoring-default-kopia-maintain-job-1787021989624-9xxtn         0/1   Error       0               57s
velero                   well-known-default-kopia-maintain-job-1787021329302-hkdww         0/1   Error       0               11m
velero                   well-known-default-kopia-maintain-job-1787021658578-9ww8z         0/1   Error       0               6m28s
velero                   well-known-default-kopia-maintain-job-1787021929274-k6qdz         0/1   Error       0               117s
```

### High Restart Pods (>3)
kube-system/tetragon-5gk99: 7 restarts
kube-system/tetragon-75hdg: 8 restarts
kube-system/tetragon-878gv: 8 restarts
kube-system/tetragon-jz2b6: 6 restarts
kube-system/tetragon-mdsn9: 23 restarts
kube-system/tetragon-tbcc7: 8 restarts
kube-system/tetragon-vbs6v: 16 restarts
logging/promtail-5jr9j: 4 restarts
logging/promtail-hp5sc: 8 restarts
logging/promtail-ng69s: 5 restarts
monitoring/monitoring-prometheus-node-exporter-6dl8r: 175 restarts
monitoring/monitoring-prometheus-node-exporter-6sc8j: 9 restarts
monitoring/monitoring-prometheus-node-exporter-vgp6b: 4 restarts
monitoring/monitoring-prometheus-node-exporter-wmcb8: 46 restarts
synology-csi/synology-csi-node-4nxcz: 6 restarts
synology-csi/synology-csi-node-577mq: 12 restarts
synology-csi/synology-csi-node-kxrjb: 17 restarts
synology-csi/synology-csi-node-l72f8: 9 restarts
synology-csi/synology-csi-node-ptwb8: 8 restarts
synology-csi/synology-csi-node-sfdmg: 6 restarts
synology-csi/synology-csi-node-zch7n: 24 restarts

### Recent Warnings (5)
```
velero        102s        Warning   BackoffLimitExceeded   job/well-known-default-kopia-maintain-job-1787021929274             Job has reached the specified backoff limit
velero        85s         Warning   BackoffLimitExceeded   job/argocd-default-kopia-maintain-job-1787021946332                 Job has reached the specified backoff limit
velero        80s         Warning   BackoffLimitExceeded   job/cilium-spire-default-kopia-maintain-job-1787021963369           Job has reached the specified backoff limit
velero        75s         Warning   BackoffLimitExceeded   job/gatus-default-kopia-maintain-job-1787021968437                  Job has reached the specified backoff limit
velero        59s         Warning   BackoffLimitExceeded   job/logging-default-kopia-maintain-job-1787021973508                Job has reached the specified backoff limit
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
