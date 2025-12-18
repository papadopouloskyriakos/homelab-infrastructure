# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2025-12-18 03:00:02 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: HEALTHY ✅

| Check | Value |
|-------|-------|
| Unhealthy Pods | 0 |
| Pending PVCs | 0 |
| Total Restarts | 199 |

## Topology

- **K8s:** v1.34.2 | **CNI:** Cilium 1.18.4
- **Nodes:** 8 (3 control-plane, 5 workers)
- **Pods:** 143

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:3795Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:3996Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:3886092Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:8006756Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:8006748Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:8006740Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:8006752Ki | Taints:none
- **notrf01k8s-node01** (worker) 10.255.3.11 | CPU:2 Mem:3907480Ki | Taints:node-type=edge:NoSchedule

## Anomalies

### Unhealthy Pods
_None_

### High Restart Pods (>3)
kube-system/etcd-nlk8s-ctrl01: 7 restarts
kube-system/etcd-nlk8s-ctrl02: 5 restarts
kube-system/etcd-nlk8s-ctrl03: 4 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 30 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 5 restarts
kube-system/kube-apiserver-nlk8s-ctrl03: 5 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 23 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 11 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 15 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 17 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 12 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 13 restarts
monitoring/goldpinger-qs5xt: 4 restarts
monitoring/monitoring-grafana-9ccf6f977-w47db: 4 restarts
nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956swwjx: 5 restarts

### Recent Warnings (5)
```
NAMESPACE      LAST SEEN   TYPE      REASON             OBJECT                        MESSAGE
kube-system    3m30s       Warning   DNSConfigForming   pod/cilium-rhcsd              Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
kube-system    2m47s       Warning   DNSConfigForming   pod/cilium-envoy-6ws74        Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
synology-csi   2m43s       Warning   DNSConfigForming   pod/synology-csi-node-n4rjm   Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
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
- status.example.net → gatus/gatus
- nl-hubble.example.net → kube-system/hubble-ui
- nl-k8s.example.net → REDACTED_d97cef76/REDACTED_d97cef76
- goldpinger.example.net → monitoring/goldpinger
- grafana.example.net → monitoring/grafana
- nl-prometheus.example.net → monitoring/prometheus
- nl-thanos.example.net → monitoring/thanos-query
- pihole.example.net → pihole/pihole-ingress
- kyriakos.papadopoulos.tech → portfolio/portfolio
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

---
*Lite version - see cluster-context-full.md for complete details*
