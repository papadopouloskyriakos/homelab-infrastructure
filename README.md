# 🔥 Nuclear Lighters Infrastructure

[![Pipeline Status](https://gitlab.example.net/infrastructure/nl/production/badges/main/pipeline.svg)](https://gitlab.example.net/infrastructure/nl/production/-/pipelines)
[![License: WTFPL](https://img.shields.io/badge/License-WTFPL-brightgreen.svg)](http://www.wtfpl.net/about/)

**Hybrid GitOps Infrastructure as Code for the Nuclear Lighters homelab.**

This repository is the **single source of truth** for the entire Nuclear Lighters infrastructure — managing network devices, virtual machines, containers, Kubernetes deployments, and 60+ Docker services through GitLab CI/CD pipelines with a two-tier GitOps model.

---

## 🎯 Overview

| Component | Technology | Management | Purpose |
|-----------|------------|------------|---------|
| ☸️ Kubernetes | K8s v1.34.2 (14 nodes) | Atlantis + Argo CD | Container orchestration |
| 🌐 CNI | Cilium v1.18.4 (eBPF) | OpenTofu | Networking + kube-proxy replacement |
| 🔀 Load Balancing | Cilium LB-IPAM + BGP | OpenTofu | LoadBalancer services via BGP |
| 🌍 Multi-Site | Cilium ClusterMesh | OpenTofu | Cross-cluster service discovery |
| 💾 Storage | NFS + Synology iSCSI CSI | OpenTofu | Dynamic provisioning (RWX + RWO) |
| 🔒 TLS Automation | cert-manager + Let's Encrypt | OpenTofu | Wildcard certificates, DNS-01 validation |
| 🔐 Secrets | External Secrets + OpenBao | OpenTofu | Centralized secrets management |
| 🛡️ Service Mesh | Cilium mTLS + SPIRE | OpenTofu | Mutual TLS REDACTED_6fa691d2 |
| 📊 Monitoring | REDACTED_d8074874 + Thanos | Helm | Prometheus, Grafana, Alertmanager |
| 📜 Logging | syslog-ng → Loki → Grafana | LXC + K8s | Centralized log aggregation |
| 🔄 Backup | Velero + SeaweedFS | Argo CD | Disaster recovery, scheduled backups |
| 🤖 Automation | AWX | OpenTofu | Scheduled jobs, cert sync, maintenance |
| 🌐 Network | Cisco IOS/ASA + FRR | GitLab CI/CD | Routers, Switches, Firewalls, BGP |
| 🖥️ Virtualization | Proxmox VE (5 nodes) | OpenTofu | 100+ LXC, 20+ QEMU VMs |
| 🐳 Docker | 60+ Services | GitLab CI/CD | GPU/AI, Media, Databases |
| 🔄 GitOps | Atlantis + Argo CD | - | Pipeline-driven deployments |

---

## 🌍 Multi-Site Architecture

Nuclear Lighters spans **4 countries** with a hub-and-spoke topology connected via IPsec VPN mesh:

```
                              ┌─────────────────────────────────────────────────────────────┐
                              │                      INTERNET                               │
                              │                                                             │
                              │    AS34927 (iFog)              AS56655 (Gigahost)          │
                              │         │                            │                      │
                              │         │ eBGP                       │ eBGP                 │
                              │         ▼                            ▼                      │
                              │    ┌─────────┐                  ┌─────────┐                │
                              │    │ 🇨🇭 CH   │                  │ 🇳🇴 NO   │                │
                              │    │ ch-edge │◄────IPsec────────►│ no-edge │                │
                              │    │ Zürich  │                  │ Oslo    │                │
                              │    └────┬────┘                  └────┬────┘                │
                              │         │                            │                      │
                              └─────────┼────────────────────────────┼──────────────────────┘
                                        │                            │
              ┌─────────────────────────┼────────────────────────────┼─────────────────────────┐
              │                         │        IPsec Mesh          │                         │
              │         ┌───────────────┴────────────────────────────┴───────────────┐        │
              │         │                                                            │        │
              │         ▼                                                            ▼        │
              │    ┌─────────────────────────────────┐    ┌─────────────────────────────────┐ │
              │    │        🇳🇱 NETHERLANDS           │    │          🇬🇷 GREECE              │ │
              │    │         (Primary Site)          │    │         (DR Site)               │ │
              │    │                                 │    │                                 │ │
              │    │  ┌─────────┐    ┌─────────┐    │    │  ┌─────────┐    ┌─────────┐    │ │
              │    │  │ nl-rtr01│    │ nl-rtr02│    │    │  │ gr-rtr01│    │ gr-rtr02│    │ │
              │    │  │   RR    │    │   RR    │    │    │  │   RR    │    │   RR    │    │ │
              │    │  └────┬────┘    └────┬────┘    │    │  └────┬────┘    └────┬────┘    │ │
              │    │       │              │         │    │       │              │         │ │
              │    │       └──────┬───────┘         │    │       └──────┬───────┘         │ │
              │    │              │                 │    │              │                 │ │
              │    │         ┌────▼────┐            │    │         ┌────▼────┐            │ │
              │    │         │ NL-ASA  │            │    │         │ GR-ASA  │            │ │
              │    │         │ 5508-X  │            │    │         │ 5508-X  │            │ │
              │    │         └────┬────┘            │    │         └────┬────┘            │ │
              │    │              │ eBGP            │    │              │ eBGP            │ │
              │    │              ▼                 │    │              ▼                 │ │
              │    │    ┌─────────────────┐         │    │    ┌─────────────────┐         │ │
              │    │    │   K8s Cluster   │         │    │    │   K8s Cluster   │         │ │
              │    │    │   (7 nodes)     │◄═══ClusterMesh═══►│   (7 nodes)     │         │ │
              │    │    │   nl       │         │    │    │   gr       │         │ │
              │    │    └─────────────────┘         │    │    └─────────────────┘         │ │
              │    │                                 │    │                                 │ │
              │    │  Proxmox: 3 nodes              │    │  Proxmox: 2 nodes              │ │
              │    │  Storage: Synology DS1621+    │    │  Storage: Local ZFS            │ │
              │    │  LXC: 100+, QEMU: 20+         │    │  LXC: 10+, QEMU: 10+           │ │
              │    └─────────────────────────────────┘    └─────────────────────────────────┘ │
              └───────────────────────────────────────────────────────────────────────────────┘
```

### Site Details

| Site | Location | Role | Infrastructure | K8s Nodes |
|------|----------|------|----------------|-----------|
| **🇳🇱 NL** | Netherlands | Primary | 3× Proxmox, Synology NAS, Cisco ASA 5508-X | 7 (3 CP + 4 W) |
| **🇬🇷 GR** | Greece | Disaster Recovery | 2× Proxmox, Local ZFS, Cisco ASA 5508-X | 7 (3 CP + 4 W) |
| **🇨🇭 CH** | Zürich, Switzerland | Edge (iFog VPS) | VPS, FRR BGP | - |
| **🇳🇴 NO** | Oslo, Norway | Edge (Gigahost VPS) | VPS, FRR BGP | - |

### Proxmox Hardware

**Netherlands (Primary)**:
| Node | Hardware | CPU | RAM | Storage |
|------|----------|-----|-----|---------|
| nl-pve01 | Venus Series Mini PC | i9-12900H (20 threads) | 96 GB | NVMe ZFS |
| nl-pve02 | Synology DS1621+ VM | Ryzen V1500B (8 cores) | 16 GB | NAS iSCSI |
| nl-pve03 | Dell Precision 3680 | i9-14900K (32 threads) | 128 GB | NVMe ZFS |

**Greece (DR)**:
| Node | Hardware | CPU | RAM | Storage |
|------|----------|-----|-----|---------|
| gr-pve01 | Venus Series Mini PC | i9-12900H (20 threads) | 96 GB | NVMe ZFS |
| gr-pve02 | Dell PowerEdge T110 II | Xeon E3-1270 V2 (8 threads) | 32 GB | SSD ZFS |

---

## 🌐 AS214304 - Public BGP

Nuclear Lighters operates its own **Autonomous System** for global IPv6 connectivity:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AS214304 - NUCLEAR LIGHTERS                        │
│                                                                              │
│  ASN:        AS214304                                                        │
│  IPv6:       2a0c:9a40:8e20::/48                                            │
│  AS-SET:     AS214304:AS-NUCLEAR-LIGHTERS                                   │
│  Status:     RIPE NCC Assigned (December 2025)                              │
│                                                                              │
│  Upstreams:                                                                  │
│  ├── AS34927 (iFog GmbH) ────────── Zürich, CH                             │
│  └── AS56655 (Gigahost AS) ──────── Oslo, NO                               │
│                                                                              │
│  IXP:        FogIXP EU (pending)                                            │
│                                                                              │
│  RIPE Objects:                                                               │
│  ├── aut-num:    AS214304                                                   │
│  ├── inet6num:   2a0c:9a40:8e20::/48                                        │
│  ├── as-set:     AS214304:AS-NUCLEAR-LIGHTERS                               │
│  ├── org:        ORG-NL672-RIPE                                             │
│  └── mntner:     NUCLEAR-LIGHTERS-MNT                                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

### IPv6 Allocation Plan

```
2a0c:9a40:8e20::/48
├── 2a0c:9a40:8e20::/52  → NL Site (4,096 /64s)
│   ├── 2a0c:9a40:8e20::/56  → NL Infrastructure
│   └── 2a0c:9a40:8e21::/56  → NL Kubernetes Pods
├── 2a0c:9a40:8e30::/52  → GR Site (4,096 /64s)
├── 2a0c:9a40:8e40::/52  → CH Edge (4,096 /64s)
├── 2a0c:9a40:8e50::/52  → NO Edge (4,096 /64s)
└── 2a0c:9a40:8e60::/52  → Reserved/Future
```

---

## 🔀 BGP Architecture

The network uses a **three-tier BGP architecture** with private ASNs for internal routing:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              BGP ARCHITECTURE                                │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    EXTERNAL (eBGP) - AS214304                        │    │
│  │                                                                      │    │
│  │      Internet ◄───► ch-edge (AS214304) ◄───► AS34927 (iFog)         │    │
│  │      Internet ◄───► no-edge (AS214304) ◄───► AS56655 (Gigahost)     │    │
│  │                                                                      │    │
│  │      Announces: 2a0c:9a40:8e20::/48                                 │    │
│  └──────────────────────────────┬──────────────────────────────────────┘    │
│                                 │                                            │
│  ┌──────────────────────────────▼──────────────────────────────────────┐    │
│  │                    INTERNAL (iBGP) - AS65000                         │    │
│  │                                                                      │    │
│  │    Full mesh between all FRR routers via IPsec tunnels:             │    │
│  │                                                                      │    │
│  │    ch-edge ◄──► no-edge ◄──► nl-rtr01 ◄──► nl-rtr02                │    │
│  │       │            │            │             │                      │    │
│  │       └────────────┼────────────┼─────────────┘                      │    │
│  │                    │            │                                    │    │
│  │              gr-rtr01 ◄────► gr-rtr02                               │    │
│  │                                                                      │    │
│  │    Route Reflectors: nl-rtr01, nl-rtr02, gr-rtr01, gr-rtr02         │    │
│  │    Clients: ch-edge, no-edge, NL-ASA, GR-ASA                        │    │
│  └──────────────────────────────┬──────────────────────────────────────┘    │
│                                 │                                            │
│  ┌──────────────────────────────▼──────────────────────────────────────┐    │
│  │                 KUBERNETES (eBGP) - AS65001 per site                 │    │
│  │                                                                      │    │
│  │    NL Site:  ASA (AS65000) ◄──eBGP──► Cilium nodes (AS65001)        │    │
│  │    GR Site:  ASA (AS65000) ◄──eBGP──► Cilium nodes (AS65001)        │    │
│  │                                                                      │    │
│  │    Advertises: Pod CIDRs, LoadBalancer IPs                          │    │
│  │    Receives: Default route, internal networks                        │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### ASN Summary

| ASN | Scope | Purpose | Nodes |
|-----|-------|---------|-------|
| **AS214304** | Public | Internet peering, IPv6 announcements | ch-edge, no-edge |
| **AS65000** | Private | Internal backbone iBGP mesh | All FRR routers, ASAs |
| **AS65001** | Private | Kubernetes BGP (per site, isolated) | Cilium nodes |

---

## 🔗 Cilium ClusterMesh

Cross-cluster service discovery and failover between NL and GR Kubernetes clusters:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           CILIUM CLUSTERMESH                                 │
│                                                                              │
│    ┌─────────────────────────┐        ┌─────────────────────────┐          │
│    │      NL Cluster         │        │      GR Cluster         │          │
│    │      (nl)          │        │      (gr)          │          │
│    │                         │        │                         │          │
│    │  ┌─────────────────┐   │        │   ┌─────────────────┐   │          │
│    │  │ ClusterMesh     │   │        │   │ ClusterMesh     │   │          │
│    │  │ API Server      │◄──┼── mTLS ──►│ API Server      │   │          │
│    │  │ (etcd cluster)  │   │        │   │ (etcd cluster)  │   │          │
│    │  └────────┬────────┘   │        │   └────────┬────────┘   │          │
│    │           │             │        │            │            │          │
│    │  ┌────────▼────────┐   │        │   ┌────────▼────────┐   │          │
│    │  │  Cilium Agents  │   │        │   │  Cilium Agents  │   │          │
│    │  │  (all nodes)    │   │        │   │  (all nodes)    │   │          │
│    │  └─────────────────┘   │        │   └─────────────────┘   │          │
│    │                         │        │                         │          │
│    │  Global Services:       │        │   Global Services:      │          │
│    │  • thanos-store-nl│◄═══════►│  • thanos-store-gr│          │
│    │  • thanos-store-gr│  shared │  • thanos-store-nl│          │
│    │    (stub)              │endpoints│    (stub)              │          │
│    └─────────────────────────┘        └─────────────────────────┘          │
│                                                                              │
│  Annotations for Global Services:                                           │
│  ├── service.cilium.io/global: "true"   → Discoverable across clusters     │
│  └── service.cilium.io/shared: "true"   → Export endpoints to remotes      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### ClusterMesh Status

| Metric | Value |
|--------|-------|
| Connected Clusters | 2 (nl, gr) |
| Global Services | 4+ |
| Remote Nodes Synced | 7 per cluster |
| Connection | mTLS via IPsec tunnel |

---

## 📊 Thanos Cross-Site Metrics Federation

Long-term metrics storage and cross-site querying via Thanos:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        THANOS ARCHITECTURE                                   │
│                                                                              │
│    ┌─────────────────────────┐        ┌─────────────────────────┐          │
│    │      NL Cluster         │        │      GR Cluster         │          │
│    │                         │        │                         │          │
│    │  ┌─────────────────┐   │        │   ┌─────────────────┐   │          │
│    │  │   Prometheus    │   │        │   │   Prometheus    │   │          │
│    │  │   (HA: 2 pods)  │   │        │   │   (HA: 2 pods)  │   │          │
│    │  │   site: nl      │   │        │   │   site: gr      │   │          │
│    │  └────────┬────────┘   │        │   └────────┬────────┘   │          │
│    │           │ sidecar    │        │            │ sidecar    │          │
│    │  ┌────────▼────────┐   │        │   ┌────────▼────────┐   │          │
│    │  │  Thanos Sidecar │   │        │   │  Thanos Sidecar │   │          │
│    │  │  :10901 (gRPC)  │   │        │   │  :10901 (gRPC)  │   │          │
│    │  └────────┬────────┘   │        │   └────────┬────────┘   │          │
│    │           │             │        │            │            │          │
│    │  ┌────────▼────────┐   │        │   ┌────────▼────────┐   │          │
│    │  │  Thanos Store   │   │        │   │  Thanos Store   │   │          │
│    │  │  (SeaweedFS S3) │   │        │   │  (SeaweedFS S3) │   │          │
│    │  └────────┬────────┘   │        │   └────────┬────────┘   │          │
│    │           │             │        │            │            │          │
│    │           └─────────────┼────────┼────────────┘            │          │
│    │                         │        │                         │          │
│    │  ┌─────────────────────▼────────▼─────────────────────┐   │          │
│    │  │                  Thanos Query                       │   │          │
│    │  │   Connects to:                                      │   │          │
│    │  │   • Local NL sidecars + store                      │   │          │
│    │  │   • Remote GR store (via ClusterMesh)              │   │          │
│    │  │                                                     │   │          │
│    │  │   Query: {site="nl"} or {site="gr"}                │   │          │
│    │  └─────────────────────────────────────────────────────┘   │          │
│    │                         │                                   │          │
│    │                         ▼                                   │          │
│    │  ┌─────────────────────────────────────────────────────┐   │          │
│    │  │                    Grafana                           │   │          │
│    │  │   Datasource: Thanos (http://thanos-query:9090)     │   │          │
│    │  │   Cross-site dashboards with site selector          │   │          │
│    │  └─────────────────────────────────────────────────────┘   │          │
│    └─────────────────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Grafana Datasources

| Datasource | URL | Purpose |
|------------|-----|---------|
| Prometheus | http://prometheus.monitoring:9090 | Local site metrics |
| Thanos | http://thanos-query.monitoring:9090 | Cross-site aggregated metrics |
| Loki | http://loki.logging:3100 | Log aggregation |
| Alertmanager | http://alertmanager.monitoring:9093 | Alert management |

---

## 🔍 Network Monitoring

Comprehensive network observability with dedicated exporters:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        NETWORK MONITORING STACK                              │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         EXPORTERS                                    │    │
│  │                                                                      │    │
│  │  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐        │    │
│  │  │  FRR Exporter  │  │ IPsec Exporter │  │ SNMP Exporter  │        │    │
│  │  │  :9342         │  │  :9903         │  │  :9116         │        │    │
│  │  │                │  │                │  │                │        │    │
│  │  │ • BGP sessions │  │ • Tunnel state │  │ • ASA metrics  │        │    │
│  │  │ • Prefix counts│  │ • Bytes in/out │  │ • Interface    │        │    │
│  │  │ • Peer state   │  │ • Packets      │  │ • CPU/Memory   │        │    │
│  │  │ • Uptime       │  │ • SA lifetime  │  │                │        │    │
│  │  └───────┬────────┘  └───────┬────────┘  └───────┬────────┘        │    │
│  │          │                   │                   │                  │    │
│  │          └───────────────────┼───────────────────┘                  │    │
│  │                              │                                      │    │
│  │                              ▼                                      │    │
│  │                    ┌─────────────────┐                             │    │
│  │                    │   Prometheus    │                             │    │
│  │                    │  (scrapes all)  │                             │    │
│  │                    └────────┬────────┘                             │    │
│  │                             │                                      │    │
│  │                             ▼                                      │    │
│  │                    ┌─────────────────┐                             │    │
│  │                    │    Grafana      │                             │    │
│  │                    │                 │                             │    │
│  │                    │  Dashboards:    │                             │    │
│  │                    │  • AS214304 Network Flow                      │    │
│  │                    │  • BGP Sessions                               │    │
│  │                    │  • IPsec Tunnels                              │    │
│  │                    │  • Cilium/Hubble                              │    │
│  │                    └─────────────────┘                             │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Key Metrics

| Source | Metrics | Purpose |
|--------|---------|---------|
| FRR Exporter | `frr_bgp_peer_state`, `frr_bgp_peer_prefixes_*` | BGP session health |
| IPsec Exporter | `ipsec_up`, `ipsec_in_bytes`, `ipsec_out_bytes` | VPN tunnel monitoring |
| SNMP Exporter | `snmp_*` (Cisco ASA) | Firewall metrics |
| Cilium | `cilium_bgp_*`, `cilium_endpoint_*` | K8s network metrics |
| Hubble | `hubble_flows_processed_total` | Network flow visibility |

### AS214304 Network Flow Dashboard

5-layer visualization showing traffic flow through the network:

```
Layer 1: Edge Nodes (CH/NO) ──── Transit BGP with AS34927/AS56655
    │
    ▼ IPsec
Layer 2: IPsec Tunnels ──────── 12 tunnels connecting all sites
    │
    ▼
Layer 3: Route Reflectors ───── nl-rtr01/02, gr-rtr01/02
    │
    ▼
Layer 4: Cisco ASA Firewalls ── BGP to Kubernetes nodes
    │
    ▼ eBGP (AS65000 ↔ AS65001)
Layer 5: Kubernetes Pods ────── Cilium CNI, 100+ endpoints
```

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
│  │ 14 Nodes HA    │ │                │ │ 5 Nodes        │ │              │ │
│  │ (2 clusters)   │ │ • Routers      │ │                │ │ • GPU/AI     │ │
│  │                │ │ • Switches     │ │ • 100+ LXC     │ │ • Media      │ │
│  │ Platform:      │ │ • Firewalls    │ │ • 20+ QEMU     │ │ • Databases  │ │
│  │ • Cilium CNI   │ │ • Access Points│ │ • Cloud-init   │ │ • Matrix     │ │
│  │ • ClusterMesh  │ │                │ │ • Templates    │ │ • Nextcloud  │ │
│  │ • Thanos       │ │ Auto Drift     │ │                │ │              │ │
│  │ • Prometheus   │ │ Detection      │ │ OpenTofu       │ │ 60+ Services │ │
│  │ • Grafana      │ │                │ │ Managed        │ │              │ │
│  │ • Ingress NGINX│ │ Python +       │ │                │ │ CI/CD Auto   │ │
│  │ • AWX          │ │ Netmiko        │ │                │ │ Deploy       │ │
│  │ • Velero       │ │                │ │                │ │              │ │
│  │ • cert-manager │ │                │ │                │ │              │ │
│  │ • External Sec │ │                │ │                │ │              │ │
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
│   │   ├── monitoring/            #    - Prometheus + Grafana + Thanos
│   │   ├── pihole/                #    - Pi-hole DNS
│   │   ├── seaweedfs/             #    - Distributed object storage
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

**NL Cluster (nl)** - Primary:
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster v1.34.2                                │
│                  api-k8s.example.net:6443                            │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                       Control Plane (HA)                              │   │
│  │   ┌────────────┐   ┌────────────┐   ┌────────────┐                   │   │
│  │   │  ctrl01   │   │  ctrl02   │   │  ctrl03   │                   │   │
│  │   │  4 CPU     │   │  4 CPU     │   │  4 CPU     │                   │   │
│  │   │  4 GB RAM  │   │  4 GB RAM  │   │  4 GB RAM  │                   │   │
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

**GR Cluster (gr)** - Disaster Recovery:
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster v1.34.2                                │
│                 gr-api-k8s.example.net:6443                          │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                       Control Plane (HA)                              │   │
│  │   ┌────────────┐   ┌────────────┐   ┌────────────┐                   │   │
│  │   │  ctrl01   │   │  ctrl02   │   │  ctrl03   │                   │   │
│  │   │  2 CPU     │   │  2 CPU     │   │  2 CPU     │                   │   │
│  │   │  4 GB RAM  │   │  4 GB RAM  │   │  4 GB RAM  │                   │   │
│  │   └────────────┘   └────────────┘   └────────────┘                   │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                        Worker Nodes                                   │   │
│  │   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐             │   │
│  │   │ worker01│   │ worker02│   │ worker03│   │ worker04│             │   │
│  │   │ 4 CPU   │   │ 4 CPU   │   │ 4 CPU   │   │ 4 CPU   │             │   │
│  │   │ 8 GB    │   │ 8 GB    │   │ 12 GB   │   │ 8 GB    │             │   │
│  │   └─────────┘   └─────────┘   └─────────┘   └─────────┘             │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 🧩 Platform Components

| Category | Component | Version | Status | Description |
|----------|-----------|---------|--------|-------------|
| **CNI** | Cilium | v1.18.4 | ✅ | eBPF networking, kube-proxy replacement |
| **Multi-Cluster** | Cilium ClusterMesh | v1.18.4 | ✅ | Cross-site service discovery |
| **Load Balancing** | Cilium BGP + LB-IPAM | - | ✅ | BGP peering with Cisco ASA |
| **Storage** | Synology CSI / Democratic CSI | v1.1.4 | ✅ | iSCSI block storage (RWO) |
| **Storage** | NFS Provisioner | - | ✅ | NFS shares (RWX) |
| **Object Storage** | SeaweedFS | v4.01 | ✅ | S3-compatible distributed storage |
| **Ingress** | NGINX Ingress | v1.14.1 | ✅ | External HTTP/HTTPS access |
| **Monitoring** | REDACTED_d8074874 | v79.10.0 | ✅ | Prometheus, Grafana, Alertmanager |
| **Metrics** | Thanos | - | ✅ | Long-term storage, cross-site query |
| **Logging** | Grafana Loki | v3.5.7 | ✅ | Log aggregation from syslog-ng |
| **Secrets** | External Secrets | v1.1.1 | ✅ | Sync secrets from OpenBao |
| **TLS** | cert-manager | v1.17.1 | ✅ | Let's Encrypt wildcard certificates |
| **Service Mesh** | Cilium mTLS + SPIRE | - | ✅ | Mutual TLS REDACTED_6fa691d2 |
| **Backup** | Velero + SeaweedFS | - | ✅ | Scheduled backups, DR |
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
│  │ (HA Cluster) │      │    Operator       │      │  (per namespace)     │ │
│  │              │      │                   │      │                      │ │
│  │ NL + GR Raft │      │ ClusterSecretStore│      │ • cloudflare-api     │ │
│  │              │      │ "openbao"         │      │ • grafana-admin      │ │
│  │ secret/k8s/  │      │                   │      │ • pihole-password    │ │
│  │ ├─ argocd/   │      │ ExternalSecret    │      │ • minio-credentials  │ │
│  │ ├─ awx/      │      │ (per namespace)   │      │ • velero-s3-creds    │ │
│  │ ├─ monitoring│      │                   │      │ • npm-credentials    │ │
│  │ ├─ pihole/   │      │ Refresh: 1h       │      │ • k8s-api-creds      │ │
│  │ └─ velero/   │      │                   │      │                      │ │
│  └──────────────┘      └───────────────────┘      └──────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### OpenBao HA Cluster

| Node | Location | Role |
|------|----------|------|
| nl-vault01 | NL | Leader/Standby |
| nl-vault02 | NL | Standby |
| gr-vault01 | GR | Standby |

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

**Check ClusterMesh:**
```bash
cilium clustermesh status
kubectl get svc -A -o json | jq '.items[] | select(.metadata.annotations["service.cilium.io/global"]=="true") | .metadata.name'
```

**Check Thanos stores:**
```bash
curl -s http://thanos-query.monitoring:9090/api/v1/stores | jq
```

### 🌐 BGP Issues

**Check FRR BGP on edge nodes:**
```bash
ssh ch-edge "vtysh -c 'show bgp summary'"
ssh no-edge "vtysh -c 'show bgp ipv6 unicast'"
```

**Check Cilium BGP:**
```bash
cilium bgp peers
cilium bgp routes advertised ipv4 unicast
```

---

## 🤝 Contributing

### Commit Message Format
```
<type>(<scope>): <description>

Types: feat, fix, docs, refactor, test, chore
Scopes: k8s, argocd, cisco, pve, docker, ci, cilium, cert-manager, awx, thanos, clustermesh
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
  <img src="https://img.shields.io/badge/Multi--Site-ClusterMesh-green" alt="ClusterMesh">
  <img src="https://img.shields.io/badge/ASN-AS214304-yellow" alt="AS214304">
  <img src="https://img.shields.io/badge/Secrets-OpenBao-yellow" alt="OpenBao">
  <img src="https://img.shields.io/badge/TLS-cert--manager-green" alt="cert-manager">
</p>

<p align="center">
  <b>🔥 Nuclear Lighters - Hybrid GitOps Multi-Site Infrastructure Since 2024 🔥</b>
</p>
