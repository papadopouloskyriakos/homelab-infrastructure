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
    {
      # OMOIKANE-1153 — per-container CPU/memory from cAdvisor,
      # deployed as a sidecar on each DMZ host (daemon repo
      # `cadvisor/compose.yml`, bound on the mesh IP at :8098).
      #
      # Targets and labels MIRROR the `omoikane-node` job below on
      # purpose: the production-only alert rules select on
      # role="omoikane-production", and a cAdvisor job carrying
      # different labels would sit outside every one of them.
      #
      # The bench host is deliberately ABSENT. cAdvisor is not
      # deployed there — nlomktst01 still runs the containerd
      # snapshotter, under which cAdvisor cannot identify containers
      # at all (one unlabelled series). A target for it would scrape
      # a port with nothing behind it and read as permanently down.
      job_name = "omoikane-cadvisor"
      static_configs = [
        {
          targets = [
            "10.255.4.11:8098", # notrf01dmz01 — app NL primary
            "10.255.5.11:8098", # notrf01dmz02 — app NL peer
            "10.255.7.11:8098", # notrf01dmz03 — YB primary
            "10.255.8.11:8098", # notrf01dmz04 — YB peer
          ]
          labels = {
            role = "omoikane-production"
          }
        },
      ]
      relabel_configs = [
        { source_labels = ["__address__"], regex = "10\\.255\\.4\\.11:.*", target_label = "instance", replacement = "notrf01dmz01" },
        { source_labels = ["__address__"], regex = "10\\.255\\.5\\.11:.*", target_label = "instance", replacement = "notrf01dmz02" },
        { source_labels = ["__address__"], regex = "10\\.255\\.7\\.11:.*", target_label = "instance", replacement = "notrf01dmz03" },
        { source_labels = ["__address__"], regex = "10\\.255\\.8\\.11:.*", target_label = "instance", replacement = "notrf01dmz04" },
        { source_labels = ["__address__"], regex = "10\\.255\\..*", target_label = "site", replacement = "no" },
      ]
    },
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
      ]
      relabel_configs = [
        { source_labels = ["__address__"], regex = "10\\.255\\.4\\.11:.*", target_label = "instance", replacement = "notrf01dmz01" },
        { source_labels = ["__address__"], regex = "10\\.255\\.5\\.11:.*", target_label = "instance", replacement = "notrf01dmz02" },
        { source_labels = ["__address__"], regex = "10\\.255\\.7\\.11:.*", target_label = "instance", replacement = "notrf01dmz03" },
        { source_labels = ["__address__"], regex = "10\\.255\\.8\\.11:.*", target_label = "instance", replacement = "notrf01dmz04" },
        { source_labels = ["__address__"], regex = "192\\.168\\.192\\.10:.*", target_label = "instance", replacement = "nldmz01" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\.30:.*", target_label = "instance", replacement = "nlomktst01" },
        { source_labels = ["__address__"], regex = "10\\.255\\.4\\..*", target_label = "site", replacement = "no" },
        { source_labels = ["__address__"], regex = "10\\.255\\.5\\..*", target_label = "site", replacement = "no" },
        { source_labels = ["__address__"], regex = "10\\.255\\.7\\..*", target_label = "site", replacement = "no" },
        { source_labels = ["__address__"], regex = "10\\.255\\.8\\..*", target_label = "site", replacement = "no" },
        { source_labels = ["__address__"], regex = "192\\.168\\.192\\..*", target_label = "site", replacement = "nl" },
        { source_labels = ["__address__"], regex = "192\\.168\\.181\\..*", target_label = "site", replacement = "nl" },
      ]
    },
    # =============================================================
    # omoikane-daemon — the APPLICATION's own metrics.
    #
    # OMOIKANE-1486 (2026-07-26). The daemon has exposed /metrics on
    # container port 8080 (host 8459) since it was built, and this
    # Prometheus has never scraped it. Only `omoikane-node` existed,
    # which is node_exporter — host CPU/RAM, not the application.
    #
    # The consequence was not theoretical. On 2026-07-25 the
    # embedding backend died and ran ~20 hours with no alert. Part of
    # that was missing instrumentation (fixed in daemon !3155/!3157),
    # but the rest was this: nothing collected what the daemon
    # emitted, so no rule could evaluate and nothing could page.
    # `daemon/monitoring/prometheus-rules-omoikane-daemon.yaml` has
    # been in the repo for months and is loaded by neither cluster.
    #
    # Reachability was verified before adding this, from inside
    # prometheus-REDACTED_6dfbe9fc-0:
    #   wget -qO- http://10.255.4.11:8459/metrics -> 314 omoikane_* series
    #   wget -qO- http://10.255.5.11:8459/metrics -> 314 omoikane_* series
    # Same hosts already scraped on :9100 by omoikane-node, so no
    # firewall change is required.
    #
    # Collection only. No alert rules are activated by this change —
    # see the MR for why those are deliberately separate.
    #
    # 30s interval: the daemon's status prober refreshes every 60s by
    # default (OMOIKANE_STATUS_REFRESH_SECS), so 30s gives two samples
    # per prober pass and keeps `for:` windows meaningful.
    # =============================================================
    {
      job_name        = "omoikane-daemon"
      scrape_interval = "30s"
      metrics_path    = "/metrics"
      static_configs = [
        {
          targets = [
            "10.255.4.11:8459", # notrf01dmz01 — app NL primary
            "10.255.5.11:8459", # notrf01dmz02 — app NL peer
          ]
          labels = {
            role = "omoikane-production"
          }
        },
      ]
      relabel_configs = [
        { source_labels = ["__address__"], regex = "10\\.255\\.4\\.11:.*", target_label = "instance", replacement = "notrf01dmz01" },
        { source_labels = ["__address__"], regex = "10\\.255\\.5\\.11:.*", target_label = "instance", replacement = "notrf01dmz02" },
        { source_labels = ["__address__"], regex = "10\\.255\\..*", target_label = "site", replacement = "no" },
      ]
    },
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
  ]
}
