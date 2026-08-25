# =============================================================================
# Estate Scrape Jobs — NL-estate targets (chatops, omoikane, crowdsec, fisha,
# IoT cluster, edge node_exporter, frr-dmz)
# =============================================================================
# These jobs scrape ESTATE-wide targets (edge VPS/DMZ hosts, NL LXC hosts,
# omoikane production) that must be collected by exactly ONE Prometheus.
# The NL cluster owns them; GR disables via estate_scrape_enabled = false.
# Enabling on both clusters would double-scrape every target and double every
# alert evaluated on these series.
#
# The list is concat()-ed into additionalScrapeConfigs in main.tf AFTER the
# per-site base jobs (frr-route-reflectors, frr-edge-nodes, ipsec-edge-nodes,
# snmp-asa).
# =============================================================================

locals {
  # NOTE: gating uses a filtered for-expression (not `cond ? list : []`) because
  # the job objects are heterogeneous — a conditional cannot type-unify a
  # 12-element tuple of distinct object shapes against an empty tuple.
  estate_scrape_configs = [for job in local.estate_scrape_configs_all : job if var.estate_scrape_enabled]

  estate_scrape_configs_all = [
    # FRR BGP Exporters - Omoikane app DMZ pair (OMOIKANE-1437)
    #
    # These two speak iBGP in AS65000 and have shipped frr_exporter on
    # :9342 all along — they were simply in neither list above, so
    # MeshiBGPPeerDown (expr `frr_bgp_peer_state != 1`, no job selector)
    # could never fire for them: no series, no alert. A rule that cannot
    # express the failure it was written for.
    #
    # Verified live before adding, not inferred from config: dmz01 :9342
    # answers HTTP 200 and serves 9 frr_bgp_peer_state samples right now.
    #
    # instance/site replacements deliberately match the omoikane-node job
    # below (full hostname, site "no") so BGP and disk alerts name these
    # hosts identically.
    {
      job_name = "frr-dmz-nodes"
      static_configs = [{
        targets = [
          "10.255.4.11:9342", # notrf01dmz01 — omoikane app DMZ
          "10.255.5.11:9342", # notrf01dmz02 — omoikane app DMZ
        ]
        labels = {
          role = "dmz-node"
        }
      }]
      relabel_configs = [
        { source_labels = ["__address__"], regex = "10\\.255\\.4\\.11:.*", target_label = "instance", replacement = "notrf01dmz01" },
        { source_labels = ["__address__"], regex = "10\\.255\\.5\\.11:.*", target_label = "instance", replacement = "notrf01dmz02" },
        { source_labels = ["__address__"], regex = "10\\.255\\.[45]\\..*", target_label = "site", replacement = "no" },
      ]
    },
    # Node Exporter - Edge/DMZ Hosts
    {
      job_name = "node-exporter-edge"
      static_configs = [{
        targets = [
          "10.0.X.X:9100", # nldmz01 - NL DMZ Docker host
          "10.0.X.X:9100",  # grdmz01 - GR DMZ Docker host
          "10.255.2.11:9100",    # chzrh01vps01 - CH VPS edge proxy
          "10.255.3.11:9100",    # notrf01vps01 - NO VPS edge proxy
          "10.255.6.11:9100",    # txhou01vps01 - TX VPS edge proxy
        ]
        labels = {
          role = "edge-host"
        }
      }]
      relabel_configs = [
        # Instance names
        { source_labels = ["__address__"], regex = "192\\.168\\.192\\.10:.*", target_label = "instance", replacement = "nldmz01" },
        { source_labels = ["__address__"], regex = "192\\.168\\.15\\.10:.*", target_label = "instance", replacement = "grdmz01" },
        { source_labels = ["__address__"], regex = "10\\.255\\.2\\.11:.*", target_label = "instance", replacement = "chzrh01vps01" },
        { source_labels = ["__address__"], regex = "10\\.255\\.3\\.11:.*", target_label = "instance", replacement = "notrf01vps01" },
        { source_labels = ["__address__"], regex = "10\\.255\\.6\\.11:.*", target_label = "instance", replacement = "txhou01vps01" },
        # Site labels
        { source_labels = ["__address__"], regex = "192\\.168\\.192\\..*", target_label = "site", replacement = "nl" },
        { source_labels = ["__address__"], regex = "192\\.168\\.15\\..*", target_label = "site", replacement = "gr" },
        { source_labels = ["__address__"], regex = "10\\.255\\.2\\..*", target_label = "site", replacement = "ch" },
        { source_labels = ["__address__"], regex = "10\\.255\\.3\\..*", target_label = "site", replacement = "no" },
        { source_labels = ["__address__"], regex = "10\\.255\\.6\\..*", target_label = "site", replacement = "tx" },
      ]
    },
    # =============================================================
    # ChatOps Infrastructure - LXC Hosts (node_exporter)
    # =============================================================
    {
      job_name = "chatops-node"
      static_configs = [{
        targets = [
          "10.0.X.X:9100", # nlclaude01 - Claude Code + n8n
          "10.0.X.X:9100", # nlgpu01 - Ollama + RTX 3090 Ti
        ]
        labels = {
          role = "chatops"
        }
      }]
      relabel_configs = [
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.111:.*", target_label = "instance", replacement = "nlclaude01" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.181:.*", target_label = "instance", replacement = "nlgpu01" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\..*", target_label = "site", replacement = "nl" },
      ]
    },
    # (omoikane-cadvisor job REMOVED 2026-08-18, OMOIKANE-1623: cAdvisor was
    # dropped in the k8s migration; per-container metrics come from the NO
    # cluster kubelet cadvisor via REDACTED_d8074874.)
    {
      job_name = "omoikane-node"
      static_configs = [
        {
          targets = [
            "10.255.4.11:9100",    # notrf01dmz01 — app NL primary
            "10.255.5.11:9100",    # notrf01dmz02 — app NL peer
            "10.255.7.11:9100",    # notrf01dmz03 — YB primary
            "10.255.8.11:9100",    # notrf01dmz04 — YB peer + current LEADER
            "10.0.X.X:9100", # nldmz01 — YB arbitrator (NL)
          ]
          labels = {
            role = "omoikane-production"
          }
        },
        {
          targets = [
            "10.0.X.X:9100", # nlomktst01 — benchmark host
          ]
          labels = {
            role = "omoikane-benchmark"
          }
        },
        {
          targets = [
            "10.255.9.11:9100",  # notrf01dmz05 — baseline mesh member (no services yet)
            "10.255.10.11:9100", # notrf01dmz06 — baseline mesh member (no services yet)
          ]
          labels = {
            role = "edge-baseline"
          }
        },
      ]
      relabel_configs = [
        { source_labels = ["__address__"], regex = "10\\.255\\.4\\.11:.*", target_label = "instance", replacement = "notrf01dmz01" },
        { source_labels = ["__address__"], regex = "10\\.255\\.5\\.11:.*", target_label = "instance", replacement = "notrf01dmz02" },
        { source_labels = ["__address__"], regex = "10\\.255\\.7\\.11:.*", target_label = "instance", replacement = "notrf01dmz03" },
        { source_labels = ["__address__"], regex = "10\\.255\\.8\\.11:.*", target_label = "instance", replacement = "notrf01dmz04" },
        { source_labels = ["__address__"], regex = "192\\.168\\.192\\.10:.*", target_label = "instance", replacement = "nldmz01" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.30:.*", target_label = "instance", replacement = "nlomktst01" },
        { source_labels = ["__address__"], regex = "10\\.255\\.9\\.11:.*", target_label = "instance", replacement = "notrf01dmz05" },
        { source_labels = ["__address__"], regex = "10\\.255\\.10\\.11:.*", target_label = "instance", replacement = "notrf01dmz06" },
        { source_labels = ["__address__"], regex = "10\\.255\\.4\\..*", target_label = "site", replacement = "no" },
        { source_labels = ["__address__"], regex = "10\\.255\\.5\\..*", target_label = "site", replacement = "no" },
        { source_labels = ["__address__"], regex = "10\\.255\\.7\\..*", target_label = "site", replacement = "no" },
        { source_labels = ["__address__"], regex = "10\\.255\\.8\\..*", target_label = "site", replacement = "no" },
        { source_labels = ["__address__"], regex = "10\\.255\\.9\\..*", target_label = "site", replacement = "no" },
        { source_labels = ["__address__"], regex = "10\\.255\\.10\\..*", target_label = "site", replacement = "no" },
        { source_labels = ["__address__"], regex = "192\\.168\\.192\\..*", target_label = "site", replacement = "nl" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\..*", target_label = "site", replacement = "nl" },
      ]
    },
    # (omoikane-daemon mesh scrape REMOVED 2026-08-18, OMOIKANE-1623: the
    # compose pair is retired; the app metrics arrive via the NO cluster
    # ServiceMonitor + remote-write as job="daemon", namespace="omoikane",
    # site="no" — the omoikane_* alert exprs are job-agnostic and kept firing
    # correctly through the cutover, which is how the writing_drafts RED was
    # caught on 2026-08-18.)
    # ChatOps Infrastructure - GPU Metrics (nvidia_gpu_exporter)
    {
      job_name = "chatops-nvidia"
      static_configs = [{
        targets = ["10.0.X.X:9835"]
        labels = {
          role = "gpu"
        }
      }]
      relabel_configs = [
        { target_label = "instance", replacement = "nlgpu01" },
        { target_label = "site", replacement = "nl" },
      ]
    },
    # ChatOps Infrastructure - HTTP Service Probes (blackbox_exporter)
    {
      job_name        = "chatops-blackbox"
      scrape_interval = "60s"
      scrape_timeout  = "30s"
      metrics_path    = "/probe"
      params = {
        module = ["http_2xx"]
      }
      static_configs = [{
        targets = [
          "https://matrix.example.net/_matrix/client/versions",
          "https://gitlab.example.net/explore",
          "https://youtrack.example.net/api/config",
          "https://n8n.example.net/healthz",
          "https://ollama.example.net/api/tags",
          "https://grafana.example.net/api/health",
          "https://nl-prometheus.example.net/-/healthy",
        ]
      }]
      relabel_configs = [
        { source_labels = ["__address__"], target_label = "__param_target" },
        { source_labels = ["__param_target"], target_label = "instance" },
        { target_label = "__address__", replacement = "10.0.X.X:9115" },
      ]
    },

    # Omoikane public surfaces — OUTSIDE-IN availability (OMOIKANE-8).
    # Every other omoikane check watches an INTERNAL mesh IP or the
    # daemon's own /metrics; an edge or DMZ outage with a healthy daemon
    # alerts nothing today. This probes the full public path
    # (edge -> DMZ -> daemon) from the blackbox exporter on
    # nlclaude01, egressing to the internet like a real user, so a
    # broken edge trips probe_success even while the daemon is fine.
    # http_2xx follows redirects, so www (301 -> apex) and cv
    # (302 -> login) both resolve to 200. Deliberately NOT wired to the
    # tier=1 SMS surface — these route via Alertmanager -> n8n ->
    # Matrix/YT like the rest of the omoikane rules (page-free).
    {
      job_name        = "omoikane-public"
      scrape_interval = "60s"
      scrape_timeout  = "30s"
      metrics_path    = "/probe"
      params = {
        module = ["http_2xx"]
      }
      static_configs = [
        {
          targets = [
            "https://omoikane.coach",
            "https://www.omoikane.coach",
            "https://app.omoikane.coach",
            "https://cv.omoikane.coach",
          ]
          labels = {
            service = "omoikane"
            env     = "production"
            site    = "nl"
          }
        },
        {
          targets = ["https://beta.omoikane.coach"]
          labels = {
            service = "omoikane"
            env     = "staging"
            site    = "nl"
          }
        },
      ]
      relabel_configs = [
        { source_labels = ["__address__"], target_label = "__param_target" },
        { source_labels = ["__param_target"], target_label = "instance" },
        { target_label = "__address__", replacement = "10.0.X.X:9115" },
      ]
    },

    # CrowdSec Security Metrics
    {
      job_name = "crowdsec"
      static_configs = [{
        targets = [
          "10.0.X.X:6060", # nldmz01
          "10.0.X.X:6060",  # grdmz01
          "10.255.2.11:6060",    # chzrh01vps01
          "10.255.3.11:6060",    # notrf01vps01
          "10.255.6.11:6060",    # txhou01vps01
        ]
        labels = {
          role = "security"
        }
      }]
      relabel_configs = [
        { source_labels = ["__address__"], regex = "192\\.168\\.192\\.10:.*", target_label = "instance", replacement = "nldmz01" },
        { source_labels = ["__address__"], regex = "192\\.168\\.15\\.10:.*", target_label = "instance", replacement = "grdmz01" },
        { source_labels = ["__address__"], regex = "10\\.255\\.2\\.11:.*", target_label = "instance", replacement = "chzrh01vps01" },
        { source_labels = ["__address__"], regex = "10\\.255\\.3\\.11:.*", target_label = "instance", replacement = "notrf01vps01" },
        { source_labels = ["__address__"], regex = "10\\.255\\.6\\.11:.*", target_label = "instance", replacement = "txhou01vps01" },
        { source_labels = ["__address__"], regex = "192\\.168\\.192\\..*", target_label = "site", replacement = "nl" },
        { source_labels = ["__address__"], regex = "192\\.168\\.15\\..*", target_label = "site", replacement = "gr" },
        { source_labels = ["__address__"], regex = "10\\.255\\.2\\..*", target_label = "site", replacement = "ch" },
        { source_labels = ["__address__"], regex = "10\\.255\\.3\\..*", target_label = "site", replacement = "no" },
        { source_labels = ["__address__"], regex = "10\\.255\\.6\\..*", target_label = "site", replacement = "tx" },
      ]
    },

    # FISHA NFS Stale-FH Exporter — counts NFS4ERR_STALE responses.
    # Per IFRNLLEI01PRD-805. Healthy nfsd should report 0 forever.
    # Service code: native/fisha/nlcl01file{01,02}/scripts/nfs-stale-fh-exporter.py
    {
      job_name = "fisha-nfs-stale-fh"
      static_configs = [{
        targets = [
          "10.0.X.X:9101", # nlcl01file01
          "10.0.X.X:9101", # nlcl01file02
        ]
        labels = {
          role = "nfs-server"
          site = "nl"
        }
      }]
      relabel_configs = [
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.155:.*", target_label = "instance", replacement = "nlcl01file01" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.156:.*", target_label = "instance", replacement = "nlcl01file02" },
      ]
    },

    # HAHA (IoT) Pacemaker Cluster — node_exporter + pacemaker_node_standby
    # textfile metric (native/haha/pacemaker-standby-exporter/). Feeds the
    # REDACTED_2aa4f351 alert so we don't lose another 16h to a
    # forgotten "crm node standby" the next time the weekly playbook fails.
    {
      job_name = "REDACTED_84f96d5e"
      static_configs = [{
        targets = [
          "10.0.X.X:9100", # nlcl01iot01 — primary (active/standby)
          "10.0.X.X:9100", # nlcl01iot02 — primary (active/standby)
          "10.0.X.X:9100", # nlcl01iotarb01 — arbiter (Synology VMM)
        ]
        labels = {
          role = "iot-cluster"
          site = "nl"
        }
      }]
      relabel_configs = [
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.175:.*", target_label = "instance", replacement = "nlcl01iot01" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.176:.*", target_label = "instance", replacement = "nlcl01iot02" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.174:.*", target_label = "instance", replacement = "nlcl01iotarb01" },
      ]
    },

    # =============================================================
    # PVE hosts — prometheus-pve-exporter (:9221) + node_exporter (:9100)
    # =============================================================
    # Installed natively on all 5 LIVE PVE hosts 2026-08-25 by claude-gateway
    # scripts/pve-host-exporters-install.sh (venv /opt/prometheus-pve-exporter,
    # API token prometheus@pve!pve-exporter, PVEAuditor). nl-pve02 is
    # POWERED OFF by design (5/6 baseline, IFRNLLEI01PRD-2646) — NOT a target.
    #
    # pve-exporter 3.x: status/version/node/resources/backup-info are all
    # "cluster collectors" (?cluster=1) — EVERY host reports the whole
    # cluster view (~236 pve_up ids, ~3.5k series/host). Rules must dedup
    # with max by (id). The per-host value: exporter liveness, that host's
    # API/pmxcfs responsiveness (scrape_duration_seconds per instance), and
    # partition-safe reporters on both sites. config/replication/
    # subscription/qdevice collectors are deliberately disabled on the hosts.
    {
      job_name        = "pve-exporter"
      scrape_interval = "60s"
      scrape_timeout  = "50s"
      metrics_path    = "/pve"
      params = {
        cluster = ["1"]
        node    = ["0"]
      }
      static_configs = [{
        targets = [
          "10.0.X.X:9221", # nl-pve01
          "10.0.X.X:9221", # nl-pve03
          "10.0.X.X:9221", # nlpve04
          "10.0.X.X:9221",   # gr-pve01
          "10.0.X.X:9221",   # gr-pve02
        ]
        labels = {
          role = "pve-host"
        }
      }]
      relabel_configs = [
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.22:.*", target_label = "instance", replacement = "nl-pve01" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.25:.*", target_label = "instance", replacement = "nl-pve03" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.27:.*", target_label = "instance", replacement = "nlpve04" },
        { source_labels = ["__address__"], regex = "192\\.168\\.2\\.26:.*", target_label = "instance", replacement = "gr-pve01" },
        { source_labels = ["__address__"], regex = "192\\.168\\.2\\.28:.*", target_label = "instance", replacement = "gr-pve02" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\..*", target_label = "site", replacement = "nl" },
        { source_labels = ["__address__"], regex = "192\\.168\\.2\\..*", target_label = "site", replacement = "gr" },
      ]
    },
    # Host-native node_exporter on the same 5 PVE hosts (Debian package,
    # PSI/zfs/textfile collectors, mgmt-IP-bound). Makes the host-pressure
    # rules in host-pressure-alerts.tf live for the first time.
    {
      job_name = "pve-node-exporter"
      static_configs = [{
        targets = [
          "10.0.X.X:9100", # nl-pve01
          "10.0.X.X:9100", # nl-pve03
          "10.0.X.X:9100", # nlpve04
          "10.0.X.X:9100",   # gr-pve01
          "10.0.X.X:9100",   # gr-pve02
        ]
        labels = {
          role = "pve-host"
        }
      }]
      relabel_configs = [
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.22:.*", target_label = "instance", replacement = "nl-pve01" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.25:.*", target_label = "instance", replacement = "nl-pve03" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.27:.*", target_label = "instance", replacement = "nlpve04" },
        { source_labels = ["__address__"], regex = "192\\.168\\.2\\.26:.*", target_label = "instance", replacement = "gr-pve01" },
        { source_labels = ["__address__"], regex = "192\\.168\\.2\\.28:.*", target_label = "instance", replacement = "gr-pve02" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\..*", target_label = "site", replacement = "nl" },
        { source_labels = ["__address__"], regex = "192\\.168\\.2\\..*", target_label = "site", replacement = "gr" },
      ]
    },
  ]
}
