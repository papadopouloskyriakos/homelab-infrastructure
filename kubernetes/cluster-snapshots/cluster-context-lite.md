# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2025-12-01 13:11:41 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: HEALTHY ✅

| Check | Value |
|-------|-------|
| Unhealthy Pods | 0 |
| Pending PVCs | 0 |
| Total Restarts | 117 |

## Topology

- **K8s:** v1.34.2 | **CNI:** Cilium 1.18.4
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 104

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:3886100Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:3996Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:3886092Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:8006752Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:8006740Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:8006740Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:8006736Ki | Taints:none

## Anomalies

### Unhealthy Pods
_None_

### High Restart Pods (>3)
kube-system/kube-apiserver-nlk8s-ctrl01: 16 restarts
kube-system/kube-apiserver-nlk8s-ctrl03: 4 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 14 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 7 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 12 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 11 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 7 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 10 restarts
synology-csi/synology-csi-node-465rx: 6 restarts
synology-csi/synology-csi-node-5sj22: 6 restarts
synology-csi/synology-csi-node-5tmgb: 4 restarts
synology-csi/synology-csi-node-7ssk7: 6 restarts
synology-csi/synology-csi-node-hmvnt: 6 restarts
synology-csi/synology-csi-node-jw295: 6 restarts
synology-csi/synology-csi-node-mx7bm: 6 restarts

### Recent Warnings (5)
```
NAMESPACE     LAST SEEN   TYPE      REASON      OBJECT                                  MESSAGE
kube-system   18m         Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Liveness probe failed: HTTP probe failed with statuscode: 500
kube-system   3m11s       Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Readiness probe failed: HTTP probe failed with statuscode: 500
```

## Key Resources

### LoadBalancer Services
```
ingress-nginx/ingress-nginx-controller: 10.0.X.X -> 80:31689/TCP,443:30327/TCP
kube-system/hubble-relay-lb: 10.0.X.X -> 80:30629/TCP
logging/promtail-syslog: 10.0.X.X -> 514:30623/TCP
pihole/pihole-dns-lb: 10.0.X.X -> 53:31803/UDP
pihole/pihole-dns-tcp-lb: 10.0.X.X -> 53:30438/TCP
```

### Ingresses
- argocd.example.net → argocd/argocd-server
- awx.example.net → awx/awx
- bentopdf.example.net → bentopdf/bentopdf
- hubble.example.net → kube-system/hubble-ui
- k8s.example.net → REDACTED_d97cef76/REDACTED_d97cef76
- minio.example.net → minio/minio-console
- grafana.example.net → monitoring/grafana
- pihole.example.net → pihole/pihole-ingress
- velero.example.net → velero/velero-ui

### Helm Releases
- argocd (argo-cd-7.7.10) in argocd
- cert-manager (cert-manager-v1.17.1) in cert-manager
- cilium (cilium-1.18.4) in kube-system
- external-secrets (external-secrets-0.12.1) in external-secrets
- ingress-nginx (ingress-nginx-4.14.0) in ingress-nginx
- k8s-agent (gitlab-agent-2.21.1) in REDACTED_01b50c5d
- loki (loki-6.46.0) in logging
- monitoring (REDACTED_d8074874-79.9.0) in monitoring
- nfs-provisioner (REDACTED_5fef70be-4.0.18) in nfs-provisioner
- promtail (promtail-6.17.1) in logging
- synology-csi (synology-csi-0.10.1) in synology-csi

---
*Lite version - see cluster-context-full.md for complete details*
