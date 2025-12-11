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

**Generated:** 2025-12-11 19:58:18 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | HEALTHY | ✅ |
| Unhealthy Pods | 0 | ✅ |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 159 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.18.4 |
| Nodes | 8 total (3 control-plane, 5 workers) |
| Total Pods | 129 |

### Node Details (with Taints & Labels)

#### nlk8s-ctrl01
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 3795Mi
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-ctrl02
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 3996Mi
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-ctrl03
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 3886092Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node01
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006756Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node02
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006748Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node03
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006740Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node04
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006752Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### notrf01k8s-node01
- **Role:** worker
- **IP:** 10.255.3.11
- **Status:** True
- **CPU:** 2 | **Memory:** 3907488Ki
- **Taints:** node-type=edge:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=, topology.kubernetes.io/region=no-trf, topology.kubernetes.io/zone=no-trf-01


---

## Anomalies & Issues

### Unhealthy Pods
_None - all pods are Running or Completed_

### High Restart Pods (>3 restarts)
- kube-system/etcd-nlk8s-ctrl01: 7 restarts
- kube-system/etcd-nlk8s-ctrl02: 5 restarts
- kube-system/etcd-nlk8s-ctrl03: 4 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 26 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 5 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 5 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 23 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 11 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 14 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 17 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 12 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 13 restarts
- logging/loki-0: 9 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE      LAST SEEN   TYPE      REASON             OBJECT                        MESSAGE
kube-system    4m30s       Warning   DNSConfigForming   pod/cilium-envoy-6ws74        Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
synology-csi   4m28s       Warning   DNSConfigForming   pod/synology-csi-node-n4rjm   Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
kube-system    2m43s       Warning   DNSConfigForming   pod/cilium-rhcsd              Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
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
- ExternalSecret: argocd-redis (SecretSynced)
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

2/- **Deployment: monitoring-grafana** (2) → Ingress:goldpinger.example.net
1/- **Deployment: monitoring-kube-prometheus-operator** (1) → Ingress:goldpinger.example.net
1/- **Deployment: monitoring-kube-state-metrics** (1) → Ingress:goldpinger.example.net
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

### Namespace: `seaweedfs`

1/- **Deployment: seaweedfs-filer-sync** (1) → Ingress:nl-seaweedfs.example.net
- **StatefulSet: seaweedfs-filer** (2/2)
- **StatefulSet: seaweedfs-master** (3/3)
- **StatefulSet: seaweedfs-volume** (2/2)

**Storage:**
- PVC: data-filer-seaweedfs-filer-0 (20Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-filer-seaweedfs-filer-1 (20Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-seaweedfs-master-0 (10Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-seaweedfs-master-1 (10Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-seaweedfs-master-2 (10Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-volume-0 (500Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-volume-1 (500Gi, Bound, sc:REDACTED_b280aec5)

**Secrets:**
- ExternalSecret: seaweedfs-s3-config (SecretSynced)

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
nlk8s-ctrl01   1459m        36%      2211Mi          58%         
nlk8s-ctrl02   693m         17%      2434Mi          60%         
nlk8s-ctrl03   244m         6%       2430Mi          64%         
nlk8s-node01    280m         3%       4838Mi          61%         
nlk8s-node02    216m         2%       4321Mi          55%         
nlk8s-node03    166m         2%       3549Mi          45%         
nlk8s-node04    259m         3%       4009Mi          51%         
notrf01k8s-node01    44m          2%       542Mi           14%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              kube-apiserver-nlk8s-ctrl02                                 244m         1073Mi          
kube-system              etcd-nlk8s-ctrl02                                           171m         127Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-1                160m         1498Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 142m         1321Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 141m         1405Mi          
kube-system              cilium-mvsq5                                                      112m         146Mi           
kube-system              hubble-ui-576dcd986f-wthq8                                        111m         208Mi           
kube-system              cilium-22zgh                                                      103m         289Mi           
kube-system              etcd-nlk8s-ctrl01                                           73m          113Mi           
kube-system              cilium-kghrg                                                      64m          146Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-1                160m         1498Mi          
awx                      my-awx-task-6f8f46478-wkz6j                                       22m          1486Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                44m          1447Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 141m         1405Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 142m         1321Mi          
awx                      my-awx-web-7bc5ccfbf4-bkrlp                                       6m           1216Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 244m         1073Mi          
monitoring               monitoring-grafana-9ccf6f977-w47db                                8m           690Mi           
monitoring               monitoring-grafana-9ccf6f977-mhjwg                                8m           680Mi           
minio                    minio-755b65f5b8-6x8tm                                            1m           404Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
kube-system: CPU=2050m Mem=440Mi
awx: CPU=1855m Mem=3552Mi
monitoring: CPU=1280m Mem=4752Mi
seaweedfs: CPU=1200m Mem=2944Mi
ingress-nginx: CPU=1000m Mem=1024Mi
argocd: CPU=750m Mem=1664Mi
velero: CPU=550m Mem=704Mi
logging: CPU=450m Mem=704Mi
minio: CPU=100m Mem=256Mi
pihole: CPU=100m Mem=256Mi
```

---

## Network & Security

### PodDisruptionBudgets
```
NAMESPACE         NAME                                              MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
argocd            argocd-application-controller                     1               N/A               0                     14d
argocd            argocd-applicationset-controller                  1               N/A               0                     14d
argocd            argocd-redis                                      1               N/A               0                     14d
argocd            argocd-repo-server                                1               N/A               1                     14d
argocd            argocd-server                                     1               N/A               1                     14d
awx               awx-postgres-pdb                                  1               N/A               0                     14d
awx               awx-task-pdb                                      1               N/A               0                     14d
awx               awx-web-pdb                                       1               N/A               0                     14d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     14d
kube-system       coredns-pdb                                       1               N/A               1                     14d
kube-system       metrics-server-pdb                                1               N/A               0                     14d
minio             minio-pdb                                         1               N/A               0                     14d
monitoring        monitoring-grafana                                1               N/A               1                     14d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     14d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     14d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     14d
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
| ClusterIP | 56 |
| NodePort | 9 |
| LoadBalancer | 6 |

### LoadBalancer Services
```
NAMESPACE       NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   35d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               4d17h
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 12d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                10d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 12d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 12d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                              ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net         10.0.X.X   80, 443   16d
awx                    awx                    nginx    awx.example.net            10.0.X.X   80        14d
bentopdf               bentopdf               nginx    bentopdf.example.net       10.0.X.X   80        12d
kube-system            hubble-ui              nginx    hubble.example.net         10.0.X.X   80, 443   13d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    k8s.example.net            10.0.X.X   80        14d
minio                  minio-console          nginx    minio.example.net          10.0.X.X   80        16d
monitoring             goldpinger             nginx    goldpinger.example.net     10.0.X.X   80        3d20h
monitoring             grafana                nginx    grafana.example.net        10.0.X.X   80        14d
pihole                 pihole-ingress         nginx    pihole.example.net         10.0.X.X   80        17d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net   10.0.X.X   80        20h
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net          10.0.X.X   80        20h
velero                 velero-ui              nginx    velero.example.net         10.0.X.X   80        16d
```

---

#***REMOVED***

| Metric | Count |
|--------|-------|
| StorageClasses | 10 |
| PersistentVolumes | 21 |
| PersistentVolumeClaims | 18 |

##***REMOVED***Classes
```
NAME                                      PROVISIONER                                                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   16d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   37d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   14d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   14d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   14d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   14d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   14d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   14d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   14d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   14d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 3 |
| External Secrets | 14 |
| Certificates | 1 |
| ServiceMonitors | 24 |
| CiliumNetworkPolicies | 2 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE   PAUSED
daily-backup    Enabled   0 2 * * *   17h          16d   
weekly-backup   Enabled   0 3 * * 0   4d16h        16d   
```

### Recent Backups (last 5)
```
weekly-backup-20251207030043   4d16h
daily-backup-20251208020044    3d17h
daily-backup-20251209020045    2d17h
daily-backup-20251210020047    41h
daily-backup-20251211020048    17h
```

---

## Helm Releases
```
NAME            	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd          	argocd                	3       	2025-11-29 02:18:52.98547378 +0000 UTC 	deployed	argo-cd-7.7.10                        	v2.13.2    
cert-manager    	cert-manager          	3       	2025-11-30 21:22:09.520251302 +0000 UTC	deployed	cert-manager-v1.17.1                  	v1.17.1    
cilium          	kube-system           	19      	2025-12-11 14:58:06.227787242 +0000 UTC	deployed	cilium-1.18.4                         	1.18.4     
external-secrets	external-secrets      	1       	2025-11-29 19:53:58.182715236 +0000 UTC	deployed	external-secrets-0.12.1               	v0.12.1    
ingress-nginx   	ingress-nginx         	6       	2025-11-30 20:29:39.171185711 +0000 UTC	deployed	ingress-nginx-4.14.0                  	1.14.0     
k8s-agent       	REDACTED_01b50c5d	6       	2025-11-29 02:18:29.271243252 +0000 UTC	deployed	gitlab-agent-2.21.1                   	v18.6.1    
loki            	logging               	4       	2025-12-11 18:26:31.871759393 +0000 UTC	deployed	loki-6.46.0                           	3.5.7      
monitoring      	monitoring            	17      	2025-12-01 21:21:45.662633308 +0000 UTC	deployed	REDACTED_d8074874-79.10.0         	v0.86.2    
nfs-provisioner 	nfs-provisioner       	8       	2025-11-29 02:18:25.900770326 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail        	logging               	4       	2025-12-01 01:45:36.092885959 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
seaweedfs       	seaweedfs             	1       	2025-12-11 00:12:58.814719121 +0000 UTC	deployed	seaweedfs-4.0.401                     	4.01       
synology-csi    	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   16d
awx                      Active   37d
bentopdf                 Active   12d
cert-manager             Active   11d
cilium-secrets           Active   13d
cilium-spire             Active   12d
default                  Active   37d
external-secrets         Active   12d
REDACTED_01b50c5d   Active   17d
ingress-nginx            Active   35d
kube-node-lease          Active   37d
kube-public              Active   37d
kube-system              Active   37d
REDACTED_d97cef76     Active   37d
logging                  Active   11d
minio                    Active   16d
monitoring               Active   36d
nfs-provisioner          Active   36d
opentofu-ns              Active   35d
pihole                   Active   17d
production               Active   17d
seaweedfs                Active   22h
synology-csi             Active   14d
velero                   Active   16d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           16d
argocd                   argocd-redis                                      1/1     1            1           16d
argocd                   argocd-repo-server                                2/2     2            2           16d
argocd                   argocd-server                                     2/2     2            2           16d
awx                      awx-operator-controller-manager                   1/1     1            1           37d
awx                      my-awx-task                                       1/1     1            1           37d
awx                      my-awx-web                                        1/1     1            1           37d
bentopdf                 bentopdf                                          1/1     1            1           12d
cert-manager             cert-manager                                      1/1     1            1           11d
cert-manager             cert-manager-cainjector                           1/1     1            1           11d
cert-manager             cert-manager-webhook                              1/1     1            1           11d
external-secrets         external-secrets                                  1/1     1            1           12d
external-secrets         external-secrets-cert-controller                  1/1     1            1           12d
external-secrets         external-secrets-webhook                          1/1     1            1           12d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           17d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           35d
kube-system              cilium-operator                                   1/1     1            1           13d
kube-system              clustermesh-apiserver                             1/1     1            1           4d17h
kube-system              coredns                                           2/2     2            2           37d
kube-system              hubble-relay                                      1/1     1            1           13d
kube-system              hubble-ui                                         1/1     1            1           13d
kube-system              metrics-server                                    1/1     1            1           37d
REDACTED_d97cef76     dashboard-metrics-scraper                         1/1     1            1           35d
REDACTED_d97cef76     REDACTED_d97cef76                              1/1     1            1           35d
minio                    minio                                             1/1     1            1           16d
monitoring               monitoring-grafana                                2/2     2            2           14d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           36d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           36d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           36d
pihole                   pihole                                            1/1     1            1           12d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           3h51m
velero                   velero                                            1/1     1            1           16d
velero                   velero-ui                                         1/1     1            1           16d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     16d
awx            my-awx-postgres-15                                     1/1     37d
cilium-spire   spire-server                                           1/1     12d
logging        loki                                                   1/1     11d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     14d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     14d
seaweedfs      seaweedfs-filer                                        2/2     21h
seaweedfs      seaweedfs-master                                       3/3     21h
seaweedfs      seaweedfs-volume                                       2/2     21h
synology-csi   synology-csi-controller                                1/1     14d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           8         8         8       8            8           <none>                   12d
kube-system    cilium                                8         8         8       8            8           kubernetes.io/os=linux   13d
kube-system    cilium-envoy                          8         8         8       8            8           kubernetes.io/os=linux   13d
logging        loki-canary                           4         4         4       4            4           <none>                   133m
logging        promtail                              7         7         7       7            7           <none>                   11d
monitoring     goldpinger                            8         8         8       8            8           <none>                   3d20h
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   36d
synology-csi   synology-csi-node                     8         8         8       8            8           <none>                   14d
velero         velero-node-agent                     4         4         4       4            4           <none>                   16d
```

---

*Full cluster context dump - v3.1.0*
