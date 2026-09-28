# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-09-28 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: CRITICAL ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 24 |
| Pending PVCs | 0 |
| Total Restarts | 2320 |

## Topology

- **K8s:** v1.36.3 | **CNI:** Cilium 1.20.0
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 195

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:8002680Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8003704Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:10054388Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:10054404Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:10054404Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:10053380Ki | Taints:none

## Anomalies

### Unhealthy Pods
```
awx                      awx-pg-dump-29832735-9kk5w                                        0/1   Error       0                 6d22h
awx                      awx-pg-dump-29832735-fdmmq                                        0/1   Error       0                 6d22h
awx                      awx-pg-dump-29832735-jtdwq                                        0/1   Error       0                 6d22h
awx                      awx-pg-dump-29834175-7k7j8                                        0/1   Error       0                 5d22h
awx                      awx-pg-dump-29834175-h4bmp                                        0/1   Error       0                 5d22h
awx                      awx-pg-dump-29834175-hslcb                                        0/1   Error       0                 5d22h
awx                      awx-pg-dump-29835615-jsf4r                                        0/1   Error       0                 4d22h
awx                      awx-pg-dump-29835615-sk6jx                                        0/1   Error       0                 4d22h
awx                      awx-pg-dump-29835615-xjwgx                                        0/1   Error       0                 4d22h
cnpg-system              cnpg-janitor-29842283-x2xd8                                       0/1   Error       0                 7h37m
cnpg-system              cnpg-janitor-29842403-7dj6d                                       0/1   Error       0                 5h37m
cnpg-system              cnpg-janitor-29842523-qfwsw                                       0/1   Error       0                 3h37m
monitoring               meshsat-status-heartbeat-29842285-9w5jn                           0/1   Error       0                 7h35m
monitoring               meshsat-status-heartbeat-29842286-24n7c                           0/1   Error       0                 7h34m
monitoring               meshsat-status-heartbeat-29842341-rcznt                           0/1   Error       0                 6h39m
velero                   awx-default-kopia-maintain-job-1790197609192-kgk5z                0/1   Error       0                 4d5h
velero                   awx-default-kopia-maintain-job-1790197913232-l749m                0/1   Error       0                 4d5h
velero                   awx-default-kopia-maintain-job-1790198218290-d2g6j                0/1   Error       0                 4d5h
velero                   monitoring-default-kopia-maintain-job-1790197613242-pc7bq         0/1   Error       0                 4d5h
velero                   monitoring-default-kopia-maintain-job-1790197917279-s5f69         0/1   Error       0                 4d5h
velero                   monitoring-default-kopia-maintain-job-1790198209194-96r7j         0/1   Error       0                 4d5h
velero                   pihole-default-kopia-maintain-job-1790197618280-wvmf6             0/1   Error       0                 4d5h
velero                   pihole-default-kopia-maintain-job-1790197909193-mxplz             0/1   Error       0                 4d5h
velero                   pihole-default-kopia-maintain-job-1790198213248-gg9tr             0/1   Error       0                 4d5h
```

### High Restart Pods (>3)
argocd/argocd-application-controller-0: 16 restarts
awx/my-awx-task-756d768868-bslc2: 6 restarts
cilium-spire/spire-agent-2xj9z: 265 restarts
cilium-spire/spire-agent-bf7g7: 263 restarts
cilium-spire/spire-agent-hpld8: 260 restarts
cilium-spire/spire-agent-hrngt: 13 restarts
cilium-spire/spire-agent-sm9xs: 269 restarts
cilium-spire/spire-agent-xk8cl: 266 restarts
cilium-spire/spire-agent-zqpt4: 271 restarts
cnpg-system/cnpg-cloudnative-pg-6d8bdc546d-zl8gc: 7 restarts
kube-system/cilium-c8kqc: 5 restarts
kube-system/cilium-envoy-brdkr: 4 restarts
kube-system/cilium-envoy-dzx97: 5 restarts
kube-system/cilium-g5h5t: 4 restarts
kube-system/cilium-operator-84c4fb58c7-jlhkp: 15 restarts
kube-system/etcd-nlk8s-ctrl02: 5 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 22 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 12 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 15 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 12 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 10 restarts
kube-system/kube-proxy-7jvns: 5 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 8 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 5 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 11 restarts
kube-system/tetragon-5gk99: 9 restarts
kube-system/tetragon-75hdg: 18 restarts
kube-system/tetragon-878gv: 8 restarts
kube-system/tetragon-jz2b6: 12 restarts
kube-system/tetragon-mdsn9: 35 restarts
kube-system/tetragon-tbcc7: 10 restarts
kube-system/tetragon-vbs6v: 18 restarts
kyverno/kyverno-reports-controller-7bbf4b866b-2ccd2: 4 restarts
logging/loki-0: 5 restarts
logging/loki-canary-bbplf: 7 restarts
logging/loki-canary-xbmzr: 4 restarts
logging/promtail-5jr9j: 6 restarts
logging/promtail-br4rf: 5 restarts
logging/promtail-hp5sc: 9 restarts
logging/promtail-m2gzm: 7 restarts
logging/promtail-ng69s: 10 restarts
monitoring/bgpalerter-b7bc9c8c-j5mgh: 6 restarts
monitoring/goldpinger-fjpnh: 5 restarts
monitoring/goldpinger-rb96x: 5 restarts
monitoring/goldpinger-t8x65: 5 restarts
monitoring/monitoring-grafana-7d6c5795b8-6cvtn: 11 restarts
monitoring/monitoring-prometheus-node-exporter-6dl8r: 180 restarts
monitoring/monitoring-prometheus-node-exporter-6sc8j: 10 restarts
monitoring/monitoring-prometheus-node-exporter-88hp8: 7 restarts
monitoring/monitoring-prometheus-node-exporter-8bq88: 5 restarts
monitoring/monitoring-prometheus-node-exporter-vgp6b: 5 restarts
monitoring/monitoring-prometheus-node-exporter-wmcb8: 47 restarts
nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-75b84759cfvtflq: 9 restarts
synology-csi/synology-csi-node-4nxcz: 8 restarts
synology-csi/synology-csi-node-kxrjb: 19 restarts
synology-csi/synology-csi-node-l72f8: 9 restarts
synology-csi/synology-csi-node-mrqzg: 10 restarts
synology-csi/synology-csi-node-ptwb8: 10 restarts
synology-csi/synology-csi-node-sfdmg: 12 restarts
synology-csi/synology-csi-node-zch7n: 35 restarts

### Recent Warnings (5)
```
velero                   58m         Warning   PolicyViolation   deployment/velero-ui                                                    policy restrict-seccomp-strict/autogen-check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule autogen-check-seccomp-strict[0] failed at path /spec/template/spec/securityContext/seccompProfile/ rule autogen-check-seccomp-strict[1] failed at path /spec/template/spec/containers/0/securityContext/
kube-system              60m         Warning   Unhealthy         pod/etcd-nlk8s-ctrl01                                             Readiness probe failed: Get "http://127.0.0.1:2381/readyz": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
kube-system              60m         Warning   Unhealthy         pod/etcd-nlk8s-ctrl01                                             Liveness probe failed: Get "http://127.0.0.1:2381/livez": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
monitoring               16m         Warning   Unhealthy         pod/bgpalerter-b7bc9c8c-j5mgh                                           Readiness probe failed: Get "http://10.0.2.34:8011/status": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
kube-system              14m         Warning   Unhealthy         pod/kube-apiserver-nlk8s-ctrl01                                   Liveness probe failed: HTTP probe failed with statuscode: 500
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
