# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-09-22 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: CRITICAL ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 20 |
| Pending PVCs | 0 |
| Total Restarts | 10238 |

## Topology

- **K8s:** v1.36.3 | **CNI:** Cilium 1.20.0
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 193

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:8002696Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8003704Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:10054388Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:10054404Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:10054404Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:10053376Ki | Taints:none

## Anomalies

### Unhealthy Pods
```
awx                      awx-pg-dump-29832735-9kk5w                                        0/1   Error              0                 22h
awx                      awx-pg-dump-29832735-fdmmq                                        0/1   Error              0                 22h
awx                      awx-pg-dump-29832735-jtdwq                                        0/1   Error              0                 22h
kube-system              kube-proxy-qn8md                                                  0/1   CrashLoopBackOff   8012 (4m6s ago)   36d
seaweedfs                seaweedfs-read-canary-29829623-2gd2r                              0/1   Error              0                 3d2h
seaweedfs                seaweedfs-read-canary-29829623-97727                              0/1   Error              0                 3d2h
seaweedfs                seaweedfs-read-canary-29832863-gwmbd                              0/1   Error              0                 20h
seaweedfs                seaweedfs-read-canary-29832863-htcqz                              0/1   Error              0                 20h
seaweedfs                seaweedfs-read-canary-29833223-gbcmb                              0/1   Error              0                 14h
seaweedfs                seaweedfs-read-canary-29833223-wgggp                              0/1   Error              0                 14h
seaweedfs                seaweedfs-reconciler-29833637-ptt2r                               0/1   Error              0                 7h43m
velero                   awx-default-kopia-maintain-job-1790045208808-6p4cf                0/1   Error              0                 14m
velero                   awx-default-kopia-maintain-job-1790045512851-vf72b                0/1   Error              0                 9m1s
velero                   awx-default-kopia-maintain-job-1790045808810-6qbx8                0/1   Error              0                 4m5s
velero                   monitoring-default-kopia-maintain-job-1790045213883-brg5z         0/1   Error              0                 14m
velero                   monitoring-default-kopia-maintain-job-1790045516892-pphnq         0/1   Error              0                 8m57s
velero                   monitoring-default-kopia-maintain-job-1790045812860-jj6d6         0/1   Error              0                 4m1s
velero                   pihole-default-kopia-maintain-job-1790045218925-nkw5v             0/1   Error              0                 13m
velero                   pihole-default-kopia-maintain-job-1790045508809-q4k27             0/1   Error              0                 9m5s
velero                   pihole-default-kopia-maintain-job-1790045816897-6kj82             0/1   Error              0                 3m57s
```

### High Restart Pods (>3)
argocd/argocd-application-controller-0: 5 restarts
awx/awx-operator-controller-manager-6ffdf98f6-x8jtt: 12 restarts
awx/my-awx-task-756d768868-bslc2: 6 restarts
cilium-spire/spire-agent-2xj9z: 258 restarts
cilium-spire/spire-agent-bf7g7: 262 restarts
cilium-spire/spire-agent-hpld8: 259 restarts
cilium-spire/spire-agent-hrngt: 5 restarts
cilium-spire/spire-agent-sm9xs: 259 restarts
cilium-spire/spire-agent-xk8cl: 258 restarts
cilium-spire/spire-agent-zqpt4: 264 restarts
cnpg-system/cnpg-cloudnative-pg-6d8bdc546d-zl8gc: 7 restarts
kube-system/cilium-c8kqc: 5 restarts
kube-system/cilium-envoy-brdkr: 4 restarts
kube-system/cilium-envoy-dzx97: 5 restarts
kube-system/cilium-g5h5t: 4 restarts
kube-system/cilium-operator-84c4fb58c7-jlhkp: 13 restarts
kube-system/etcd-nlk8s-ctrl02: 5 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 14 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 11 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 9 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 7 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 9 restarts
kube-system/kube-proxy-7jvns: 5 restarts
kube-system/kube-proxy-qn8md: 8012 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 6 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 5 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 9 restarts
kube-system/tetragon-5gk99: 9 restarts
kube-system/tetragon-75hdg: 18 restarts
kube-system/tetragon-878gv: 8 restarts
kube-system/tetragon-jz2b6: 10 restarts
kube-system/tetragon-mdsn9: 35 restarts
kube-system/tetragon-tbcc7: 10 restarts
kube-system/tetragon-vbs6v: 16 restarts
kyverno/kyverno-reports-controller-7bbf4b866b-2ccd2: 4 restarts
logging/loki-canary-bbplf: 7 restarts
logging/promtail-5jr9j: 6 restarts
logging/promtail-br4rf: 4 restarts
logging/promtail-hp5sc: 8 restarts
logging/promtail-m2gzm: 7 restarts
logging/promtail-ng69s: 10 restarts
monitoring/goldpinger-fjpnh: 4 restarts
monitoring/goldpinger-rb96x: 5 restarts
monitoring/goldpinger-t8x65: 5 restarts
monitoring/monitoring-grafana-7d6c5795b8-6cvtn: 6 restarts
monitoring/monitoring-prometheus-node-exporter-6dl8r: 180 restarts
monitoring/monitoring-prometheus-node-exporter-6sc8j: 10 restarts
monitoring/monitoring-prometheus-node-exporter-88hp8: 7 restarts
monitoring/monitoring-prometheus-node-exporter-8bq88: 4 restarts
monitoring/monitoring-prometheus-node-exporter-vgp6b: 4 restarts
monitoring/monitoring-prometheus-node-exporter-wmcb8: 47 restarts
monitoring/prometheus-REDACTED_6dfbe9fc-0: 4 restarts
nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-75b84759cfvtflq: 6 restarts
synology-csi/synology-csi-node-4nxcz: 8 restarts
synology-csi/synology-csi-node-kxrjb: 17 restarts
synology-csi/synology-csi-node-l72f8: 9 restarts
synology-csi/synology-csi-node-mrqzg: 10 restarts
synology-csi/synology-csi-node-ptwb8: 10 restarts
synology-csi/synology-csi-node-sfdmg: 10 restarts
synology-csi/synology-csi-node-zch7n: 35 restarts

### Recent Warnings (5)
```
velero                   8m54s       Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1790045516892                 Job has reached the specified backoff limit
velero                   4m3s        Warning   BackoffLimitExceeded   job/awx-default-kopia-maintain-job-1790045808810                        Job has reached the specified backoff limit
velero                   3m59s       Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1790045812860                 Job has reached the specified backoff limit
velero                   3m54s       Warning   BackoffLimitExceeded   job/pihole-default-kopia-maintain-job-1790045816897                     Job has reached the specified backoff limit
kube-system              98s         Warning   Unhealthy              pod/kube-apiserver-nlk8s-ctrl01                                   Readiness probe failed: HTTP probe failed with statuscode: 500
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
- kyverno (kyverno-3.9.1) in kyverno
- kyverno-policies (kyverno-policies-3.9.1) in kyverno
- loki (loki-6.55.0) in logging
- metrics-server (metrics-server-3.14.0) in kube-system
- monitoring (REDACTED_d8074874-79.12.0) in monitoring
- nfs-provisioner (REDACTED_5fef70be-4.0.18) in nfs-provisioner
- promtail (promtail-6.17.1) in logging
- reloader (reloader-2.2.17) in reloader
- seaweedfs (seaweedfs-4.44.0) in seaweedfs
- synology-csi (synology-csi-0.10.1) in synology-csi
- tetragon (tetragon-1.6.0) in kube-system

---
*Lite version - see cluster-context-full.md for complete details*
