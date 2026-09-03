# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-09-03 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: CRITICAL ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 14 |
| Pending PVCs | 0 |
| Total Restarts | 4761 |

## Topology

- **K8s:** v1.36.3 | **CNI:** Cilium 1.20.0
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 174

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:8002696Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8003704Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:16246548Ki | Taints:node.kubernetes.io/unreachable=:NoSchedule,node.cilium.io/agent-not-ready=:NoSchedule,node.kubernetes.io/unreachable=:NoExecute
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:10054404Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:10054404Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:12117776Ki | Taints:none

## Anomalies

### Unhealthy Pods
```
awx                      awx-operator-controller-manager-6ffdf98f6-m9gvc                   2/2   Terminating   2 (8d ago)         9d
cnpg-system              cnpg-cloudnative-pg-6d8bdc546d-xtt94                              1/1   Terminating   1 (8d ago)         9d
kube-system              kube-proxy-qn8md                                                  0/1   Error         2703 (6m12s ago)   17d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be-75b84759cfskglb   1/1   Terminating   2 (8d ago)         9d
velero                   awx-default-kopia-maintain-job-1788403591164-d2tbq                0/1   Error         0                  14m
velero                   awx-default-kopia-maintain-job-1788403896209-xs9gh                0/1   Error         0                  9m15s
velero                   awx-default-kopia-maintain-job-1788404196194-5wjhg                0/1   Error         0                  4m14s
velero                   monitoring-default-kopia-maintain-job-1788403596202-gcgpp         0/1   Error         0                  14m
velero                   monitoring-default-kopia-maintain-job-1788403901233-n68zr         0/1   Error         0                  9m10s
velero                   monitoring-default-kopia-maintain-job-1788404200219-c7q4l         0/1   Error         0                  4m10s
velero                   node-agent-55hgg                                                  1/1   Terminating   1 (9d ago)         9d
velero                   pihole-default-kopia-maintain-job-1788403601225-v6dnm             0/1   Error         0                  14m
velero                   pihole-default-kopia-maintain-job-1788403891165-bgftg             0/1   Error         0                  9m20s
velero                   pihole-default-kopia-maintain-job-1788404191165-bcqbc             0/1   Error         0                  4m19s
```

### High Restart Pods (>3)
awx/my-awx-task-756d768868-bslc2: 6 restarts
cilium-spire/spire-agent-2xj9z: 258 restarts
cilium-spire/spire-agent-bf7g7: 261 restarts
cilium-spire/spire-agent-hpld8: 259 restarts
cilium-spire/spire-agent-sm9xs: 259 restarts
cilium-spire/spire-agent-xk8cl: 258 restarts
cilium-spire/spire-agent-zqpt4: 261 restarts
kube-system/cilium-operator-84c4fb58c7-jlhkp: 4 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 7 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 6 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 4 restarts
kube-system/kube-proxy-qn8md: 2703 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 5 restarts
kube-system/tetragon-5gk99: 9 restarts
kube-system/tetragon-75hdg: 10 restarts
kube-system/tetragon-878gv: 8 restarts
kube-system/tetragon-jz2b6: 8 restarts
kube-system/tetragon-mdsn9: 27 restarts
kube-system/tetragon-tbcc7: 10 restarts
kube-system/tetragon-vbs6v: 16 restarts
logging/promtail-5jr9j: 6 restarts
logging/promtail-hp5sc: 8 restarts
logging/promtail-m2gzm: 4 restarts
logging/promtail-ng69s: 6 restarts
monitoring/monitoring-prometheus-node-exporter-6dl8r: 176 restarts
monitoring/monitoring-prometheus-node-exporter-6sc8j: 10 restarts
monitoring/monitoring-prometheus-node-exporter-88hp8: 4 restarts
monitoring/monitoring-prometheus-node-exporter-vgp6b: 4 restarts
monitoring/monitoring-prometheus-node-exporter-wmcb8: 47 restarts
synology-csi/synology-csi-node-4nxcz: 8 restarts
synology-csi/synology-csi-node-kxrjb: 17 restarts
synology-csi/synology-csi-node-l72f8: 9 restarts
synology-csi/synology-csi-node-ptwb8: 10 restarts
synology-csi/synology-csi-node-sfdmg: 8 restarts
synology-csi/synology-csi-node-zch7n: 27 restarts

### Recent Warnings (5)
```
velero        9m6s        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1788403901233   Job has reached the specified backoff limit
velero        4m16s       Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1788404191165       Job has reached the specified backoff limit
velero        4m12s       Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1788404196194          Job has reached the specified backoff limit
velero        4m8s        Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1788404200219   Job has reached the specified backoff limit
kube-system   2m12s       Warning   BackOff                pod/kube-proxy-qn8md                                      Back-off restarting failed container kube-proxy in pod kube-proxy-qn8md_kube-system(70ae08f5-7949-459c-9670-ac69c6b03a55)
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
- cnpg (cloudnative-pg-0.29.0) in cnpg-system
- external-secrets (external-secrets-1.1.1) in external-secrets
- ingress-nginx (ingress-nginx-4.15.1) in ingress-nginx
- k8s-agent (gitlab-agent-2.28.0) in REDACTED_01b50c5d
- REDACTED_d97cef76 (REDACTED_d97cef76-7.14.0) in REDACTED_d97cef76
- loki (loki-6.55.0) in logging
- monitoring (REDACTED_d8074874-79.12.0) in monitoring
- nfs-provisioner (REDACTED_5fef70be-4.0.18) in nfs-provisioner
- promtail (promtail-6.17.1) in logging
- seaweedfs (seaweedfs-4.44.0) in seaweedfs
- synology-csi (synology-csi-0.10.1) in synology-csi
- tetragon (tetragon-1.6.0) in kube-system

---
*Lite version - see cluster-context-full.md for complete details*
