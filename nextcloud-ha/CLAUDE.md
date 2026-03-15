# Nextcloud HA Cluster (NCHA) — Complete Architecture

## Traffic Flow

```
INTERNET
    │
    ▼
DNS RR: nextcloud.example.net
    ├─ 10.0.X.X  (nlnpm01, NL)
    └─ 10.0.X.X   (grnpm01, GR)
    │
    ▼
NPM (Nginx Proxy Manager) — SSL termination, proxy to HAProxy
    │
    ▼
HAProxy (L7, active/backup, Docker)
    ├─ 10.0.X.X  haproxy01 (pve01) — nc01 PRIMARY, nc02 BACKUP
    └─ 10.0.X.X  haproxy02 (pve03) — nc02 PRIMARY, nc01 BACKUP (cross-site)
    │
    ├── :443  → Nextcloud frontends
    ├── :6380 → Redis (TCP passthrough)
    ├── :9980 → Collabora CODE
    └── :8404 → Stats dashboard
    │
    ▼
Nextcloud Frontends (Apache 2.4.58 + PHP 8.4.18 + PHP-FPM)
    ├─ 10.0.X.X  nc01 (QEMU, pve01) — PRIMARY
    └─ 10.0.X.X  nc02 (QEMU, pve03) — BACKUP
    │
    ├── DB  → proxysql.example.net:6033 (DNS RR, direct — not via HAProxy)
    ├── Cache → redis.example.net:6380 (DNS RR → HAProxy → Redis)
    ├── Files → NFS 10.0.X.X (file01 Pacemaker VIP, VLAN 88)
    ├── Media → NFS 10.0.X.X (syno01, VLAN 88)
    ├── Auth → FreeIPA LDAP (sec.example.net)
    ├── Preview → imaginary01:9000 (direct)
    ├── AI → gpu01:5000/24002/24003/24004 (direct, Apache ProxyPass)
    └── SMTP → smtp.example.net:25 (DNS RR)
```

## SSH Access

```bash
ssh -i ~/.ssh/one_key root@nlnc01
ssh -i ~/.ssh/one_key root@nlnc02
```

## Complete Host Inventory

### Layer 1: Entry Point (Nginx Proxy Manager)

| Host | VMID | PVE | IP | Role |
|------|------|-----|-----|------|
| nlnpm01 | 101100401 | pve01 | 10.0.X.X | OpenResty 1.27.1. Proxies nextcloud.example.net to HAProxy. ~98 proxy configs total. |
| grnpm01 | — | gr-pve01 | 10.0.X.X | GR site entry point (DNS RR partner) |

### Layer 2: Load Balancer (HAProxy, Docker)

| Host | VMID | PVE | IP | Role |
|------|------|-----|-----|------|
| nlhaproxy01 | 101100402 | pve01 | 10.0.X.X | HAProxy 3.3.5. Frontends: HTTPS(:443), Redis(:6380), ProxySQL(:6034), Collabora(:9980), Stats(:8404). nc01=PRIMARY. |
| nlhaproxy02 | 103101007 | pve03 | 10.0.X.X | HAProxy 3.3.5. Same frontends, nc02=PRIMARY (cross-site failover). |

**HAProxy backends:**
- `nextcloud_servers` — nc01(.148) PRIMARY, nc02(.149) BACKUP. Old nextcloud01(.20)/nextcloud02(.120) still listed but STOPPED — should be removed.
- `proxysql_servers` — proxysql01(.152) PRIMARY, proxysql02(.154) BACKUP
- `redis_servers` — redis03(.125) PRIMARY, redis01(.123)+redis02(.124) BACKUP. **Note:** HAProxy uses TCP PING, can't detect Redis master. Actual master is redis02.
- `collabora_backend` — code01(.126) only

### Layer 3: Nextcloud Application (Native Apache + PHP)

| Host | VMID | PVE | IPs | Version |
|------|------|-----|-----|---------|
| nlnc01 | 101101206 | pve01 | 10.0.X.X, 10.0.X.X | Nextcloud 32.0.6, PHP 8.4.18, Apache 2.4.58 |
| nlnc02 | 103101201 | pve03 | 10.0.X.X, 10.0.X.X | Nextcloud 32.0.6, PHP 8.4.18, Apache 2.4.58 |

**Key config (config.php):**
- `datadirectory` → `/mnt/nextcloud-data` (NFS from file01)
- `dbhost` → `proxysql.example.net:6033`
- `dbname` → `nextcloud`, `dbuser` → `nextcloud`
- `redis.host` → `redis.example.net`, `redis.port` → `6380`
- `memcache.local` → APCu, `memcache.distributed` + `memcache.locking` → Redis
- `REDACTED_08e8170a` → `http://nlimaginary01.example.net:9000`
- `facerecognition.external_model_url` → `10.0.X.X:5000` (gpu01)
- `trusted_proxies` → haproxy01(.140), haproxy02(.158), npm01(.43), grnpm01(10.0.X.X)
- `ldapProviderFactory` → `OCA\User_LDAP\LDAPProviderFactory`
- Apache ProxyPass: `/exapps/context_chat_backend/` → gpu01:24002, `/exapps/llm2/` → gpu01:24003, `/exapps/text2image_stablediffusion2/` → gpu01:24004
- PHP-FPM on 127.0.0.1:9000

**NFS mounts (both nc01 and nc02, VLAN 88):**
- `10.0.X.X:/mnt/ocfs2/nextcloud/nextcloud-app` → `/var/www/nextcloud` (NFSv4.2, nconnect=8)
- `10.0.X.X:/mnt/ocfs2/nextcloud/nextcloud-data` → `/mnt/nextcloud-data` (NFSv4.2, nconnect=8)
- `10.0.X.X:/volume1/homes` → `/mnt/homes` (NFSv4.1, nconnect=8)
- `10.0.X.X:/volume1/Media` → `/mnt/Media` (NFSv4.1, nconnect=8)

### Layer 4: Database (Galera MariaDB + ProxySQL)

| Host | VMID | PVE | IP | Role |
|------|------|-----|-----|------|
| nlproxysql01 | 101101004 | pve01 | 10.0.X.X | ProxySQL 2.7.2. Port 6033. Docker. Monitor user: `monitor`. 64MB query cache. |
| nlproxysql02 | 101101008 | pve03 | 10.0.X.X | ProxySQL 2.7.2. Identical config. |
| nlcl01mariadb01 | 101101002 | pve01 | 10.0.X.X | MariaDB 11.6.2 Galera. Synced, Primary. InnoDB buffer pool 128MB. |
| nlcl01mariadb02 | 101101006 | pve03 | 10.0.X.X | MariaDB 11.6.2 Galera. Synced, Primary. |
| nlcl01garbd01 | 101101007 | pve02 | 10.0.X.X | Galera Arbitrator (quorum voter, no data). |

**DNS:** `proxysql.example.net` → RR 10.0.X.X + .154 (Nextcloud connects here directly, NOT via HAProxy)
**Galera cluster:** `eu-nl-mariadb01`, `gcomm://10.0.X.X,10.0.X.X,10.0.X.X`, SST method: rsync

### Layer 5: Cache (Redis Sentinel)

| Host | VMID | PVE | IP | Role |
|------|------|-----|-----|------|
| nlredis01 | 102100402 | pve01 | 10.0.X.X | Redis 8.6.1. Slave. Docker. |
| nlredis02 | 102100403 | pve02 | 10.0.X.X | Redis 8.6.1. **Master**. Docker. |
| nlredis03 | 102100404 | pve03 | 10.0.X.X | Redis 8.6.1. Slave. Docker. |

**DNS:** `redis.example.net` → RR 10.0.X.X + .158 (HAProxy, ports 6380→6379)
**Sentinel master:** `mymaster` at redis02 (10.0.X.X:6379). 3 sentinels, quorum=2.
**Note:** Nextcloud connects via HAProxy TCP proxy (:6380), not directly via Sentinel. HAProxy can't detect master — uses PING/PONG health check only.

### Layer 6: Shared Storage (DRBD + OCFS2 + NFS)

| Host | VMID | PVE | IPs | Role |
|------|------|-----|-----|------|
| nlcl01file01 | VM | pve01 | 10.0.X.X, 10.0.X.X, **VIP 10.0.X.X** | DRBD Primary + OCFS2 + **Active NFS server** (Pacemaker-managed). 3.7TB, 77GB used (3%). |
| nlcl01file02 | VM | pve03 | 10.0.X.X, 10.0.X.X | DRBD Primary + OCFS2 mounted. NFS passive (Pacemaker failover target). |
| nlcl01filearb01 | VM | syno01 | 10.0.X.X, 10.0.X.X | Corosync/Pacemaker quorum voter only. No DRBD disk. |

**Pacemaker cluster:** 3 nodes online, 7 resources. DRBD dual-Primary mode with OCFS2 (cluster filesystem).
**NFS floating IP:** 10.0.X.X (Pacemaker-managed, currently on file01). Both nc01 and nc02 mount from this IP.
**NFS export:** `/mnt/ocfs2` to `*(rw,no_root_squash)`

**Note:** This storage cluster is shared with HAHA — see [`../haha/CLAUDE.md`](../haha/CLAUDE.md). HAHA mounts `/mnt/ocfs2/iot/`.

### Layer 7: Backend Services

| Host | VMID | PVE | IP | Service | Port |
|------|------|-----|-----|---------|------|
| nlcode01 | 101101205 | pve01 | 10.0.X.X | Collabora CODE (Docker) | 9980 |
| nlcode02 | 103101008 | pve03 | 10.0.X.X | Collabora CODE (Docker, backup) | 9980 |
| nlimaginary01 | 103101203 | pve03 | 10.0.X.X | Imaginary image processing (Docker) | 9000 |
| nlwhiteboard01 | 103101202 | pve03 | 10.0.X.X | Nextcloud Whiteboard (Docker) | — |
| nlhpb01 | 103101205 | pve03 | 10.0.X.X | Talk HPB signaling (Docker) | 3478 (TURN), 8181 (signaling) |
| nlgpu01 | VM | pve03 | 10.0.X.X | AI backends (Docker) | 5000 (facerecog), 24002 (chat), 24003 (LLM), 24004 (text2image) |

### Layer 8: Identity & DNS (FreeIPA)

| Host | VMID | PVE | IP | Role |
|------|------|-----|-----|------|
| nlfreeipa01 | 101100301 | pve01 | 10.0.X.X | IPA 4.12.2. LDAP + Kerberos + DNS. Realm: `SEC.NUCLEARLIGHTERS.NET`. All 9 services running. |
| grfreeipa01 | — | gr-pve01 | — | GR site replica. DNS RR partner + LDAP replication. |

**FreeIPA manages:** DNS records (nextcloud, redis, proxysql, smtp RR entries), LDAP auth for Nextcloud, Kerberos.

### Layer 9: NAS Storage

| Host | Type | IPs | Role |
|------|------|-----|------|
| nl-nas01 | DS1621+ (physical) | 10.0.X.X, **10.0.X.X** | NFS: `/volume1/homes`, `/volume1/Media`. Also DRBD arbitrator host for filearb01. |
| nlsyno02 | DS1513+ (physical) | 10.0.X.X | Secondary NAS. |

## VLANs

| VLAN | Subnet | Purpose |
|------|--------|---------|
| 10 | 10.0.X.X/24 | Management + service traffic (all hosts) |
| 88 | 10.0.X.X/24 | NFS storage traffic (dedicated, high throughput). nc01↔file01, nc02↔file01, syno01. |

## DNS Records (FreeIPA-managed, critical for Nextcloud)

| Record | Resolves To | Purpose |
|--------|-------------|---------|
| `nextcloud.example.net` | .43 (npm01-NL) + 10.0.X.X (npm01-GR) | User entry point (RR) |
| `redis.example.net` | .140 (haproxy01) + .158 (haproxy02) | Redis via HAProxy:6380 (RR) |
| `proxysql.example.net` | .152 (proxysql01) + .154 (proxysql02) | DB via ProxySQL:6033 direct (RR) |
| `smtp.example.net` | .71 (NL) + 10.0.X.X (GR) | Outbound email (RR) |

## PVE Host Distribution (Failure Domains)

**pve01 (10.0.X.X):** npm01, haproxy01, nc01, proxysql01, mariadb01, redis01, file01, code01, freeipa01
**pve02 (10.0.X.X):** garbd01, redis02 — arbitrators only
**pve03 (10.0.X.X):** haproxy02, nc02, proxysql02, mariadb02, redis03, file02, code02, imaginary01, whiteboard01, hpb01, gpu01

**Key risk:** pve03 failure takes out half the HA cluster + ALL backend services (imaginary, whiteboard, hpb, gpu). pve01 failure takes out the primary frontends + NFS server. pve02 only has arbitrators — losing it doesn't cause outage but reduces quorum safety.

## Config Snapshots in This Directory

| Host | Service | Configs Tracked |
|------|---------|-----------------|
| nlnc01 | Nextcloud | apache/nextcloud.conf, apache/adminer.conf, php/php.ini, php/www.conf, nextcloud-config/config.php, nextcloud-config/redis_sentinel.config.php, fstab, crontabs |
| nlnc02 | Nextcloud | Same as nc01 (shared OCFS2 storage, identical app) |

## Troubleshooting Quick Reference

### Nextcloud shows Apache default page
**Cause:** NFS mounts not mounted. Check: `mount | grep nextcloud`. Fix: `mount -a` on the affected nc01/nc02.
**Known issue:** NFS mounts don't auto-recover after PVE host reboot if NFS server (file01) isn't ready. Consider adding `_netdev,x-systemd.automount` to fstab.

### Nextcloud maintenance mode
**Check:** `sudo -u www-data php /var/www/nextcloud/occ maintenance:mode`
**Fix:** `sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off`

### Database connection errors
**Check ProxySQL:** `docker exec proxysql mysql -h127.0.0.1 -P6032 -uradmin -pradmin -e "SELECT * FROM runtime_mysql_servers;"`
**Check Galera:** `mysql -e "SHOW STATUS LIKE 'wsrep_cluster_size';"` (should be 3)
**Check DNS:** `dig proxysql.example.net` (should return .152 + .154)

### Redis connection errors
**Check Sentinel:** `docker exec redis redis-cli -p 26379 sentinel master mymaster`
**Check current master:** `docker exec redis redis-cli info replication | grep role`
**Check DNS:** `dig redis.example.net` (should return .140 + .158 = HAProxy)
**Known issue:** HAProxy redis backend has redis03 as PRIMARY but actual Redis master may differ. HAProxy can't detect master — uses PING only.

### NFS/DRBD/OCFS2 issues
**Check DRBD:** `ssh -i ~/.ssh/one_key root@nlcl01file01 "cat /proc/drbd"` (should show UpToDate/UpToDate)
**Check OCFS2:** `ssh -i ~/.ssh/one_key root@nlcl01file01 "mount | grep ocfs2"`
**Check NFS exports:** `ssh -i ~/.ssh/one_key root@nlcl01file01 "exportfs -v"`
**Check Pacemaker:** `ssh -i ~/.ssh/one_key root@nlcl01file01 "crm status"`
**NFS VIP:** 10.0.X.X should be on file01. If file01 is down, Pacemaker should failover to file02.

### Collabora not loading documents
**Check:** `docker logs collabora` on code01 (pve01, VMID 101101205)
**HAProxy:** only code01 in backend — no failover to code02 configured

### FreeIPA/LDAP auth failures
**Check:** `ssh nl-pve01 "pct exec 101100301 -- ipactl status"` (all 9 services should be RUNNING)
**Realm:** `SEC.NUCLEARLIGHTERS.NET`, Base DN: `dc=sec,dc=nuclearlighters,dc=net`

### Old/decommissioned Nextcloud instances (DO NOT USE)
- nlnextcloud01 (LXC 101101203, pve01, .20) — **STOPPED**
- nlnextcloud02 (LXC 101101204, pve03, .120) — **STOPPED**
Still referenced in HAProxy backends. Should be removed from HAProxy config.
