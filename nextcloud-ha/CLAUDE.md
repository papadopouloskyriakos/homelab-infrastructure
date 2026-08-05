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
| nlnpm01 | 101100401 | nl-pve01 | 10.0.X.X | OpenResty 1.27.1. Proxies nextcloud.example.net to HAProxy. ~98 proxy configs total. |
| grnpm01 | — | gr-pve01 | 10.0.X.X | GR site entry point (DNS RR partner) |

### Layer 2: Load Balancer (HAProxy, Docker)

| Host | VMID | PVE | IP | Role |
|------|------|-----|-----|------|
| nlhaproxy01 | 101100402 | nl-pve01 | 10.0.X.X | HAProxy 3.3.5. Frontends: HTTPS(:443), Redis(:6380), ProxySQL(:6034), Collabora(:9980), Stats(:8404). nlnc01=PRIMARY. |
| nlhaproxy02 | 103101007 | nl-pve03 | 10.0.X.X | HAProxy 3.3.5. Same frontends, nlnc02=PRIMARY (cross-site failover). |

**HAProxy backends:**
- `nextcloud_servers` — nlnc01(.148) PRIMARY, nlnc02(.149) BACKUP. Old nextcloud01(.20)/nextcloud02(.120) still listed but STOPPED — should be removed.
- `proxysql_servers` — proxysql01(.152) PRIMARY, proxysql02(.154) BACKUP
- `redis_servers` — redis03(.125) PRIMARY, redis01(.123)+redis02(.124) BACKUP. **Note:** HAProxy uses TCP PING, can't detect Redis master. Actual master is redis02.
- `collabora_backend` — code01(.126) only

### Layer 3: Nextcloud Application (Native Apache + PHP)

| Host | VMID | PVE | IPs | Version |
|------|------|-----|-----|---------|
| nlnc01 | 101101206 | nl-pve01 | 10.0.X.X, 10.0.X.X | Nextcloud **33.0.7**, PHP **8.4.24**, Apache 2.4.58 |
| nlnc02 | 103101201 | nl-pve03 | 10.0.X.X, 10.0.X.X | Nextcloud **33.0.7**, PHP **8.4.24**, Apache 2.4.58 |

#### Upgrade status (2026-08-05: 32.0.6 → 32.0.13 → 33.0.7 DONE, IFRNLLEI01PRD-2235)

The EOL-driven chain ran in one window 2026-08-05 ~02:30–04:00 CEST. Next major is 34.0.2 —
no deadline pressure, schedule normally. Lessons that WILL bite the next upgrade:

- **Run the updater from a node with a healthy NFS client.** The 32 run from nc01 crawled
  ~45 min in the code-integrity check because nc01's NFSv4 state-manager thread
  (`[10.0.X.X-manager]`) had been stuck since file01's Aug-2 weekly NFS restart
  (`check lease failed ... error 13` in nc01 dmesg). Diagnostic signature: updater at ~1–2%
  CPU, `head -2 /proc/<pid>/stack` shows `nfs4_wait_clnt_recover`, while fresh processes on
  the same mount are fast. That is a wedged *client*, not slow storage. Fix = kill the
  updater chain, resume `occ upgrade` from the other node (shared code dir makes this safe),
  reboot the wedged node.
- **Restart php8.4-fpm + apache2 on BOTH nodes after the code swap.** OPcache keeps executing
  the OLD version's opcodes against the new code — nc02 returned HTTP 500 on every request
  until restarted.
- **A major disables incompatible apps silently mid-run** (33 disabled 9, incl. spreed,
  richdocuments, groupfolders, files_accesscontrol). `occ app:update --all` afterwards pulls
  compatible builds and re-enables them. Grep the updater output for `Disabled incompatible
  app:`. Note 7 apps (encryption, facerecognition, support, survey_client, suspicious_login,
  tasks, user_status) are disabled *by design* — don't "fix" them.
- **The updater can leave `loglevel => 0` (debug)** despite printing "Resetting log level" —
  check config.php afterwards; fix with `occ config:system:set loglevel --value=2 --type=integer`.
- Pretty URLs are NOT configured (`htaccess.RewriteBase` absent, always been so): bare
  `/login` 404s; `/` → `index.php/login` is the working entry path. Not upgrade damage.

#### OS patching (apt) — use AWX, never bare `apt upgrade` by hand

**⚠ php.ini symlink quirk:** on nc01/nc02 the SAPI configs are symlinks to one tuned file —
`/etc/php/<ver>/{apache2,fpm,phpdbg}/php.ini` → `/etc/php/<ver>/cli/php.ini` (the only
regular file, the source of truth). PHP package upgrades treat the SAPI paths as conffiles
and write **through the symlink**, clobbering `cli/php.ini`. A bare `apt upgrade` touching
any `php8.x-*` package destroys the tuning.

Use **AWX job template 51 "Nextcloud Weekly Update"**
(`common/production/ansible/playbooks/nextcloud/weekly_update.yaml`, also on a weekly
schedule): pre-flight asserts `cli/php.ini` is a regular file → removes the symlinks before
`apt full-upgrade` → recreates + asserts them after → restarts FPM/Apache → reboots — and
refuses to reboot if the symlink assertions fail. Nodes are done **serially** with per-node
LibreNMS maintenance, so OS patching IS rolling (the shared-OCFS2 no-rolling constraint
applies only to the Nextcloud code dir, not the OS). Verified worked 2026-08-05 (job 34099).

**🔴 THE APP TIER CANNOT BE ROLLING-UPGRADED.** `/var/www/nextcloud` is a **shared** NFSv4.2
mount of `10.0.X.X:/mnt/ocfs2/nextcloud/nextcloud-app` on **both** nc01 and nc02 — they
execute the *same files*, and both report the same version because there is only one copy. So:

- You upgrade **once**, not per node. Do not try to "do nc01 first".
- `maintenance:mode --on` takes the **entire service** down; HAProxy is left with no healthy
  backend in `nextcloud_servers`. This is a full outage window, not a failover.
- The nc01/nc02 pair gives you redundancy against *host* failure, **not** against an upgrade.

Prerequisites verified OK 2026-08-01: built-in `updater/` present, PHP 8.4.24, 3.6 TB free on the
app and data volumes, DB schema clean (`occ setupchecks` database section all green,
`needsDbUpgrade: false`).

**Back up explicitly first — do not rely on the existing chain.** Velero produced its first clean
backup on record only on 2026-07-30 and *"prove a restore"* is still an open item (see root
`CLAUDE.md`), and the app directory lives on the same DRBD/OCFS2 cluster as the data it would
restore from. Take a `mysqldump` of the `nextcloud` schema plus a copy of `config/` before
starting.

**Key config (config.php):**
- `datadirectory` → `/mnt/nextcloud-data` (NFS from nlcl01file01)
- `dbhost` → `proxysql.example.net:6033`
- `dbname` → `nextcloud`, `dbuser` → `nextcloud`
- `redis.host` → `redis.example.net`, `redis.port` → `6380`
- `memcache.local` → APCu, `memcache.distributed` + `memcache.locking` → Redis
- `REDACTED_08e8170a` → `http://nlimaginary01.example.net:9000`
- `facerecognition.external_model_url` → `10.0.X.X:5000` (nlgpu01)
- `trusted_proxies` → nlhaproxy01(.140), nlhaproxy02(.158), nlnpm01(.43), grnpm01(10.0.X.X)
- `ldapProviderFactory` → `OCA\User_LDAP\LDAPProviderFactory`
- Apache ProxyPass: `/exapps/context_chat_backend/` → nlgpu01:24002, `/exapps/llm2/` → nlgpu01:24003, `/exapps/text2image_stablediffusion2/` → nlgpu01:24004
- PHP-FPM on 127.0.0.1:9000

**NFS mounts (both nlnc01 and nlnc02, VLAN 88):**
- `10.0.X.X:/mnt/ocfs2/nextcloud/nextcloud-app` → `/var/www/nextcloud` (NFSv4.2, nconnect=8)
- `10.0.X.X:/mnt/ocfs2/nextcloud/nextcloud-data` → `/mnt/nextcloud-data` (NFSv4.2, nconnect=8)
- `10.0.X.X:/volume1/homes` → `/mnt/homes` (NFSv4.1, nconnect=8)
- `10.0.X.X:/volume1/Media` → `/mnt/Media` (NFSv4.1, nconnect=8)

### Layer 4: Database (Galera MariaDB + ProxySQL)

| Host | VMID | PVE | IP | Role |
|------|------|-----|-----|------|
| nlproxysql01 | 101101004 | nl-pve01 | 10.0.X.X | ProxySQL 3.0.10. Port 6033. Docker. Monitor user: `monitor`. 64MB query cache. Upgraded 2.7.2→3.0.10 2026-08-01. |
| nlproxysql02 | 101101008 | nl-pve03 | 10.0.X.X | ProxySQL 3.0.10. Identical config. |
| nlcl01mariadb01 | 101101002 | nlpve04 | 10.0.X.X | MariaDB 11.8.8 Galera. Synced, Primary. **InnoDB buffer pool 1536M** (the "128MB" in older docs has been wrong since the 2026-03-20 tuning). Upgraded 11.6.2→11.8.8 LTS 2026-08-01 (native VECTOR for healthops); CT lives on pve04, not pve01 as older docs said. |
| nlcl01mariadb02 | 101101006 | nl-pve03 | 10.0.X.X | MariaDB 11.8.8 Galera. Synced, Primary. InnoDB buffer pool 1536M. Upgraded 2026-08-01. |
| nlcl01garbd01 | 101101007 | nl-pve02 | 10.0.X.X | Galera Arbitrator (quorum voter, no data). galera-arbitrator-4 **26.4.27**, upgraded from Debian's 26.4.23 on 2026-08-01 — it had been left behind by the DB upgrade. The MariaDB 11.8 apt repo had to be added to this container; Debian bookworm only ships 26.4.23. |

**⚠ ProxySQL runs SINGLE-WRITER since 2026-08-01.** `mysql_galera_hostgroups.max_writers` was
`2`, so both ProxySQL instances sent writes to both Galera nodes — the classic multi-writer
anti-pattern. It was measurably costing us: 15h of uptime produced `wsrep_local_replays` 470/78,
`wsrep_local_bf_aborts` 616/280, and the app-visible symptom was 15 `SQLSTATE[40001]`
serialization failures in `nextcloud.log`. With `max_writers=1` all of those counters went
**completely flat**. Current placement (identical on both proxies):

- **HG 10 (writer)** — mariadb02 (.151) ONLINE. mariadb01 (.150) shows `SHUNNED` here; that is
  ProxySQL's *intentional demotion*, not a health failure — confirm via
  `mysql_server_galera_log` (both nodes read `primary_partition=YES, wsrep_desync=NO,
  wsrep_local_state=4`).
- **HG 30 (backup writer)** — mariadb01 (.150).
- **HG 20 (reader)** — both nodes, weight 100 each (`writer_is_also_reader=1`).

Do **not** set a higher `weight` on the preferred writer in HG 10: with
`writer_is_also_reader=1` that weight is copied into the reader hostgroup and skews reads
10:1 onto the same node. Equal weights already select the writer deterministically.

Config lives in ProxySQL's SQLite DB (`/srv/proxysql/proxysql_data/proxysql.db`), **not** in the
mounted `proxysql.cnf` — that file is only read on first init. Change it via the admin
interface on :6032 then `LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;`.

**DNS:** `proxysql.example.net` → RR 10.0.X.X + .154 (Nextcloud connects here directly, NOT via HAProxy)
**Galera cluster:** `eu-nl-mariadb01`, `gcomm://10.0.X.X,10.0.X.X,10.0.X.X`, SST method: rsync

#### MariaDB config file layout — read this before editing any `.cnf`

`/etc/mysql/my.cnf` includes `conf.d/` **first**, then `mariadb.conf.d/`, and **last definition
wins**. Settings are duplicated across both trees, so the file you edit may not be the one that
takes effect:

| Setting | `conf.d/phpmyadmin_advisor.cnf` | `mariadb.conf.d/50-server.cnf` | Effective |
|---|---|---|---|
| `innodb_flush_log_at_trx_commit` | 1 | 2 | **2** |
| `innodb_log_buffer_size` | 128M | 32M | **32M** |
| `long_query_time` | 2 | 1 | **1** |

`phpmyadmin_advisor.cnf` and `mysql_tuner.cnf` are **tool-generated advice files** that someone
pasted in wholesale — they are the source of most of the surprises here, including
`table_open_cache` and the now-removed directives below. Treat them as suspect.

Cleaned up 2026-08-01 (both nodes, no restart needed — the removed ones were already no-ops):
- **Removed, silently ignored by 11.8:** `innodb_thread_concurrency`,
  `innodb_buffer_pool_instances` (was defined *twice*), deprecated `innodb_file_per_table`
  (default is ON anyway).
- **Tuned:** `table_open_cache` 400→2000 and `table_definition_cache` 400→2000 (there are ~500
  tables across all schemas; overflows were 590/708), `innodb_ft_cache_size` 8MB→64MB
  (`healthops.chunks` FTS working set is ~18MB and was forcing flushes).
- `innodb_ft_cache_size` **is dynamic in 11.8** despite older docs calling it read-only —
  `SET GLOBAL` works, so none of this needed a rolling restart.
- Backups of the originals: `/root/mysql-cfg-backups/` on each node. Note `.cnf.bak-*` files are
  safely ignored by `!includedir`, which only reads names ending in `.cnf` — but they were moved
  out of the config dirs anyway. Validate any change with `mariadbd --verbose --help >/dev/null`
  before restarting.

#### Removed ClusterControl accounts (2026-08-01)

The estate used to run ClusterControl (Severalnines); the controller is gone and its IP
(10.0.X.X) has since been **recycled to an unrelated host**, but its grants were still in
the DB. Removed: `cmon@clustercontrol` (unusable — `skip_name_resolve=1` means a hostname grant
can never match, and it logged "entry ignored" at every startup) plus **`cmon@%` and
`cmon@10.0.X.X`, both `ALL PRIVILEGES ON *.* WITH GRANT OPTION`** — a wildcard-host
superuser on a server bound to `0.0.0.0`. `performance_schema.users` showed zero connections for
`cmon` across 15h on both nodes before removal.

**`cmonexporter@localhost/127.0.0.1/::1` MUST STAY** — same ClusterControl origin, but
`mysqld_exporter` still runs on both DB nodes using it to feed Prometheus. The tool left; its
agent didn't. Check `ps aux | grep mysqld_exporter` before touching anything named `cmon*`.

### Layer 5: Cache (Redis Sentinel)

| Host | VMID | PVE | IP | Role |
|------|------|-----|-----|------|
| nlredis01 | 102100402 | nl-pve01 | 10.0.X.X | Redis 8.6.1. Slave. Docker. |
| nlredis02 | 102100403 | nl-pve02 | 10.0.X.X | Redis 8.6.1. **Master**. Docker. |
| nlredis03 | 102100404 | nl-pve03 | 10.0.X.X | Redis 8.6.1. Slave. Docker. |

**DNS:** `redis.example.net` → RR 10.0.X.X + .158 (HAProxy, ports 6380→6379)
**Sentinel master:** `mymaster` at redis02 (10.0.X.X:6379). 3 sentinels, quorum=2.
**Note:** Nextcloud connects via HAProxy TCP proxy (:6380), not directly via Sentinel. HAProxy can't detect master — uses PING/PONG health check only.

### Layer 6: Shared Storage (DRBD + OCFS2 + NFS)

| Host | VMID | PVE | IPs | Role |
|------|------|-----|-----|------|
| nlcl01file01 | VM | nl-pve01 | 10.0.X.X, 10.0.X.X, **VIP 10.0.X.X** | DRBD Primary + OCFS2 + **Active NFS server** (Pacemaker-managed). 3.7TB, 77GB used (3%). |
| nlcl01file02 | VM | nl-pve03 | 10.0.X.X, 10.0.X.X | DRBD Primary + OCFS2 mounted. NFS passive (Pacemaker failover target). |
| nlcl01filearb01 | VM | nl-nas01 | 10.0.X.X, 10.0.X.X | Corosync/Pacemaker quorum voter only. No DRBD disk. |

**Pacemaker cluster:** 3 nodes online, 7 resources. DRBD dual-Primary mode with OCFS2 (cluster filesystem).
**NFS floating IP:** 10.0.X.X (Pacemaker-managed, currently on nlcl01file01). Both nlnc01 and nlnc02 mount from this IP.
**NFS export:** `/mnt/ocfs2` to `*(rw,no_root_squash)`

**Note:** This storage cluster is shared with HAHA — see [`../haha/CLAUDE.md`](../haha/CLAUDE.md). HAHA mounts `/mnt/ocfs2/iot/`.

### Layer 7: Backend Services

| Host | VMID | PVE | IP | Service | Port |
|------|------|-----|-----|---------|------|
| nlcode01 | 101101205 | nl-pve01 | 10.0.X.X | Collabora CODE (Docker) | 9980 |
| nlcode02 | 103101008 | nl-pve03 | 10.0.X.X | Collabora CODE (Docker, backup) | 9980 |
| nlimaginary01 | 103101203 | nl-pve03 | 10.0.X.X | Imaginary image processing (Docker) | 9000 |
| nlwhiteboard01 | 103101202 | nl-pve03 | 10.0.X.X | Nextcloud Whiteboard (Docker) | — |
| nlhpb01 | 103101205 | nl-pve03 | 10.0.X.X | Talk HPB signaling (Docker). **QEMU VM, not an LXC** — use `qm`, not `pct` (`pct config 103101205` returns "config file does not exist" and sends you chasing a ghost). **Currently STOPPED with `onboot: 0`**, i.e. deliberately off, so `occ setupchecks` reports `✗ High-performance backend: Error: Server responded with: 502` and `signaling.example.net` (→ npm01 .43) 502s. Talk still works via internal signaling; STUN/TURN are separate (`stun.example.net:3478`). | 3478 (TURN), 8181 (signaling) |
| nlgpu01 | VM | nl-pve03 | 10.0.X.X | AI backends (Docker) | 5000 (facerecog), 24002 (chat), 24003 (LLM), 24004 (text2image) |

### Layer 8: Identity & DNS (FreeIPA)

| Host | VMID | PVE | IP | Role |
|------|------|-----|-----|------|
| nlfreeipa01 | 101100301 | nl-pve01 | 10.0.X.X | IPA 4.12.2. LDAP + Kerberos + DNS. Realm: `SEC.NUCLEARLIGHTERS.NET`. All 9 services running. |
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
| 88 | 10.0.X.X/24 | NFS storage traffic (dedicated, high throughput). nlnc01↔nlcl01file01, nlnc02↔nlcl01file01, nl-nas01. |

## DNS Records (FreeIPA-managed, critical for Nextcloud)

| Record | Resolves To | Purpose |
|--------|-------------|---------|
| `nextcloud.example.net` | .43 (npm01-NL) + 10.0.X.X (npm01-GR) | User entry point (RR) |
| `redis.example.net` | .140 (nlhaproxy01) + .158 (nlhaproxy02) | Redis via HAProxy:6380 (RR) |
| `proxysql.example.net` | .152 (proxysql01) + .154 (proxysql02) | DB via ProxySQL:6033 direct (RR) |
| `smtp.example.net` | .71 (NL) + 10.0.X.X (GR) | Outbound email (RR) |

## PVE Host Distribution (Failure Domains)

**nl-pve01 (10.0.X.X):** nlnpm01, nlhaproxy01, nlnc01, proxysql01, redis01, nlcl01file01, code01, nlfreeipa01
**nl-pve02 (10.0.X.X):** garbd01, redis02 — arbitrators only
**nl-pve03 (10.0.X.X):** nlhaproxy02, nlnc02, proxysql02, mariadb02, redis03, nlcl01file02, code02, imaginary01, whiteboard01, hpb01 (stopped), nlgpu01
**nlpve04:** **mariadb01** — migrated off pve01; the Layer 4 table has said pve04 for a while but this list still said pve01. Verify placement with `pve_list_lxc`/`pvesh get /cluster/resources`, never from the VMID prefix.

**⚠ The single writer (mariadb02) and the sole reader-capable peer both sit on pve03.** Since
2026-08-01 ProxySQL routes all writes to mariadb02 on pve03, which already hosts nc02,
proxysql02, haproxy02, file02 and gpu01. Losing pve03 now costs the write path as well as half
the HA cluster — ProxySQL would promote mariadb01 (pve04) out of HG 30 automatically, but the
blast radius of a pve03 failure is larger than this doc previously implied.

**Key risk:** nl-pve03 failure takes out half the HA cluster + ALL backend services (imaginary, whiteboard, hpb, gpu). nl-pve01 failure takes out the primary frontends + NFS server. nl-pve02 only has arbitrators — losing it doesn't cause outage but reduces quorum safety.

## Config Snapshots in This Directory

| Host | Service | Configs Tracked |
|------|---------|-----------------|
| nlnc01 | Nextcloud | apache/nextcloud.conf, apache/adminer.conf, php/php.ini, php/www.conf, nextcloud-config/config.php, nextcloud-config/redis_sentinel.config.php, fstab, crontabs |
| nlnc02 | Nextcloud | Same as nlnc01 (shared OCFS2 storage, identical app) |

## Troubleshooting Quick Reference

### Nextcloud shows Apache default page
**Cause:** NFS mounts not mounted. Check: `mount | grep nextcloud`. Fix: `mount -a` on the affected nlnc01/nlnc02.
**Known issue:** NFS mounts don't auto-recover after PVE host reboot if NFS server (nlcl01file01) isn't ready. Consider adding `_netdev,x-systemd.automount` to fstab.

### Nextcloud maintenance mode
**Check:** `sudo -u www-data php /var/www/nextcloud/occ maintenance:mode`
**Fix:** `sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off`

### Database connection errors
**Check ProxySQL:** `docker exec proxysql mysql -h127.0.0.1 -P6032 -uradmin -pradmin -e "SELECT * FROM runtime_mysql_servers;"`
**Check Galera:** `mysql -e "SHOW STATUS LIKE 'wsrep_cluster_size';"` (should be 3)
**Check DNS:** `dig proxysql.example.net` (should return .152 + .154)

**Both proxies are ACTIVE.** `proxysql.example.net` is a DNS round-robin over .152 and
.154 and Nextcloud connects to both *directly*. There is no standby. HAProxy does expose a
`proxysql_servers` backend on :6034 with proxysql01 primary / proxysql02 backup — **Nextcloud
does not use that path**, so do not reason about ProxySQL failover from the HAProxy config.
Consequence: restarting one proxy drops roughly half of *new* connection attempts, so never
deploy both at once — push one `docker/nlproxysql0*/` change per commit.

**Testing which node a write lands on:** `SELECT @@hostname` alone is misleading — query rule 2
routes `^SELECT` to the reader hostgroup, so it reports a *reader*. Wrap it to pin the session
to the writer: `BEGIN; SELECT @@hostname; COMMIT;` (rule 1 matches `^BEGIN` → HG 10, and
`transaction_persistent=1` keeps it there).

### Galera write conflicts / `SQLSTATE[40001]` in nextcloud.log
Serialization failures are the app-visible face of Galera certification conflicts. Check
`wsrep_local_replays`, `wsrep_local_bf_aborts` and `wsrep_local_cert_failures` — if they are
*climbing*, writes are reaching more than one node. Verify `max_writers=1` in
`runtime_mysql_galera_hostgroups` on **both** proxies (they must agree, or you still have two
writers cluster-wide). Fixed 2026-08-01; the counters have been flat since.

### `pct` says a guest's config file does not exist
It is probably a **QEMU VM**, not an LXC — use `qm config` / `qm status`. `nlhpb01`
(103101205) is the worked example. `pvesh get /cluster/resources --type vm` resolves both types
and the true node in one shot.

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
**NFS VIP:** 10.0.X.X should be on nlcl01file01. If nlcl01file01 is down, Pacemaker should failover to nlcl01file02.

### Collabora not loading documents
**Check:** `docker logs collabora` on code01 (nl-pve01, VMID 101101205)
**HAProxy:** only code01 in backend — no failover to code02 configured

### FreeIPA/LDAP auth failures
**Check:** `ssh nl-pve01 "pct exec 101100301 -- ipactl status"` (all 9 services should be RUNNING)
**Realm:** `SEC.NUCLEARLIGHTERS.NET`, Base DN: `dc=sec,dc=nuclearlighters,dc=net`

### Old/decommissioned Nextcloud instances (DO NOT USE)
- nlnextcloud01 (LXC 101101203, nl-pve01, .20) — **STOPPED**
- nlnextcloud02 (LXC 101101204, nl-pve03, .120) — **STOPPED**
Still referenced in HAProxy backends. Should be removed from HAProxy config.
