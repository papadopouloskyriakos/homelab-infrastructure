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

**Generated:** 2026-11-18 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | DEGRADED | ⚠️ |
| Unhealthy Pods | 5 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 15686 | ⚠️ |

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
- **CPU:** 4 | **Memory:** 8002640Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-ctrl02
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** Unknown
- **CPU:** 4 | **Memory:** 8092Mi
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule, node.kubernetes.io/unreachable=:NoSchedule, node.cilium.io/agent-not-ready=:NoSchedule, node.kubernetes.io/unreachable=:NoExecute
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-ctrl03
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 8003648Ki
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
- **CPU:** 8 | **Memory:** 10054348Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node03
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 10054352Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-node04
- **Role:** worker
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 8 | **Memory:** 10053344Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01


---

## Anomalies & Issues

### Unhealthy Pods
```
monitoring               meshsat-status-heartbeat-29914042-zrt79                           0/1   Error              0                   35h
monitoring               meshsat-status-heartbeat-29914881-2wmbx                           0/1   Error              0                   21h
monitoring               meshsat-status-heartbeat-29915276-6phr5                           0/1   Error              0                   15h
velero                   monitoring-default-kopia-maintain-job-1790197917279-s5f69         0/1   Error              0                   55d
velero                   velero-ui-687565868b-b9xr7                                        0/1   CrashLoopBackOff   10225 (2m46s ago)   63d
```

#### Unhealthy Pod Details

**monitoring/meshsat-status-heartbeat-29914042-zrt79:**
```
Events:                      <none>
```

**monitoring/meshsat-status-heartbeat-29914881-2wmbx:**
```
Events:                      <none>
```

**monitoring/meshsat-status-heartbeat-29915276-6phr5:**
```
Events:                      <none>
```

**velero/monitoring-default-kopia-maintain-job-1790197917279-s5f69:**
```
Events:                      <none>
```

**velero/velero-ui-687565868b-b9xr7:**
```
Events:
  Type     Reason           Age                       From          Message
  ----     ------           ----                      ----          -------
  Warning  PolicyViolation  42s                       kyverno-scan  policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
  Warning  PolicyViolation  42s                       kyverno-scan  policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/containers/0/securityContext/
  Warning  PolicyViolation  42s                       kyverno-scan  policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/containers/0/securityContext/
  Warning  PolicyViolation  42s                       kyverno-scan  policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/containers/0/securityContext/
  Warning  Unhealthy        49m (x8674 over 3d20h)    kubelet       spec.containers{velero-ui}: Readiness probe failed: Get "http://10.0.6.103:3000/": dial tcp 10.0.6.103:3000: connect: connection refused
  Normal   Pulled           24m (x1237 over 3d20h)    kubelet       spec.containers{velero-ui}: (combined from similar events): Successfully pulled image "docker.io/otwld/velero-ui:latest" in 877ms (877ms including waiting). Image size: 133792847 bytes.
  Warning  Unhealthy        9m53s (x1488 over 3d20h)  kubelet       spec.containers{velero-ui}: Liveness probe failed: Get "http://10.0.6.103:3000/": dial tcp 10.0.6.103:3000: connect: connection refused
  Normal   Killing          9m53s (x496 over 3d20h)   kubelet       spec.containers{velero-ui}: Container velero-ui failed liveness probe, will be restarted
```

### High Restart Pods (>3 restarts)
- argocd/argocd-application-controller-0: 129 restarts
- argocd/argocd-repo-server-7dfc645f84-hqhdh: 6 restarts
- argocd/argocd-server-64dd47d8bf-ntq7c: 8 restarts
- awx/awx-operator-controller-manager-6ffdf98f6-8jv8s: 236 restarts
- awx/my-awx-task-756d768868-bslc2: 11 restarts
- awx/my-awx-web-f9c4bb98d-wcn4j: 10 restarts
- cert-manager/cert-manager-75944f484-k8x88: 54 restarts
- cert-manager/cert-manager-cainjector-74f994b988-shnfp: 61 restarts
- cilium-spire/spire-agent-2xj9z: 277 restarts
- cilium-spire/spire-agent-bf7g7: 281 restarts
- cilium-spire/spire-agent-hpld8: 278 restarts
- cilium-spire/spire-agent-hrngt: 20 restarts
- cilium-spire/spire-agent-sm9xs: 285 restarts
- cilium-spire/spire-agent-xk8cl: 281 restarts
- cilium-spire/spire-agent-zqpt4: 288 restarts
- cilium-spire/spire-server-0: 6 restarts
- cnpg-system/cnpg-cloudnative-pg-6d8bdc546d-wzdfh: 162 restarts
- cnpg-system/cnpg-cloudnative-pg-6d8bdc546d-zl8gc: 180 restarts
- kube-system/cilium-9t574: 4 restarts
- kube-system/cilium-c8kqc: 12 restarts
- kube-system/cilium-envoy-brdkr: 10 restarts
- kube-system/cilium-envoy-dzx97: 12 restarts
- kube-system/cilium-envoy-nwfj5: 4 restarts
- kube-system/cilium-envoy-z9854: 6 restarts
- kube-system/cilium-g5h5t: 10 restarts
- kube-system/cilium-operator-84c4fb58c7-jlhkp: 252 restarts
- kube-system/cilium-qw7d6: 6 restarts
- kube-system/etcd-nlk8s-ctrl01: 5 restarts
- kube-system/etcd-nlk8s-ctrl02: 11 restarts
- kube-system/etcd-nlk8s-ctrl03: 77 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 46 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 18 restarts
- kube-system/kube-apiserver-nlk8s-ctrl03: 120 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 167 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 20 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 157 restarts
- kube-system/kube-proxy-7jvns: 12 restarts
- kube-system/kube-proxy-jvln5: 6 restarts
- kube-system/kube-proxy-sg86x: 6 restarts
- kube-system/kube-proxy-xhgkv: 4 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 155 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 12 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 168 restarts
- kube-system/metrics-server-7f76dc54d5-gvlpm: 4 restarts
- kube-system/tetragon-5gk99: 11 restarts
- kube-system/tetragon-75hdg: 32 restarts
- kube-system/tetragon-878gv: 9 restarts
- kube-system/tetragon-jz2b6: 18 restarts
- kube-system/tetragon-mdsn9: 44 restarts
- kube-system/tetragon-tbcc7: 12 restarts
- kube-system/tetragon-vbs6v: 24 restarts
- kyverno/kyverno-admission-controller-584d7f7684-6k9gg: 212 restarts
- kyverno/kyverno-reports-controller-7bbf4b866b-rq8pt: 217 restarts
- logging/loki-0: 14 restarts
- logging/loki-canary-bbplf: 14 restarts
- logging/loki-canary-n69w2: 4 restarts
- logging/loki-canary-xbmzr: 7 restarts
- logging/loki-canary-zhxrk: 4 restarts
- logging/promtail-5jr9j: 7 restarts
- logging/promtail-94tkz: 4 restarts
- logging/promtail-br4rf: 8 restarts
- logging/promtail-hp5sc: 12 restarts
- logging/promtail-lphvc: 4 restarts
- logging/promtail-m2gzm: 13 restarts
- logging/promtail-ng69s: 17 restarts
- monitoring/bgpalerter-b7bc9c8c-kdlv5: 12 restarts
- monitoring/goldpinger-fjpnh: 11 restarts
- monitoring/goldpinger-gb4mq: 4 restarts
- monitoring/goldpinger-rb96x: 11 restarts
- monitoring/goldpinger-scljk: 5 restarts
- monitoring/goldpinger-t8x65: 12 restarts
- monitoring/monitoring-grafana-7d6c5795b8-6cvtn: 34 restarts
- monitoring/monitoring-grafana-7d6c5795b8-vbrmn: 30 restarts
- monitoring/monitoring-kube-prometheus-operator-67d8d4c647-dhmmb: 4 restarts
- monitoring/monitoring-kube-state-metrics-75f9fff55b-prwns: 160 restarts
- monitoring/monitoring-prometheus-node-exporter-6dl8r: 187 restarts
- monitoring/monitoring-prometheus-node-exporter-6sc8j: 12 restarts
- monitoring/monitoring-prometheus-node-exporter-88hp8: 13 restarts
- monitoring/monitoring-prometheus-node-exporter-8bq88: 8 restarts
- monitoring/monitoring-prometheus-node-exporter-vgp6b: 8 restarts
- monitoring/monitoring-prometheus-node-exporter-wmcb8: 48 restarts
- monitoring/prometheus-REDACTED_6dfbe9fc-0: 5 restarts
- monitoring/prometheus-REDACTED_6dfbe9fc-1: 46 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-75b84759cfvtflq: 246 restarts
- synology-csi/synology-csi-controller-0: 4 restarts
- synology-csi/synology-csi-node-4nxcz: 10 restarts
- synology-csi/synology-csi-node-kxrjb: 25 restarts
- synology-csi/synology-csi-node-l72f8: 11 restarts
- synology-csi/synology-csi-node-mrqzg: 24 restarts
- synology-csi/synology-csi-node-ptwb8: 12 restarts
- synology-csi/synology-csi-node-sfdmg: 18 restarts
- synology-csi/synology-csi-node-zch7n: 47 restarts
- velero/node-agent-54dn2: 10 restarts
- velero/node-agent-sm5xl: 5 restarts
- velero/velero-ui-687565868b-b9xr7: 10225 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE                LAST SEEN   TYPE      REASON            OBJECT                                                                  MESSAGE
default                  28m         Warning   PolicyViolation   clusterpolicy/restrict-seccomp-strict                                   Job velero/monitoring-hetzner-kopia-maintain-job-1794969187730: [autogen-check-seccomp-strict] fail; validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule autogen-check-seccomp-strict[0] failed at path /spec/template/spec/securityContext/seccompProfile/ rule autogen-check-seccomp-strict[1] failed at path /spec/template/spec/containers/0/securityContext/
default                  60m         Warning   PolicyViolation   clusterpolicy/restrict-seccomp-strict                                   ReplicaSet kube-system/hubble-ui-6bb97d8894: [autogen-check-seccomp-strict] fail; validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule autogen-check-seccomp-strict[0] failed at path /spec/template/spec/securityContext/seccompProfile/ rule autogen-check-seccomp-strict[1] failed at path /spec/template/spec/containers/0/securityContext/seccompProfile/
awx                      54m         Warning   PolicyViolation   pod/automation-job-45245-f9hq9                                          policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
awx                      54m         Warning   PolicyViolation   pod/automation-job-45245-f9hq9                                          policy REDACTED_50d055ab/adding-capabilities-strict pass: rule passed
awx                      54m         Warning   PolicyViolation   pod/automation-job-45245-f9hq9                                          policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/containers/0/securityContext/
awx                      53m         Warning   PolicyViolation   pod/automation-job-45245-f9hq9                                          policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
awx                      53m         Warning   PolicyViolation   pod/automation-job-45245-f9hq9                                          policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/containers/0/securityContext/
awx                      53m         Warning   PolicyViolation   pod/automation-job-45245-f9hq9                                          policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/containers/0/securityContext/
awx                      53m         Warning   PolicyViolation   pod/automation-job-45245-f9hq9                                          policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/containers/0/securityContext/
awx                      48m         Warning   PolicyViolation   pod/automation-job-45247-wgjrf                                          policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/containers/0/securityContext/
awx                      48m         Warning   PolicyViolation   pod/automation-job-45247-wgjrf                                          policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
awx                      48m         Warning   PolicyViolation   pod/automation-job-45247-wgjrf                                          policy REDACTED_50d055ab/adding-capabilities-strict pass: rule passed
awx                      48m         Warning   PolicyViolation   pod/automation-job-45247-wgjrf                                          policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/containers/0/securityContext/
awx                      48m         Warning   PolicyViolation   pod/automation-job-45247-wgjrf                                          policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/containers/0/securityContext/
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
nlk8s-ctrl01   1282m        32%         3837Mi          49%         
nlk8s-ctrl03   1883m        47%         4038Mi          51%         
nlk8s-node02    5238m        65%         8568Mi          87%         
nlk8s-node03    3529m        44%         7606Mi          77%         
nlk8s-node04    914m         11%         4783Mi          48%         
nlk8s-ctrl02   <unknown>    <unknown>   <unknown>       <unknown>   
nlk8s-node01    <unknown>    <unknown>   <unknown>       <unknown>   
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                2072m        4032Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                1417m        3484Mi          
backup-gateway           backup-gateway-55f78944f6-chbwm                                   876m         634Mi           
kube-system              kube-apiserver-nlk8s-ctrl03                                 634m         2317Mi          
kube-system              cilium-7rvww                                                      413m         352Mi           
kube-system              cilium-jfgsw                                                      330m         368Mi           
kube-system              etcd-nlk8s-ctrl03                                           267m         259Mi           
cilium-spire             spire-server-0                                                    256m         57Mi            
kube-system              cilium-nhh8q                                                      220m         296Mi           
kube-system              kube-apiserver-nlk8s-ctrl01                                 206m         1980Mi          
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                2072m        4032Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                1417m        3484Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 634m         2317Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 206m         1980Mi          
awx                      my-awx-task-756d768868-bslc2                                      95m          1442Mi          
awx                      my-awx-web-f9c4bb98d-wcn4j                                        19m          1373Mi          
logging                  loki-0                                                            45m          791Mi           
monitoring               monitoring-grafana-7d6c5795b8-vbrmn                               11m          699Mi           
monitoring               monitoring-grafana-7d6c5795b8-6cvtn                               50m          688Mi           
monitoring               bgpalerter-b7bc9c8c-kdlv5                                         2m           658Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
kube-system: CPU=2210m Mem=536Mi
monitoring: CPU=2210m Mem=11008Mi
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
argocd            argocd-application-controller                     1               N/A               0                     355d
argocd            argocd-applicationset-controller                  1               N/A               0                     355d
argocd            argocd-redis                                      1               N/A               0                     355d
argocd            argocd-repo-server                                1               N/A               1                     355d
argocd            argocd-server                                     1               N/A               1                     355d
awx               awx-postgres-pdb                                  1               N/A               0                     355d
awx               awx-task-pdb                                      1               N/A               0                     355d
awx               awx-web-pdb                                       1               N/A               0                     355d
backup-gateway    backup-gateway                                    1               N/A               1                     55d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     355d
kube-system       coredns-pdb                                       1               N/A               1                     355d
kube-system       metrics-server-pdb                                1               N/A               0                     63d
monitoring        monitoring-grafana                                1               N/A               1                     220d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     220d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     220d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     355d
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
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   377d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               346d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 354d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                352d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 354d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 354d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS   HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx   argocd.example.net                              10.0.X.X   80, 443   357d
awx                    awx                    nginx   awx.example.net                                 10.0.X.X   80        356d
bentopdf               bentopdf               nginx   bentopdf.example.net                            10.0.X.X   80        353d
echo-server            echo-server            nginx   echo.example.net                                10.0.X.X   80        247d
gatus                  gatus                  nginx   nl-gatus.example.net                            10.0.X.X   80, 443   336d
kube-system            hubble-ui              nginx   nl-hubble.example.net                           10.0.X.X   80        341d
REDACTED_d97cef76   REDACTED_d97cef76   nginx   nl-k8s.example.net                              10.0.X.X   80        340d
monitoring             goldpinger             nginx   goldpinger.example.net                          10.0.X.X   80        345d
monitoring             grafana                nginx   grafana.example.net                             10.0.X.X   80        356d
monitoring             prometheus             nginx   nl-prometheus.example.net                       10.0.X.X   80        340d
monitoring             thanos-query           nginx   nl-thanos.example.net                           10.0.X.X   80        341d
pihole                 pihole-ingress         nginx   pihole.example.net                              10.0.X.X   80        358d
velero                 velero-ui              nginx   velero.example.net                              10.0.X.X   80        357d
well-known             well-known             nginx   status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   335d
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
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   358d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   378d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   355d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   355d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   355d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   355d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   355d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   355d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   355d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   355d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 4 |
| External Secrets | 19 |
| Certificates | 23 |
| ServiceMonitors | 32 |
| CiliumNetworkPolicies | 5 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE    PAUSED
daily-backup    Enabled   0 2 * * *   62m          357d   false
weekly-backup   Enabled   0 3 * * 0   3d           357d   false
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
monitoring          	monitoring            	41      	2026-11-04 11:38:32.120581633 +0000 UTC	deployed	REDACTED_d8074874-79.12.0         	v0.86.2    
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
argocd                   Active   357d
awx                      Active   378d
backup-gateway           Active   55d
bentopdf                 Active   353d
cert-manager             Active   352d
cilium-secrets           Active   354d
cilium-spire             Active   354d
cnpg-system              Active   86d
default                  Active   379d
echo-server              Active   247d
external-secrets         Active   353d
gatus                    Active   336d
REDACTED_01b50c5d   Active   358d
ingress-nginx            Active   377d
kube-node-lease          Active   379d
kube-public              Active   379d
kube-system              Active   379d
REDACTED_d97cef76     Active   340d
kyverno                  Active   58d
logging                  Active   352d
monitoring               Active   378d
nfs-provisioner          Active   377d
opentofu-ns              Active   377d
pihole                   Active   358d
production               Active   358d
reloader                 Active   64d
synology-csi             Active   355d
velero                   Active   357d
well-known               Active   335d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           357d
argocd                   argocd-notifications-controller                   1/1     1            1           248d
argocd                   argocd-redis                                      1/1     1            1           357d
argocd                   argocd-repo-server                                2/2     2            2           357d
argocd                   argocd-server                                     2/2     2            2           357d
awx                      awx-operator-controller-manager                   1/1     1            1           378d
awx                      my-awx-task                                       1/1     1            1           378d
awx                      my-awx-web                                        1/1     1            1           378d
backup-gateway           backup-gateway                                    2/2     2            2           55d
bentopdf                 bentopdf                                          1/1     1            1           353d
cert-manager             cert-manager                                      1/1     1            1           352d
cert-manager             cert-manager-cainjector                           1/1     1            1           352d
cert-manager             cert-manager-webhook                              1/1     1            1           352d
cnpg-system              cnpg-cloudnative-pg                               2/2     2            2           86d
echo-server              echo-server                                       1/1     1            1           247d
external-secrets         external-secrets                                  1/1     1            1           353d
external-secrets         external-secrets-cert-controller                  1/1     1            1           353d
external-secrets         external-secrets-webhook                          1/1     1            1           353d
gatus                    gatus                                             1/1     1            1           336d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           358d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           377d
kube-system              cilium-operator                                   1/1     1            1           354d
kube-system              clustermesh-apiserver                             1/1     1            1           346d
kube-system              coredns                                           2/2     2            2           379d
kube-system              hubble-relay                                      1/1     1            1           354d
kube-system              hubble-ui                                         1/1     1            1           354d
kube-system              metrics-server                                    1/1     1            1           63d
kube-system              tetragon-operator                                 1/1     1            1           333d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           340d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           340d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           340d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           340d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           340d
kyverno                  kyverno-admission-controller                      1/1     1            1           58d
kyverno                  kyverno-reports-controller                        1/1     1            1           58d
monitoring               bgpalerter                                        1/1     1            1           338d
monitoring               monitoring-grafana                                2/2     2            2           220d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           220d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           220d
monitoring               snmp-exporter                                     1/1     1            1           340d
monitoring               thanos-query                                      2/2     2            2           341d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           377d
pihole                   pihole                                            1/1     1            1           353d
reloader                 reloader-reloader                                 1/1     1            1           64d
velero                   velero                                            1/1     1            1           357d
velero                   velero-ui                                         0/1     1            0           357d
well-known               well-known                                        1/1     1            1           335d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     357d
awx            my-awx-postgres-15                                     1/1     378d
cilium-spire   spire-server                                           1/1     354d
logging        loki                                                   1/1     333d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     220d
monitoring     prometheus-REDACTED_6dfbe9fc       2/2     220d
monitoring     thanos-compactor                                       1/1     63d
monitoring     thanos-store                                           2/2     341d
synology-csi   synology-csi-controller                                1/1     355d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           5         5         5       5            5           <none>                   354d
kube-system    cilium                                7         7         5       7            5           kubernetes.io/os=linux   354d
kube-system    cilium-envoy                          7         7         5       7            5           kubernetes.io/os=linux   354d
kube-system    kube-proxy                            7         7         5       7            5           kubernetes.io/os=linux   93d
kube-system    tetragon                              5         5         5       5            5           <none>                   333d
logging        loki-canary                           3         3         3       3            3           <none>                   341d
logging        promtail                              5         5         5       5            5           <none>                   352d
monitoring     goldpinger                            5         5         5       5            5           <none>                   345d
monitoring     monitoring-prometheus-node-exporter   5         5         5       5            5           kubernetes.io/os=linux   220d
synology-csi   synology-csi-node                     7         7         5       7            5           <none>                   355d
velero         node-agent                            3         3         3       3            3           <none>                   112d
```

---

*Full cluster context dump - v3.1.0*
