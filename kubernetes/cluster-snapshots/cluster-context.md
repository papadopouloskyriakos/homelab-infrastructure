# Kubernetes Cluster Context Dump
<!-- 
LLM INSTRUCTIONS:
- This is a point-in-time snapshot of a Kubernetes cluster for analysis/troubleshooting
- Health Summary section indicates overall cluster state - check this first
- Anomalies section lists items requiring attention
- Workload Map shows relationships: Deployment → Pod → Service → Ingress
- Use this context to answer questions about cluster state, diagnose issues, or suggest improvements
-->

**Generated:** 2025-12-01 12:52:35 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.0.1

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | HEALTHY | ✅ |
| Unhealthy Pods | 0 | ✅ |
| Pending PVCs | 0 | ✅ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.18.4 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 104 |

### Node Details

| Node | Role | IP | Status | CPU | Memory |
|------|------|-----|--------|-----|--------|
| nlk8s-ctrl01 | control-plane | Ready | 4 | 3886100Ki |  |
| nlk8s-ctrl02 | control-plane | Ready | 4 | 3996Mi |  |
| nlk8s-ctrl03 | control-plane | Ready | 4 | 3886092Ki |  |
| nlk8s-node01 | worker | 10.0.X.X | Ready | 8 | 8006752Ki |
| nlk8s-node02 | worker | 10.0.X.X | Ready | 8 | 8006740Ki |
| nlk8s-node03 | worker | 10.0.X.X | Ready | 8 | 8006740Ki |
| nlk8s-node04 | worker | 10.0.X.X | Ready | 8 | 8006736Ki |

---

## Anomalies & Issues

### Unhealthy Pods
_None - all pods are Running or Completed_

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events (last 1 hour)
```
NAMESPACE     LAST SEEN   TYPE      REASON      OBJECT                                  MESSAGE
kube-system   7m49s       Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Readiness probe failed: HTTP probe failed with statuscode: 500
```

---

## Workload Map

### Namespace: `argocd`

- **Deployment: argocd-applicationset-controller** (1/1) → Svc:argocd-applicationset-controller (ClusterIP) → Ingress: argocd.example.net
- **Deployment: argocd-redis** (1/1) → Svc:argocd-applicationset-controller (ClusterIP) → Ingress: argocd.example.net
- **Deployment: argocd-repo-server** (2/2) → Svc:argocd-applicationset-controller (ClusterIP) → Ingress: argocd.example.net
- **Deployment: argocd-server** (2/2) → Svc:argocd-applicationset-controller (ClusterIP) → Ingress: argocd.example.net
- **StatefulSet: argocd-application-controller** (1/1)

**Secrets:**
- ExternalSecret: gitlab-repo-creds (SecretSynced)

### Namespace: `awx`

- **Deployment: awx-operator-controller-manager** (1/1) → Svc:REDACTED_ce3f365d (ClusterIP) → Ingress: awx.example.net
- **Deployment: my-awx-task** (1/1) → Svc:REDACTED_ce3f365d (ClusterIP) → Ingress: awx.example.net
- **Deployment: my-awx-web** (1/1) → Svc:REDACTED_ce3f365d (ClusterIP) → Ingress: awx.example.net
- **StatefulSet: my-awx-postgres-15** (1/1)

**Storage:**
- PVC: my-awx-projects (50Gi, Bound)
- PVC: REDACTED_0d7ca6a5 (50Gi, Bound)

**Secrets:**
- ExternalSecret: k8s-api-credentials (SecretSynced)
- ExternalSecret: npm-credentials (SecretSynced)

### Namespace: `bentopdf`

- **Deployment: bentopdf** (1/1) → Svc:bentopdf (ClusterIP) → Ingress: bentopdf.example.net

### Namespace: `cert-manager`

- **Deployment: cert-manager** (1/1) → Svc:cert-manager (ClusterIP) 
- **Deployment: cert-manager-cainjector** (1/1) → Svc:cert-manager (ClusterIP) 
- **Deployment: cert-manager-webhook** (1/1) → Svc:cert-manager (ClusterIP) 

**Secrets:**
- ExternalSecret: REDACTED_fb8d60db (SecretSynced)

### Namespace: `cilium-spire`

- **StatefulSet: spire-server** (1/1)

**Storage:**
- PVC: spire-data-spire-server-0 (1Gi, Bound)

### Namespace: `external-secrets`

- **Deployment: external-secrets** (1/1) → Svc:external-secrets-cert-controller-metrics (ClusterIP) 
- **Deployment: external-secrets-cert-controller** (1/1) → Svc:external-secrets-cert-controller-metrics (ClusterIP) 
- **Deployment: external-secrets-webhook** (1/1) → Svc:external-secrets-cert-controller-metrics (ClusterIP) 

### Namespace: `REDACTED_01b50c5d`

- **Deployment: REDACTED_ab04b573-v2** (2/2) → Svc:REDACTED_ab04b573-service (ClusterIP) 

### Namespace: `ingress-nginx`

- **Deployment: ingress-nginx-controller** (2/2) → Svc:ingress-nginx-controller (LoadBalancer 10.0.X.X) 

### Namespace: `REDACTED_d97cef76`

- **Deployment: dashboard-metrics-scraper** (1/1) → Svc:dashboard-metrics-scraper (ClusterIP) → Ingress: k8s.example.net
- **Deployment: REDACTED_d97cef76** (1/1) → Svc:dashboard-metrics-scraper (ClusterIP) → Ingress: k8s.example.net

### Namespace: `logging`

- **StatefulSet: loki** (1/1)

**Storage:**
- PVC: storage-loki-0 (10Gi, Bound)

**Secrets:**
- ExternalSecret: loki-minio-credentials (SecretSynced)

### Namespace: `minio`

- **Deployment: minio** (1/1) → Svc:minio-api (NodePort) → Ingress: minio.example.net

**Storage:**
- PVC: minio-data-csi (1Ti, Bound)

**Secrets:**
- ExternalSecret: minio-credentials (SecretSynced)
- ExternalSecret: minio-snapshot-credentials (SecretSynced)

### Namespace: `monitoring`

- **Deployment: monitoring-grafana** (2/2) → Svc:alertmanager-operated (ClusterIP) → Ingress: grafana.example.net
- **Deployment: monitoring-kube-prometheus-operator** (1/1) → Svc:alertmanager-operated (ClusterIP) → Ingress: grafana.example.net
- **Deployment: monitoring-kube-state-metrics** (1/1) → Svc:alertmanager-operated (ClusterIP) → Ingress: grafana.example.net
- **StatefulSet: alertmanager-monitoring-kube-prometheus-alertmanager** (2/2)
- **StatefulSet: prometheus-REDACTED_6dfbe9fc** (2/2)

**Storage:**
- PVC: alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-0 (10Gi, Bound)
- PVC: alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-1 (10Gi, Bound)
- PVC: monitoring-grafana (20Gi, Bound)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-0 (200Gi, Bound)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-1 (200Gi, Bound)

**Secrets:**
- ExternalSecret: monitoring-grafana (SecretSynced)

### Namespace: `nfs-provisioner`

- **Deployment: nfs-provisioner-REDACTED_5fef70be** (1/1)  

### Namespace: `pihole`

- **Deployment: pihole** (1/1) → Svc:pihole-dns-lb (LoadBalancer 10.0.X.X) → Ingress: pihole.example.net

**Storage:**
- PVC: pihole-data (1Gi, Bound)

**Secrets:**
- ExternalSecret: pihole-credentials (SecretSynced)

### Namespace: `synology-csi`

- **StatefulSet: synology-csi-controller** (1/1)

### Namespace: `velero`

- **Deployment: velero** (1/1) → Svc:velero-ui (NodePort) → Ingress: velero.example.net
- **Deployment: velero-ui** (1/1) → Svc:velero-ui (NodePort) → Ingress: velero.example.net

**Secrets:**
- ExternalSecret: velero-repo-credentials (SecretSynced)
- ExternalSecret: velero-s3-credentials (SecretSynced)


---

## Resource Utilization

### Node Resources
```
NAME                 CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
nlk8s-ctrl01   985m         24%      2020Mi          53%         
nlk8s-ctrl02   704m         17%      2277Mi          57%         
nlk8s-ctrl03   279m         6%       2130Mi          56%         
nlk8s-node01    223m         2%       3170Mi          40%         
nlk8s-node02    282m         3%       2587Mi          33%         
nlk8s-node03    172m         2%       4492Mi          57%         
nlk8s-node04    201m         2%       2400Mi          30%         
```

### Top Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              kube-apiserver-nlk8s-ctrl02                                 244m         1143Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                229m         1111Mi          
kube-system              etcd-nlk8s-ctrl02                                           203m         112Mi           
kube-system              kube-apiserver-nlk8s-ctrl01                                 140m         1293Mi          
kube-system              cilium-88kc5                                                      120m         145Mi           
kube-system              kube-apiserver-nlk8s-ctrl03                                 109m         1215Mi          
kube-system              cilium-lhv26                                                      96m          143Mi           
kube-system              cilium-l2lvv                                                      85m          142Mi           
kube-system              etcd-nlk8s-ctrl01                                           81m          93Mi            
kube-system              cilium-7mwgn                                                      75m          141Mi           
kube-system              cilium-x58c7                                                      74m          172Mi           
kube-system              hubble-ui-576dcd986f-df2wz                                        73m          101Mi           
kube-system              etcd-nlk8s-ctrl03                                           70m          118Mi           
kube-system              cilium-kshc6                                                      48m          149Mi           
Metrics server not available
```

### Top Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
awx                      my-awx-task-665479ff65-hk8nj                                      34m          1479Mi          
awx                      my-awx-web-694487457f-4m8kx                                       6m           1313Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 140m         1293Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 109m         1215Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 244m         1143Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                229m         1111Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                43m          1048Mi          
monitoring               monitoring-grafana-8487cccf54-5tg9p                               7m           524Mi           
monitoring               monitoring-grafana-8487cccf54-6bbcx                               8m           524Mi           
logging                  loki-0                                                            19m          292Mi           
argocd                   argocd-application-controller-0                                   6m           225Mi           
minio                    minio-755b65f5b8-2jnkh                                            1m           203Mi           
velero                   velero-ui-7bcfc7d884-9hnvl                                        1m           178Mi           
kube-system              cilium-x58c7                                                      74m          172Mi           
Metrics server not available
```

---

#***REMOVED*** Summary

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

## Installed Operators & CRDs

### CRD Groups (by count)
```
     19 cilium.io
     13 velero.io
     12 configuration.konghq.com
     11 generators.external-secrets.io
     10 monitoring.coreos.com
      7 metallb.io
      5 external-secrets.io
      4 cert-manager.io
      4 awx.ansible.com
      3 argoproj.io
      2 acme.cert-manager.io
```

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
daily-backup    Enabled   0 2 * * *   10h          5d17h   
weekly-backup   Enabled   0 3 * * 0   33h          5d17h   
```

### Recent Backups
```
daily-backup-20251127020025    4d10h
pre-migration-full             3d12h
daily-backup-20251128114425    3d1h
pre-cilium-migration           3d
post-cilium-migration          2d21h
daily-backup-20251129020047    2d10h
daily-backup-20251130020048    34h
weekly-backup-20251130030048   33h
test-creds-1764505956          24h
daily-backup-20251201020003    10h
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

## Network Configuration

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
minio                  minio-console          nginx   minio.example.net      10.0.X.X   80        6d11h
monitoring             grafana                nginx   grafana.example.net    10.0.X.X   80        4d13h
pihole                 pihole-ingress         nginx   pihole.example.net     10.0.X.X   80        7d8h
velero                 velero-ui              nginx   velero.example.net     10.0.X.X   80        5d17h
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   5d18h
awx                      Active   26d
bentopdf                 Active   46h
cert-manager             Active   17h
cilium-secrets           Active   2d23h
cilium-spire             Active   2d13h
default                  Active   27d
external-secrets         Active   41h
REDACTED_01b50c5d   Active   6d23h
ingress-nginx            Active   25d
kube-node-lease          Active   27d
kube-public              Active   27d
kube-system              Active   27d
REDACTED_d97cef76     Active   27d
logging                  Active   23h
minio                    Active   6d11h
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
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           6d23h
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
logging        loki                                                   1/1     21h
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
logging        promtail                              7         7         7       7            7           <none>                   21h
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   25d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   3d20h
velero         velero-node-agent                     4         4         4       4            4           <none>                   5d17h
```

---

*End of cluster context dump*
