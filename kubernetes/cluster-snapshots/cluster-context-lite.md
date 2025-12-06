# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2025-12-06 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: DEGRADED ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 2 |
| Pending PVCs | 0 |
| Total Restarts | 270 |

## Topology

- **K8s:** v1.34.2 | **CNI:** Cilium 1.18.4
- **Nodes:** 8 (3 control-plane, 5 workers)
- **Pods:** 111

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:3795Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:3996Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:3886092Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:8006756Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:8006748Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:8006740Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:8006752Ki | Taints:none
- **notrf01k8s-node01** (worker) 185.125.171.172 | CPU:2 Mem:3907488Ki | Taints:none

## Anomalies

### Unhealthy Pods
```
cilium-spire             spire-agent-8n2ff                                                 0/1   Init:0/1           5 (2m28s ago)    9m20s
velero                   velero-node-agent-fbdfq                                           0/1   CrashLoopBackOff   6 (67s ago)      8m53s
```

### High Restart Pods (>3)
awx/awx-operator-controller-manager-79499d9678-hr474: 6 restarts
awx/my-awx-web-694487457f-9r975: 7 restarts
kube-system/cilium-envoy-ntrv6: 4 restarts
kube-system/cilium-operator-67ff4f447c-7zv95: 5 restarts
kube-system/cilium-x58c7: 4 restarts
kube-system/etcd-nlk8s-ctrl01: 7 restarts
kube-system/etcd-nlk8s-ctrl02: 5 restarts
kube-system/etcd-nlk8s-ctrl03: 4 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 24 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 5 restarts
kube-system/kube-apiserver-nlk8s-ctrl03: 5 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 22 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 10 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 14 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 17 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 12 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 13 restarts
logging/promtail-j42hf: 4 restarts
monitoring/monitoring-prometheus-node-exporter-95m6x: 5 restarts
nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-855bd85b44jwmvk: 4 restarts
synology-csi/synology-csi-node-465rx: 10 restarts
synology-csi/synology-csi-node-5sj22: 8 restarts
synology-csi/synology-csi-node-5tmgb: 10 restarts
synology-csi/synology-csi-node-7ssk7: 10 restarts
synology-csi/synology-csi-node-hmvnt: 14 restarts
synology-csi/synology-csi-node-jw295: 8 restarts
synology-csi/synology-csi-node-mx7bm: 8 restarts
velero/velero-node-agent-fbdfq: 6 restarts

### Recent Warnings (5)
```
velero         103s        Warning   BackOff            pod/velero-node-agent-fbdfq                     Back-off restarting failed container node-agent in pod velero-node-agent-fbdfq_velero(d36ab493-1887-4554-a32b-4cba8c39f99d)
kube-system    81s         Warning   DNSConfigForming   pod/cilium-fvklh                                Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
kube-system    73s         Warning   DNSConfigForming   pod/cilium-envoy-77slm                          Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
cilium-spire   69s         Warning   BackOff            pod/spire-agent-8n2ff                           Back-off restarting failed container init in pod spire-agent-8n2ff_cilium-spire(3f8eefc4-a263-4385-9750-01760a4d1dbf)
monitoring     32s         Warning   DNSConfigForming   pod/monitoring-prometheus-node-exporter-9m8bt   Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
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
- monitoring (REDACTED_d8074874-79.10.0) in monitoring
- nfs-provisioner (REDACTED_5fef70be-4.0.18) in nfs-provisioner
- promtail (promtail-6.17.1) in logging
- synology-csi (synology-csi-0.10.1) in synology-csi

---
*Lite version - see cluster-context-full.md for complete details*
