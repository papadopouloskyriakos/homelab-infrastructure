# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-01-27 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: HEALTHY ✅

| Check | Value |
|-------|-------|
| Unhealthy Pods | 0 |
| Pending PVCs | 0 |
| Total Restarts | 757 |

## Topology

- **K8s:** v1.34.2 | **CNI:** Cilium 1.18.4
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 143

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:3795Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:3996Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:3886092Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:8006756Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:8006748Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:8006740Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:8006752Ki | Taints:none

## Anomalies

### Unhealthy Pods
_None_

### High Restart Pods (>3)
awx/awx-operator-controller-manager-846b99bbd-t9589: 8 restarts
cert-manager/cert-manager-75944f484-4v6qh: 9 restarts
cert-manager/cert-manager-cainjector-56b4cf957-s7xd9: 7 restarts
cilium-spire/spire-agent-xwbn2: 8 restarts
kube-system/cilium-22zgh: 8 restarts
kube-system/cilium-envoy-mmfnj: 8 restarts
kube-system/cilium-operator-6b94496fcd-l6cjl: 73 restarts
kube-system/etcd-nlk8s-ctrl01: 16 restarts
kube-system/etcd-nlk8s-ctrl02: 38 restarts
kube-system/etcd-nlk8s-ctrl03: 4 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 108 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 55 restarts
kube-system/kube-apiserver-nlk8s-ctrl03: 12 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 83 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 21 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 69 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 20 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 21 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 18 restarts
kube-system/tetragon-mdsn9: 16 restarts
logging/loki-0: 15 restarts
logging/promtail-rxt6j: 8 restarts
monitoring/bgpalerter-596d7b756b-pxcb5: 8 restarts
monitoring/goldpinger-4fvxd: 9 restarts
monitoring/goldpinger-qs5xt: 4 restarts
monitoring/monitoring-grafana-9ccf6f977-mhjwg: 43 restarts
monitoring/monitoring-grafana-9ccf6f977-w47db: 33 restarts
monitoring/monitoring-kube-state-metrics-74d579585b-6cprn: 10 restarts
monitoring/monitoring-prometheus-node-exporter-d5wkz: 8 restarts
nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956swwjx: 13 restarts
seaweedfs/seaweedfs-filer-0: 30 restarts
seaweedfs/seaweedfs-filer-1: 26 restarts
synology-csi/synology-csi-node-zch7n: 16 restarts

### Recent Warnings (5)
```
NAMESPACE     LAST SEEN   TYPE      REASON      OBJECT                                  MESSAGE
kube-system   59m         Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl02   Readiness probe failed: HTTP probe failed with statuscode: 500
kube-system   113s        Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Readiness probe failed: HTTP probe failed with statuscode: 500
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
