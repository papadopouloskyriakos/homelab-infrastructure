# Kubernetes Infrastructure — Claude Code Instructions

## Architecture

- **Cluster**: `nlcl01k8s` (ID: 1), K8s **v1.36.3** (upgraded 1.34.2→1.35.7→1.36.3 on 2026-08-16, IFRNLLEI01PRD-2373; etcd 3.6.8, CoreDNS 1.14.2), API at `api-k8s.example.net:6443`
- **Nodes**: 3 control-plane (4 CPU, 8GB) + 4 workers (8 CPU, 8GB), all Ubuntu 24.04.3, IPs 10.0.X.X-12 (CP), .20-23 (workers). **ctrl02 is an LXC on nl-pve02** (kernel = pve02's host kernel, 7.0.14-12-pve; every kubeadm operation on it needs `--ignore-preflight-errors=SystemVerification`); the other 6 are QEMU VMs on kernel 7.0.0-28-generic (HWE track, converged 2026-08-16)
- **CNI**: Cilium **v1.20.0** (bumped from 1.19.5 via MR !464 with `REDACTED_d95cbb1b=1.19` + `bpf.datapathMode=veth` pinned — 1.20 defaults datapathMode to netkit-probing "auto"), eBPF, REDACTED_fd61d0fe, VXLAN tunneling, MTU 1350. ⚠ A kube-proxy DaemonSet ALSO exists (kubeadm-managed) despite REDACTED_fd61d0fe — pre-existing, under review
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
- **Argo CD** manages 4 apps (bentopdf, pihole, velero, echo-server) from `argocd-apps/`. These auto-sync — push YAML to main. `argocd-apps/velero/` is canonical (byte-identical with GR, incl. the 13-CRD `crds.yaml` pinned v1.17.1); the other three are NL-only (mirror-exempt).
- **State**: GitLab Terraform HTTP backend. Never run `tofu apply` locally.
- **The root is tfvars-driven since 2026-08-16 (mirror campaign):** `main.tf`/`variables.tf`/`providers.tf`/`outputs.tf` are canonical (byte-identical with GR, zero site literals); ALL site values live in `terraform.tfvars` (77 keys, key-set parity with GR asserted by the mirror check); `site-storage.tf` holds the per-site CSI module call (nl-nas01-csi) and is the only mirror-exempt root `.tf` file. `moved.tf`/`imports.tf` were spent and deleted. Secrets stay in Atlantis `TF_VAR_*` env — tfvars values would override them.
- Run `tofu fmt -recursive` before committing — the pipeline enforces formatting.

## Mirror contract

THREE `k8s/` trees are a **character-perfect mirror** of one hub form: **NL (the hub)** `infrastructure/nl/production` (gitlab.example.net, project 7), **GR** `infrastructure/gr/production` (gr-gitlab.example.net, project 5), and **NO** `infrastructure/notrf01/production` (gitlab.example.net, project 58, Atlantis instance `Atlantis-no`) — byte-identical except site-unique identifiers, checked hub-pairwise (NL↔GR, NL↔NO). This section is IDENTICAL in all three repos' `k8s/CLAUDE.md`. Every `k8s/` edit falls into exactly one of the four file classes below; know which one before you touch a file.

### File classes

| Class | Files | Rule |
|-------|-------|------|
| **Canonical (byte-identical)** | Every `.tf` under `_core/*` (except the site storage module dirs) and `namespaces/*`; root `main.tf` / `variables.tf` / `providers.tf` / `outputs.tf`; `argocd-apps/velero/*`; `ci/k8s.yml`; `atlantis.yaml`; `.githooks/pre-commit`; `scripts/k8s-mirror-*` | NO site identifiers in file content — every site value is `var.*` fed from tfvars. Edits MUST be ported to BOTH twins (see THE RULE). |
| **Site values** | root `terraform.tfvars` | The ONLY home of site-unique values. The diff asserts all files carry the **same key set**; values differ per the identifier dictionary. Secrets stay in the Atlantis `TF_VAR_*` env — never in tfvars (tfvars values OVERRIDE env vars). Adding a key in one repo without the twins fails the key-set gate. |
| **Site structural (same name, per-site content)** | root `site-storage.tf` (the per-site storage module call: NL = synology-csi against nl-nas01, GR = democratic-csi against the gr-pve02 ZFS pool, NO = openebs-localpv hostpath on the 160G shared roots); `namespaces/monitoring/scrape-estate.tf` (NL = the estate-wide scrape jobs, GR and NO = stubs defining `estate_scrape_configs = []`) | Deliberately different content behind an identical filename, so `main.tf` (root and monitoring) stays byte-identical. All are on the exemption manifest. Do not "align" them. |
| **Exempt** | Everything listed in `scripts/k8s-mirror-exempt.txt`: the three site storage module dirs, `terraform.tfvars` (key-set-checked instead), the estate/NL-subsystem alert files (`estate-alerts.tf`, `host-pressure-alerts.tf`, `infrastructure-integrity-alerts.tf`, the omoikane/edge/intersite/agentic `*-alerts.tf` set), `dashboards.tf` + `dashboards/`, NL-only `argocd-apps/{bentopdf,echo-server,pihole}`, `CLAUDE.md`, `README.md`, `cluster-snapshots/`, `secrets/`, lock/terraform dirs | Every entry MUST carry a reason comment. Removing an entry = claiming the path is now canonical. |

### Tooling

- `scripts/k8s-mirror-diff.sh` (v2, hub-pairwise) + the per-twin identifier maps `scripts/k8s-mirror-map-gr.txt` / `scripts/k8s-mirror-map-no.txt` (twin→NL normalization, longest-match-first) + `scripts/k8s-mirror-exempt.txt` — all of them are themselves canonical and identical in all three repos.
- The script carries a twin table SITE → (checkout path, map file, guard regex). Run locally on the claude-runner host: `scripts/k8s-mirror-diff.sh` (no args = every configured twin whose checkout exists; a missing checkout — e.g. the NO repo before provisioning — is skipped WITH a warning); `scripts/k8s-mirror-diff.sh gr` / `... no` checks one twin. Exit 0 = mirror holds for every twin checked; exit 1 prints the divergence; exit 2 = setup error.
- How it works, per twin: prune exempt paths → normalize twin-form identifiers to NL hub form **only in files that already differ** (canonical files legitimately mention other sites' values in comments and the gatus endpoint union — rewriting them would manufacture divergence) → guard: any twin-form token surviving normalization in a differing file is itself a failure (dictionary gap) → assert tfvars key-set equality → byte-diff.
- CI job `k8s_mirror_check` (stage verify, scheduled + on main k8s changes) is **pending**: it needs `ci/mirror` OpenBao tokens for the cross-instance clone. Until wired, local runs are the proof.

### THE RULE

> **Any edit to a canonical file must be ported to BOTH twin repos the same day, and `k8s-mirror-diff.sh` must exit 0 for every present twin before the LAST merge.**

Corollaries:
- Never introduce a site identifier into a canonical file — hoist it to a variable and put the value in all three tfvars files.
- Pair the MRs: NL-first, twins same day (the campaign convention). One open k8s MR per repo at a time (Atlantis lock).
- A key added to one `terraform.tfvars` must be added to the twins the same day.
- Changes to this section, the maps, or the exempt manifest are themselves canonical edits — port them too.
- During an NL↔GR partition, GR CI cannot authenticate to OpenBao (GR raft minority) — don't merge k8s MRs during tunnel instability. (The NO repo lives on the NL GitLab, so NL↔GR partitions do not block it — but a NO-site overlay outage blocks its Atlantis apply reaching the NO cluster.)

### Identifier dictionary (NL ↔ GR ↔ NO)

The authoritative machine-readable pairs live in `terraform.tfvars` (all three files, same keys) and `scripts/k8s-mirror-map-{gr,no}.txt`. Human summary (NO values are the IFRNLLEI01PRD-2403 plan; the NO repo/cluster is being provisioned):

| Concept | NL | GR | NO |
|---------|----|----|----|
| Cluster name / ID | `nlcl01k8s` / 1 | `grcl01k8s` / 2 | `notrf01cl01k8s` / 3 |
| site / site_code / node_region | `nl` / `nl` / `nl-lei` | `gr` / `gr` / `gr-skg` | `no` / `notrf01` / `no-trf` |
| Node subnet / pod CIDR | 192.168.85.x / 10.0.0.0/16 | 192.168.58.x / 10.1.0.0/16 | overlay loopbacks 10.255.{4,5,7,8,9,10}.11 / 10.2.0.0/16 |
| API endpoint | api-k8s.example.net (VIP .85.5) | gr-api-k8s.example.net (VIP .58.5) | no-api-k8s.example.net (VIP 10.255.11.5) |
| LB pool / BGP peer | .85.64–.126 / ASA 10.0.X.X | .58.64–.126 / ASA 10.0.X.X | none — no ASA (`cilium_bgp_enabled = false`) |
| BGP ASNs | 65001 (k8s) / 65000 (ASA) — **identical NL+GR, NOT site-unique** | same | n/a (BGP gate off) |
| ClusterMesh endpoint (own) | 10.0.X.X:2379 | 10.0.X.X:2379 | none initially (`clustermesh_enabled = false`) |
| Cilium MTU | 1350 | 1350 | 1300 (overlay path) |
| Service FQDNs | unprefixed / `nl-*` (grafana., argocd., nl-prometheus., nl-s3., …) | `gr-*` (gr-grafana., gr-argocd., gr-prometheus., gr-s3., …) | `no-*` (no-grafana., no-argocd., no-prometheus., …) |
| GitLab / project id / Atlantis | gitlab.example.net / 7 / project `k8s` | gr-gitlab.example.net / 5 / project `k8s` | gitlab.example.net / 58 / project `k8s` (Atlantis-no) |
| TF state name | `k8s-production-state` | `k8s-gr-production-state` | `k8s-no-production-state` |
| OpenBao CI role / JWT mount / prefix | `gitlab-ci` / `jwt` / `ci/` | `gitlab-ci-gr` / `jwt-gr` / `ci-gr/` | `gitlab-ci-no` / `jwt` (same NL GitLab issuer) / `ci-no/` |
| ESO auth mount | `kubernetes` | `kubernetes-gr` | `kubernetes-notrf01` |
| NFS | 10.0.X.X:/volume1/k8s | 10.0.X.X:/exports/nfs/k8s | none (`nfs_enabled = false`) |
| Storage classes (backend) | `synology-csi-nl-nas01-iscsi-{retain,delete}` (Synology DS1621+) | `iscsi-ssd-{retain,delete}` (democratic-csi, ZFS on gr-pve02) | `local-hostpath-{retain,delete}` (OpenEBS LocalPV, 160G shared roots) |
| S3 buckets | `loki` / `thanos-nl` / `velero` | `loki-gr` / `thanos-gr` / `velero-gr` | `loki-no` / `thanos-no` / `velero-no` — loki-no/thanos-no on the LOCAL NO SeaweedFS (7 pods run there — audit fix 2026-08-18); velero-no + etcd-snapshots-no on NL S3 (velero BSL s3Url = https://nl-s3.example.net) |
| cert-manager role | issuer (`acme_issuer_enabled = true`: ACME + 19 Certificates + PushSecret) | consumer (`false`: ExternalSecret pulls `REDACTED_2812d784`) | consumer (`false`) |
| Estate scrapes / estate alerts | `estate_scrape_enabled = true` + the estate alert files | `false` + stub / exempt (see below) | `false` + stub |
| Gating vars (2403) | clustermesh/bgp/nfs/asa_snmp/thanos_remote/awx all `true`; remote-write receiver `true` (hub) | all `true`; receiver `false` | **all `false`**; `prometheus_remote_write_url` → NL receiver (satellite) |
| Twilio bridge | http://10.0.X.X:9106/alert (nlclaude01) | http://10.0.X.X:9106/alert (grclaude01) | NL bridge over the overlay (http://10.0.X.X:9106/alert) |
| Alertmanager n8n webhook | …/webhook/prometheus-alert | …/webhook/prometheus-alert-gr | …/webhook/prometheus-alert-no |
| Timezone / site name | Europe/Amsterdam / Netherlands | Europe/Athens / Greece | Europe/Oslo / Norway |

### Adding a new module — canonical from day one

1. Author the module byte-identical in ALL repos (`_core/<name>/` or `namespaces/<name>/`) with `main.tf`, `variables.tf`, `outputs.tf`. No site literals — anything site-specific is a module variable.
2. Wire it in the canonical root `main.tf` passing `common_labels` and `var.*` only; declare the vars once in the canonical `variables.tf`; put the per-site values in ALL `terraform.tfvars` files (same key set). If a site cannot run it at all, gate the module call with a `count` on a `*_enabled` var (defaults preserving NL/GR) plus a `moved {}` block so existing state maps to `[0]` — the nfs_provisioner/awx pattern.
3. If it can only ever run on one site (an estate subsystem), do NOT half-mirror it: give it its own file, add that file to `scripts/k8s-mirror-exempt.txt` with a reason, and give the other sites a stub only if a canonical file references it (the `scrape-estate.tf` pattern).
4. Run `scripts/k8s-mirror-diff.sh` before any merge; NL MR first, twin MRs same day.

### The estate-alerts / scrape-estate NL-only pattern (why: double-fire)

Estate-wide subsystems (edge VPS, omoikane, PVE hosts, DMZ, chatops, agentic platform, …) are scraped and alerted from exactly **one** Prometheus — NL's. Mirroring those scrape jobs or alert rules to GR would fire every estate alert twice: two YT issues, two Matrix posts, two pages per event. Therefore:

- `namespaces/monitoring/scrape-estate.tf` is site-structural: NL's copy defines `local.estate_scrape_configs` (the estate jobs); GR's and NO's copies define `[]`. `namespaces/monitoring/main.tf` concatenates it unconditionally and stays byte-identical.
- The estate/NL-subsystem alert files (`estate-alerts.tf` + the omoikane/edge/intersite/agentic/etc. `*-alerts.tf` set) exist only in the NL repo and are on the exemption manifest. `estate-alerts.tf` gained `REDACTED_50695a0e` on 2026-08-23 (>7d, all estate node-exporter jobs): a node_exporter textfile gauge has NO staleness of its own — a dead producer's `.prom` is re-served forever, so Prometheus shows month-old values with fresh timestamps, which reads as healthy rather than absent. Found when a YouTrack-hygiene gauge served `open=433` for 28 days while the truth was 85.
- `host-pressure-alerts.tf` and `infrastructure-integrity-alerts.tf` are ALSO exempt for a different reason: they key on PVE `node_exporter` / `pve_wedge` / `asa_binding` series that GR's Prometheus does not scrape — on GR they would be can-never-fire rules (worse than absent). If GR PVE exporters ever land, revisit with var-driven targets.
- Cluster-local alerts ARE mirrored and canonical: `custom-alerts.tf` (16 rules — the 16th is `REDACTED_50666b71`, OMOIKANE-1657 2026-08-23: an Argo Application whose `syncPolicy.automated` is removed still reads Synced/Healthy while merges stop deploying, which `ArgocdAppOutOfSync` is structurally blind to until the next merge; note both Argo rules were DECORATIVE until the same MR added the argocd metrics Services + ServiceMonitors — Prometheus held zero `argocd_*` series), `seaweedfs-write-path-alerts.tf` (3), `velero-backup-alerts.tf` (6) — byte-identical, firing per-site against each cluster's own Prometheus.

## Module Structure

```
k8s/
├── main.tf              # Root orchestrator — CANONICAL, all module calls var-driven
├── variables.tf         # CANONICAL union var set (122 vars, declared once each)
├── providers.tf         # CANONICAL — Kubernetes + Helm providers (~> 3.2.0 both)
├── outputs.tf           # CANONICAL — var-driven deployment summary
├── site-storage.tf      # SITE FILE — nl-nas01-csi module call (GR: democratic-csi)
├── terraform.tfvars     # SITE FILE — ALL site values (77 keys, key-set parity with GR)
├── _core/               # Platform infrastructure modules (all canonical except the CSI dir)
│   ├── cilium/          # CNI, BGP, ClusterMesh, SPIRE mTLS, Hubble
│   ├── tetragon/        # eBPF security monitoring (observe-only)
│   ├── ingress-nginx/   # Hardened ingress 4.15.1 (ModSecurity WAF → stdout, HSTS, headers)
│   ├── cert-manager/    # ONE canonical module, role-gated: NL = issuer (acme_issuer_enabled=true —
│   │                    #   ACME DNS-01/Cloudflare, the Certificate fleet, PushSecret to OpenBao)
│   ├── external-secrets/# ClusterSecretStore "openbao" (inline caBundle), auth mount "kubernetes"
│   ├── cnpg-operator/   # CloudNativePG DB-tier operator — canonical, gated `cnpg_enabled`
│   │                    #   (notrf01 true; NL/GR count=0 no-op). Operator+CRDs only; Cluster CRs app-tier
│   ├── nfs-provisioner/ # StorageClass "nfs-client" → 10.0.X.X:/volume1/k8s — SC chart-managed
│   │                    #   (helm-adopted 2026-08-16; do NOT flip storageClass.create back to false)
│   ├── nl-nas01-csi/ # SITE MODULE — Synology DS1621+ iSCSI CSI (retain + delete classes)
│   ├── gitlab-agent/    # GitLab K8s agent 2.28.0
│   ├── REDACTED_d97cef76/ # Vendored chart (upstream archived)
│   └── pod-disruption-budgets/ # CoreDNS + Metrics Server PDBs (selector per-site var)
├── namespaces/          # Application namespace modules (all canonical)
│   ├── monitoring/      # REDACTED_d8074874 79.12.0, Thanos v0.42.4, Goldpinger, BGPalerter, SNMP
│   │                    #   canonical rules: custom-alerts.tf + seaweedfs-write-path + velero-backup
│   │                    #   NL-ONLY (mirror-exempt): estate-alerts.tf + the estate/omoikane/edge
│   │                    #   *-alerts.tf set, dashboards.tf; scrape-estate.tf = NL estate scrape jobs
│   │                    #   (GR carries an empty stub of the same file)
│   ├── logging/         # Loki 6.55.0 (single-binary, SeaweedFS S3) + Promtail (syslog)
│   ├── seaweedfs/       # S3 storage; NL runs the single bidirectional filer.sync (NL↔GR replication)
│   ├── argocd/          # Argo CD chart 7.7.10 (2 server + 2 repo-server replicas on NL)
│   ├── awx/             # AWX Operator (Postgres on iSCSI static PV, projects on NFS "projects")
│   ├── gatus/           # Status page v5.36.0 (endpoint union — monitors BOTH sites' services)
│   └── well-known/      # RFC 8615 security.txt, multi-domain, Certificate + CNP
└── argocd-apps/         # Argo CD application manifests (YAML, not OpenTofu)
    ├── bentopdf/        # PDF converter (NL-only, mirror-exempt)
    ├── echo-server/     # HTTP echo at echo.example.net (NL-only, mirror-exempt)
    ├── pihole/          # DNS ad-blocker with Cilium network policy (NL-only, mirror-exempt)
    └── velero/          # CANONICAL — backup (daily 2AM TTL 336h + weekly Sun 3AM TTL 1440h,
                         #   excludedNamespaces incl. seaweedfs; crds.yaml 13 CRDs pinned v1.17.1)
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

- **Tetragon**: 5 TracingPolicies defined, 3 enabled (sensitive file access, privilege escalation, kubectl exec); process exec + network connections disabled (noise) — flags identical on both sites (canonical module + root call)
- **ModSecurity WAF**: DetectionOnly mode with OWASP CRS on ingress-nginx
- **SPIRE mTLS**: Cilium mutual TLS for pod-to-pod REDACTED_6fa691d2
- **Cilium Network Policies**: Applied to pihole, logging, gatus, well-known namespaces

## Monitoring & Observability

- **Prometheus**: 2 replicas, 200Gi each, site label `nl`. **Hub for notrf01's remote-write** (`enableRemoteWriteReceiver`, via `nl-prometheus.example.net` → ingress-nginx). ⚠ The unfiltered satellite stream (545k series) OOM-looped both replicas at their 6.5Gi limit within a day of the 08-18 cutover (8GB nodes — the limit cannot go higher); since 2026-08-20 the **sender drops `__name__=~".+_bucket"`** (writeRelabelConfigs in the canonical satellite overlay, MRs !494/NO!10/GR!108) — hub keeps `_sum`/`_count` (rates/means fine, cross-site quantiles gone; notrf01's local Prometheus retains full resolution). Head ≈630k post-fix; if OOMs recur, extend the sender drop list — do NOT raise the limit. **Retention is `24h` / `50GB` locally** (verified live 2026-07-30) — long-term storage is Thanos's job, not Prometheus's. The multi-year retention this line used to claim was never true of the local TSDB and misled a capacity investigation on 2026-07-30: a growth query against `prometheus-operated` returned nothing beyond 24h and had to be re-run against `thanos-query:9090`. **For any history older than a day, query Thanos.**
- **Thanos**: **v0.42.4** (bumped from v0.37.2 in the 2026-08-16 mirror campaign, batch 3c) — Query (2 replicas) + Store (2 replicas, SeaweedFS S3, now with a startupProbe: a v0.42 index re-sync got probe-killed on GR without it) + Compactor. Bucket `thanos-nl`. GR store reached via ClusterMesh.
- **Grafana**: 2 replicas, NFS-backed (20Gi). Datasources: Prometheus (local), Thanos (cross-site), Loki (logs), OpenObserve (read-only; credential via ExternalSecret `monitoring-openobserve-ro` ← OpenBao `secret/REDACTED_17ddacf8` + Grafana `$__file` provider — the plaintext password that sat in `monitoring/main.tf` left git in the 2026-08-16 campaign, D28; rotation of the credential itself is a pending follow-up). 10 custom dashboards provisioned via sidecar ConfigMaps (`grafana_dashboard=1` label) — 6 managed by OpenTofu in `dashboards.tf`, 4 via kubectl. Dashboard JSON source files in `namespaces/monitoring/dashboards/`. Never import dashboards via Grafana UI — they don't survive pod restarts.
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

Prometheus alerts (391 rules across 65 groups live 2026-07-30 — the old "163/13 custom" figure is stale; custom rules live in `namespaces/monitoring/*.tf`) are routed via:

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

**Custom alert rules — split in the 2026-08-16 mirror campaign (batch 3a, MR !469):**
- `custom-alerts.tf` (CANONICAL, byte-identical with GR, 15 rules): ContainerOOMKilled, REDACTED_879bd353, REDACTED_02123891, REDACTED_a8a7eee8, REDACTED_67797f17, CiliumAgentNotReady, REDACTED_b94e0389, REDACTED_e52ce3d8, NFSMountStale, NFSMountHighLatency, ArgocdAppDegraded, ArgocdAppOutOfSync, HighPodRestartRate, PodCrashLoopBackOff (adopted from GR), NodeOOMKill (host-level kernel OOM — catches non-pod/compose OOMs, IFRNLLEI01PRD-2414).
- `estate-alerts.tf` (NL-ONLY, mirror-exempt, 7 rules): Pacemaker×2, OmoikaneClamav×2, OmoikaneRestic×2, REDACTED_febdf887 — moved out of custom-alerts.tf so the latter could go canonical.
- The 3 legacy counter-based Velero rules were DELETED (documented-broken: `increase(velero_backup_partial_failure_total[1h])` resets on pod restart and measured 0 across a week of PartiallyFailed backups). Velero coverage = the 6 gauge-based rules in `velero-backup-alerts.tf` (canonical).

**Triage policy:** All non-info alerts trigger triage (no whitelist). Dedup by `alertname:namespace` prevents duplicate YT issues. Noisy alerts should be silenced in Alertmanager, not filtered in the receiver.

**YT custom fields set by k8s-triage.sh:** Hostname, Alert Rule, Severity, Namespace, Pod, Alert Source (`Prometheus`).

### Paging surface — what actually reaches the phone (ntfy-first since 2026-08-25)

**The phone channel is ntfy** (topic `alrt-tier1` on the Matrix-stack ntfy at nl-matrix01, real auth since infra !518); **Twilio SMS fires ONLY for the ULTRA-urgent allowlist** (`page = "sms"` label) + the bridge's own dead-men + a capped ntfy-down fail-over. Runbook: claude-gateway `docs/runbooks/paging-ntfy.md`.

1. **Alertmanager → paging bridge** (`page-tier1` receiver → `http://10.0.X.X:9106/alert` on nlclaude01; GR mirror `http://10.0.X.X:9106/alert`). The route still matches **`tier = 1` AND `severity = critical`** (`group_wait 10s`, `repeat 1h`, `continue = true` so alerts also reach Matrix/YT). Every match → ntfy urgent push (edge-triggered, one push per firing episode); **SMS additionally iff the rule carries `page = "sms"`**. Stock kube-prometheus rules carry no `tier` label → never page.
2. **Alertmanager `Watchdog` → `page-heartbeat`** (`/heartbeat`, repeat 2m) — feeds the bridge's per-site Prometheus dead-man (`PrometheusHeartbeatLost`: ntfy always, SMS only for the bridge's own site).
3. **Gatus → ntfy natively** (`gatus/main.tf`, `alerts = local.ntfy_enabled ? [...]`, provider `ntfy`, token via the `gatus-ntfy` Secret from `TF_VAR_gatus_ntfy_*` in Atlantis's env / OpenBao `ci/gatus-ntfy`). **Twilio + the dead GitLab-pipeline provider are REMOVED** from Gatus. NL-only; GR/NO `alerting = null` (deliberate).

**Current paging population:**

| Channel | Alerts |
|------|--------|
| ntfy only (`tier=1`+`critical`) — **8** | `REDACTED_06ec64ac`, `REDACTED_c39c23d4`, `REDACTED_e67edccb`, `REDACTED_578414e4`, `EdgeWafNotEnforcing`, `EdgeWafNotWired`, `EdgeCrowdSecDown`, `REDACTED_22590886` |
| ntfy + SMS (`page="sms"`) — **3** | `PVEPmxcfsWedged`, `REDACTED_57cdabcd` (both restored 2026-08-25), `IntersiteBGPPartition` (newly tiered — a total NL↔GR partition finally pages) |
| Gatus → ntfy — **4** | `NL Kubernetes API`, `FISHA file01`, `FISHA file02`, `Home Assistant` |
| Bridge-internal SMS | `PagingPushDown` (ntfy probe dead ×3), own-site `PrometheusHeartbeatLost`, fail-over (cap 3/h) |

**26 alerts stay non-paging** (marker `# tier = "1"  # not tier-1 by operator decision 2026-08-25 …`): `severity` stays `critical` → Matrix + YouTrack triage only. The operator explicitly declined restoring them (2026-08-25). To promote one to ntfy paging: uncomment its `tier = "1"`; to make it ULTRA add `page = "sms"`. `severity = "critical"` alone does **not** page; the `tier` label is the gate.

Bridge self-monitoring: `PagingBridgeStale` + `PagingPushDown` in `agentic-health-alerts.tf` (critical, deliberately **untiered** — a dead bridge can't page through itself; NL-scoped because nothing scrapes the GR bridge's textfile metrics yet).

⚠ **`REDACTED_880627c0` is defined in two files** (`agentic-health-alerts.tf` +
`scheduled-reboot-alerts.tf`) — change both or they drift. Alertmanager dedups by `alertname`,
so a live duplicate pages once, but it is a config smell worth collapsing.

To re-audit the paging surface: grep the custom rule files for `tier = "1"` co-located with
`severity = "critical"` (a header-comment mention does not count) and for `page     = "sms"`,
plus the `alerts = local.ntfy_enabled` blocks in `gatus/main.tf`.

## Known Issues

- **SeaweedFS filer store = shared CNPG Postgres since 2026-08-23/24 (IFRNLLEI01PRD-2605).** The per-filer leveldb2 topology (2 filers + async meta-aggregator) was the root enabler of the 2026 object-corruption class (-2090 signatures: duplicate chunks at offset 0, index blobs failing decrypt): two private stores reconciled asynchronously commit inconsistent chunk lists under stalled-PUT client retries, and leveldb has no crash story. At cutover the two GR filers held **148k vs 109k directories** for the same bucket tree — two different truths. Now both filers are stateless readers of `seaweedfs-filer-meta` (CNPG, ns seaweedfs, 2 instances async; `filer_store = "postgres2"` in tfvars; `namespaces/seaweedfs/filer-postgres.tf`). Barman for that DB goes **cross-site** (never into the S3 it serves — its restore must not depend on the filer being up): NL→gr-s3 `filer-meta-nl`, GR→nl-s3 `filer-meta-gr`, NO→nl-s3 `filer-meta-no`. The old leveldb2 PVCs (`data-filer-seaweedfs-filer-{0,1}`) were left in place as rollback artifacts and can be reclaimed once the stores have soaked. SeaweedFS is on **4.44** (chart 4.44.0 — the 4.29 per-path locks/ObjectTransaction and 4.41 conditional chunk-set UpdateEntry fixes address exactly the retry race).
  - **Cutover mechanics that bit:** `fs.meta.save -o FILE` does NOT truncate an existing file — a killed earlier dump left a longer file, the rerun overwrote in place, and 34 KB of stale tail made `fs.meta.load` die with `gzip: invalid header` mid-stream (busybox `gunzip -t` only validates the FIRST gzip member and said "valid"). Always `rm` the target first. Repair = extract the first gzip member (python `zlib.decompressobj(wbits=31)`, keep `len(data)-len(unused_data)` bytes). `fs.meta.load` needs the shell `lock`; `fs.meta.save` does not; pin the filer with `weed shell -filer=127.0.0.1:8888` or you dump the round-robin service. During the mixed-store rolling window the new-store filer bootstraps metadata from the old-store peer (4.18 join behaviour) — harmless under a write-fence.
  - **Identity edits in the canonical bao `s3-credentials` JSON reach the cluster only on ESO refresh (1h) — delete the `seaweedfs-s3-config` Secret (instant recreate) BEFORE rolling filers**, or they reload the stale config (bit notrf01 once: `InvalidAccessKeyId` after a roll). The filer default `concurrentUploadLimit` rejects single PUTs ≥64 MB with a connection reset; every real consumer multiparts, so only hand-seeding hits it.
- **S3 ingress: ModSecurity OFF + proxy buffering OFF on the `seaweedfs-s3` vhost (2026-08-23).** The barman restore drill failed with "error reading from response stream": the 2 GB base tar was cut at **exactly 512 MiB with a clean EOF** through nl-s3 while ranged reads at 1 GiB+ succeeded and pod-to-pod bypassing nginx streamed complete. Isolation: `enable-modsecurity: "false"` on that one ingress → complete in 43 s. **ModSecurity v3's body filter truncates large streamed responses even in DetectionOnly**, and its CRS web rules only flag noise on sigv4 machine traffic (PUT + octet-stream = "anomaly"). The WAF stays on for every other vhost. `proxy-buffering/request-buffering off`, `max-temp-file-size 0`, 1800 s timeouts keep nginx from spooling S3 bodies. Production DB backups were **not restorable through this gateway until this landed** — proven by the drill afterwards (users=43 exact, all DBs).
- **Velero is opt-IN since 2026-08-23** (`defaultVolumesToFsBackup: false` in `argocd-apps/velero/schedules.yaml`). Precious volumes carry `backup.velero.io/backup-volumes: <pod-spec VOLUME name>`: grafana `storage` (kps `podAnnotations`), AWX `my-awx-projects` (`web_annotations`), NL pihole `pihole-data`, and in the omoikane app repo bridge `bridge-state` ×2 + qdrant `storage`. AWX postgres has no annotation path in the operator CRD → nightly `pg_dump` CronJob to `s3://awx-pg-dumps` (`namespaces/awx/pg-dump.tf`). This removed the nightly full-cluster kopia storm (the provocation for the stall/retry chain), the notrf01 "node-agent absent on tainted CP nodes" 4-error floor, and the GR sidecar-emptyDir flap. **Roll node-agents whenever repos are wiped/re-initialized** — kopia's node-local cache vs hourly maintenance GC otherwise yields `BLOB not found` on cached content (the -2547 recurrence). `litellm` (notrf01) has NO coverage by any mechanism (no barman, no schedule, not annotated) — a deliberate operator ruling, not an oversight; do not read the quiet alert as coverage.
- **Read-path canary** (`namespaces/seaweedfs/read-canary.tf`, 6h): 1 MiB write/read/delete roundtrip + streams the 1 GiB `read-canary/sentinel-1g.bin` through the site consumer path (NL/GR public ingress; notrf01 cluster-local — `no-s3` has no DNS) verifying length + SHA256 against `sentinel-1g.sha`. Rules `SeaweedFSReadCanaryFailed` (critical) / `SeaweedFSReadCanaryStale` (warning, includes `absent()` so a never-run canary alerts). A readability test is not a correctness test — this is the correctness test.
- **grafana `initChownData` is disabled** (kps values): its `chown -R` runs as root with capabilities `[drop ALL, add CHOWN]` — no DAC_OVERRIDE — and cannot traverse grafana's own 0700 `png/csv/pdf` dirs on a lived-in volume; it crash-loops, helm `atomic` rolls back, and three notrf01 applies failed on it before the exact-spec reproduction found it. `fsGroup: 472` owns the volume anyway.
- **2026-08-24/25 addendum (IFRNLLEI01PRD-2605 continuation).** The estate-wide ext4 `emergency_ro` storm was **nl-nas01 memory starvation** (a 16GB nested-PVE VMM guest left DSM+iSCSI ~3GB; stalls past initiator timeouts → aborts → RO latches). Fixed by evacuating that VM's 7 LXC into the PVE cluster and shutting it down. **RO-latch cure runbook: cordon → delete pod → ≥6 min podless (kubelet must unstage the globalmount) → uncordon; a fast same-node bounce reuses the stale mount and does NOT clear the latch. After any RO storm, sweep EVERY PVC pod — CrashLoopBackOff pods pass a phase==Running filter but fail exec probes; treat un-probe-able pods as suspect.** Related wedge cures, all seen twice+: seaweedfs master raft goes leaderless on peer churn (bounce all three masters; alert `SeaweedFSMasterRaftLeaderless` now watches it); velero server/node-agent controllers go silent after S3 flaps (bounce them; `REDACTED_45e7a03a` watches); a CNPG cluster's failed Backup CR blocks its per-cluster backup queue (delete the failed CR). NL-only: `syno-nas-health` rules (swap-pressure + load — UCD memAvailReal is free-only and must never be thresholded) via the `snmp-syno` scrape lane.
- **SeaweedFS volume-SLOT exhaustion is silent and bucket-selective**: NL volume-1 hit its max-volumes cap (1028/1028) — writes to EXISTING collections kept working while any NEW collection's replicated assigns hung to timeout (≥4MB chunked PUTs first). `volume.deleteEmpty -quietFor=24h -force` reclaims; structural fix (raise `-max` / deep vacuum + a free-slots alert) tracked on 2605. Also: never create buckets via raw S3 PUT-bucket — it poisons the collection (repair: `collection.delete -force` + `s3.bucket.create`).
- **Velero offsite for the two SeaweedFS sites = the NL↔GR filer.sync**, which replicates `/buckets/velero` and `/buckets/velero-gr` bidirectionally (verified live 2026-08-24). Do not repoint the BSLs cross-site — the mirror-map substitution cascade fights it and the sync already moves the data off-site. Corollary (bit us once): when a peer site's filer store is reloaded from dumps that predate a velero wipe, the sync resurrects the wiped kopia tree on the other side — wipe BOTH sides after such a load.

- **kubeadm upgrade runbook (established 2026-08-16, first-ever minor upgrades, IFRNLLEI01PRD-2373):** one minor at a time; per cluster: fresh per-CP etcd snapshots (`etcdctl snapshot save` inside the etcd pod; verify with `etcdutl snapshot status` — etcd 3.6 moved `status` out of etcdctl), first-CP `kubeadm upgrade apply vX.Y.Z -y` on a healthy NON-leader (NL: ctrl03), others `kubeadm upgrade node`, workers last, drain each node for its kubelet bump. **Hard rules learned:** (1) `kubeadm upgrade node/apply` MUST succeed (RC=0) BEFORE touching kubelet — kubelet minors remove flags (1.35 removed `--pod-infra-container-image`) and only a successful kubeadm run regenerates `/var/lib/kubelet/kubeadm-flags.env`; a new kubelet against the old flags file crash-loops, and a crash-looping kubelet then deadlocks the retried upgrade (it can't roll static pods). (2) ctrl02 (LXC) always needs `--ignore-preflight-errors=SystemVerification`. (3) Pre-delete PDB-pinned single-replica pods (argocd trio+server, my-awx-*, metrics-server, prometheus-operator, kube-state-metrics, seaweedfs filer/master/volume) before drains. (4) A transient `Forbidden (User "kubernetes-admin")` can appear right after a CP's apiserver restarts (authorizer warmup) — retry, don't diagnose.
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
- **Velero backup wipe = TWO-part operation (2026-08-06, learned the hard way)** — after the nl-pve03 outage, all Velero backups were deliberately wiped (operator-approved) to clear SeaweedFS capacity exhaustion (95% → 34%).
  - **What actually freed the space was deleting the Velero CRs, not the bucket**: `kubectl delete deletebackuprequests -n velero --all` then `kubectl delete backups -n velero --all` — 3 STALLED DeleteBackupRequests were jamming the deletion queue; by the time `fs.rm /buckets/velero` ran there was nothing left to remove.
  - **Wiping the bucket alone breaks every per-namespace kopia repo**: the `BackupRepository` CRs still point at repo structures that no longer exist, and the next backup fails with N× `repository not initialized in the provided storage` (observed: `PartiallyFailed`, 60 errors on a fresh run). **Fix: `kubectl delete backuprepositories -n velero --all`** — Velero recreates and initializes them unaided (observed: 7 CRs back, all `Ready`, error count 0). Rule: **object storage AND the BackupRepository CRs, always both.**
  - Aborted-run debris persists: `Failed` PodVolumeBackup objects keep the aborted run's name prefix (`post-wipe-verify-*`) — **check object name prefixes before calling a failure current**; they read like a live regression in any status sweep.
  - First backup against a freshly wiped repo is **very slow** (nothing dedupes) and its full-cluster I/O caused a transient LibreNMS SNMP-unreachable burst across ~11 hosts (17:38 UTC) — expect noise, don't triage it as host failures.
  - **Pod-reseat pattern (same day):** after a multi-node outage k8s never rebalances — `seaweedfs-master-1` sat Pending 3h27m on worker-memory (not disk). To reseat a small Pending pod, find a stateless multi-replica pod on the blocked node (`--field-selector spec.nodeName=<node>`, sum memory requests) and delete one replica; the scheduler redistributes it (~20 s to scheduled).
- **SeaweedFS S3 PUT tail spikes (IFRNLLEI01PRD-2375, found 2026-08-16, OPEN):** PUT p99 is 93ms at baseline but spikes to **1.7–6.5s several times daily** — two distinct sources observed: disk-level (volumeServer write p99 2.8s; volumes are syno01 iSCSI) and filer/S3-layer stalls with fast disks beneath. Public symptom: `cv.omoikane.coach` flapped off the edge (its health probe has a 1500ms budget — see the 2052 coupling above); edge mitigated with HAProxy `fall 4` on CH+NO, so any cv flap that still gets through means a stall >8s. ⚠ **Scope S3 latency queries by `type="PUT"`** — the aggregate p99 reads ~3.2s permanently because the accepted omoikane-tempo poller (IFRNLLEI01PRD-2090) retries GETs against volumes 657–662 that no longer exist (deleted-collection debris, likely from the 2026-08-06 wipe below); that GET tail pollutes the global number.
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
