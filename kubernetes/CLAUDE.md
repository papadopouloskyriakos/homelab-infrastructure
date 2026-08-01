# Kubernetes Infrastructure — Claude Code Instructions

## Architecture

- **Cluster**: `nlcl01k8s` (ID: 1), K8s v1.34.2, API at `api-k8s.example.net:6443`
- **Nodes**: 3 control-plane (4 CPU, 8GB — nlk8s-ctrl02 4GB on nl-pve02, nlk8s-ctrl01+nlk8s-ctrl03 upgraded 4→8GB on 2026-03-15) + 4 workers (8 CPU, 8GB), all Ubuntu 24.04, IPs 10.0.X.X-12 (CP), .20-23 (workers)
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

- **Prometheus**: 2 replicas, 200Gi each, site label `nl`. **Retention is `24h` / `50GB` locally** (verified live 2026-07-30) — long-term storage is Thanos's job, not Prometheus's. The "1095-day retention" this line used to claim was never true of the local TSDB and misled a capacity investigation on 2026-07-30: a growth query against `prometheus-operated` returned nothing beyond 24h and had to be re-run against `thanos-query:9090`. **For any history older than a day, query Thanos.**
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

### SMS (Twilio) surface — what actually pages a human

**SMS is the only channel that pages.** Two independent paths reach the phone:

1. **Alertmanager → Twilio bridge** (`http://10.0.X.X:9106/alert`, `nlclaude01:9106`). The route matches **`tier = 1` AND `severity = critical`** only (`group_wait 10s`, `repeat 1h`, `continue = true` so it still reaches Matrix/YT). Stock kube-prometheus rules carry **no `tier` label**, so none of them can SMS — only the custom `namespaces/monitoring/*.tf` rules that set `tier = "1"`.
2. **Gatus → Twilio directly** (`gatus/main.tf`, `alerts = local.twilio_enabled ? [...]`), bypassing Alertmanager. Enabled live via `TF_VAR_gatus_twilio_*` in Atlantis's env (source of the harmless "gatus_twilio will be destroyed" phantom in the drift job — ignore it).

**Current SMS surface = 12** (operator triage 2026-08-01, MR !447):

| Path | Alerts |
|------|--------|
| Alertmanager (`tier=1`+`critical`) — **8** | `REDACTED_06ec64ac`, `REDACTED_c39c23d4`, `REDACTED_e67edccb`, `REDACTED_578414e4`, `EdgeWafNotEnforcing`, `EdgeWafNotWired`, `EdgeCrowdSecDown`, `REDACTED_22590886` |
| Gatus — **4** | `NL Kubernetes API`, `FISHA file01`, `FISHA file02`, `Home Assistant` |

**31 alerts were removed from SMS on 2026-08-01** by commenting out their `tier = "1"` label
(`# tier = "1"  # SMS-disabled 2026-08-01 …`). **`severity` stays `critical`** — every one still
fires to Matrix + YouTrack triage; only the page is gone. **Reversible: uncomment the tier line.**
Disabled set: the two SeaweedFS write-path lines; the omoikane/velero/YB-backup, PVE-pressure,
pmxcfs and NFS-poisoning infra alerts; and all agentic-platform governance + dead-man alerts
(`agentic-health-alerts.tf`, `renovate-autonomy-alerts.tf`, `scheduled-reboot-alerts.tf`, etc.).

⚠ **To re-enable one, uncomment its `tier = "1"` — do NOT re-derive from severity.** `severity =
"critical"` alone does **not** SMS; the `tier` label is the gate. And note `OmoikaneContainerMemoryCritical`
was separately set to `tier = "2"` (not commented) by MR OMOIKANE-1493 with a "restore tier=1 at
launch" note — a different mechanism, same effect (no SMS).

⚠ **`REDACTED_880627c0` is defined in two files** (`agentic-health-alerts.tf` +
`scheduled-reboot-alerts.tf`) — change both or they drift. Alertmanager dedups by `alertname`,
so a live duplicate pages once, but it is a config smell worth collapsing.

To re-audit the SMS surface: grep the custom rule files for a `tier = "1"` label co-located with
`severity = "critical"` in the same rule block (a header-comment mention of "tier" does not count),
plus the `alerts = local.twilio_enabled` blocks in `gatus/main.tf`.

## Known Issues

- **kube-apiserver on nlk8s-ctrl01**: chronic apiserver crash-loop (~1994 restarts as of 2026-07-24). **Root cause is etcd WAL fsync latency on the hypervisor's ZFS rpool — NOT the old pve01 memory-pressure / androidsdk01 story (obsolete).** ctrl01 was migrated off nl-pve01 (~2026-05) and now runs as **QEMU VM 101850601 on nlpve04** — a 4th NL hypervisor (EPYC 9334, 32c/64t, ~135 GB) absent from most docs and from the `pve/` repo; its rpool is a consumer-NVMe mirror with **no SLOG** (`zpool iostat -l` write syncq_wait ~1s). Slow etcd (WAL fdatasync 1–2 s, apply/range up to ~2 s) → apiserver `/livez` HTTP 500 → kubelet restarts it (now a graceful exit 0, not the old exit 137/OOM). Worsens during long `vzdump` backups on pve04. Tracked in **IFRNLLEI01PRD-1741** (+ **1861** etcdInsufficientMembers); a 200 MiB/s backup `bwlimit` (2026-07-09) helped but does not cover off-schedule rpool I/O (a Friday 2026-07-24 flap confirmed this). Durable fix: live-migrate ctrl01 off pve04's rpool, or add a PLP/Optane SLOG vdev. See memory `reference_etcd_tuning` + `reference_k8s_api_lb`.
- **K8s API endpoint / control-plane LB**: `api-k8s.example.net:6443` (kubeadm `controlPlaneEndpoint`, Cilium `k8sServiceHost`, and the Gatus `K8s-NL-API-down` Twilio SMS check) → VIP **10.0.X.X**, served by a keepalived + dockerized-haproxy LXC pair — **nlk8s-haproxy01** (LXC 101850401, pve01, .85.6, keepalived MASTER, normally holds the VIP) + **nlk8s-haproxy02** (LXC 103850401, pve03, .85.7, BACKUP). haproxy runs as a Docker container (`haproxytech/haproxy-alpine:latest`, cfg `/srv/haproxy/config/haproxy.cfg`, single-process → reload = `docker restart haproxy`; watchtower auto-updates the `:latest` image). **Not in any git repo/pipeline** (only the LXC `.conf` is in `pve/`) — live-is-source-of-truth. **2026-07-24:** replaced the backend's bare TCP-connect check with an HTTPS health check (`option httpchk` / `http-check send meth GET uri /readyz` / `http-check expect status 200` + `check check-ssl verify none`) so a listening-but-unhealthy apiserver (the ctrl01 flap above) is evicted from rotation instead of round-robining ~1/3 of Gatus probes onto it and paging. Also fronts OpenBao (:8200); stats on :8404. See memory `reference_k8s_api_lb`.
- **SeaweedFS filer**: Helm cleanup + filer memory re-applied at 2Gi (MR !229, 2026-03-15). Multipath/iSCSI conflict fixed via Synology multipath blacklist on all 7 K8s nodes.
- **SeaweedFS low-space deadlock (IFRNLLEI01PRD-2052, 2026-07-30)** — took the whole NL S3 write path down for 11h13m and `cv.omoikane.coach` off the public internet. **Below `minFreeSpacePercent` a volume server marks every volume read-only AND refuses to compact**, so `volume.vacuum` — the tool that reclaims space — is disabled by the condition it would fix. `volume-1` sat at 6.99% free against the chart default of 7, i.e. ~49 MB short. Verified: vacuum selected zero volumes even at `-garbageThreshold=0.001`.
  - Two settings are now **explicit** in `namespaces/seaweedfs/`: `REDACTED_0a7b20f8` (5, MR !434) and `master.garbageThreshold` (0.10, MR !435). The latter matters more than it looks — the chart leaves it null so the master ran weed's built-in **0.3**, and **no volume here has ever exceeded 30% garbage**, so automatic GC had been a no-op since install and ~68 GiB accumulated.
  - **PV expansion cannot go through a plain `atlantis apply`**: `volume_storage_size` feeds the StatefulSet `volumeClaimTemplates`, which Kubernetes treats as immutable, so the helm upgrade fails rather than resizing. Procedure (used for 500Gi→1000Gi, MR !436): patch the PVCs (Synology CSI v1.2.0 + csi-resizer expands the LUN; ext4 grew online on one server, needed a pod restart on the other), then `kubectl delete sts seaweedfs-volume --cascade=orphan` so the pods keep running, then apply — the recreated StatefulSet **adopts** them (2/2 Ready in 6s). `-max 0` means the volume-count ceiling follows the disk automatically.
  - Alerting added in `namespaces/monitoring/seaweedfs-write-path-alerts.tf`. Key on `read_only_volumes{type="isDiskSpaceLow"}` — the server's own name for the failing state — **not** on PV percentage: `KubePersistentVolumeFillingUp` fired 18 days early (IFRNLLEI01PRD-1775/-1767) and was auto-closed on threshold recovery. `volume_layout_writable` is only meaningful on the **raft leader**; followers serve a stale layout, so join against `SeaweedFS_master_is_leader == 1`.
  - **`weed shell` silently refuses mutating commands without `lock` first** — it exits 0 having done nothing. Always `printf 'lock\n<cmd>\nunlock\n' | weed shell`.
- **SeaweedFS object corruption → Velero (IFRNLLEI01PRD-2090/-2091, fixed 2026-07-30)** — the write-path outage left corrupt objects behind, and the read side had no monitoring at all, so it surfaced only by accident. **All 14 Velero `kopia.maintenance` blobs were bad, in two different ways:**
  - **8 had two chunks at offset 0** with different sizes/eTags while the filer reported the file length as the *older* chunk's size — GET returns **0 bytes**, client sees `unexpected EOF`.
  - **6 had one chunk but wrong content** — they read fine and fail with `cipher: message REDACTED_6fa691d2 failed`.
  - **A readability test is not a correctness test.** Those 6 were initially cleared as healthy because they returned bytes; they were not. Detect with the chunk count: `fs.meta.cat <path> | grep -c '"offset":  "0"'` — 1 is healthy, 2 is corrupt — but that catches only the first class.
  - **Fix:** delete the blob and let kopia recreate it (`fs.rm`, validated on one repo first — Error → `Completed`, blob recreated). Do NOT bulk-delete Tempo blocks by the same reasoning: a naive "does meta.json return bytes" scan flags ~1,171 of 39,157, but most are normal `meta.compacted.json` lifecycle state and empty debris.
  - **Consequence worth knowing:** this alone was causing Velero's chronic `PartiallyFailed` (a stable 38 errors / 78 warnings on *every* run back to 2026-05-10). Fixing the blobs — with **no Velero change** — produced the first clean backup on record (`Completed`, 3251/3251, 0 errors). Three months of backup failures were storage corruption presenting one layer up.
  - **Still missing:** nothing alerts on Velero backup phase, and nothing monitors the SeaweedFS **read** path. Every check added during the outage watches writes, so a 0-byte response to a 1890-byte object produces no signal.
- **SeaweedFS cross-site replication — stale-checkpoint recovery (MR !290, 2026-05-05)**: Two independent failure modes, same shape (persisted offset → GC'd change-log volume → permanent retry-loop). Symptom: PUT to one site doesn't appear on the other; or appears intermittently because the GR cluster-service round-robins between filers and only one has the data. (1) **Cross-site `filer.sync`** — recover by setting `filer_sync_{a,b}_from_ts_ms` in `main.tf`'s `module "seaweedfs"` block to a recent ms timestamp; **upstream's `-{a,b}.fromTsMs` flags are inverted** (`-a.fromTsMs` controls direction `b→a`, REMOTE→LOCAL — the variable's description block has full notes). MR + `atlantis apply`; pod rolling-restart picks it up. (2) **GR intra-cluster `meta_aggregator`** between `seaweedfs-filer-0` ↔ `seaweedfs-filer-1` — recover via gRPC `KvPut` on each filer's `Meta`+peer-signature key with a recent ns. Tool + step-by-step in claude-gateway: `scripts/seaweedfs/fix_meta_offset.py`, `docs/runbooks/seaweedfs-cross-site-replication.md`. **Diagnostic gotcha**: read state per-pod (port-forward each `seaweedfs-filer-N` directly), not via the cluster-service — round-robin hides per-pod metadata divergence.
- **cilium-operator**: 90+ restarts accumulated — not a recent regression
- **ArgoCD server.secretkey**: Runtime patch applied (2026-03-15). velero.io resource exclusions added via MR !230 to fix Velero OutOfSync.

## Things to Never Do

- Do not run `tofu apply` locally — always use Atlantis via MR
- Do not `kubectl apply` resources managed by OpenTofu — Atlantis will detect drift and revert
- Do not change Pod CIDR (10.0.0.0/16) — it must not overlap with GR cluster (10.1.0.0/16)
- Do not remove ExternalSecret `deletionPolicy: Retain` — secrets must survive ESO restarts
- Do not set Tetragon policies to enforce mode without explicit instruction — observe-only is intentional
- Do not switch ModSecurity from DetectionOnly to On without explicit instruction
