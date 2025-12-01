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

**Generated:** 2025-12-01 13:11:41 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | HEALTHY | ✅ |
| Unhealthy Pods | 0 | ✅ |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 117 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.18.4 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 104 |

### Node Details (with Taints & Labels)

#### nlk8s-ctrl01
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 3886100Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=

#### nlk8s-ctrl02
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 3996Mi
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=

#### nlk8s-ctrl03
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 3886092Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=

#### nlk8s-node01
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006752Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker

#### nlk8s-node02
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006740Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker

#### nlk8s-node03
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006740Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker

#### nlk8s-node04
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006736Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker


---

## Anomalies & Issues

### Unhealthy Pods
_None - all pods are Running or Completed_

### High Restart Pods (>3 restarts)
- kube-system/kube-apiserver-nlk8s-ctrl01: 16 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 4 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 14 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 7 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 12 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 11 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 7 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 10 restarts
- synology-csi/synology-csi-node-465rx: 6 restarts
- synology-csi/synology-csi-node-5sj22: 6 restarts
- synology-csi/synology-csi-node-5tmgb: 4 restarts
- synology-csi/synology-csi-node-7ssk7: 6 restarts
- synology-csi/synology-csi-node-hmvnt: 6 restarts
- synology-csi/synology-csi-node-jw295: 6 restarts
- synology-csi/synology-csi-node-mx7bm: 6 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE     LAST SEEN   TYPE      REASON      OBJECT                                  MESSAGE
kube-system   18m         Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Liveness probe failed: HTTP probe failed with statuscode: 500
kube-system   3m16s       Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Readiness probe failed: HTTP probe failed with statuscode: 500
```

---

## Workload Map

### Namespace: `argocd`

1/- **Deployment: argocd-applicationset-controller** (1) → Svc:argocd-applicationset-controller (ClusterIP) → Ingress:argocd.example.net
1/- **Deployment: argocd-redis** (1) → Svc:argocd-redis (ClusterIP) → Ingress:argocd.example.net
2/- **Deployment: argocd-repo-server** (2) → Svc:argocd-repo-server (ClusterIP) → Ingress:argocd.example.net
2/- **Deployment: argocd-server** (2) → Svc:argocd-server (NodePort) → Ingress:argocd.example.net
- **StatefulSet: argocd-application-controller** (1/1)

**Secrets:**
- ExternalSecret: gitlab-repo-creds (SecretSynced)

### Namespace: `awx`

1/- **Deployment: awx-operator-controller-manager** (1) → Ingress:awx.example.net
1/- **Deployment: my-awx-task** (1) → Ingress:awx.example.net
1/- **Deployment: my-awx-web** (1) → Svc:my-awx-service (NodePort) → Ingress:awx.example.net
- **StatefulSet: my-awx-postgres-15** (1/1)

**Storage:**
- PVC: my-awx-projects (50Gi, Bound, sc:nfs-sc)
- PVC: REDACTED_0d7ca6a5 (50Gi, Bound, sc:REDACTED_b280aec5)

**Secrets:**
- ExternalSecret: k8s-api-credentials (SecretSynced)
- ExternalSecret: npm-credentials (SecretSynced)

### Namespace: `bentopdf`

1/- **Deployment: bentopdf** (1) → Svc:bentopdf (ClusterIP) → Ingress:bentopdf.example.net

### Namespace: `cert-manager`

1/- **Deployment: cert-manager** (1) → Svc:cert-manager (ClusterIP)
1/- **Deployment: cert-manager-cainjector** (1)
1/- **Deployment: cert-manager-webhook** (1)

**Secrets:**
- ExternalSecret: REDACTED_fb8d60db (SecretSynced)

### Namespace: `cilium-spire`

- **StatefulSet: spire-server** (1/1)

**Storage:**
- PVC: spire-data-spire-server-0 (1Gi, Bound, sc:nfs-client)

### Namespace: `external-secrets`

1/- **Deployment: external-secrets** (1) → Svc:external-secrets-cert-controller-metrics (ClusterIP)
1/- **Deployment: external-secrets-cert-controller** (1) → Svc:external-secrets-cert-controller-metrics (ClusterIP)
1/- **Deployment: external-secrets-webhook** (1) → Svc:external-secrets-webhook (ClusterIP)

### Namespace: `REDACTED_01b50c5d`

2/- **Deployment: REDACTED_ab04b573-v2** (2)

### Namespace: `ingress-nginx`

2/- **Deployment: ingress-nginx-controller** (2)

### Namespace: `REDACTED_d97cef76`

1/- **Deployment: dashboard-metrics-scraper** (1) → Svc:dashboard-metrics-scraper (ClusterIP) → Ingress:k8s.example.net
1/- **Deployment: REDACTED_d97cef76** (1) → Svc:REDACTED_d97cef76 (NodePort) → Ingress:k8s.example.net

### Namespace: `logging`

- **StatefulSet: loki** (1/1)

**Storage:**
- PVC: storage-loki-0 (10Gi, Bound, sc:REDACTED_4f3da73d)

**Secrets:**
- ExternalSecret: loki-minio-credentials (SecretSynced)

### Namespace: `minio`

1/- **Deployment: minio** (1) → Svc:minio-api (NodePort) → Ingress:minio.example.net

**Storage:**
- PVC: minio-data-csi (1Ti, Bound, sc:REDACTED_b280aec5)

**Secrets:**
- ExternalSecret: minio-credentials (SecretSynced)
- ExternalSecret: minio-snapshot-credentials (SecretSynced)

### Namespace: `monitoring`

2/- **Deployment: monitoring-grafana** (2) → Ingress:grafana.example.net
1/- **Deployment: monitoring-kube-prometheus-operator** (1) → Ingress:grafana.example.net
1/- **Deployment: monitoring-kube-state-metrics** (1) → Ingress:grafana.example.net
- **StatefulSet: alertmanager-monitoring-kube-prometheus-alertmanager** (2/2)
- **StatefulSet: prometheus-REDACTED_6dfbe9fc** (2/2)

**Storage:**
- PVC: alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-0 (10Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-1 (10Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: monitoring-grafana (20Gi, Bound, sc:nfs-client)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-0 (200Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-1 (200Gi, Bound, sc:REDACTED_4f3da73d)

**Secrets:**
- ExternalSecret: monitoring-grafana (SecretSynced)

### Namespace: `nfs-provisioner`

1/- **Deployment: nfs-provisioner-REDACTED_5fef70be** (1)

### Namespace: `pihole`

1/- **Deployment: pihole** (1) → Svc:pihole-dns-lb (LoadBalancer 10.0.X.X) → Ingress:pihole.example.net

**Storage:**
- PVC: pihole-data (1Gi, Bound, sc:nfs-client)

**Secrets:**
- ExternalSecret: pihole-credentials (SecretSynced)

### Namespace: `synology-csi`

- **StatefulSet: synology-csi-controller** (1/1)

### Namespace: `velero`

1/- **Deployment: velero** (1) → Svc:velero-ui (NodePort) → Ingress:velero.example.net
1/- **Deployment: velero-ui** (1) → Svc:velero-ui (NodePort) → Ingress:velero.example.net

**Secrets:**
- ExternalSecret: velero-repo-credentials (SecretSynced)
- ExternalSecret: velero-s3-credentials (SecretSynced)


---

## Resource Analysis

### Node Utilization
```
NAME                 CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
nlk8s-ctrl01   1543m        38%      1953Mi          51%         
nlk8s-ctrl02   820m         20%      2233Mi          55%         
nlk8s-ctrl03   289m         7%       2121Mi          55%         
nlk8s-node01    250m         3%       3099Mi          39%         
nlk8s-node02    295m         3%       2526Mi          32%         
nlk8s-node03    217m         2%       4486Mi          57%         
nlk8s-node04    202m         2%       2431Mi          31%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              etcd-nlk8s-ctrl02                                           254m         116Mi           
kube-system              kube-apiserver-nlk8s-ctrl02                                 253m         1099Mi          
kube-system              cilium-88kc5                                                      138m         144Mi           
kube-system              kube-apiserver-nlk8s-ctrl01                                 125m         1195Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 110m         1218Mi          
kube-system              cilium-lhv26                                                      105m         143Mi           
kube-system              cilium-x58c7                                                      94m          169Mi           
kube-system              etcd-nlk8s-ctrl01                                           92m          96Mi            
kube-system              cilium-l2lvv                                                      85m          139Mi           
kube-system              cilium-7mwgn                                                      78m          141Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
awx                      my-awx-task-665479ff65-hk8nj                                      24m          1479Mi          
awx                      my-awx-web-694487457f-4m8kx                                       9m           1312Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 110m         1218Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 125m         1195Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 253m         1099Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                61m          1035Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                49m          985Mi           
monitoring               monitoring-grafana-8487cccf54-5tg9p                               7m           525Mi           
monitoring               monitoring-grafana-8487cccf54-6bbcx                               11m          524Mi           
logging                  loki-0                                                            20m          294Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
kube-system: CPU=2050m Mem=440Mi
awx: CPU=1855m Mem=3552Mi
monitoring: CPU=1200m Mem=4496Mi
ingress-nginx: CPU=1000m Mem=1024Mi
argocd: CPU=750m Mem=1664Mi
velero: CPU=550m Mem=704Mi
logging: CPU=450m Mem=704Mi
minio: CPU=100m Mem=256Mi
pihole: CPU=100m Mem=256Mi
bentopdf: CPU=50m Mem=64Mi
```

---

## Network & Security

### PodDisruptionBudgets
```
NAMESPACE         NAME                                              MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
argocd            argocd-application-controller                     1               N/A               0                     3d21h
argocd            argocd-applicationset-controller                  1               N/A               0                     3d21h
argocd            argocd-redis                                      1               N/A               0                     3d21h
argocd            argocd-repo-server                                1               N/A               1                     3d21h
argocd            argocd-server                                     1               N/A               1                     3d21h
awx               awx-postgres-pdb                                  1               N/A               0                     3d21h
awx               awx-task-pdb                                      1               N/A               0                     3d21h
awx               awx-web-pdb                                       1               N/A               0                     3d21h
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     3d21h
kube-system       coredns-pdb                                       1               N/A               1                     3d21h
kube-system       metrics-server-pdb                                1               N/A               0                     3d21h
minio             minio-pdb                                         1               N/A               0                     3d21h
monitoring        monitoring-grafana                                1               N/A               1                     3d21h
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     3d21h
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     3d21h
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     3d21h
```

### CiliumNetworkPolicies
- CiliumNetworkPolicies: 2
- CiliumClusterwideNetworkPolicies: 0

**Policies by namespace:**
- logging: 1 policies
- pihole: 1 policies

### Services by Type
| Type | Count |
|------|-------|
| ClusterIP | 47 |
| NodePort | 9 |
| LoadBalancer | 5 |

### LoadBalancer Services
```
NAMESPACE       NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   25d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 2d16h
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                11h
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 2d15h
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 2d15h
```

### Ingresses
```
NAMESPACE              NAME                   CLASS   HOSTS                          ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx   argocd.example.net     10.0.X.X   80, 443   5d18h
awx                    awx                    nginx   awx.example.net        10.0.X.X   80        4d13h
bentopdf               bentopdf               nginx   bentopdf.example.net   10.0.X.X   80        46h
kube-system            hubble-ui              nginx   hubble.example.net     10.0.X.X   80, 443   2d22h
REDACTED_d97cef76   REDACTED_d97cef76   nginx   k8s.example.net        10.0.X.X   80        4d13h
minio                  minio-console          nginx   minio.example.net      10.0.X.X   80        6d12h
monitoring             grafana                nginx   grafana.example.net    10.0.X.X   80        4d13h
pihole                 pihole-ingress         nginx   pihole.example.net     10.0.X.X   80        7d8h
velero                 velero-ui              nginx   velero.example.net     10.0.X.X   80        5d17h
```

---

#***REMOVED***

| Metric | Count |
|--------|-------|
| StorageClasses | 10 |
| PersistentVolumes | 14 |
| PersistentVolumeClaims | 11 |

##***REMOVED***Classes
```
NAME                                      PROVISIONER                                                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   6d11h
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   26d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   3d20h
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   3d20h
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   3d20h
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   3d20h
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   3d20h
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   3d20h
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   3d20h
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   3d20h
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 3 |
| External Secrets | 11 |
| Certificates | 1 |
| ServiceMonitors | 21 |
| CiliumNetworkPolicies | 2 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE     PAUSED
daily-backup    Enabled   0 2 * * *   11h          5d17h   
weekly-backup   Enabled   0 3 * * 0   34h          5d17h   
```

### Recent Backups (last 5)
```
post-cilium-migration          2d22h
daily-backup-20251129020047    2d11h
daily-backup-20251130020048    35h
weekly-backup-20251130030048   34h
test-creds-1764505956          24h
```

---

## Helm Releases
```
NAME            	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd          	argocd                	3       	2025-11-29 02:18:52.98547378 +0000 UTC 	deployed	argo-cd-7.7.10                        	v2.13.2    
cert-manager    	cert-manager          	3       	2025-11-30 21:22:09.520251302 +0000 UTC	deployed	cert-manager-v1.17.1                  	v1.17.1    
cilium          	kube-system           	4       	2025-11-29 02:18:27.455069627 +0000 UTC	deployed	cilium-1.18.4                         	1.18.4     
external-secrets	external-secrets      	1       	2025-11-29 19:53:58.182715236 +0000 UTC	deployed	external-secrets-0.12.1               	v0.12.1    
ingress-nginx   	ingress-nginx         	6       	2025-11-30 20:29:39.171185711 +0000 UTC	deployed	ingress-nginx-4.14.0                  	1.14.0     
k8s-agent       	REDACTED_01b50c5d	6       	2025-11-29 02:18:29.271243252 +0000 UTC	deployed	gitlab-agent-2.21.1                   	v18.6.1    
loki            	logging               	2       	2025-12-01 01:16:24.090060483 +0000 UTC	deployed	loki-6.46.0                           	3.5.7      
monitoring      	monitoring            	16      	2025-11-30 15:14:31.480625864 +0000 UTC	deployed	REDACTED_d8074874-79.9.0          	v0.86.2    
nfs-provisioner 	nfs-provisioner       	8       	2025-11-29 02:18:25.900770326 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail        	logging               	4       	2025-12-01 01:45:36.092885959 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
synology-csi    	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   5d18h
awx                      Active   26d
bentopdf                 Active   46h
cert-manager             Active   18h
cilium-secrets           Active   2d23h
cilium-spire             Active   2d13h
default                  Active   27d
external-secrets         Active   41h
REDACTED_01b50c5d   Active   7d
ingress-nginx            Active   25d
kube-node-lease          Active   27d
kube-public              Active   27d
kube-system              Active   27d
REDACTED_d97cef76     Active   27d
logging                  Active   23h
minio                    Active   6d12h
monitoring               Active   26d
nfs-provisioner          Active   25d
opentofu-ns              Active   25d
pihole                   Active   7d8h
production               Active   7d8h
synology-csi             Active   3d20h
velero                   Active   5d17h
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           5d18h
argocd                   argocd-redis                                      1/1     1            1           5d18h
argocd                   argocd-repo-server                                2/2     2            2           5d18h
argocd                   argocd-server                                     2/2     2            2           5d18h
awx                      awx-operator-controller-manager                   1/1     1            1           26d
awx                      my-awx-task                                       1/1     1            1           26d
awx                      my-awx-web                                        1/1     1            1           26d
bentopdf                 bentopdf                                          1/1     1            1           46h
cert-manager             cert-manager                                      1/1     1            1           17h
cert-manager             cert-manager-cainjector                           1/1     1            1           17h
cert-manager             cert-manager-webhook                              1/1     1            1           17h
external-secrets         external-secrets                                  1/1     1            1           41h
external-secrets         external-secrets-cert-controller                  1/1     1            1           41h
external-secrets         external-secrets-webhook                          1/1     1            1           41h
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           7d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           25d
kube-system              cilium-operator                                   1/1     1            1           2d23h
kube-system              coredns                                           2/2     2            2           27d
kube-system              hubble-relay                                      1/1     1            1           2d23h
kube-system              hubble-ui                                         1/1     1            1           2d23h
kube-system              metrics-server                                    1/1     1            1           27d
REDACTED_d97cef76     dashboard-metrics-scraper                         1/1     1            1           25d
REDACTED_d97cef76     REDACTED_d97cef76                              1/1     1            1           25d
minio                    minio                                             1/1     1            1           6d11h
monitoring               monitoring-grafana                                2/2     2            2           3d17h
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           25d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           25d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           25d
pihole                   pihole                                            1/1     1            1           43h
velero                   velero                                            1/1     1            1           5d17h
velero                   velero-ui                                         1/1     1            1           5d17h
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     5d18h
awx            my-awx-postgres-15                                     1/1     26d
cilium-spire   spire-server                                           1/1     2d13h
logging        loki                                                   1/1     22h
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     3d17h
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     3d18h
synology-csi   synology-csi-controller                                1/1     3d20h
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   2d13h
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   2d23h
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   2d23h
logging        promtail                              7         7         7       7            7           <none>                   22h
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   25d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   3d20h
velero         velero-node-agent                     4         4         4       4            4           <none>                   5d17h
```

---

*Full cluster context dump - v3.1.0*
