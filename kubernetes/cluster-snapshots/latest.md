# K8s Cluster Snapshot

**Date:** 2025-11-27 13:07:13 UTC | **Host:** nlk8s-ctrl01 | **Version:** 2.0.0

## Overview

| Metric | Value |
|--------|-------|
| K8s Version | v1.34.2 |
| Nodes | 7 (3 ctrl, 4 workers) |
| Pods | 72 |
| Services | 37 |
| PVCs | 7 |
| Helm Releases | 6 |

## Nodes
```
NAME                 STATUS   ROLES           AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
nlk8s-ctrl01   Ready    control-plane   23d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.14.0-36-generic   containerd://2.1.5
nlk8s-ctrl02   Ready    control-plane   21d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.14.11-4-pve       containerd://2.1.5
nlk8s-ctrl03   Ready    control-plane   23d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.14.0-36-generic   containerd://2.1.5
nlk8s-node01    Ready    worker          23d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.8.0-88-generic    containerd://2.1.5
nlk8s-node02    Ready    worker          23d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.8.0-88-generic    containerd://2.1.5
nlk8s-node03    Ready    worker          23d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.8.0-88-generic    containerd://2.1.5
nlk8s-node04    Ready    worker          23d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.8.0-88-generic    containerd://2.1.5
```

## Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           42h
argocd                   argocd-redis                                      1/1     1            1           42h
argocd                   argocd-repo-server                                1/1     1            1           42h
argocd                   argocd-server                                     1/1     1            1           42h
awx                      awx-operator-controller-manager                   1/1     1            1           22d
awx                      my-awx-task                                       1/1     1            1           22d
awx                      my-awx-web                                        1/1     1            1           22d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           3d
ingress-nginx            ingress-nginx-controller                          1/1     1            1           21d
kube-system              coredns                                           2/2     2            2           23d
kube-system              metrics-server                                    1/1     1            1           23d
REDACTED_d97cef76     dashboard-metrics-scraper                         1/1     1            1           21d
REDACTED_d97cef76     REDACTED_d97cef76                              1/1     1            1           21d
metallb-system           metallb-controller                                1/1     1            1           23h
minio                    minio                                             1/1     1            1           2d11h
monitoring               monitoring-grafana                                1/1     1            1           21d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           21d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           21d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           21d
pihole                   pihole                                            1/1     1            1           3d8h
velero                   velero                                            1/1     1            1           41h
velero                   velero-ui                                         1/1     1            1           41h
```

## StatefulSets
```
NAMESPACE    NAME                                                   READY   AGE
argocd       argocd-application-controller                          1/1     42h
awx          my-awx-postgres-15                                     1/1     22d
monitoring   alertmanager-monitoring-kube-prometheus-alertmanager   1/1     2d11h
monitoring   prometheus-REDACTED_6dfbe9fc       1/1     21d
```

## Services (NodePort)
```
NAMESPACE              NAME                                    TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
argocd                 argocd-server                           NodePort   10.97.64.236     <none>        80:30080/TCP,443:30085/TCP      42h
awx                    my-awx-service                          NodePort   10.108.112.207   <none>        80:30994/TCP                    22d
REDACTED_d97cef76   REDACTED_d97cef76                    NodePort   10.98.175.139    <none>        443:32321/TCP                   21d
minio                  minio-api                               NodePort   10.101.113.218   <none>        9000:30011/TCP                  2d11h
minio                  minio-console                           NodePort   10.110.239.239   <none>        9001:30010/TCP                  2d11h
monitoring             monitoring-grafana                      NodePort   10.98.185.238    <none>        80:30000/TCP                    21d
monitoring             REDACTED_6dfbe9fc   NodePort   10.101.216.87    <none>        9090:30090/TCP,8080:32012/TCP   21d
pihole                 pihole-web                              NodePort   10.103.135.132   <none>        80:30666/TCP                    3d8h
velero                 velero-ui                               NodePort   10.108.96.16     <none>        3000:30012/TCP                  41h
```

## Ingresses
```
NAMESPACE              NAME                   CLASS   HOSTS                         ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx   argocd.example.net    10.0.X.X   80, 443   42h
awx                    awx                    nginx   awx.example.net       10.0.X.X   80        13h
REDACTED_d97cef76   REDACTED_d97cef76   nginx   k8s.example.net       10.0.X.X   80        13h
minio                  minio-console          nginx   minio.example.net     10.0.X.X   80        2d11h
monitoring             grafana                nginx   grafana.example.net   10.0.X.X   80        13h
pihole                 pihole-ingress         nginx   pihole.example.net    10.0.X.X   80        3d8h
velero                 velero-ui              nginx   velero.example.net    10.0.X.X   80        41h
```

## PVCs
```
NAMESPACE    NAME                                                                                                             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
awx          my-awx-projects                                                                                                  Bound    awx-projects-pv                            50Gi       RWX            nfs-sc         <unset>                 22d
awx          REDACTED_0d7ca6a5                                                                                 Bound    awx-postgres-data-pv                       50Gi       RWO            nfs-sc         <unset>                 22d
minio        minio-data                                                                                                       Bound    pvc-3a18610a-a271-47bf-8a9d-e36f88c0bab9   100Gi      RWO            nfs-client     <unset>                 2d11h
monitoring   alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-0   Bound    pvc-a339315e-25df-4518-a6bf-b6759351cb90   10Gi       RWO            nfs-client     <unset>                 2d11h
monitoring   monitoring-grafana                                                                                               Bound    pvc-9ca05c43-0607-4426-9c3f-ccf8ce4969a3   20Gi       RWO            nfs-client     <unset>                 21d
monitoring   prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-0           Bound    pvc-34c6ed7d-2ad0-4bef-b8e9-3ba493e506fb   200Gi      RWO            nfs-client     <unset>                 21d
pihole       pihole-data                                                                                                      Bound    pvc-b45463d9-aa5b-483e-92b8-54fee6635219   1Gi        RWO            nfs-client     <unset>                 3d8h
```

## Helm Releases
```
NAME           	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd         	argocd                	1       	2025-11-25 18:28:56.171125342 +0000 UTC	deployed	argo-cd-7.7.10                        	v2.13.2    
ingress-nginx  	ingress-nginx         	3       	2025-11-24 18:14:53.851364648 +0000 UTC	deployed	ingress-nginx-4.14.0                  	1.14.0     
k8s-agent      	REDACTED_01b50c5d	3       	2025-11-25 01:09:50.065151822 +0000 UTC	deployed	gitlab-agent-2.21.0                   	v18.6.0    
metallb        	metallb-system        	2       	2025-11-27 00:56:30.56061147 +0000 UTC 	deployed	metallb-0.14.9                        	v0.14.9    
monitoring     	monitoring            	8       	2025-11-25 17:33:40.676402643 +0000 UTC	deployed	REDACTED_d8074874-79.7.1          	v0.86.2    
nfs-provisioner	nfs-provisioner       	6       	2025-11-27 00:00:44.803439068 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
```

## Velero Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE   PAUSED
daily-backup    Enabled   0 2 * * *   11h          41h   
weekly-backup   Enabled   0 3 * * 0                41h   
```

## Warning Events
```
NAMESPACE     LAST SEEN   TYPE      REASON      OBJECT                                  MESSAGE
kube-system   33m         Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Liveness probe failed: HTTP probe failed with statuscode: 500
kube-system   33m         Warning   Unhealthy   pod/kube-apiserver-nlk8s-ctrl01   Readiness probe failed: HTTP probe failed with statuscode: 500
```

---
*Generated by k8s-cluster-snapshot.sh v2.0.0*
