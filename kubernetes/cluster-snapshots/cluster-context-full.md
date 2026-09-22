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

**Generated:** 2026-09-22 03:00:01 UTC  
**Host:** nlk8s-ctrl01  
**Script Version:** 3.1.0

---

## Health Summary

| Indicator | Value | Status |
|-----------|-------|--------|
| Cluster State | CRITICAL | ⚠️ |
| Unhealthy Pods | 20 | 🔴 |
| Pending PVCs | 0 | ✅ |
| Total Restarts | 10238 | ⚠️ |

---

## Cluster Topology

| Property | Value |
|----------|-------|
| Kubernetes Version | v1.36.3 |
| CNI | Cilium 1.20.0 |
| Nodes | 7 total (3 control-plane, 4 workers) |
| Total Pods | 193 |

### Node Details (with Taints & Labels)

#### nlk8s-ctrl01
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 8002696Ki
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/control-plane=, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01

#### nlk8s-ctrl02
- **Role:** control-plane
- **IP:** 10.0.X.X
- **Status:** True
- **CPU:** 4 | **Memory:** 8092Mi
- **Taints:** node-role.kubernetes.io/control-plane=:NoSchedule
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
- **Status:** True
- **CPU:** 8 | **Memory:** 10054388Ki
- **Taints:** none
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
- **CPU:** 8 | **Memory:** 10053376Ki
- **Taints:** none
- **Key Labels:** beta.kubernetes.io/arch=amd64, beta.kubernetes.io/os=linux, kubernetes.io/arch=amd64, kubernetes.io/os=linux, node-role.kubernetes.io/worker=worker, topology.kubernetes.io/region=nl-lei, topology.kubernetes.io/zone=nl-lei-01


---

## Anomalies & Issues

### Unhealthy Pods
```
awx                      awx-pg-dump-29832735-9kk5w                                        0/1   Error              0                  22h
awx                      awx-pg-dump-29832735-fdmmq                                        0/1   Error              0                  22h
awx                      awx-pg-dump-29832735-jtdwq                                        0/1   Error              0                  22h
kube-system              kube-proxy-qn8md                                                  0/1   CrashLoopBackOff   8012 (4m12s ago)   36d
seaweedfs                seaweedfs-read-canary-29829623-2gd2r                              0/1   Error              0                  3d2h
seaweedfs                seaweedfs-read-canary-29829623-97727                              0/1   Error              0                  3d2h
seaweedfs                seaweedfs-read-canary-29832863-gwmbd                              0/1   Error              0                  20h
seaweedfs                seaweedfs-read-canary-29832863-htcqz                              0/1   Error              0                  20h
seaweedfs                seaweedfs-read-canary-29833223-gbcmb                              0/1   Error              0                  14h
seaweedfs                seaweedfs-read-canary-29833223-wgggp                              0/1   Error              0                  14h
seaweedfs                seaweedfs-reconciler-29833637-ptt2r                               0/1   Error              0                  7h43m
velero                   awx-default-kopia-maintain-job-1790045208808-6p4cf                0/1   Error              0                  14m
velero                   awx-default-kopia-maintain-job-1790045512851-vf72b                0/1   Error              0                  9m7s
velero                   awx-default-kopia-maintain-job-1790045808810-6qbx8                0/1   Error              0                  4m11s
velero                   monitoring-default-kopia-maintain-job-1790045213883-brg5z         0/1   Error              0                  14m
velero                   monitoring-default-kopia-maintain-job-1790045516892-pphnq         0/1   Error              0                  9m3s
velero                   monitoring-default-kopia-maintain-job-1790045812860-jj6d6         0/1   Error              0                  4m7s
velero                   pihole-default-kopia-maintain-job-1790045218925-nkw5v             0/1   Error              0                  14m
velero                   pihole-default-kopia-maintain-job-1790045508809-q4k27             0/1   Error              0                  9m11s
velero                   pihole-default-kopia-maintain-job-1790045816897-6kj82             0/1   Error              0                  4m3s
```

#### Unhealthy Pod Details

**awx/awx-pg-dump-29832735-9kk5w:**
```
Events:
  Type     Reason           Age   From          Message
  ----     ------           ----  ----          -------
  Warning  PolicyViolation  59m   kyverno-scan  policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/initContainers/0/securityContext/
  Warning  PolicyViolation  59m   kyverno-scan  policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/initContainers/0/securityContext/
  Warning  PolicyViolation  59m   kyverno-scan  policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
  Warning  PolicyViolation  59m   kyverno-scan  policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/initContainers/0/securityContext/
```

**awx/awx-pg-dump-29832735-fdmmq:**
```
Events:
  Type     Reason           Age   From          Message
  ----     ------           ----  ----          -------
  Warning  PolicyViolation  59m   kyverno-scan  policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
  Warning  PolicyViolation  59m   kyverno-scan  policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/initContainers/0/securityContext/
  Warning  PolicyViolation  59m   kyverno-scan  policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/initContainers/0/securityContext/
  Warning  PolicyViolation  59m   kyverno-scan  policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/initContainers/0/securityContext/
```

**awx/awx-pg-dump-29832735-jtdwq:**
```
Events:
  Type     Reason           Age   From          Message
  ----     ------           ----  ----          -------
  Warning  PolicyViolation  59m   kyverno-scan  policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/initContainers/0/securityContext/
  Warning  PolicyViolation  59m   kyverno-scan  policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/initContainers/0/securityContext/
  Warning  PolicyViolation  59m   kyverno-scan  policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
  Warning  PolicyViolation  59m   kyverno-scan  policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/initContainers/0/securityContext/
```

**kube-system/kube-proxy-qn8md:**
```
Events:
  Type     Reason           Age                     From          Message
  ----     ------           ----                    ----          -------
  Warning  PolicyViolation  59m                     kyverno-scan  policy REDACTED_07a81da5/host-namespaces fail: validation error: Sharing the host namespaces is disallowed. The fields spec.hostNetwork, spec.hostIPC, and spec.hostPID must be unset or set to `false`. rule host-namespaces failed at path /spec/hostNetwork/
  Warning  PolicyViolation  59m                     kyverno-scan  policy disallow-privileged-containers/privileged-containers fail: validation error: Privileged mode is disallowed. The fields spec.containers[*].securityContext.privileged and spec.initContainers[*].securityContext.privileged must be unset or set to `false`. rule privileged-containers failed at path /spec/containers/0/securityContext/privileged/
  Warning  PolicyViolation  59m                     kyverno-scan  policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/containers/0/securityContext/runAsNonRoot/
  Warning  PolicyViolation  59m                     kyverno-scan  policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/containers/0/securityContext/allowPrivilegeEscalation/
  Warning  PolicyViolation  59m                     kyverno-scan  policy restrict-volume-types/restricted-volumes fail: Only the following types of volumes may be used: configMap, csi, downwardAPI, emptyDir, ephemeral, image, REDACTED_33feff97, projected, and secret.
  Warning  PolicyViolation  59m                     kyverno-scan  policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
  Warning  PolicyViolation  59m                     kyverno-scan  policy disallow-host-path/host-path fail: validation error: HostPath volumes are forbidden. The field spec.volumes[*].hostPath must be unset. rule host-path failed at path /spec/volumes/1/hostPath/
  Warning  PolicyViolation  59m                     kyverno-scan  policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/containers/0/securityContext/seccompProfile/
```

**seaweedfs/seaweedfs-read-canary-29829623-2gd2r:**
```
Events:
  Type     Reason           Age   From          Message
  ----     ------           ----  ----          -------
  Warning  PolicyViolation  59m   kyverno-scan  policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/containers/0/securityContext/
  Warning  PolicyViolation  59m   kyverno-scan  policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/containers/0/securityContext/
  Warning  PolicyViolation  59m   kyverno-scan  policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
  Warning  PolicyViolation  59m   kyverno-scan  policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/containers/0/securityContext/
```

### High Restart Pods (>3 restarts)
- argocd/argocd-application-controller-0: 5 restarts
- awx/awx-operator-controller-manager-6ffdf98f6-x8jtt: 12 restarts
- awx/my-awx-task-756d768868-bslc2: 6 restarts
- cilium-spire/spire-agent-2xj9z: 258 restarts
- cilium-spire/spire-agent-bf7g7: 262 restarts
- cilium-spire/spire-agent-hpld8: 259 restarts
- cilium-spire/spire-agent-hrngt: 5 restarts
- cilium-spire/spire-agent-sm9xs: 259 restarts
- cilium-spire/spire-agent-xk8cl: 258 restarts
- cilium-spire/spire-agent-zqpt4: 264 restarts
- cnpg-system/cnpg-cloudnative-pg-6d8bdc546d-zl8gc: 7 restarts
- kube-system/cilium-c8kqc: 5 restarts
- kube-system/cilium-envoy-brdkr: 4 restarts
- kube-system/cilium-envoy-dzx97: 5 restarts
- kube-system/cilium-g5h5t: 4 restarts
- kube-system/cilium-operator-84c4fb58c7-jlhkp: 13 restarts
- kube-system/etcd-nlk8s-ctrl02: 5 restarts
- kube-system/kube-apiserver-nlk8s-ctrl01: 14 restarts
- kube-system/kube-apiserver-nlk8s-ctrl02: 11 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl01: 9 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl02: 7 restarts
- kube-system/kube-controller-manager-nlk8s-ctrl03: 9 restarts
- kube-system/kube-proxy-7jvns: 5 restarts
- kube-system/kube-proxy-qn8md: 8012 restarts
- kube-system/kube-scheduler-nlk8s-ctrl01: 6 restarts
- kube-system/kube-scheduler-nlk8s-ctrl02: 5 restarts
- kube-system/kube-scheduler-nlk8s-ctrl03: 9 restarts
- kube-system/tetragon-5gk99: 9 restarts
- kube-system/tetragon-75hdg: 18 restarts
- kube-system/tetragon-878gv: 8 restarts
- kube-system/tetragon-jz2b6: 10 restarts
- kube-system/tetragon-mdsn9: 35 restarts
- kube-system/tetragon-tbcc7: 10 restarts
- kube-system/tetragon-vbs6v: 16 restarts
- kyverno/kyverno-reports-controller-7bbf4b866b-2ccd2: 4 restarts
- logging/loki-canary-bbplf: 7 restarts
- logging/promtail-5jr9j: 6 restarts
- logging/promtail-br4rf: 4 restarts
- logging/promtail-hp5sc: 8 restarts
- logging/promtail-m2gzm: 7 restarts
- logging/promtail-ng69s: 10 restarts
- monitoring/goldpinger-fjpnh: 4 restarts
- monitoring/goldpinger-rb96x: 5 restarts
- monitoring/goldpinger-t8x65: 5 restarts
- monitoring/monitoring-grafana-7d6c5795b8-6cvtn: 6 restarts
- monitoring/monitoring-prometheus-node-exporter-6dl8r: 180 restarts
- monitoring/monitoring-prometheus-node-exporter-6sc8j: 10 restarts
- monitoring/monitoring-prometheus-node-exporter-88hp8: 7 restarts
- monitoring/monitoring-prometheus-node-exporter-8bq88: 4 restarts
- monitoring/monitoring-prometheus-node-exporter-vgp6b: 4 restarts
- monitoring/monitoring-prometheus-node-exporter-wmcb8: 47 restarts
- monitoring/prometheus-REDACTED_6dfbe9fc-0: 4 restarts
- nfs-provisioner/nfs-provisioner-REDACTED_5fef70be-75b84759cfvtflq: 6 restarts
- synology-csi/synology-csi-node-4nxcz: 8 restarts
- synology-csi/synology-csi-node-kxrjb: 17 restarts
- synology-csi/synology-csi-node-l72f8: 9 restarts
- synology-csi/synology-csi-node-mrqzg: 10 restarts
- synology-csi/synology-csi-node-ptwb8: 10 restarts
- synology-csi/synology-csi-node-sfdmg: 10 restarts
- synology-csi/synology-csi-node-zch7n: 35 restarts

### Pending PVCs
_None - all PVCs are Bound_

### Certificate Expiry (< 14 days)
_None - all certificates valid for 14+ days_

### Recent Warning Events
```
NAMESPACE                LAST SEEN   TYPE      REASON                 OBJECT                                                                  MESSAGE
default                  9m5s        Warning   PolicyViolation        clusterpolicy/restrict-seccomp-strict                                   Pod velero/monitoring-default-kopia-maintain-job-1790045516892-pphnq: [check-seccomp-strict] fail; validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/containers/0/securityContext/
default                  59m         Warning   PolicyViolation        clusterpolicy/REDACTED_50d055ab                              Pod velero/awx-default-kopia-maintain-job-1790042508800-vg6r9: [require-drop-all] fail; validation failure: Containers must drop `ALL` capabilities.
awx                      60m         Warning   PolicyViolation        pod/automation-job-39936-ptnvj                                          policy REDACTED_50d055ab/adding-capabilities-strict pass: rule passed
awx                      60m         Warning   PolicyViolation        pod/automation-job-39936-ptnvj                                          policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/containers/0/securityContext/
awx                      60m         Warning   PolicyViolation        pod/automation-job-39936-ptnvj                                          policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/containers/0/securityContext/
awx                      59m         Warning   PolicyViolation        pod/automation-job-39936-ptnvj                                          policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/containers/0/securityContext/
awx                      59m         Warning   PolicyViolation        pod/automation-job-39936-ptnvj                                          policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/containers/0/securityContext/
awx                      59m         Warning   PolicyViolation        pod/automation-job-39936-ptnvj                                          policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
awx                      59m         Warning   PolicyViolation        pod/automation-job-39936-ptnvj                                          policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/containers/0/securityContext/
awx                      55m         Warning   PolicyViolation        pod/automation-job-39937-l592s                                          policy REDACTED_50d055ab/require-drop-all fail: validation failure: Containers must drop `ALL` capabilities.
awx                      55m         Warning   PolicyViolation        pod/automation-job-39937-l592s                                          policy REDACTED_50d055ab/adding-capabilities-strict pass: rule passed
awx                      55m         Warning   PolicyViolation        pod/automation-job-39937-l592s                                          policy restrict-seccomp-strict/check-seccomp-strict fail: validation error: Use of custom Seccomp profiles is disallowed. The fields spec.securityContext.seccompProfile.type, spec.containers[*].securityContext.seccompProfile.type, spec.initContainers[*].securityContext.seccompProfile.type, and spec.ephemeralContainers[*].securityContext.seccompProfile.type must be set to `RuntimeDefault` or `Localhost`. rule check-seccomp-strict[0] failed at path /spec/securityContext/seccompProfile/ rule check-seccomp-strict[1] failed at path /spec/containers/0/securityContext/
awx                      55m         Warning   PolicyViolation        pod/automation-job-39937-l592s                                          policy require-run-as-nonroot/run-as-non-root fail: validation error: Running as root is not allowed. Either the field spec.securityContext.runAsNonRoot must be set to `true`, or the fields spec.containers[*].securityContext.runAsNonRoot, spec.initContainers[*].securityContext.runAsNonRoot, and spec.ephemeralContainers[*].securityContext.runAsNonRoot must be set to `true`. rule run-as-non-root[0] failed at path /spec/securityContext/runAsNonRoot/ rule run-as-non-root[1] failed at path /spec/containers/0/securityContext/
awx                      55m         Warning   PolicyViolation        pod/automation-job-39937-l592s                                          policy disallow-privilege-escalation/privilege-escalation fail: validation error: Privilege escalation is disallowed. The fields spec.containers[*].securityContext.allowPrivilegeEscalation, spec.initContainers[*].securityContext.allowPrivilegeEscalation, and spec.ephemeralContainers[*].securityContext.allowPrivilegeEscalation must be set to `false`. rule privilege-escalation failed at path /spec/containers/0/securityContext/
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
- PVC: data-seaweedfs-volume-0 (1000Gi, Bound, sc:REDACTED_b280aec5)
- PVC: data-seaweedfs-volume-1 (1000Gi, Bound, sc:REDACTED_b280aec5)
- PVC: seaweedfs-filer-meta-1 (10Gi, Bound, sc:REDACTED_b280aec5)
- PVC: seaweedfs-filer-meta-2 (10Gi, Bound, sc:REDACTED_b280aec5)

**Secrets:**
- ExternalSecret: REDACTED_073f5849 (SecretSynced)
- ExternalSecret: seaweedfs-read-canary-s3 (SecretSynced)
- ExternalSecret: seaweedfs-s3-config (SecretSynced)

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
NAME                 CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
nlk8s-ctrl01   796m         19%      3572Mi          45%         
nlk8s-ctrl02   738m         18%      4916Mi          60%         
nlk8s-ctrl03   1648m        41%      3786Mi          48%         
nlk8s-node01    1924m        24%      4908Mi          49%         
nlk8s-node02    502m         6%       5292Mi          53%         
nlk8s-node03    2485m        31%      7890Mi          80%         
nlk8s-node04    303m         3%       6728Mi          68%         
```

### Top 10 Pods by CPU
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
kyverno                  kyverno-reports-controller-7bbf4b866b-2ccd2                       1369m        73Mi            
kube-system              kube-apiserver-nlk8s-ctrl03                                 1084m        2305Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-0                855m         3787Mi          
kube-system              etcd-nlk8s-ctrl03                                           429m         159Mi           
kube-system              tetragon-mdsn9                                                    272m         501Mi           
kube-system              kube-apiserver-nlk8s-ctrl02                                 241m         2039Mi          
kube-system              etcd-nlk8s-ctrl02                                           191m         191Mi           
argocd                   argocd-application-controller-0                                   172m         353Mi           
kube-system              cilium-7rvww                                                      168m         361Mi           
kube-system              kube-apiserver-nlk8s-ctrl01                                 157m         1871Mi          
Metrics server not available
```

### Top 10 Pods by Memory
```
NAMESPACE                NAME                                                              CPU(cores)   MEMORY(bytes)   
monitoring               prometheus-REDACTED_6dfbe9fc-0                855m         3787Mi          
monitoring               prometheus-REDACTED_6dfbe9fc-1                155m         3655Mi          
kube-system              kube-apiserver-nlk8s-ctrl03                                 1084m        2305Mi          
kube-system              kube-apiserver-nlk8s-ctrl02                                 241m         2039Mi          
kube-system              kube-apiserver-nlk8s-ctrl01                                 157m         1871Mi          
awx                      my-awx-task-756d768868-bslc2                                      28m          1516Mi          
awx                      my-awx-web-f9c4bb98d-wcn4j                                        7m           1404Mi          
monitoring               thanos-compactor-0                                                1m           1005Mi          
seaweedfs                seaweedfs-filer-1                                                 31m          907Mi           
kube-system              cilium-g5h5t                                                      42m          788Mi           
Metrics server not available
```

### Resource Requests/Limits Summary
```
monitoring: CPU=2570m Mem=11968Mi
kube-system: CPU=2210m Mem=536Mi
seaweedfs: CPU=1950m Mem=8896Mi
awx: CPU=1855m Mem=3552Mi
ingress-nginx: CPU=1000m Mem=1024Mi
logging: CPU=850m Mem=2944Mi
argocd: CPU=750m Mem=1664Mi
velero: CPU=550m Mem=832Mi
REDACTED_d97cef76: CPU=400m Mem=800Mi
cnpg-system: CPU=130m Mem=400Mi
```

---

## Network & Security

### PodDisruptionBudgets
```
NAMESPACE         NAME                                              MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
argocd            argocd-application-controller                     1               N/A               0                     298d
argocd            argocd-applicationset-controller                  1               N/A               0                     298d
argocd            argocd-redis                                      1               N/A               0                     298d
argocd            argocd-repo-server                                1               N/A               1                     298d
argocd            argocd-server                                     1               N/A               1                     298d
awx               awx-postgres-pdb                                  1               N/A               0                     298d
awx               awx-task-pdb                                      1               N/A               0                     298d
awx               awx-web-pdb                                       1               N/A               0                     298d
ingress-nginx     ingress-nginx-controller                          1               N/A               1                     298d
kube-system       coredns-pdb                                       1               N/A               1                     298d
kube-system       metrics-server-pdb                                1               N/A               0                     6d13h
monitoring        monitoring-grafana                                1               N/A               1                     163d
monitoring        monitoring-kube-prometheus-operator               1               N/A               0                     163d
monitoring        monitoring-kube-state-metrics                     1               N/A               0                     163d
nfs-provisioner   nfs-provisioner-REDACTED_5fef70be   N/A             1                 1                     298d
seaweedfs         seaweedfs-filer                                   1               N/A               1                     184d
seaweedfs         seaweedfs-filer-meta-primary                      1               N/A               0                     29d
seaweedfs         seaweedfs-master                                  2               N/A               1                     184d
seaweedfs         seaweedfs-volume                                  1               N/A               1                     184d
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
| ClusterIP | 83 |
| NodePort | 6 |
| LoadBalancer | 6 |

### LoadBalancer Services
```
NAMESPACE       NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx   ingress-nginx-controller   LoadBalancer   10.103.32.106    10.0.X.X   80:31689/TCP,443:30327/TCP   320d
kube-system     clustermesh-apiserver      LoadBalancer   10.102.123.248   10.0.X.X   2379:30462/TCP               289d
kube-system     hubble-relay-lb            LoadBalancer   10.110.32.130    10.0.X.X   80:30629/TCP                 297d
logging         promtail-syslog            LoadBalancer   10.105.64.19     10.0.X.X   514:30623/TCP                295d
pihole          pihole-dns-lb              LoadBalancer   10.99.196.72     10.0.X.X   53:31803/UDP                 297d
pihole          pihole-dns-tcp-lb          LoadBalancer   10.106.199.199   10.0.X.X   53:30438/TCP                 297d
```

### Ingresses
```
NAMESPACE              NAME                   CLASS    HOSTS                                                   ADDRESS         PORTS     AGE
argocd                 argocd-server          nginx    argocd.example.net                              10.0.X.X   80, 443   300d
awx                    awx                    nginx    awx.example.net                                 10.0.X.X   80        299d
bentopdf               bentopdf               nginx    bentopdf.example.net                            10.0.X.X   80        296d
echo-server            echo-server            nginx    echo.example.net                                10.0.X.X   80        190d
gatus                  gatus                  nginx    nl-gatus.example.net                            10.0.X.X   80, 443   279d
kube-system            hubble-ui              nginx    nl-hubble.example.net                           10.0.X.X   80        284d
REDACTED_d97cef76   REDACTED_d97cef76   nginx    nl-k8s.example.net                              10.0.X.X   80        283d
monitoring             goldpinger             nginx    goldpinger.example.net                          10.0.X.X   80        288d
monitoring             grafana                nginx    grafana.example.net                             10.0.X.X   80        299d
monitoring             prometheus             nginx    nl-prometheus.example.net                       10.0.X.X   80        283d
monitoring             thanos-query           nginx    nl-thanos.example.net                           10.0.X.X   80        284d
pihole                 pihole-ingress         nginx    pihole.example.net                              10.0.X.X   80        301d
seaweedfs              seaweedfs-master       <none>   nl-seaweedfs.example.net                        10.0.X.X   80        285d
seaweedfs              seaweedfs-s3           <none>   nl-s3.example.net                               10.0.X.X   80        285d
velero                 velero-ui              nginx    velero.example.net                              10.0.X.X   80        300d
well-known             well-known             nginx    status.example.net,kyriakos.papadopoulos.tech   10.0.X.X   80, 443   278d
```

---

## Storage

| Metric | Count |
|--------|-------|
| StorageClasses | 10 |
| PersistentVolumes | 24 |
| PersistentVolumeClaims | 23 |

### StorageClasses
```
NAME                                      PROVISIONER                                                     RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
nfs-client                                cluster.local/nfs-provisioner-REDACTED_5fef70be   Delete          Immediate           true                   301d
nfs-sc                                    kubernetes.io/no-provisioner                                    Retain          Immediate           true                   321d
synology-csi-iscsi-delete                 csi.san.synology.com                                            Delete          Immediate           true                   298d
synology-csi-iscsi-retain                 csi.san.synology.com                                            Retain          Immediate           true                   298d
synology-csi-nfs-delete                   csi.san.synology.com                                            Delete          Immediate           true                   298d
synology-csi-nfs-retain                   csi.san.synology.com                                            Retain          Immediate           true                   298d
REDACTED_4f3da73d   csi.san.synology.com                                            Delete          Immediate           true                   298d
REDACTED_b280aec5   csi.san.synology.com                                            Retain          Immediate           true                   298d
synology-csi-smb-delete                   csi.san.synology.com                                            Delete          Immediate           true                   298d
synology-csi-smb-retain                   csi.san.synology.com                                            Retain          Immediate           true                   298d
```

---

## Operators & CRDs

### Key Custom Resource Counts
| Resource | Count |
|----------|-------|
| ArgoCD Applications | 4 |
| External Secrets | 21 |
| Certificates | 22 |
| ServiceMonitors | 33 |
| CiliumNetworkPolicies | 4 |
| Velero Schedules | 2 |

---

## Backup Status (Velero)

### Schedules
```
NAME            STATUS    SCHEDULE    LASTBACKUP   AGE    PAUSED
daily-backup    Enabled   0 2 * * *   60m          300d   false
weekly-backup   Enabled   0 3 * * 0   2d           300d   false
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
ingress-nginx       	ingress-nginx         	16      	2026-09-11 15:51:51.079021102 +0000 UTC	deployed	ingress-nginx-4.15.1                  	1.15.1     
k8s-agent           	REDACTED_01b50c5d	8       	2026-08-16 19:44:19.392287363 +0000 UTC	deployed	gitlab-agent-2.28.0                   	v19.1.0    
REDACTED_d97cef76	REDACTED_d97cef76  	2       	2026-02-25 19:02:27.096604857 +0000 UTC	deployed	REDACTED_d97cef76-7.14.0           	           
kyverno             	kyverno               	1       	2026-09-20 11:39:18.941723567 +0000 UTC	deployed	kyverno-3.9.1                         	v1.19.1    
kyverno-policies    	kyverno               	1       	2026-09-20 11:39:56.894631411 +0000 UTC	deployed	kyverno-policies-3.9.1                	v1.19.1    
loki                	logging               	15      	2026-09-20 10:40:01.974860793 +0000 UTC	deployed	loki-6.55.0                           	3.6.7      
metrics-server      	kube-system           	1       	2026-09-15 13:27:45.896794695 +0000 UTC	deployed	metrics-server-3.14.0                 	0.9.0      
monitoring          	monitoring            	36      	2026-09-18 13:06:08.622383879 +0000 UTC	deployed	REDACTED_d8074874-79.12.0         	v0.86.2    
nfs-provisioner     	nfs-provisioner       	9       	2026-08-16 19:44:19.484898096 +0000 UTC	deployed	REDACTED_5fef70be-4.0.18	4.0.2      
promtail            	logging               	8       	2026-03-14 22:22:09.209112925 +0000 UTC	deployed	promtail-6.17.1                       	3.5.1      
reloader            	reloader              	1       	2026-09-15 00:36:24.969024643 +0000 UTC	deployed	reloader-2.2.17                       	v1.4.22    
seaweedfs           	seaweedfs             	26      	2026-09-21 17:38:59.832215755 +0000 UTC	deployed	seaweedfs-4.44.0                      	4.44       
synology-csi        	synology-csi          	2       	2025-11-29 02:18:25.854988376 +0000 UTC	deployed	synology-csi-0.10.1                   	v1.2.0     
tetragon            	kube-system           	7       	2025-12-20 22:35:40.030282504 +0000 UTC	deployed	tetragon-1.6.0                        	1.6.0      
```

---

## Quick Reference

### All Namespaces
```
NAME                     STATUS   AGE
argocd                   Active   300d
awx                      Active   321d
bentopdf                 Active   296d
cert-manager             Active   295d
cilium-secrets           Active   297d
cilium-spire             Active   297d
cnpg-system              Active   29d
default                  Active   322d
echo-server              Active   190d
external-secrets         Active   296d
gatus                    Active   279d
REDACTED_01b50c5d   Active   301d
ingress-nginx            Active   320d
kube-node-lease          Active   322d
kube-public              Active   322d
kube-system              Active   322d
REDACTED_d97cef76     Active   283d
kyverno                  Active   39h
logging                  Active   295d
monitoring               Active   321d
nfs-provisioner          Active   320d
opentofu-ns              Active   320d
pihole                   Active   301d
production               Active   301d
reloader                 Active   7d2h
seaweedfs                Active   285d
synology-csi             Active   298d
velero                   Active   300d
well-known               Active   278d
```

### All Deployments
```
NAMESPACE                NAME                                              READY   UP-TO-DATE   AVAILABLE   AGE
argocd                   argocd-applicationset-controller                  1/1     1            1           300d
argocd                   argocd-notifications-controller                   1/1     1            1           191d
argocd                   argocd-redis                                      1/1     1            1           300d
argocd                   argocd-repo-server                                2/2     2            2           300d
argocd                   argocd-server                                     2/2     2            2           300d
awx                      awx-operator-controller-manager                   1/1     1            1           321d
awx                      my-awx-task                                       1/1     1            1           321d
awx                      my-awx-web                                        1/1     1            1           321d
bentopdf                 bentopdf                                          1/1     1            1           296d
cert-manager             cert-manager                                      1/1     1            1           295d
cert-manager             cert-manager-cainjector                           1/1     1            1           295d
cert-manager             cert-manager-webhook                              1/1     1            1           295d
cnpg-system              cnpg-cloudnative-pg                               2/2     2            2           29d
echo-server              echo-server                                       1/1     1            1           190d
external-secrets         external-secrets                                  1/1     1            1           296d
external-secrets         external-secrets-cert-controller                  1/1     1            1           296d
external-secrets         external-secrets-webhook                          1/1     1            1           296d
gatus                    gatus                                             1/1     1            1           279d
REDACTED_01b50c5d   REDACTED_ab04b573-v2                         2/2     2            2           301d
ingress-nginx            ingress-nginx-controller                          2/2     2            2           320d
kube-system              cilium-operator                                   1/1     1            1           297d
kube-system              clustermesh-apiserver                             1/1     1            1           289d
kube-system              coredns                                           2/2     2            2           322d
kube-system              hubble-relay                                      1/1     1            1           297d
kube-system              hubble-ui                                         1/1     1            1           297d
kube-system              metrics-server                                    1/1     1            1           6d13h
kube-system              tetragon-operator                                 1/1     1            1           276d
REDACTED_d97cef76     REDACTED_d97cef76-api                          1/1     1            1           283d
REDACTED_d97cef76     REDACTED_d97cef76-auth                         1/1     1            1           283d
REDACTED_d97cef76     REDACTED_d97cef76-kong                         1/1     1            1           283d
REDACTED_d97cef76     REDACTED_d97cef76-metrics-scraper              1/1     1            1           283d
REDACTED_d97cef76     REDACTED_d97cef76-web                          1/1     1            1           283d
kyverno                  kyverno-admission-controller                      1/1     1            1           39h
kyverno                  kyverno-reports-controller                        1/1     1            1           39h
monitoring               bgpalerter                                        1/1     1            1           281d
monitoring               monitoring-grafana                                2/2     2            2           163d
monitoring               monitoring-kube-prometheus-operator               1/1     1            1           163d
monitoring               monitoring-kube-state-metrics                     1/1     1            1           163d
monitoring               snmp-exporter                                     1/1     1            1           283d
monitoring               thanos-query                                      2/2     2            2           284d
nfs-provisioner          nfs-provisioner-REDACTED_5fef70be   1/1     1            1           320d
pihole                   pihole                                            1/1     1            1           296d
reloader                 reloader-reloader                                 1/1     1            1           7d2h
seaweedfs                seaweedfs-filer-sync                              1/1     1            1           284d
velero                   velero                                            1/1     1            1           300d
velero                   velero-ui                                         1/1     1            1           300d
well-known               well-known                                        1/1     1            1           278d
```

### All StatefulSets
```
NAMESPACE      NAME                                                   READY   AGE
argocd         argocd-application-controller                          1/1     300d
awx            my-awx-postgres-15                                     1/1     321d
cilium-spire   spire-server                                           1/1     297d
logging        loki                                                   1/1     276d
monitoring     alertmanager-monitoring-kube-prometheus-alertmanager   2/2     163d
monitoring     prometheus-REDACTED_6dfbe9fc       1/2     163d
monitoring     thanos-compactor                                       1/1     6d9h
monitoring     thanos-store                                           2/2     284d
seaweedfs      seaweedfs-filer                                        2/2     285d
seaweedfs      seaweedfs-master                                       3/3     285d
seaweedfs      seaweedfs-volume                                       2/2     53d
synology-csi   synology-csi-controller                                1/1     298d
```

### All DaemonSets
```
NAMESPACE      NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium-spire   spire-agent                           7         7         7       7            7           <none>                   297d
kube-system    cilium                                7         7         7       7            7           kubernetes.io/os=linux   297d
kube-system    cilium-envoy                          7         7         7       7            7           kubernetes.io/os=linux   297d
kube-system    kube-proxy                            7         7         6       7            6           kubernetes.io/os=linux   36d
kube-system    tetragon                              7         7         7       7            7           <none>                   276d
logging        loki-canary                           4         4         4       4            4           <none>                   284d
logging        promtail                              7         7         7       7            7           <none>                   295d
monitoring     goldpinger                            7         7         7       7            7           <none>                   288d
monitoring     monitoring-prometheus-node-exporter   7         7         7       7            7           kubernetes.io/os=linux   163d
synology-csi   synology-csi-node                     7         7         7       7            7           <none>                   298d
velero         node-agent                            4         4         4       4            4           <none>                   55d
```

---

*Full cluster context dump - v3.1.0*
