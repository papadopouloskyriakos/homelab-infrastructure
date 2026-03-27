# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-03-27 03:00:12 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: DEGRADED ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 5 |
| Pending PVCs | 0 |
| Total Restarts | 1387 |

## Topology

- **K8s:** v1.34.2 | **CNI:** Cilium 1.18.4
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 157

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:8 Mem:8005572Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8006944Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:8006756Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:8006748Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:8006732Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:8006740Ki | Taints:none

## Anomalies

### Unhealthy Pods
```
default                  node-debugger-nlk8s-node01-drblb                             0/1   Error              0                10h
default                  node-debugger-nlk8s-node02-5wkqg                             0/1   Error              0                10h
default                  node-debugger-nlk8s-node03-jjmv9                             0/1   Error              0                10h
default                  node-debugger-nlk8s-node04-zmc56                             0/1   Error              0                10h
kube-system              kube-apiserver-nlk8s-ctrl01                                 0/1   CrashLoopBackOff   519 (44s ago)    120d
```

### High Restart Pods (>3)
cert-manager/cert-manager-75944f484-4v6qh: 15 restarts
cert-manager/cert-manager-cainjector-56b4cf957-s7xd9: 13 restarts
cilium-spire/spire-agent-xwbn2: 9 restarts
cilium-spire/spire-server-0: 4 restarts
kube-system/cilium-22zgh: 9 restarts
kube-system/cilium-envoy-mmfnj: 9 restarts
kube-system/cilium-operator-6b94496fcd-l6cjl: 100 restarts
kube-system/etcd-nlk8s-ctrl01: 89 restarts
kube-system/etcd-nlk8s-ctrl02: 39 restarts
kube-system/etcd-nlk8s-ctrl03: 6 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 519 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 57 restarts
kube-system/kube-apiserver-nlk8s-ctrl03: 14 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 92 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 30 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 80 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 29 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 27 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 26 restarts
kube-system/tetragon-878gv: 4 restarts
kube-system/tetragon-mdsn9: 18 restarts
kube-system/tetragon-vbs6v: 4 restarts
logging/loki-0: 7 restarts
monitoring/goldpinger-4fvxd: 10 restarts
monitoring/goldpinger-b44g9: 4 restarts
monitoring/goldpinger-cjzc4: 5 restarts
monitoring/goldpinger-f72lw: 4 restarts
monitoring/goldpinger-qs5xt: 5 restarts
monitoring/goldpinger-vtfpx: 5 restarts
monitoring/monitoring-grafana-777dc75f9-85gdv: 18 restarts
monitoring/monitoring-grafana-777dc75f9-hl9fb: 12 restarts
monitoring/monitoring-kube-state-metrics-74d579585b-6cprn: 19 restarts
monitoring/monitoring-prometheus-node-exporter-d5wkz: 9 restarts
monitoring/monitoring-prometheus-node-exporter-f2fld: 6 restarts
monitoring/thanos-compactor-0: 7 restarts
nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956swwjx: 30 restarts
synology-csi/synology-csi-node-kxrjb: 4 restarts
synology-csi/synology-csi-node-l72f8: 4 restarts
synology-csi/synology-csi-node-zch7n: 18 restarts

### Recent Warnings (5)
```
REDACTED_d97cef76     107s        Warning   Unhealthy               pod/REDACTED_d97cef76-kong-5c7f96dd9b-lbdrs               Readiness probe failed: Get "http://10.0.6.71:8100/status/ready": dial tcp 10.0.6.71:8100: connect: connection refused
pihole                   102s        Warning   Unhealthy               pod/pihole-fb8b7b6df-lxh9p                                   Readiness probe failed: Get "http://10.0.2.220:80/admin/": dial tcp 10.0.2.220:80: connect: connection refused
velero                   92s         Warning   Unhealthy               pod/velero-ui-687565868b-7vln5                               Readiness probe failed: Get "http://10.0.2.35:3000/": dial tcp 10.0.2.35:3000: connect: connection refused
monitoring               91s         Warning   Unhealthy               pod/goldpinger-b44g9                                         Readiness probe failed: Get "http://10.0.6.49:8080/healthz": dial tcp 10.0.6.49:8080: connect: connection refused
cert-manager             82s         Warning   Unhealthy               pod/cert-manager-webhook-5556f58976-kz9gp                    Readiness probe failed: Get "http://10.0.6.63:6080/healthz": dial tcp 10.0.6.63:6080: connect: connection refused
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
- cilium (cilium-1.18.4) in kube-system
- external-secrets (external-secrets-1.1.1) in external-secrets
- ingress-nginx (ingress-nginx-4.14.0) in ingress-nginx
- k8s-agent (gitlab-agent-2.21.1) in REDACTED_01b50c5d
- REDACTED_d97cef76 (REDACTED_d97cef76-7.14.0) in REDACTED_d97cef76
- loki (loki-6.46.0) in logging
- monitoring (REDACTED_d8074874-79.10.0) in monitoring
- nfs-provisioner (REDACTED_5fef70be-4.0.18) in nfs-provisioner
- promtail (promtail-6.17.1) in logging
- seaweedfs (seaweedfs-4.0.401) in seaweedfs
- synology-csi (synology-csi-0.10.1) in synology-csi
- tetragon (tetragon-1.6.0) in kube-system

---
*Lite version - see cluster-context-full.md for complete details*
