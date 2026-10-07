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

**Generated:** 2026-10-07 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | DEGRADED | ⚠️ |
| Unhealthy Pods | 4 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 3097 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.36.3 |
| CNI | Cilium 1.20.0 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 175 |

### Node Details (with Taints & Labels)

#### nlk8s-ctrl01
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 8002680Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-ctrl02
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** Unknown
- **CPU:** 4 | **Memory:** 8092Mi
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule, node.kubernetes.io/unreachable=:NoSchedule, node.kubernetes.io/unreachable=:NoExecute, node.cilium.io/agent-not-ready=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-ctrl03
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 8003704Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node01
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** Unknown
- **CPU:** 8 | **Memory:** 10054396Ki
- **Taints:** node.kubernetes.io/unschedulable=:NoSchedule, node.kubernetes.io/unreachable=:NoSchedule, node.cilium.io/agent-not-ready=:NoSchedule, node.kubernetes.io/unreachable=:NoExecute
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node02
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 10054404Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node03
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 10054404Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node04
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 10053380Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01


---

## Anomalies & Issues

### Unhealthy Pods
```
monitoring               meshsat-status-heartbeat-29851857-cvf46                           0/1   Error       0                 2d16h
monitoring               meshsat-status-heartbeat-29854452-76r9j                           0/1   Error       0                 20h
monitoring               meshsat-status-heartbeat-29854897-xrsvd                           0/1   Error       0                 13h
velero                   monitoring-default-kopia-maintain-job-1790197917279-s5f69         0/1   Error       0                 13d
```

#### Unhealthy Pod Details

**monitoring/meshsat-status-heartbeat-29851857-cvf46:**
```
Events:                      <none>
```

**monitoring/meshsat-status-heartbeat-29854452-76r9j:**
```
Events:                      <none>
```

**monitoring/meshsat-status-heartbeat-29854897-xrsvd:**
```
Events:                      <none>
```

**velero/monitoring-default-kopia-maintain-job-1790197917279-s5f69:**
```
Events:
  Type     Reason           Age   From          Message
  ----     ------           ----  ----          -------
  Warning  PolicyViolation  43m   kyverno-scan  policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/containers/0/securityContext/
  Warning  PolicyViolation  43m   kyverno-scan  policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/containers/0/securityContext/
  Warning  PolicyViolation  43m   kyverno-scan  policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/containers/0/securityContext/
  Warning  PolicyViolation  43m   kyverno-scan  policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
```

### High Restart Pods (>3 restarts)
- argocd/argocd-application-controller-0: 35 restarts
- awx/awx-operator-controller-manager-6ffdf98f6-8jv8s: 47 restarts
- awx/my-awx-task-756d768868-bslc2: 6 restarts
- cert-manager/cert-manager-75944f484-k8x88: 18 restarts
- cert-manager/cert-manager-cainjector-74f994b988-shnfp: 20 restarts
- cilium-spire/spire-agent-2xj9z: 276 restarts
- cilium-spire/spire-agent-bf7g7: 278 restarts
- cilium-spire/spire-agent-hpld8: 275 restarts
- cilium-spire/spire-agent-hrngt: 20 restarts
- cilium-spire/spire-agent-sm9xs: 284 restarts
- cilium-spire/spire-agent-xk8cl: 280 restarts
- cilium-spire/spire-agent-zqpt4: 288 restarts
- cnpg-system/cnpg-cloudnative-pg-6d8bdc546d-wzdfh: 32 restarts
- cnpg-system/cnpg-cloudnative-pg-6d8bdc546d-zl8gc: 45 restarts
- kube-system/cilium-c8kqc: 12 restarts
- kube-system/cilium-envoy-brdkr: 10 restarts
- kube-system/cilium-envoy-dzx97: 12 restarts
- kube-system/cilium-g5h5t: 10 restarts
- kube-system/cilium-operator-84c4fb58c7-jlhkp: 65 restarts
- kube-system/etcd-nlk8s-ctrl02: 11 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 25 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 18 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 6 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 48 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 20 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 42 restarts
- kube-system/kube-proxy-7jvns: 12 restarts
- kube-system/kube-proxy-jvln5: 6 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 39 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 12 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 45 restarts
- kube-system/tetragon-5gk99: 9 restarts
- kube-system/tetragon-75hdg: 32 restarts
- kube-system/tetragon-878gv: 8 restarts
- kube-system/tetragon-jz2b6: 12 restarts
- kube-system/tetragon-mdsn9: 44 restarts
- kube-system/tetragon-tbcc7: 10 restarts
- kube-system/tetragon-vbs6v: 18 restarts
- kyverno/kyverno-admission-controller-584d7f7684-6k9gg: 49 restarts
- kyverno/kyverno-reports-controller-7bbf4b866b-rq8pt: 48 restarts
- logging/loki-canary-bbplf: 14 restarts
- logging/loki-canary-xbmzr: 4 restarts
- logging/promtail-5jr9j: 6 restarts
- logging/promtail-br4rf: 5 restarts
- logging/promtail-hp5sc: 9 restarts
- logging/promtail-m2gzm: 13 restarts
- logging/promtail-ng69s: 17 restarts
- monitoring/goldpinger-fjpnh: 5 restarts
- monitoring/goldpinger-rb96x: 11 restarts
- monitoring/goldpinger-t8x65: 12 restarts
- monitoring/monitoring-grafana-7d6c5795b8-6cvtn: 16 restarts
- monitoring/monitoring-grafana-7d6c5795b8-vbrmn: 7 restarts
- monitoring/monitoring-kube-state-metrics-75f9fff55b-prwns: 33 restarts
- monitoring/monitoring-prometheus-node-exporter-6dl8r: 187 restarts
- monitoring/monitoring-prometheus-node-exporter-6sc8j: 10 restarts
- monitoring/monitoring-prometheus-node-exporter-88hp8: 13 restarts
- monitoring/monitoring-prometheus-node-exporter-8bq88: 5 restarts
- monitoring/monitoring-prometheus-node-exporter-vgp6b: 5 restarts
- monitoring/monitoring-prometheus-node-exporter-wmcb8: 47 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-75b84759cfvtflq: 58 restarts
- synology-csi/synology-csi-node-4nxcz: 8 restarts
- synology-csi/synology-csi-node-kxrjb: 19 restarts
- synology-csi/synology-csi-node-l72f8: 9 restarts
- synology-csi/synology-csi-node-mrqzg: 24 restarts
- synology-csi/synology-csi-node-ptwb8: 10 restarts
- synology-csi/synology-csi-node-sfdmg: 12 restarts
- synology-csi/synology-csi-node-zch7n: 47 restarts
- velero/node-agent-54dn2: 10 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE                LAST SEEN   TYPE      REASON            OBJECT                                                                  MESSAGE
awx                      53m         Warning   PolicyViolation   pod/automation-job-41209-l8wrn                                          policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/containers/0/securityContext/
awx                      53m         Warning   PolicyViolation   pod/automation-job-41209-l8wrn                                          policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
awx                      53m         Warning   PolicyViolation   pod/automation-job-41209-l8wrn                                          policy REDACTED_50d055ab/adding-capabilities-strict pass: rule passed
awx                      53m         Warning   PolicyViolation   pod/automation-job-41209-l8wrn                                          policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/containers/0/securityContext/
awx                      53m         Warning   PolicyViolation   pod/automation-job-41209-l8wrn                                          policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/containers/0/securityContext/
awx                      52m         Warning   PolicyViolation   pod/automation-job-41209-l8wrn                                          policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/containers/0/securityContext/
awx                      52m         Warning   PolicyViolation   pod/automation-job-41209-l8wrn                                          policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/containers/0/securityContext/
awx                      52m         Warning   PolicyViolation   pod/automation-job-41209-l8wrn                                          policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
awx                      52m         Warning   PolicyViolation   pod/automation-job-41209-l8wrn                                          policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/containers/0/securityContext/
awx                      44m         Warning   PolicyViolation   pod/awx-operator-controller-manager-6ffdf98f6-8jv8s                     policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/containers/0/securityContext/seccompProfile/
awx                      42m         Warning   PolicyViolation   replicaset/awx-operator-controller-manager-6ffdf98f6                    policy restrict-seccomp-strict/autogen-check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule autogen-check-seccomp-strict[0] failed at path /spec/template/spec/securityContext/seccompProfile/ rule autogen-check-seccomp-strict[1] failed at path /spec/template/spec/containers/0/securityContext/seccompProfile/
awx                      41m         Warning   PolicyViolation   replicaset/awx-operator-controller-manager-79499d9678                   policy restrict-seccomp-strict/autogen-check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule autogen-check-seccomp-strict[0] failed at path /spec/template/spec/securityContext/seccompProfile/ rule autogen-check-seccomp-strict[1] failed at path /spec/template/spec/containers/0/securityContext/seccompProfile/
awx                      42m         Warning   PolicyViolation   replicaset/awx-operator-controller-manager-846b99bbd                    policy restrict-seccomp-strict/autogen-check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule autogen-check-seccomp-strict[0] failed at path /spec/template/spec/securityContext/seccompProfile/ rule autogen-check-seccomp-strict[1] failed at path /spec/template/spec/containers/0/securityContext/seccompProfile/
awx                      41m         Warning   PolicyViolation   replicaset/awx-operator-controller-manager-f84fc744                     policy restrict-seccomp-strict/autogen-check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule autogen-check-seccomp-strict[0] failed at path /spec/template/spec/securityContext/seccompProfile/ rule autogen-check-seccomp-strict[1] failed at path /spec/template/spec/containers/0/securityContext/seccompProfile/
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
- ExternalSecret: awx-pg-dump-s3 (SecretSynced)
- ExternalSecret: k8s-api-credentials (SecretSynced)
- ExternalSecret: npm-credentials (SecretSynced)

### Namespace: `backup-gateway`

2/- **Deployment: backup-gateway** (2) → Svc:backup-gateway (ClusterIP)

**Secrets:**
- ExternalSecret: REDACTED_3e2f7d3c (SecretSynced)

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

### Namespace: `cnpg-system`

2/- **Deployment: cnpg-cloudnative-pg** (2)

### Namespace: `echo-server`

1/- **Deployment: echo-server** (1) → Svc:echo-server (ClusterIP) → Ingress:echo.example.net

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

### Namespace: `kyverno`

1/- **Deployment: kyverno-admission-controller** (1)
1/- **Deployment: kyverno-reports-controller** (1)

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
- PVC: data-thanos-compactor-0 (100Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: data-thanos-store-0 (20Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: data-thanos-store-1 (20Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: monitoring-grafana (20Gi, Bound, sc:nfs-client)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-0 (200Gi, Bound, sc:REDACTED_4f3da73d)
- PVC: prometheus-REDACTED_6dfbe9fc-db-prometheus-REDACTED_6dfbe9fc-1 (200Gi, Bound, sc:REDACTED_4f3da73d)

**Secrets:**
- ExternalSecret: meshsat-status-heartbeat (SecretSynced)
- ExternalSecret: monitoring-finops-db-ro (SecretSynced)
- ExternalSecret: monitoring-grafana (SecretSynced)
- ExternalSecret: monitoring-openobserve-ro (SecretSynced)
- ExternalSecret: tg-ingest-token (SecretSynced)
- ExternalSecret: REDACTED_5f4971dc (SecretSynced)

### Namespace: `nfs-provisioner`

1/- **Deployment: nfs-provisioner-REDACTED_5fef70be** (1)

### Namespace: `pihole`

1/- **Deployment: pihole** (1) → Svc:pihole-dns-lb (LoadBalancer 10.0.X.X) → Ingress:pihole.example.net

**Storage:**
- PVC: pihole-data (1Gi, Bound, sc:nfs-client)

**Secrets:**
- ExternalSecret: pihole-credentials (SecretSynced)

### Namespace: `reloader`

1/- **Deployment: reloader-reloader** (1)

### Namespace: `synology-csi`

- **StatefulSet: synology-csi-controller** (1/1)

### Namespace: `velero`

1/- **Deployment: velero** (1) → Svc:velero-metrics (ClusterIP) → Ingress:velero.example.net
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
NAME                 CPU(cores)   CPU(%)      MEMORY(bytes)   MEMORY(%)   
nlk8s-ctrl01   1533m        38%         4287Mi          54%         
nlk8s-ctrl03   542m         13%         3687Mi          47%         
nlk8s-node02    2565m        32%         8578Mi          87%         
nlk8s-node03    2155m        26%         7291Mi          74%         
nlk8s-node04    419m         5%          5026Mi          51%         
nlk8s-ctrl02   <unknown>    <unknown>   <unknown>       <unknown>   
nlk8s-node01    <unknown>    <unknown>   <unknown>       <unknown>   
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-1                595m         3006Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                319m         3653Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 216m         2290Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 199m         1880Mi          
kube-system              cilium-7rvww                                                      144m         333Mi           
kube-system              etcd-nlk8s-ctrl03                                           122m         150Mi           
kube-system              cilium-qw7d6                                                      112m         380Mi           
kube-system              cilium-jfgsw                                                      111m         353Mi           
kube-system              tetragon-5gk99                                                    75m          185Mi           
kube-system              cilium-nhh8q                                                      65m          200Mi           
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                319m         3653Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                595m         3006Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 216m         2290Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 199m         1880Mi          
awx                      my-awx-task-756d768868-bslc2                                      29m          1609Mi          
awx                      my-awx-web-f9c4bb98d-wcn4j                                        10m          1407Mi          
monitoring               bgpalerter-b7bc9c8c-kdlv5                                         2m           1110Mi          
monitoring               monitoring-grafana-7d6c5795b8-vbrmn                               11m          728Mi           
logging                  loki-0                                                            38m          721Mi           
monitoring               monitoring-grafana-7d6c5795b8-6cvtn                               15m          694Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
kube-system: CPU=2210m Mem=536Mi
monitoring: CPU=2200m Mem=10992Mi
awx: CPU=1855m Mem=3552Mi
ingress-nginx: CPU=1000m Mem=1024Mi
logging: CPU=850m Mem=2944Mi
argocd: CPU=750m Mem=1664Mi
backup-gateway: CPU=700m Mem=1920Mi
velero: CPU=550m Mem=832Mi
REDACTED_d97cef76: CPU=400m Mem=800Mi
cnpg-system: CPU=130m Mem=400Mi
```

---

## Network & Security

### PodDisruptionBudgets
```
NAMESPACE         NAME                                              MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
argocd            argocd-application-controller                     1               N/A               0                     313d
argocd            argocd-applicationset-controller                  1               N/A               0                     313d
argocd            argocd-redis                                      1               N/A               0                     313d
argocd            argocd-repo-server                                1               N/A               1                     313d
argocd            argocd-server                                     1               N/A               1                     313d
awx               awx-postgres-pdb                                  1               N/A               0                     313d
awx               awx-task-pdb                                      1               N/A               0                     313d
awx               awx-web-pdb                                       1               N/A               0                     313d
backup-gateway    backup-gateway                                    1               N/A               1                     13d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     313d
kube-system       coredns-pdb                                       1               N/A               1                     313d
kube-system       metrics-server-pdb                                1               N/A               0                     21d
monitoring        monitoring-grafana                                1               N/A               1                     178d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     178d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     178d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     313d
```

### CiliumNetworkPolicies
- CiliumNetworkPolicies: 5
- CiliumClusterwideNetworkPolicies: 0

**Policies by namespace:**
- backup-gateway: 1 policies
- gatus: 1 policies
- logging: 1 policies
- pihole: 1 policies
- well-known: 1 policies

### Services by Type
| Type | Count |
|------|-------|
| ClusterIP | 73 |
| NodePort | 6 |
| LoadBalancer | 6 |

### LoadBalancer Services
```
NAMESPACE       NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   335d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               304d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 312d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                310d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 312d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 312d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS   HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx   argocd.example.net                              10.0.X.X   80, 443   315d
awx                    awx                    nginx   awx.example.net                                 10.0.X.X   80        314d
bentopdf               bentopdf               nginx   bentopdf.example.net                            10.0.X.X   80        311d
echo-server            echo-server            nginx   echo.example.net                                10.0.X.X   80        205d
gatus                  gatus                  nginx   nl-gatus.example.net                            10.0.X.X   80, 443   294d
kube-system            hubble-ui              nginx   nl-hubble.example.net                           10.0.X.X   80        299d
REDACTED_d97cef76   REDACTED_d97cef76   nginx   nl-k8s.example.net                              10.0.X.X   80        298d
monitoring             goldpinger             nginx   goldpinger.example.net                          10.0.X.X   80        303d
monitoring             grafana                nginx   grafana.example.net                             10.0.X.X   80        314d
monitoring             prometheus             nginx   nl-prometheus.example.net                       10.0.X.X   80        298d
monitoring             thanos-query           nginx   nl-thanos.example.net                           10.0.X.X   80        299d
pihole                 pihole-ingress         nginx   pihole.example.net                              10.0.X.X   80        316d
velero                 velero-ui              nginx   velero.example.net                              10.0.X.X   80        315d
well-known             well-known             nginx   status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   293d
```

---

## Storage

| Metric | Count |
|--------|-------|
| StorageClasses | 10 |
| PersistentVolumes | 15 |
| PersistentVolumeClaims | 14 |

### StorageClasses
```
NAME                                      PROVISIONER                                                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   316d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   336d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   313d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   313d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   313d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   313d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   313d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   313d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   313d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   313d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 4 |
| External Secrets | 19 |
| Certificates | 22 |
| ServiceMonitors | 32 |
| CiliumNetworkPolicies | 5 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE    PAUSED
daily-backup    Enabled   0 2 * * *   61m          315d   false
weekly-backup   Enabled   0 3 * * 0   3d           315d   false
```

### Recent Backups (last 5)
```

```

---

## Helm Releases
```
NAME                	NAMESPACE             	REVISION	UPDATED                                	STATUS  	CHART                                 	APP VERSION
argocd              	argocd                	10      	2026-08-22 21:03:45.885765007 +0000 UTC	deployed	argo-cd-7.7.10                        	v2.13.2    
cert-manager        	cert-manager          	4       	2026-08-16 20:22:17.02474649 +0000 UTC 	deployed	cert-manager-v1.17.1                  	v1.17.1    
cilium              	kube-system           	23      	2026-08-16 19:52:42.423404071 +0000 UTC	deployed	cilium-1.20.0                         	1.20.0     
cnpg                	cnpg-system           	1       	2026-08-23 18:35:22.841169369 +0000 UTC	deployed	cloudnative-pg-0.29.0                 	1.30.0     
external-secrets    	external-secrets      	3       	2026-08-16 19:44:17.756739716 +0000 UTC	deployed	external-secrets-1.1.1                	v1.1.1     
ingress-nginx       	ingress-nginx         	17      	2026-09-26 07:25:33.516214415 +0000 UTC	deployed	ingress-nginx-4.15.1                  	1.15.1     
k8s-agent           	REDACTED_01b50c5d	8       	2026-08-16 19:44:19.392287363 +0000 UTC	deployed	gitlab-agent-2.28.0                   	v19.1.0    
REDACTED_d97cef76	REDACTED_d97cef76  	2       	2026-02-25 19:02:27.096604857 +0000 UTC	deployed	REDACTED_d97cef76-7.14.0           	           
kyverno             	kyverno               	1       	2026-09-20 11:39:18.941723567 +0000 UTC	deployed	kyverno-3.9.1                         	v1.19.1    
kyverno-policies    	kyverno               	1       	2026-09-20 11:39:56.894631411 +0000 UTC	deployed	kyverno-policies-3.9.1                	v1.19.1    
loki                	logging               	18      	2026-09-25 01:35:16.010887664 +0000 UTC	deployed	loki-6.55.0                           	3.6.7      
metrics-server      	kube-system           	1       	2026-09-15 13:27:45.896794695 +0000 UTC	deployed	metrics-server-3.14.0                 	0.9.0      
monitoring          	monitoring            	40      	2026-10-06 13:46:58.639588713 +0000 UTC	deployed	REDACTED_d8074874-79.12.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	9       	2026-08-16 19:44:19.484898096 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail            	logging               	8       	2026-03-14 22:22:09.209112925 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
reloader            	reloader              	1       	2026-09-15 00:36:24.969024643 +0000 UTC	deployed	reloader-2.2.17                       	v1.4.22    
synology-csi        	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
tetragon            	kube-system           	7       	2025-12-20 22:35:40.030282504 +0000 UTC	deployed	tetragon-1.6.0                        	1.6.0      
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   315d
awx                      Active   336d
backup-gateway           Active   13d
bentopdf                 Active   311d
cert-manager             Active   310d
cilium-secrets           Active   312d
cilium-spire             Active   312d
cnpg-system              Active   44d
default                  Active   337d
echo-server              Active   205d
external-secrets         Active   311d
gatus                    Active   294d
REDACTED_01b50c5d   Active   316d
ingress-nginx            Active   335d
kube-node-lease          Active   337d
kube-public              Active   337d
kube-system              Active   337d
REDACTED_d97cef76     Active   298d
kyverno                  Active   16d
logging                  Active   310d
monitoring               Active   336d
nfs-provisioner          Active   335d
opentofu-ns              Active   335d
pihole                   Active   316d
production               Active   316d
reloader                 Active   22d
synology-csi             Active   313d
velero                   Active   315d
well-known               Active   293d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           315d
argocd                   argocd-notifications-controller                   1/1     1            1           206d
argocd                   argocd-redis                                      1/1     1            1           315d
argocd                   argocd-repo-server                                2/2     2            2           315d
argocd                   argocd-server                                     2/2     2            2           315d
awx                      awx-operator-controller-manager                   1/1     1            1           336d
awx                      my-awx-task                                       1/1     1            1           336d
awx                      my-awx-web                                        1/1     1            1           336d
backup-gateway           backup-gateway                                    2/2     2            2           13d
bentopdf                 bentopdf                                          1/1     1            1           311d
cert-manager             cert-manager                                      1/1     1            1           310d
cert-manager             cert-manager-cainjector                           1/1     1            1           310d
cert-manager             cert-manager-webhook                              1/1     1            1           310d
cnpg-system              cnpg-cloudnative-pg                               2/2     2            2           44d
echo-server              echo-server                                       1/1     1            1           205d
external-secrets         external-secrets                                  1/1     1            1           311d
external-secrets         external-secrets-cert-controller                  1/1     1            1           311d
external-secrets         external-secrets-webhook                          1/1     1            1           311d
gatus                    gatus                                             1/1     1            1           294d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           316d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           335d
kube-system              cilium-operator                                   1/1     1            1           312d
kube-system              clustermesh-apiserver                             1/1     1            1           304d
kube-system              coredns                                           2/2     2            2           337d
kube-system              hubble-relay                                      1/1     1            1           312d
kube-system              hubble-ui                                         1/1     1            1           312d
kube-system              metrics-server                                    1/1     1            1           21d
kube-system              tetragon-operator                                 1/1     1            1           291d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           298d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           298d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           298d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           298d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           298d
kyverno                  kyverno-admission-controller                      1/1     1            1           16d
kyverno                  kyverno-reports-controller                        1/1     1            1           16d
monitoring               bgpalerter                                        1/1     1            1           296d
monitoring               monitoring-grafana                                2/2     2            2           178d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           178d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           178d
monitoring               snmp-exporter                                     1/1     1            1           298d
monitoring               thanos-query                                      2/2     2            2           299d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           335d
pihole                   pihole                                            1/1     1            1           311d
reloader                 reloader-reloader                                 1/1     1            1           22d
velero                   velero                                            1/1     1            1           315d
velero                   velero-ui                                         1/1     1            1           315d
well-known               well-known                                        1/1     1            1           293d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     315d
awx            my-awx-postgres-15                                     1/1     336d
cilium-spire   spire-server                                           1/1     312d
logging        loki                                                   1/1     291d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     178d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     178d
monitoring     thanos-compactor                                       1/1     21d
monitoring     thanos-store                                           2/2     299d
synology-csi   synology-csi-controller                                1/1     313d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           5         5         5       5            5           <none>                   312d
kube-system    cilium                                7         7         5       7            5           kubernetes.io/os=linux   312d
kube-system    cilium-envoy                          7         7         5       7            5           kubernetes.io/os=linux   312d
kube-system    kube-proxy                            7         7         5       7            5           kubernetes.io/os=linux   51d
kube-system    tetragon                              5         5         5       5            5           <none>                   291d
logging        loki-canary                           3         3         3       3            3           <none>                   299d
logging        promtail                              5         5         5       5            5           <none>                   310d
monitoring     goldpinger                            5         5         5       5            5           <none>                   303d
monitoring     monitoring-prometheus-node-exporter   5         5         5       5            5           kubernetes.io/os=linux   178d
synology-csi   synology-csi-node                     7         7         5       7            5           <none>                   313d
velero         node-agent                            3         3         3       3            3           <none>                   70d
```

---

*Full cluster context dump - v3.1.0*
