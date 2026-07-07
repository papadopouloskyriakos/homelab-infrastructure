# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-07-07 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: DEGRADED ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 2 |
| Pending PVCs | 0 |
| Total Restarts | 3244 |

## Topology

- **K8s:** v1.34.2 | **CNI:** Cilium 1.18.4
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 152

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:8005928Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8006944Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:8005716Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:8006756Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:8006732Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:8006740Ki | Taints:none

## Anomalies

### Unhealthy Pods
```
monitoring               bgpalerter-5c8b566bbd-dnk78                                       0/1   CrashLoopBackOff   4 (72s ago)        3m11s
monitoring               prometheus-REDACTED_6dfbe9fc-0                0/3   Init:0/1           0                  49s
```

### High Restart Pods (>3)
argocd/argocd-server-64dd47d8bf-mcx86: 149 restarts
cert-manager/cert-manager-75944f484-htnps: 19 restarts
cilium-spire/spire-agent-26mm7: 34 restarts
cilium-spire/spire-agent-9whrn: 5 restarts
cilium-spire/spire-agent-jn2zt: 5 restarts
cilium-spire/spire-agent-lvrj5: 7 restarts
cilium-spire/spire-agent-xwbn2: 9 restarts
kube-system/cilium-22zgh: 9 restarts
kube-system/cilium-envoy-cfv8x: 7 restarts
kube-system/cilium-envoy-mmfnj: 9 restarts
kube-system/cilium-gz5mp: 7 restarts
kube-system/cilium-operator-6b94496fcd-qwll4: 45 restarts
kube-system/etcd-nlk8s-ctrl01: 64 restarts
kube-system/hubble-relay-8577574994-88mcm: 12 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 1992 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 58 restarts
kube-system/kube-apiserver-nlk8s-ctrl03: 14 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 103 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 34 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 88 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 36 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 32 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 35 restarts
kube-system/tetragon-75hdg: 4 restarts
kube-system/tetragon-878gv: 4 restarts
kube-system/tetragon-mdsn9: 18 restarts
kube-system/tetragon-tbcc7: 4 restarts
kube-system/tetragon-vbs6v: 14 restarts
REDACTED_d97cef76/REDACTED_d97cef76-kong-5c7f96dd9b-wdxb7: 31 restarts
logging/loki-0: 75 restarts
logging/loki-canary-7shdd: 7 restarts
logging/promtail-hp5sc: 7 restarts
monitoring/alertmanager-monitoring-kube-prometheus-alertmanager-1: 4 restarts
monitoring/bgpalerter-5c8b566bbd-dnk78: 4 restarts
monitoring/monitoring-prometheus-node-exporter-6dl8r: 157 restarts
monitoring/monitoring-prometheus-node-exporter-wmcb8: 6 restarts
monitoring/thanos-compactor-0: 8 restarts
nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b495697mkm: 129 restarts
synology-csi/synology-csi-node-577mq: 8 restarts
synology-csi/synology-csi-node-kxrjb: 14 restarts
synology-csi/synology-csi-node-l72f8: 4 restarts
synology-csi/synology-csi-node-ptwb8: 4 restarts
synology-csi/synology-csi-node-zch7n: 18 restarts

### Recent Warnings (5)
```
REDACTED_01b50c5d   2m56s       Warning   Unhealthy            pod/k8s-agent-gitlabREDACTED_be72e515lv6fg                        Readiness probe failed: Get "http://10.0.2.211:8080/readiness": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
ingress-nginx            2m38s       Warning   Unhealthy            pod/ingress-nginx-controller-54679f6994-n5wjf                         Readiness probe failed: HTTP probe failed with statuscode: 500
ingress-nginx            2m35s       Warning   Unhealthy            pod/ingress-nginx-controller-54679f6994-7j275                         Readiness probe failed: HTTP probe failed with statuscode: 500
monitoring               2m27s       Warning   Unhealthy            pod/goldpinger-4fvxd                                                  Readiness probe failed: Get "http://10.0.5.240:8080/healthz": dial tcp 10.0.5.240:8080: connect: connection refused
monitoring               65s         Warning   Unhealthy            pod/prometheus-REDACTED_6dfbe9fc-1                Startup probe failed: HTTP probe failed with statuscode: 503
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
- monitoring (REDACTED_d8074874-79.12.0) in monitoring
- nfs-provisioner (REDACTED_5fef70be-4.0.18) in nfs-provisioner
- promtail (promtail-6.17.1) in logging
- synology-csi (synology-csi-0.10.1) in synology-csi
- tetragon (tetragon-1.6.0) in kube-system

---
*Lite version - see cluster-context-full.md for complete details*
