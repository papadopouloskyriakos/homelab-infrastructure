# Nuclear Lighters Infrastructure

[![License: WTFPL](https://img.shields.io/badge/License-WTFPL-brightgreen.svg)](http://www.wtfpl.net/about/)

**Hybrid GitOps Infrastructure as Code for the Nuclear Lighters homelab.**

Single source of truth for the entire Nuclear Lighters infrastructure across 4 countries (NL, GR, CH, NO) — managing Kubernetes clusters, Cisco network devices, Proxmox VMs/containers, 80+ Docker services, and two HA clusters (Nextcloud 9-layer, Home Assistant Pacemaker) through GitLab CI/CD pipelines.

---

## Overview

| Component | Technology | Management | Count |
|-----------|------------|------------|-------|
| Kubernetes | K8s v1.34.2, Cilium v1.18.4 (eBPF) | Atlantis + Argo CD | 2 clusters, 14 nodes |
| Multi-Site | Cilium ClusterMesh + IPsec mesh | OpenTofu | NL primary + GR DR |
| Network | Cisco IOS/IOS-XE/ASA + FRR BGP | GitLab CI/CD (Netmiko) | 11 devices, AS214304 |
| Virtualization | Proxmox VE | GitLab CI/CD | 5 nodes, 116 LXC, 22 QEMU |
| Docker Services | Docker Compose | GitLab CI/CD (rsync) | 51 hosts, 80+ services |
| HA Clusters | Nextcloud (DRBD+OCFS2+NFS), Home Assistant (Pacemaker) | Native configs | 21 + 3 hosts |
| Monitoring | REDACTED_d8074874 + Thanos + LibreNMS | Helm + LXC | 163 alert rules, 137 monitored devices |
| Secrets | OpenBao (HA, 3 nodes) + External Secrets Operator | OpenTofu | JWT auth for CI, K8s sync |
| Storage | NFS + Synology iSCSI CSI + SeaweedFS S3 | OpenTofu | RWX + RWO + S3 |
| Logging | syslog-ng → Promtail → Loki → Grafana | K8s + LXC | Centralized log aggregation |
| TLS | cert-manager + Let's Encrypt (DNS-01 via Cloudflare) | OpenTofu | Wildcard certificates |
| Backup | Velero + SeaweedFS S3 | Argo CD | Daily 2AM + weekly Sunday 3AM |

---

## Multi-Site Architecture

```
                              ┌─────────────────────────────────────────────────────────────┐
                              │                      INTERNET                               │
                              │                                                             │
                              │    AS34927 (iFog)              AS56655 (Gigahost)          │
                              │         │                            │                      │
                              │         │ eBGP                       │ eBGP                 │
                              │         ▼                            ▼                      │
                              │    ┌─────────┐                  ┌─────────┐                │
                              │    │ CH Edge │                  │ NO Edge │                │
                              │    │ Zürich  │◄────IPsec────────►│ Oslo    │                │
                              │    └────┬────┘                  └────┬────┘                │
                              └─────────┼────────────────────────────┼──────────────────────┘
                                        │                            │
              ┌─────────────────────────┼────────────────────────────┼─────────────────────────┐
              │                         │        IPsec Mesh          │                         │
              │         ┌───────────────┴────────────────────────────┴───────────────┐        │
              │         ▼                                                            ▼        │
              │    ┌─────────────────────────────────┐    ┌─────────────────────────────────┐ │
              │    │       NETHERLANDS (Primary)     │    │          GREECE (DR)             │ │
              │    │                                 │    │                                 │ │
              │    │  nlfrr01 ◄──iBGP──► nlfrr02  grfrr01 ◄──iBGP──► grfrr02 │
              │    │         │                       │    │         │                       │ │
              │    │    nlfw01 (ASA 5508-X)     │    │    grfw01 (ASA 5508-X)     │ │
              │    │         │ eBGP (AS65000↔65001)  │    │         │ eBGP (AS65000↔65001)  │ │
              │    │    ┌────▼────────────────┐      │    │    ┌────▼────────────────┐      │ │
              │    │    │ K8s: nlcl01k8s │      │    │    │ K8s: grcl01k8s │      │ │
              │    │    │ 7 nodes (3CP + 4W)  │◄═ClusterMesh═►│ 7 nodes (3CP + 4W)  │      │ │
              │    │    └────────────────────┘      │    │    └────────────────────┘      │ │
              │    │                                 │    │                                 │ │
              │    │  Proxmox: pve01/02/03           │    │  Proxmox: pve01/02              │ │
              │    │  Storage: Synology DS1621+      │    │  Storage: Local ZFS             │ │
              │    │  LXC: 116, QEMU: 22             │    │  LXC: 10+, QEMU: 10+           │ │
              │    └─────────────────────────────────┘    └─────────────────────────────────┘ │
              └───────────────────────────────────────────────────────────────────────────────┘
```

### Site Details

| Site | Location | Role | Infrastructure | K8s Nodes |
|------|----------|------|----------------|-----------|
| **NL** | Netherlands | Primary | 3x Proxmox, 2x Synology NAS, Cisco ASA/Switch/Router/LTE/4xAP | 7 (3 CP + 4 W) |
| **GR** | Greece | Disaster Recovery | 2x Proxmox, Local ZFS, Cisco ASA | 7 (3 CP + 4 W) |
| **CH** | Zürich, Switzerland | Edge (iFog VPS) | FRR BGP router | - |
| **NO** | Oslo, Norway | Edge (Gigahost VPS) | FRR BGP router | - |

### Proxmox Hardware

| Node | Hardware | CPU | RAM | Storage | VMs |
|------|----------|-----|-----|---------|-----|
| nl-pve01 | Venus Series Mini PC | i9-12900H (20T) | 96 GB | NVMe ZFS | 75 LXC, 8 QEMU |
| nl-pve02 | Synology DS1621+ VM | Ryzen V1500B (8C) | 16 GB | NAS iSCSI | 7 LXC |
| nl-pve03 | Dell Precision 3680 | i9-14900K (32T) | 128 GB | NVMe ZFS | 34 LXC, 14 QEMU |
| gr-pve01 | Venus Series Mini PC | i9-12900H (20T) | 96 GB | NVMe ZFS | — |
| gr-pve02 | Dell PowerEdge T110 II | Xeon E3-1270 V2 (8T) | 32 GB | SSD ZFS | — |

---

## Repository Structure

```
production/
├── k8s/                          # Kubernetes (OpenTofu + Atlantis)
│   ├── main.tf                   #   Root orchestrator — calls all modules
│   ├── variables.tf              #   Input variables (connection, sizing, feature flags)
│   ├── providers.tf              #   Kubernetes + Helm providers
│   ├── terraform.tfvars          #   Variable overrides
│   ├── _core/                    #   Platform infrastructure modules
│   │   ├── cilium/               #     CNI, BGP, ClusterMesh, SPIRE mTLS, Hubble
│   │   ├── tetragon/             #     eBPF security monitoring (5 TracingPolicies)
│   │   ├── ingress-nginx/        #     Hardened ingress (ModSecurity WAF, HSTS)
│   │   ├── cert-manager/         #     Let's Encrypt DNS-01 via Cloudflare
│   │   ├── external-secrets/     #     ClusterSecretStore "openbao"
│   │   ├── nfs-provisioner/      #     StorageClass "nfs-client"
│   │   ├── nl-nas01-csi/    #     Synology iSCSI CSI (retain + delete classes)
│   │   ├── gitlab-agent/         #     GitLab K8s agent (2 replicas)
│   │   ├── REDACTED_d97cef76/ #     Dashboard (vendored chart)
│   │   └── pod-disruption-budgets/ #   CoreDNS + Metrics Server PDBs
│   ├── namespaces/               #   Application namespace modules
│   │   ├── monitoring/           #     REDACTED_d8074874, Thanos, Goldpinger, BGPalerter, SNMP
│   │   ├── logging/              #     Loki (single-binary, SeaweedFS S3) + Promtail (syslog)
│   │   ├── seaweedfs/            #     S3 storage, filer.sync for NL↔GR replication
│   │   ├── argocd/               #     Argo CD (2 replica server + repo-server)
│   │   ├── awx/                  #     AWX Operator (Postgres on iSCSI, projects on NFS)
│   │   ├── gatus/                #     Status page with BGP/IPsec/network health monitoring
│   │   └── well-known/           #     RFC 8615 security.txt, multi-domain
│   ├── argocd-apps/              #   Argo CD application manifests (YAML)
│   │   ├── bentopdf/             #     PDF converter
│   │   ├── echo-server/          #     HTTP echo at echo.example.net
│   │   ├── pihole/               #     DNS ad-blocker with Cilium network policy
│   │   └── velero/               #     Backup (daily 2AM + weekly Sunday 3AM)
│   └── cluster-snapshots/        #   Auto-generated daily (03:00 UTC)
│       ├── latest.md             #     Current cluster state
│       ├── cluster-context-lite.md #   3K token summary for quick troubleshooting
│       ├── cluster-context-full.md #   10K token deep analysis
│       └── history/              #     130+ daily snapshots since 2025-11-27
│
├── network/                      # Cisco Network Automation
│   ├── configs/                  #   Raw running-config files (no extension)
│   │   ├── Router/               #     nlrtr01, nl-lte01
│   │   ├── Switch/               #     nlsw01
│   │   ├── Firewall/             #     nlfw01
│   │   └── Access-Point/         #     nlap01-04
│   ├── scripts/                  #   Python automation (11 scripts)
│   │   ├── detect_drift.py       #     Drift detection (device as source of truth)
│   │   ├── auto_sync_drift.py    #     Sync drifted configs to git
│   │   ├── pre_deploy_drift_gate.py #  Block deploy on true drift
│   │   ├── validate_syntax.py    #     Syntax validation (hostname, no dangerous patterns)
│   │   ├── generate_diff.py      #     Hierarchical diff generator (JSON)
│   │   ├── generate_diff_ciscoconfparse.py # Alt diff generator
│   │   ├── direct_deploy.py      #     Deploy diffs via Netmiko SSH
│   │   ├── post_validate.py      #     Post-deploy health check
│   │   ├── sync_from_device.py   #     Pull device config → create MR
│   │   ├── filter_dynamic_content.py # Strip timestamps/checksums (library)
│   │   └── rebase-after-drift.sh #     Rebase branch after drift MR merge
│   └── ansible/                  #   deploy.yml playbook (Netmiko backend)
│
├── pve/                          # Proxmox VM/LXC Configs
│   ├── nl-pve01/
│   │   ├── lxc/                  #     75 container configs (VMID.conf)
│   │   └── qemu/                 #     8 VM configs (VMID.conf)
│   ├── nl-pve02/
│   │   └── lxc/                  #     7 container configs
│   ├── nl-pve03/
│   │   ├── lxc/                  #     34 container configs
│   │   └── qemu/                 #     14 VM configs
│   ├── scripts/                  #   Drift detection + config normalization
│   └── templates/                #   Empty (reserved)
│
├── docker/                       # Docker Compose Services (51 hosts, 80+ services)
│   ├── nlgpu01/             #   21 GPU services (see Docker Services section)
│   ├── nl-matrix01/matrix/   #   Matrix homeserver (see Matrix section)
│   ├── nlpinchflat01/       #   YouTube archiver (see Pinchflat section)
│   └── ...                       #   50+ more hosts
│
├── native/                       # Non-Docker HA Cluster Configs (read-only snapshots)
│   ├── ncha/                     #   Nextcloud HA: 9-layer stack, 21 hosts
│   │   ├── nlnc01/          #     Apache, PHP, config.php, fstab, crontabs
│   │   └── nlnc02/          #     Identical config (shared OCFS2 storage)
│   └── haha/                     #   Home Assistant HA: 3-node Pacemaker cluster
│       ├── nlcl01iot01/     #     Pacemaker, Corosync, ESPHome, Z2M, configs
│       └── nlcl01iot02/     #     Same (active/standby pair, shared NFS)
│
├── ci/                           # Modular GitLab CI Pipeline Includes (8 files)
│   ├── cisco.yml                 #   Cisco: drift → validate → deploy → verify
│   ├── docker.yml                #   Docker: rsync + compose pull/up, Matrix notifications
│   ├── k8s.yml                   #   K8s: tofu fmt/validate + Argo CD bootstrap
│   ├── lxc.yml                   #   Proxmox LXC: backup → stop → replace → start
│   ├── qemu.yml                  #   Proxmox QEMU: same as LXC for VMs
│   ├── openbao.yml               #   Shared OpenBao JWT auth templates
│   ├── images.yml                #   CI runner image builds (6 images, manual trigger)
│   └── github-sync.yml           #   Sanitized public mirror to GitHub
│
├── images/                       # CI Runner Image Build Contexts (6 images)
│   ├── cisco-ee/                 #   Python + Netmiko + Ansible Cisco collections (~1.1GB)
│   ├── docker-runner/            #   Alpine + SSH + rsync (~90MB)
│   ├── pve-runner/               #   Alpine + SSH + diff (~28MB)
│   ├── k8s-runner/               #   Alpine + OpenTofu (pre-cached providers) + kubectl + helm (~347MB)
│   ├── hugo-runner/              #   Debian + Hugo extended + MinIO client (~309MB, versioned tags)
│   └── github-sync-runner/       #   Debian + git-filter-repo + gitleaks + trufflehog (~444MB)
│
├── ansible/playbooks/            # AWX-managed playbooks (synced from common repo)
│   ├── cert-manager/             #   TLS cert sync to NPM
│   ├── docker/                   #   Docker project collection
│   ├── pve/                      #   Proxmox automation
│   ├── snmpd/                    #   SNMP daemon management
│   ├── ssh/                      #   SSH key distribution
│   └── updates/                  #   System updates
│
├── .gitlab-ci.yml                # Main pipeline: 5 stages, 8 includes
├── atlantis.yaml                 # Atlantis project config (project: k8s)
└── renovate.json                 # Automated dependency updates
```

**Note:** `native/` configs are **read-only snapshots** — there is no CI/CD pipeline for native services. To update: SSH to the VM, make changes, copy the updated config back, commit with `chore(native): sync <service> config from <host>`. Both NCHA and HAHA share the DRBD+OCFS2+NFS storage cluster (file01/file02/filearb01).

---

## Deployment Paths

Every directory has its own CI/CD pipeline. Push to main triggers automatic deployment (except K8s, which requires MRs + Atlantis).

| Directory | Pipeline | Deploy Method | Trigger |
|-----------|----------|---------------|---------|
| `k8s/**/*.tf` | `ci/k8s.yml` + Atlantis | `tofu plan/apply` via MR | MR + `atlantis apply` comment |
| `k8s/argocd-apps/` | `ci/k8s.yml` | `kubectl apply` + Argo CD sync | Push to main |
| `network/configs/` | `ci/cisco.yml` | Hierarchical diffs via Netmiko SSH | Push to main |
| `pve/**/lxc/*.conf` | `ci/lxc.yml` | SCP + `pct` commands (causes downtime) | Push to main |
| `pve/**/qemu/*.conf` | `ci/qemu.yml` | SCP + `qm` commands (causes downtime) | Push to main |
| `docker/<host>/<svc>/` | `ci/docker.yml` | rsync + `docker compose up -d` | Push to main |

### Key Design Decisions

- **K8s: strict GitOps** — all changes via OpenTofu + Atlantis MRs. No `kubectl apply`, no `helm install` outside of OpenTofu. Read-only kubectl is allowed for debugging.
- **Network: device as source of truth** — drift detection syncs device → git (not the other way). Deployments use hierarchical diffs, never full config replace.
- **PVE: config changes cause downtime** — pipeline stops the container/VM, replaces the config, and restarts. Backups created automatically before deployment in `/var/lib/vz/backup/config-backups/`. Auto-rollback on failure.
- **Docker: rsync-based** — files deployed to `/srv/<service>/` on each host, then `docker compose pull && up -d`. Dockerfile changes trigger `docker compose build --no-cache` instead.

---

## CI/CD Pipeline Details

### Pipeline Stages

```
drift-detection → validate → pre-deploy → deploy → verify
```

### Trigger Rules

| Pipeline | Push to main | MR | Scheduled | Bot commits skipped |
|----------|-------------|-----|-----------|---------------------|
| Docker | `docker/**/*` changes | Validation only | No | `GitLab CI Auto-Sync` |
| Cisco | `network/configs/**/*` changes | Never deploys | Drift detection only | `NL Oxidized Bot`, `GitLab CI Auto-Sync` |
| K8s | `k8s/**/*.tf` changes | Validation only | No | No |
| Argo CD | `k8s/argocd-apps/**/*` changes | Validation only | No | No |
| LXC | `pve/**/lxc/*.conf` changes | No | No | `GitLab CI Auto-Sync` |
| QEMU | `pve/**/qemu/*.conf` changes | No | No | `GitLab CI Auto-Sync` |
| GitHub Sync | Every push to main | Dry-run (manual) | Never | — |
| Images | Never (manual only) | Never | Never | — |

### OpenBao Authentication Templates (`openbao.yml`)

Three shared templates — extend these, don't duplicate the auth logic:

| Template | Provides |
|----------|----------|
| `.openbao-auth` | `BAO_TOKEN` + `fetch_secret()` helper |
| `.openbao-cisco` | Above + `CISCO_USER`, `CISCO_PASSWORD`, `CISCO_ENABLE_SECRET` |
| `.openbao-cisco-with-git` | Above + `GITLAB_PUSH_TOKEN` + git configured for push |

All use JWT auth (`VAULT_ID_TOKEN` with aud `https://gitlab.example.net`), role `gitlab-ci`, CA cert for TLS.

### Pipeline-Specific Details

**Docker (`docker.yml`):**
- Discovers changed projects by walking up from changed files to find `docker-compose.yml` or `Dockerfile`
- Verification: waits 30s, checks `docker compose ps` for exited/restarting/dead/unhealthy containers
- Matrix webhook notifications on deploy start, success, and failure (3 retry attempts)
- `.rsyncignore` in a service dir excludes files from deployment sync

**Cisco (`cisco.yml`):**
- `detect_drift.py` runs on schedule — device is source of truth
- `pre_deploy_drift_gate.py` blocks deployment if device has unreported manual changes, creates MR
- `generate_diff.py` fetches LIVE config from device, diffs against desired, outputs hierarchical JSON diff blocks
- `direct_deploy.py` applies diffs via Netmiko with pre/post backups and `write memory`
- Deployment lock at `/tmp/ansible_deployment_lock` (process-scoped)
- Artifacts: `drift_report.txt`, `diffs/*.json`, deploy logs (7-day retention)

**K8s (`k8s.yml`):**
- `validate_k8s_opentofu`: `tofu fmt -check` + `tofu validate` with temporary local backend override
- `validate_argocd_manifests`: `kubectl apply --dry-run=client` on all YAML except `application.yaml`
- `bootstrap_argocd_apps`: applies `application.yaml` files on push to main (idempotent)
- `verify_k8s_infrastructure`: post-merge health check — nodes, pods, PVCs, services
- Atlantis workflow: init → validate → plan. Project name: `k8s`. State backend: GitLab Terraform HTTP.

**LXC/QEMU (`lxc.yml`, `qemu.yml`):**
- Nearly identical pipelines, differ in paths (`/etc/pve/lxc/` vs `/etc/pve/qemu-server/`) and commands (`pct` vs `qm`)
- Deploy flow: validate → backup → stop → upload via staging dir → verify with `diff -q` → start → cleanup
- Auto-rollback: on config verification or start failure, restores backup and restarts

### CI Runner Images

| Image | Base | Tag | Size | Purpose |
|-------|------|-----|------|---------|
| `cisco-ee` | python:3.11-slim | `latest` | ~1.1GB | Netmiko, ciscoconfparse, Ansible cisco.ios/asa collections |
| `docker-runner` | alpine:3.20 | `latest` | ~90MB | SSH, rsync, Python + PyYAML for Docker deployments |
| `pve-runner` | alpine:3.20 | `latest` | ~28MB | SSH, diff, bash for Proxmox config management |
| `k8s-runner` | alpine:3.20 | `latest` | ~347MB | OpenTofu (pre-cached providers), kubectl, helm |
| `hugo-runner` | debian:bookworm-slim | versioned (e.g. `1.5`) | ~309MB | Hugo extended, MinIO client, Docker buildx, OpenBao CA |
| `github-sync-runner` | debian:bookworm-slim | `latest` | ~444MB | git-filter-repo, gitleaks, trufflehog, detect-secrets, ripgrep, yq |

Build contexts live in `images/<name>/`. Built via `ci/images.yml` (manual trigger on changes). Registry: `registry.example.net/infrastructure/nl/production/<name>:<tag>`.

---

## Kubernetes Infrastructure

### Cluster: nlcl01k8s (Primary)

- **API**: api-k8s.example.net:6443
- **Nodes**: 3 control-plane + 4 workers, all Ubuntu 24.04
  - ctrl01 (pve01): 4 CPU, 8GB RAM
  - ctrl02 (pve02): 4 CPU, 4GB RAM
  - ctrl03 (pve03): 4 CPU, 8GB RAM
  - worker01-04: 4-8 CPU, 8GB RAM each. IPs 10.0.X.X-23
- **CNI**: Cilium v1.18.4 (eBPF, REDACTED_fd61d0fe, VXLAN tunneling, MTU 1350)
- **Pod CIDR**: 10.0.0.0/16 (NL), 10.1.0.0/16 (GR) — must not overlap for ClusterMesh
- **ClusterMesh**: Connected to GR cluster grcl01k8s at 10.0.X.X:2379, mTLS via ExternalSecret from OpenBao

### Cluster: grcl01k8s (DR)

- **API**: gr-api-k8s.example.net:6443
- **Nodes**: 3 control-plane (2 CPU, 4GB each) + 4 workers (4 CPU, 8-12GB)

### BGP & Networking

- **Cilium BGP**: local ASN 65001 peers with ASA firewall at 10.0.X.X (ASN 65000)
- **BGP timers**: hold 90s, keepalive 30s
- **LB-IPAM pool**: 10.0.X.X–10.0.X.X
- **Current LB allocations**: .64 (ingress-nginx), .65 (hubble-relay), .66 (pihole-dns-tcp), .67 (pihole-dns-udp), .68 (promtail-syslog), .69 (clustermesh-api)
- **Ingress real-IP trusted from**: CH edge (198.51.100.X/32), NO edge (198.51.100.X/32), internal (10.255.2-3.0/24)

### Storage Classes

| Class | Backend | Use Case |
|-------|---------|----------|
| `nfs-client` | Synology DS1621+ NFS → 10.0.X.X:/volume1/k8s | Shared/low-IOPS (Grafana, Pi-hole config, AWX projects, SPIRE data) |
| `REDACTED_b280aec5` | Synology iSCSI | Databases, metrics, stateful (Prometheus, Loki, Postgres, Thanos, SeaweedFS) |
| `REDACTED_4f3da73d` | Synology iSCSI | Ephemeral stateful (Alertmanager, Gatus) |

### Platform Components

| Category | Component | Version | Description |
|----------|-----------|---------|-------------|
| CNI | Cilium | v1.18.4 | eBPF networking, kube-proxy replacement, BGP, ClusterMesh |
| Security | Tetragon | — | eBPF monitoring (5 TracingPolicies: process exec, sensitive file access, privilege escalation, kubectl exec, network connections). All observe-only. |
| Security | ModSecurity WAF | — | DetectionOnly mode with OWASP CRS on ingress-nginx |
| Security | SPIRE mTLS | — | Cilium mutual TLS for pod-to-pod REDACTED_6fa691d2 |
| Ingress | NGINX Ingress | v1.14.1 | Hardened (HSTS, security headers, rate limiting) |
| Storage | Synology CSI | v1.1.4 | iSCSI block storage (RWO), retain + delete classes |
| Storage | NFS Provisioner | — | NFS shares from Synology DS1621+ (RWX) |
| Storage | SeaweedFS | v4.01 | S3-compatible, filer.sync for NL↔GR active-active replication |
| Monitoring | REDACTED_d8074874 | v79.10.0 | Prometheus (2 replicas, 200Gi each, 1095-day retention, site label `nl`) |
| Monitoring | Thanos | — | Query (2 replicas) + Store (2 replicas, SeaweedFS S3) + Compactor. GR store via ClusterMesh. |
| Monitoring | Goldpinger | — | DaemonSet for cross-node connectivity/latency testing |
| Monitoring | BGPalerter | — | Monitors AS214304 prefix for hijacks, route leaks, RPKI invalidity |
| Monitoring | SNMP Exporter | — | Polls Cisco ASA for BGP + IPsec metrics |
| Logging | Grafana Loki | v3.5.7 | Single-binary, 100Gi iSCSI, 30-day retention, SeaweedFS S3 for chunks |
| Logging | Promtail | — | Syslog receiver on LB .68:514 — all Docker containers send logs here |
| Secrets | External Secrets | v1.1.1 | ClusterSecretStore "openbao", 1h refresh, Kubernetes auth |
| TLS | cert-manager | v1.17.1 | Let's Encrypt wildcard certs, DNS-01 via Cloudflare. Pushes wildcard cert to OpenBao via PushSecret for GR cluster. |
| GitOps | Argo CD | — | 4 apps (bentopdf, pihole, velero, echo-server). Chart 7.8.28, Matrix webhook → `#alerts`. Auto-sync with prune + selfHeal. |
| Backup | Velero | — | Daily 2AM + weekly Sunday 3AM, SeaweedFS S3 backend |
| DNS | Pi-hole | — | DNS ad-blocking with Cilium network policy |
| Automation | AWX | — | Ansible (cert sync, Docker inventory, system updates). Postgres on iSCSI, projects on NFS. |
| Dashboard | REDACTED_d97cef76 | — | Vendored chart (upstream archived) |

### Secrets

- All K8s secrets come from OpenBao via ExternalSecret resources (1h refresh)
- ClusterSecretStore name: `openbao`
- OpenBao paths: `secret/k8s/<namespace>/<secret-name>` or `secret/k8s/shared/` for cross-namespace
- cert-manager pushes the wildcard cert to OpenBao via PushSecret for GR cluster consumption

### Drift Detection

Scheduled CI job `detect_k8s_drift` runs `tofu plan -detailed-exitcode` on main. Uses OpenBao JWT auth for secrets. Exit 2 = drift warning.

### Alert Pipeline

```
Prometheus (163 rules: 150 REDACTED_d8074874 + 13 custom)
    │
    ▼ Alertmanager webhook
n8n Prometheus Alert Receiver (24 nodes)
    │ dedup by alertname:namespace, dual-store persistence
    │ filters: Watchdog, InfoInhibitor, info severity
    ▼
Matrix #infra-nl-prod notification
    │
    ▼
OpenClaw k8s-triage.sh (L1/L2: creates YT issue with Namespace/Pod/Alert Source fields,
    │                     kubectl investigation, posts findings as YT comment)
    │ critical alerts auto-escalated
    ▼
Claude Code (L3: reads YT comments, plans fix, waits for human approval, executes)
```

**Custom alert rules** (13, in `k8s/namespaces/monitoring/custom-alerts.tf`):
ContainerOOMKilled, REDACTED_879bd353, REDACTED_02123891, REDACTED_a8a7eee8, REDACTED_67797f17, CiliumAgentNotReady, REDACTED_b94e0389, REDACTED_e52ce3d8, NFSMountStale, NFSMountHighLatency, ArgocdAppDegraded, ArgocdAppOutOfSync, HighPodRestartRate.

**Triage policy:** All non-info alerts trigger triage (no whitelist). Dedup by `alertname:namespace` prevents duplicate YT issues. Noisy alerts should be silenced at Alertmanager level, not filtered in the receiver.

### Known Issues

- **kube-apiserver on ctrl01**: Intermittent HTTP 500 probe failures, 370+ restarts — present for entire cluster lifetime, does not impact stability
- **cilium-operator**: 90+ restarts accumulated — not a recent regression
- **SeaweedFS filer**: Multipath/iSCSI conflict fixed via Synology multipath blacklist on all 7 K8s nodes

---

## BGP Architecture

AS214304 (public ASN, RIPE NCC assigned December 2025) with a three-tier design:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  EXTERNAL (eBGP) - AS214304                                                │
│                                                                             │
│    Internet ◄──► ch-edge (Zürich)  ◄──► AS34927 (iFog GmbH)              │
│    Internet ◄──► no-edge (Oslo)    ◄──► AS56655 (Gigahost AS)            │
│    Announces: 2a0c:9a40:8e20::/48                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│  INTERNAL (iBGP) - AS65000                                                 │
│                                                                             │
│    Full mesh between 6 FRR routers via IPsec tunnels:                      │
│    ch-edge ◄──► no-edge ◄──► nlfrr01 ◄──► nlfrr02              │
│                                nlfw01       grfrr01 ◄──► grfrr02 │
│                                                   grfw01               │
│    Route Reflectors: nlfrr01/02, grfrr01/02                      │
│    Clients: ch-edge, no-edge, NL-ASA, GR-ASA                              │
├─────────────────────────────────────────────────────────────────────────────┤
│  KUBERNETES (eBGP) - AS65001 per site                                      │
│                                                                             │
│    NL: ASA (AS65000) ◄──► Cilium nodes (AS65001)                          │
│    GR: ASA (AS65000) ◄──► Cilium nodes (AS65001)                          │
│    Advertises: Pod CIDRs, LoadBalancer IPs (10.0.X.X-126)            │
│    Receives: Default route, internal networks                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### IPv6 Allocation

```
2a0c:9a40:8e20::/48
├── :8e20::/52  → NL Site (4,096 /64s)
│   ├── :8e20::/56  → NL Infrastructure
│   └── :8e21::/56  → NL Kubernetes Pods
├── :8e30::/52  → GR Site
├── :8e40::/52  → CH Edge
├── :8e50::/52  → NO Edge
└── :8e60::/52  → Reserved
```

### ASN Summary

| ASN | Scope | Purpose | Nodes |
|-----|-------|---------|-------|
| AS214304 | Public | Internet peering, IPv6 announcements | ch-edge, no-edge |
| AS65000 | Private | Internal backbone iBGP mesh | All FRR routers, ASAs |
| AS65001 | Private | Kubernetes BGP (per site, isolated) | Cilium nodes |

---

## Network Devices & Topology

### Device Inventory

| Device | Model | OS | IP | Role |
|--------|-------|----|----|------|
| nlfw01 | ASA 5508-X | ASA 9.16(4) | 10.0.X.X | Core firewall, NAT, VPN, BGP peer to K8s |
| nlsw01 | Catalyst 3850-12X48U | IOS-XE 16.12 | 10.0.X.X | Core L2 switch, 7 port-channels, 13+ VLANs |
| nlrtr01 | ISR 4321 | IOS 17.9 | 10.0.X.X | Primary router |
| nl-lte01 | C819G-LTE-MNA | IOS 15.6 | 10.0.X.X | LTE failover gateway |
| nlap01-04 | AIR-CAP3702I-E | IOS 15.3 | 10.0.X.X-96 | Wireless APs (8 SSIDs each) |

### WAN Connections

| Provider | Interface | Type |
|----------|-----------|------|
| XS4ALL | ASA Port-channel1.2 (VLAN 2) | PPPoE |
| Freedom Internet | ASA Port-channel1.6 (VLAN 6) | PPPoE, public IPs 45.138.52-55.x |
| LTE Failover | Cellular0 on nl-lte01 | NAT to 10.0.X.X/30 |

### VLANs

| VLAN | Name | Subnet | Security Level | Purpose |
|------|------|--------|----------------|---------|
| 2 | outside_xs4all | PPPoE | 0 | WAN uplink |
| 3 | outside_lte | 10.0.X.X/30 | 0 | LTE failover |
| 5 | inside_iot | 10.0.X.X/26 | 30 | IoT devices |
| 6 | outside_freedom | PPPoE | 0 | WAN uplink |
| 7-9 | rooms B/C/D | 192.168.17x.x | 40 | Guest rooms |
| 10 | inside_mgmt | 10.0.X.X/24 | 100 | Management (trusted) |
| 12 | cctv | 10.0.X.X/28 | — | CCTV cameras |
| 13 | guest | — | — | Guest WiFi |
| 14 | dmz_vpn01 | — | 0 | VPN DMZ |
| 85 | inside_k8s | 10.0.X.X/24 | 100 | Kubernetes nodes |
| 87-88 | corosync/nfs | — | 100 | Cluster comms + NFS storage |

### Switch Port-Channels

| Po | Speed | Members | Destination |
|----|-------|---------|-------------|
| Po1 | 4 Gbps | 4x Gi | ASA firewall (trunk) |
| Po2 | 2 Gbps | 2x Gi | Synology NAS |
| Po3 | 20 Gbps | 2x 10G | PVE host (trunk) |
| Po5 | 4 Gbps | 4x Gi | Synology NAS |
| Po6 | 20 Gbps | 2x 10G | Synology NAS |
| Po7 | 20 Gbps | 2x 10G | MINISFORUM host (trunk) |

### Wireless (8 SSIDs per AP)

Each AP serves 8 SSIDs mapped to VLANs: IoT (5), Guest (13), CCTV (12), Mgmt (10), Room A (11), Room B (7), Room C (8), Room D (9). All WPA/AES-CCM.

### Network Automation Scripts

| Script | Purpose | Args |
|--------|---------|------|
| `detect_drift.py` | Check all/one device for drift | `[device_type] [device_name]` |
| `auto_sync_drift.py` | Sync drifted configs to git | `[device_type] [device_name]` |
| `pre_deploy_drift_gate.py` | Block deploy on true drift | `<device_type> <device_name>` |
| `validate_syntax.py` | Syntax validation | `<config_file>` |
| `generate_diff.py` | Create hierarchical diff JSON | `<device_type> <device_name> <config_file>` |
| `direct_deploy.py` | Deploy diff to device | `<device_type> <device_name> <diff_json>` |
| `post_validate.py` | Post-deploy health check | `<device_type> <device_name>` |
| `sync_from_device.py` | Pull device config → create MR | `<device_type> <device_name>` |
| `filter_dynamic_content.py` | Strip timestamps/checksums (library) | Imported by other scripts |

All Python scripts use `CISCO_USER`, `CISCO_PASSWORD`, `CISCO_ENABLE_SECRET` env vars (fetched from OpenBao in CI).

### Cisco Deployment Pipeline

```
drift-detection → validate → pre-deploy-gate → generate-diff → deploy → verify
```

- **Device as source of truth** — scheduled drift detection treats the device as authoritative, not git. Manual changes are synced INTO git via MR.
- **Hierarchical diffs** — `generate_diff.py` parses configs into hierarchical blocks (interface, router, access-list) and generates only add/remove commands needed. Never replaces entire configs.
- **Dynamic content filtering** — `filter_dynamic_content.py` strips timestamps, checksums, uptime markers, NTP clock periods, and "Building configuration" headers before comparison.
- **Bot exclusions** — pipeline skips commits by `NL Oxidized Bot` (automated backup) and `GitLab CI Auto-Sync` (drift sync) to prevent infinite loops.

### Common Infrastructure

- **SNMP**: All devices report to 10.0.X.X (LibreNMS)
- **Syslog**: All devices log to 10.0.X.X and 10.0.X.X
- **NTP**: Pool servers on routers, specific servers on APs
- **DNS**: 10.0.X.X (local Pi-hole), 1.1.1.1 / 8.8.8.8 (upstream)
- **SSH**: Version 2 on all devices, DH min 4096 on routers

---

## Proxmox VE Infrastructure

### VMID Naming Convention

VMIDs follow a hierarchical 9-digit scheme: `XYZABCDEF`

| Segment | Digits | Meaning |
|---------|--------|---------|
| XYZ | 1-3 | Host/cluster (101=pve01, 102=pve02, 103=pve03) |
| ABC | 4-6 | Functional group (100=infra, 101=apps) |
| DEF | 7-9 | Instance number |

Exceptions: `666`, `777` are IoT cluster nodes (special-purpose IDs).

### Resource Allocation Patterns

**LXC (typical):**
- CPU: 4 cores (62%), 2 cores (25%), 8 cores (11%)
- RAM: 4096 MB (55%), 2048 MB (20%), 8192 MB (10%)
- Disk: 10G (58%), 20G (13%), 50G+ (20%)
- Nesting: 96 of 116 have `nesting=1` (Docker-in-LXC support)

**QEMU (typical):**
- CPU: 4 cores (59%), 2 cores (36%)
- RAM: 8192 MB (41%), 4096 MB (32%)
- Disk: 64-128G most common
- BIOS: OVMF (UEFI) with q35 machine type

### Storage Backends

| Backend | Type | Used By | Purpose |
|---------|------|---------|---------|
| `nl-pve01-local-zfs` | Local ZFS | 72 LXC, 6 QEMU | Performance workloads |
| `nl-pve03-local-zfs` | Local ZFS | 29 LXC, 10 QEMU | Performance workloads |
| `nlpvecl01-nfs` | NFS (shared) | 15 LXC, 4 QEMU | Portable/shared VMs |

### Network Configuration

- **Bridge**: `vmbr0` (all VMs)
- **Primary VLAN**: 10 (management, 10.0.X.X/24) — 104 of 138 configs
- **Gateway**: 10.0.X.X (ASA firewall)
- **DNS**: 10.0.X.X, 10.0.X.X
- **Multi-NIC**: Some containers have up to 7 interfaces (e.g. netalertx01 for network monitoring)

### Boot Order

- `onboot: 1` on 80 LXC (production), `onboot: 0` on 35 (test/lab)
- `startup` field controls ordering: 1-3 critical infra, 4-10 core services, 11+ apps

### Key VMs

| Name | VMID | Type | Host | CPU/RAM | Purpose |
|------|------|------|------|---------|---------|
| nlk8s-ctrl01-03 | 1011006xx | QEMU | pve01+03 | 4C/4-8G | K8s control plane |
| nlk8s-node01-04 | 1011006xx, 1031006xx | QEMU | pve01+03 | 4-8C/8G | K8s workers |
| nlpihole01 | 101100201 | LXC | pve01 | 8C/4G | DNS/DHCP |
| nlnpm01 | 101100401 | LXC | pve01 | 4C/4G | Reverse proxy (NPM) |
| nlpbs01 | 101100802 | LXC | pve01 | 4C/8G | Proxmox Backup Server |

---

## Docker Services

### Service Categories (51 hosts, 80+ services)

**Communication:** matrix01 (Synapse + 8 bridges), mattermost01, librechat01, openwebui01
**Media:** gpu01/jellyfin, navidrome01, lyrion01, feishin01, frigate01, pinchflat01, tautulli01
**AI/GPU** (all on gpu01, 21 services): Ollama, Stable Diffusion, Immich ML, Whisper, Piper, Milvus, LibreTranslate, Audiomuse, Viseron, Beszel, GPU-Hot, Onlogs
**Productivity:** nc01/nc02 (Nextcloud), mealie01, docuseal01, excalidraw01, calibre01, audiobookshelf01, bookwyrm01, linkwarden02
**Infrastructure:** haproxy01/02, npm01, redis01/02/03, influxdb01, proxysql01/02, atlantis01, sftpgo01
**Monitoring:** netalertx01, netvisor01
**Finance:** actualbudget01, ghostfolio01, wallos01

### Compose Conventions

- **Networking**: `network_mode: host` is default (databases, load balancers, GPU, infrastructure). Bridge for multi-container apps (BookWyrm, LibreChat, Immich).
- **Image versions**: Always pinned (no `:latest`). Version history tracked in `.env` files.
- **Restart policy**: `unless-stopped` (90%+), `always` (critical: Redis, InfluxDB), `on-failure` (workers: Celery)
- **Watchtower**: Auto-update labels. Multi-service hosts use scoped updates: `com.centurylinklabs.watchtower.scope=jellyfin`
- **Logging**: Syslog (`udp://127.0.0.1:514`) for Matrix stack → Promtail → Loki. JSON-file (`max-size: 1m, max-file: 30`) for most others.

### GPU Services (nlgpu01)

21 services sharing an RTX 3090 Ti:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1       # or "all"
          capabilities: [gpu]
```

- `count: all` — Ollama, Stable Diffusion
- `count: 1` — Immich ML
- Intel iGPU passthrough (`/dev/dri/renderD128`) — Frigate NVR

### Custom Dockerfiles (3 services)

- **BookWyrm** — Django app, multi-stage build
- **LibreChat** — Node.js + React, jemalloc optimization
- **Matrix** — Mattermost bridge (currently disabled)

All other services use prebuilt public images.

---

## Matrix Homeserver

Self-hosted Matrix stack at `matrix.example.net` on host `nl-matrix01`:

```
Internet → HAProxy (2 VPSes, BGP anycast) → nginx:443/6666 (TLS re-encryption)
  ├── mas.example.net      → MAS:9090 (all paths)
  └── matrix.example.net
      ├── auth (login/logout/refresh) → MAS:9090
      ├── /_matrix/push/v1/notify     → ntfy:8880
      ├── /ntfy/                       → ntfy:8880 (WebSocket)
      ├── /.well-known/*               → static JSON (includes rtc_foci)
      ├── /_matrix|/_synapse/*         → synapse:8008
      ├── /webhook/                    → hookshot:9000 (localhost only)
      └── /                            → element-web:8088
```

### Services

| Service | Image | Port | Status |
|---------|-------|------|--------|
| postgres | postgres:15.13-alpine | 5432 | active |
| synapse | element-hq/synapse:v1.149.1 | 8008 | active |
| mas | element-hq/matrix-REDACTED_6fa691d2-service:1.13.0 | 9090 | active |
| element-web | vectorim/element-web:v1.12.12 | 8088 | active |
| nginx | nginx:1.29.6 | 443, 6666 | active |
| synapse-admin | synapse-admin:0.11.4 | 80 | active (localhost only) |
| matrix-hookshot | matrix-hookshot:7.3.2 | 9993, 9000 | active |
| hookshot-redis | redis:8.6.1-alpine | 6379 | active |
| ntfy | ntfy:v2.18.0 | 8880 | active |
| mautrix-signal | mautrix/signal:v0.2602.2 | 29328 | active |
| mautrix-whatsapp | mautrix/whatsapp:v0.2602.0 | 29329 | active |

### Databases (single Postgres instance)

synapse, mas, mm-matrix-bridge (disabled), mautrix_signal, mautrix_whatsapp

### Bridges (Signal & WhatsApp)

Both use megabridge v0.26+ format with `encryption.appservice: true` + MSC3202/MSC4190 support. Commands: `!signal <cmd>` / `!wa <cmd>`.

### Key Design Decisions

- **MAS** handles all auth via `matrix_REDACTED_6fa691d2_service`
- **Cloudflare Turnstile** captcha on registration
- **Open registration** with email verification and 45 banned disposable email domains
- **Federation whitelisted** to `matrix.org` and `integrations.ems.host` only
- **Element X calling**: MatrixRTC via `livekit-jwt.call.matrix.org`, requires MSC3401+MSC4143
- **Sliding sync**: enabled natively in Synapse (v1.114+)
- **Authenticated media** intentionally disabled
- **Backups**: Postgres cron at 03:00 daily, dumps all 5 databases gzipped

---

## Pinchflat YouTube Archiver

Self-hosted YouTube video archiver on `nlpinchflat01` with VPN protection and automatic self-healing.

```
┌────────────────────────────────────────────────────────────┐
│  nlpinchflat01                                        │
│                                                            │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐  ┌──────────┐ │
│  │ gluetun │◄───│pinchflat│    │watchtower│  │ selfheal │ │
│  │(ProtonVPN)   │(archiver)    │(auto-upd)│  │ (sidecar)│ │
│  │WireGuard│    │         │    └─────────┘  │ loop 15m │ │
│  └─────────┘    └─────────┘                  └──────────┘ │
└────────────────────────────────────────────────────────────┘
```

### Self-Healing Sidecar (`pinchflat-selfheal.py`)

Runs as a Docker sidecar container (not cron), starts on `docker compose up`, loops every 15 minutes:

1. **Container health** — checks pinchflat and gluetun are running
2. **Network connectivity** — verifies VPN via external IP check
3. **Binary health check** — detects yt-dlp corruption ("text file busy"), force-reinstalls via atomic temp-file replacement
4. **YouTube access** — tests YouTube reachability (detects VPN blocks)
5. **Process management** — kills yt-dlp processes running >4 hours
6. **Job queue management** — resets stuck, retryable, and discarded Oban jobs
7. **Error classification** — marks permanent errors (members-only, deleted) vs transient (bot detection, timeouts)
8. **Lightweight indexing** — replaces Pinchflat's native full-channel scans with fast `--flat-playlist --playlist-end 15` checks (seconds vs minutes per source)
9. **yt-dlp updates** — updates binary only when no jobs are running
10. **Corruption recovery** — downloads to `/tmp/yt-dlp-new` then atomically `mv`s, clears corruption errors for retry

### Database Schema

**`sources`** — YouTube channels/playlists: `id`, `collection_name`, `original_url`, `enabled`, `last_indexed_at`
**`media_items`** — Individual videos: `id`, `source_id`, `media_id`, `title`, `media_filepath` (NULL = not downloaded), `prevent_download`, `last_error`
**`oban_jobs`** — Job queue (Elixir Oban): `id`, `queue` (media_collection_indexing / media_fetching), `state` (available/executing/completed/discarded/retryable), `args`, `attempt`, `errors`

---

## Nextcloud HA Cluster (NCHA)

9-layer architecture spanning 21 hosts across 3 Proxmox nodes:

```
DNS RR: nextcloud.example.net
    ├─ nlnpm01 (10.0.X.X, NL)
    └─ grnpm01 (10.0.X.X, GR)
    │
    ▼
NPM (Nginx Proxy Manager) — SSL termination, ~98 proxy configs
    │
    ▼
HAProxy (L7, active/backup, Docker)
    ├─ nlhaproxy01 (pve01, 10.0.X.X) — nc01 PRIMARY, nc02 BACKUP
    └─ nlhaproxy02 (pve03, 10.0.X.X) — nc02 PRIMARY, nc01 BACKUP (cross-site)
    │
    ├── :443  → Nextcloud frontends
    ├── :6380 → Redis (TCP passthrough)
    ├── :9980 → Collabora CODE
    └── :8404 → Stats dashboard
    │
    ▼
Nextcloud Frontends (Apache 2.4.58 + PHP 8.4.18 + PHP-FPM)
    ├─ nlnc01 (QEMU, pve01, 10.0.X.X) — PRIMARY
    └─ nlnc02 (QEMU, pve03, 10.0.X.X) — BACKUP
    │
    ├── DB → ProxySQL (2x, 10.0.X.X+154, port 6033) → Galera MariaDB 11.6.2
    ├── Cache → HAProxy TCP :6380 → Redis Sentinel (3-node, master: redis02)
    ├── Files → NFS VIP 10.0.X.X (DRBD dual-primary + OCFS2, VLAN 88)
    ├── Auth → FreeIPA LDAP (sec.example.net)
    ├── Preview → imaginary01:9000
    ├── AI → gpu01 (face recognition :5000, chat :24002, LLM :24003, text2image :24004)
    └── Storage → Synology NAS 10.0.X.X (homes + media via NFSv4.1)
```

### Complete Host Inventory

**Layer 1 — Entry Point (NPM):**

| Host | VMID | PVE | IP | Role |
|------|------|-----|-----|------|
| nlnpm01 | 101100401 | pve01 | 10.0.X.X | OpenResty 1.27.1, ~98 proxy configs |
| grnpm01 | — | gr-pve01 | 10.0.X.X | GR site entry point (DNS RR partner) |

**Layer 2 — Load Balancer (HAProxy, Docker):**

| Host | VMID | PVE | IP | Config |
|------|------|-----|-----|--------|
| nlhaproxy01 | 101100402 | pve01 | 10.0.X.X | HAProxy 3.3.5, nc01 PRIMARY |
| nlhaproxy02 | 103101007 | pve03 | 10.0.X.X | HAProxy 3.3.5, nc02 PRIMARY (cross-site) |

**Layer 3 — Nextcloud Application (Native Apache + PHP):**

| Host | VMID | PVE | IPs | Version |
|------|------|-----|-----|---------|
| nlnc01 | 101101206 | pve01 | 10.0.X.X, 10.0.X.X | Nextcloud 32.0.6, PHP 8.4.18 |
| nlnc02 | 103101201 | pve03 | 10.0.X.X, 10.0.X.X | Nextcloud 32.0.6, PHP 8.4.18 |

NFS mounts (both nodes, VLAN 88): `10.0.X.X:/mnt/ocfs2/nextcloud/nextcloud-app` → `/var/www/nextcloud`, `10.0.X.X:/mnt/ocfs2/nextcloud/nextcloud-data` → `/mnt/nextcloud-data` (NFSv4.2, nconnect=8)

**Layer 4 — Database (Galera MariaDB + ProxySQL):**

| Host | VMID | PVE | IP | Role |
|------|------|-----|-----|------|
| nlproxysql01 | 101101004 | pve01 | 10.0.X.X | ProxySQL 2.7.2, port 6033 |
| nlproxysql02 | 101101008 | pve03 | 10.0.X.X | ProxySQL 2.7.2, identical config |
| nlcl01mariadb01 | 101101002 | pve01 | 10.0.X.X | MariaDB 11.6.2 Galera, Primary |
| nlcl01mariadb02 | 101101006 | pve03 | 10.0.X.X | MariaDB 11.6.2 Galera, Primary |
| nlcl01garbd01 | 101101007 | pve02 | 10.0.X.X | Galera Arbitrator (quorum voter, no data) |

DNS: `proxysql.example.net` → RR .152 + .154 (Nextcloud connects directly, NOT via HAProxy)

**Layer 5 — Cache (Redis Sentinel):**

| Host | VMID | PVE | IP | Role |
|------|------|-----|-----|------|
| nlredis01 | 102100402 | pve01 | 10.0.X.X | Redis 8.6.1, Slave |
| nlredis02 | 102100403 | pve02 | 10.0.X.X | Redis 8.6.1, **Master** |
| nlredis03 | 102100404 | pve03 | 10.0.X.X | Redis 8.6.1, Slave |

DNS: `redis.example.net` → RR .140 + .158 (HAProxy TCP proxy :6380→6379). Sentinel master: `mymaster`, quorum=2. **Known issue:** HAProxy uses PING health check only — can't detect Redis master. HAProxy has redis03 as PRIMARY but actual master is redis02.

**Layer 6 — Shared Storage (DRBD + OCFS2 + NFS):**

| Host | VMID | PVE | IPs | Role |
|------|------|-----|-----|------|
| nlcl01file01 | VM | pve01 | 10.0.X.X, 10.0.X.X, **VIP 10.0.X.X** | DRBD Primary + OCFS2 + active NFS (Pacemaker-managed), 3.7TB |
| nlcl01file02 | VM | pve03 | 10.0.X.X, 10.0.X.X | DRBD Primary + OCFS2, NFS passive (failover target) |
| nlcl01filearb01 | VM | syno01 | 10.0.X.X, 10.0.X.X | Corosync/Pacemaker quorum voter only |

Pacemaker: 3 nodes, 7 resources. DRBD dual-Primary mode with OCFS2 (cluster filesystem). NFS floating IP 10.0.X.X. Export: `/mnt/ocfs2` to `*(rw,no_root_squash)`. This storage cluster is shared with HAHA — HAHA mounts `/mnt/ocfs2/iot/`.

**Layer 7 — Backend Services:**

| Host | IP | Service | Port |
|------|-----|---------|------|
| nlcode01 | 10.0.X.X | Collabora CODE (Docker) | 9980 |
| nlcode02 | 10.0.X.X | Collabora CODE (backup) | 9980 |
| nlimaginary01 | 10.0.X.X | Imaginary image processing | 9000 |
| nlwhiteboard01 | 10.0.X.X | Nextcloud Whiteboard | — |
| nlhpb01 | 10.0.X.X | Talk HPB signaling | 3478 (TURN), 8181 |
| nlgpu01 | 10.0.X.X | AI backends | 5000, 24002-24004 |

**Layer 8 — Identity (FreeIPA):**

| Host | IP | Role |
|------|-----|------|
| nlfreeipa01 | 10.0.X.X | IPA 4.12.2, LDAP + Kerberos + DNS. Realm: `SEC.NUCLEARLIGHTERS.NET` |
| grfreeipa01 | — | GR site replica, DNS RR + LDAP replication |

**Layer 9 — NAS Storage:**

| Host | Type | IPs | Role |
|------|------|-----|------|
| nl-nas01 | DS1621+ | 10.0.X.X, 10.0.X.X | NFS: homes, Media. Also DRBD arbitrator host. |
| nlsyno02 | DS1513+ | 10.0.X.X | Secondary NAS |

### DNS Records (FreeIPA-managed)

| Record | Resolves To | Purpose |
|--------|-------------|---------|
| `nextcloud.example.net` | .43 (NL) + 10.0.X.X (GR) | User entry point (RR) |
| `redis.example.net` | .140 + .158 (HAProxy) | Redis via HAProxy:6380 |
| `proxysql.example.net` | .152 + .154 | DB via ProxySQL:6033 direct |
| `smtp.example.net` | .71 (NL) + 10.0.X.X (GR) | Outbound email |

### PVE Failure Domains

- **pve01**: npm01, haproxy01, nc01, proxysql01, mariadb01, redis01, file01, code01, freeipa01
- **pve02**: garbd01, redis02 — arbitrators only
- **pve03**: haproxy02, nc02, proxysql02, mariadb02, redis03, file02, code02, imaginary01, whiteboard01, hpb01, gpu01

**Key risk:** pve03 failure takes out half the HA cluster + ALL backend services. pve01 failure takes out primary frontends + NFS server. pve02 only has arbitrators — losing it doesn't cause outage but reduces quorum safety.

---

## Home Assistant HA Cluster (HAHA)

3-node Pacemaker cluster with STONITH fencing and automatic failover. All services run as Pacemaker-managed Docker containers on the active node.

```
IoT Devices (Zigbee, BLE, ESP, WiFi)
    │
    ├─ TubesZB CC2652P7 (Ethernet Zigbee coordinator, PoE, Gi1/0/17, 10.0.X.X:6638)
    ├─ Olimex ESP32-POE-ISO (Ethernet Bluetooth proxy, PoE, Gi1/0/35, 10.0.X.X)
    ├─ M5Stack Atom Echo x2 (WiFi voice assistants, 10.0.X.X)
    ├─ HA Voice PE (WiFi voice assistant, ESP32-S3)
    └─ 50+ Zigbee devices
    │
    ▼
VIP: 10.0.X.X (Pacemaker-managed, floats between iot01/iot02)
    │
    ├── :8123 → Home Assistant (4,142 entities, 82 automations)
    ├── :1883 → Mosquitto MQTT
    ├── :8099 → Zigbee2MQTT (50+ devices, channel 15, PAN ID 6754)
    ├── :6052 → ESPHome (7 devices)
    ├── :1880 → Node-RED
    └── :80   → Emulated Hue (Google Home compatibility)
    │
    ├── Files → NFS 10.0.X.X (file01 VIP) → /mnt/ocfs2/iot
    ├── Media → NFS 10.0.X.X (syno01) → /volume1/Media
    ├── AI → gpu01 Ollama (llama3.2:1b, RTX 3090 Ti)
    └── External → https://homeassistant.example.net (via NPM)
```

### Cluster Nodes

| Host | VMID | PVE | IPs | Role |
|------|------|-----|-----|------|
| nlcl01iot01 | 666 | pve01 | 10.0.X.X, 10.0.X.X | QEMU, 2C/2S, 4GB. Currently standby. |
| nlcl01iot02 | 777 | pve03 | 10.0.X.X, 10.0.X.X | QEMU, 2C/2S, 4GB. Currently **active**. |
| nlcl01iotarb01 | — | syno01 | 10.0.X.X | Synology VMM. Quorum voter + SBD + DC. |

### Pacemaker Configuration

- **Cluster**: `ha_cluster` (Corosync ring: `iotcluster`)
- **Stack**: Corosync 2 + Pacemaker 2.1.6
- **Quorum**: 3 votes, `no-quorum-policy=suicide`
- **Stickiness**: `resource-stickiness=100` (prefer current node after failover)
- **Failure handling**: `migration-threshold=2`, `failure-timeout=60s`, `start-failure-is-fatal=false`
- **Corosync**: token 10000 (10s timeout, tuned for NFS latency), consensus 12000

### STONITH Fencing

| Resource | Type | Target |
|----------|------|--------|
| `fence_iot01` | `fence_pve` | VMID 666 on pve01, runs on iot02 |
| `fence_iot02` | `fence_pve` | VMID 777 on pve03, runs on iotarb01 |
| `sbd_stonith` | `external/sbd` | `/dev/sdb` (all 3 nodes), pinned to iotarb01 |

### Resource Group: `g_iot_stack`

Resources start in order, stop in reverse. All colocated on same node. Never runs on iotarb01.

| # | Resource | Type | Config |
|---|----------|------|--------|
| 1 | `p_fs_iot` | Filesystem | NFS 10.0.X.X:/mnt/ocfs2/iot → /mnt/iot |
| 2 | `p_vip_iot` | IPaddr2 | 10.0.X.X/24 |
| 3 | `p_fs_media` | Filesystem | NFS syno01 Media → /mnt/iot/homeassistant/ha_nl-nas01 |
| 4 | `p_fs_backup` | Filesystem | NFS syno01 Backup → backups/ |
| 5 | `p_docker_home-assistant` | docker | ghcr.io/home-assistant/home-assistant:stable, privileged, host network |
| 6 | `p_docker_mosquitto` | docker | eclipse-mosquitto:latest |
| 7 | `p_docker_zigbee2mqtt` | docker | koenkk/zigbee2mqtt:latest |
| 8 | `p_docker_esphome` | docker | esphome/esphome:latest, privileged |
| 9 | `p_docker_nodered` | docker | nodered/node-red:latest |

### Home Assistant Details

- **Version**: 2026.3.1
- **Entities**: 4,142 across 35 domains (1,857 sensors, 919 binary_sensors, 738 buttons, 139 switches, 82 automations)
- **Automations** (82 total: 63 on, 17 off, 2 unavailable):
  - WC presence lighting (4): TUYA presence → 3 time brackets for brightness
  - Sunset adaptive lighting (10): progressive dimming from 4.5h before sunset to 23:00
  - Ventilation control (4): humidity >50% OR CO2 >800ppm → fan ON
  - Thermostat management (6): lower to 16°C when room unoccupied 15min
  - Doorbell/security (3): G4 motion → camera stream to Shield TV + lights
  - Kitchen appliance safety (3): scheduled ON/OFF, hood auto-off if forgotten
  - EcoDim wall switch (6): 8-button controller for 3 light zones
  - AXA window (2): temp >25°C → open, <25°C → close

### Integrations (key)

Zigbee2MQTT (50+ devices), ESPHome (7 devices), Evohome/Lyric (Honeywell heating), Sonoff/Tuya/BleBox (WiFi devices), UniFi Protect (8 cameras), Nuki (smart locks), Enphase Envoy (solar), Proxmox VE monitoring, APC UPS, Ollama (conversation agent), Wyoming (voice pipeline), Piper TTS, Squeezebox/LMS (7 audio players), Philips TV, Frigate, Immich, CalDAV, HACS.

### Voice Assistant Stack (local-only)

1. Wake word detection → M5Stack Atom Echo / HA Voice PE (ESPHome)
2. Speech-to-text → HA built-in STT
3. Intent processing → Ollama `llama3.2:1b` on gpu01
4. Text-to-speech → Piper TTS (local)
5. Audio output → Sonos Symfonisk or LMS

### Zigbee Devices (50+)

| Brand | Count | Types |
|-------|-------|-------|
| Sonoff | ~12 | Contact sensors, motion sensors, ZBMINIL2 switches, temp/humidity, wireless buttons |
| TUYA | ~12 | Presence detectors, illuminance sensors, smart plugs, LED bulbs, RGB strips |
| IKEA | ~5 | TRADFRI LED lights, signal repeaters, ON/OFF switch, Silverglans |
| Aqara/Xiaomi | ~4 | Cube T1 Pro, roller shade, motion sensors |
| Philips Hue | 1 | Infuse ceiling light |
| Other | ~5 | MOES IR remote + scene switch, Ecodim wall switch, b-parasite plant sensor |

### ESPHome Devices (7)

| Device | Board | Network | Purpose |
|--------|-------|---------|---------|
| Olimex ESP32-POE-ISO | esp32-poe-iso | Ethernet (LAN8720) | Bluetooth proxy (BLE tracker) |
| M5Stack Atom Echo x2 | m5stack-atom | WiFi | Voice assistants with wake word |
| HA Voice PE | esp32-s3-devkitc-1 | WiFi | Voice assistant |
| AXA Remote | nodemcu (ESP8266) | WiFi | Window lock control (GPIO pulse) |
| M5 Atom TimerCam | esp32dev | WiFi | Camera 640x480 |

### IoT Peripherals (Ethernet, not USB)

Both key peripherals connect via Ethernet+PoE to the Cisco switch, enabling clean Pacemaker failover without USB device rebinding:

| Device | Switch Port | IP | Purpose |
|--------|-------------|-----|---------|
| TubesZB CC2652P7 | Gi1/0/17 | 10.0.X.X | Zigbee coordinator, TCP 6638 |
| Olimex ESP32-POE-ISO | Gi1/0/35 | 10.0.X.X | Bluetooth proxy |

Daily PoE power-cycle: cron resets both switch ports at 5:00/6:00 via `hard_reset_tubeszb_olimex.sh` (Netmiko SSH to switch).

### Storage Layout

```
/mnt/iot/                           ← NFS from 10.0.X.X:/mnt/ocfs2/iot
├── homeassistant/
│   ├── ha_config/                  ← HA config + automations
│   │   └── backups/                ← NFS from syno01:/volume1/Backup/habackup
│   └── ha_nl-nas01/           ← NFS from syno01:/volume1/Media
├── mosquitto/msqt_config/          ← Mosquitto config + password file
├── zigbee2mqtt/z2m_data/           ← Z2M config + device database
├── esphome/esphome_config/         ← ESPHome device configs (8 YAML files)
└── nodered/nodered_data/           ← Node-RED flows + settings
```

---

## Secrets Management

```
┌──────────────┐      ┌───────────────────┐      ┌──────────────────────┐
│   OpenBao    │ ───► │ External Secrets   │ ───► │  K8s Secrets         │
│ (HA Cluster) │      │    Operator        │      │  (per namespace)     │
│              │      │                    │      │                      │
│ nl      │      │ ClusterSecretStore │      │ • cloudflare-api     │
│  openbao01/02│      │ "openbao"          │      │ • grafana-admin      │
│ gr      │      │                    │      │ • pihole-password    │
│  openbao01   │      │ Refresh: 1h        │      │ • velero-s3-creds    │
│              │      │ Auth: Kubernetes    │      │ • npm-credentials    │
│ Paths:       │      │ JWT auth for CI    │      │                      │
│ secret/k8s/  │      │                    │      │                      │
└──────────────┘      └───────────────────┘      └──────────────────────┘
```

- **K8s secrets**: OpenBao → External Secrets Operator (1h refresh)
- **CI/CD secrets**: OpenBao JWT auth (`openbao.yml` shared templates), role `gitlab-ci`
- **Docker secrets**: `.env` files alongside `docker-compose.yml` (private repo, intentional)
- **Cisco credentials**: `CISCO_USER`/`CISCO_PASSWORD`/`CISCO_ENABLE_SECRET` fetched from OpenBao at CI job runtime
- **K8s secret paths**: `secret/k8s/<namespace>/<secret-name>` or `secret/k8s/shared/` for cross-namespace
- **Wildcard cert**: cert-manager pushes to OpenBao via PushSecret for GR cluster consumption

---

## Monitoring Stack

### LibreNMS (Infrastructure)

- **Instance**: nlnms01 (10.0.X.X)
- **Devices**: 137 monitored across 9 OS types:

| OS | Type | Count | Examples |
|----|------|-------|---------|
| `proxmox` | server | 89 | PVE containers/VMs |
| `linux` | server | 25 | Bare Linux (UniFi, custom) |
| `ping` | — | 10 | Cameras, miners, K8s pihole |
| `ios` | network | 5 | Cisco APs + LTE router |
| `iosxe` | network | 2 | Cisco switch + router |
| `asa` | firewall | 1 | Cisco ASA 5508-X |
| `apc` | power | 2 | APC UPS + PDU |
| `dsm` | storage | 2 | Synology DS1621+ / DS1513+ |
| `pfsense` | firewall | 1 | pfSense VPN gateway |

- **Alert rules**: 16 (device up/down, service checks, SNMP thresholds)
- **Alert flow**: LibreNMS → webhook → n8n LibreNMS Receiver (24 nodes, dual-store dedup, 2h TTL) → Matrix → OpenClaw infra-triage → YT issue → Claude Code

### Prometheus + Thanos (Kubernetes)

- **Prometheus**: 2 replicas, 200Gi each, 1095-day retention, site label `nl`
- **Thanos**: Query (2 replicas) + Store (2 replicas, SeaweedFS S3) + Compactor
- **Cross-site**: GR Thanos Store reached via ClusterMesh. Query: `{site="nl"}` or `{site="gr"}`
- **Grafana**: 2 replicas, NFS-backed (20Gi). Datasources: Prometheus (local), Thanos (cross-site), Loki (logs), Alertmanager
- **Custom alerts** (13, in `k8s/namespaces/monitoring/custom-alerts.tf`): ContainerOOMKilled, REDACTED_879bd353, REDACTED_02123891, REDACTED_a8a7eee8, REDACTED_67797f17, CiliumAgentNotReady, REDACTED_b94e0389, REDACTED_e52ce3d8, NFSMountStale, NFSMountHighLatency, ArgocdAppDegraded, ArgocdAppOutOfSync, HighPodRestartRate

### Network Monitoring

| Exporter | Port | Metrics |
|----------|------|---------|
| FRR Exporter | :9342 | BGP sessions, prefix counts, peer state, uptime |
| IPsec Exporter | :9903 | Tunnel state, bytes in/out, packets, SA lifetime |
| SNMP Exporter | :9116 | Cisco ASA interface, CPU, memory |
| Cilium/Hubble | — | BGP peers, endpoints, network flows |

---

## GitHub Public Mirror

Selected content is automatically sanitized and synced to a public GitHub repository on every push to main.

### Sanitization Pipeline (4-layer defense-in-depth)

1. **Path filter** — only whitelisted directories are included via `git filter-repo --path`
2. **Static replacements** — hostnames, domains, IPs, node names replaced via regex patterns in `replacements.txt`
3. **Dynamic secret scanning** — multi-pass gitleaks + trufflehog (up to 10 passes), any detected secret >8 chars → `REDACTED_<md5hash>`
4. **Final verification** — gitleaks + trufflehog + custom ripgrep patterns (leftover hostnames, internal domains, private IPs, API key formats) + detect-secrets (advisory)

### What Gets Sanitized

| Category | Pattern | Replacement |
|----------|---------|-------------|
| Site prefixes | `nl`, `gr` | `nl`, `gr` |
| Domains | `example.net` (most specific first) | `example.net` |
| Private IPs | `192.168.x.x`, `172.16-18.x.x` | `10.0.X.X`, `10.1.X.X` |
| Public IPs | `45.138.5x.x`, `185.44.82.x`, `185.125.171.x` | `203.0.113.X`, `198.51.100.X` (RFC 5737) |
| Node names | 15 explicit renames (PVE, OpenBao, FRR, storage, controllers) | Generic names |
| Secrets | SNMP communities, WiFi PSK, JWT tokens, passwords, API keys | `REDACTED` or `REDACTED_<hash>` |
| Nextcloud config | instanceid, passwordsalt, secret, dbpassword, API keys | `REDACTED` |
| Disk UUIDs | LVM UUIDs, fstab UUIDs | `REDACTED` |
| Locations | City names | Country only |
| CLAUDE.md files | All instances | Deleted |

### Included Paths

README.md, LICENSE, atlantis.yaml, renovate.json, `k8s/` (→ `kubernetes/`), `network/configs/`, `network/scripts/`, `network/ansible/`, `ansible/playbooks/`, `ci/` (all 8 files), `docker/nl-matrix01/matrix/` (→ `docker/matrix/`), `pve/scripts/` (→ `proxmox/scripts/`), `native/ncha/` (→ `nextcloud-ha/`)

### Runner Image

`github-sync-runner` (debian:bookworm-slim, ~444MB): git-filter-repo, gitleaks v8.21.2, trufflehog v3.82.13, detect-secrets, ripgrep, yq. Configs baked in at build time.

---

## Contributing

### Commit Message Format

```
<type>(<scope>): <description>

Types: feat, fix, docs, refactor, test, chore
Scopes: k8s, argocd, cisco, pve, docker, ci, cilium, cert-manager, awx, thanos, clustermesh, matrix, pinchflat
```

### Branch Strategy

- **Direct to main**: `docker/`, `network/`, `pve/` changes — pipelines auto-deploy on push
- **MRs required**: `k8s/` changes — Atlantis handles plan/apply via MR comments
- Do not push to the GitHub public mirror — the `github-sync` pipeline handles sanitization automatically

### Pre-commit Hook

`.githooks/pre-commit` auto-checks `tofu fmt` + `tofu validate` on staged `.tf` files. Install: `git config core.hooksPath .githooks`

---

## License

```
            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
                    Version 2, December 2004

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>

 Everyone is permitted to copy and distribute verbatim or modified
 copies of this license document, and changing it is allowed as long
 as the name is changed.

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. You just DO WHAT THE FUCK YOU WANT TO.
```
