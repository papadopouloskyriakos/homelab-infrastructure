# =============================================================================
# NL site values — terraform.tfvars
# The mirror-diff asserts this file and GR's carry the SAME KEY SET;
# only the values differ. Secrets stay in the Atlantis TF_VAR_* env
# (k8s_*, openbao_ca_cert, REDACTED_b6136a28, argocd_matrix_token,
# gatus_ntfy_*, REDACTED_6177f7df/password) — do NOT add them
# here: tfvars values OVERRIDE env vars.
# =============================================================================

# --- site identity ---
site             = "nl"
site_code        = "nl"
remote_site_code = "gr"
node_region      = "nl-lei"
repository_label = "REDACTED_25022d4e"

# --- node failure domains (node-zones.tf) ---
# Empty = this site's failure-domain topology has not been surveyed, so no node
# carries topology.kubernetes.io/zone and kube-scheduler treats the whole
# cluster as ONE zone: every topology spread constraint in it is a no-op. That
# is a gap to close, not a setting. See variables.tf and k8s/node-zones.tf.
node_zones      = {}
node_zone_basis = ""

# --- cluster identity ---
cluster_name = "nlcl01k8s"
cluster_id   = 1
k8s_api_host = "api-k8s.example.net"
pod_cidr     = "10.0.0.0/16"

# --- clustermesh (remote = GR) ---
clustermesh_enabled             = true
clustermesh_remote_cluster_name = "grcl01k8s"
REDACTED_9b1272d3     = "10.0.X.X:2379"

# --- cilium BGP / MTU ---
cilium_bgp_enabled   = true
cilium_mtu           = 1350
REDACTED_08cea5a5 = "10.0.X.X"
cilium_lb_pool_stop  = "10.0.X.X"
cilium_peer_address  = "10.0.X.X"

# --- NFS ---
nfs_enabled       = true
nfs_server        = "10.0.X.X"
nfs_path          = "/volume1/k8s"
archive_on_delete = false # live SC parameter (immutable)

# --- storage classes (Synology CSI — see site-storage.tf) ---
storage_class_retain       = "REDACTED_b280aec5"
storage_class_delete       = "REDACTED_4f3da73d"
REDACTED_cdb3d821   = "REDACTED_4f3da73d"
alertmanager_storage_class = "REDACTED_4f3da73d"
thanos_storage_class       = "REDACTED_4f3da73d"
loki_storage_class         = "REDACTED_4f3da73d"

# --- external-secrets / cert-manager role gates ---
eso_auth_mount_path = "kubernetes"
acme_issuer_enabled = true # NL is the ACME-issuing site
install_crds        = false

# --- gitlab agent ---
gitlab_agent_name  = "k8s-agent"
gitlab_kas_address = "wss://gitlab.example.net/-/kubernetes-agent/"

# --- PDBs ---
metrics_server_selector = {
  "app.kubernetes.io/name" = "metrics-server"
}

# --- service hostnames ---
hubble_hostname           = "nl-hubble.example.net"
dashboard_hostname        = "nl-k8s.example.net"
argocd_hostname           = "argocd.example.net"
awx_hostname              = "awx.example.net"
prometheus_hostname       = "nl-prometheus.example.net"
grafana_hostname          = "grafana.example.net"
goldpinger_hostname       = "goldpinger.example.net"
REDACTED_928c2d3a     = "nl-thanos.example.net"
seaweedfs_master_hostname = "nl-seaweedfs.example.net"
s3_hostname               = "nl-s3.example.net"
gatus_hostname            = "nl-gatus.example.net"

# --- alerting / webhooks ---
alert_webhook_url      = "https://n8n.example.net/webhook/prometheus-alert"
paging_bridge_url      = "http://10.0.X.X:9106/alert"
tg_webhook_url         = "https://territory-grounder.example.net/api/v1/ingest/prometheus-alertmanager"
wal_healer_webhook_url = "" # not wired on NL

# --- scrape targets (NL Prometheus scrapes the whole estate) ---
estate_scrape_enabled = true
bgpalerter_enabled    = true
asa_snmp_enabled      = true
snmp_asa_target       = "10.0.X.X"
snmp_asa_device       = "nlfw01"
etcd_endpoints        = ["10.0.X.X", "10.0.X.X", "10.0.X.X"]
frr_route_reflector_targets = [
  "10.0.X.X:9342", # NL-FRR01 (DMZ)
  "10.0.X.X:9342", # NL-FRR02 (DMZ)
  "10.0.X.X:9342",  # GR-FRR01 (DMZ)
  "10.0.X.X:9342",  # GR-FRR02 (DMZ)
]
frr_edge_targets = [
  "10.255.2.11:9342", # CH Edge
  "10.255.3.11:9342", # NO Edge
  "10.255.6.11:9342", # TX Edge
]
ipsec_edge_targets = [
  "10.255.2.11:9536", # CH Edge
  "10.255.3.11:9536", # NO Edge
  "10.255.6.11:9536", # TX Edge
]

# --- thanos cross-site identity (remote = GR) ---
thanos_bucket_name             = "thanos-nl"
REDACTED_52f9638b          = true
thanos_remote_store_endpoint   = "dnssrv+_grpc._tcp.thanos-store-gr.monitoring.svc.cluster.local"
REDACTED_d312035b = "dnssrv+_grpc._tcp.thanos-sidecar-gr.monitoring.svc.cluster.local"

# --- monitoring storage sizes (immutable live StatefulSet templates) ---
alertmanager_storage_size     = "10Gi"
thanos_store_storage_size     = "20Gi"
REDACTED_fd3fdc21 = "100Gi" # 50 -> 100 2026-09-15: the compactor halted 13 Sep on ENOSPC of its own PV and retention stopped (IFRNLLEI01PRD-2850)
# NL: dedicated Synology CSI volumes - unchanged, these are the historical defaults.
thanos_retention_raw      = "7d" # 14d -> 7d 2026-09-15 (IFRNLLEI01PRD-2850, owner decision): 434 GB logical and the store at 95%; 5m keeps 120d, 1h 365d
thanos_retention_5m       = "120d"
thanos_retention_1h       = "365d"
loki_retention_days       = 14   # 30 -> 14 2026-09-15 (IFRNLLEI01PRD-2850, owner decision)
thanos_delete_delay       = "2h" # 48h -> 2h 2026-09-10 (IFRNLLEI01PRD-2831): 84 expired blocks were waiting 48h to be deleted while the compactor wrote new ones, eating the vacuum's reclaim on a 96%-full S3; NO already runs 2h
REDACTED_bf135212 = 1    # 0 -> 1 2026-09-21 (IFRNLLEI01PRD-2850): the 09-15 park was never undone and nl-s3 filled again in six days; REDACTED_8fdc9a1c now pages on a park longer than 12h

# --- prometheus remote-write (IFRNLLEI01PRD-2403 hub/satellite) ---
prometheus_remote_write_url = "" # NL is a hub, not a satellite
# DELIBERATE NL live change: arm the receiver so notrf01 can remote_write
# into NL's Prometheus (the one intended plan delta of the Phase-3 prep).
REDACTED_923cce14 = true

# --- logging ---
loki_s3_bucket        = "loki"
REDACTED_337e6630 = "10.0.X.X"

# --- seaweedfs ---
REDACTED_a8217c41    = "1000Gi"
REDACTED_323fe643 = 200  # 50 -> 200 2026-09-15: vacuum reclaimed 2 GiB per 10 min against 120 GiB of garbage (IFRNLLEI01PRD-2850)
REDACTED_6db9426a   = 8000 # chart default 1000 made 1.8 TiB into 2778 volumes; new volumes seal at 8 GB (IFRNLLEI01PRD-2850)
REDACTED_d36a9dce     = 1800 # 1400 -> 1800 2026-09-15: 22 slots left of 2800 (IFRNLLEI01PRD-2850); minFreeSpacePercent stays the disk guard
# Floor history: 5 -> 3 -> 2 on 2026-09-10 (IFRNLLEI01PRD-2831) and 2 -> 1 -> 0.5 on 2026-09-21
# (IFRNLLEI01PRD-2850), each time so writes and vacuum could resume on a full store; back to 5 the
# evening of 09-21 at ~20 % free. 5 % (~53 GB) is the standing reserve: it must exceed one full
# 8 GB volume + idx so compaction always has room (an explicit -volumeId vacuum digs out even
# below it). A value below 5 is an emergency override and must carry an expiry (plan Phase 7).
REDACTED_6930756b = 5 # module off since 2026-09-25 (seaweedfs_enabled = false); back at the 5 % reserve so the tfvars lint has nothing to register
# Staged 4.44 rollout (IFRNLLEI01PRD-2605): NO first, then NL, then GR.
seaweedfs_enabled       = false # RETIRED 2026-09-25 (IFRNLLEI01PRD-2887 Plan A): the store, its LUNs and the SeaweedFS alerts/checks are gone; every consumer uses the crypt gateway
REDACTED_0e952fda  = false # CNPG operator + janitor stay, but no clusters since the filer-meta ones left with SeaweedFS (2026-09-25): CnpgMetricsMissing would be permanent
REDACTED_c1342204 = "4.44.0"
REDACTED_a4f42897 = "4.44"
# Filer metadata store (IFRNLLEI01PRD-2605): flip to "postgres2" at this
# site's cutover, AFTER filer_meta_db_enabled has applied and the CNPG
# cluster is healthy. Barman goes CROSS-SITE (never into the S3 it serves).
seaweedfs_filer_store                = "postgres2"
seaweedfs_filer_meta_db_enabled      = true
REDACTED_8bee20b3 = "http://backup-gateway.backup-gateway.svc.cluster.local:8080" # crypt gateway -> Hetzner since 2026-09-23 (IFRNLLEI01PRD-2850); was the other site's SeaweedFS
REDACTED_0bd01d17   = "filer-meta-nl"
REDACTED_b3642cef         = "https://nl-s3.example.net"
REDACTED_4bbaa453        = true # NL runs the single bidirectional filer.sync
# Stale-checkpoint recovery floors (2026-05-05 incident) — see the flag-semantics
# comment block on the seaweedfs module call in main.tf.
REDACTED_d063ac2f = 1787516819348 # 2605 cutover floor (store re-init resets change-log offsets)
REDACTED_88d37e0b = 1787516819348 # 2605 cutover floor

# --- argocd ---
REDACTED_7ce225ce       = 2
argocd_repo_server_replicas  = 2
REDACTED_035cbec1 = true
REDACTED_2f84acaa   = "[ArgoCD]"
REDACTED_9360424f = {
  "gitlab-repo-creds" = {
    openbao_path = "REDACTED_79b33008"
  }
}

# --- awx ---
awx_enabled                  = true
cnpg_enabled                 = true
REDACTED_6b820d0e = true
REDACTED_0b348a0e     = "projects" # asymmetric by history — live NFS dir name
awx_ingress_enabled          = false      # NL reaches AWX via NodePort/NPM
REDACTED_4c1f6c62   = "REDACTED_b280aec5"
# Static/imported postgres PV (CSI migration 2024-11-27) — pins the claim
# to the existing Synology-CSI PV. Empty on GR (operator provisions).
REDACTED_28b716ba = "REDACTED_c7d87e23"

# --- gatus ---
site_name                    = "Netherlands"
timezone                     = "Europe/Amsterdam"
REDACTED_9246ffd6    = 35
REDACTED_1c1562d0 = 4
gatus_tls_secret_name        = "gatus-tls" # NL issues its own ACME cert

# --- openebs localpv (notrf01 site-storage module — unused at NL, key-set parity) ---
REDACTED_afff1a35 = "4.5.1"
REDACTED_8553de03     = "/var/openebs/local"

# --- credentials kept in tfvars (private repo — intentional) ---
snmp_community = "xK9mQ2vL8nR4pT6w"

# Gatus alerting webhook — disabled 2026-04-28 after fourth pipeline storm in 5 weeks.
# Empty token gates the entire alerting block + per-endpoint alerts entries off
# (see namespaces/gatus/main.tf). Status page now relies on the 5-min schedule
# plus client-side /api/mesh-stats and /api/service-health polling. See
# kyriakos/AUDIT-2026-04-28.md for the post-mortem.

# Basic-auth for the Gatus Edge HAProxy stats checks
haproxy_stats_auth = "REDACTED_38a2053f"

# -----------------------------------------------------------------------------
# Gatus -> Twilio SMS (IFRNLLEI01PRD-802 replacement for the disabled GitLab
# pipeline path).
#
# Variable values come from TF_VAR_gatus_ntfy_* env vars on the Atlantis
# runner (loaded via env_file: /srv/atlantis/ntfy.env). They are NOT set
# here because tfvars OVERRIDE env vars (precedence: tfvars > TF_VAR_* env).
# Default values in variables.tf are empty strings; with no tfvars override,
# env vars apply, locals.ntfy_enabled = true, gatus-ntfy Secret is
# created, and Gatus's custom alerting provider routes to Twilio.
# -----------------------------------------------------------------------------

# --- primary PVC sizes (explicit = the historical defaults; keys exist for the
# --- 3-way tfvars key-set parity with the small-disk notrf01 site, YT-2403) ---
REDACTED_6a2724e6 = "200Gi"
grafana_storage_size    = "20Gi"
loki_storage_size       = "100Gi"

# --- cilium device overrides (loopback-node-IP sites only; "" = auto) ---
cilium_devices               = ""
REDACTED_9c9808e4 = ""

# --- LB-IPAM (assignment) + SPIRE storage (3-way parity keys) ---
cilium_lb_ipam_enabled = true
spire_storage_class    = "nfs-client"

# --- grafana storage/replicas + node-exporter port (3-way parity; NL keeps defaults) ---
grafana_storage_class = "nfs-client"
grafana_replicas      = 2
node_exporter_port    = 9100

ingress_csp_header  = "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' wss:; frame-ancestors 'self' https://matrix.example.net vector://vector; base-uri 'self'; form-action 'self';"
snmp_syno_target    = "10.0.X.X"
snmp_syno_community = "uBnr@W9dKOu#7ifTdVbAi!k$=XKr9X"

# This site's PVE hosts (native pve-exporter :9221 + node_exporter :9100) —
# per-site scraping since 2026-08-26 (was: NL estate job for all 5 hosts).
pve_hosts = [
  { instance = "nl-pve01", ip = "10.0.X.X" },
  { instance = "nl-pve03", ip = "10.0.X.X" },
  { instance = "nlpve04", ip = "10.0.X.X" },
]

# --- seaweedfs reclaim + storage-pinning (site values, 2026-09-20) ---
REDACTED_4c9c3cf5 = "0.10" # measured: 142/1558 volumes already clear it
# Below-standard settings must be registered here with an end date (lint + REDACTED_8e8e28d2).
temporary_overrides = {} # the seaweedfs floor override ended with the store (2026-09-25)

REDACTED_fd6d5350 = { # bulkhead, 2026-09-21 (IFRNLLEI01PRD-2850); both excluded from filer.sync
  "thanos-nl" = 409600         # 400 GiB: 232 GB live at the time, raw 7d + 5m 120d + 1h 365d, + compaction burst
  "loki"      = 153600         # 150 GiB: 64 GB live, 14 d retention now actually running
}
seaweedfs_vacuum_schedule        = "17 * * * *" # hourly seaweedfs-reconciler (IFRNLLEI01PRD-2850)
REDACTED_5741a7a4 = false        # network-attached iSCSI: pods reschedule

# --- log-based alerting + node floor (site values, 2026-09-20) ---
loki_ruler_enabled            = true  # NL is the estate alerting hub; had none before
node_root_floor_alert_enabled = false # gpu01 already at 19.8% free: 0.22 would fire at birth
node_root_floor_threshold     = "0.22"

# --- ingress WAF + internal CA (site values, 2026-09-20) ---
REDACTED_f03c8bab = "DetectionOnly" # backend-only ingress; ModSecurity already truncated a 2 GB restore here
REDACTED_14740f3f = ""
internal_ca_enabled     = false # no meshsat-hub NATS consumer

# --- kyverno admission policy (site values, 2026-09-20) ---
kyverno_enabled               = true  # AUDIT-ONLY here
REDACTED_a1145f93 = false # cosign policy is notrf01-only (Enforce)

# --- backup gateway: rclone crypt -> Hetzner Object Storage fsn1 (site values, 2026-09-23, IFRNLLEI01PRD-2850) ---
REDACTED_b987a401            = true # NL hub: velero/thanos/loki/filer-meta consumers
REDACTED_2eab95fd           = 2
REDACTED_ff855352 = ["velero", "monitoring", "logging", "awx"] # awx: nightly pg_dump via the gateway since 2026-09-25 (IFRNLLEI01PRD-2887)
REDACTED_ea08c35b = false                                      # no host-level consumer on NL

# --- off-estate object storage cut-over (site values, 2026-09-23, IFRNLLEI01PRD-2850) ---
thanos_s3_endpoint                        = "backup-gateway.backup-gateway.svc.cluster.local:8080" # was seaweedfs-s3:8333; history NOT copied (3-week hole already, dashboards only)
thanos_s3_secret_path                     = "REDACTED_218b2888"
loki_s3_endpoint                          = "backup-gateway.backup-gateway.svc.cluster.local:8080" # `s3` store = gateway from the cut-over day
loki_s3_secret_path                       = "REDACTED_218b2888"
REDACTED_7ad49fe3        = "access_key"
loki_s3_secret_secret_key_property        = "secret_key"
REDACTED_e934fd5d                   = "backup-gateway.backup-gateway.svc.cluster.local:8080" # `legacy` store repointed at the gateway 2026-09-25 (operator: pre-cut-over chunks on SeaweedFS not needed); the first schema period is never removed
REDACTED_6512c9a2                = "REDACTED_218b2888"
REDACTED_573a99be = "access_key"
REDACTED_bfd705f5 = "secret_key"
REDACTED_a2a6f208                      = "2026-09-24"

# 2026-09-25 (2): no-op line so Atlantis applies the Velero cadence rule merged before its apply (IFRNLLEI01PRD-2887)
