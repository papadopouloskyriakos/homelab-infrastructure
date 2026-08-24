# K8s Cluster Context (Lite)
<!-- 
LLM: Compact cluster snapshot for quick analysis. Use cluster-context-full.md for deep troubleshooting.
-->

**Generated:** 2026-08-24 03:00:01 UTC | **Host:** nlk8s-ctrl01 | **v3.1.0**

## Health: CRITICAL ⚠️

| Check | Value |
|-------|-------|
| Unhealthy Pods | 35 |
| Pending PVCs | 0 |
| Total Restarts | 700 |

## Topology

- **K8s:** v1.36.3 | **CNI:** Cilium 1.20.0
- **Nodes:** 7 (3 control-plane, 4 workers)
- **Pods:** 192

### Nodes
- **nlk8s-ctrl01** (control-plane) 10.0.X.X | CPU:4 Mem:8002696Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl02** (control-plane) 10.0.X.X | CPU:4 Mem:8092Mi | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-ctrl03** (control-plane) 10.0.X.X | CPU:4 Mem:8003704Ki | Taints:node-role.kubernetes.io/control-plane=:NoSchedule
- **nlk8s-node01** (worker) 10.0.X.X | CPU:8 Mem:8001304Ki | Taints:none
- **nlk8s-node02** (worker) 10.0.X.X | CPU:8 Mem:8002312Ki | Taints:none
- **nlk8s-node03** (worker) 10.0.X.X | CPU:8 Mem:8002312Ki | Taints:none
- **nlk8s-node04** (worker) 10.0.X.X | CPU:8 Mem:8002308Ki | Taints:none

## Anomalies

### Unhealthy Pods
```
default                  fence-probe                                                       0/1   Error              0                 4h47m
logging                  loki-0                                                            1/2   CrashLoopBackOff   22 (96s ago)      7d10h
monitoring               bgpalerter-789f984488-b2fpj                                       0/1   Pending            0                 3h37m
monitoring               prometheus-REDACTED_6dfbe9fc-0                2/3   CrashLoopBackOff   92 (2m48s ago)    6d4h
monitoring               thanos-compactor-0                                                0/1   CrashLoopBackOff   38 (2m54s ago)    3d17h
seaweedfs                seaweedfs-read-canary-29792183-4ccsh                              0/1   Error              0                 157m
seaweedfs                seaweedfs-read-canary-29792183-6vxxw                              0/1   Error              0                 157m
velero                   argocd-default-kopia-maintain-job-1787514854153-66z9r             0/1   Error              0                 7h6m
velero                   argocd-default-kopia-maintain-job-1787515627611-gfzr9             0/1   Error              0                 6h53m
velero                   argocd-default-kopia-maintain-job-1787516396098-kfvr6             0/1   Error              0                 6h40m
velero                   awx-default-kopia-maintain-job-1787537477433-rv7vs                0/1   Error              0                 49m
velero                   awx-default-kopia-maintain-job-1787537785465-d5sjn                0/1   Error              0                 44m
velero                   awx-default-kopia-maintain-job-1787538077435-qxh8v                0/1   Error              0                 39m
velero                   cilium-spire-default-kopia-maintain-job-1787515004231-l44tg       0/1   Error              0                 7h4m
velero                   cilium-spire-default-kopia-maintain-job-1787515777659-xwvst       0/1   Error              0                 6h51m
velero                   cilium-spire-default-kopia-maintain-job-1787516547163-8fwlz       0/1   Error              0                 6h38m
velero                   gatus-default-kopia-maintain-job-1787514699898-pglfv              0/1   Error              0                 7h9m
velero                   gatus-default-kopia-maintain-job-1787515473456-vw8hr              0/1   Error              0                 6h56m
velero                   gatus-default-kopia-maintain-job-1787516238890-tsm8n              0/1   Error              0                 6h43m
velero                   REDACTED_d97cef76-default-kopia-maintain-job-17875147046nf6r   0/1   Error              0                 7h9m
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787515478zh6jd   0/1   Error              0                 6h56m
velero                   REDACTED_d97cef76-default-kopia-maintain-job-1787516245rj97k   0/1   Error              0                 6h43m
velero                   logging-default-kopia-maintain-job-1787515010277-kjjpk            0/1   Error              0                 7h4m
velero                   logging-default-kopia-maintain-job-1787515787734-nncqk            0/1   Error              0                 6h51m
velero                   logging-default-kopia-maintain-job-1787516552197-fbjtl            0/1   Error              0                 6h38m
velero                   monitoring-default-kopia-maintain-job-1787537485542-pftlg         0/1   Error              0                 49m
velero                   monitoring-default-kopia-maintain-job-1787537795509-cr2zg         0/1   Error              0                 44m
velero                   monitoring-default-kopia-maintain-job-1787539075485-nr7nj         0/1   Error              0                 22m
velero                   pihole-default-kopia-maintain-job-1787537205849-vzxbx             0/1   Error              0                 54m
velero                   pihole-default-kopia-maintain-job-1787537494574-v6pq7             0/1   Error              0                 49m
velero                   pihole-default-kopia-maintain-job-1787537777435-5x6kn             0/1   Error              0                 44m
velero                   well-known-default-kopia-maintain-job-1787514401817-t764g         0/1   Error              0                 7h14m
velero                   well-known-default-kopia-maintain-job-1787515168357-6hg2p         0/1   Error              0                 7h1m
velero                   well-known-default-kopia-maintain-job-1787515941813-z8k5h         0/1   Error              0                 6h48m
velero                   well-known-default-kopia-maintain-job-1787516706278-fndcj         0/1   Error              0                 6h35m
```

### High Restart Pods (>3)
ingress-nginx/ingress-nginx-controller-8445475547-6zqqc: 47 restarts
ingress-nginx/ingress-nginx-controller-8445475547-kr7kz: 43 restarts
kube-system/clustermesh-apiserver-6c8cd7bb6f-ctst4: 101 restarts
kube-system/kube-apiserver-nlk8s-ctrl01: 4 restarts
kube-system/kube-scheduler-nlk8s-ctrl03: 4 restarts
kube-system/tetragon-5gk99: 7 restarts
kube-system/tetragon-75hdg: 8 restarts
kube-system/tetragon-878gv: 8 restarts
kube-system/tetragon-jz2b6: 6 restarts
kube-system/tetragon-mdsn9: 23 restarts
kube-system/tetragon-tbcc7: 8 restarts
kube-system/tetragon-vbs6v: 16 restarts
logging/loki-0: 22 restarts
logging/promtail-5jr9j: 5 restarts
logging/promtail-hp5sc: 8 restarts
logging/promtail-ng69s: 5 restarts
monitoring/monitoring-grafana-7d6c5795b8-9tq4w: 25 restarts
monitoring/monitoring-kube-prometheus-operator-67d8d4c647-vwbbr: 20 restarts
monitoring/monitoring-kube-state-metrics-75f9fff55b-4vfg6: 44 restarts
monitoring/monitoring-prometheus-node-exporter-6dl8r: 175 restarts
monitoring/monitoring-prometheus-node-exporter-6sc8j: 9 restarts
monitoring/monitoring-prometheus-node-exporter-vgp6b: 4 restarts
monitoring/monitoring-prometheus-node-exporter-wmcb8: 46 restarts
monitoring/prometheus-REDACTED_6dfbe9fc-0: 92 restarts
monitoring/prometheus-REDACTED_6dfbe9fc-1: 21 restarts
monitoring/thanos-compactor-0: 38 restarts
seaweedfs/seaweedfs-filer-0: 8 restarts
seaweedfs/seaweedfs-filer-1: 8 restarts
synology-csi/synology-csi-node-4nxcz: 6 restarts
synology-csi/synology-csi-node-kxrjb: 17 restarts
synology-csi/synology-csi-node-l72f8: 9 restarts
synology-csi/synology-csi-node-ptwb8: 8 restarts
synology-csi/synology-csi-node-sfdmg: 6 restarts
synology-csi/synology-csi-node-zch7n: 24 restarts

### Recent Warnings (5)
```
kube-system     7m28s       Warning   Unhealthy              pod/kube-apiserver-nlk8s-ctrl01                     Readiness probe failed: HTTP probe failed with statuscode: 500
velero          5m18s       Warning   BackoffLimitExceeded   job/monitoring-default-kopia-maintain-job-1787539075485   Job has reached the specified backoff limit
monitoring      4m27s       Warning   BackOff                pod/thanos-compactor-0                                    Back-off restarting failed container thanos-compactor in pod thanos-compactor-0_monitoring(a9d9acff-f6d2-40da-8b5c-0b6136d55a8a)
monitoring      4m13s       Warning   BackOff                pod/prometheus-REDACTED_6dfbe9fc-0    Back-off restarting failed container prometheus in pod prometheus-REDACTED_6dfbe9fc-0_monitoring(4e11d479-c4da-4d23-b55b-6156d31191c9)
kube-system     2m38s       Warning   Unhealthy              pod/kube-apiserver-nlk8s-ctrl02                     Readiness probe failed: HTTP probe failed with statuscode: 500
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
