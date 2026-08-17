# =============================================================================
# NL site values — terraform.tfvars
# The mirror-diff asserts this file and GR's carry the SAME KEY SET;
# only the values differ. Secrets stay in the Atlantis TF_VAR_* env
# (k8s_*, openbao_ca_cert, REDACTED_b6136a28, argocd_matrix_token,
# gatus_twilio_*, REDACTED_6177f7df/password) — do NOT add them
# here: tfvars values OVERRIDE env vars.
# =============================================================================

# --- site identity ---
site             = "nl"
site_code        = "nl"
remote_site_code = "gr"
node_region      = "nl-lei"
repository_label = "REDACTED_25022d4e"

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
  "k8s-app" = "metrics-server"
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
twilio_bridge_url      = "http://10.0.X.X:9106/alert"
tg_webhook_url         = "https://territory-grounder.example.net/api/v1/ingest/prometheus-alertmanager"
wal_healer_webhook_url = "" # not wired on NL

# --- scrape targets (NL Prometheus scrapes the whole estate) ---
estate_scrape_enabled = true
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
REDACTED_fd3fdc21 = "50Gi"

# --- prometheus remote-write (IFRNLLEI01PRD-2403 hub/satellite) ---
prometheus_remote_write_url = "" # NL is a hub, not a satellite
# DELIBERATE NL live change: arm the receiver so notrf01 can remote_write
# into NL's Prometheus (the one intended plan delta of the Phase-3 prep).
REDACTED_923cce14 = true

# --- logging ---
loki_s3_bucket        = "loki"
REDACTED_337e6630 = "10.0.X.X"

# --- seaweedfs ---
REDACTED_a8217c41 = "1000Gi"
REDACTED_4bbaa453 = true # NL runs the single bidirectional filer.sync
# Stale-checkpoint recovery floors (2026-05-05 incident) — see the flag-semantics
# comment block on the seaweedfs module call in main.tf.
REDACTED_d063ac2f = 1777991510258 # b->a recovery floor (GR->NL)
REDACTED_88d37e0b = 1777991510258 # a->b recovery floor (NL->GR)

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
awx_enabled                = true
REDACTED_0b348a0e   = "projects" # asymmetric by history — live NFS dir name
awx_ingress_enabled        = false      # NL reaches AWX via NodePort/NPM
REDACTED_4c1f6c62 = "REDACTED_b280aec5"
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
REDACTED_2636fc38 = ""

# Basic-auth for the Gatus Edge HAProxy stats checks
haproxy_stats_auth = "REDACTED_38a2053f"

# -----------------------------------------------------------------------------
# Gatus -> Twilio SMS (IFRNLLEI01PRD-802 replacement for the disabled GitLab
# pipeline path).
#
# Variable values come from TF_VAR_gatus_twilio_* env vars on the Atlantis
# runner (loaded via env_file: /srv/atlantis/twilio.env). They are NOT set
# here because tfvars OVERRIDE env vars (precedence: tfvars > TF_VAR_* env).
# Default values in variables.tf are empty strings; with no tfvars override,
# env vars apply, locals.twilio_enabled = true, gatus-twilio Secret is
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
