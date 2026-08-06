# Kubernetes Cluster Context (Full)
<!-- 
LLM INSTRUCTIONS:
- Comprehensive cluster snapshot for deep analysis/troubleshooting
- Health Summary: Check first for cluster state
- Anomalies: Items requiring immediate attention
- Workload Map: Deployment → Service → Ingress relationships
- Resource Analysis: Capacity planning data
- Network Policies: Zero-trust security posture
-->

**Generated:** 2026-08-06 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | CRITICAL | ⚠️ |
| Unhealthy Pods | 81 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 3236 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.19.5 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 202 |

### Node Details (with Taints & Labels)

#### nlk8s-ctrl01
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 8005928Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-ctrl02
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 8092Mi
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-ctrl03
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** Unknown
- **CPU:** 4 | **Memory:** 8006944Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule, node.kubernetes.io/unreachable=:NoSchedule, node.cilium.io/agent-not-ready=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node01
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8005712Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node02
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** Unknown
- **CPU:** 8 | **Memory:** 8006756Ki
- **Taints:** node.kubernetes.io/unreachable=:NoSchedule, node.kubernetes.io/unreachable=:NoExecute, node.cilium.io/agent-not-ready=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node03
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** Unknown
- **CPU:** 8 | **Memory:** 8006732Ki
- **Taints:** node.kubernetes.io/unreachable=:NoSchedule, node.cilium.io/agent-not-ready=:NoSchedule, node.kubernetes.io/unreachable=:NoExecute
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node04
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** Unknown
- **CPU:** 8 | **Memory:** 8006740Ki
- **Taints:** node.kubernetes.io/unreachable=:NoSchedule, node.cilium.io/agent-not-ready=:NoSchedule, node.kubernetes.io/unreachable=:NoExecute
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01


---

## Anomalies & Issues

### Unhealthy Pods
```
argocd                   argocd-application-controller-0                                   1/1   Terminating   0                  50d
argocd                   argocd-applicationset-controller-db66f5cb8-lmhs9                  0/1   Pending       0                  5m36s
argocd                   argocd-applicationset-controller-db66f5cb8-m8fkh                  1/1   Terminating   0                  144d
argocd                   argocd-notifications-controller-64789ccc8b-26cvm                  1/1   Terminating   0                  144d
argocd                   argocd-repo-server-7dfc645f84-84ld8                               0/1   Pending       0                  5m51s
argocd                   argocd-repo-server-7dfc645f84-npgtw                               1/1   Terminating   0                  87d
argocd                   argocd-repo-server-7dfc645f84-q6mbm                               0/1   Pending       0                  5m36s
argocd                   argocd-repo-server-7dfc645f84-qxz64                               1/1   Terminating   5 (7d23h ago)      87d
argocd                   argocd-server-64dd47d8bf-fkr26                                    1/1   Terminating   37 (51m ago)       29d
argocd                   argocd-server-64dd47d8bf-lk5rz                                    0/1   Pending       0                  5m37s
argocd                   argocd-server-64dd47d8bf-pn46c                                    0/1   Pending       0                  5m47s
argocd                   argocd-server-64dd47d8bf-wsbcr                                    1/1   Terminating   0                  143d
awx                      awx-operator-controller-manager-6ffdf98f6-hwvqf                   2/2   Terminating   20 (33m ago)       30d
awx                      my-awx-postgres-15-0                                              1/1   Terminating   0                  144d
awx                      my-awx-task-756d768868-k9sdd                                      4/4   Terminating   0                  132d
awx                      my-awx-task-756d768868-xs8gc                                      0/4   Pending       0                  5m36s
bentopdf                 bentopdf-85d6d55b9f-5mnjl                                         0/1   Pending       0                  5m51s
bentopdf                 bentopdf-85d6d55b9f-kfqzn                                         1/1   Terminating   1 (8d ago)         87d
cert-manager             cert-manager-75944f484-kg87v                                      1/1   Terminating   1 (18d ago)        29d
cert-manager             cert-manager-75944f484-vtvg7                                      0/1   Pending       0                  5m35s
cert-manager             cert-manager-cainjector-56b4cf957-5lxjh                           1/1   Terminating   3 (33m ago)        131d
cert-manager             cert-manager-webhook-5556f58976-95h7t                             1/1   Terminating   0                  131d
cilium-spire             spire-server-0                                                    2/2   Terminating   18 (51m ago)       29d
echo-server              echo-server-7b46895b56-fmz6l                                      1/1   Terminating   0                  143d
external-secrets         external-secrets-54bf5f9b8b-k7sk7                                 1/1   Terminating   0                  87d
external-secrets         external-secrets-54bf5f9b8b-rlbmf                                 0/1   Pending       0                  5m50s
external-secrets         external-secrets-cert-controller-785c7fcd8d-djx4f                 1/1   Terminating   0                  131d
external-secrets         external-secrets-webhook-69865bf7cd-mgrcc                         1/1   Terminating   0                  131d
REDACTED_01b50c5d   REDACTED_ab04b573-v2-8c85f5d4b-gdw9r                         1/1   Terminating   3 (7d23h ago)      29d
REDACTED_01b50c5d   REDACTED_ab04b573-v2-8c85f5d4b-ng8lb                         1/1   Terminating   26 (51m ago)       29d
ingress-nginx            ingress-nginx-controller-8445475547-52656                         0/1   Pending       0                  5m50s
ingress-nginx            ingress-nginx-controller-8445475547-bwczk                         1/1   Terminating   33 (19m ago)       4d19h
ingress-nginx            ingress-nginx-controller-8445475547-lk4fg                         0/1   Pending       0                  5m36s
ingress-nginx            ingress-nginx-controller-8445475547-mxdrc                         1/1   Terminating   30 (5d20h ago)     29d
kube-system              clustermesh-apiserver-6c96779765-rmrzt                            3/3   Terminating   46 (33m ago)       29d
kube-system              hubble-relay-7bc7f44865-glwjd                                     1/1   Terminating   0                  29d
kube-system              hubble-ui-6bb97d8894-nnkx5                                        2/2   Terminating   23 (51m ago)       29d
kube-system              metrics-server-56fb9549f4-kmrv4                                   1/1   Terminating   0                  131d
kube-system              tetragon-operator-f674b87f4-b29hg                                 1/1   Terminating   2 (8d ago)         87d
kube-system              tetragon-operator-f674b87f4-xdwhj                                 0/1   Pending       0                  5m51s
REDACTED_d97cef76     REDACTED_d97cef76-api-5579c66b6b-qw9sf                         0/1   Pending       0                  5m36s
REDACTED_d97cef76     REDACTED_d97cef76-api-5579c66b6b-ws62l                         1/1   Terminating   0                  87d
REDACTED_d97cef76     REDACTED_d97cef76-auth-8f5d95bd5-6f45d                         1/1   Terminating   0                  87d
REDACTED_d97cef76     REDACTED_d97cef76-auth-8f5d95bd5-r7ssq                         0/1   Pending       0                  5m51s
REDACTED_d97cef76     REDACTED_d97cef76-kong-5c7f96dd9b-fgxd9                        1/1   Terminating   15 (51m ago)       29d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper-7685fd8b77-4g7qc             0/1   Pending       0                  5m51s
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper-7685fd8b77-f8fpp             1/1   Terminating   0                  87d
REDACTED_d97cef76     REDACTED_d97cef76-web-5c9f966b98-7t7jd                         1/1   Terminating   0                  87d
monitoring               alertmanager-monitoring-kube-prometheus-alertmanager-0            2/2   Terminating   0                  19d
monitoring               bgpalerter-789f984488-jpkvh                                       1/1   Terminating   0                  6d4h
monitoring               bgpalerter-789f984488-w9nx8                                       0/1   Pending       0                  5m50s
monitoring               monitoring-grafana-b54c68dbb-7jfds                                0/3   Pending       0                  5m47s
monitoring               monitoring-grafana-b54c68dbb-khbn6                                3/3   Terminating   4 (32m ago)        41d
monitoring               monitoring-grafana-b54c68dbb-vg8lv                                0/3   Pending       0                  5m38s
monitoring               monitoring-grafana-b54c68dbb-zxvjx                                3/3   Terminating   0                  6d3h
monitoring               monitoring-kube-prometheus-operator-67d8d4c647-5955s              1/1   Terminating   40 (51m ago)       30d
monitoring               monitoring-kube-state-metrics-75f9fff55b-6cc8x                    1/1   Terminating   7 (7d23h ago)      116d
monitoring               prometheus-REDACTED_6dfbe9fc-0                3/3   Terminating   15 (24h ago)       30d
monitoring               thanos-compactor-0                                                1/1   Terminating   0                  29d
monitoring               thanos-query-64dfd687dd-9rkgd                                     1/1   Terminating   0                  87d
monitoring               thanos-query-64dfd687dd-gz5p8                                     0/1   Pending       0                  5m37s
monitoring               thanos-query-64dfd687dd-r6xnk                                     0/1   Pending       0                  5m51s
monitoring               thanos-query-64dfd687dd-xv9cv                                     1/1   Terminating   0                  29d
monitoring               thanos-store-0                                                    1/1   Terminating   0                  29d
monitoring               thanos-store-1                                                    1/1   Terminating   0                  50d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be-84888b4956jjmld   1/1   Terminating   54 (22h ago)       29d
pihole                   pihole-fb8b7b6df-l5mcx                                            0/1   Pending       0                  5m53s
pihole                   pihole-fb8b7b6df-xc84w                                            1/1   Terminating   1 (8d ago)         87d
seaweedfs                seaweedfs-filer-0                                                 1/1   Terminating   0                  5d
seaweedfs                seaweedfs-filer-1                                                 1/1   Terminating   3 (22h ago)        5d
seaweedfs                seaweedfs-filer-sync-f7489458c-fjr68                              1/1   Terminating   0                  6d3h
seaweedfs                seaweedfs-filer-sync-f7489458c-tgvcj                              0/1   Pending       0                  5m35s
seaweedfs                seaweedfs-master-0                                                1/1   Terminating   0                  5d
seaweedfs                seaweedfs-master-1                                                1/1   Terminating   0                  5d
seaweedfs                seaweedfs-master-2                                                1/1   Terminating   0                  5d
seaweedfs                seaweedfs-volume-0                                                1/1   Terminating   0                  5d
seaweedfs                seaweedfs-volume-1                                                1/1   Terminating   0                  5d
synology-csi             synology-csi-controller-0                                         4/4   Terminating   0                  131d
velero                   velero-ui-687565868b-57tld                                        0/1   Pending       0                  5m51s
velero                   velero-ui-687565868b-dsgsb                                        1/1   Terminating   2 (8d ago)         87d
well-known               well-known-7b9498f5f5-57cjq                                       1/1   Terminating   0                  87d
```

#### Unhealthy Pod Details

**argocd/argocd-application-controller-0:**
```
Events:
  Type     Reason        Age   From             Message
  ----     ------        ----  ----             -------
  Warning  NodeNotReady  10m   node-controller  Node is not ready
```

**argocd/argocd-applicationset-controller-db66f5cb8-lmhs9:**
```
Events:
  Type     Reason            Age                  From               Message
  ----     ------            ----                 ----               -------
  Warning  FailedScheduling  5m35s                default-scheduler  0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
  Warning  FailedScheduling  22s (x2 over 5m34s)  default-scheduler  0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
```

**argocd/argocd-applicationset-controller-db66f5cb8-m8fkh:**
```
Events:
  Type     Reason        Age   From             Message
  ----     ------        ----  ----             -------
  Warning  NodeNotReady  10m   node-controller  Node is not ready
```

**argocd/argocd-notifications-controller-64789ccc8b-26cvm:**
```
Events:
  Type     Reason        Age   From             Message
  ----     ------        ----  ----             -------
  Warning  NodeNotReady  10m   node-controller  Node is not ready
```

**argocd/argocd-repo-server-7dfc645f84-84ld8:**
```
Events:
  Type     Reason            Age                    From               Message
  ----     ------            ----                   ----               -------
  Warning  FailedScheduling  5m50s                  default-scheduler  0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
  Warning  FailedScheduling  5m35s (x2 over 5m35s)  default-scheduler  0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
```

### High Restart Pods (>3 restarts)
- argocd/argocd-repo-server-7dfc645f84-qxz64: 5 restarts
- argocd/argocd-server-64dd47d8bf-fkr26: 37 restarts
- awx/awx-operator-controller-manager-6ffdf98f6-hwvqf: 20 restarts
- cilium-spire/spire-agent-49g4h: 28 restarts
- cilium-spire/spire-agent-mdslp: 8 restarts
- cilium-spire/spire-server-0: 18 restarts
- REDACTED_01b50c5d/REDACTED_ab04b573-v2-8c85f5d4b-ng8lb: 26 restarts
- ingress-nginx/ingress-nginx-controller-8445475547-bwczk: 33 restarts
- ingress-nginx/ingress-nginx-controller-8445475547-mxdrc: 30 restarts
- kube-system/cilium-operator-6cdbfb68d7-z6v2x: 11 restarts
- kube-system/clustermesh-apiserver-6c96779765-rmrzt: 46 restarts
- kube-system/etcd-nlk8s-ctrl01: 64 restarts
- kube-system/hubble-ui-6bb97d8894-nnkx5: 23 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 1999 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 58 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 15 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 109 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 37 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 93 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 38 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 35 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 40 restarts
- kube-system/tetragon-75hdg: 6 restarts
- kube-system/tetragon-878gv: 4 restarts
- kube-system/tetragon-mdsn9: 18 restarts
- kube-system/tetragon-tbcc7: 4 restarts
- kube-system/tetragon-vbs6v: 14 restarts
- REDACTED_d97cef76/REDACTED_d97cef76-kong-5c7f96dd9b-fgxd9: 15 restarts
- logging/promtail-hp5sc: 7 restarts
- logging/promtail-ng69s: 4 restarts
- monitoring/goldpinger-25hf5: 46 restarts
- monitoring/goldpinger-6dj9l: 25 restarts
- monitoring/goldpinger-n2fzm: 8 restarts
- monitoring/goldpinger-zxtb9: 6 restarts
- monitoring/monitoring-grafana-b54c68dbb-khbn6: 4 restarts
- monitoring/monitoring-kube-prometheus-operator-67d8d4c647-5955s: 40 restarts
- monitoring/monitoring-kube-state-metrics-75f9fff55b-6cc8x: 7 restarts
- monitoring/monitoring-prometheus-node-exporter-6dl8r: 174 restarts
- monitoring/monitoring-prometheus-node-exporter-6sc8j: 7 restarts
- monitoring/monitoring-prometheus-node-exporter-wmcb8: 44 restarts
- monitoring/prometheus-REDACTED_6dfbe9fc-0: 15 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956jjmld: 54 restarts
- synology-csi/synology-csi-node-577mq: 10 restarts
- synology-csi/synology-csi-node-kxrjb: 14 restarts
- synology-csi/synology-csi-node-l72f8: 4 restarts
- synology-csi/synology-csi-node-ptwb8: 4 restarts
- synology-csi/synology-csi-node-zch7n: 18 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE                LAST SEEN   TYPE      REASON              OBJECT                                                                MESSAGE
pihole                   5m54s       Warning   FailedScheduling    pod/pihole-fb8b7b6df-l5mcx                                            0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
kube-system              5m37s       Warning   FailedScheduling    pod/tetragon-operator-f674b87f4-xdwhj                                 0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
argocd                   25s         Warning   FailedScheduling    pod/argocd-applicationset-controller-db66f5cb8-lmhs9                  0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
velero                   5m37s       Warning   FailedScheduling    pod/velero-ui-687565868b-57tld                                        0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
velero                   5m52s       Warning   FailedScheduling    pod/velero-ui-687565868b-57tld                                        0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
monitoring               5m37s       Warning   FailedScheduling    pod/monitoring-grafana-b54c68dbb-vg8lv                                0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
argocd                   5m52s       Warning   FailedScheduling    pod/argocd-repo-server-7dfc645f84-84ld8                               0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
argocd                   5m37s       Warning   FailedScheduling    pod/argocd-repo-server-7dfc645f84-84ld8                               0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
monitoring               5m40s       Warning   FailedScheduling    pod/monitoring-grafana-b54c68dbb-vg8lv                                0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
argocd                   5m37s       Warning   FailedScheduling    pod/argocd-repo-server-7dfc645f84-q6mbm                               0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
argocd                   25s         Warning   FailedScheduling    pod/argocd-repo-server-7dfc645f84-q6mbm                               0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
monitoring               5m52s       Warning   FailedScheduling    pod/bgpalerter-789f984488-w9nx8                                       0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
kube-system              5m39s       Warning   FailedScheduling    pod/metrics-server-56fb9549f4-8zwbz                                   0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s).
monitoring               5m37s       Warning   FailedScheduling    pod/monitoring-grafana-b54c68dbb-7jfds                                0/7 nodes are available: 1 Insufficient memory, 6 node(s) had untolerated taint(s). no new claims to deallocate, preemption: 0/7 nodes are available: 1 No preemption victims found for incoming pod, 6 Preemption is not helpful for scheduling.
```

---

## Workload Map

### Namespace: `argocd`

0/- **Deployment: argocd-applicationset-controller** (1) → Svc:argocd-applicationset-controller (ClusterIP) → Ingress:argocd.example.net
1/- **Deployment: argocd-notifications-controller** (1) → Ingress:argocd.example.net
1/- **Deployment: argocd-redis** (1) → Svc:argocd-redis (ClusterIP) → Ingress:argocd.example.net
0/- **Deployment: argocd-repo-server** (2) → Svc:argocd-repo-server (ClusterIP) → Ingress:argocd.example.net
0/- **Deployment: argocd-server** (2) → Svc:argocd-server (NodePort) → Ingress:argocd.example.net
- **StatefulSet: argocd-application-controller** (/1)

**Secrets:**
- ExternalSecret: argocd-redis (SecretSynced)
- ExternalSecret: gitlab-common-creds (SecretSynced)
- ExternalSecret: gitlab-repo-creds (SecretSynced)

### Namespace: `awx`

1/- **Deployment: awx-operator-controller-manager** (1) → Ingress:awx.example.net
0/- **Deployment: my-awx-task** (1) → Ingress:awx.example.net
1/- **Deployment: my-awx-web** (1) → Svc:my-awx-service (NodePort) → Ingress:awx.example.net
- **StatefulSet: my-awx-postgres-15** (/1)

**Storage:**
- PVC: my-awx-projects (50Gi, Bound, sc:nfs-sc)
- PVC: REDACTED_0d7ca6a5 (50Gi, Bound, sc:REDACTED_b280aec5)

**Secrets:**
- ExternalSecret: k8s-api-credentials (SecretSynced)
- ExternalSecret: npm-credentials (SecretSynced)

### Namespace: `bentopdf`

0/- **Deployment: bentopdf** (1) → Svc:bentopdf (ClusterIP) → Ingress:bentopdf.example.net

### Namespace: `cert-manager`

0/- **Deployment: cert-manager** (1) → Svc:cert-manager (ClusterIP)
1/- **Deployment: cert-manager-cainjector** (1)
1/- **Deployment: cert-manager-webhook** (1)

**Secrets:**
- ExternalSecret: REDACTED_fb8d60db (SecretSynced)

### Namespace: `cilium-spire`

- **StatefulSet: spire-server** (/1)

**Storage:**
- PVC: spire-data-spire-server-0 (1Gi, Bound, sc:nfs-client)

### Namespace: `default`


### Namespace: `echo-server`

1/- **Deployment: echo-server** (1) → Svc:echo-server (ClusterIP) → Ingress:echo.example.net

### Namespace: `external-secrets`

0/- **Deployment: external-secrets** (1) → Svc:external-secrets-cert-controller-metrics (ClusterIP)
1/- **Deployment: external-secrets-cert-controller** (1) → Svc:external-secrets-cert-controller-metrics (ClusterIP)
1/- **Deployment: external-secrets-webhook** (1) → Svc:external-secrets-webhook (ClusterIP)

### Namespace: `gatus`

1/- **Deployment: gatus** (1) → Svc:gatus (ClusterIP) → Ingress:nl-gatus.example.net

**Storage:**
- PVC: gatus-data (1Gi, Bound, sc:REDACTED_4f3da73d)

### Namespace: `REDACTED_01b50c5d`

2/- **Deployment: REDACTED_ab04b573-v2** (2)

### Namespace: `ingress-nginx`

0/- **Deployment: ingress-nginx-controller** (2)

### Namespace: `REDACTED_d97cef76`

0/- **Deployment: REDACTED_d97cef76-api** (1) → Svc:REDACTED_d97cef76-api (ClusterIP) → Ingress:nl-k8s.example.net
0/- **Deployment: REDACTED_d97cef76-auth** (1) → Svc:REDACTED_d97cef76-auth (ClusterIP) → Ingress:nl-k8s.example.net
1/- **Deployment: REDACTED_d97cef76-kong** (1) → Ingress:nl-k8s.example.net
0/- **Deployment: REDACTED_d97cef76-metrics-scraper** (1) → Svc:REDACTED_d97cef76-metrics-scraper (ClusterIP) → Ingress:nl-k8s.example.net
1/- **Deployment: REDACTED_d97cef76-web** (1) → Svc:REDACTED_d97cef76-web (ClusterIP) → Ingress:nl-k8s.example.net

### Namespace: `logging`

- **StatefulSet: loki** (1/1)

**Storage:**
- PVC: storage-loki-0 (100Gi, Bound, sc:REDACTED_4f3da73d)

**Secrets:**
- ExternalSecret: loki-s3-credentials (SecretSynced)

### Namespace: `monitoring`

0/- **Deployment: bgpalerter** (1) → Svc:bgpalerter (ClusterIP) → Ingress:goldpinger.example.net
0/- **Deployment: monitoring-grafana** (2) → Ingress:goldpinger.example.net
1/- **Deployment: monitoring-kube-prometheus-operator** (1) → Ingress:goldpinger.example.net
1/- **Deployment: monitoring-kube-state-metrics** (1) → Ingress:goldpinger.example.net
1/- **Deployment: snmp-exporter** (1) → Svc:snmp-exporter (ClusterIP) → Ingress:goldpinger.example.net
0/- **Deployment: thanos-query** (2) → Ingress:goldpinger.example.net
- **StatefulSet: alertmanager-monitoring-kube-prometheus-alertmanager** (1/2)
- **StatefulSet: prometheus-REDACTED_6dfbe9fc** (1/2)
- **StatefulSet: thanos-compactor** (/1)
- **StatefulSet: thanos-store** (/2)

**Storage:**
- PVC: alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-0 (10Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-1 (10Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: data-thanos-compactor-0 (50Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: data-thanos-store-0 (20Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: data-thanos-store-1 (20Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: monitoring-grafana (20Gi, Bound, sc:nfs-client)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-0 (200Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-1 (200Gi, Bound, sc:REDACTED_4f3da73d)

**Secrets:**
- ExternalSecret: monitoring-finops-db-ro (SecretSynced)
- ExternalSecret: monitoring-grafana (SecretSynced)
- ExternalSecret: tg-ingest-token (SecretSynced)
- ExternalSecret: REDACTED_5f4971dc (SecretSynced)

### Namespace: `nfs-provisioner`

1/- **Deployment: nfs-provisioner-REDACTED_5fef70be** (1)

### Namespace: `pihole`

0/- **Deployment: pihole** (1) → Svc:pihole-dns-lb (LoadBalancer 10.0.X.X) → Ingress:pihole.example.net

**Storage:**
- PVC: pihole-data (1Gi, Bound, sc:nfs-client)

**Secrets:**
- ExternalSecret: pihole-credentials (SecretSynced)

### Namespace: `seaweedfs`

0/- **Deployment: seaweedfs-filer-sync** (1) → Ingress:nl-seaweedfs.example.net
- **StatefulSet: seaweedfs-filer** (/2)
- **StatefulSet: seaweedfs-master** (/3)
- **StatefulSet: seaweedfs-volume** (/2)

**Storage:**
- PVC: data-filer-seaweedfs-filer-0 (20Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-filer-seaweedfs-filer-1 (20Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-seaweedfs-master-0 (10Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-seaweedfs-master-1 (10Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-seaweedfs-master-2 (10Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-volume-0 (1000Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-volume-1 (1000Gi, Bound, sc:REDACTED_b280aec5)

**Secrets:**
- ExternalSecret: seaweedfs-s3-config (SecretSynced)

### Namespace: `synology-csi`

- **StatefulSet: synology-csi-controller** (/1)

### Namespace: `velero`

1/- **Deployment: velero** (1) → Svc:velero-metrics (ClusterIP) → Ingress:velero.example.net
0/- **Deployment: velero-ui** (1) → Svc:velero-ui (NodePort) → Ingress:velero.example.net

**Secrets:**
- ExternalSecret: velero-repo-credentials (SecretSynced)
- ExternalSecret: velero-s3-credentials (SecretSynced)

### Namespace: `well-known`

1/- **Deployment: well-known** (1) → Svc:well-known (ClusterIP) → Ingress:status.example.net


---

## Resource Analysis

### Node Utilization
```
NAME                 CPU(cores)   CPU(%)      MEMORY(bytes)   MEMORY(%)   
nlk8s-ctrl01   1147m        28%         2882Mi          36%         
nlk8s-ctrl02   1739m        43%         3842Mi          47%         
nlk8s-node01    1754m        21%         6012Mi          76%         
nlk8s-ctrl03   <unknown>    <unknown>   <unknown>       <unknown>   
nlk8s-node02    <unknown>    <unknown>   <unknown>       <unknown>   
nlk8s-node03    <unknown>    <unknown>   <unknown>       <unknown>   
nlk8s-node04    <unknown>    <unknown>   <unknown>       <unknown>   
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
awx                      awx-operator-controller-manager-6ffdf98f6-2k2jd                   1105m        173Mi           
kube-system              kube-apiserver-nlk8s-ctrl02                                 801m         1754Mi          
kube-system              tetragon-mdsn9                                                    295m         663Mi           
kube-system              cilium-64v2f                                                      199m         187Mi           
logging                  promtail-ng69s                                                    199m         86Mi            
kube-system              etcd-nlk8s-ctrl02                                           187m         222Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-1                184m         1681Mi          
kube-system              kube-controller-manager-nlk8s-ctrl02                        92m          197Mi           
kube-system              kube-apiserver-nlk8s-ctrl01                                 86m          1201Mi          
kube-system              coredns-66bc5c9577-vr4vx                                          83m          38Mi            
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              kube-apiserver-nlk8s-ctrl02                                 801m         1754Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                184m         1681Mi          
awx                      my-awx-web-55ccb47b58-m95v8                                       4m           1470Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 86m          1201Mi          
logging                  loki-0                                                            54m          963Mi           
kube-system              tetragon-mdsn9                                                    295m         663Mi           
kube-system              etcd-nlk8s-ctrl01                                           49m          288Mi           
kube-system              cilium-5v9vw                                                      69m          273Mi           
kube-system              etcd-nlk8s-ctrl02                                           187m         222Mi           
logging                  promtail-hp5sc                                                    8m           218Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
awx: CPU=2810m Mem=5376Mi
monitoring: CPU=2600m Mem=13232Mi
kube-system: CPU=2170m Mem=704Mi
ingress-nginx: CPU=2000m Mem=2048Mi
seaweedfs: CPU=1300m Mem=7936Mi
argocd: CPU=1200m Mem=2752Mi
logging: CPU=850m Mem=2944Mi
REDACTED_d97cef76: CPU=800m Mem=1600Mi
velero: CPU=600m Mem=768Mi
pihole: CPU=200m Mem=512Mi
```

---

## Network & Security

### PodDisruptionBudgets
```
NAMESPACE         NAME                                              MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
argocd            argocd-application-controller                     1               N/A               0                     251d
argocd            argocd-applicationset-controller                  1               N/A               0                     251d
argocd            argocd-redis                                      1               N/A               0                     251d
argocd            argocd-repo-server                                1               N/A               0                     251d
argocd            argocd-server                                     1               N/A               0                     251d
awx               awx-postgres-pdb                                  1               N/A               0                     251d
awx               awx-task-pdb                                      1               N/A               0                     251d
awx               awx-web-pdb                                       1               N/A               0                     251d
ingress-nginx     ingress-nginx-controller                          1               N/A               0                     251d
kube-system       coredns-pdb                                       1               N/A               0                     251d
kube-system       metrics-server-pdb                                1               N/A               0                     251d
monitoring        monitoring-grafana                                1               N/A               0                     116d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     116d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     116d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     251d
seaweedfs         seaweedfs-filer                                   1               N/A               0                     137d
seaweedfs         seaweedfs-master                                  2               N/A               0                     137d
seaweedfs         seaweedfs-volume                                  1               N/A               0                     137d
```

### CiliumNetworkPolicies
- CiliumNetworkPolicies: 4
- CiliumClusterwideNetworkPolicies: 0

**Policies by namespace:**
- gatus: 1 policies
- logging: 1 policies
- pihole: 1 policies
- well-known: 1 policies

### Services by Type
| Type | Count |
|------|-------|
| ClusterIP | 72 |
| NodePort | 6 |
| LoadBalancer | 6 |

### LoadBalancer Services
```
NAMESPACE       NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   273d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               242d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 250d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                248d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 250d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 250d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   253d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        252d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        249d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        143d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   232d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        237d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        236d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        241d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        252d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        236d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        237d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        254d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        238d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        238d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        253d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   231d
```

---

## Storage

| Metric | Count |
|--------|-------|
| StorageClasses | 10 |
| PersistentVolumes | 22 |
| PersistentVolumeClaims | 21 |

### StorageClasses
```
NAME                                      PROVISIONER                                                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   254d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   274d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   251d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   251d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   251d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   251d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   251d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   251d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   251d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   251d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 4 |
| External Secrets | 16 |
| Certificates | 21 |
| ServiceMonitors | 28 |
| CiliumNetworkPolicies | 4 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE    PAUSED
daily-backup    Enabled   0 2 * * *   60m          253d   false
weekly-backup   Enabled   0 3 * * 0   4d           253d   false
```

### Recent Backups (last 5)
```
daily-backup-20260802020016    4d1h
weekly-backup-20260802030016   4d
daily-backup-20260803020017    3d1h
daily-backup-20260804020018    2d1h
daily-backup-20260805020019    25h
```

---

## Helm Releases
```
NAME                	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd              	argocd                	9       	2026-03-15 17:16:45.748376325 +0000 UTC	deployed	argo-cd-7.7.10                        	v2.13.2    
cert-manager        	cert-manager          	3       	2025-11-30 21:22:09.520251302 +0000 UTC	deployed	cert-manager-v1.17.1                  	v1.17.1    
cilium              	kube-system           	21      	2026-07-07 13:27:42.463449823 +0000 UTC	deployed	cilium-1.19.5                         	1.19.5     
external-secrets    	external-secrets      	2       	2025-12-16 13:20:23.175188029 +0000 UTC	deployed	external-secrets-1.1.1                	v1.1.1     
ingress-nginx       	ingress-nginx         	14      	2026-07-07 14:07:26.472035985 +0000 UTC	deployed	ingress-nginx-4.15.1                  	1.15.1     
k8s-agent           	REDACTED_01b50c5d	7       	2026-07-07 14:02:10.666450172 +0000 UTC	deployed	gitlab-agent-2.28.0                   	v19.1.0    
REDACTED_d97cef76	REDACTED_d97cef76  	2       	2026-02-25 19:02:27.096604857 +0000 UTC	deployed	REDACTED_d97cef76-7.14.0           	           
loki                	logging               	12      	2026-07-07 13:12:39.944244427 +0000 UTC	deployed	loki-6.55.0                           	3.6.7      
monitoring          	monitoring            	23      	2026-08-06 02:48:50.032708747 +0000 UTC	deployed	REDACTED_d8074874-79.12.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	8       	2025-11-29 02:18:25.900770326 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail            	logging               	8       	2026-03-14 22:22:09.209112925 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
seaweedfs           	seaweedfs             	15      	2026-08-01 04:01:07.781707084 +0000 UTC	deployed	seaweedfs-4.0.401                     	4.01       
synology-csi        	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
tetragon            	kube-system           	7       	2025-12-20 22:35:40.030282504 +0000 UTC	deployed	tetragon-1.6.0                        	1.6.0      
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   253d
awx                      Active   274d
bentopdf                 Active   249d
cert-manager             Active   248d
cilium-secrets           Active   250d
cilium-spire             Active   250d
default                  Active   275d
echo-server              Active   143d
external-secrets         Active   249d
gatus                    Active   232d
REDACTED_01b50c5d   Active   254d
ingress-nginx            Active   273d
kube-node-lease          Active   275d
kube-public              Active   275d
kube-system              Active   275d
REDACTED_d97cef76     Active   236d
logging                  Active   248d
monitoring               Active   274d
nfs-provisioner          Active   273d
opentofu-ns              Active   273d
pihole                   Active   254d
production               Active   254d
seaweedfs                Active   238d
synology-csi             Active   251d
velero                   Active   253d
well-known               Active   231d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  0/1     1            0           253d
argocd                   argocd-notifications-controller                   1/1     1            1           144d
argocd                   argocd-redis                                      1/1     1            1           253d
argocd                   argocd-repo-server                                0/2     2            0           253d
argocd                   argocd-server                                     0/2     2            0           253d
awx                      awx-operator-controller-manager                   1/1     1            1           274d
awx                      my-awx-task                                       0/1     1            0           274d
awx                      my-awx-web                                        1/1     1            1           274d
bentopdf                 bentopdf                                          0/1     1            0           249d
cert-manager             cert-manager                                      0/1     1            0           248d
cert-manager             cert-manager-cainjector                           1/1     1            1           248d
cert-manager             cert-manager-webhook                              1/1     1            1           248d
echo-server              echo-server                                       1/1     1            1           143d
external-secrets         external-secrets                                  0/1     1            0           249d
external-secrets         external-secrets-cert-controller                  1/1     1            1           249d
external-secrets         external-secrets-webhook                          1/1     1            1           249d
gatus                    gatus                                             1/1     1            1           232d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           254d
ingress-nginx            ingress-nginx-controller                          0/2     2            0           273d
kube-system              cilium-operator                                   1/1     1            1           250d
kube-system              clustermesh-apiserver                             1/1     1            1           242d
kube-system              coredns                                           1/2     2            1           275d
kube-system              hubble-relay                                      1/1     1            1           250d
kube-system              hubble-ui                                         1/1     1            1           250d
kube-system              metrics-server                                    1/1     1            1           274d
kube-system              tetragon-operator                                 0/1     1            0           229d
REDACTED_d97cef76     REDACTED_d97cef76-api                          0/1     1            0           236d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         0/1     1            0           236d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           236d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              0/1     1            0           236d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           236d
monitoring               bgpalerter                                        0/1     1            0           234d
monitoring               monitoring-grafana                                0/2     2            0           116d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           116d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           116d
monitoring               snmp-exporter                                     1/1     1            1           236d
monitoring               thanos-query                                      0/2     2            0           237d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           273d
pihole                   pihole                                            0/1     1            0           249d
seaweedfs                seaweedfs-filer-sync                              0/1     1            0           237d
velero                   velero                                            1/1     1            1           253d
velero                   velero-ui                                         0/1     1            0           253d
well-known               well-known                                        1/1     1            1           231d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          0/1     253d
awx            my-awx-postgres-15                                     0/1     274d
cilium-spire   spire-server                                           0/1     250d
logging        loki                                                   1/1     229d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   1/2     116d
monitoring     prometheus-REDACTED_6dfbe9fc       1/2     116d
monitoring     thanos-compactor                                       0/1     237d
monitoring     thanos-store                                           0/2     237d
seaweedfs      seaweedfs-filer                                        0/2     238d
seaweedfs      seaweedfs-master                                       0/3     238d
seaweedfs      seaweedfs-volume                                       0/2     6d11h
synology-csi   synology-csi-controller                                0/1     251d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           3         3         3       3            3           <none>                   250d
kube-system    cilium                                7         7         3       7            3           kubernetes.io/os=linux   250d
kube-system    cilium-envoy                          7         7         3       7            3           kubernetes.io/os=linux   250d
kube-system    tetragon                              3         3         3       3            3           <none>                   229d
logging        loki-canary                           1         1         1       1            1           <none>                   237d
logging        promtail                              3         3         3       3            3           <none>                   248d
monitoring     goldpinger                            3         3         3       3            3           <none>                   241d
monitoring     monitoring-prometheus-node-exporter   3         3         3       3            3           kubernetes.io/os=linux   116d
synology-csi   synology-csi-node                     7         7         3       7            3           <none>                   251d
velero         node-agent                            1         1         1       1            1           <none>                   8d
```

---

*Full cluster context dump - v3.1.0*
