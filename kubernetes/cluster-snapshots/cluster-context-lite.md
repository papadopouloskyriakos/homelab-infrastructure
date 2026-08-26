# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-08-26 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: CRITICAL ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 36 |
| Pending PVCs | 0 |
| Total Restarts | 1784 |

## Topology

- **K8s:** v1.36.3 | **CNI:** Cilium 1.20.0
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 187

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:8002696Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8003704Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:16246548Ki | Taints:node.kubernetes.io/unreachable=:NoSchedule,node.kubernetes.io/unreachable=:NoExecute,node.cilium.io/agent-not-ready=:NoSchedule
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:10054404Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:10054404Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:12117776Ki | Taints:none

## Anomalies

### Unhealthy Pods
```
argocd                   argocd-repo-server-7dfc645f84-5sh42                               1/1   Terminating        0                 31h
argocd                   argocd-repo-server-7dfc645f84-vqd64                               1/1   Terminating        0                 31h
awx                      awx-operator-controller-manager-6ffdf98f6-m9gvc                   2/2   Terminating        2 (17h ago)       31h
bentopdf                 bentopdf-85d6d55b9f-697tk                                         1/1   Terminating        0                 31h
cert-manager             cert-manager-webhook-76ccbc5994-t2h2n                             1/1   Terminating        0                 31h
cilium-spire             spire-agent-2xj9z                                                 0/1   CrashLoopBackOff   137 (27s ago)     9d
cilium-spire             spire-agent-bf7g7                                                 0/1   CrashLoopBackOff   139 (4m45s ago)   9d
cilium-spire             spire-agent-hpld8                                                 0/1   CrashLoopBackOff   138 (3m48s ago)   9d
cilium-spire             spire-agent-sm9xs                                                 0/1   CrashLoopBackOff   138 (3m6s ago)    9d
cilium-spire             spire-agent-xk8cl                                                 0/1   CrashLoopBackOff   137 (2m57s ago)   9d
cilium-spire             spire-agent-zqpt4                                                 0/1   CrashLoopBackOff   140 (76s ago)     9d
cilium-spire             spire-server-0                                                    2/2   Terminating        0                 31h
cnpg-system              cnpg-cloudnative-pg-6d8bdc546d-5s4w9                              1/1   Terminating        0                 31h
cnpg-system              cnpg-cloudnative-pg-6d8bdc546d-xtt94                              1/1   Terminating        1 (18h ago)       31h
external-secrets         external-secrets-54bf5f9b8b-fp6f8                                 1/1   Terminating        0                 31h
external-secrets         external-secrets-cert-controller-7b5c8c9659-nhsnq                 1/1   Terminating        0                 31h
external-secrets         external-secrets-webhook-57bfc8987-tqdf7                          1/1   Terminating        0                 31h
REDACTED_01b50c5d   REDACTED_ab04b573-v2-766bfc86f5-5ltjp                        1/1   Terminating        0                 31h
REDACTED_01b50c5d   REDACTED_ab04b573-v2-766bfc86f5-5skcf                        1/1   Terminating        0                 31h
ingress-nginx            ingress-nginx-controller-8445475547-7lbw5                         1/1   Terminating        0                 31h
ingress-nginx            ingress-nginx-controller-8445475547-jxm5f                         1/1   Terminating        0                 31h
kube-system              kube-proxy-qn8md                                                  0/1   CrashLoopBackOff   461 (4m22s ago)   9d
kube-system              tetragon-operator-f674b87f4-m54tx                                 1/1   Terminating        0                 31h
REDACTED_d97cef76     REDACTED_d97cef76-api-5579c66b6b-zvmrl                         1/1   Terminating        0                 31h
REDACTED_d97cef76     REDACTED_d97cef76-auth-8f5d95bd5-v5l8m                         1/1   Terminating        0                 31h
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper-7685fd8b77-6kw9f             1/1   Terminating        0                 31h
REDACTED_d97cef76     REDACTED_d97cef76-web-5c9f966b98-z5brs                         1/1   Terminating        0                 31h
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be-75b84759cfskglb   1/1   Terminating        2 (15h ago)       31h
pihole                   pihole-574d9db4c-qf5hk                                            1/1   Terminating        0                 31h
velero                   node-agent-55hgg                                                  1/1   Terminating        1 (31h ago)       31h
velero                   pihole-default-kopia-maintain-job-1787712389425-skjc9             0/1   Error              0                 14m
velero                   pihole-default-kopia-maintain-job-1787712689426-zs8nx             0/1   Error              0                 9m15s
velero                   pihole-default-kopia-maintain-job-1787712989426-rrq44             0/1   Error              0                 4m15s
velero                   velero-f7fc5f448-z2lbm                                            1/1   Terminating        0                 31h
velero                   velero-ui-687565868b-547hd                                        1/1   Terminating        0                 31h
well-known               well-known-7b9498f5f5-kn7br                                       1/1   Terminating        0                 31h
```

### High Restart Pods (>3)
awx/my-awx-task-756d768868-bslc2: 6 restarts
cilium-spire/spire-agent-2xj9z: 137 restarts
cilium-spire/spire-agent-bf7g7: 139 restarts
cilium-spire/spire-agent-hpld8: 138 restarts
cilium-spire/spire-agent-sm9xs: 138 restarts
cilium-spire/spire-agent-xk8cl: 137 restarts
cilium-spire/spire-agent-zqpt4: 140 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 4 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 6 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 4 restarts
kube-system/kube-proxy-qn8md: 461 restarts
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
cilium-spire   3m40s       Warning   Unhealthy              pod/spire-agent-sm9xs                                 Readiness probe failed: Get "http://10.0.X.X:4251/ready": dial tcp 10.0.X.X:4251: connect: connection refused
cilium-spire   2m27s       Warning   BackOff                pod/spire-agent-hpld8                                 Back-off restarting failed container spire-agent in pod spire-agent-hpld8_cilium-spire(ef3e9277-4925-488d-b6ee-a82b8276764c)
cilium-spire   2m20s       Warning   BackOff                pod/spire-agent-bf7g7                                 Back-off restarting failed container spire-agent in pod spire-agent-bf7g7_cilium-spire(8757e3ca-53e4-4bb6-b853-f0d35385d5b8)
cilium-spire   87s         Warning   Unhealthy              pod/spire-agent-zqpt4                                 Readiness probe failed: HTTP probe failed with statuscode: 500
cilium-spire   79s         Warning   BackOff                pod/spire-agent-2xj9z                                 Back-off restarting failed container spire-agent in pod spire-agent-2xj9z_cilium-spire(0b7ea57c-7260-4278-8017-bcbdca8023c1)
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
