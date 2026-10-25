# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-10-25 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: DEGRADED ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 3 |
| Pending PVCs | 0 |
| Total Restarts | 7535 |

## Topology

- **K8s:** v1.36.3 | **CNI:** Cilium 1.20.0
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 175

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:8002648Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule,node.kubernetes.io/unreachable=:NoSchedule,node.cilium.io/agent-not-ready=:NoSchedule,node.kubernetes.io/unreachable=:NoExecute
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8003704Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:10054396Ki | Taints:node.kubernetes.io/unschedulable=:NoSchedule,node.kubernetes.io/unreachable=:NoSchedule,node.cilium.io/agent-not-ready=:NoSchedule,node.kubernetes.io/unreachable=:NoExecute
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:10054404Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:10054404Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:10053348Ki | Taints:none

## Anomalies

### Unhealthy Pods
```
cnpg-system              cnpg-janitor-29880203-bjgqk                                       0/1   Error              0                 23h
velero                   monitoring-default-kopia-maintain-job-1790197917279-s5f69         0/1   Error              0                 31d
velero                   velero-ui-687565868b-b9xr7                                        0/1   CrashLoopBackOff   3418 (92s ago)    39d
```

### High Restart Pods (>3)
argocd/argocd-application-controller-0: 77 restarts
awx/awx-operator-controller-manager-6ffdf98f6-8jv8s: 136 restarts
awx/my-awx-task-756d768868-bslc2: 7 restarts
awx/my-awx-web-f9c4bb98d-wcn4j: 5 restarts
cert-manager/cert-manager-75944f484-k8x88: 39 restarts
cert-manager/cert-manager-cainjector-74f994b988-shnfp: 41 restarts
cilium-spire/spire-agent-2xj9z: 276 restarts
cilium-spire/spire-agent-bf7g7: 279 restarts
cilium-spire/spire-agent-hpld8: 276 restarts
cilium-spire/spire-agent-hrngt: 20 restarts
cilium-spire/spire-agent-sm9xs: 284 restarts
cilium-spire/spire-agent-xk8cl: 280 restarts
cilium-spire/spire-agent-zqpt4: 288 restarts
cnpg-system/cnpg-cloudnative-pg-6d8bdc546d-wzdfh: 93 restarts
cnpg-system/cnpg-cloudnative-pg-6d8bdc546d-zl8gc: 116 restarts
kube-system/cilium-c8kqc: 12 restarts
kube-system/cilium-envoy-brdkr: 10 restarts
kube-system/cilium-envoy-dzx97: 12 restarts
kube-system/cilium-envoy-z9854: 4 restarts
kube-system/cilium-g5h5t: 10 restarts
kube-system/cilium-operator-84c4fb58c7-jlhkp: 156 restarts
kube-system/cilium-qw7d6: 4 restarts
kube-system/etcd-nlk8s-ctrl02: 11 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 31 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 18 restarts
kube-system/kube-apiserver-nlk8s-ctrl03: 15 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 108 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 20 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 102 restarts
kube-system/kube-proxy-7jvns: 12 restarts
kube-system/kube-proxy-jvln5: 6 restarts
kube-system/kube-proxy-sg86x: 4 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 95 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 12 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 108 restarts
kube-system/tetragon-5gk99: 9 restarts
kube-system/tetragon-75hdg: 32 restarts
kube-system/tetragon-878gv: 8 restarts
kube-system/tetragon-jz2b6: 14 restarts
kube-system/tetragon-mdsn9: 44 restarts
kube-system/tetragon-tbcc7: 10 restarts
kube-system/tetragon-vbs6v: 20 restarts
kyverno/kyverno-admission-controller-584d7f7684-6k9gg: 126 restarts
kyverno/kyverno-reports-controller-7bbf4b866b-rq8pt: 129 restarts
logging/loki-0: 8 restarts
logging/loki-canary-bbplf: 14 restarts
logging/loki-canary-xbmzr: 5 restarts
logging/promtail-5jr9j: 6 restarts
logging/promtail-br4rf: 6 restarts
logging/promtail-hp5sc: 10 restarts
logging/promtail-m2gzm: 13 restarts
logging/promtail-ng69s: 17 restarts
monitoring/bgpalerter-b7bc9c8c-kdlv5: 4 restarts
monitoring/goldpinger-fjpnh: 7 restarts
monitoring/goldpinger-rb96x: 11 restarts
monitoring/goldpinger-t8x65: 12 restarts
monitoring/monitoring-grafana-7d6c5795b8-6cvtn: 25 restarts
monitoring/monitoring-grafana-7d6c5795b8-vbrmn: 22 restarts
monitoring/monitoring-kube-state-metrics-75f9fff55b-prwns: 102 restarts
monitoring/monitoring-prometheus-node-exporter-6dl8r: 187 restarts
monitoring/monitoring-prometheus-node-exporter-6sc8j: 10 restarts
monitoring/monitoring-prometheus-node-exporter-88hp8: 13 restarts
monitoring/monitoring-prometheus-node-exporter-8bq88: 6 restarts
monitoring/monitoring-prometheus-node-exporter-vgp6b: 6 restarts
monitoring/monitoring-prometheus-node-exporter-wmcb8: 47 restarts
monitoring/prometheus-REDACTED_6dfbe9fc-1: 25 restarts
nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-75b84759cfvtflq: 150 restarts
synology-csi/synology-csi-node-4nxcz: 8 restarts
synology-csi/synology-csi-node-kxrjb: 21 restarts
synology-csi/synology-csi-node-l72f8: 9 restarts
synology-csi/synology-csi-node-mrqzg: 24 restarts
synology-csi/synology-csi-node-ptwb8: 10 restarts
synology-csi/synology-csi-node-sfdmg: 14 restarts
synology-csi/synology-csi-node-zch7n: 47 restarts
velero/node-agent-54dn2: 10 restarts
velero/velero-ui-687565868b-b9xr7: 3418 restarts

### Recent Warnings (5)
```
kube-system              93s         Warning   Unhealthy         pod/kube-controller-manager-nlk8s-ctrl01                          Liveness probe failed: Get "https://127.0.0.1:10257/healthz": dial tcp 127.0.0.1:10257: connect: connection refused
kube-system              91s         Warning   Unhealthy         pod/kube-apiserver-nlk8s-ctrl01                                   Readiness probe failed: HTTP probe failed with statuscode: 500
kube-system              91s         Warning   Unhealthy         pod/etcd-nlk8s-ctrl01                                             Readiness probe failed: HTTP probe failed with statuscode: 503
kube-system              90s         Warning   Unhealthy         pod/kube-scheduler-nlk8s-ctrl01                                   Liveness probe failed: Get "https://127.0.0.1:10259/livez": dial tcp 127.0.0.1:10259: connect: connection refused
cnpg-system              90s         Warning   Unhealthy         pod/cnpg-cloudnative-pg-6d8bdc546d-zl8gc                                Readiness probe failed: Get "https://10.0.6.45:9443/readyz": dial tcp 10.0.6.45:9443: connect: connection refused
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
- velero.example.net → velero/velero-ui
- status.example.net,kyriakos.papadopoulos.tech → well-known/well-known

### Helm Releases
- argocd (argo-cd-7.7.10) in argocd
- cert-manager (cert-manager-v1.17.1) in cert-manager
- cilium (cilium-1.20.0) in kube-system
- cnpg (cloudnative-pg-0.29.0) in cnpg-system
- external-secrets (external-secrets-1.1.1) in external-secrets
- ingress-nginx (ingress-nginx-4.15.1) in ingress-nginx
- k8s-agent (gitlab-agent-2.28.0) in REDACTED_01b50c5d
- REDACTED_d97cef76 (REDACTED_d97cef76-7.14.0) in REDACTED_d97cef76
- kyverno (kyverno-3.9.1) in kyverno
- kyverno-policies (kyverno-policies-3.9.1) in kyverno
- loki (loki-6.55.0) in logging
- metrics-server (metrics-server-3.14.0) in kube-system
- monitoring (REDACTED_d8074874-79.12.0) in monitoring
- nfs-provisioner (REDACTED_5fef70be-4.0.18) in nfs-provisioner
- promtail (promtail-6.17.1) in logging
- reloader (reloader-2.2.17) in reloader
- synology-csi (synology-csi-0.10.1) in synology-csi
- tetragon (tetragon-1.6.0) in kube-system

---
*Lite version - see cluster-context-full.md for complete details*
