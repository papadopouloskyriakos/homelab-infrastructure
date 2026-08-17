# =============================================================================
# Root Variables — CANONICAL FILE (byte-identical NL <-> GR, mirror campaign
# 2026-08-16). Union variable set: per-site values come from terraform.tfvars
# (same key set both repos, asserted by the mirror-diff) or from the Atlantis
# TF_VAR_* environment for secrets. Defaults are NL values where a safe
# default makes sense; tokens/CA have no defaults or empty-string "disabled"
# defaults (see each description).
# =============================================================================

# =============================================================================
# Kubernetes Connection (Atlantis env: TF_VAR_k8s_host / _k8s_token / _k8s_ca_cert)
# =============================================================================

variable "k8s_host" {
  description = "Kubernetes API server URL (env-fed; NL https://api-k8s.example.net:6443, GR https://gr-api-k8s.example.net:6443)"
  type        = string
}

variable "k8s_token" {
  description = "Service account token for K8s API"
  type        = string
  sensitive   = true
}

variable "k8s_ca_cert" {
  description = "Cluster CA certificate (base64 encoded)"
  type        = string
  sensitive   = true
}

# =============================================================================
# Site Identity
# =============================================================================

variable "site" {
  description = "Short site tag: \"nl\" or \"gr\". Used in common_labels and as gatus/argocd/monitoring site identity."
  type        = string
  default     = "nl"
}

variable "site_code" {
  description = "Long site code: \"nl\" or \"gr\". Used by thanos/seaweedfs cross-site identity and as monitoring's short cluster label."
  type        = string
  default     = "nl"
}

variable "remote_site_code" {
  description = "The OTHER site's long code (NL passes gr, GR passes nl)"
  type        = string
  default     = "gr"
}

variable "node_region" {
  description = "SeaweedFS/monitoring node region label: \"nl-lei\" or \"gr-skg\""
  type        = string
  default     = "nl-lei"
}

variable "repository_label" {
  description = "Value of the `repository` common label (REDACTED_25022d4e / infrastructure-gr-production)"
  type        = string
  default     = "REDACTED_25022d4e"
}

# =============================================================================
# Cluster Identity (Cilium)
# =============================================================================

variable "cluster_name" {
  description = "Full kubeadm/Cilium cluster name (nlcl01k8s / grcl01k8s)"
  type        = string
  default     = "nlcl01k8s"
}

variable "cluster_id" {
  description = "Cilium ClusterMesh cluster ID (NL 1, GR 2)"
  type        = number
  default     = 1
}

variable "k8s_api_host" {
  description = "K8s API FQDN for Cilium k8sServiceHost (api-k8s / gr-api-k8s .example.net)"
  type        = string
  default     = "api-k8s.example.net"
}

variable "pod_cidr" {
  description = "Pod CIDR — MUST NOT overlap between sites (NL 10.0.0.0/16, GR 10.1.0.0/16)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "clustermesh_remote_cluster_name" {
  description = "Remote cluster name for ClusterMesh (NL passes grcl01k8s, GR passes nlcl01k8s)"
  type        = string
  default     = "grcl01k8s"
}

variable "REDACTED_9b1272d3" {
  description = "Remote clustermesh-apiserver endpoint (NL -> GR 10.0.X.X:2379, GR -> NL 10.0.X.X:2379). Ignored when clustermesh_enabled = false (a standalone site passes \"\")."
  type        = string
  default     = "10.0.X.X:2379"
}

variable "clustermesh_enabled" {
  description = "Deploy the Cilium ClusterMesh apiserver + remote-cluster config (NL/GR true — meshed pair; a standalone third site starts false). false omits every clustermesh.* Helm value so the chart runs its standalone defaults."
  type        = bool
  default     = true
}

# =============================================================================
# Cilium BGP - LoadBalancer IP allocation and BGP peering
# =============================================================================

variable "REDACTED_08cea5a5" {
  description = "Start IP of Cilium LoadBalancer IP pool"
  type        = string
  default     = "10.0.X.X"
}

variable "cilium_lb_pool_stop" {
  description = "End IP of Cilium LoadBalancer IP pool"
  type        = string
  default     = "10.0.X.X"
}

variable "cilium_local_asn" {
  description = "Local BGP AS number for Kubernetes nodes (same both sites)"
  type        = number
  default     = 65001
}

variable "cilium_peer_asn" {
  description = "BGP peer AS number (ASA firewall; same both sites)"
  type        = number
  default     = 65000
}

variable "cilium_peer_address" {
  description = "BGP peer IP address (ASA firewall on K8s VLAN; NL 10.0.X.X, GR 10.0.X.X)"
  type        = string
  default     = "10.0.X.X"
}

variable "cilium_bgp_enabled" {
  description = "Deploy the Cilium BGP control plane objects (LB-IPAM pool, peer/cluster config, advertisement) and enable bgpControlPlane in Helm (NL/GR true — ASA peering; a site without a BGP peer passes false)."
  type        = bool
  default     = true
}

variable "cilium_mtu" {
  description = "Cilium MTU Helm value (NL/GR 1350 — VXLAN over the site LAN; notrf01 needs 1300 for the overlay path)"
  type        = number
  default     = 1350
}

# =============================================================================
# NFS Storage
# =============================================================================

variable "nfs_server" {
  description = "NFS server IP address (NL 10.0.X.X syno01, GR 10.0.X.X)"
  type        = string
  default     = "10.0.X.X"
}

variable "nfs_path" {
  description = "NFS export path (NL /volume1/k8s, GR /exports/nfs/k8s)"
  type        = string
  default     = "/volume1/k8s"
}

variable "archive_on_delete" {
  description = "nfs-client StorageClass archiveOnDelete parameter. IMMUTABLE on the live SC — NL false, GR true; do NOT \"align\"."
  type        = bool
  default     = false
}

variable "nfs_enabled" {
  description = "Deploy the nfs-provisioner module (NL/GR true — site NAS present; a site without NFS passes false and must supply non-NFS classes wherever nfs-client is used)."
  type        = bool
  default     = true
}

# =============================================================================
# Storage Classes (per-site CSI backend — see site-storage.tf)
# =============================================================================

variable "storage_class_retain" {
  description = "iSCSI Retain-policy class (NL REDACTED_b280aec5, GR iscsi-ssd-retain)"
  type        = string
  default     = "REDACTED_b280aec5"
}

variable "storage_class_delete" {
  description = "iSCSI Delete-policy class (NL REDACTED_4f3da73d, GR iscsi-ssd-delete)"
  type        = string
  default     = "REDACTED_4f3da73d"
}

variable "REDACTED_cdb3d821" {
  description = "Prometheus PVC class — IMMUTABLE StatefulSet template (NL ...-iscsi-delete, GR iscsi-ssd-retain); MUST match live"
  type        = string
  default     = "REDACTED_4f3da73d"
}

variable "alertmanager_storage_class" {
  description = "Alertmanager PVC class — IMMUTABLE StatefulSet template (NL ...-iscsi-delete, GR iscsi-ssd-retain); MUST match live"
  type        = string
  default     = "REDACTED_4f3da73d"
}

variable "thanos_storage_class" {
  description = "Thanos store/compactor PVC class — IMMUTABLE StatefulSet template; MUST match live"
  type        = string
  default     = "REDACTED_4f3da73d"
}

variable "loki_storage_class" {
  description = "Loki PVC class — IMMUTABLE (live PVC; flipping = STS replace). NL ...-iscsi-delete, GR iscsi-ssd-retain; do NOT \"align\"."
  type        = string
  default     = "REDACTED_4f3da73d"
}

# =============================================================================
# External Secrets / OpenBao
# =============================================================================

variable "openbao_address" {
  description = "OpenBao server address (same 5-node raft cluster from both sites)"
  type        = string
  default     = "https://openbao.example.net:8200"
}

variable "openbao_ca_cert" {
  description = "OpenBao CA certificate, base64-encoded PEM. NO default — Atlantis env must export TF_VAR_openbao_ca_cert on BOTH sites."
  type        = string
  sensitive   = true
}

variable "eso_auth_mount_path" {
  description = "OpenBao Kubernetes auth mount path for this cluster (NL kubernetes, GR kubernetes-gr)"
  type        = string
  default     = "kubernetes"
}

# =============================================================================
# Ingress NGINX
# =============================================================================

variable "REDACTED_af8c15ba" {
  description = "Default SSL certificate for ingress (namespace/secret-name; same value both sites)"
  type        = string
  default     = "REDACTED_f89271df"
}

# =============================================================================
# cert-manager role gates
# =============================================================================

variable "acme_issuer_enabled" {
  description = "ACME issuer + Certificate resources (NL true — the issuing site; GR false — consumes the NL wildcard via OpenBao). Also gates the gatus and well-known certificates."
  type        = bool
  default     = true
}

variable "install_crds" {
  description = "Let the cert-manager Helm release install CRDs (NL false — pre-installed; GR true)"
  type        = bool
  default     = false
}

# =============================================================================
# GitLab Agent
# =============================================================================

variable "REDACTED_b6136a28" {
  description = "GitLab Agent token. NO default (fail-closed) — Atlantis env must export TF_VAR_REDACTED_b6136a28 on BOTH sites (GR: renamed from TF_VAR_gitlab_agent_token, mirror campaign 2026-08-16)."
  type        = string
  sensitive   = true
}

variable "gitlab_agent_name" {
  description = "GitLab agent name (NL k8s-agent, GR gr-k8s-agent)"
  type        = string
  default     = "k8s-agent"
}

variable "gitlab_kas_address" {
  description = "GitLab KAS (Kubernetes Agent Server) address (NL gitlab., GR gr-gitlab.)"
  type        = string
  default     = "wss://gitlab.example.net/-/kubernetes-agent/"
}

# =============================================================================
# Pod Disruption Budgets
# =============================================================================

variable "metrics_server_selector" {
  description = "PDB selector match_labels for the metrics-server deployment. NL k8s-app=metrics-server; GR app.kubernetes.io/name=metrics-server."
  type        = map(string)
  default = {
    "k8s-app" = "metrics-server"
  }
}

# =============================================================================
# Service Hostnames (full FQDNs, per site — see terraform.tfvars)
# =============================================================================

variable "hubble_hostname" {
  description = "Hubble UI FQDN"
  type        = string
  default     = "nl-hubble.example.net"
}

variable "dashboard_hostname" {
  description = "Kubernetes Dashboard FQDN"
  type        = string
  default     = "nl-k8s.example.net"
}

variable "argocd_hostname" {
  description = "Argo CD FQDN (NL argocd., GR gr-argocd.)"
  type        = string
  default     = "argocd.example.net"
}

variable "awx_hostname" {
  description = "AWX web FQDN — REDACTED_db732a25 and (when enabled) the ingress host"
  type        = string
  default     = "awx.example.net"
}

variable "prometheus_hostname" {
  description = "Prometheus FQDN (feeds both the monitoring ingress and gatus checks)"
  type        = string
  default     = "nl-prometheus.example.net"
}

variable "grafana_hostname" {
  description = "Grafana FQDN (NL grafana., GR gr-grafana.)"
  type        = string
  default     = "grafana.example.net"
}

variable "goldpinger_hostname" {
  description = "Goldpinger FQDN"
  type        = string
  default     = "goldpinger.example.net"
}

variable "REDACTED_928c2d3a" {
  description = "Thanos Query FQDN"
  type        = string
  default     = "nl-thanos.example.net"
}

variable "seaweedfs_master_hostname" {
  description = "SeaweedFS master UI FQDN"
  type        = string
  default     = "nl-seaweedfs.example.net"
}

variable "s3_hostname" {
  description = "SeaweedFS S3 FQDN (NL nl-s3., GR gr-s3.)"
  type        = string
  default     = "nl-s3.example.net"
}

variable "gatus_hostname" {
  description = "Gatus status page FQDN"
  type        = string
  default     = "nl-gatus.example.net"
}

# =============================================================================
# Monitoring
# =============================================================================

variable "REDACTED_6a2724e6" {
  description = "Prometheus PVC size"
  type        = string
  default     = "200Gi"
}

variable "grafana_storage_size" {
  description = "Grafana PVC size"
  type        = string
  default     = "20Gi"
}

variable "snmp_community" {
  description = "SNMP community string for ASA firewalls (terraform.tfvars)"
  type        = string
  sensitive   = true
}

variable "alert_webhook_url" {
  description = "n8n Prometheus alert receiver webhook (NL .../prometheus-alert, GR .../prometheus-alert-gr)"
  type        = string
  default     = "https://n8n.example.net/webhook/prometheus-alert"
}

variable "twilio_bridge_url" {
  description = "Twilio SMS bridge URL for tier-1 paging (NL http://10.0.X.X:9106/alert, GR http://10.0.X.X:9106/alert). Feeds monitoring AND gatus."
  type        = string
  default     = "http://10.0.X.X:9106/alert"
}

variable "tg_webhook_url" {
  description = "TerritoryGrounder alert-ingest webhook. TG is a single NL-estate instance — GR passes \"\"."
  type        = string
  default     = "https://territory-grounder.example.net/api/v1/ingest/prometheus-alertmanager"
}

variable "wal_healer_webhook_url" {
  description = "n8n Prometheus WAL-healer webhook (NL \"\" — disabled; GR .../prometheus-wal-healer-gr)"
  type        = string
  default     = ""
}

variable "estate_scrape_enabled" {
  description = "Run the estate-wide scrape jobs (exactly ONE Prometheus may — NL true, GR false; see scrape-estate.tf)"
  type        = bool
  default     = true
}

variable "asa_snmp_enabled" {
  description = "Deploy the ASA SNMP exporter (config map, deployment, service, ServiceMonitor) and the snmp-asa scrape job (NL/GR true — one ASA per site; a site without an ASA passes false)."
  type        = bool
  default     = true
}

variable "snmp_asa_target" {
  description = "SNMP exporter target ASA (NL 10.0.X.X, GR 10.0.X.X)"
  type        = string
  default     = "10.0.X.X"
}

variable "snmp_asa_device" {
  description = "SNMP exporter device label (nlfw01 / grfw01)"
  type        = string
  default     = "nlfw01"
}

variable "etcd_endpoints" {
  description = "Control-plane node IPs for the kubeEtcd scrape (client port :2379, mTLS)"
  type        = list(string)
  default     = ["10.0.X.X", "10.0.X.X", "10.0.X.X"]
}

variable "frr_route_reflector_targets" {
  description = "FRR exporter targets for route reflector VMs (NL scrapes all four DMZ FRRs; GR only its own pair)"
  type        = list(string)
  default = [
    "10.0.X.X:9342", # NL-FRR01 (DMZ)
    "10.0.X.X:9342", # NL-FRR02 (DMZ)
    "10.0.X.X:9342",  # GR-FRR01 (DMZ)
    "10.0.X.X:9342",  # GR-FRR02 (DMZ)
  ]
}

variable "frr_edge_targets" {
  description = "FRR exporter targets for edge nodes (NL: CH/NO/TX; GR: CH/NO)"
  type        = list(string)
  default = [
    "10.255.2.11:9342", # CH Edge
    "10.255.3.11:9342", # NO Edge
    "10.255.6.11:9342", # TX Edge
  ]
}

variable "ipsec_edge_targets" {
  description = "IPsec exporter targets for edge nodes (NL: CH/NO/TX; GR: CH/NO)"
  type        = list(string)
  default = [
    "10.255.2.11:9536", # CH Edge
    "10.255.3.11:9536", # NO Edge
    "10.255.6.11:9536", # TX Edge
  ]
}

variable "thanos_bucket_name" {
  description = "Thanos S3 bucket (thanos-nl / thanos-gr)"
  type        = string
  default     = "thanos-nl"
}

variable "thanos_remote_store_endpoint" {
  description = "Remote site's thanos-store dnssrv endpoint (via ClusterMesh). Ignored when REDACTED_52f9638b = false."
  type        = string
  default     = "dnssrv+_grpc._tcp.thanos-store-gr.monitoring.svc.cluster.local"
}

variable "REDACTED_d312035b" {
  description = "Remote site's thanos-sidecar dnssrv endpoint (via ClusterMesh). Ignored when REDACTED_52f9638b = false."
  type        = string
  default     = "dnssrv+_grpc._tcp.thanos-sidecar-gr.monitoring.svc.cluster.local"
}

variable "REDACTED_52f9638b" {
  description = "Add the remote site's Thanos store + sidecar endpoints to Thanos Query (NL/GR true — cross-site federation via ClusterMesh; a site without ClusterMesh passes false and queries only its own components)."
  type        = bool
  default     = true
}

variable "alertmanager_storage_size" {
  description = "Alertmanager PVC size (StatefulSet volumeClaimTemplate — immutable live; keep matching the deployed value)"
  type        = string
  default     = "10Gi"
}

variable "thanos_store_storage_size" {
  description = "Thanos Store Gateway cache PVC size (StatefulSet volumeClaimTemplate — immutable live; keep matching the deployed value)"
  type        = string
  default     = "20Gi"
}

variable "REDACTED_fd3fdc21" {
  description = "Thanos Compactor working-dir PVC size (StatefulSet volumeClaimTemplate — immutable live; keep matching the deployed value)"
  type        = string
  default     = "50Gi"
}

variable "prometheus_remote_write_url" {
  description = "Prometheus remote_write target URL. \"\" (default) = no remoteWrite key rendered at all — today's NL/GR behavior. A satellite site (notrf01) sets its hub receiver URL here."
  type        = string
  default     = ""
}

variable "REDACTED_923cce14" {
  description = "Enable Prometheus's remote-write receiver endpoint (prometheusSpec.enableRemoteWriteReceiver). false (default) omits the key entirely — today's behavior; NL flips true to receive notrf01's remote_write stream."
  type        = bool
  default     = false
}

# =============================================================================
# Logging (Loki + Promtail)
# =============================================================================

variable "loki_storage_size" {
  description = "Loki WAL/cache PVC size"
  type        = string
  default     = "100Gi"
}

variable "loki_retention_days" {
  description = "Log retention in days"
  type        = number
  default     = 30
}

variable "loki_s3_endpoint" {
  description = "S3 endpoint for Loki S3 storage (cluster-local; same both sites)"
  type        = string
  default     = "seaweedfs-s3.seaweedfs.svc.cluster.local:8333"
}

variable "loki_s3_bucket" {
  description = "S3 bucket for Loki (NL loki, GR loki-gr)"
  type        = string
  default     = "loki"
}

variable "promtail_syslog_port" {
  description = "Promtail syslog receiver port"
  type        = number
  default     = 1514
}

variable "REDACTED_337e6630" {
  description = "LoadBalancer IP for Promtail syslog receiver (NL 10.0.X.X, GR 10.0.X.X)"
  type        = string
  default     = "10.0.X.X"
}

# =============================================================================
# SeaweedFS
# =============================================================================

variable "REDACTED_c1342204" {
  description = "SeaweedFS Helm chart version"
  type        = string
  default     = "4.0.401"
}

variable "REDACTED_a8217c41" {
  description = "Storage size per volume server (NL 1000Gi, GR 500Gi)"
  type        = string
  default     = "1000Gi"
}

# Operational lever — see namespaces/seaweedfs/variables.tf for the full rationale.
# Below this free-space percentage a volume server marks all volumes read-only AND
# refuses compaction, which is self-deadlocking (IFRNLLEI01PRD-2052).
variable "REDACTED_6930756b" {
  description = "SeaweedFS volume server minFreeSpacePercent"
  type        = number
  default     = 5
}

variable "seaweedfs_master_storage_size" {
  description = "Storage size for master metadata"
  type        = string
  default     = "10Gi"
}

variable "REDACTED_b907bdb5" {
  description = "Storage size for filer metadata"
  type        = string
  default     = "20Gi"
}

variable "REDACTED_4bbaa453" {
  description = "Run the bidirectional filer.sync deployment (NL true — the single sync runner; GR false)"
  type        = bool
  default     = true
}

variable "REDACTED_d063ac2f" {
  description = "filer.sync b->a resume floor, ms epoch (see the flag-semantics note in main.tf). NL 1777991510258; GR 0."
  type        = number
  default     = 1777991510258
}

variable "REDACTED_88d37e0b" {
  description = "filer.sync a->b resume floor, ms epoch (see the flag-semantics note in main.tf). NL 1777991510258; GR 0."
  type        = number
  default     = 1777991510258
}

# =============================================================================
# Argo CD
# =============================================================================

variable "REDACTED_be8b31fd" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "7.7.10"
}

variable "argocd_nodeport" {
  description = "NodePort for Argo CD HTTPS access"
  type        = number
  default     = 30085
}

variable "REDACTED_84146aee" {
  description = "Enable ingress for Argo CD"
  type        = bool
  default     = true
}

variable "REDACTED_649263f1" {
  description = "Run Argo CD server in insecure mode"
  type        = bool
  default     = false
}

variable "REDACTED_7ce225ce" {
  description = "Number of Argo CD server replicas (NL 2, GR 1 — DR site)"
  type        = number
  default     = 2
}

variable "argocd_repo_server_replicas" {
  description = "Number of Argo CD repo server replicas (NL 2, GR 1 — DR site)"
  type        = number
  default     = 2
}

variable "REDACTED_035cbec1" {
  description = "Enable Argo CD notifications controller (NL true, GR false)"
  type        = bool
  default     = true
}

variable "REDACTED_2f84acaa" {
  description = "Prefix for Matrix notification messages (NL [ArgoCD], GR [ArgoCD-GR])"
  type        = string
  default     = "[ArgoCD]"
}

variable "argocd_dex_enabled" {
  description = "Enable Dex for SSO integration"
  type        = bool
  default     = false
}

variable "argocd_repositories" {
  description = "Git repositories for Argo CD to manage"
  type        = map(any)
  default     = {}
}

variable "argocd_ssh_known_hosts" {
  description = "SSH known hosts for Git repositories"
  type        = string
  default     = ""
}

variable "argocd_matrix_token" {
  description = "Matrix bot access token for Argo CD notifications webhook (env-fed on NL; \"\" = disabled)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "REDACTED_9360424f" {
  description = "Repository-credential ExternalSecrets passed to the argocd module (map key = live Secret name — do not rename). NL 1 entry, GR 3 (its own gr-gitlab repos)."
  type = map(object({
    openbao_path = string
    url_override = optional(string)
  }))
  default = {
    "gitlab-repo-creds" = {
      openbao_path = "REDACTED_79b33008"
    }
  }
}

# =============================================================================
# AWX
# =============================================================================

variable "awx_enabled" {
  description = "Deploy the AWX namespace module (NL/GR true; a site without AWX passes false)."
  type        = bool
  default     = true
}

variable "REDACTED_3e5e811f" {
  description = "AWX PostgreSQL PVC size"
  type        = string
  default     = "50Gi"
}

variable "REDACTED_12032801" {
  description = "AWX Projects PVC size (NFS RWX)"
  type        = string
  default     = "50Gi"
}

variable "REDACTED_0b348a0e" {
  description = "Subdirectory under nfs_path holding AWX projects. Asymmetric by history (NL projects, GR awx-projects) — renaming the live NFS dir would orphan project data."
  type        = string
  default     = "projects"
}

variable "awx_ingress_enabled" {
  description = "Create an ingress-nginx Ingress for AWX (GR true; NL false — NodePort/NPM only)"
  type        = bool
  default     = false
}

variable "REDACTED_4c1f6c62" {
  description = "Storage class for the AWX PostgreSQL PVC (NL syno retain class, GR iscsi-ssd-retain)"
  type        = string
  default     = "REDACTED_b280aec5"
}

variable "REDACTED_28b716ba" {
  description = "Pre-existing PV to statically bind the AWX PostgreSQL PVC to (NL: imported 2024-11-27 CSI-migration PV). \"\" = dynamic provisioning (GR)."
  type        = string
  default     = "REDACTED_c7d87e23"
}

# =============================================================================
# Gatus
# =============================================================================

variable "site_name" {
  description = "Human site name on the Gatus page (Netherlands / Greece)"
  type        = string
  default     = "Netherlands"
}

variable "timezone" {
  description = "Site timezone (Europe/Amsterdam / Europe/Athens)"
  type        = string
  default     = "Europe/Amsterdam"
}

variable "REDACTED_9246ffd6" {
  description = "Gatus threshold: minimum established FRR BGP sessions (NL 35, GR 12)"
  type        = number
  default     = 35
}

variable "REDACTED_1c1562d0" {
  description = "Gatus threshold: minimum established Cilium BGP sessions (NL 4, GR 3)"
  type        = number
  default     = 4
}

variable "gatus_tls_secret_name" {
  description = "TLS secret for the Gatus ingress (NL gatus-tls via ACME; GR the shared REDACTED_0d82b4df-tls)"
  type        = string
  default     = "gatus-tls"
}

variable "gatus_gitlab_pipeline_trigger_token" {
  description = "GitLab pipeline trigger token for portfolio status webhook (\"\" = alerting path disabled)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "haproxy_stats_auth" {
  description = "Base64 encoded HAProxy stats REDACTED_6fa691d2 (user:pass) for the Gatus edge checks"
  type        = string
  default     = ""
  sensitive   = true
}

# Twilio SMS — for tier-1 service alerts via Gatus custom provider.
# Closes IFRNLLEI01PRD-802. Reuses the same API-Key-based auth pattern as
# claude-gateway/scripts/freedom-qos-toggle.sh (proven in production for
# Freedom-ISP outage SMS since 2026-04-22). API Key auth means we do NOT
# need the operator's master Twilio Auth Token — only API Key SID + Secret.
# Values come from TF_VAR_gatus_twilio_* in the NL Atlantis env; GR leaves
# them empty (paging bridge is wired, credentials deliberately absent).
variable "gatus_twilio_account_sid" {
  description = "Twilio Account SID (AC...). Same value as TWILIO_ACCOUNT_SID in claude-gateway/.env."
  type        = string
  default     = ""
  sensitive   = true
}
variable "gatus_twilio_api_key_sid" {
  description = "Twilio API Key SID (SK...). Same value as TWILIO_API_KEY_SID in claude-gateway/.env."
  type        = string
  default     = ""
  sensitive   = true
}
variable "gatus_twilio_api_key_secret" {
  description = "Twilio API Key Secret. Same value as TWILIO_API_KEY_SECRET in claude-gateway/.env."
  type        = string
  default     = ""
  sensitive   = true
}
variable "gatus_twilio_from_number" {
  description = "E.164 from-number, the Twilio-owned sender."
  type        = string
  default     = ""
  sensitive   = true
}
variable "gatus_twilio_to_number" {
  description = "E.164 destination, the operator's mobile."
  type        = string
  default     = ""
  sensitive   = true
}

# =============================================================================
# Synology CSI - nl-nas01 (DS1621+)
# Consumed ONLY by NL's site-storage.tf (module "nl-nas01_csi").
# Declared in both repos so variables.tf stays byte-identical; unused on GR.
# =============================================================================

variable "nl-nas01_csi_host" {
  description = "Synology NAS IP address for CSI driver (NL only)"
  type        = string
  default     = "10.0.X.X"
}

variable "REDACTED_6177f7df" {
  description = "Synology DSM username for CSI (NL only; env-fed — \"\" only on GR where it is unused)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "REDACTED_29445e2e" {
  description = "Synology DSM password for CSI (NL only; env-fed — \"\" only on GR where it is unused)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "REDACTED_cd98d00a" {
  description = "Synology volume path for LUNs (NL only)"
  type        = string
  default     = "/volume1"
}

variable "REDACTED_bf874266" {
  description = "Synology CSI Helm chart version (NL only)"
  type        = string
  default     = "0.10.1"
}

# =============================================================================
# Democratic CSI - iSCSI Storage
# Consumed ONLY by GR's site-storage.tf (module "democratic_csi").
# Declared in both repos so variables.tf stays byte-identical; unused on NL.
# =============================================================================

variable "iscsi_portal" {
  description = "iSCSI target portal address (GR only)"
  type        = string
  default     = "10.0.X.X:3260"
}

variable "iscsi_target_iqn" {
  description = "iSCSI target IQN prefix (GR only)"
  type        = string
  default     = "iqn.2024-12.net.nuclearlighters"
}

variable "democratic_csi_ssh_host" {
  description = "SSH host for democratic-csi ZFS management (GR only)"
  type        = string
  default     = "10.0.X.X"
}

variable "REDACTED_8b6f46ba" {
  description = "SSH username for democratic-csi (GR only)"
  type        = string
  default     = "root"
}

variable "REDACTED_768cc2a0" {
  description = "SSH private key for democratic-csi (GR only; env-fed TF_VAR_REDACTED_768cc2a0 — \"\" only on NL where it is unused)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "REDACTED_529ede8c" {
  description = "ZFS dataset parent path (GR only)"
  type        = string
  default     = "ssd-pool/k8s-iscsi"
}

# =============================================================================
# OpenEBS LocalPV - hostpath storage
# Consumed ONLY by notrf01's site-storage.tf (module "openebs_localpv").
# Declared in all repos so variables.tf stays byte-identical; unused on NL/GR.
# =============================================================================

variable "REDACTED_afff1a35" {
  description = "openebs/localpv-provisioner Helm chart version (notrf01 only; 4.5.1 = latest stable per the dynamic-localpv-provisioner repo index, verified 2026-08-17)"
  type        = string
  default     = "4.5.1"
}

variable "REDACTED_8553de03" {
  description = "Host base path for OpenEBS LocalPV hostpath volumes (notrf01 only — 160G shared roots)"
  type        = string
  default     = "/var/openebs/local"
}
