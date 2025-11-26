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
| 🌐 Network | Cisco IOS/ASA | GitLab CI/CD | Routers, Switches, Firewalls, APs |
| 🖥️ Virtualization | Proxmox VE (3 nodes) | OpenTofu | 100+ LXC, 20+ QEMU VMs |
| 🐳 Docker | 60+ Services | GitLab CI/CD | GPU/AI, Media, Databases |
| 🔄 Automation | GitLab CI/CD | - | Pipeline-driven deployments |

---

## 🏗️ Hybrid GitOps Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SOURCE OF TRUTH                                      │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                      📂 GitLab Repository                              │  │
│  │  k8s/          → OpenTofu configs (Atlantis)                          │  │
│  │  k8s/argocd-apps/ → Argo CD manifests                                 │  │
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
│  │ • Prometheus   │ │ • Firewalls    │ │ • 20+ QEMU     │ │ • Databases  │ │
│  │ • Grafana      │ │ • Access Points│ │ • Cloud-init   │ │ • Matrix     │ │
│  │ • Ingress NGINX│ │                │ │ • Templates    │ │ • Nextcloud  │ │
│  │ • Pi-hole      │ │ Auto Drift     │ │                │ │              │ │
│  │ • AWX          │ │ Detection      │ │ OpenTofu       │ │ 60+ Services │ │
│  │ • MinIO        │ │                │ │ Managed        │ │              │ │
│  │ • Argo CD      │ │ Python +       │ │                │ │ CI/CD Auto   │ │
│  │                │ │ Netmiko        │ │                │ │ Deploy       │ │
│  │ Apps:          │ │                │ │                │ │              │ │
│  │ • Velero       │ │                │ │                │ │              │ │
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
│   │   ├── nfs-provisioner/       #    - NFS StorageClass
│   │   ├── ingress-nginx/         #    - Ingress Controller
│   │   └── gitlab-agent/          #    - GitLab K8s Agent
│   │
│   ├── 📁 namespaces/             #    Application namespaces (Atlantis)
│   │   ├── argocd/                #    - Argo CD deployment
│   │   ├── awx/                   #    - AWX Ansible automation
│   │   ├── minio/                 #    - S3-compatible storage
│   │   ├── monitoring/            #    - Prometheus + Grafana
│   │   └── pihole/                #    - Pi-hole DNS
│   │
│   └── 📁 argocd-apps/            #    Argo CD managed applications
│       └── velero/                #    - Backup & disaster recovery
│           ├── application.yaml   #      Argo CD Application
│           ├── deployment.yaml    #      Velero server
│           ├── daemonset.yaml     #      Node agents
│           ├── schedules.yaml     #      Backup schedules
│           └── ui.yaml            #      Velero UI
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
│  │   ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌────────────┐       │   │
│  │   │   node01   │ │   node02   │ │   node03   │ │   node04   │       │   │
│  │   │  8 CPU     │ │  8 CPU     │ │  8 CPU     │ │  8 CPU     │       │   │
│  │   │  8 GB RAM  │ │  8 GB RAM  │ │  8 GB RAM  │ │  8 GB RAM  │       │   │
│  │   └────────────┘ └────────────┘ └────────────┘ └────────────┘       │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 📦 Managed Workloads

#### Platform Infrastructure (Atlantis + OpenTofu)

| Workload | Namespace | Access | Description |
|----------|-----------|--------|-------------|
| 🗂️ **NFS Provisioner** | `nfs-provisioner` | StorageClass: `nfs-client` | Dynamic NFS provisioning |
| 🌐 **Ingress NGINX** | `ingress-nginx` | LoadBalancer | HTTP/HTTPS ingress |
| 🔗 **GitLab Agent** | `REDACTED_01b50c5d` | Internal | Cluster connectivity |
| 📊 **Prometheus** | `monitoring` | NodePort :30090 | Metrics collection (3yr retention) |
| 📈 **Grafana** | `monitoring` | NodePort :30000 | Dashboards & visualization |
| 🔔 **Alertmanager** | `monitoring` | Internal | Alert routing |
| 🛡️ **Pi-hole** | `pihole` | NodePort :30666 | DNS filtering |
| 🤖 **AWX** | `awx` | NodePort :30994 | Ansible automation |
| 💾 **MinIO** | `minio` | NodePort :30010 | S3-compatible storage |
| 🔄 **Argo CD** | `argocd` | NodePort :30085 | GitOps delivery |

#### Applications (Argo CD)

| Application | Namespace | Access | Description |
|-------------|-----------|--------|-------------|
| 📦 **Velero** | `velero` | NodePort :30012 | Backup & disaster recovery |

### 🔄 Hybrid GitOps Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     Platform Changes (OpenTofu)                              │
│                                                                              │
│   Developer                  Atlantis                    Kubernetes          │
│       │                          │                            │              │
│       │── git push ─────────────▶│                            │              │
│       │                          │── tofu plan ──────────────▶│              │
│       │◀── MR comment (plan) ────│                            │              │
│       │                          │                            │              │
│       │── "atlantis apply" ─────▶│                            │              │
│       │                          │── tofu apply ─────────────▶│              │
│       │◀── MR comment (applied) ─│                            │              │
│       │                          │                            │              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                     Application Changes (Argo CD)                            │
│                                                                              │
│   Developer                  Argo CD                     Kubernetes          │
│       │                          │                            │              │
│       │── git push (main) ──────▶│                            │              │
│       │                          │── detect OutOfSync ───────▶│              │
│       │                          │── auto-sync ──────────────▶│              │
│       │                          │── self-heal if needed ────▶│              │
│       │                          │                            │              │
│       │◀─────────── Synced & Healthy ─────────────────────────│              │
│       │                          │                            │              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 🔗 Access URLs

| Service | NodePort | Ingress |
|---------|----------|---------|
| 📈 Grafana | `<node-ip>:30000` | - |
| 📊 Prometheus | `<node-ip>:30090` | - |
| 🛡️ Pi-hole | `<node-ip>:30666` | `pihole.example.net` |
| 🤖 AWX | `<node-ip>:30994` | - |
| 💾 MinIO Console | `<node-ip>:30010` | `minio.example.net` |
| 🔄 Argo CD | `<node-ip>:30085` | `argocd.example.net` |
| 📦 Velero UI | `<node-ip>:30012` | `velero.example.net` |

### 🔄 K8s Pipeline Jobs

| Stage | Job | Trigger | Description |
|-------|-----|---------|-------------|
| ✅ **validate** | `validate_k8s_opentofu` | `k8s/**/*.tf` | OpenTofu fmt + validate |
| ✅ **validate** | `validate_argocd_manifests` | `k8s/argocd-apps/**/*.yaml` | Dry-run K8s manifests |
| ✔️ **verify** | `verify_k8s_infrastructure` | merge to main | Check pods, services, Argo CD apps |

---

## 🌐 Network Automation (Cisco)

### 🔄 Pipeline Stages

| Stage | Job | Description |
|-------|-----|-------------|
| 🔍 **drift-detection** | `auto_detect_and_sync_drift` | Nightly check for manual SSH changes |
| ✅ **validate** | `pre_deploy_drift_gate` | Blocks deploy if device has unreported changes |
| ✅ **validate** | `validate_cisco_configs` | Syntax validation, sanity checks |
| 📝 **pre-deploy** | `generate_deployment_diffs` | Creates hierarchical diffs (adds + deletes) |
| 🚀 **deploy** | `deploy_cisco_configs` | Applies changes via Netmiko |
| ✔️ **verify** | `verify_cisco_deployments` | Post-deployment validation + ping test |

### 📋 Supported Devices

| Type | Platform | Config Path |
|------|----------|-------------|
| 🌐 Router | Cisco IOS | `network/configs/Router/` |
| 🔀 Switch | Cisco IOS | `network/configs/Switch/` |
| 🛡️ Firewall | Cisco ASA | `network/configs/Firewall/` |
| 📶 Access Point | Cisco IOS | `network/configs/Access-Point/` |

### 🚨 Drift Detection Flow

```
Someone SSHs to device and makes changes
              │
              ▼
┌─────────────────────────────┐
│  Nightly drift detection    │
│  or pre-deploy check        │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│   Drift detected!           │
│   🛑 DEPLOYMENT BLOCKED     │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│  MR created automatically   │
│  with device's current      │
│  configuration              │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│  Review & merge the MR      │
│  Rebase your changes        │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│  Pipeline succeeds! 🎉       │
└─────────────────────────────┘
```

---

## 🖥️ Proxmox Automation

### 📊 Infrastructure Overview

| Node | LXC Containers | QEMU VMs |
|------|----------------|----------|
| nl-pve01 | 76 | 8 |
| nl-pve02 | 7 | - |
| nl-pve03 | 34 | 14 |
| **Total** | **117** | **22** |

### 🔄 Pipeline Stages

| Stage | Description |
|-------|-------------|
| ✅ **validate** | OpenTofu fmt check + validate |
| 📝 **plan** | Generate execution plan |
| 🚀 **apply** | Create/modify VMs & containers (manual trigger) |
| ✔️ **verify** | Verify resources are running |

---

## 🐳 Docker Fleet

### 📊 Service Categories

| Category | Examples | Count |
|----------|----------|-------|
| 🤖 GPU/AI | Ollama, Stable Diffusion, Whisper, Immich | 8+ |
| 🎬 Media | Jellyfin, Plex, Navidrome, Audiobookshelf | 10+ |
| 🗄️ Databases | Redis, InfluxDB, ProxySQL, PostgreSQL | 8+ |
| 💬 Communication | Matrix Synapse, Element, LibreChat | 6+ |
| 📁 Productivity | Nextcloud, Paperless-ngx, Vaultwarden | 10+ |
| 🔧 Infrastructure | Traefik, Portainer, Watchtower | 8+ |
| 📊 Monitoring | Telegraf, Uptime Kuma, Healthchecks | 6+ |
| **Total** | | **60+** |

### 🖥️ Custom Runner Images

| Image | Purpose | Pre-cached |
|-------|---------|------------|
| `k8s-runner` | Kubernetes operations | OpenTofu providers, kubectl, helm |
| `cisco-ee` | Network automation | Netmiko, Ansible, Python |
| `pve-runner` | Proxmox operations | Proxmox API tools |
| `docker-runner` | Docker operations | Docker CLI, buildx |

---

## 📊 Infrastructure Status

| Component | Status | Version | Endpoint |
|-----------|--------|---------|----------|
| ☸️ Kubernetes | 🟢 Operational | v1.34.2 | api-k8s.example.net:6443 |
| 🔄 Argo CD | 🟢 Operational | v2.13.2 | argocd.example.net |
| 📦 Velero | 🟢 Operational | v1.14.1 | velero.example.net |
| 🌐 Cisco Network | 🟢 Operational | - | - |
| 🖥️ Proxmox | 🟢 Operational | - | pve.example.net:8006 |
| 📈 Grafana | 🟢 Running | v12.3.0 | `<node-ip>:30000` |
| 📊 Prometheus | 🟢 Running | v3.7.3 | `<node-ip>:30090` |
| 🛡️ Pi-hole | 🟢 Running | latest | `<node-ip>:30666` |
| 🤖 AWX | 🟢 Running | v24.6.1 | `<node-ip>:30994` |
| 💾 MinIO | 🟢 Running | latest | `<node-ip>:30010` |
| 🐳 Registry | 🟢 Operational | - | registry.example.net |

### 📦 Backup Status (Velero)

| Schedule | Frequency | Retention |
|----------|-----------|-----------|
| daily-backup | 2:00 AM daily | 30 days |
| weekly-backup | 3:00 AM Sunday | 90 days |

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

---

## 🤝 Contributing

### Commit Message Format

```
<type>(<scope>): <description>

Types: feat, fix, docs, refactor, test, chore
Scopes: k8s, argocd, cisco, pve, docker, ci
```

**Examples:**
```bash
feat(k8s): Add cert-manager for TLS certificates
feat(argocd): Deploy external-dns application
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
  <img src="https://img.shields.io/badge/Infrastructure-as%20Code-green" alt="IaC">
</p>

<p align="center">
  <b>🔥 Nuclear Lighters - Hybrid GitOps Since 2024 🔥</b>
</p>
