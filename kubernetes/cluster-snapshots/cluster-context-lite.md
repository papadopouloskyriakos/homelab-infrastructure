# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-08-10 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: CRITICAL ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 18 |
| Pending PVCs | 0 |
| Total Restarts | 3487 |

## Topology

- **K8s:** v1.34.2 | **CNI:** Cilium 1.19.5
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 191

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:8005928Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8003704Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:8005712Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:8006716Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:8006728Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:8006716Ki | Taints:none

## Anomalies

### Unhealthy Pods
```
velero                   monitoring-default-kopia-maintain-job-1786330035707-p89df         0/1   Error       0                 13m
velero                   monitoring-default-kopia-maintain-job-1786330335707-5wrht         0/1   Error       0                 8m39s
velero                   monitoring-default-kopia-maintain-job-1786330645954-q5n8v         0/1   Error       0                 3m29s
velero                   nfs-provisioner-default-kopia-maintain-job-1786040876571-6bjxq    0/1   Error       0                 3d8h
velero                   nfs-provisioner-default-kopia-maintain-job-1786041167440-x8kbw    0/1   Error       0                 3d8h
velero                   nfs-provisioner-default-kopia-maintain-job-1786041455209-5bhtz    0/1   Error       0                 3d8h
velero                   pihole-default-kopia-maintain-job-1786040852187-99d5q             0/1   Error       0                 3d8h
velero                   pihole-default-kopia-maintain-job-1786041143027-7bfsl             0/1   Error       0                 3d8h
velero                   pihole-default-kopia-maintain-job-1786041487800-cm7xb             0/1   Error       0                 3d8h
velero                   REDACTED_00313366-maintain-job-1786040856243-5mlk6          0/1   Error       0                 3d8h
velero                   REDACTED_00313366-maintain-job-1786041147068-szc9f          0/1   Error       0                 3d8h
velero                   REDACTED_00313366-maintain-job-1786041434895-5md9m          0/1   Error       0                 3d8h
velero                   velero-resttest-default-kopia-maintain-job-1786040860311-rq69r    0/1   Error       0                 3d8h
velero                   velero-resttest-default-kopia-maintain-job-1786041151140-k7b4s    0/1   Error       0                 3d8h
velero                   velero-resttest-default-kopia-maintain-job-1786041438983-fdkgv    0/1   Error       0                 3d8h
velero                   velero-rt-default-kopia-maintain-job-1786040864370-kv498          0/1   Error       0                 3d8h
velero                   velero-rt-default-kopia-maintain-job-1786041155220-whvtw          0/1   Error       0                 3d8h
velero                   velero-rt-default-kopia-maintain-job-1786041443052-pvhfv          0/1   Error       0                 3d8h
```

### High Restart Pods (>3)
awx/my-awx-web-55ccb47b58-m95v8: 122 restarts
cilium-spire/spire-agent-44qs8: 129 restarts
cilium-spire/spire-agent-49g4h: 29 restarts
cilium-spire/spire-agent-6lc7n: 130 restarts
cilium-spire/spire-agent-mdslp: 133 restarts
ingress-nginx/ingress-nginx-controller-8445475547-52656: 37 restarts
ingress-nginx/ingress-nginx-controller-8445475547-lk4fg: 45 restarts
kube-system/cilium-operator-6cdbfb68d7-z6v2x: 13 restarts
kube-system/clustermesh-apiserver-6c96779765-f9j6x: 10 restarts
kube-system/etcd-nlk8s-ctrl01: 64 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 1999 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 58 restarts
kube-system/kube-apiserver-nlk8s-ctrl03: 16 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 110 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 39 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 96 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 39 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 35 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 41 restarts
kube-system/tetragon-5gk99: 5 restarts
kube-system/tetragon-75hdg: 6 restarts
kube-system/tetragon-878gv: 6 restarts
kube-system/tetragon-jz2b6: 4 restarts
kube-system/tetragon-mdsn9: 18 restarts
kube-system/tetragon-tbcc7: 6 restarts
kube-system/tetragon-vbs6v: 14 restarts
logging/promtail-hp5sc: 7 restarts
logging/promtail-ng69s: 4 restarts
monitoring/goldpinger-25hf5: 47 restarts
monitoring/goldpinger-6dj9l: 25 restarts
monitoring/goldpinger-n2fzm: 9 restarts
monitoring/goldpinger-zxtb9: 6 restarts
monitoring/monitoring-prometheus-node-exporter-6dl8r: 174 restarts
monitoring/monitoring-prometheus-node-exporter-6sc8j: 8 restarts
monitoring/monitoring-prometheus-node-exporter-wmcb8: 45 restarts
seaweedfs/seaweedfs-filer-sync-f7489458c-tgvcj: 5 restarts
synology-csi/synology-csi-node-4nxcz: 4 restarts
synology-csi/synology-csi-node-577mq: 10 restarts
synology-csi/synology-csi-node-kxrjb: 14 restarts
synology-csi/synology-csi-node-l72f8: 6 restarts
synology-csi/synology-csi-node-ptwb8: 6 restarts
synology-csi/synology-csi-node-sfdmg: 4 restarts
synology-csi/synology-csi-node-zch7n: 18 restarts

### Recent Warnings (5)
```
velero        28m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786329135705   Job has reached the specified backoff limit
velero        23m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786329435705   Job has reached the specified backoff limit
velero        18m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786329735706   Job has reached the specified backoff limit
velero        13m         Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786330035707   Job has reached the specified backoff limit
velero        8m34s       Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1786330335707   Job has reached the specified backoff limit
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
