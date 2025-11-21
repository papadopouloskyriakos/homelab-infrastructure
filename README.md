# 🏗️ Infrastructure Configuration Management

Automated GitLab CI/CD pipeline for managing Docker services, Proxmox VMs/LXC containers, and Cisco network device configurations.

> **⚡ Quick Start:** Make changes → Push → Pipeline validates → Approve deployment → Done

---

## 📋 What This Pipeline Does

| System | What It Manages | Deployment Type |
|--------|----------------|-----------------|
| 🐳 **Docker** | Compose files, .env configs | Automatic on changes |
| 🖥️ **Proxmox** | VM/LXC configurations | Manual approval |
| 🌐 **Cisco** | Router/Switch/Firewall configs | Manual approval |
| 🤖 **Renovate** | Dependency updates | Manual approval |

---

## 🗂️ Repository Structure

```
production/
├── docker/                          # Docker services
│   ├── {hostname}/
│   │   └── {project}/
│   │       ├── docker-compose.yml
│   │       └── .env
│
├── pve/                             ***REMOVED*** configs
│   ├── {hostname}/
│   │   ├── lxc/{vmid}.conf
│   │   └── qemu/{vmid}.conf
│
├── network/
│   └── oxidized/                    # Network device configs
│       ├── Router/
│       ├── Switch/
│       ├── Firewall/
│       ├── Access-Point/
│       ├── PDU/
│       └── UPS/
│
└── .gitlab-ci.yml                   # Pipeline definition
```

---

## 🚀 Deployment Workflows

### 🐳 Docker Services

**Triggers:** Changes to `docker/**/*`  
**Approval:** Automatic (Manual for Renovate updates)

```bash
# 1. Edit compose file
vim docker/nldocker01/immich/docker-compose.yml

# 2. Commit and push
git add docker/nldocker01/immich/
git commit -m "Update Immich to use new config"
git push

# 3. Pipeline automatically deploys
```

**What happens:**
- Files synced to target host via rsync
- `docker compose pull` downloads new images
- `docker compose up -d` applies changes
- Old containers removed with `--remove-orphans`

---

### 🖥️ Proxmox VMs/Containers

**Triggers:** Changes to `pve/**/*.conf`  
**Approval:** Manual

```bash
# 1. Edit VM config
vim pve/nl-pve01/lxc/101000000.conf

# 2. Commit and push
git add pve/nl-pve01/lxc/101000000.conf
git commit -m "Increase memory for LXC 101000000"
git push

# 3. Review validation in pipeline
# 4. Click "Deploy" button in GitLab
```

**Safety features:**
✅ Automatic backup before deployment  
✅ Graceful shutdown → replace config → restart  
✅ Automatic rollback on failure  
✅ Verification of successful startup  

**Backups stored at:** `/var/lib/vz/backup/config-backups/`

---

### 🌐 Network Devices (Cisco)

**Triggers:** Changes to `network/oxidized/**/*`  
**Approval:** Manual  

```bash
# 1. Edit device config
vim network/oxidized/Firewall/nlfw01

# 2. Commit and push
git add network/oxidized/Firewall/nlfw01
git commit -m "Update firewall ACL rules"
git push

# 3. Review validation
# 4. Click "Deploy" button
```

**What happens:**
- 🔒 Creates deployment lock (prevents oxidized backup conflicts)
- 📦 Ansible backs up running config
- 🚀 Deploys new configuration
- ✅ Verifies device connectivity
- ⏳ 60-second settling period
- 🔓 Removes deployment lock

**⚠️ Important:**  
- **Never commit** Oxidized bot backups manually
- Pipeline skips commits with `[oxidized-backup]` tag
- Oxidized bot automatically backs up configs hourly

---

## 🔐 Oxidized Integration

### How It Works

```
Oxidized (hourly scrape)
    ↓
Detects changes
    ↓
Commits to Git with [oxidized-backup] tag
    ↓
Pipeline SKIPS (no deployment triggered)
```

### Deployment Lock System

When **deploying** network configs:
1. Pipeline creates `/tmp/ansible_deployment_lock`
2. Oxidized backup detects lock and skips
3. Pipeline completes and removes lock
4. Next oxidized backup proceeds normally

**This prevents backing up incomplete configs during deployment!**

---

## 🎯 Pipeline Stages

### Stage 1: Validate
- ✅ Syntax checking
- ✅ File integrity
- ✅ Host connectivity
- ✅ Configuration diffs

### Stage 2: Deploy
- 🔒 Create deployment locks (Cisco only)
- 💾 Backup current state
- 🚀 Apply changes
- ✅ Verify success
- ↩️ Auto-rollback on failure

### Stage 3: Verify
- 🔍 Check service health
- 📊 Verify reachability
- 📝 Report status

---

## ⚙️ Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PVE_BACKUP_DIR` | `/var/lib/vz/backup/config-backups` | Proxmox backup location |
| `PVE_DEPLOYMENT_TIMEOUT` | `60` | Seconds to wait for VM/LXC startup |
| `CISCO_BACKUP_DIR` | `/var/backups/cisco-configs` | Network config backups |
| `DEPLOYMENT_LOCK_FILE` | `/tmp/ansible_deployment_lock` | Prevents oxidized conflicts |

---

## 🔑 Prerequisites

### 1. SSH Key Setup

```bash
# Pipeline uses base64-encoded SSH key
base64 ~/.ssh/id_ed25519 > .ssh/one_key.b64
git add .ssh/one_key.b64
git commit -m "Add SSH key for deployments"
git push
```

### 2. Host SSH Access

```bash
# Ensure passwordless SSH to all hosts
ssh root@nl-pve01     ***REMOVED***
ssh root@nldocker01  # Docker
ssh root@nlfw01.example.net  # Network devices
```

### 3. GitLab Runner

- Runner with Docker executor
- Network access to all infrastructure hosts
- Ansible collections installed (automatic via pipeline)

---

## 💡 Best Practices

### ✅ DO

- ✅ Make small, incremental changes
- ✅ Test in development environment first
- ✅ Write descriptive commit messages
- ✅ Review validation output before approving
- ✅ Monitor deployments in real-time

### ❌ DON'T

- ❌ Edit network configs during active deployments
- ❌ Manually commit oxidized backups
- ❌ Force-push to main branch
- ❌ Deploy multiple changes to same device simultaneously
- ❌ Skip validation warnings

---

## 🆘 Troubleshooting

### Deployment Failed

**Check:**
1. Pipeline job logs for error details
2. Target host connectivity: `ssh root@{hostname}`
3. Service logs on target host
4. Backup files (automatic rollback may have occurred)

### Oxidized Backup Triggered Pipeline

**Issue:** Commits with `[oxidized-backup]` shouldn't trigger deploys

**Fix:** Verify skip rule in `.gitlab-ci.yml`:
```yaml
- if: '$CI_COMMIT_MESSAGE =~ /\[oxidized-backup\]/'
  when: never
```

### Git Push Conflict

**Issue:** "non-fast-forward" error

**Fix:**
```bash
git pull --rebase origin main
git push origin main
```

### Deployment Lock Stuck

**Issue:** "Deployment in progress" but no pipeline running

**Fix:**
```bash
# On oxidized host
rm /tmp/ansible_deployment_lock
```

---

## 📊 Monitoring

### Check Deployment History

```bash
# GitLab UI
CI/CD → Pipelines → View jobs

# Recent deployments
Deployments → Environments → Production
```

### View Backups

```bash
***REMOVED*** backups
ssh root@nl-pve01 "ls -lh /var/lib/vz/backup/config-backups/"

# Cisco backups  
ssh root@nlgitlab01 "ls -lh /var/backups/cisco-configs/"

# Oxidized git history
cd /root/.config/oxidized/git_sync
git log --oneline -20
```

---

## 🔄 Manual Rollback

##***REMOVED*** VM/LXC

```bash
# 1. Find backup
ssh root@nl-pve01 "ls -lt /var/lib/vz/backup/config-backups/lxc/ | grep 101000000"

# 2. Stop container
ssh root@nl-pve01 "pct stop 101000000"

# 3. Restore config
ssh root@nl-pve01 "cp /var/lib/vz/backup/config-backups/lxc/101000000_20250121_143022.conf /etc/pve/lxc/101000000.conf"

# 4. Start container
ssh root@nl-pve01 "pct start 101000000"

# 5. Update Git to match
scp root@nl-pve01:/etc/pve/lxc/101000000.conf pve/nl-pve01/lxc/
git add pve/nl-pve01/lxc/101000000.conf
git commit -m "Rollback LXC 101000000"
git push
```

### Network Device

```bash
# 1. Find backup in Ansible backup dir
ssh root@nlgitlab01 "ls -lt /var/backups/cisco-configs/ | grep nlfw01"

# 2. Copy backup to network/oxidized/
scp root@nlgitlab01:/var/backups/cisco-configs/nlfw01_1737469222.cfg network/oxidized/Firewall/nlfw01

# 3. Commit and deploy
git add network/oxidized/Firewall/nlfw01
git commit -m "Rollback firewall to previous config"
git push
# Approve deployment in GitLab UI
```

---

## 🔗 Useful Commands

### Quick Health Check

```bash
# Check all Docker services
for host in nldocker01; do
  echo "=== $host ==="
  ssh root@$host "docker ps --format 'table {{.Names}}\t{{.Status}}'"
done

# Check all Proxmox VMs/LXCs
for host in nl-pve01; do
  echo "=== $host ==="
  ssh root@$host "pct list && qm list"
done

# Check network device reachability
for device in nlfw01 nlrouter01 nlsw01; do
  ping -c 1 ${device}.example.net && echo "✅ $device" || echo "❌ $device"
done
```

### View Recent Changes

```bash
# Last 10 commits
git log --oneline -10

# Changes to specific system
git log --oneline --follow -- docker/nldocker01/
git log --oneline --follow -- pve/nl-pve01/lxc/101000000.conf
git log --oneline --follow -- network/oxidized/Firewall/nlfw01

# Filter out oxidized auto-backups
git log --oneline --all --grep="\[oxidized-backup\]" --invert-grep
```

---

## 🎓 Common Workflows

### Update Docker Service

```bash
# Update image version in .env
vim docker/nldocker01/immich/.env
# Change: IMMICH_VERSION=v1.95.0 → IMMICH_VERSION=v1.96.0

git add docker/nldocker01/immich/.env
git commit -m "Update Immich to v1.96.0"
git push

# Pipeline auto-deploys
```

### Add New Network Interface to VM

```bash
# Edit config
vim pve/nl-pve01/qemu/201000000.conf
# Add: net1: virtio=XX:XX:XX:XX:XX:XX,bridge=vmbr1

git add pve/nl-pve01/qemu/201000000.conf
git commit -m "Add second NIC to VM 201000000"
git push

# Review → Approve in GitLab
```

### Update Firewall Rules

```bash
# Edit firewall config
vim network/oxidized/Firewall/nlfw01

# Add new ACL entries
# access-list outside_in extended permit tcp any host 10.0.1.50 eq 443

git add network/oxidized/Firewall/nlfw01
git commit -m "Allow HTTPS to 10.0.1.50"
git push

# Review → Approve in GitLab
```

---

## 🤖 Renovate Integration

Renovate automatically creates MRs for dependency updates.

**Workflow:**
1. Renovate bot opens MR with version bump
2. Pipeline validates changes
3. Review changelog and test results
4. Approve and merge MR
5. Pipeline deploys automatically (or requires manual approval)

**⚠️ Major version updates show warning - review carefully!**

---

## 🔒 Security Notes

- SSH keys base64-encoded (not encrypted) - use GitLab masked variables for production
- All deployments logged and auditable via Git history
- Manual approval required for infrastructure changes
- Automatic backups before all changes
- Root SSH access required (ensure key rotation schedule)

---

## 📚 Additional Resources

- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [Proxmox Configuration Reference](https://pve.proxmox.com/wiki/Manual:_pve-conf)
- [Ansible Cisco Collections](https://docs.ansible.com/ansible/latest/collections/cisco/index.html)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

## 📞 Support

**Issue?** Check pipeline logs first:
1. Go to CI/CD → Pipelines
2. Click failed pipeline
3. View job output

**Still stuck?**
- Review this README
- Check `/var/log/oxidized_backup.log` on oxidized host
- Verify host connectivity
- Check GitLab Runner status

---

**Last Updated:** 2025-11-21  
**Pipeline Version:** 2.0 (with Oxidized integration)