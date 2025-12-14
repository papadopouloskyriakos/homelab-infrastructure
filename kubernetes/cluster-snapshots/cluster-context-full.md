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

**Generated:** 2025-12-14 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | HEALTHY | ✅ |
| Unhealthy Pods | 0 | ✅ |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 195 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.18.4 |
| Nodes | 8 total (3 control-plane, 5 workers) |
| Total Pods | 138 |

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
- kube-system/kube-apiserver-nlk8s-ctrl01: 28 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 5 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 5 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 23 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 11 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 15 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 17 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 12 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 13 restarts
- monitoring/goldpinger-qs5xt: 4 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956swwjx: 5 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE      LAST SEEN   TYPE      REASON             OBJECT                                  MESSAGE
kube-system    20m         Warning   Unhealthy          pod/kube-apiserver-nlk8s-ctrl01   Readiness probe failed: HTTP probe failed with statuscode: 500
kube-system    2m42s       Warning   DNSConfigForming   pod/cilium-envoy-6ws74                  Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
synology-csi   2m21s       Warning   DNSConfigForming   pod/synology-csi-node-n4rjm             Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
kube-system    15s         Warning   DNSConfigForming   pod/cilium-rhcsd                        Nameserver limits were exceeded, some nameservers have been omitted, the applied nameserver line is: 1.1.1.1 1.0.0.1 1.1.1.1
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

### Namespace: `default`


### Namespace: `external-secrets`

1/- **Deployment: external-secrets** (1) → Svc:external-secrets-cert-controller-metrics (ClusterIP)
1/- **Deployment: external-secrets-cert-controller** (1) → Svc:external-secrets-cert-controller-metrics (ClusterIP)
1/- **Deployment: external-secrets-webhook** (1) → Svc:external-secrets-webhook (ClusterIP)

### Namespace: `REDACTED_01b50c5d`

2/- **Deployment: REDACTED_ab04b573-v2** (2)

### Namespace: `ingress-nginx`

2/- **Deployment: ingress-nginx-controller** (2)

### Namespace: `REDACTED_d97cef76`

1/- **Deployment: REDACTED_d97cef76-api** (1) → Svc:REDACTED_d97cef76-api (ClusterIP) → Ingress:nl-k8s.example.net
1/- **Deployment: REDACTED_d97cef76-auth** (1) → Svc:REDACTED_d97cef76-auth (ClusterIP) → Ingress:nl-k8s.example.net
1/- **Deployment: REDACTED_d97cef76-kong** (1) → Ingress:nl-k8s.example.net
1/- **Deployment: REDACTED_d97cef76-metrics-scraper** (1) → Svc:REDACTED_d97cef76-metrics-scraper (ClusterIP) → Ingress:nl-k8s.example.net
1/- **Deployment: REDACTED_d97cef76-web** (1) → Svc:REDACTED_d97cef76-web (ClusterIP) → Ingress:nl-k8s.example.net

### Namespace: `logging`

- **StatefulSet: loki** (1/1)

**Storage:**
- PVC: storage-loki-0 (10Gi, Bound, sc:REDACTED_4f3da73d)

**Secrets:**
- ExternalSecret: loki-s3-credentials (SecretSynced)

### Namespace: `monitoring`

2/- **Deployment: monitoring-grafana** (2) → Ingress:goldpinger.example.net
1/- **Deployment: monitoring-kube-prometheus-operator** (1) → Ingress:goldpinger.example.net
1/- **Deployment: monitoring-kube-state-metrics** (1) → Ingress:goldpinger.example.net
1/- **Deployment: snmp-exporter** (1) → Svc:snmp-exporter (ClusterIP) → Ingress:goldpinger.example.net
2/- **Deployment: thanos-query** (2) → Ingress:goldpinger.example.net
- **StatefulSet: alertmanager-monitoring-kube-prometheus-alertmanager** (2/2)
- **StatefulSet: prometheus-REDACTED_6dfbe9fc** (2/2)
- **StatefulSet: thanos-compactor** (1/1)
- **StatefulSet: thanos-store** (2/2)

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
- ExternalSecret: monitoring-grafana (SecretSynced)
- ExternalSecret: REDACTED_5f4971dc (SecretSynced)

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
nlk8s-ctrl01   1487m        37%      1953Mi          51%         
nlk8s-ctrl02   887m         22%      2638Mi          66%         
nlk8s-ctrl03   252m         6%       2168Mi          57%         
nlk8s-node01    342m         4%       3627Mi          46%         
nlk8s-node02    311m         3%       3974Mi          50%         
nlk8s-node03    376m         4%       3409Mi          43%         
nlk8s-node04    428m         5%       4370Mi          55%         
notrf01k8s-node01    67m          3%       571Mi           14%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              kube-apiserver-nlk8s-ctrl02                                 249m         1315Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                230m         1261Mi          
kube-system              etcd-nlk8s-ctrl02                                           185m         129Mi           
kube-system              cilium-mvsq5                                                      156m         154Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-1                144m         1291Mi          
kube-system              cilium-22zgh                                                      144m         359Mi           
kube-system              hubble-ui-576dcd986f-wthq8                                        137m         363Mi           
kube-system              kube-apiserver-nlk8s-ctrl03                                 119m         1389Mi          
logging                  promtail-8mpwp                                                    112m         99Mi            
kube-system              cilium-kghrg                                                      98m          199Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
awx                      my-awx-task-6f8f46478-wkz6j                                       48m          1446Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 119m         1389Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 249m         1315Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                144m         1291Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                230m         1261Mi          
awx                      my-awx-web-7bc5ccfbf4-bkrlp                                       7m           1216Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 87m          885Mi           
monitoring               monitoring-grafana-9ccf6f977-w47db                                10m          705Mi           
monitoring               monitoring-grafana-9ccf6f977-mhjwg                                10m          702Mi           
seaweedfs                seaweedfs-filer-1                                                 2m           453Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
kube-system: CPU=2050m Mem=440Mi
monitoring: CPU=1930m Mem=7120Mi
awx: CPU=1855m Mem=3552Mi
seaweedfs: CPU=1200m Mem=2944Mi
ingress-nginx: CPU=1000m Mem=1024Mi
argocd: CPU=750m Mem=1664Mi
velero: CPU=550m Mem=704Mi
logging: CPU=450m Mem=704Mi
REDACTED_d97cef76: CPU=400m Mem=800Mi
pihole: CPU=100m Mem=256Mi
```

---

## Network & Security

### PodDisruptionBudgets
```
NAMESPACE         NAME                                              MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
argocd            argocd-application-controller                     1               N/A               0                     16d
argocd            argocd-applicationset-controller                  1               N/A               0                     16d
argocd            argocd-redis                                      1               N/A               0                     16d
argocd            argocd-repo-server                                1               N/A               1                     16d
argocd            argocd-server                                     1               N/A               1                     16d
awx               awx-postgres-pdb                                  1               N/A               0                     16d
awx               awx-task-pdb                                      1               N/A               0                     16d
awx               awx-web-pdb                                       1               N/A               0                     16d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     16d
kube-system       coredns-pdb                                       1               N/A               1                     16d
kube-system       metrics-server-pdb                                1               N/A               0                     16d
monitoring        monitoring-grafana                                1               N/A               1                     16d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     16d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     16d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     16d
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
| ClusterIP | 67 |
| NodePort | 6 |
| LoadBalancer | 6 |

### LoadBalancer Services
```
NAMESPACE       NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   38d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               7d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 15d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                13d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 15d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 15d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                               ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net          10.0.X.X   80, 443   18d
awx                    awx                    nginx    awx.example.net             10.0.X.X   80        17d
bentopdf               bentopdf               nginx    bentopdf.example.net        10.0.X.X   80        14d
kube-system            hubble-ui              nginx    nl-hubble.example.net       10.0.X.X   80        2d2h
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net          10.0.X.X   80        39h
monitoring             goldpinger             nginx    goldpinger.example.net      10.0.X.X   80        6d3h
monitoring             grafana                nginx    grafana.example.net         10.0.X.X   80        17d
monitoring             prometheus             nginx    nl-prometheus.example.net   10.0.X.X   80        29h
monitoring             thanos-query           nginx    nl-thanos.example.net       10.0.X.X   80        2d3h
pihole                 pihole-ingress         nginx    pihole.example.net          10.0.X.X   80        19d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net    10.0.X.X   80        3d3h
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net           10.0.X.X   80        3d3h
velero                 velero-ui              nginx    velero.example.net          10.0.X.X   80        18d
```

---

#***REMOVED***

| Metric | Count |
|--------|-------|
| StorageClasses | 10 |
| PersistentVolumes | 27 |
| PersistentVolumeClaims | 20 |

##***REMOVED***Classes
```
NAME                                      PROVISIONER                                                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   19d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   39d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   16d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   16d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   16d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   16d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   16d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   16d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   16d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   16d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 3 |
| External Secrets | 13 |
| Certificates | 1 |
| ServiceMonitors | 26 |
| CiliumNetworkPolicies | 2 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE   PAUSED
daily-backup    Enabled   0 2 * * *   61m          18d   
weekly-backup   Enabled   0 3 * * 0   69s          18d   
```

### Recent Backups (last 5)
```
daily-backup-20251210020047    4d1h
daily-backup-20251211020048    3d1h
daily-backup-20251212020031    2d1h
daily-backup-20251213020032    25h
daily-backup-20251214020033    61m
```

---

## Helm Releases
```
NAME                	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd              	argocd                	3       	2025-11-29 02:18:52.98547378 +0000 UTC 	deployed	argo-cd-7.7.10                        	v2.13.2    
cert-manager        	cert-manager          	3       	2025-11-30 21:22:09.520251302 +0000 UTC	deployed	cert-manager-v1.17.1                  	v1.17.1    
cilium              	kube-system           	20      	2025-12-12 16:06:57.516153767 +0000 UTC	deployed	cilium-1.18.4                         	1.18.4     
external-secrets    	external-secrets      	1       	2025-11-29 19:53:58.182715236 +0000 UTC	deployed	external-secrets-0.12.1               	v0.12.1    
ingress-nginx       	ingress-nginx         	6       	2025-11-30 20:29:39.171185711 +0000 UTC	deployed	ingress-nginx-4.14.0                  	1.14.0     
k8s-agent           	REDACTED_01b50c5d	6       	2025-11-29 02:18:29.271243252 +0000 UTC	deployed	gitlab-agent-2.21.1                   	v18.6.1    
REDACTED_d97cef76	REDACTED_d97cef76  	1       	2025-12-12 11:22:00.351838712 +0000 UTC	deployed	REDACTED_d97cef76-7.14.0           	           
loki                	logging               	5       	2025-12-11 21:14:28.613285343 +0000 UTC	deployed	loki-6.46.0                           	3.5.7      
monitoring          	monitoring            	22      	2025-12-12 20:41:08.664039333 +0000 UTC	deployed	REDACTED_d8074874-79.10.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	8       	2025-11-29 02:18:25.900770326 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail            	logging               	4       	2025-12-01 01:45:36.092885959 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
seaweedfs           	seaweedfs             	1       	2025-12-11 00:12:58.814719121 +0000 UTC	deployed	seaweedfs-4.0.401                     	4.01       
synology-csi        	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   18d
awx                      Active   39d
bentopdf                 Active   14d
cert-manager             Active   13d
cilium-secrets           Active   15d
cilium-spire             Active   15d
default                  Active   40d
external-secrets         Active   14d
REDACTED_01b50c5d   Active   19d
ingress-nginx            Active   38d
kube-node-lease          Active   40d
kube-public              Active   40d
kube-system              Active   40d
REDACTED_d97cef76     Active   39h
logging                  Active   13d
monitoring               Active   39d
nfs-provisioner          Active   38d
opentofu-ns              Active   38d
pihole                   Active   19d
production               Active   19d
seaweedfs                Active   3d5h
synology-csi             Active   16d
velero                   Active   18d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           18d
argocd                   argocd-redis                                      1/1     1            1           18d
argocd                   argocd-repo-server                                2/2     2            2           18d
argocd                   argocd-server                                     2/2     2            2           18d
awx                      awx-operator-controller-manager                   1/1     1            1           39d
awx                      my-awx-task                                       1/1     1            1           39d
awx                      my-awx-web                                        1/1     1            1           39d
bentopdf                 bentopdf                                          1/1     1            1           14d
cert-manager             cert-manager                                      1/1     1            1           13d
cert-manager             cert-manager-cainjector                           1/1     1            1           13d
cert-manager             cert-manager-webhook                              1/1     1            1           13d
external-secrets         external-secrets                                  1/1     1            1           14d
external-secrets         external-secrets-cert-controller                  1/1     1            1           14d
external-secrets         external-secrets-webhook                          1/1     1            1           14d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           19d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           38d
kube-system              cilium-operator                                   1/1     1            1           15d
kube-system              clustermesh-apiserver                             1/1     1            1           7d
kube-system              coredns                                           2/2     2            2           40d
kube-system              hubble-relay                                      1/1     1            1           15d
kube-system              hubble-ui                                         1/1     1            1           15d
kube-system              metrics-server                                    1/1     1            1           39d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           39h
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           39h
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           39h
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           39h
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           39h
monitoring               monitoring-grafana                                2/2     2            2           16d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           38d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           38d
monitoring               snmp-exporter                                     1/1     1            1           31h
monitoring               thanos-query                                      2/2     2            2           2d3h
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           38d
pihole                   pihole                                            1/1     1            1           14d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           2d10h
velero                   velero                                            1/1     1            1           18d
velero                   velero-ui                                         1/1     1            1           18d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     18d
awx            my-awx-postgres-15                                     1/1     39d
cilium-spire   spire-server                                           1/1     15d
logging        loki                                                   1/1     13d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     16d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     16d
monitoring     thanos-compactor                                       1/1     2d3h
monitoring     thanos-store                                           2/2     2d3h
seaweedfs      seaweedfs-filer                                        2/2     3d4h
seaweedfs      seaweedfs-master                                       3/3     3d4h
seaweedfs      seaweedfs-volume                                       2/2     3d4h
synology-csi   synology-csi-controller                                1/1     16d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           8         8         8       8            8           <none>                   15d
kube-system    cilium                                8         8         8       8            8           kubernetes.io/os=linux   15d
kube-system    cilium-envoy                          8         8         8       8            8           kubernetes.io/os=linux   15d
logging        loki-canary                           4         4         4       4            4           <none>                   2d9h
logging        promtail                              7         7         7       7            7           <none>                   13d
monitoring     goldpinger                            8         8         8       8            8           <none>                   6d3h
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   38d
synology-csi   synology-csi-node                     8         8         8       8            8           <none>                   16d
velero         velero-node-agent                     4         4         4       4            4           <none>                   18d
```

---

*Full cluster context dump - v3.1.0*
