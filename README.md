# 🔥 Nuclear Lighters Infrastructure

[![Pipeline Status](https://gitlab.example.net/infrastructure/nl/production/badges/main/pipeline.svg)](https://gitlab.example.net/infrastructure/nl/production/-/pipelines)
[![License: WTFPL](https://img.shields.io/badge/License-WTFPL-brightgreen.svg)](http://www.wtfpl.net/about/)

**Hybrid GitOps Infrastructure as Code for the Nuclear Lighters homelab.**

This repository is the **single source of truth** for the entire Nuclear Lighters infrastructure — managing network devices, virtual machines, containers, Kubernetes deployments, and 60+ Docker services through GitLab CI/CD pipelines with a two-tier GitOps model.

---

## 🎯 Overview

| Component | Technology | Management | Purpose |
|-----------|------------|------------|---------|
| ☸️ Kubernetes | K8s v1.34.2 (7 nodes) | Atlantis + Argo CD | Container orchestration |
| 🌐 CNI | Cilium v1.18.2 (eBPF) | OpenTofu | Networking + kube-proxy replacement |
| 🔀 Load Balancing | Cilium LB-IPAM + BGP | OpenTofu | LoadBalancer services via BGP |
| 💾 Storage | NFS + Synology iSCSI CSI | OpenTofu | Dynamic provisioning (RWX + RWO) |
| 🔒 TLS Automation | cert-manager + Let's Encrypt | OpenTofu | Wildcard certificates, DNS-01 validation |
| 🔐 Secrets | External Secrets + OpenBao | OpenTofu | Centralized secrets management |
| 🛡️ Service Mesh | Cilium mTLS + SPIRE | OpenTofu | Mutual TLS REDACTED_6fa691d2 |
| 📊 Monitoring | REDACTED_d8074874 | Helm | Prometheus, Grafana, Alertmanager |
| 📜 Logging | syslog-ng → Loki → Grafana | LXC + K8s | Centralized log aggregation |
| 🔄 Backup | Velero + MinIO | Argo CD | Disaster recovery, scheduled backups |
| 🤖 Automation | AWX | OpenTofu | Scheduled jobs, cert sync, maintenance |
| 🌐 Network | Cisco IOS/ASA | GitLab CI/CD | Routers, Switches, Firewalls, APs |
| 🖥️ Virtualization | Proxmox VE (3 nodes) | OpenTofu | 100+ LXC, 20+ QEMU VMs |
| 🐳 Docker | 60+ Services | GitLab CI/CD | GPU/AI, Media, Databases |
| 🔄 GitOps | Atlantis + Argo CD | - | Pipeline-driven deployments |

---

## 🏗️ Hybrid GitOps Architecture
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SOURCE OF TRUTH                                      │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      📂 GitLab Repository                              │  │
│  │  k8s/          → OpenTofu configs (Atlantis)                          │  │
│  │  k8s/argocd-apps/ → Argo CD manifests                                 │  │
│  │  ansible/      → AWX playbooks                                        │  │
│  │  network/      → Cisco configs                                        │  │
│  │  pve/          → Proxmox VM/LXC configs                               │  │
│  │  docker/       → 60+ service definitions                              │  │
│  │                                                                        │  │
│  │  📊 1000+ commits • Terraform State Backend                           │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      ⚡ GitLab CI/CD Pipeline                                │
│                                                                              │
│   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐                │
│   │  DRIFT   │ → │ VALIDATE │ → │   PLAN   │ → │  DEPLOY  │                │
│   │  DETECT  │   │          │   │ MR Comment│   │Auto/Manual│               │
│   └──────────┘   └──────────┘   └──────────┘   └──────────┘                │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  🏗️ Atlantis (Platform)          │  🔄 Argo CD (Applications)       │   │
│   │  PR-based OpenTofu workflows     │  Auto-sync with self-healing     │   │
│   │  `atlantis plan` / `apply`       │  GitOps for K8s workloads        │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   Custom Runners: [k8s-runner] [cisco-ee] [pve-runner] [docker-runner]      │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      MANAGED INFRASTRUCTURE                                  │
│                                                                              │
│  ┌────────────────┐ ┌────────────────┐ ┌────────────────┐ ┌──────────────┐ │
│  │ ☸️ Kubernetes   │ │ 🌐 Cisco       │ │ 🖥️ Proxmox     │ │ 🐳 Docker    │ │
│  │ v1.34.2        │ │ Network        │ │ VE             │ │ Fleet        │ │
│  │ 7 Nodes HA     │ │                │ │ 3 Nodes        │ │              │ │
│  │                │ │ • Routers      │ │                │ │ • GPU/AI     │ │
│  │ Platform:      │ │ • Switches     │ │ • 100+ LXC     │ │ • Media      │ │
│  │ • Cilium CNI   │ │ • Firewalls    │ │ • 20+ QEMU     │ │ • Databases  │ │
│  │ • Prometheus   │ │ • Access Points│ │ • Cloud-init   │ │ • Matrix     │ │
│  │ • Grafana      │ │                │ │ • Templates    │ │ • Nextcloud  │ │
│  │ • Ingress NGINX│ │ Auto Drift     │ │                │ │              │ │
│  │ • Pi-hole      │ │ Detection      │ │ OpenTofu       │ │ 60+ Services │ │
│  │ • AWX          │ │                │ │ Managed        │ │              │ │
│  │ • MinIO        │ │ Python +       │ │                │ │ CI/CD Auto   │ │
│  │ • Argo CD      │ │ Netmiko        │ │                │ │ Deploy       │ │
│  │ • Velero       │ │                │ │                │ │              │ │
│  │ • cert-manager │ │                │ │                │ │              │ │
│  │ • External Sec │ │                │ │                │ │              │ │
│  │ • Loki         │ │                │ │                │ │              │ │
│  └────────────────┘ └────────────────┘ └────────────────┘ └──────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │  🔍 Drift → 📝 Auto MR → ✅ Reconcile  │
                    └───────────────────────────────┘
```

---

## 📁 Repository Structure
```
production/
├── 📄 .gitlab-ci.yml              # Main pipeline configuration
├── 📄 atlantis.yaml               # Atlantis project configuration
├── 📄 renovate.json               # Automated dependency updates
├── 📄 README.md                   # You are here! 👋
│
├── 📁 ansible/                    # 🤖 AWX Playbooks
│   └── 📁 playbooks/
│       ├── cert-manager/          #    - TLS cert sync to NPM
│       ├── docker/                #    - Docker project collection
│       ├── pve/                   #    - Proxmox automation
│       ├── snmpd/                 #    - SNMP daemon management
│       ├── ssh/                   #    - SSH key distribution
│       └── updates/               #    - System updates
│
├── 📁 ci/                         # 🔧 Modular pipeline includes
│   ├── cisco.yml                  #    Cisco device automation
│   ├── k8s.yml                    #    Kubernetes (OpenTofu + Argo CD validation)
│   ├── docker.yml                 #    Docker image builds & deployments
│   ├── lxc.yml                    #    Proxmox LXC automation
│   └── qemu.yml                   #    Proxmox QEMU automation
│
├── 📁 k8s/                        # ☸️ Kubernetes Infrastructure
│   ├── main.tf                    #    Main orchestrator
│   ├── variables.tf               #    Input variables
│   ├── outputs.tf                 #    Output values
│   ├── providers.tf               #    Provider configuration
│   │
│   ├── 📁 _core/                  #    Core infrastructure (Atlantis)
│   │   ├── cert-manager/          #    - TLS certificate automation
│   │   ├── cilium/                #    - Cilium BGP configuration
│   │   ├── external-secrets/      #    - External Secrets Operator
│   │   ├── nfs-provisioner/       #    - NFS StorageClass
│   │   ├── nl-nas01-csi/     #    - Synology iSCSI CSI driver
│   │   ├── ingress-nginx/         #    - Ingress Controller
│   │   ├── gitlab-agent/          #    - GitLab K8s Agent
│   │   └── pod-disruption-budgets/#    - PDBs for critical workloads
│   │
│   ├── 📁 namespaces/             #    Application namespaces (Atlantis)
│   │   ├── argocd/                #    - Argo CD deployment
│   │   ├── awx/                   #    - AWX Ansible automation
│   │   ├── cert-manager/          #    - Certificate management
│   │   ├── external-secrets/      #    - Secrets sync from OpenBao
│   │   ├── logging/               #    - Loki log aggregation
│   │   ├── minio/                 #    - S3-compatible storage
│   │   ├── monitoring/            #    - Prometheus + Grafana
│   │   ├── pihole/                #    - Pi-hole DNS
│   │   └── velero/                #    - Backup & DR
│   │
│   └── 📁 argocd-apps/            #    Argo CD managed applications
│       ├── pihole/                #    - Pi-hole DNS ad-blocking
│       └── velero/                #    - Backup & disaster recovery
│
├── 📁 network/                    # 🌐 Cisco Network Configs
│   ├── 📁 configs/                #    Device configurations
│   │   ├── Router/                #    - Router configs
│   │   ├── Switch/                #    - Switch configs
│   │   ├── Firewall/              #    - ASA firewall configs
│   │   └── Access-Point/          #    - Wireless AP configs
│   └── 📁 scripts/                #    Python automation scripts
│       ├── detect_drift.py        #    - Drift detection
│       ├── generate_diff.py       #    - Hierarchical diff generator
│       ├── direct_deploy.py       #    - Device deployment
│       ├── auto_sync_drift.py     #    - Auto-sync device→GitLab
│       └── ...                    #    - More utilities
│
├── 📁 pve/                        # 🖥️ Proxmox Automation
│   ├── 📁 lxc/                    #    LXC container definitions
│   │   ├── nl-pve01/          #    - 76 containers
│   │   ├── nl-pve02/          #    - 7 containers
│   │   └── nl-pve03/          #    - 34 containers
│   └── 📁 qemu/                   #    QEMU VM definitions
│       ├── nl-pve01/          #    - 8 VMs
│       └── nl-pve03/          #    - 14 VMs
│
└── 📁 docker/                     # 🐳 Docker Services & Images
    ├── 📁 images/                 #    Custom CI/CD runner images
    │   ├── cisco-ee/              #    - Cisco automation (Netmiko)
    │   ├── k8s-runner/            #    - K8s runner (tofu, kubectl, helm)
    │   ├── docker-runner/         #    - Docker operations
    │   └── pve-runner/            #    - Proxmox API tools
    └── 📁 services/               #    60+ Docker service definitions
        ├── gpu-ai/                #    - Ollama, Stable Diffusion, Whisper
        ├── media/                 #    - Jellyfin, Plex, Navidrome
        ├── databases/             #    - Redis, InfluxDB, ProxySQL
        └── productivity/          #    - Matrix, LibreChat, Nextcloud
```

---

## ☸️ Kubernetes Infrastructure

### 🏗️ Cluster Architecture
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster v1.34.2                                │
│                  api-k8s.example.net:6443                            │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                       Control Plane (HA)                              │   │
│  │   ┌────────────┐   ┌────────────┐   ┌────────────┐                   │   │
│  │   │  ctrl01   │   │  ctrl02   │   │  ctrl03   │                   │   │
│  │   │  8 CPU     │   │  4 CPU     │   │  8 CPU     │                   │   │
│  │   │  8 GB RAM  │   │  4 GB RAM  │   │  8 GB RAM  │                   │   │
│  │   └────────────┘   └────────────┘   └────────────┘                   │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                        Worker Nodes                                   │   │
│  │   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐             │   │
│  │   │ worker01│   │ worker02│   │ worker03│   │ worker04│             │   │
│  │   │ 8 CPU   │   │ 6 CPU   │   │ 6 CPU   │   │ 4 CPU   │             │   │
│  │   │ 8 GB    │   │ 8 GB    │   │ 8 GB    │   │ 8 GB    │             │   │
│  │   └─────────┘   └─────────┘   └─────────┘   └─────────┘             │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 🧩 Platform Components

| Category | Component | Version | Status | Description |
|----------|-----------|---------|--------|-------------|
| **CNI** | Cilium | v1.18.2 | ✅ | eBPF networking, kube-proxy replacement |
| **Load Balancing** | Cilium BGP + LB-IPAM | - | ✅ | BGP peering with Cisco ASA |
| **Storage** | Synology CSI | v1.1.4 | ✅ | iSCSI block storage (RWO) |
| **Storage** | NFS Provisioner | - | ✅ | NFS shares (RWX) |
| **Ingress** | NGINX Ingress | - | ✅ | External HTTP/HTTPS access |
| **Monitoring** | REDACTED_d8074874 | v79.9.0 | ✅ | Prometheus, Grafana, Alertmanager |
| **Logging** | Grafana Loki | - | ✅ | Log aggregation from syslog-ng |
| **Secrets** | External Secrets | v0.x | ✅ | Sync secrets from OpenBao |
| **TLS** | cert-manager | v1.x | ✅ | Let's Encrypt wildcard certificates |
| **Service Mesh** | Cilium mTLS + SPIRE | - | ✅ | Mutual TLS REDACTED_6fa691d2 |
| **Backup** | Velero + MinIO | - | ✅ | Scheduled backups, DR |
| **DNS** | Pi-hole | - | ✅ | Ad-blocking DNS |
| **Automation** | AWX | - | ✅ | Ansible automation platform |
| **GitOps** | Argo CD | - | ✅ | Application delivery |

---

## 🔐 Secrets Management

### Architecture
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SECRETS FLOW                                         │
│                                                                              │
│  ┌──────────────┐      ┌───────────────────┐      ┌──────────────────────┐ │
│  │   OpenBao    │ ───▶ │ External Secrets  │ ───▶ │  K8s Secrets         │ │
│  │ 10.0.X.X│      │    Operator       │      │  (per namespace)     │ │
│  │              │      │                   │      │                      │ │
│  │ secret/k8s/  │      │ ClusterSecretStore│      │ • cloudflare-api     │ │
│  │ ├─ argocd/   │      │ "openbao"         │      │ • grafana-admin      │ │
│  │ ├─ awx/      │      │                   │      │ • pihole-password    │ │
│  │ ├─ monitoring│      │ ExternalSecret    │      │ • minio-credentials  │ │
│  │ ├─ pihole/   │      │ (per namespace)   │      │ • velero-s3-creds    │ │
│  │ ├─ velero/   │      │                   │      │ • npm-credentials    │ │
│  │ └─ npm/      │      │ Refresh: 1h       │      │ • k8s-api-creds      │ │
│  └──────────────┘      └───────────────────┘      └──────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Current ExternalSecrets

| Namespace | ExternalSecret | Source Path | Purpose |
|-----------|----------------|-------------|---------|
| argocd | gitlab-repo-creds | secret/k8s/argocd | GitLab repository credentials |
| awx | k8s-api-credentials | secret/k8s/awx/api-credentials | K8s API access for playbooks |
| awx | npm-credentials | secret/k8s/npm/credentials | NPM API for cert sync |
| cert-manager | REDACTED_fb8d60db | secret/k8s/cert-manager | DNS-01 validation |
| logging | loki-minio-credentials | secret/k8s/logging | Loki storage backend |
| minio | minio-credentials | secret/k8s/minio | MinIO admin credentials |
| monitoring | monitoring-grafana | secret/k8s/monitoring | Grafana admin password |
| pihole | pihole-credentials | secret/k8s/pihole | Pi-hole web password |
| velero | velero-s3-credentials | secret/k8s/velero | MinIO S3 backup storage |

---

## 🔒 TLS Certificate Automation

### Flow
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TLS CERTIFICATE LIFECYCLE                                 │
│                                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐  │
│  │ cert-manager│───▶│ Let's       │───▶│ Cloudflare  │───▶│ K8s Secret  │  │
│  │ Certificate │    │ Encrypt     │    │ DNS-01      │    │ tls.crt/key │  │
│  │             │    │ ACME        │    │ Validation  │    │             │  │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘  │
│         │                                                        │          │
│         │              ┌──────────────────────────────────────────┘          │
│         │              ▼                                                     │
│         │     ┌─────────────────┐                                           │
│         │     │   AWX Job       │  Daily 6AM UTC                            │
│         │     │   (idempotent)  │  Compares expiry dates                    │
│         │     └────────┬────────┘                                           │
│         │              │                                                     │
│         │              ▼                                                     │
│         │     ┌─────────────────┐    ┌─────────────────┐                   │
│         │     │  NPM Master     │───▶│  Syncthing      │                   │
│         │     │  94 proxy hosts │    │  Replication    │                   │
│         │     │  nlnpm01   │    │                 │                   │
│         │     └─────────────────┘    └────────┬────────┘                   │
│         │                                      │                            │
│         │                                      ▼                            │
│         │                            ┌─────────────────┐                   │
│         │                            │  NPM Slave      │                   │
│         │                            │  grnpm01   │                   │
│         │                            │  + watcher      │                   │
│         │                            │  nginx reload   │                   │
│         │                            └─────────────────┘                   │
│         │                                                                    │
│  Auto-renews 30 days before expiry                                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Components

| Component | Details |
|-----------|---------|
| **ClusterIssuer** | `letsencrypt-prod` - ACME with Cloudflare DNS-01 |
| **Certificate** | `REDACTED_0d82b4df` - *.example.net |
| **Expiry** | Feb 28, 2026 (auto-renews ~Jan 29, 2026) |
| **AWX Job** | `Sync Cert-Manager Cert to NPM` - daily 6AM UTC |
| **AWX Schedule** | ID 6 - `DTSTART:20251201T060000Z RRULE:FREQ=DAILY` |
| **NPM Hosts** | 94 proxy hosts auto-updated |
| **Slave Sync** | Syncthing + watcher script for nginx reload |

---

## 📜 Centralized Logging

### Architecture
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      LOGGING PIPELINE                                        │
│                                                                              │
│  ┌──────────────────────────────────────────────────┐                       │
│  │              LOG SOURCES                          │                       │
│  │                                                   │                       │
│  │  Cisco Devices ──┐                               │                       │
│  │  Linux Servers ──┼──▶ syslog UDP/TCP:514         │                       │
│  │  Proxmox Nodes ──┤                               │                       │
│  │  Docker Hosts  ──┘                               │                       │
│  └───────────────────────────┬──────────────────────┘                       │
│                              │                                               │
│                              ▼                                               │
│  ┌──────────────────────────────────────────────────┐                       │
│  │           syslog-ng (nlsyslogng01)          │                       │
│  │                                                   │                       │
│  │  • Receives all network syslogs                  │                       │
│  │  • Writes to /mnt/logs/syslog-ng/$HOST/...       │                       │
│  │  • Forwards to Loki via TCP:514                  │                       │
│  │                                                   │                       │
│  └───────────────────────────┬──────────────────────┘                       │
│                              │                                               │
│                              ▼                                               │
│  ┌──────────────────────────────────────────────────┐                       │
│  │           Promtail (10.0.X.X)               │                       │
│  │                                                   │                       │
│  │  • Receives forwarded syslogs                    │                       │
│  │  • Parses and labels logs                        │                       │
│  │  • Pushes to Loki                                │                       │
│  └───────────────────────────┬──────────────────────┘                       │
│                              │                                               │
│                              ▼                                               │
│  ┌──────────────────────────────────────────────────┐                       │
│  │           Loki (loki.logging.svc:3100)           │                       │
│  │                                                   │                       │
│  │  • Log aggregation and indexing                  │                       │
│  │  • MinIO S3 backend storage                      │                       │
│  │  • LogQL query language                          │                       │
│  └───────────────────────────┬──────────────────────┘                       │
│                              │                                               │
│                              ▼                                               │
│  ┌──────────────────────────────────────────────────┐                       │
│  │           Grafana (monitoring namespace)         │                       │
│  │                                                   │                       │
│  │  • Loki datasource configured                    │                       │
│  │  • Log exploration and dashboards                │                       │
│  │  • Alerting on log patterns                      │                       │
│  └──────────────────────────────────────────────────┘                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🛡️ Service Mesh & Network Policies

### Cilium mTLS with SPIRE
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MUTUAL TLS AUTHENTICATION                                 │
│                                                                              │
│  ┌──────────────┐                              ┌──────────────┐             │
│  │   Pod A      │                              │   Pod B      │             │
│  │              │◄──── mTLS (SPIFFE/SPIRE) ───▶│              │             │
│  │  identity:   │                              │  identity:   │             │
│  │  spiffe://   │                              │  spiffe://   │             │
│  │  cilium/...  │                              │  cilium/...  │             │
│  └──────────────┘                              └──────────────┘             │
│         │                                              │                    │
│         └──────────────────┬───────────────────────────┘                    │
│                            │                                                 │
│                            ▼                                                 │
│  ┌──────────────────────────────────────────────────┐                       │
│  │              SPIRE Server                         │                       │
│  │              cilium-spire namespace               │                       │
│  │                                                   │                       │
│  │  • Trust domain: spiffe.cilium                   │                       │
│  │  • Issues SVID certificates                      │                       │
│  │  • Agent socket: /run/spire/sockets/agent.sock   │                       │
│  └──────────────────────────────────────────────────┘                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Network Policies (Zero Trust)

| Namespace | Policy | Purpose |
|-----------|--------|---------|
| pihole | `pihole-policy` | Allow DNS (53/UDP,TCP), require mTLS from ingress-nginx |
| logging | `logging-policy` | Control access to Loki |

**Example Policy Features:**
- Ingress from `ingress-nginx` requires `REDACTED_6fa691d2: { mode: required }`
- Egress limited to specific ports (DNS, HTTPS)
- Monitoring namespace allowed for metrics scraping

---

## 🤖 AWX Automation

### Scheduled Jobs

| Job Template | Schedule | Purpose |
|--------------|----------|---------|
| Sync Cert-Manager Cert to NPM | Daily 6AM UTC | TLS cert sync to NPM (idempotent) |
| Cleanup Job/Activity | Weekly | AWX housekeeping |
| Update Proxmox | Manual | System updates |
| Install SNMPD | Manual | Monitoring agent deployment |

### Custom Credential Types

| Name | Purpose | Injected Variables |
|------|---------|-------------------|
| Kubernetes API Token | K8s API access | K8S_HOST, K8S_TOKEN, K8S_CA_CERT |
| NPM API Credentials | NPM certificate management | NPM_EMAIL, NPM_PASSWORD |
| LibreNMS API Token | Monitoring integration | API token |
| Proxmox API | VM/LXC management | API credentials |

### Projects

| Project | Repository | Purpose |
|---------|------------|---------|
| Cert-Manager NPM Sync | gitlab/.../production.git | TLS automation |
| Proxmox Inventory | gitlab/.../production.git | PVE management |
| Collect Docker Projects | gitlab/.../production.git | Documentation |

---

## 📦 Backup & Disaster Recovery

### Velero Configuration

| Component | Details |
|-----------|---------|
| **Storage** | MinIO S3 (minio.example.net) |
| **Location** | `default` BackupStorageLocation |
| **Node Agents** | DaemonSet on all 4 workers |

### Backup Schedules

| Schedule | Cron | Retention |
|----------|------|-----------|
| daily-backup | `0 2 * * *` | Rolling |
| weekly-backup | `0 3 * * 0` | Rolling |

### Recent Backups

- `daily-backup-*` - Automated daily snapshots
- `pre-migration-full` - Pre-change safety backup
- `pre-cilium-migration` / `post-cilium-migration` - CNI migration snapshots

---

## 🛠️ Quick Start

### Making Kubernetes Changes

**Platform Infrastructure (Atlantis):**
```bash
# 1. Create feature branch
git checkout -b feature/add-new-service

# 2. Edit OpenTofu files
vim k8s/namespaces/new-service/main.tf

# 3. Push and create MR
git add -A && git commit -m "feat(k8s): Add new-service"
git push -u origin feature/add-new-service

# 4. Atlantis comments the plan on MR
# 5. Review plan, then comment: atlantis apply
# 6. Merge MR after apply succeeds
```

**Applications (Argo CD):**
```bash
# 1. Create app manifests
mkdir k8s/argocd-apps/new-app
vim k8s/argocd-apps/new-app/deployment.yaml
vim k8s/argocd-apps/new-app/application.yaml

# 2. Push to main (or via MR)
git add -A && git commit -m "feat(argocd): Add new-app"
git push origin main

# 3. Argo CD auto-syncs within 3 minutes
# 4. Check status: kubectl get application new-app -n argocd
```

### Making Network Changes
```bash
# 1. Edit the device config
vim network/configs/Router/nl-lte01

# 2. Commit and push
git add network/configs/Router/nl-lte01
git commit -m "feat(router): Add new VLAN interface"
git push origin main

# 3. Pipeline automatically:
#    ✅ Validates syntax
#    🔍 Checks for drift (blocks if device was modified via SSH)
#    📝 Generates hierarchical diff
#    🚀 Deploys ONLY the changes
#    ✔️ Verifies device is reachable
```

---

## 🆘 Troubleshooting

### ☸️ Kubernetes Issues

**Check Cilium status:**
```bash
cilium status
cilium bgp peers
cilium connectivity test
```

**Hubble network flows:**
```bash
hubble observe --namespace <namespace>
hubble observe --to-pod <pod-name>
```

**Argo CD app stuck in "Progressing"?**
```bash
# Check application status
kubectl get application <app> -n argocd -o yaml

# Force refresh
kubectl patch application <app> -n argocd --type=merge \
  -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
```

**Atlantis plan/apply not working?**
```bash
# Check Atlantis logs
kubectl logs -n atlantis deployment/atlantis

# Verify webhook is configured in GitLab
# Settings → Webhooks → Should see atlantis URL
```

**Pod not starting?**
```bash
# Check pod status
kubectl get pods -n <namespace>
kubectl describe pod -n <namespace> <pod-name>
kubectl logs -n <namespace> <pod-name>
```

**iSCSI volume not attaching?**
```bash
# Check Synology CSI pods
kubectl get pods -n synology-csi

# Check node iSCSI sessions
iscsiadm -m session

# Check PVC status
kubectl get pvc -A
```

### 🔐 Secrets Issues

**External Secrets not syncing?**
```bash
# Check ExternalSecret status
kubectl get externalsecrets -A
kubectl describe externalsecret <name> -n <namespace>

# Check ClusterSecretStore
kubectl describe clustersecretstore openbao

# Check External Secrets Operator logs
kubectl logs -n external-secrets deployment/external-secrets
```

**OpenBao connectivity?**
```bash
# Test from cluster
kubectl run -it --rm debug --image=curlimages/curl -- \
  curl -s http://10.0.X.X:8200/v1/sys/health
```

### 🔒 TLS Issues

**cert-manager not issuing certificates?**
```bash
# Check certificate status
kubectl get certificates -A
kubectl describe certificate <name> -n <namespace>

# Check certificate requests
kubectl get certificaterequests -A

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager
```

**NPM cert not updating?**
```bash
# Manually trigger AWX job
curl -sk -X POST -u "admin:<password>" \
  https://awx.example.net/api/v2/job_templates/33/launch/

# Check NPM certificates
curl -s http://nlnpm01:81/api/nginx/certificates | jq
```

### 🌐 Cisco Issues

**Pipeline fails at drift gate?**
```bash
# Someone made manual changes via SSH
# 1. Review the auto-created MR
# 2. Merge it
# 3. Rebase your changes
./network/scripts/rebase-after-drift.sh
```

### 📦 Velero Issues

**Check backup status:**
```bash
velero backup get
velero schedule get
velero backup-location get
```

**Create manual backup:**
```bash
velero backup create manual-backup --include-namespaces pihole,monitoring
```

### 📜 Logging Issues

**Logs not appearing in Grafana?**
```bash
# Check Loki pods
kubectl get pods -n logging

# Check Promtail is receiving logs
# On syslog-ng server:
journalctl -u syslog-ng -f

# Test Loki datasource in Grafana
# Explore → Select Loki → Run query: {job="syslog"}
```

---

## 🤝 Contributing

### Commit Message Format
```
<type>(<scope>): <description>

Types: feat, fix, docs, refactor, test, chore
Scopes: k8s, argocd, cisco, pve, docker, ci, cilium, cert-manager, awx
```

**Examples:**
```bash
feat(k8s): Add cert-manager for TLS certificates
feat(argocd): Deploy external-dns application
feat(cilium): Configure BGP peering with new router
feat(cert-manager): Add wildcard certificate for example.net
feat(awx): Add NPM cert sync automation
fix(velero): Correct backup schedule timezone
chore(ci): Update k8s-runner image version
docs(readme): Update architecture diagram
```

---

## 📜 License
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

---

<p align="center">
  <img src="https://img.shields.io/badge/Made%20with-❤️-red" alt="Made with love">
  <img src="https://img.shields.io/badge/Powered%20by-GitLab-orange" alt="Powered by GitLab">
  <img src="https://img.shields.io/badge/GitOps-Atlantis%20%2B%20Argo%20CD-blue" alt="GitOps">
  <img src="https://img.shields.io/badge/CNI-Cilium%20eBPF-purple" alt="Cilium">
  <img src="https://img.shields.io/badge/Secrets-OpenBao-yellow" alt="OpenBao">
  <img src="https://img.shields.io/badge/TLS-cert--manager-green" alt="cert-manager">
  <img src="https://img.shields.io/badge/Infrastructure-as%20Code-green" alt="IaC">
</p>

<p align="center">
  <b>🔥 Nuclear Lighters - Hybrid GitOps Since 2024 🔥</b>
</p>
