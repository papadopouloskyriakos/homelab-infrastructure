# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-03-28 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: HEALTHY ✅

| Check | Value |
|-------|-------|
| Unhealthy Pods | 0 |
| Pending PVCs | 0 |
| Total Restarts | 1275 |

## Topology

- **K8s:** v1.34.2 | **CNI:** Cilium 1.18.4
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 151

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:8006952Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8006944Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:8006752Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:8006756Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:8006732Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:8006740Ki | Taints:none

## Anomalies

### Unhealthy Pods
_None_

### High Restart Pods (>3)
cilium-spire/spire-agent-26mm7: 4 restarts
cilium-spire/spire-agent-jn2zt: 5 restarts
cilium-spire/spire-agent-lvrj5: 4 restarts
cilium-spire/spire-agent-xwbn2: 9 restarts
kube-system/cilium-22zgh: 9 restarts
kube-system/cilium-envoy-cfv8x: 4 restarts
kube-system/cilium-envoy-mmfnj: 9 restarts
kube-system/cilium-gz5mp: 4 restarts
kube-system/etcd-nlk8s-ctrl01: 99 restarts
kube-system/etcd-nlk8s-ctrl02: 39 restarts
kube-system/etcd-nlk8s-ctrl03: 6 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 551 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 57 restarts
kube-system/kube-apiserver-nlk8s-ctrl03: 14 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 94 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 30 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 80 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 31 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 27 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 26 restarts
kube-system/tetragon-878gv: 4 restarts
kube-system/tetragon-mdsn9: 18 restarts
kube-system/tetragon-tbcc7: 4 restarts
kube-system/tetragon-vbs6v: 8 restarts
logging/loki-0: 13 restarts
logging/promtail-hp5sc: 4 restarts
monitoring/goldpinger-4fvxd: 10 restarts
monitoring/goldpinger-b44g9: 6 restarts
monitoring/goldpinger-cjzc4: 5 restarts
monitoring/goldpinger-f72lw: 5 restarts
monitoring/goldpinger-qs5xt: 5 restarts
monitoring/goldpinger-vtfpx: 7 restarts
monitoring/monitoring-grafana-777dc75f9-8l8qt: 10 restarts
monitoring/monitoring-grafana-777dc75f9-zdlv4: 8 restarts
monitoring/monitoring-prometheus-node-exporter-d5wkz: 9 restarts
monitoring/monitoring-prometheus-node-exporter-f2fld: 8 restarts
monitoring/monitoring-prometheus-node-exporter-fh2zz: 4 restarts
monitoring/monitoring-prometheus-node-exporter-hc6cl: 4 restarts
seaweedfs/seaweedfs-volume-1: 5 restarts
synology-csi/synology-csi-node-kxrjb: 8 restarts
synology-csi/synology-csi-node-l72f8: 4 restarts
synology-csi/synology-csi-node-ptwb8: 4 restarts
synology-csi/synology-csi-node-zch7n: 18 restarts

### Recent Warnings (5)
```
NAMESPACE     LAST SEEN   TYPE      REASON      OBJECT                                  MESSAGE
kube-system   41m         Warning   Unhealthy   pod/etcd-nlk8s-ctrl01             Readiness probe failed: Get "http://127.0.0.1:2381/readyz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
kube-system   20m         Warning   Unhealthy   pod/etcd-nlk8s-ctrl01             Readiness probe failed: HTTP probe failed with statuscode: 503
kube-system   6m          Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Readiness probe failed: HTTP probe failed with statuscode: 500
kube-system   2m8s        Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Liveness probe failed: HTTP probe failed with statuscode: 500
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
