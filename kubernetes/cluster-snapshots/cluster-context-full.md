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

**Generated:** 2026-03-15 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | DEGRADED | ⚠️ |
| Unhealthy Pods | 1 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 1200 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.34.2 |
| CNI | Cilium 1.18.4 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 145 |

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
- **CPU:** 4 | **Memory:** 3884328Ki
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
- **CPU:** 8 | **Memory:** 8006732Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node04
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 8006740Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01


---

## Anomalies & Issues

### Unhealthy Pods
```
seaweedfs                seaweedfs-filer-0                                                 0/1   ContainerCreating   0                 4h36m
```

#### Unhealthy Pod Details

**seaweedfs/seaweedfs-filer-0:**
```
Events:
  Type     Reason       Age                   From     Message
  ----     ------       ----                  ----     -------
  Warning  FailedMount  44s (x97 over 4h36m)  kubelet  MountVolume.MountDevice failed for volume "REDACTED_e7c2cc95" : rpc error: code = Internal desc = mount failed: exit status 32
Mounting command: mount
Mounting arguments: -t ext4 -o rw,defaults /dev/disk/by-path/ip-10.0.X.X:3260-iscsi-iqn.2000-01.com.synology:nl-nas01.REDACTED_e7c2cc95-lun-2 /var/lib/kubelet/plugins/kubernetes.io/csi/csi.san.synology.com/801db6d36e18e09037c25ebc412adde82a12af741e54bf9d77312a71d14ffee6/globalmount
Output: mount: /var/lib/kubelet/plugins/kubernetes.io/csi/csi.san.synology.com/801db6d36e18e09037c25ebc412adde82a12af741e54bf9d77312a71d14ffee6/globalmount: fsconfig system call failed: /dev/sdh: Can't open blockdev.
       dmesg(1) may have more information after failed mount system call.
```

### High Restart Pods (>3 restarts)
- awx/awx-operator-controller-manager-846b99bbd-t9589: 15 restarts
- awx/my-awx-web-7bc5ccfbf4-bkrlp: 92 restarts
- cert-manager/cert-manager-75944f484-4v6qh: 11 restarts
- cert-manager/cert-manager-cainjector-56b4cf957-s7xd9: 8 restarts
- cilium-spire/spire-agent-xwbn2: 8 restarts
- kube-system/cilium-22zgh: 8 restarts
- kube-system/cilium-envoy-mmfnj: 8 restarts
- kube-system/cilium-operator-6b94496fcd-l6cjl: 93 restarts
- kube-system/etcd-nlk8s-ctrl01: 62 restarts
- kube-system/etcd-nlk8s-ctrl02: 38 restarts
- kube-system/etcd-nlk8s-ctrl03: 5 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 378 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 55 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 13 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 85 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 24 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 76 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 23 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 23 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 21 restarts
- kube-system/tetragon-mdsn9: 16 restarts
- logging/loki-0: 44 restarts
- monitoring/goldpinger-4fvxd: 9 restarts
- monitoring/goldpinger-cjzc4: 4 restarts
- monitoring/goldpinger-qs5xt: 5 restarts
- monitoring/monitoring-grafana-68dbd786f9-9m48b: 7 restarts
- monitoring/monitoring-grafana-68dbd786f9-zs6md: 4 restarts
- monitoring/monitoring-kube-state-metrics-74d579585b-6cprn: 12 restarts
- monitoring/monitoring-prometheus-node-exporter-d5wkz: 8 restarts
- monitoring/thanos-compactor-0: 6 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-84888b4956swwjx: 23 restarts
- seaweedfs/seaweedfs-master-2: 111 restarts
- synology-csi/synology-csi-node-zch7n: 16 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE     LAST SEEN   TYPE      REASON        OBJECT                                  MESSAGE
kube-system   17m         Warning   Unhealthy     pod/kube-apiserver-nlk8s-ctrl01   Liveness probe failed: HTTP probe failed with statuscode: 500
kube-system   3m1s        Warning   Unhealthy     pod/kube-apiserver-nlk8s-ctrl01   Readiness probe failed: HTTP probe failed with statuscode: 500
seaweedfs     47s         Warning   FailedMount   pod/seaweedfs-filer-0                   MountVolume.MountDevice failed for volume "REDACTED_e7c2cc95" : rpc error: code = Internal desc = mount failed: exit status 32...
```

---

## Workload Map

### Namespace: `argocd`

1/- **Deployment: argocd-applicationset-controller** (1) → Svc:argocd-applicationset-controller (ClusterIP) → Ingress:argocd.example.net
1/- **Deployment: argocd-notifications-controller** (1) → Ingress:argocd.example.net
1/- **Deployment: argocd-redis** (1) → Svc:argocd-redis (ClusterIP) → Ingress:argocd.example.net
2/- **Deployment: argocd-repo-server** (2) → Svc:argocd-repo-server (ClusterIP) → Ingress:argocd.example.net
2/- **Deployment: argocd-server** (2) → Svc:argocd-server (NodePort) → Ingress:argocd.example.net
- **StatefulSet: argocd-application-controller** (1/1)

**Secrets:**
- ExternalSecret: argocd-redis (SecretSynced)
- ExternalSecret: gitlab-common-creds (SecretSynced)
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

### Namespace: `gatus`

1/- **Deployment: gatus** (1) → Svc:gatus (ClusterIP) → Ingress:nl-gatus.example.net

**Storage:**
- PVC: gatus-data (1Gi, Bound, sc:REDACTED_4f3da73d)

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
- PVC: storage-loki-0 (100Gi, Bound, sc:REDACTED_4f3da73d)

**Secrets:**
- ExternalSecret: loki-s3-credentials (SecretSynced)

### Namespace: `monitoring`

1/- **Deployment: bgpalerter** (1) → Svc:bgpalerter (ClusterIP) → Ingress:goldpinger.example.net
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
- **StatefulSet: seaweedfs-filer** (1/2)
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

### Namespace: `well-known`

1/- **Deployment: well-known** (1) → Svc:well-known (ClusterIP) → Ingress:status.example.net


---

## Resource Analysis

### Node Utilization
```
NAME                 CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
nlk8s-ctrl01   1567m        39%      2370Mi          62%         
nlk8s-ctrl02   1318m        32%      2803Mi          70%         
nlk8s-ctrl03   270m         6%       2326Mi          61%         
nlk8s-node01    611m         7%       5015Mi          64%         
nlk8s-node02    641m         8%       5309Mi          67%         
nlk8s-node03    303m         3%       4241Mi          54%         
nlk8s-node04    299m         3%       3780Mi          48%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kube-system              kube-apiserver-nlk8s-ctrl02                                 417m         1422Mi          
kube-system              etcd-nlk8s-ctrl02                                           293m         146Mi           
kube-system              cilium-22zgh                                                      247m         278Mi           
kube-system              tetragon-mdsn9                                                    230m         191Mi           
logging                  loki-0                                                            219m         1996Mi          
kube-system              cilium-kghrg                                                      160m         213Mi           
monitoring               prometheus-REDACTED_6dfbe9fc-1                131m         1320Mi          
kube-system              tetragon-vbs6v                                                    117m         157Mi           
kube-system              cilium-mvsq5                                                      104m         215Mi           
kube-system              kube-apiserver-nlk8s-ctrl03                                 101m         1362Mi          
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
logging                  loki-0                                                            219m         1996Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 417m         1422Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 101m         1362Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                131m         1320Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                69m          1318Mi          
awx                      my-awx-task-6f8f46478-wkz6j                                       22m          1245Mi          
awx                      my-awx-web-7bc5ccfbf4-bkrlp                                       9m           1213Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 85m          1036Mi          
monitoring               monitoring-grafana-68dbd786f9-9m48b                               10m          747Mi           
monitoring               monitoring-grafana-68dbd786f9-zs6md                               13m          723Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
monitoring: CPU=2120m Mem=7600Mi
awx: CPU=2105m Mem=3652Mi
kube-system: CPU=2060m Mem=472Mi
seaweedfs: CPU=1200m Mem=2944Mi
ingress-nginx: CPU=1000m Mem=1024Mi
logging: CPU=850m Mem=2944Mi
argocd: CPU=750m Mem=1664Mi
velero: CPU=550m Mem=704Mi
REDACTED_d97cef76: CPU=400m Mem=800Mi
pihole: CPU=100m Mem=256Mi
```

---

## Network & Security

### PodDisruptionBudgets
```
NAMESPACE         NAME                                              MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
argocd            argocd-application-controller                     1               N/A               0                     107d
argocd            argocd-applicationset-controller                  1               N/A               0                     107d
argocd            argocd-redis                                      1               N/A               0                     107d
argocd            argocd-repo-server                                1               N/A               1                     107d
argocd            argocd-server                                     1               N/A               1                     107d
awx               awx-postgres-pdb                                  1               N/A               0                     107d
awx               awx-task-pdb                                      1               N/A               0                     107d
awx               awx-web-pdb                                       1               N/A               0                     107d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     107d
kube-system       coredns-pdb                                       1               N/A               1                     107d
kube-system       metrics-server-pdb                                1               N/A               0                     107d
monitoring        monitoring-grafana                                1               N/A               1                     107d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     107d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     107d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     107d
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
| ClusterIP | 68 |
| NodePort | 6 |
| LoadBalancer | 6 |

### LoadBalancer Services
```
NAMESPACE       NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   129d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               98d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 106d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                104d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 106d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 106d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   109d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        108d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        105d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   88d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        93d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        92d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        97d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        108d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        92d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        93d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        110d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        94d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        94d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        109d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   87d
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   110d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   130d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   107d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   107d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   107d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   107d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   107d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   107d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   107d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   107d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 3 |
| External Secrets | 14 |
| Certificates | 6 |
| ServiceMonitors | 27 |
| CiliumNetworkPolicies | 4 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE    PAUSED
daily-backup    Enabled   0 2 * * *   61m          109d   
weekly-backup   Enabled   0 3 * * 0   88s          109d   
```

### Recent Backups (last 5)
```
daily-backup-20260221020053    83s
daily-backup-20260217020049    83s
daily-backup-20260223020056    82s
daily-backup-20260220020052    82s
weekly-backup-20260301030003   82s
```

---

## Helm Releases
```
NAME                	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd              	argocd                	8       	2026-03-14 20:16:06.409422347 +0000 UTC	deployed	argo-cd-7.7.10                        	v2.13.2    
cert-manager        	cert-manager          	3       	2025-11-30 21:22:09.520251302 +0000 UTC	deployed	cert-manager-v1.17.1                  	v1.17.1    
cilium              	kube-system           	20      	2025-12-12 16:06:57.516153767 +0000 UTC	deployed	cilium-1.18.4                         	1.18.4     
external-secrets    	external-secrets      	2       	2025-12-16 13:20:23.175188029 +0000 UTC	deployed	external-secrets-1.1.1                	v1.1.1     
ingress-nginx       	ingress-nginx         	9       	2026-03-11 00:24:34.420335322 +0000 UTC	deployed	ingress-nginx-4.14.0                  	1.14.0     
k8s-agent           	REDACTED_01b50c5d	6       	2025-11-29 02:18:29.271243252 +0000 UTC	deployed	gitlab-agent-2.21.1                   	v18.6.1    
REDACTED_d97cef76	REDACTED_d97cef76  	2       	2026-02-25 19:02:27.096604857 +0000 UTC	deployed	REDACTED_d97cef76-7.14.0           	           
loki                	logging               	10      	2025-12-20 00:53:40.31805239 +0000 UTC 	deployed	loki-6.46.0                           	3.5.7      
monitoring          	monitoring            	29      	2026-03-14 22:15:19.108793576 +0000 UTC	deployed	REDACTED_d8074874-79.10.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	8       	2025-11-29 02:18:25.900770326 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail            	logging               	8       	2026-03-14 22:22:09.209112925 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
seaweedfs           	seaweedfs             	2       	2026-03-14 22:22:07.374368448 +0000 UTC	failed  	seaweedfs-4.0.401                     	4.01       
synology-csi        	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
tetragon            	kube-system           	7       	2025-12-20 22:35:40.030282504 +0000 UTC	deployed	tetragon-1.6.0                        	1.6.0      
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   109d
awx                      Active   130d
bentopdf                 Active   105d
cert-manager             Active   104d
cilium-secrets           Active   106d
cilium-spire             Active   106d
default                  Active   131d
external-secrets         Active   105d
gatus                    Active   88d
REDACTED_01b50c5d   Active   110d
ingress-nginx            Active   129d
kube-node-lease          Active   131d
kube-public              Active   131d
kube-system              Active   131d
REDACTED_d97cef76     Active   92d
logging                  Active   104d
monitoring               Active   130d
nfs-provisioner          Active   129d
opentofu-ns              Active   129d
pihole                   Active   110d
production               Active   110d
seaweedfs                Active   94d
synology-csi             Active   107d
velero                   Active   109d
well-known               Active   87d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           109d
argocd                   argocd-notifications-controller                   1/1     1            1           8h
argocd                   argocd-redis                                      1/1     1            1           109d
argocd                   argocd-repo-server                                2/2     2            2           109d
argocd                   argocd-server                                     2/2     2            2           109d
awx                      awx-operator-controller-manager                   1/1     1            1           130d
awx                      my-awx-task                                       1/1     1            1           130d
awx                      my-awx-web                                        1/1     1            1           130d
bentopdf                 bentopdf                                          1/1     1            1           105d
cert-manager             cert-manager                                      1/1     1            1           104d
cert-manager             cert-manager-cainjector                           1/1     1            1           104d
cert-manager             cert-manager-webhook                              1/1     1            1           104d
external-secrets         external-secrets                                  1/1     1            1           105d
external-secrets         external-secrets-cert-controller                  1/1     1            1           105d
external-secrets         external-secrets-webhook                          1/1     1            1           105d
gatus                    gatus                                             1/1     1            1           88d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           110d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           129d
kube-system              cilium-operator                                   1/1     1            1           106d
kube-system              clustermesh-apiserver                             1/1     1            1           98d
kube-system              coredns                                           2/2     2            2           131d
kube-system              hubble-relay                                      1/1     1            1           106d
kube-system              hubble-ui                                         1/1     1            1           106d
kube-system              metrics-server                                    1/1     1            1           130d
kube-system              tetragon-operator                                 1/1     1            1           85d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           92d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           92d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           92d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           92d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           92d
monitoring               bgpalerter                                        1/1     1            1           90d
monitoring               monitoring-grafana                                2/2     2            2           107d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           129d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           129d
monitoring               snmp-exporter                                     1/1     1            1           92d
monitoring               thanos-query                                      2/2     2            2           93d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           129d
pihole                   pihole                                            1/1     1            1           105d
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           93d
velero                   velero                                            1/1     1            1           109d
velero                   velero-ui                                         1/1     1            1           109d
well-known               well-known                                        1/1     1            1           87d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     109d
awx            my-awx-postgres-15                                     1/1     130d
cilium-spire   spire-server                                           1/1     106d
logging        loki                                                   1/1     85d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     107d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     107d
monitoring     thanos-compactor                                       1/1     93d
monitoring     thanos-store                                           2/2     93d
seaweedfs      seaweedfs-filer                                        1/2     94d
seaweedfs      seaweedfs-master                                       3/3     94d
seaweedfs      seaweedfs-volume                                       2/2     94d
synology-csi   synology-csi-controller                                1/1     107d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   106d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   106d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   106d
kube-system    tetragon                              7         7         7       7            7           <none>                   85d
logging        loki-canary                           4         4         4       4            4           <none>                   93d
logging        promtail                              7         7         7       7            7           <none>                   104d
monitoring     goldpinger                            7         7         7       7            7           <none>                   97d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   129d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   107d
velero         velero-node-agent                     4         4         4       4            4           <none>                   109d
```

---

*Full cluster context dump - v3.1.0*
