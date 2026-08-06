# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-08-06 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: CRITICAL ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 81 |
| Pending PVCs | 0 |
| Total Restarts | 3236 |

## Topology

- **K8s:** v1.34.2 | **CNI:** Cilium 1.19.5
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 202

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:8005928Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8006944Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule,node.kubernetes.io/unreachable=:NoSchedule,node.cilium.io/agent-not-ready=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:8005712Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:8006756Ki | Taints:node.kubernetes.io/unreachable=:NoSchedule,node.kubernetes.io/unreachable=:NoExecute,node.cilium.io/agent-not-ready=:NoSchedule
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:8006732Ki | Taints:node.kubernetes.io/unreachable=:NoSchedule,node.cilium.io/agent-not-ready=:NoSchedule,node.kubernetes.io/unreachable=:NoExecute
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:8006740Ki | Taints:node.kubernetes.io/unreachable=:NoSchedule,node.cilium.io/agent-not-ready=:NoSchedule,node.kubernetes.io/unreachable=:NoExecute

## Anomalies

### Unhealthy Pods
```
argocd                   argocd-application-controller-0                                   1/1   Terminating   0                  50d
argocd                   argocd-applicationset-controller-db66f5cb8-lmhs9                  0/1   Pending       0                  5m28s
argocd                   argocd-applicationset-controller-db66f5cb8-m8fkh                  1/1   Terminating   0                  144d
argocd                   argocd-notifications-controller-64789ccc8b-26cvm                  1/1   Terminating   0                  144d
argocd                   argocd-repo-server-7dfc645f84-84ld8                               0/1   Pending       0                  5m43s
argocd                   argocd-repo-server-7dfc645f84-npgtw                               1/1   Terminating   0                  87d
argocd                   argocd-repo-server-7dfc645f84-q6mbm                               0/1   Pending       0                  5m28s
argocd                   argocd-repo-server-7dfc645f84-qxz64                               1/1   Terminating   5 (7d23h ago)      87d
argocd                   argocd-server-64dd47d8bf-fkr26                                    1/1   Terminating   37 (51m ago)       29d
argocd                   argocd-server-64dd47d8bf-lk5rz                                    0/1   Pending       0                  5m29s
argocd                   argocd-server-64dd47d8bf-pn46c                                    0/1   Pending       0                  5m39s
argocd                   argocd-server-64dd47d8bf-wsbcr                                    1/1   Terminating   0                  143d
awx                      awx-operator-controller-manager-6ffdf98f6-hwvqf                   2/2   Terminating   20 (33m ago)       30d
awx                      my-awx-postgres-15-0                                              1/1   Terminating   0                  144d
awx                      my-awx-task-756d768868-k9sdd                                      4/4   Terminating   0                  132d
awx                      my-awx-task-756d768868-xs8gc                                      0/4   Pending       0                  5m28s
bentopdf                 bentopdf-85d6d55b9f-5mnjl                                         0/1   Pending       0                  5m43s
bentopdf                 bentopdf-85d6d55b9f-kfqzn                                         1/1   Terminating   1 (8d ago)         87d
cert-manager             cert-manager-75944f484-kg87v                                      1/1   Terminating   1 (18d ago)        29d
cert-manager             cert-manager-75944f484-vtvg7                                      0/1   Pending       0                  5m27s
cert-manager             cert-manager-cainjector-56b4cf957-5lxjh                           1/1   Terminating   3 (32m ago)        131d
cert-manager             cert-manager-webhook-5556f58976-95h7t                             1/1   Terminating   0                  131d
cilium-spire             spire-server-0                                                    2/2   Terminating   18 (51m ago)       29d
echo-server              echo-server-7b46895b56-fmz6l                                      1/1   Terminating   0                  143d
external-secrets         external-secrets-54bf5f9b8b-k7sk7                                 1/1   Terminating   0                  87d
external-secrets         external-secrets-54bf5f9b8b-rlbmf                                 0/1   Pending       0                  5m42s
external-secrets         external-secrets-cert-controller-785c7fcd8d-djx4f                 1/1   Terminating   0                  131d
external-secrets         external-secrets-webhook-69865bf7cd-mgrcc                         1/1   Terminating   0                  131d
REDACTED_01b50c5d   REDACTED_ab04b573-v2-8c85f5d4b-gdw9r                         1/1   Terminating   3 (7d23h ago)      29d
REDACTED_01b50c5d   REDACTED_ab04b573-v2-8c85f5d4b-ng8lb                         1/1   Terminating   26 (51m ago)       29d
ingress-nginx            ingress-nginx-controller-8445475547-52656                         0/1   Pending       0                  5m42s
ingress-nginx            ingress-nginx-controller-8445475547-bwczk                         1/1   Terminating   33 (19m ago)       4d19h
ingress-nginx            ingress-nginx-controller-8445475547-lk4fg                         0/1   Pending       0                  5m28s
ingress-nginx            ingress-nginx-controller-8445475547-mxdrc                         1/1   Terminating   30 (5d20h ago)     29d
kube-system              clustermesh-apiserver-6c96779765-rmrzt                            3/3   Terminating   46 (33m ago)       29d
kube-system              hubble-relay-7bc7f44865-glwjd                                     1/1   Terminating   0                  29d
kube-system              hubble-ui-6bb97d8894-nnkx5                                        2/2   Terminating   23 (51m ago)       29d
kube-system              metrics-server-56fb9549f4-kmrv4                                   1/1   Terminating   0                  131d
kube-system              tetragon-operator-f674b87f4-b29hg                                 1/1   Terminating   2 (8d ago)         87d
kube-system              tetragon-operator-f674b87f4-xdwhj                                 0/1   Pending       0                  5m43s
REDACTED_d97cef76     REDACTED_d97cef76-api-5579c66b6b-qw9sf                         0/1   Pending       0                  5m28s
REDACTED_d97cef76     REDACTED_d97cef76-api-5579c66b6b-ws62l                         1/1   Terminating   0                  87d
REDACTED_d97cef76     REDACTED_d97cef76-auth-8f5d95bd5-6f45d                         1/1   Terminating   0                  87d
REDACTED_d97cef76     REDACTED_d97cef76-auth-8f5d95bd5-r7ssq                         0/1   Pending       0                  5m43s
REDACTED_d97cef76     REDACTED_d97cef76-kong-5c7f96dd9b-fgxd9                        1/1   Terminating   15 (50m ago)       29d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper-7685fd8b77-4g7qc             0/1   Pending       0                  5m43s
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper-7685fd8b77-f8fpp             1/1   Terminating   0                  87d
REDACTED_d97cef76     REDACTED_d97cef76-web-5c9f966b98-7t7jd                         1/1   Terminating   0                  87d
monitoring               alertmanager-monitoring-kube-prometheus-alertmanager-0            2/2   Terminating   0                  19d
monitoring               bgpalerter-789f984488-jpkvh                                       1/1   Terminating   0                  6d4h
monitoring               bgpalerter-789f984488-w9nx8                                       0/1   Pending       0                  5m42s
monitoring               monitoring-grafana-b54c68dbb-7jfds                                0/3   Pending       0                  5m39s
monitoring               monitoring-grafana-b54c68dbb-khbn6                                3/3   Terminating   4 (32m ago)        41d
monitoring               monitoring-grafana-b54c68dbb-vg8lv                                0/3   Pending       0                  5m30s
monitoring               monitoring-grafana-b54c68dbb-zxvjx                                3/3   Terminating   0                  6d3h
monitoring               monitoring-kube-prometheus-operator-67d8d4c647-5955s              1/1   Terminating   40 (51m ago)       30d
monitoring               monitoring-kube-state-metrics-75f9fff55b-6cc8x                    1/1   Terminating   7 (7d23h ago)      116d
monitoring               prometheus-REDACTED_6dfbe9fc-0                3/3   Terminating   15 (24h ago)       30d
monitoring               thanos-compactor-0                                                1/1   Terminating   0                  29d
monitoring               thanos-query-64dfd687dd-9rkgd                                     1/1   Terminating   0                  87d
monitoring               thanos-query-64dfd687dd-gz5p8                                     0/1   Pending       0                  5m29s
monitoring               thanos-query-64dfd687dd-r6xnk                                     0/1   Pending       0                  5m43s
monitoring               thanos-query-64dfd687dd-xv9cv                                     1/1   Terminating   0                  29d
monitoring               thanos-store-0                                                    1/1   Terminating   0                  29d
monitoring               thanos-store-1                                                    1/1   Terminating   0                  50d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be-84888b4956jjmld   1/1   Terminating   54 (22h ago)       29d
pihole                   pihole-fb8b7b6df-l5mcx                                            0/1   Pending       0                  5m45s
pihole                   pihole-fb8b7b6df-xc84w                                            1/1   Terminating   1 (8d ago)         87d
seaweedfs                seaweedfs-filer-0                                                 1/1   Terminating   0                  5d
seaweedfs                seaweedfs-filer-1                                                 1/1   Terminating   3 (22h ago)        5d
seaweedfs                seaweedfs-filer-sync-f7489458c-fjr68                              1/1   Terminating   0                  6d3h
seaweedfs                seaweedfs-filer-sync-f7489458c-tgvcj                              0/1   Pending       0                  5m27s
seaweedfs                seaweedfs-master-0                                                1/1   Terminating   0                  5d
seaweedfs                seaweedfs-master-1                                                1/1   Terminating   0                  5d
seaweedfs                seaweedfs-master-2                                                1/1   Terminating   0                  5d
seaweedfs                seaweedfs-volume-0                                                1/1   Terminating   0                  5d
seaweedfs                seaweedfs-volume-1                                                1/1   Terminating   0                  5d
synology-csi             synology-csi-controller-0                                         4/4   Terminating   0                  131d
velero                   velero-ui-687565868b-57tld                                        0/1   Pending       0                  5m43s
velero                   velero-ui-687565868b-dsgsb                                        1/1   Terminating   2 (8d ago)         87d
well-known               well-known-7b9498f5f5-57cjq                                       1/1   Terminating   0                  87d
```

### High Restart Pods (>3)
argocd/argocd-repo-server-7dfc645f84-qxz64: 5 restarts
argocd/argocd-server-64dd47d8bf-fkr26: 37 restarts
awx/awx-operator-controller-manager-6ffdf98f6-hwvqf: 20 restarts
cilium-spire/spire-agent-49g4h: 28 restarts
cilium-spire/spire-agent-mdslp: 8 restarts
cilium-spire/spire-server-0: 18 restarts
REDACTED_01b50c5d/REDACTED_ab04b573-v2-8c85f5d4b-ng8lb: 26 restarts
ingress-nginx/ingress-nginx-controller-8445475547-bwczk: 33 restarts
ingress-nginx/ingress-nginx-controller-8445475547-mxdrc: 30 restarts
kube-system/cilium-operator-6cdbfb68d7-z6v2x: 11 restarts
kube-system/clustermesh-apiserver-6c96779765-rmrzt: 46 restarts
kube-system/etcd-nlk8s-ctrl01: 64 restarts
kube-system/hubble-ui-6bb97d8894-nnkx5: 23 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 1999 restarts
kube-system/kube-apiserver-nlk8s-ctrl02: 58 restarts
kube-system/kube-apiserver-nlk8s-ctrl03: 15 restarts
kube-system/kube-controller-manager-nlk8s-ctrl01: 109 restarts
kube-system/kube-controller-manager-nlk8s-ctrl02: 37 restarts
kube-system/kube-controller-manager-nlk8s-ctrl03: 93 restarts
kube-system/kube-scheduler-nlk8s-ctrl01: 38 restarts
kube-system/kube-scheduler-nlk8s-ctrl02: 35 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 40 restarts
kube-system/tetragon-75hdg: 6 restarts
kube-system/tetragon-878gv: 4 restarts
kube-system/tetragon-mdsn9: 18 restarts
kube-system/tetragon-tbcc7: 4 restarts
kube-system/tetragon-vbs6v: 14 restarts
REDACTED_d97cef76/REDACTED_d97cef76-kong-5c7f96dd9b-fgxd9: 15 restarts
logging/promtail-hp5sc: 7 restarts
logging/promtail-ng69s: 4 restarts
monitoring/goldpinger-25hf5: 46 restarts
monitoring/goldpinger-6dj9l: 25 restarts
monitoring/goldpinger-n2fzm: 8 restarts
monitoring/goldpinger-zxtb9: 6 restarts
monitoring/monitoring-grafana-b54c68dbb-khbn6: 4 restarts
monitoring/monitoring-kube-prometheus-operator-67d8d4c647-5955s: 40 restarts
monitoring/monitoring-kube-state-metrics-75f9fff55b-6cc8x: 7 restarts
monitoring/monitoring-prometheus-node-exporter-6dl8r: 174 restarts
monitoring/monitoring-prometheus-node-exporter-6sc8j: 7 restarts
monitoring/monitoring-prometheus-node-exporter-wmcb8: 44 restarts
monitoring/prometheus-REDACTED_6dfbe9fc-0: 15 restarts
nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956jjmld: 54 restarts
synology-csi/synology-csi-node-577mq: 10 restarts
synology-csi/synology-csi-node-kxrjb: 14 restarts
synology-csi/synology-csi-node-l72f8: 4 restarts
synology-csi/synology-csi-node-ptwb8: 4 restarts
synology-csi/synology-csi-node-zch7n: 18 restarts

### Recent Warnings (5)
```
argocd                   10m         Warning   NodeNotReady        pod/argocd-repo-server-7dfc645f84-npgtw                               Node is not ready
external-secrets         10m         Warning   NodeNotReady        pod/external-secrets-cert-controller-785c7fcd8d-djx4f                 Node is not ready
kube-system              10m         Warning   NodeNotReady        pod/cilium-envoy-xvgv4                                                Node is not ready
echo-server              10m         Warning   NodeNotReady        pod/echo-server-7b46895b56-fmz6l                                      Node is not ready
monitoring               5m36s       Warning   Unhealthy           pod/monitoring-kube-prometheus-operator-67d8d4c647-gzzrv              Readiness probe failed: Get "https://10.0.2.152:10250/healthz": dial tcp 10.0.2.152:10250: connect: connection refused
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
- cilium (cilium-1.19.5) in kube-system
- external-secrets (external-secrets-1.1.1) in external-secrets
- ingress-nginx (ingress-nginx-4.15.1) in ingress-nginx
- k8s-agent (gitlab-agent-2.28.0) in REDACTED_01b50c5d
- REDACTED_d97cef76 (REDACTED_d97cef76-7.14.0) in REDACTED_d97cef76
- loki (loki-6.55.0) in logging
- monitoring (REDACTED_d8074874-79.12.0) in monitoring
- nfs-provisioner (REDACTED_5fef70be-4.0.18) in nfs-provisioner
- promtail (promtail-6.17.1) in logging
- seaweedfs (seaweedfs-4.0.401) in seaweedfs
- synology-csi (synology-csi-0.10.1) in synology-csi
- tetragon (tetragon-1.6.0) in kube-system

---
*Lite version - see cluster-context-full.md for complete details*
