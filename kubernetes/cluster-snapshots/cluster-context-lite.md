# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-10-04 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: DEGRADED ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 5 |
| Pending PVCs | 0 |
| Total Restarts | 3033 |

## Topology

- **K8s:** v1.36.3 | **CNI:** Cilium 1.20.0
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 180

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:8002680Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8003704Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:10054396Ki | Taints:node.kubernetes.io/unschedulable=:NoSchedule
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:10054404Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:10054404Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:10053380Ki | Taints:none

## Anomalies

### Unhealthy Pods
```
cnpg-system              cnpg-janitor-29850683-2pkmh                                       0/1   Error       0                11h
cnpg-system              cnpg-janitor-29850743-gkdfq                                       0/1   Error       0                10h
cnpg-system              cnpg-janitor-29850863-646k4                                       0/1   Error       0                8h
monitoring               meshsat-status-heartbeat-29850312-jbpn8                           0/1   Error       0                17h
velero                   monitoring-default-kopia-maintain-job-1790197917279-s5f69         0/1   Error       0                10d
```

### High Restart Pods (>3)
argocd/argocd-application-controller-0: 29 restarts
awx/awx-operator-controller-manager-6ffdf98f6-8jv8s: 47 restarts
awx/my-awx-task-756d768868-bslc2: 6 restarts
cert-manager/cert-manager-75944f484-k8x88: 18 restarts
cert-manager/cert-manager-cainjector-74f994b988-shnfp: 20 restarts
cilium-spire/spire-agent-2xj9z: 276 restarts
cilium-spire/spire-agent-bf7g7: 278 restarts
cilium-spire/spire-agent-hpld8: 275 restarts
cilium-spire/spire-agent-hrngt: 18 restarts
cilium-spire/spire-agent-sm9xs: 284 restarts
cilium-spire/spire-agent-xk8cl: 280 restarts
cilium-spire/spire-agent-zqpt4: 286 restarts
cnpg-system/cnpg-cloudnative-pg-6d8bdc546d-wzdfh: 32 restarts
cnpg-system/cnpg-cloudnative-pg-6d8bdc546d-zl8gc: 45 restarts
kube-system/cilium-c8kqc: 10 restarts
kube-system/cilium-envoy-brdkr: 8 restarts
kube-system/cilium-envoy-dzx97: 10 restarts
kube-system/cilium-g5h5t: 8 restarts
kube-system/cilium-operator-84c4fb58c7-jlhkp: 64 restarts
kube-system/etcd-nlk8s-ctrl02: 9 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 25 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 16 restarts
kube-system/kube-apiserver-nlk8s-ctrl03: 6 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 47 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 18 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 42 restarts
kube-system/kube-proxy-7jvns: 10 restarts
kube-system/kube-proxy-jvln5: 4 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 39 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 10 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 44 restarts
kube-system/tetragon-5gk99: 9 restarts
kube-system/tetragon-75hdg: 28 restarts
kube-system/tetragon-878gv: 8 restarts
kube-system/tetragon-jz2b6: 12 restarts
kube-system/tetragon-mdsn9: 41 restarts
kube-system/tetragon-tbcc7: 10 restarts
kube-system/tetragon-vbs6v: 18 restarts
kyverno/kyverno-admission-controller-584d7f7684-6k9gg: 45 restarts
kyverno/kyverno-reports-controller-7bbf4b866b-rq8pt: 48 restarts
logging/loki-canary-bbplf: 12 restarts
logging/loki-canary-xbmzr: 4 restarts
logging/promtail-5jr9j: 6 restarts
logging/promtail-br4rf: 5 restarts
logging/promtail-hp5sc: 9 restarts
logging/promtail-m2gzm: 11 restarts
logging/promtail-ng69s: 15 restarts
monitoring/goldpinger-fjpnh: 5 restarts
monitoring/goldpinger-rb96x: 9 restarts
monitoring/goldpinger-t8x65: 10 restarts
monitoring/monitoring-grafana-7d6c5795b8-6cvtn: 16 restarts
monitoring/monitoring-grafana-7d6c5795b8-vbrmn: 7 restarts
monitoring/monitoring-kube-state-metrics-75f9fff55b-prwns: 33 restarts
monitoring/monitoring-prometheus-node-exporter-6dl8r: 185 restarts
monitoring/monitoring-prometheus-node-exporter-6sc8j: 10 restarts
monitoring/monitoring-prometheus-node-exporter-88hp8: 11 restarts
monitoring/monitoring-prometheus-node-exporter-8bq88: 5 restarts
monitoring/monitoring-prometheus-node-exporter-vgp6b: 5 restarts
monitoring/monitoring-prometheus-node-exporter-wmcb8: 47 restarts
nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-75b84759cfvtflq: 58 restarts
synology-csi/synology-csi-node-4nxcz: 8 restarts
synology-csi/synology-csi-node-kxrjb: 19 restarts
synology-csi/synology-csi-node-l72f8: 9 restarts
synology-csi/synology-csi-node-mrqzg: 20 restarts
synology-csi/synology-csi-node-ptwb8: 10 restarts
synology-csi/synology-csi-node-sfdmg: 12 restarts
synology-csi/synology-csi-node-zch7n: 43 restarts
velero/node-agent-54dn2: 8 restarts

### Recent Warnings (5)
```
velero                   9s          Warning   PolicyViolation   pod/weekly-backup-20261004030005-vprcm                                  policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/containers/0/securityContext/allowPrivilegeEscalation/
velero                   9s          Warning   PolicyViolation   pod/weekly-backup-20261004030005-vprcm                                  policy disallow-host-path/host-path fail: validation error: HostPath volumes are forbidden. The field spec.volumes[*].hostPath must be unset. rule host-path failed at path /spec/volumes/0/hostPath/
velero                   9s          Warning   PolicyViolation   pod/weekly-backup-20261004030005-vprcm                                  policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/containers/0/securityContext/runAsNonRoot/
velero                   9s          Warning   PolicyViolation   pod/weekly-backup-20261004030005-vprcm                                  policy require-run-as-non-root-user/run-as-non-root-user fail: validation error: Running as root is not allowed. The fields spec.securityContext.runAsUser, spec.containers[*].securityContext.runAsUser, spec.initContainers[*].securityContext.runAsUser, and spec.ephemeralContainers[*].securityContext.runAsUser must be unset or set to a number greater than zero. rule run-as-non-root-user failed at path /spec/securityContext/runAsUser/
velero                   9s          Warning   PolicyViolation   pod/weekly-backup-20261004030005-vprcm                                  policy restrict-volume-types/restricted-volumes fail: Only the following types of volumes may be used: configMap, csi, downwardAPI, emptyDir, ephemeral, image, REDACTED_33feff97, projected, and secret.
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
