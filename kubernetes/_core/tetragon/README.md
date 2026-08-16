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
│  │  /var/log/  │    │  /var/log/  │    │  /var/log/  │          │
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

Add module to your OpenTofu configuration (identical on NL and GR):

```hcl
module "tetragon" {
  source = "./_core/tetragon"

  # TracingPolicy toggles (all observe-only, no enforcement)
  REDACTED_8a8d8279         = false # raw_syscalls tracepoint is high-volume
  REDACTED_ca9faf45      = true
  REDACTED_f45ec1ce = true
  REDACTED_936fa359         = true
  REDACTED_073bcdbd      = false # Can be noisy

  # ServiceMonitor for Prometheus
  REDACTED_46d876c8 = true

  # Rate limit exports
  export_rate_limit = 1000
}
```

### 2. Update Promtail Configuration

Add the Tetragon scrape config from `PROMTAIL_CONFIG_SNIPPET.yaml` to your Promtail Helm values.

### 3. Apply Changes

```bash
# Via Atlantis (the ONLY supported apply path — never run tofu apply locally)
git checkout -b feature/tetragon
git add k8s/_core/tetragon/
git commit -m "feat(k8s): Add Tetragon runtime security observability"
git push origin feature/tetragon
# Create MR, review the Atlantis plan, then comment: atlantis apply -p k8s
```

## Deployed Resources

| Resource | Type | Description |
|----------|------|-------------|
| `tetragon` | Helm Release | Tetragon DaemonSet + Operator |
| `REDACTED_de85e9d6` | TracingPolicy | Monitors process executions (disabled by default) |
| `REDACTED_8cae118b` | TracingPolicy | Monitors file access |
| `REDACTED_bbe670ef` | TracingPolicy | Monitors privilege changes |
| `REDACTED_e2274e6a` | TracingPolicy | Monitors shell access |
| `network-connection-monitor` | TracingPolicy | Monitors TCP connections (disabled by default) |

## TracingPolicies

All policies are **observe-only** (no enforcement). Events are logged to Loki.

| Policy | What it monitors |
|--------|------------------|
| `REDACTED_de85e9d6` | All process executions via `execve` (disabled by default - high volume) |
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

This module does not ship a dashboard ConfigMap. Import the official Tetragon
dashboard from Grafana Labs instead:
- **Dashboard ID**: 20189
- **Name**: Tetragon "kubectl exec" Audit

Tetragon exposes metrics on port 2112 (agent) and 2113 (operator); ServiceMonitors
are created when `REDACTED_46d876c8 = true`.

```promql
# Events per second
sum(rate(tetragon_events_total[5m]))
```

## Upgrading

Update `tetragon_version` variable, create an MR, review the Atlantis plan and
comment `atlantis apply -p k8s`.

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
kubectl exec -n kube-system ds/tetragon -c tetragon -- ls -la /var/log/tetragon/
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
