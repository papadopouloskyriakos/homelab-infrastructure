# Shared DB Cluster — Galera MariaDB + ProxySQL (nl)

The estate's shared relational database layer: a 2-node MariaDB Galera cluster + arbitrator,
fronted by two ProxySQL instances. **This is shared infrastructure, not a Nextcloud-internal
component** — consumers as of 2026-08-28:

| Consumer | Schema(s) | Docs |
|----------|-----------|------|
| Nextcloud (NCHA) | `nextcloud` | [`../ncha/CLAUDE.md`](../ncha/CLAUDE.md) (full 9-layer architecture; this cluster was its "Layer 4" until split out) |
| paperless | `paperless` | — |
| CiviCRM | `civicrm` | `docker/nlcivicrm01/civicrm/CLAUDE.md` (onboarding required cluster-wide settings — see below) + `native/civicrm/CLAUDE.md` (its nightly dump is that app's real backup) |
| healthops | `healthops` | uses native VECTOR (the reason for the 11.8 LTS upgrade) |

**Onboarding a new app? Read the CiviCRM settings section below first** — the cluster runs
single-writer with Galera auto-increment striding DISABLED, and that combination is
load-bearing for data integrity.

```
apps ──► proxysql.example.net:6033  (DNS RR .152 + .154, both ACTIVE — no standby)
              │
    ┌─────────┴─────────┐
    ▼                   ▼
 nlproxysql01   nlproxysql02     (ProxySQL 3.0.10, Docker, single-writer HGs)
    └─────────┬─────────┘
              ▼
 Galera "eu-nl-mariadb01" (MariaDB 11.8.8)
   ├─ nlcl01mariadb01  .150  (pve04)
   ├─ nlcl01mariadb02  .151  (pve03)  ← current single writer
   └─ nlcl01garbd01    .153  (pve01)  ← arbitrator, quorum vote only
```

## Host Inventory

| Host | VMID | PVE | IP | Role |
|------|------|-----|-----|------|
| nlproxysql01 | 101101004 | nl-pve01 | 10.0.X.X | ProxySQL 3.0.10. Port 6033. Docker. Monitor user: `monitor`. 64MB query cache. Upgraded 2.7.2→3.0.10 2026-08-01. |
| nlproxysql02 | 101101008 | nl-pve03 | 10.0.X.X | ProxySQL 3.0.10. Identical config. |
| nlcl01mariadb01 | 101101002 | nlpve04 | 10.0.X.X | MariaDB 11.8.8 Galera. Synced, Primary. **InnoDB buffer pool 1536M** (the "128MB" in older docs has been wrong since the 2026-03-20 tuning). Upgraded 11.6.2→11.8.8 LTS 2026-08-01 (native VECTOR for healthops); CT lives on pve04, not pve01 as older docs said. |
| nlcl01mariadb02 | 101101006 | nl-pve03 | 10.0.X.X | MariaDB 11.8.8 Galera. Synced, Primary. InnoDB buffer pool 1536M. Upgraded 2026-08-01. |
| nlcl01garbd01 | 101101007 | **nl-pve01** | 10.0.X.X | Galera Arbitrator (quorum voter, no data). galera-arbitrator-4 **26.4.27**, upgraded from Debian's 26.4.23 on 2026-08-01 — it had been left behind by the DB upgrade. The MariaDB 11.8 apt repo had to be added to this container; Debian bookworm only ships 26.4.23. ⚠ Runs on **pve01**, verified live 2026-08-28 — this line said pve02, which has been powered off since 2026-08-25; had that been true the cluster would have had no tiebreaker. ⚠ **Not backed up**: vmid 101101007 appears only in the Tue 03:00 vzdump job, which is node-pinned to the powered-off pve02 and therefore never runs. Stateless and rebuildable, but the job is dead. |

**DNS:** `proxysql.example.net` → RR 10.0.X.X + .154 (apps connect here directly, NOT via HAProxy)
**Galera cluster:** `eu-nl-mariadb01`, `gcomm://10.0.X.X,10.0.X.X,10.0.X.X`, SST method: rsync

## SSH Access

All five hosts are LXCs reachable directly:

```bash
ssh -i ~/.ssh/one_key root@10.0.X.X   # mariadb01
ssh -i ~/.ssh/one_key root@10.0.X.X   # mariadb02
ssh -i ~/.ssh/one_key root@10.0.X.X   # garbd01
ssh -i ~/.ssh/one_key root@10.0.X.X   # proxysql01
ssh -i ~/.ssh/one_key root@10.0.X.X   # proxysql02
```

## ⚠ ProxySQL runs SINGLE-WRITER since 2026-08-01

`mysql_galera_hostgroups.max_writers` was
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

## ProxySQL lives in TWO trees — this split is permanent

- **`docker/nlproxysql01/` + `docker/nlproxysql02/`** — the deployable compose
  projects (rsync + `docker compose up` pipeline; the `docker/<hostname>/<service>/` path
  convention is pipeline-bound, so these can never move here). Also run `dolphie` monitoring.
- **`native/dbcluster/nlproxysql0*/proxysql/`** (this directory) — snapshots of the
  mounted bootstrap `proxysql.cnf` **and `runtime-config.sql`, the only git copy of the
  SQLite runtime state** (see Config snapshots below).

Both proxies are ACTIVE behind DNS RR and apps connect to both *directly*. There is no
standby. HAProxy does expose a `proxysql_servers` backend on :6034 with proxysql01 primary /
proxysql02 backup — **Nextcloud does not use that path**, so do not reason about ProxySQL
failover from the HAProxy config. Consequence: restarting one proxy drops roughly half of
*new* connection attempts, so never deploy both at once — push one `docker/nlproxysql0*/`
change per commit.

## Config snapshots (added 2026-08-28)

Because none of this layer has a deploy pipeline and none of it was in git, the live configs are
snapshotted here — **reference copies only, nothing applies them automatically**:

```
native/dbcluster/nlcl01mariadb01/mariadb/{my.cnf,conf.d/*.cnf,mariadb.conf.d/*.cnf}
native/dbcluster/nlcl01mariadb02/mariadb/{...}                    # identical file set
native/dbcluster/nlproxysql01/proxysql/proxysql.cnf               # the mounted bootstrap file
native/dbcluster/nlproxysql01/proxysql/runtime-config.sql         # replayable dump of the SQLite state
native/dbcluster/nlproxysql02/proxysql/{...}
native/dbcluster/nlcl01garbd01/garbd/default-garb                 # /etc/default/garb — GALERA_GROUP/GALERA_NODES
native/dbcluster/nlcl01garbd01/garbd/garbd.service                # /etc/systemd/system/garbd.service (custom unit, SIGINT kill)
native/dbcluster/nlcl01garbd01/garbd/mariadb.sources              # /etc/apt/sources.list.d/ — the 11.8 repo garbd 26.4.27 comes from
```

`runtime-config.sql` is the important one: it carries `mysql_servers`, `mysql_users`,
`mysql_query_rules` and `mysql_galera_hostgroups` as INSERTs plus the LOAD/SAVE lines. Without
it, a rebuild of either proxysql LXC loses the hostgroup topology and every query rule silently.
Re-snapshot after any :6032 change — `device is source of truth` applies here as everywhere in
`native/`.

## ⚠ CiviCRM added three cluster-wide MariaDB settings (2026-08-28)

`mariadb.conf.d/99-civicrm.cnf` on **both** Galera nodes — see
`docker/nlcivicrm01/civicrm/CLAUDE.md` for the full reasoning:

| Setting | Why |
|---|---|
| `log_bin_trust_function_creators = 1` | `wsrep_on=ON` counts as binary logging, so `CREATE TRIGGER` as a non-SUPER user raises `ER_1419` **even though `log_bin=OFF`**. CiviCRM creates 26 triggers. |
| `wsrep_auto_increment_control = OFF`<br>`auto_increment_increment = 1`<br>`auto_increment_offset = 1` | CiviCRM requires `auto_increment_increment=1`. Galera sets it to the cluster size and the override **cannot be scoped to a session or a user** — global was the only lever. |

🚨 **The second one makes `max_writers=1` load-bearing for data integrity, not just for the
certification-conflict reason above.** Galera's auto-increment striding is what makes concurrent
multi-writer inserts safe, and it is now disabled. **Never raise `max_writers` above 1 without
first reverting `wsrep_auto_increment_control`.**

Measured on this cluster 2026-08-28, in a throwaway schema: 100 concurrent inserts fired at each
node simultaneously gave **26 × `ERROR 1062 Duplicate entry for key 'PRIMARY'`**, 2 × deadlock,
`wsrep_local_cert_failures` +61/+23, and **172 of 200 rows landed — 28 lost**. Sequential
alternating inserts did not collide (each replicates before the next), so this only bites under
real concurrency. Writes are rejected with errors, not silently corrupted.

The guard is self-healing — a manual `OFFLINE_SOFT` on `.151` in `mysql_servers` was reverted by
the Galera checker within seconds. ⚠ But it **persisted in the config table** while runtime
reverted, so it would have applied on the next ProxySQL restart. After any manual server edit,
re-check `mysql_servers`, not just `runtime_mysql_servers`.

All consumers share this cluster and are subject to all three settings. None of them alter
existing data or query behaviour; they relax creation-time restrictions and change ID stride.

## MariaDB config file layout — read this before editing any `.cnf`

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

## Removed ClusterControl accounts (2026-08-01)

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

## Failure Domains

**⚠ The single writer (mariadb02) and the sole reader-capable peer both sit on pve03.** Since
2026-08-01 ProxySQL routes all writes to mariadb02 on pve03, which already hosts nc02,
proxysql02, haproxy02, file02 and gpu01. Losing pve03 costs the write path as well as half the
NCHA HA cluster — ProxySQL would promote mariadb01 (pve04) out of HG 30 automatically, but the
blast radius of a pve03 failure is larger than older docs implied. garbd01 on pve01 is the
quorum tiebreaker; losing pve01 leaves mariadb01+mariadb02 with 2/3 quorum (fine), but losing
pve01 **and** either DB node partitions the survivor into non-Primary.

## Troubleshooting

### Database connection errors
**Check ProxySQL:** `docker exec proxysql mysql -h127.0.0.1 -P6032 -uradmin -pradmin -e "SELECT * FROM runtime_mysql_servers;"`
**Check Galera:** `mysql -e "SHOW STATUS LIKE 'wsrep_cluster_size';"` (should be 3)
**Check DNS:** `dig proxysql.example.net` (should return .152 + .154)

**Testing which node a write lands on:** `SELECT @@hostname` alone is misleading — query rule 2
routes `^SELECT` to the reader hostgroup, so it reports a *reader*. Wrap it to pin the session
to the writer: `BEGIN; SELECT @@hostname; COMMIT;` (rule 1 matches `^BEGIN` → HG 10, and
`transaction_persistent=1` keeps it there).

### Galera write conflicts / `SQLSTATE[40001]` in app logs
Serialization failures are the app-visible face of Galera certification conflicts. Check
`wsrep_local_replays`, `wsrep_local_bf_aborts` and `wsrep_local_cert_failures` — if they are
*climbing*, writes are reaching more than one node. Verify `max_writers=1` in
`runtime_mysql_galera_hostgroups` on **both** proxies (they must agree, or you still have two
writers cluster-wide). Fixed 2026-08-01; the counters have been flat since.
