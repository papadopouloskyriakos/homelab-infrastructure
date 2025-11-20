***REMOVED*** Configuration Management Pipeline

Automated GitLab CI/CD pipeline for safely managing Proxmox LXC and VM configurations with validation, backups, and rollback capabilities.

## Features

✅ **Configuration Validation** - Validates configs before deployment  
✅ **Automatic Backups** - Creates timestamped backups before changes  
✅ **Safe Deployment** - Graceful shutdown, replace config, verify startup  
✅ **Rollback Protection** - Automatic rollback on failure  
✅ **Manual Approval** - Requires manual trigger for deployments  
✅ **Status Verification** - Checks VM/LXC health after deployment  
✅ **Backup Retention** - Automatic cleanup of old backups  

## Pipeline Stages

### 1. Validate (`validate_proxmox_configs`)

- Detects changed `.conf` files
- Validates VMID and type (lxc/qemu)
- Checks host connectivity
- Verifies configuration syntax
- Shows configuration diff
- Checks for required fields

**Triggers:** Automatically on config changes

### 2. Deploy (`deploy_proxmox_configs`)

Performs safe deployment with these steps:

1. **Copy to temp** - Stage new config on Proxmox host
2. **Check status** - Determine current VM/LXC state
3. **Backup** - Save current config with timestamp
4. **Shutdown** - Graceful shutdown (with force fallback)
5. **Replace** - Swap configuration file
6. **Startup** - Start VM/LXC if it was running
7. **Verify** - Confirm successful startup
8. **Rollback** - Automatic if any step fails

**Triggers:** Manual approval required  
**Environment:** Production

### 3. Verify (`verify_deployments`)

- Waits 10 seconds for services to stabilize
- Checks final status of all deployed resources
- Reports any issues

**Triggers:** Automatically after successful deployment

### 4. Cleanup (`cleanup_old_backups`)

- Removes backups older than 30 days
- Runs across all Proxmox hosts
- Reports deletion statistics

**Triggers:** Scheduled (configure in GitLab)

## Repository Structure

```
infrastructure/
├── pve/
│   ├── nl-pve01/          ***REMOVED*** host 1
│   │   ├── lxc/
│   │   │   ├── 101000000.conf
│   │   │   ├── 101020203.conf
│   │   │   └── ...
│   │   └── qemu/
│   │       ├── 201000000.conf
│   │       └── ...
│   ├── nl-pve02/          ***REMOVED*** host 2
│   │   └── ...
│   └── ...
├── .gitlab-ci.yml
└── README.md
```

## Configuration Variables

Set these in GitLab CI/CD settings or modify in pipeline:

| Variable | Default | Description |
|----------|---------|-------------|
| `BACKUP_DIR` | `/var/lib/vz/backup/config-backups` | Backup storage location |
| `TEMP_CONFIG_DIR` | `/tmp/pve-config-staging` | Staging directory |
| `DEPLOYMENT_TIMEOUT` | `60` | Seconds to wait for startup |
| `KEEP_BACKUPS_DAYS` | `30` | Backup retention period |

## Prerequisites

### GitLab Setup

1. **SSH Key** - Base64-encoded private key in `.ssh/one_key.b64`
   ```bash
   base64 ~/.ssh/id_ed25519 > .ssh/one_key.b64
   git add .ssh/one_key.b64
   ```

2. **GitLab Runner** - Configured runner with Docker executor

3. **CI/CD Variables** (optional)
   - Custom backup paths
   - Custom timeouts
   - Notification webhooks

##***REMOVED*** Host Setup

1. **SSH Access** - Root SSH access with key authentication
   ```bash
   ssh-copy-id root@nl-pve01
   ```

2. **Backup Directory** - Ensure directory exists or pipeline creates it
   ```bash
   mkdir -p /var/lib/vz/backup/config-backups/{lxc,qemu}
   ```

3. **Hostname Resolution** - Ensure hostnames resolve correctly
   ```bash
   # Test from GitLab runner
   ping nl-pve01
   ```

## Usage

### Making Configuration Changes

1. **Edit configuration** in GitLab (web IDE or git clone)
   ```bash
   git clone <repo-url>
   cd infrastructure
   vim pve/nl-pve01/lxc/101000000.conf
   ```

2. **Commit and push** changes
   ```bash
   git add pve/nl-pve01/lxc/101000000.conf
   git commit -m "Update LXC 101000000 memory allocation"
   git push
   ```

3. **Pipeline runs automatically**
   - Validation stage runs first
   - If validation passes, deployment job waits for manual approval

4. **Review and approve**
   - Check pipeline validation output
   - Review configuration diff
   - Click "Play" button on deploy job

5. **Monitor deployment**
   - Watch job output in real-time
   - Verify successful completion
   - Check verification stage

### Viewing Deployment History

All deployments are tracked in GitLab:
- Pipeline history: `CI/CD → Pipelines`
- Deployment environments: `Deployments → Environments → Production`
- Job logs: Click any pipeline → View job output

### Accessing Backups

Backups are stored on each Proxmox host:

```bash
# List all backups
ssh root@nl-pve01 "ls -lh /var/lib/vz/backup/config-backups/lxc/"

# Find backups for specific VMID
ssh root@nl-pve01 "find /var/lib/vz/backup/config-backups -name '101000000_*'"

# View a backup
ssh root@nl-pve01 "cat /var/lib/vz/backup/config-backups/lxc/101000000_20250117_143022.conf"
```

### Manual Rollback

If you need to manually rollback a configuration:

1. **Find the backup**
   ```bash
   ssh root@nl-pve01 "ls -lt /var/lib/vz/backup/config-backups/lxc/ | grep 101000000"
   ```

2. **Stop the LXC/VM**
   ```bash
   ssh root@nl-pve01 "pct stop 101000000"
   # or for VM:
   ssh root@nl-pve01 "qm stop 201000000"
   ```

3. **Restore backup**
   ```bash
   ssh root@nl-pve01 "cp /var/lib/vz/backup/config-backups/lxc/101000000_20250117_143022.conf /etc/pve/lxc/101000000.conf"
   ```

4. **Start the LXC/VM**
   ```bash
   ssh root@nl-pve01 "pct start 101000000"
   ```

5. **Update GitLab repo** to match the restored config
   ```bash
   scp root@nl-pve01:/etc/pve/lxc/101000000.conf pve/nl-pve01/lxc/101000000.conf
   git add pve/nl-pve01/lxc/101000000.conf
   git commit -m "Rollback LXC 101000000 to previous config"
   git push
   ```

## Troubleshooting

### Validation Fails

**Issue:** Configuration validation fails

**Solutions:**
- Check syntax errors in the config file
- Ensure required fields are present (arch, ostype for LXC; memory for VMs)
- Verify VMID exists on the target host
- Check SSH connectivity to Proxmox host

### Deployment Fails to Start

**Issue:** VM/LXC won't start after config change

**What happens:**
- Pipeline automatically rolls back to previous config
- Attempts to start with old config
- Reports failure in job output

**Solutions:**
- Review the configuration changes
- Check Proxmox task log: `Datacenter → Task History`
- Verify hardware references (disks, networks) exist
- Check resource availability (memory, storage)

### Connection Timeout

**Issue:** Cannot connect to Proxmox host

**Solutions:**
- Verify hostname resolution: `ping nl-pve01`
- Check SSH key is correctly encoded in `.ssh/one_key.b64`
- Ensure Proxmox host accepts SSH key auth
- Check firewall rules on Proxmox host

### Backup Directory Full

**Issue:** Backup directory running out of space

**Solutions:**
- Reduce `KEEP_BACKUPS_DAYS` variable
- Manually clean old backups:
  ```bash
  ssh root@nl-pve01 "find /var/lib/vz/backup/config-backups -type f -mtime +7 -delete"
  ```
- Schedule cleanup job more frequently
- Use different backup location with more space

## Best Practices

### 1. Test in Development First

- Create a dev Proxmox environment
- Test configuration changes there first
- Use the same pipeline structure

### 2. Small, Incremental Changes

- Make one config change at a time
- Easier to identify issues
- Faster rollback if needed

### 3. Descriptive Commit Messages

Good examples:
```
✅ Increase memory for LXC 101000000 from 2GB to 4GB
✅ Add additional network interface to VM 201000000
✅ Update CPU cores for LXC 101020203 to 4 cores
```

### 4. Review Configuration Diffs

Always review the diff shown in the validation stage:
- Understand what's changing
- Verify no accidental changes
- Check for typos

### 5. Monitor After Deployment

- Check services are running properly
- Review logs for any issues
- Verify connectivity to VM/LXC

### 6. Regular Backup Cleanup

- Schedule cleanup job weekly
- Monitor backup directory size
- Keep backups for critical systems longer

## Advanced Configuration

### Custom Validation Rules

Add custom checks in the validation stage:

```yaml
# Add to validate_proxmox_configs script section
# Check for specific naming conventions
if ! echo "$file" | grep -qE 'pve/[a-z0-9]+/'; then
  echo "❌ Invalid naming convention"
  exit 1
fi

# Validate memory allocation
if [ "$TYPE" = "lxc" ]; then
  MEMORY=$(grep "^memory:" "$TEMP_CONFIG" | cut -d' ' -f2)
  if [ "$MEMORY" -lt 512 ]; then
    echo "⚠️  Warning: Memory less than 512MB"
  fi
fi
```

### Notifications

Add Slack/Discord notifications:

```yaml
# Add to end of deploy_proxmox_configs script
curl -X POST -H 'Content-type: application/json' \
  --data "{\"text\":\"✅ Deployed $TYPE/$VMID on $HOSTNAME\"}" \
  $SLACK_WEBHOOK_URL
```

### Pre-deployment Snapshots

For VMs (not LXC), take snapshots before deployment:

```yaml
# Add before config replacement
if [ "$TYPE" = "qemu" ]; then
  echo "Creating pre-deployment snapshot..."
  qm snapshot $VMID "pre-deploy-$(date +%Y%m%d_%H%M%S)"
fi
```

## Security Considerations

1. **SSH Key Protection**
   - Use read-only deploy keys where possible
   - Rotate keys regularly
   - Base64 encoding is not encryption - consider using GitLab CI/CD variables with masking

2. **Access Control**
   - Limit who can approve deployments
   - Use protected branches
   - Enable merge request approvals

3. **Audit Trail**
   - All changes tracked in Git
   - Pipeline logs retained
   - Backup timestamps for forensics

## Integration with AWX

Your setup already uses AWX. You can trigger this pipeline from AWX playbooks:

```yaml
# AWX Playbook example
- name: Trigger GitLab pipeline for Proxmox configs
  uri:
    url: "https://gitlab.example.net/api/v4/projects/{{ project_id }}/trigger/pipeline"
    method: POST
    body_format: json
    body:
      token: "{{ gitlab_trigger_token }}"
      ref: "main"
    status_code: 201
```

## Monitoring and Metrics

Consider tracking:
- Deployment success rate
- Average deployment time
- Number of rollbacks
- Backup storage usage
- Configuration changes per week

Use GitLab CI/CD Analytics or integrate with Prometheus/Grafana.

## Support

For issues or questions:
1. Check pipeline job logs
2. Review Proxmox task history
3. Check this documentation
4. Review GitLab CI/CD documentation

## License

Internal use only - Nuclearlighters Infrastructure