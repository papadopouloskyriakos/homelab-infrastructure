# CLAUDE.md — Matrix Stack (nl-matrix01)

## Session Protocol

**At the start of every session**, read `PROJECT_STATE.md` to understand current state.
**At the end of every session** (or when significant changes are made), update:
1. `PROJECT_STATE.md` — reflect current state, recent changes, open issues
2. Memory files in `~/.claude/projects/-home-kyriakosp-gitlab-REDACTED_25022d4e/memory/` — if new persistent knowledge was learned

## Project Overview

Self-hosted **Matrix homeserver** stack for `matrix.example.net`, running on host `nl-matrix01` at `/srv/matrix/`. This git repo holds the config-as-code mirror. All containers use **host networking** and log to **syslog** (`udp://127.0.0.1:514`).

## Architecture

```
Internet → HAProxy (2 VPSes, BGP anycast) → nginx:443/6666 (TLS re-encryption)
  ├── mas.example.net      → MAS:9090 (all paths)
  └── matrix.example.net
      ├── auth (login/logout/refresh) → MAS:9090
      ├── /_matrix/push/v1/notify     → ntfy:8880
      ├── /ntfy/                       → ntfy:8880 (WebSocket)
      ├── /.well-known/*               → static JSON (includes rtc_foci for Element X)
      ├── /_matrix|/_synapse/*         → synapse:8008
      ├── /webhook/                    → hookshot:9000 (localhost only)
      ├── /bridge/                     → mm-bridge:9995 (DISABLED)
      ├── /admin                       → returns 404 (SSH tunnel only)
      └── /                            → element-web:8088
```

## Services

| Service | Image | Port | Status |
|---|---|---|---|
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
| matrix-commander | matrix-commander | — | tools profile only |
| matrix-bridge (MM) | custom Dockerfile | 9995 | DISABLED |
| crowdsec | native (not Docker) v1.7.6 | — | active on host |

## Key Accounts

| Account | Role | Admin | Type |
|---|---|---|---|
| @dominicus | Primary user | Yes | regular |
| @admin | Server admin | Yes | regular |
| @openclaw | Bot | No | bot |
| @claude | Bot | No | bot |
| @hookbot | Webhook bot | No | regular |
| @signalbot | Signal bridge bot | No | appservice |
| @whatsappbot | WhatsApp bridge bot | No | appservice |

## Databases (single Postgres instance)

| Database | User | Consumer |
|---|---|---|
| synapse | synapse (superuser) | Synapse homeserver |
| mas | mas | Matrix Authentication Service |
| mm-matrix-bridge | mm-matrix-bridge | Mattermost bridge (disabled) |
| mautrix_signal | mautrix_signal | Signal bridge |
| mautrix_whatsapp | mautrix_whatsapp | WhatsApp bridge |

## Bridges

Both bridges use the **megabridge v0.26+ config format** and require:
- `encryption.appservice: true` + `encryption.msc4190: true` for MAS compatibility
- `org.matrix.msc3202: true` + `org.matrix.msc4190: true` in registration files
- Commands: `!signal <cmd>` / `!wa <cmd>` (prefix required, not management rooms)
- Signal: ContactName → ProfileName → PhoneNumber display priority, contact avatar sync enabled
- WhatsApp: PushName → BusinessName → JID display priority, history backfill enabled

## Key Design Decisions

- **MAS** handles all auth via `matrix_REDACTED_6fa691d2_service` (not deprecated `msc3861`)
- **Cloudflare Turnstile** captcha on registration
- **Open registration** with mandatory email verification
- **Federation whitelisted** to `matrix.org` and `integrations.ems.host` only
- **Security headers** set at HAProxy edge (not nginx) to avoid duplicates
- **CSP frame-ancestors** allows Grafana embedding in Element
- **HAProxy timeout tunnel 3600s** for Matrix/Mattermost WebSockets
- **Memory limits** via `deploy.resources.limits.memory` (not `mem_limit`)
- **Element Web rebranded** via nginx `sub_filter` (title, OG tags for link previews)
- **VoIP**: Jitsi public STUN/TURN for 1:1 calls, meet.jit.si for conferences
- **Element X calling**: MatrixRTC via lk.element.dev (Element's hosted LiveKit SFU). Requires `msc3401_enabled: true` in Synapse and both `m.rtc_foci` (stable) + `org.matrix.msc4143.rtc_foci` (unstable) in well-known. Element X caches well-known aggressively — users must clear app cache after changes.
- **Sliding sync**: enabled natively in Synapse (v1.114+) + Element Web feature flag
- **Bot accounts** have `user_type: bot`, hidden from user directory
- **Authenticated media** intentionally disabled (`enable_authenticated_media: false`)
- **SMTP** via `10.0.X.X:25` (plain, no auth, no TLS)
- **TLS** via Let's Encrypt certs on host, mounted into nginx
- **Real IP** trusted from `10.255.0.0/16` and `10.0.X.X/27` (HAProxy)

## File Map

```
matrix/
├── .env                          # Pinned service versions
├── docker-compose.yml            # Stack definition (11 active + disabled services)
├── element-app/
│   ├── config.json               # Element Web config (Jitsi, sliding sync, branding)
│   ├── config.matrix.example.net.json  # Server-specific overrides
│   └── lake.jpg                  # Custom background (used as OG image)
├── element-nginx/
│   └── default.conf.template     # Element internal nginx :8088 (sub_filter branding)
├── mas-config/
│   └── config.yaml               # MAS auth config (secrets, captcha, signing keys)
├── matrix-hookshot/
│   ├── config.yml                # Hookshot: webhooks, feeds, encryption
│   └── registration.yml          # Hookshot appservice registration
├── mautrix-signal/
│   ├── config.yaml               # Signal bridge config (megabridge v0.26+ format)
│   └── registration.yaml         # Signal appservice registration (MSC3202+MSC4190)
├── mautrix-whatsapp/
│   ├── config.yaml               # WhatsApp bridge config (megabridge v0.26+ format)
│   └── registration.yaml         # WhatsApp appservice registration (MSC3202+MSC4190)
├── nginx-conf/
│   └── nginx.conf                # Main reverse proxy config (well-known with rtc_foci)
├── ntfy-etc/
│   └── server.yml                # UnifiedPush notification config
├── postgres-backup.sh            # Daily backup script (5 databases)
└── synapse-data/
    └── homeserver.yaml           # Synapse main config
```

## Deployment

Config is deployed via **GitLab CI/CD pipeline** (`ci/docker.yml`):
1. Commit to main (or MR → merge)
2. Pipeline: validate → deploy (rsync + docker compose pull/up) → verify
3. Webhook notifications sent to Matrix room with commit/status details

**Important**: `docker compose up -d` does NOT restart containers when bind-mounted files change. Use `docker compose restart <service>` after config-only changes.

**Important**: NEVER edit config files directly on the server — the pipeline uses rsync to deploy, so any direct server changes will be overwritten on the next deploy. Always commit changes to git and deploy via pipeline. Database changes (SQL) are safe since rsync only manages files.

**Important**: The `.env` file is NOT in `.rsyncignore` — pipeline deploys it. Add new version vars to both local `.env` and server `.env` when adding services.

## Secrets Present in Config

These files contain secrets — this is intentional for this infrastructure repo:
- `mas-config/config.yaml` — captcha secret, DB password, matrix secret, private keys
- `synapse-data/homeserver.yaml` — DB password, macaroon_secret, MAS shared secret
- `matrix-hookshot/registration.yml` — as_token, hs_token
- `mautrix-signal/config.yaml` — as_token, hs_token, DB password
- `mautrix-whatsapp/config.yaml` — as_token, hs_token, DB password
- `docker-compose.yml` — POSTGRES_PASSWORD

## Backups & Log Rotation

- **Postgres**: cron at 03:00 daily via `/srv/matrix/postgres-backup.sh`, dumps all 5 databases (synapse, mas, mm-matrix-bridge, mautrix_signal, mautrix_whatsapp) gzipped to `/srv/matrix/backups/`. Log: `/var/log/matrix-backup.log`
- **Nginx logs**: logrotate daily, 7-14 day retention, compressed, with `docker exec nginx nginx -s reopen` postrotate. Config: `/etc/logrotate.d/nginx-matrix`

## Common Tasks

```bash
# Deploy via pipeline (preferred — commit to main, pipeline auto-deploys)
git add ... && git commit -m "description" && git push origin main

# Manual restart after bind-mount config change
ssh root@nl-matrix01 'cd /srv/matrix && docker compose restart <service>'

# Check service health
ssh root@nl-matrix01 'docker ps --format "table {{.Names}}\t{{.Status}}"'

# Access synapse-admin (SSH tunnel)
ssh -L 8080:localhost:80 root@nl-matrix01
# Then browse http://localhost:8080

# Synapse admin API
ssh root@nl-matrix01 'curl -s -H "Authorization: Bearer <token>" http://localhost:8008/_synapse/admin/v2/users/<user>'

# Bridge commands (in DM with bot)
# !signal login    — link Signal account
# !wa login        — link WhatsApp account
```

## Port Reference

| Port | Service | Bind |
|---|---|---|
| 443 | nginx (TLS) | 0.0.0.0 |
| 5432 | postgres | 0.0.0.0 |
| 6379 | redis (hookshot) | 127.0.0.1 |
| 6666 | nginx (HAProxy backend) | 0.0.0.0 |
| 8008 | synapse | 0.0.0.0 |
| 8088 | element-web | 0.0.0.0 |
| 8880 | ntfy | 0.0.0.0 |
| 9000 | hookshot webhooks | 127.0.0.1 |
| 9001 | hookshot metrics | 127.0.0.1 |
| 9090 | MAS (web) | 0.0.0.0 |
| 9091 | MAS (admin) | 127.0.0.1 |
| 9993 | hookshot HS port | 127.0.0.1 |
| 29328 | mautrix-signal | 127.0.0.1 |
| 29329 | mautrix-whatsapp | 127.0.0.1 |
