# Kubernetes Infrastructure — Claude Code Instructions

## Architecture

- **Cluster**: `nlcl01k8s` (ID: 1), K8s v1.34.2, API at `api-k8s.example.net:6443`
- **Nodes**: 3 control-plane (4 CPU, 8GB — ctrl02 4GB on pve02, ctrl01+ctrl03 upgraded 4→8GB on 2026-03-15) + 4 workers (8 CPU, 8GB), all Ubuntu 24.04, IPs 10.0.X.X-12 (CP), .20-23 (workers)
- **CNI**: Cilium v1.18.4, eBPF, REDACTED_fd61d0fe, VXLAN tunneling, MTU 1350
- **Pod CIDR**: 10.0.0.0/16 (NL), 10.1.0.0/16 (GR) — must not overlap for ClusterMesh
- **ClusterMesh**: Connected to GR cluster `grcl01k8s` at 10.0.X.X:2379, mTLS via ExternalSecret from OpenBao

## MCP Tools & Graph Database for K8s Work

| Tool | Use for |
|------|---------|
| `opentofu` MCP | Registry lookups — get correct resource args, provider docs, module schemas |
| `tfmcp` MCP | Local analysis — module dependency graph, resource dependencies, health scoring |
| `codegraph` MCP | **Neo4j Cypher queries** on indexed TF modules, resources, helm releases |
| `tofu graph` | CLI — DOT-format dependency graph (needs `tofu init` first) |

**Before editing any `.tf` file**, use `opentofu` MCP to look up the resource schema.
**Before refactoring modules**, query the dependency graph via `codegraph` MCP's `execute_cypher_query`:

```cypher
-- What breaks if I change cert_manager?
MATCH (m:TFModule)-[:DEPENDS_ON|REFERENCES*1..3]->(c:TFModule {name:"cert_manager"}) RETURN m.name

-- What Helm charts are in monitoring?
MATCH (h:HelmRelease {namespace:"monitoring"}) RETURN h.name, h.chart, h.version

-- Full module dependency chain
MATCH (a:TFModule)-[r:DEPENDS_ON|REFERENCES]->(b:TFModule) RETURN a.name, type(r), b.name
```

**Re-index after TF changes:**
```bash
source /home/claude-runner/.cgc-venv/bin/activate
python3 /home/claude-runner/scripts/tf-graph-indexer.py /home/claude-runner/gitlab/infrastructure/nl/production/k8s --clean
```

**OpenTofu binary:** `/home/claude-runner/.local/bin/tofu` (v1.9.0). Needs `tofu init` before `tofu graph`.

## Deployment Model

- **OpenTofu** manages all K8s resources. Never use `kubectl apply` directly for Atlantis-managed resources.
- **Atlantis** handles plan/apply via MR comments. Always create MRs for `.tf` changes.
- **Argo CD** manages 4 apps (bentopdf, pihole, velero, echo-server) from `argocd-apps/`. These auto-sync — push YAML to main.
- **State**: GitLab Terraform HTTP backend. Never run `tofu apply` locally.
- Run `tofu fmt -recursive` before committing — the pipeline enforces formatting.

## Module Structure

```
k8s/
├── main.tf              # Root orchestrator — calls all modules
├── variables.tf         # All input variables (connection, sizing, feature flags)
├── providers.tf         # Kubernetes + Helm providers
├── outputs.tf           # Deployment summary
├── terraform.tfvars     # Variable overrides (SNMP community, Gatus token)
├── _core/               # Platform infrastructure modules
│   ├── cilium/          # CNI, BGP, ClusterMesh, SPIRE mTLS, Hubble
│   ├── tetragon/        # eBPF security monitoring (5 TracingPolicies, observe-only)
│   ├── ingress-nginx/   # Hardened ingress (ModSecurity WAF, HSTS, security headers)
│   ├── cert-manager/    # Let's Encrypt DNS-01 via Cloudflare, 4 wildcard certs
│   ├── external-secrets/# ClusterSecretStore "openbao" with Kubernetes auth
│   ├── nfs-provisioner/ # StorageClass "nfs-client" → 10.0.X.X:/volume1/k8s
│   ├── nl-nas01-csi/ # Synology DS1621+ iSCSI CSI (retain + delete classes)
│   ├── gitlab-agent/    # GitLab K8s agent (2 replicas)
│   ├── REDACTED_d97cef76/ # Vendored chart (upstream archived)
│   └── pod-disruption-budgets/ # CoreDNS + Metrics Server PDBs
├── namespaces/          # Application namespace modules
│   ├── monitoring/      # REDACTED_d8074874, Thanos, Goldpinger, BGPalerter, SNMP
│   ├── logging/         # Loki (single-binary, SeaweedFS S3 backend) + Promtail (syslog)
│   ├── seaweedfs/       # S3 storage, filer.sync for NL↔GR active-active replication
│   ├── argocd/          # Argo CD (2 replica server + repo-server)
│   ├── awx/             # AWX Operator (Postgres on iSCSI, projects on NFS)
│   ├── gatus/           # Status page with BGP/IPsec/network health monitoring
│   └── well-known/      # RFC 8615 security.txt, multi-domain
└── argocd-apps/         # Argo CD application manifests (YAML, not OpenTofu)
    ├── bentopdf/        # PDF converter
    ├── echo-server/     # HTTP echo at echo.example.net
    ├── pihole/          # DNS ad-blocker with Cilium network policy
    └── velero/          # Backup (daily 2AM + weekly Sunday 3AM, SeaweedFS S3)
```

## Key Conventions

### Adding a new Atlantis-managed module
1. Create directory under `namespaces/<name>/` with `main.tf`, `variables.tf`, `outputs.tf`
2. Add module call in root `main.tf` passing `common_labels` and any required variables
3. Create MR — Atlantis will comment the plan. Comment `atlantis apply` after review.

### Adding a new Argo CD application
1. Create directory under `argocd-apps/<name>/` with `application.yaml` + K8s manifests
2. Push to main — the `bootstrap_argocd_apps` CI job applies the Application CR
3. Argo CD auto-syncs the manifests. Use `syncPolicy.automated` with `prune: true` and `selfHeal: true`.

### Storage class selection
- **NFS (`nfs-client`)**: Shared/low-IOPS workloads (Grafana dashboards, Pi-hole config, AWX projects, SPIRE data)
- **Synology iSCSI (`REDACTED_b280aec5`)**: Databases, metrics, stateful workloads (Prometheus, Loki, Postgres, Thanos, SeaweedFS)
- **Synology iSCSI (`...-delete`)**: Ephemeral stateful data (Alertmanager, Gatus)
- Use `-retain` for anything that should survive PVC deletion. Use `-delete` for replaceable data.

### Secrets
- All K8s secrets come from OpenBao via ExternalSecret resources (1h refresh)
- ClusterSecretStore name is `openbao` — reference it in all ExternalSecret specs
- OpenBao paths follow `secret/k8s/<namespace>/<secret-name>` or `secret/k8s/shared/` for cross-namespace
- cert-manager pushes the wildcard cert to OpenBao via PushSecret for GR cluster consumption

## BGP & Networking

- Cilium BGP: local ASN 65001 peers with ASA firewall at 10.0.X.X (ASN 65000)
- LB-IPAM pool: 10.0.X.X–10.0.X.X
- Current LB allocations: .64 (ingress-nginx), .65 (hubble-relay), .66 (pihole-dns-tcp), .67 (pihole-dns-udp), .68 (promtail-syslog), .69 (clustermesh-api)
- BGP timers: hold 90s, keepalive 30s
- Ingress real-IP trusted from: CH edge (198.51.100.X/32), NO edge (198.51.100.X/32), internal (10.255.2-3.0/24)

## Security Stack (all observe/detect-only, not blocking)

- **Tetragon**: 5 TracingPolicies — process exec, sensitive file access, privilege escalation, kubectl exec, network connections (disabled due to noise)
- **ModSecurity WAF**: DetectionOnly mode with OWASP CRS on ingress-nginx
- **SPIRE mTLS**: Cilium mutual TLS for pod-to-pod REDACTED_6fa691d2
- **Cilium Network Policies**: Applied to pihole, logging, gatus, well-known namespaces

## Monitoring & Observability

- **Prometheus**: 2 replicas, 200Gi each, 1095-day retention, site label `nl`
- **Thanos**: Query (2 replicas) + Store (2 replicas, SeaweedFS S3) + Compactor. GR store reached via ClusterMesh.
- **Grafana**: 2 replicas, NFS-backed (20Gi). Datasources: Prometheus (local), Thanos (cross-site), Loki (logs). 10 custom dashboards provisioned via sidecar ConfigMaps (`grafana_dashboard=1` label) — 6 managed by OpenTofu in `dashboards.tf`, 4 via kubectl. Dashboard JSON source files in `namespaces/monitoring/dashboards/`. Never import dashboards via Grafana UI — they don't survive pod restarts.
- **Loki**: Single-binary, 100Gi iSCSI, 30-day retention, SeaweedFS S3 for chunks
- **Promtail**: Syslog receiver on LB .68:514 — all Docker containers send logs here
- **BGPalerter**: Monitors AS214304 prefix for hijacks, route leaks, RPKI invalidity
- **Goldpinger**: DaemonSet for cross-node connectivity/latency testing
- **SNMP Exporter**: Polls Cisco ASA for BGP + IPsec metrics

## Cluster Snapshots

- Auto-generated daily by `k8s-cluster-snapshot.sh v3.1.0` at 03:00 UTC
- `cluster-snapshots/latest.md` — current state
- `cluster-snapshots/cluster-context-lite.md` — 3K token summary for quick troubleshooting
- `cluster-snapshots/cluster-context-full.md` — 10K token deep analysis
- `cluster-snapshots/history/` — 130+ daily snapshots since 2025-11-27
- Read `cluster-context-lite.md` first when debugging cluster issues

## Alert Pipeline

Prometheus alerts (163 rules: 150 REDACTED_d8074874 + 13 custom in `namespaces/monitoring/custom-alerts.tf`) are routed via:

```
Prometheus → Alertmanager → webhook POST to n8n
    ↓
n8n Prometheus Alert Receiver (24 nodes, ID: CqrN7hNiJsATcJGE)
    ↓ (dedup by alertname:namespace, all non-info alerts triaged)
Matrix #infra-nl-prod notification
    ↓
OpenClaw k8s-triage.sh (creates YT issue, kubectl investigation, posts findings)
    ↓ (critical alerts auto-escalated)
Claude Code L3 (reads YT comments, plans fix, waits for human approval)
```

**Custom alert rules** (`custom-alerts.tf`): ContainerOOMKilled, REDACTED_879bd353, REDACTED_02123891, REDACTED_a8a7eee8, REDACTED_67797f17, CiliumAgentNotReady, REDACTED_b94e0389, REDACTED_e52ce3d8, NFSMountStale, NFSMountHighLatency, ArgocdAppDegraded, ArgocdAppOutOfSync, HighPodRestartRate.

**Triage policy:** All non-info alerts trigger triage (no whitelist). Dedup by `alertname:namespace` prevents duplicate YT issues. Noisy alerts should be silenced in Alertmanager, not filtered in the receiver.

**YT custom fields set by k8s-triage.sh:** Hostname, Alert Rule, Severity, Namespace, Pod, Alert Source (`Prometheus`).

## Known Issues

- **kube-apiserver on ctrl01**: Intermittent HTTP 500 probe failures, 370+ restarts — present for entire cluster lifetime, does not impact stability
- **SeaweedFS filer**: Helm cleanup + filer memory re-applied at 2Gi (MR !229, 2026-03-15). Multipath/iSCSI conflict fixed via Synology multipath blacklist on all 7 K8s nodes.
- **cilium-operator**: 90+ restarts accumulated — not a recent regression
- **ArgoCD server.secretkey**: Runtime patch applied (2026-03-15). velero.io resource exclusions added via MR !230 to fix Velero OutOfSync.

## Things to Never Do

- Do not run `tofu apply` locally — always use Atlantis via MR
- Do not `kubectl apply` resources managed by OpenTofu — Atlantis will detect drift and revert
- Do not change Pod CIDR (10.0.0.0/16) — it must not overlap with GR cluster (10.1.0.0/16)
- Do not remove ExternalSecret `deletionPolicy: Retain` — secrets must survive ESO restarts
- Do not set Tetragon policies to enforce mode without explicit instruction — observe-only is intentional
- Do not switch ModSecurity from DetectionOnly to On without explicit instruction
