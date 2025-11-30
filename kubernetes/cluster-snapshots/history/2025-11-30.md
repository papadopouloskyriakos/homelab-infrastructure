# K8s Cluster Snapshot

**Date:** 2025-11-30 12:54:28 UTC | **Host:** nlk8s-ctrl01 | **Version:** 2.0.0

## Overview

| Metric | Value |
|--------|-------|
| K8s Version | v1.34.2 |
| Nodes | 7 (3 ctrl, 4 workers) |
| Pods | 93 |
| Services | 52 |
| PVCs | 10 |
| Helm Releases | 8 |

## Nodes
```
NAME                 STATUS   ROLES           AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
nlk8s-ctrl01   Ready    control-plane   26d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.14.0-36-generic   containerd://2.1.5
nlk8s-ctrl02   Ready    control-plane   24d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.14.11-4-pve       containerd://2.1.5
nlk8s-ctrl03   Ready    control-plane   26d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.14.0-36-generic   containerd://2.1.5
nlk8s-node01    Ready    worker          26d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.8.0-88-generic    containerd://2.1.5
nlk8s-node02    Ready    worker          26d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.8.0-88-generic    containerd://2.1.5
nlk8s-node03    Ready    worker          26d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.8.0-88-generic    containerd://2.1.5
nlk8s-node04    Ready    worker          26d   v1.34.2   10.0.X.X   <none>        Ubuntu 24.04.3 LTS   6.8.0-88-generic    containerd://2.1.5
```

## Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           4d18h
argocd                   argocd-redis                                      1/1     1            1           4d18h
argocd                   argocd-repo-server                                2/2     2            2           4d18h
argocd                   argocd-server                                     2/2     2            2           4d18h
awx                      awx-operator-controller-manager                   1/1     1            1           25d
awx                      my-awx-task                                       1/1     1            1           25d
awx                      my-awx-web                                        1/1     1            1           25d
bentopdf                 bentopdf                                          1/1     1            1           22h
external-secrets         external-secrets                                  1/1     1            1           17h
external-secrets         external-secrets-cert-controller                  1/1     1            1           17h
external-secrets         external-secrets-webhook                          1/1     1            1           17h
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           5d23h
ingress-nginx            ingress-nginx-controller                          2/2     2            2           24d
kube-system              cilium-operator                                   1/1     1            1           47h
kube-system              coredns                                           2/2     2            2           26d
kube-system              hubble-relay                                      1/1     1            1           47h
kube-system              hubble-ui                                         1/1     1            1           47h
kube-system              metrics-server                                    1/1     1            1           26d
REDACTED_d97cef76     dashboard-metrics-scraper                         1/1     1            1           24d
REDACTED_d97cef76     REDACTED_d97cef76                              1/1     1            1           24d
minio                    minio                                             1/1     1            1           5d11h
monitoring               monitoring-grafana                                2/2     2            2           2d17h
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           24d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           24d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           24d
pihole                   pihole                                            1/1     1            1           19h
velero                   velero                                            1/1     1            1           4d17h
velero                   velero-ui                                         1/1     1            1           4d17h
```

## StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     4d18h
awx            my-awx-postgres-15                                     1/1     25d
cilium-spire   spire-server                                           1/1     37h
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     2d17h
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     2d18h
synology-csi   synology-csi-controller                                1/1     2d20h
```

## Services (NodePort)
```
NAMESPACE              NAME                                    TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
argocd                 argocd-server                           NodePort   10.97.64.236     <none>        80:30080/TCP,443:30085/TCP      4d18h
awx                    my-awx-service                          NodePort   10.108.112.207   <none>        80:30994/TCP                    25d
REDACTED_d97cef76   REDACTED_d97cef76                    NodePort   10.98.175.139    <none>        443:32321/TCP                   24d
minio                  minio-api                               NodePort   10.101.113.218   <none>        9000:30011/TCP                  5d11h
minio                  minio-console                           NodePort   10.110.239.239   <none>        9001:30010/TCP                  5d11h
monitoring             monitoring-grafana                      NodePort   10.98.185.238    <none>        80:30000/TCP                    24d
monitoring             REDACTED_6dfbe9fc   NodePort   10.101.216.87    <none>        9090:30090/TCP,8080:32012/TCP   24d
pihole                 pihole-web                              NodePort   10.103.135.132   <none>        80:30666/TCP                    6d8h
velero                 velero-ui                               NodePort   10.108.96.16     <none>        3000:30012/TCP                  4d17h
```

## Ingresses
```
NAMESPACE              NAME                   CLASS   HOSTS                          ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx   argocd.example.net     10.0.X.X   80, 443   4d18h
awx                    awx                    nginx   awx.example.net        10.0.X.X   80        3d13h
bentopdf               bentopdf               nginx   bentopdf.example.net   10.0.X.X   80        22h
kube-system            hubble-ui              nginx   hubble.example.net     10.0.X.X   80, 443   46h
REDACTED_d97cef76   REDACTED_d97cef76   nginx   k8s.example.net        10.0.X.X   80        3d13h
minio                  minio-console          nginx   minio.example.net      10.0.X.X   80        5d11h
monitoring             grafana                nginx   grafana.example.net    10.0.X.X   80        3d13h
pihole                 pihole-ingress         nginx   pihole.example.net     10.0.X.X   80        6d8h
velero                 velero-ui              nginx   velero.example.net     10.0.X.X   80        4d17h
```

## PVCs
```
NAMESPACE      NAME                                                                                                             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                              VOLUMEATTRIBUTESCLASS   AGE
awx            my-awx-projects                                                                                                  Bound    awx-projects-pv                            50Gi       RWX            nfs-sc                                    <unset>                 25d
awx            REDACTED_0d7ca6a5                                                                                 Bound    REDACTED_c7d87e23   50Gi       RWO            REDACTED_b280aec5   <unset>                 2d16h
cilium-spire   spire-data-spire-server-0                                                                                        Bound    pvc-6f3da11a-d6a0-4cd0-8f14-d35dfd334075   1Gi        RWO            nfs-client                                <unset>                 37h
minio          minio-data-csi                                                                                                   Bound    pvc-7ed8ddf6-ff5f-4a09-87b3-add99604e608   100Gi      RWO            REDACTED_b280aec5   <unset>                 2d19h
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-0   Bound    REDACTED_3f07e323   10Gi       RWO            REDACTED_4f3da73d   <unset>                 2d17h
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager-db-alertmanager-monitoring-kube-prometheus-alertmanager-1   Bound    REDACTED_c70a75d3   10Gi       RWO            REDACTED_4f3da73d   <unset>                 2d17h
monitoring     monitoring-grafana                                                                                               Bound    pvc-55805781-0f58-4d80-9074-a62cec165932   20Gi       RWO            nfs-client                                <unset>                 2d17h
monitoring     prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-0           Bound    REDACTED_b1b2f2d4   200Gi      RWO            REDACTED_4f3da73d   <unset>                 2d18h
monitoring     prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-1           Bound    REDACTED_628b3ba4   200Gi      RWO            REDACTED_4f3da73d   <unset>                 2d18h
pihole         pihole-data                                                                                                      Bound    pvc-b45463d9-aa5b-483e-92b8-54fee6635219   1Gi        RWO            nfs-client                                <unset>                 6d8h
```

## Helm Releases
```
NAME            	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd          	argocd                	3       	2025-11-29 02:18:52.98547378 +0000 UTC 	deployed	argo-cd-7.7.10                        	v2.13.2    
cilium          	kube-system           	4       	2025-11-29 02:18:27.455069627 +0000 UTC	deployed	cilium-1.18.4                         	1.18.4     
external-secrets	external-secrets      	1       	2025-11-29 19:53:58.182715236 +0000 UTC	deployed	external-secrets-0.12.1               	v0.12.1    
ingress-nginx   	ingress-nginx         	5       	2025-11-29 02:18:34.195490227 +0000 UTC	deployed	ingress-nginx-4.14.0                  	1.14.0     
k8s-agent       	REDACTED_01b50c5d	6       	2025-11-29 02:18:29.271243252 +0000 UTC	deployed	gitlab-agent-2.21.1                   	v18.6.1    
monitoring      	monitoring            	15      	2025-11-29 22:21:06.835960786 +0000 UTC	deployed	REDACTED_d8074874-79.9.0          	v0.86.2    
nfs-provisioner 	nfs-provisioner       	8       	2025-11-29 02:18:25.900770326 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
synology-csi    	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
```

## Velero Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE     PAUSED
daily-backup    Enabled   0 2 * * *   10h          4d17h   
weekly-backup   Enabled   0 3 * * 0   9h           4d17h   
```

## Warning Events
```
NAMESPACE     LAST SEEN   TYPE      REASON                  OBJECT                                  MESSAGE
kube-system   50m         Warning   Unhealthy               pod/kube-apiserver-nlk8s-ctrl01   Liveness probe failed: HTTP probe failed with statuscode: 500
default       40m         Warning   InvalidProviderConfig   clustersecretstore/openbao              unable to log in to auth method: unable to log in with Kubernetes auth: Error making API request....
argocd        35m         Warning   UpdateFailed            externalsecret/gitlab-repo-creds        error processing spec.data[0] (key: REDACTED_79b33008), err: ClusterSecretStore "openbao" is not ready
kube-system   6m10s       Warning   Unhealthy               pod/kube-apiserver-nlk8s-ctrl01   Readiness probe failed: HTTP probe failed with statuscode: 500
```

---
*Generated by k8s-cluster-snapshot.sh v2.0.0*
