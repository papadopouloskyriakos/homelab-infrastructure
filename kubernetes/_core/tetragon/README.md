# Tetragon - eBPF Security Observability

This module deploys [Tetragon](https://tetragon.io/) for runtime security observability and enforcement in Kubernetes.

## What is Tetragon?

Tetragon is a Cilium sub-project that provides:
- **Process execution monitoring** - See all processes started in containers
- **File access monitoring** - Detect access to sensitive files (`/etc/shadow`, SSH keys)
- **Privilege escalation detection** - Monitor setuid, capability changes
- **Network connection visibility** - Track outbound connections from pods
- **Kubernetes-aware** - Events include pod/namespace metadata

All monitoring happens in-kernel via eBPF with minimal overhead.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Kubernetes Cluster                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐          │
│  │   Node 01   │    │   Node 02   │    │   Node 03   │          │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────┐ │          │
│  │ │Tetragon │ │    │ │Tetragon │ │    │ │Tetragon │ │          │
│  │ │ Agent   │ │    │ │ Agent   │ │    │ │ Agent   │ │          │
│  │ └────┬────┘ │    │ └────┬────┘ │    │ └────┬────┘ │          │
│  │      │      │    │      │      │    │      │      │          │
│  │      ▼      │    │      ▼      │    │      ▼      │          │
│  │  JSON Logs  │    │  JSON Logs  │    │  JSON Logs  │          │
│  │  /var/run/  │    │  /var/run/  │    │  /var/run/  │          │
│  │  cilium/    │    │  cilium/    │    │  cilium/    │          │
│  │  tetragon/  │    │  tetragon/  │    │  tetragon/  │          │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘          │
│         │                  │                  │                  │
│         └──────────────────┼──────────────────┘                  │
│                            │                                     │
│                            ▼                                     │
│                     ┌─────────────┐                              │
│                     │  Promtail   │                              │
│                     │ (DaemonSet) │                              │
│                     └──────┬──────┘                              │
│                            │                                     │
│                            ▼                                     │
│                     ┌─────────────┐                              │
│                     │    Loki     │                              │
│                     └──────┬──────┘                              │
│                            │                                     │
│                            ▼                                     │
│                     ┌─────────────┐                              │
│                     │   Grafana   │                              │
│                     │ (Dashboard) │                              │
│                     └─────────────┘                              │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

- Kubernetes 1.24+
- Linux kernel 5.8+ with BTF support (Ubuntu 22.04+ has this)
- Cilium CNI (already deployed)
- Prometheus + Grafana (REDACTED_d8074874)
- Loki + Promtail for log aggregation

## Deployment

### 1. Deploy Tetragon Module

Add module to your OpenTofu configuration:

```hcl
module "tetragon" {
  source = "./k8s/_core/tetragon"

  cluster_name = "nlcl01k8s"

  # TracingPolicy toggles (all observe-only, no enforcement)
  REDACTED_8a8d8279         = true
  REDACTED_ca9faf45      = true
  REDACTED_f45ec1ce = true
  REDACTED_936fa359         = true
  REDACTED_073bcdbd      = false  # Can be noisy

  # Grafana dashboard
  enable_grafana_dashboard      = true
  REDACTED_060311fa   = "monitoring"
}
```

### 2. Update Promtail Configuration

Add the Tetragon scrape config from `PROMTAIL_CONFIG_SNIPPET.yaml` to your Promtail Helm values.

### 3. Apply Changes

```bash
# Via Atlantis
git checkout -b feature/tetragon
git add k8s/_core/tetragon/
git commit -m "feat: Add Tetragon runtime security observability"
git push origin feature/tetragon
# Create MR and let Atlantis plan/apply

# Or directly
cd k8s/_core/tetragon
tofu init
tofu plan
tofu apply
```

## Deployed Resources

| Resource | Type | Description |
|----------|------|-------------|
| `tetragon` | Helm Release | Tetragon DaemonSet + Operator |
| `REDACTED_de85e9d6` | TracingPolicy | Monitors process executions |
| `REDACTED_8cae118b` | TracingPolicy | Monitors file access |
| `REDACTED_bbe670ef` | TracingPolicy | Monitors privilege changes |
| `REDACTED_e2274e6a` | TracingPolicy | Monitors shell access |
| `tetragon-security-dashboard` | ConfigMap | Grafana dashboard |

## TracingPolicies

All policies are **observe-only** (no enforcement). Events are logged to Loki.

| Policy | What it monitors |
|--------|------------------|
| `REDACTED_de85e9d6` | All process executions via `execve` |
| `REDACTED_8cae118b` | Access to `/etc/shadow`, `/etc/passwd`, SSH keys, K8s secrets |
| `REDACTED_bbe670ef` | `setuid`, `setgid`, capability changes |
| `REDACTED_e2274e6a` | Shell processes (`bash`, `sh`, `zsh`) |
| `network-connection-monitor` | TCP connections (disabled by default - noisy) |

## Verification

```bash
# Check Tetragon pods are running
kubectl get pods -n kube-system -l app.kubernetes.io/name=tetragon

# Check TracingPolicies
kubectl get tracingpolicies

# View live events (from any Tetragon pod)
kubectl exec -n kube-system ds/tetragon -c tetragon -- tetra getevents -o compact

# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus-operated 9090
# Open http://localhost:9090/targets and search for "tetragon"

# Check logs in Grafana
# Navigate to Explore → Loki → {job="tetragon"}
```

## Example Events in Loki

```logql
# All Tetragon events
{job="tetragon"}

# Process executions
{job="tetragon", event_type="process_exec"}

# Events in specific namespace
{job="tetragon", namespace="default"}

# Sensitive file access
{job="tetragon"} |= "/etc/shadow"

# Shell executions
{job="tetragon"} |= "bash" or |= "/bin/sh"
```

## Grafana Dashboard

The deployed dashboard includes:
- **Overview stats**: Total events, process exec count, kprobe events
- **Event timeline**: Events over time by type
- **Security events log**: Live log viewer with JSON parsing
- **Agent metrics**: CPU/memory usage of Tetragon pods

Access via Grafana → Dashboards → "Tetragon Security Observability"

## Upgrading

Update `tetragon_version` variable and run:

```bash
tofu plan
tofu apply
```

## Troubleshooting

### Tetragon pods not starting

```bash
# Check pod status
kubectl describe pod -n kube-system -l app.kubernetes.io/name=tetragon

# Check for BTF issues
kubectl logs -n kube-system -l app.kubernetes.io/name=tetragon -c tetragon | grep BTF
```

### No events in Loki

```bash
# Verify Promtail is scraping Tetragon logs
kubectl logs -n logging -l app.kubernetes.io/name=promtail | grep tetragon

# Check Tetragon is exporting events
kubectl exec -n kube-system ds/tetragon -c tetragon -- ls -la REDACTED_fa94d8bd/
```

### TracingPolicy not working

```bash
# Check policy status
kubectl get tracingpolicies -o wide

# Check Tetragon operator logs
kubectl logs -n kube-system -l app.kubernetes.io/name=tetragon-operator
```

## Future Enhancements

- [ ] Add enforcement mode for specific policies
- [ ] Create PrometheusRules for alerting
- [ ] Add more TracingPolicies (crypto miner detection, container escape)
- [ ] Export to SIEM integration

## References

- [Tetragon Documentation](https://tetragon.io/docs/)
- [Tetragon GitHub](https://github.com/cilium/tetragon)
- [TracingPolicy Examples](https://github.com/cilium/tetragon/tree/main/examples/tracingpolicy)
- [Helm Chart Reference](https://tetragon.io/docs/reference/helm-chart/)
