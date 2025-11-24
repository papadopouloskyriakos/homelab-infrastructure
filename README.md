# 🔥 Nuclear Lighters Infrastructure

[![Pipeline Status](https://gitlab.example.net/infrastructure/nl/production/badges/main/pipeline.svg)](https://gitlab.example.net/infrastructure/nl/production/-/pipelines)
[![License: WTFPL](https://img.shields.io/badge/License-WTFPL-brightgreen.svg)](http://www.wtfpl.net/about/)

**GitLab-driven Infrastructure as Code for the Nuclear Lighters homelab.**

This repository is the **single source of truth** for the entire Nuclear Lighters infrastructure - managing network devices, virtual machines, containers, Kubernetes deployments, and automation through GitLab CI/CD pipelines.

---

## 🎯 Overview

| Component | Technology | Purpose |
|-----------|------------|---------|
| 🌐 Network | Cisco IOS/ASA | Routers, Switches, Firewalls, APs |
| 🖥️ Virtualization | Proxmox VE | QEMU VMs & LXC Containers |
| ☸️ Orchestration | Kubernetes | Container workloads |
| 🐳 Images | Docker | Custom CI/CD runner images |
| 🔄 Automation | GitLab CI/CD | Pipeline-driven deployments |

---

## 📁 Repository Structure

```
production/
├── 📄 _gitlab-ci.yml              # Main pipeline configuration
├── 📄 README.md                   # You are here! 👋
├── 📄 LICENSE                     # WTFPL - Do what you want!
│
├── 📁 ci/                         # 🔧 Modular pipeline includes
│   ├── cisco.yml                  #    Cisco device automation
│   ├── k8s.yml                    #    Kubernetes deployments
│   ├── docker.yml                 #    Docker image builds
│   └── proxmox.yml                #    Proxmox VM/LXC automation
│
├── 📁 network/                    # 🌐 Cisco Network Configs
│   ├── configs/                   #    Device configurations
│   │   ├── Router/                #    - Router configs
│   │   ├── Switch/                #    - Switch configs
│   │   ├── Firewall/              #    - ASA firewall configs
│   │   └── Access-Point/          #    - Wireless AP configs
│   └── scripts/                   #    Python automation scripts
│       ├── detect_drift.py        #    - Drift detection
│       ├── generate_diff.py       #    - Hierarchical diff generator
│       ├── direct_deploy.py       #    - Device deployment
│       ├── validate_syntax.py     #    - Config validation
│       ├── pre_deploy_drift_gate.py   # - Pre-deploy checks
│       ├── post_validate.py       #    - Post-deploy verification
│       ├── auto_sync_drift.py     #    - Auto-sync device→GitLab
│       ├── sync_from_device.py    #    - Manual sync helper
│       ├── filter_dynamic_content.py  # - Dynamic content filter
│       └── rebase-after-drift.sh  #    - Rebase helper script
│
├── 📁 k8s/                        # ☸️ Kubernetes (OpenTofu)
│   ├── main.tf                    #    K8s resources
│   ├── variables.tf               #    Input variables
│   ├── outputs.tf                 #    Output values
│   └── backend.tf                 #    GitLab state backend
│
├── 📁 proxmox/                    # 🖥️ Proxmox Automation
│   ├── lxc/                       #    LXC container definitions
│   │   ├── main.tf                #    - Container resources
│   │   ├── variables.tf           #    - Container variables
│   │   └── templates/             #    - Container templates
│   ├── qemu/                      #    QEMU VM definitions
│   │   ├── main.tf                #    - VM resources
│   │   ├── variables.tf           #    - VM variables
│   │   └── cloud-init/            #    - Cloud-init configs
│   └── modules/                   #    Shared Terraform modules
│
└── 📁 docker/                     # 🐳 Custom Docker Images
    ├── cisco-ee/                  #    Cisco automation image
    │   └── Dockerfile             #    - Netmiko, Ansible, etc.
    ├── k8s-runner/                #    Kubernetes runner image
    │   └── Dockerfile             #    - tofu, kubectl, helm
    ├── docker-runner/             #    Docker operations image
    │   └── Dockerfile             #    - Docker CLI, buildx
    └── pve-runner/                #    Proxmox runner image
        └── Dockerfile             #    - Proxmox API tools
```

---

## 🌐 Network Automation (Cisco)

### 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitLab Repository                         │
│                    (Single Source of Truth)                      │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      GitLab CI/CD Pipeline                       │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐ │
│  │  Drift   │→│ Validate │→│Pre-Deploy│→│  Deploy  │→│ Verify │ │
│  │Detection │ │          │ │  (Diff)  │ │          │ │        │ │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └────────┘ │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Network Devices                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐            │
│  │ 🌐 Router│ │🔀 Switch │ │🛡️Firewall│ │ 📶 AP    │            │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

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

| Type | Platform | Naming Convention | Example | Config Path |
|------|----------|-------------------|---------|-------------|
| 🌐 Router | Cisco IOS | `nllte*` | nl-lte01 | `network/configs/Router/` |
| 🔀 Switch | Cisco IOS | `nlsw*` | nlsw01 | `network/configs/Switch/` |
| 🛡️ Firewall | Cisco ASA | `nlfw*` | nlfw01 | `network/configs/Firewall/` |
| 📶 Access Point | Cisco IOS | `nlap*` | nlap01 | `network/configs/Access-Point/` |

### 🛠️ Making Network Changes

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
#    🚀 Deploys ONLY the changes (not full config)
#    ✔️ Verifies device is reachable
```

### 🚨 Drift Detection Flow

```
Someone SSHs to device and makes changes
              │
              ▼
┌─────────────────────────────┐
│  You push changes to GitLab │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│   Pipeline detects drift!   │
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
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│  Rebase your changes:       │
│  ./network/scripts/         │
│    rebase-after-drift.sh    │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│  Pipeline succeeds! 🎉       │
└─────────────────────────────┘
```

### 🔧 Network Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `detect_drift.py` | Check all devices for drift | `python3 detect_drift.py` |
| `generate_diff.py` | Generate hierarchical diff | `python3 generate_diff.py Router nl-lte01 <config>` |
| `direct_deploy.py` | Deploy diff to device | `python3 direct_deploy.py Router nl-lte01 <diff.json>` |
| `validate_syntax.py` | Validate config syntax | `python3 validate_syntax.py <config_file>` |
| `pre_deploy_drift_gate.py` | Check drift before deploy | `python3 pre_deploy_drift_gate.py Router nl-lte01` |
| `post_validate.py` | Post-deployment checks | `python3 post_validate.py Router nl-lte01` |
| `auto_sync_drift.py` | Auto-sync device→GitLab | `python3 auto_sync_drift.py` |
| `sync_from_device.py` | Manual sync helper | `python3 sync_from_device.py Router nl-lte01` |
| `rebase-after-drift.sh` | Rebase after drift MR | `./rebase-after-drift.sh` |

---

## 🖥️ Proxmox Automation (VMs & Containers)

### 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Proxmox VE Cluster                          │
│                                                                  │
│  ┌─────────────────────────┐  ┌─────────────────────────────┐   │
│  │    🖥️ QEMU/KVM VMs      │  │    📦 LXC Containers        │   │
│  │                         │  │                             │   │
│  │  • Full virtualization  │  │  • Lightweight containers   │   │
│  │  • Any OS supported     │  │  • Shared kernel            │   │
│  │  • Cloud-init support   │  │  • Fast startup             │   │
│  │  • PCI passthrough      │  │  • Low overhead             │   │
│  └─────────────────────────┘  └─────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                            │
                            │ Managed by OpenTofu
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GitLab CI/CD Pipeline                         │
│            (proxmox/ directory → Proxmox API)                    │
└─────────────────────────────────────────────────────────────────┘
```

### 📦 LXC Containers

LXC containers are lightweight Linux containers running on the Proxmox host kernel.

**Use Cases:**
- 🌐 Web servers (nginx, Apache)
- 🗄️ Databases (PostgreSQL, MySQL)
- 🔧 Utility services (DNS, DHCP)
- 📊 Monitoring (Prometheus, Grafana)

**Directory Structure:**
```
proxmox/lxc/
├── main.tf              # Container definitions
├── variables.tf         # Container variables
├── outputs.tf           # Output values
└── templates/           # Container templates
    ├── debian-12.conf   # Debian 12 template
    └── ubuntu-24.conf   # Ubuntu 24.04 template
```

**Example LXC Resource:**
```hcl
resource "proxmox_lxc" "webserver" {
  hostname    = "nlweb01"
  target_node = "nl-pve01"
  ostemplate  = "local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
  
  cores  = 2
  memory = 2048
  swap   = 512
  
  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "10.0.X.X/24"
    gw     = "10.0.X.X"
  }
  
  features {
    nesting = true  # For Docker-in-LXC
  }
}
```

### 🖥️ QEMU Virtual Machines

Full virtualization for workloads requiring complete OS isolation.

**Use Cases:**
- 🪟 Windows servers
- ☸️ Kubernetes nodes
- 🔒 Security-sensitive workloads
- 🧪 Testing environments

**Directory Structure:**
```
proxmox/qemu/
├── main.tf              # VM definitions
├── variables.tf         # VM variables
├── outputs.tf           # Output values
└── cloud-init/          # Cloud-init configurations
    ├── user-data.yaml   # User configuration
    └── network.yaml     # Network configuration
```

**Example QEMU Resource:**
```hcl
resource "proxmox_vm_qemu" "k8s_worker" {
  name        = "nlk8s-wrk01"
  target_node = "nl-pve01"
  clone       = "ubuntu-cloud-template"
  
  cores   = 4
  sockets = 1
  memory  = 8192
  
  disk {
    storage = "local-lvm"
    size    = "50G"
    type    = "scsi"
  }
  
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # Cloud-init configuration
  os_type    = "cloud-init"
  ipconfig0  = "ip=10.0.X.X/24,gw=10.0.X.X"
  ciuser     = "ansible"
  sshkeys    = file("~/.ssh/id_rsa.pub")
}
```

### 🔄 Proxmox Pipeline Stages

| Stage | Description |
|-------|-------------|
| ✅ **validate** | Terraform fmt check + validate |
| 📝 **plan** | Generate execution plan |
| 🚀 **apply** | Create/modify VMs & containers (manual trigger) |
| ✔️ **verify** | Verify resources are running |

### 🔐 Proxmox Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `PVE_API_URL` | Proxmox API endpoint | `https://pve.example.net:8006/api2/json` |
| `PVE_USER` | API user | `root@pam` or `terraform@pve` |
| `PVE_PASSWORD` | API password/token | `****` |
| `PVE_NODE` | Default target node | `nl-pve01` |

---

## ☸️ Kubernetes Deployments

### 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                            │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │  Controller  │  │   Worker 1   │  │   Worker 2   │           │
│  │   (master)   │  │              │  │              │           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│                                                                  │
│  Namespaces:                                                     │
│  ┌────────────┐ ┌────────────┐ ┌────────────┐                   │
│  │ production │ │   pihole   │ │  monitoring│                   │
│  └────────────┘ └────────────┘ └────────────┘                   │
└─────────────────────────────────────────────────────────────────┘
                            │
                            │ Managed by OpenTofu
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    GitLab CI/CD Pipeline                         │
│              (k8s/ directory → Kubernetes API)                   │
└─────────────────────────────────────────────────────────────────┘
```

### 📦 Current Deployments

| App | Namespace | Service Type | Port | Access |
|-----|-----------|--------------|------|--------|
| 🛡️ Pi-hole | `pihole` | NodePort | 30666 | http://\<node-ip\>:30666/admin |

### 🔄 K8s Pipeline Stages

| Stage | Job | Description |
|-------|-----|-------------|
| ✅ **validate** | `validate_k8s_manifests` | `tofu fmt` + `tofu validate` |
| 📝 **pre-deploy** | `plan_k8s_infrastructure` | Generate execution plan |
| 🚀 **deploy** | `apply_k8s_infrastructure` | Apply changes (manual trigger) |
| ✔️ **verify** | `verify_k8s_infrastructure` | Check pods, services, ingress |

### 🛠️ Adding New K8s Deployments

1. **Add resources to `k8s/main.tf`:**
```hcl
resource "kubernetes_deployment" "myapp" {
  metadata {
    name      = "myapp"
    namespace = "production"
  }
  # ... spec
}
```

2. **Commit and push:**
```bash
git add k8s/main.tf
git commit -m "feat(k8s): Add myapp deployment"
git push
```

3. **Pipeline runs automatically:**
   - ✅ Validates manifests
   - 📝 Shows plan (what will change)
   - 🚀 Apply (click manual trigger)
   - ✔️ Verifies deployment

### 🔧 K8s Management Commands

```bash
# View pods
kubectl get pods -n pihole

# View logs
kubectl logs -n pihole <pod-name> -f

# Port forward for testing
kubectl port-forward -n pihole svc/pihole-web 8080:80 --address=0.0.0.0

# Exec into pod
kubectl exec -it -n pihole <pod-name> -- /bin/bash

# Reset Pi-hole password
kubectl exec -n pihole <pod-name> -- pihole -a -p newpassword
```

---

## 🐳 Docker Images

Custom runner images optimized for specific CI/CD tasks.

### 📦 Image Registry

All images stored at: `registry.example.net/infrastructure/nl/production/`

| Image | Purpose | Base | Size | Key Tools |
|-------|---------|------|------|-----------|
| `cisco-ee` | Cisco automation | AWX EE | ~500MB | Netmiko, Ansible, ciscoconfparse |
| `k8s-runner` | K8s deployments | Alpine | ~74MB | OpenTofu, kubectl, helm |
| `docker-runner` | Docker builds | Alpine | ~27MB | Docker CLI, buildx |
| `pve-runner` | Proxmox automation | Alpine | ~28MB | Proxmox API client, OpenTofu |

### 🔨 Building Images

Images auto-build when their Dockerfile changes:

```bash
# Manual build example
cd docker/k8s-runner
docker build -t registry.example.net/infrastructure/nl/production/k8s-runner:latest .
docker push registry.example.net/infrastructure/nl/production/k8s-runner:latest
```

### 📋 Image Contents

**cisco-ee (Cisco Execution Environment):**
```dockerfile
# Based on AWX Execution Environment
- ansible-core
- netmiko
- paramiko
- ciscoconfparse
- textfsm
- cisco.ios collection
- cisco.asa collection
```

**k8s-runner:**
```dockerfile
# Alpine-based, minimal
- opentofu
- kubectl
- helm
- curl, jq, git
```

**pve-runner:**
```dockerfile
# Alpine-based
- opentofu
- proxmoxer (Python)
- curl, jq, git
```

---

## 🔐 GitLab CI/CD Variables

### 🌐 Cisco Network Automation

| Variable | Description | Type | Protected |
|----------|-------------|------|-----------|
| `CISCO_USER` | SSH username for devices | String | ✅ |
| `CISCO_PASSWORD` | SSH password | Secret | ✅ |
| `GITLAB_PUSH_TOKEN` | Token for auto-sync commits | Secret | ✅ |

### ☸️ Kubernetes

| Variable | Description | Type | Protected |
|----------|-------------|------|-----------|
| `K8S_HOST` | API server URL | String | ❌ |
| `K8S_TOKEN` | Service account token | Secret | ✅ |
| `K8S_CA_CERT` | Cluster CA cert (base64) | Secret | ✅ |
| `PIHOLE_PASSWORD` | Pi-hole admin password | Secret | ✅ |

### 🖥️ Proxmox

| Variable | Description | Type | Protected |
|----------|-------------|------|-----------|
| `PVE_API_URL` | Proxmox API endpoint | String | ❌ |
| `PVE_USER` | API username | String | ✅ |
| `PVE_PASSWORD` | API password/token | Secret | ✅ |
| `PVE_NODE` | Default target node | String | ❌ |

### 🐳 Docker Registry

| Variable | Description | Type | Protected |
|----------|-------------|------|-----------|
| `CI_REGISTRY` | GitLab registry URL | Auto | - |
| `CI_REGISTRY_USER` | Registry username | Auto | - |
| `CI_REGISTRY_PASSWORD` | Registry password | Auto | - |

---

## 🧪 Local Development

### 🔧 Prerequisites

```bash
# Python packages for Cisco automation
pip install netmiko paramiko ciscoconfparse pyyaml

# OpenTofu for infrastructure
brew install opentofu  # macOS
# or download from https://opentofu.org

# kubectl for Kubernetes
brew install kubectl   # macOS
```

### 🌐 Testing Cisco Scripts

```bash
# Set credentials
export CISCO_USER="your-username"
export CISCO_PASSWORD="your-password"

# Check all devices for drift
python3 network/scripts/detect_drift.py

# Check specific device
python3 network/scripts/detect_drift.py Router nl-lte01

# Validate config syntax
python3 network/scripts/validate_syntax.py network/configs/Router/nl-lte01

# Generate diff (dry-run)
python3 network/scripts/generate_diff.py Router nl-lte01 network/configs/Router/nl-lte01
```

### ☸️ Testing Kubernetes

```bash
cd k8s

# Set variables
export TF_VAR_k8s_host="https://api-k8s.example.net:6443"
export TF_VAR_k8s_token="your-token"
export TF_VAR_k8s_ca_cert="base64-ca-cert"
export TF_VAR_pihole_password="your-password"

# Initialize and plan
tofu init
tofu plan

# Apply (be careful!)
tofu apply
```

### 🖥️ Testing Proxmox

```bash
cd proxmox/lxc  # or proxmox/qemu

# Set variables
export TF_VAR_pve_api_url="https://pve.example.net:8006/api2/json"
export TF_VAR_pve_user="terraform@pve"
export TF_VAR_pve_password="your-password"

# Initialize and plan
tofu init
tofu plan

# Apply (creates VMs/containers!)
tofu apply
```

---

## 🆘 Troubleshooting

### 🌐 Cisco Issues

**Pipeline fails at drift gate?**
```bash
# Someone made manual changes via SSH
# 1. Review the auto-created MR
# 2. Merge it
# 3. Rebase your changes:
./network/scripts/rebase-after-drift.sh
```

**Can't connect to device?**
```bash
# Check connectivity
ping nlsw01.example.net

# Test SSH manually
ssh kyriakosp@nlsw01.example.net

# Check credentials in GitLab variables
```

**Config deploy succeeded but changes not applied?**
```bash
# Check the deployment log for errors
# Verify with show run on device
ssh user@device "show running-config | include your-change"
```

### ☸️ Kubernetes Issues

**K8s deploy fails with "Unauthorized"?**
```bash
# Token expired - regenerate:
kubectl create token gitlab-ci -n kube-system --duration=8760h

# Update K8S_TOKEN in GitLab → Settings → CI/CD → Variables
```

**Pod not starting?**
```bash
# Check pod status
kubectl get pods -n pihole

# Describe pod for events
kubectl describe pod -n pihole <pod-name>

# Check logs
kubectl logs -n pihole <pod-name>
```

**Service not accessible?**
```bash
# Check service
kubectl get svc -n pihole

# Port forward for testing
kubectl port-forward -n pihole svc/pihole-web 8080:80 --address=0.0.0.0
```

### 🖥️ Proxmox Issues

**VM/Container creation fails?**
```bash
# Check Proxmox API access
curl -k -d "username=user@pam&password=pass" \
  https://pve.example.net:8006/api2/json/access/ticket

# Check storage availability
pvesm status

# Check template exists
pveam list local
```

**Can't connect to VM after creation?**
```bash
# Check if VM is running
qm list

# Check network configuration
qm config <vmid>

# Check cloud-init status (if used)
qm cloudinit dump <vmid> user
```

### 🐳 Docker Issues

**Image build fails?**
```bash
# Build locally to debug
cd docker/k8s-runner
docker build -t test:local .

# Check registry authentication
docker login registry.example.net
```

---

## 📊 Infrastructure Status

| Component | Status | Endpoint |
|-----------|--------|----------|
| 🌐 Cisco Network | 🟢 Operational | - |
| ☸️ Kubernetes | 🟢 Operational | api-k8s.example.net:6443 |
| 🖥️ Proxmox | 🟢 Operational | pve.example.net:8006 |
| 🛡️ Pi-hole | 🟢 Running | \<node-ip\>:30666 |
| 🐳 Registry | 🟢 Operational | registry.example.net |

---

## 🤝 Contributing

1. **Create a branch** (or fork)
2. **Make your changes**
3. **Test locally** if possible
4. **Create a Merge Request**
5. **Pipeline must pass** before merge

### 📝 Commit Message Format

```
<type>(<scope>): <description>

Types: feat, fix, docs, style, refactor, test, chore
Scopes: cisco, k8s, proxmox, docker, ci
```

Examples:
```bash
feat(cisco): Add VLAN 100 to core switch
fix(k8s): Correct Pi-hole service port
docs(readme): Update troubleshooting section
chore(ci): Update runner image version
```

---

## 👤 Author

**Nuclear Lighters Infrastructure Team**

- 🏠 Homelab: Nuclear Lighters
- 🌐 Domain: example.net
- 📧 Contact: admin@example.net

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

See [LICENSE](LICENSE) file for details.

---

<p align="center">
  <img src="https://img.shields.io/badge/Made%20with-❤️-red" alt="Made with love">
  <img src="https://img.shields.io/badge/Powered%20by-GitLab-orange" alt="Powered by GitLab">
  <img src="https://img.shields.io/badge/Infrastructure-as%20Code-blue" alt="IaC">
</p>

<p align="center">
  <b>🔥 Nuclear Lighters - Powering the Homelab Since Day One 🔥</b>
</p>
