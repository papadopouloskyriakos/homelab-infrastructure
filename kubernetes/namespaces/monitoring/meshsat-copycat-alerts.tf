# =============================================================================
# meshsat.info copycat watch: outside-in probes + alerts (MESHSAT-984,
# enforcement record MESHSAT-689)
#
# NL-ONLY, mirror-exempt (scripts/k8s-mirror-exempt.txt). Mirroring this to GR
# and NO would fire every alert three times: three YouTrack issues, three Matrix
# posts, three pages per event.
#
# WHAT THIS WATCHES AND WHY
# meshsat.info is a copycat that uses our trademark for a different product. It
# advertises, as its "recommended" install path, on a page whose tutorial uses
# sudo 19 times and targets a freshly imaged Raspberry Pi:
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/IngeniiImperator/MeshSat/main/scripts/install.sh)
#
# That endpoint returns 404 today, but the account is live and active. The
# instruction to fetch and execute it is already published and indexed. The
# moment it serves anything, arbitrary code runs as root on machines whose
# owners believe they are installing MeshSat. No abuse body (Google Safe
# Browsing, the .info registry, the hosting forge) will act on a hypothetical;
# every one of them needs a live artifact. This is how we get that artifact in
# the first hours rather than after someone is compromised.
#
# THE INVERSION
# Every other rule in this directory alerts when a URL STOPS returning 200.
# These alert when a URL that is currently 404 STARTS returning 200. That needs
# no blackbox module change: probe_http_status_code is exported even when
# probe_success is 0, so the stock http_2xx module is enough. This is deliberate
# because the blackbox exporter's config is not in git (it lives only in the
# container's writable layer on nlclaude01), so it must not be touched
# casually.
#
# TWO SOURCES
#   1. Blackbox probes (this ScrapeConfig) of the URLs we know about today.
#   2. scripts/meshsat-copycat-watch.py in the claude-gateway repo, run by cron
#      on nlclaude01 at 7 and 37 past, which covers what a status probe
#      cannot: the install URL can simply be changed, and they are not obliged to
#      stay on GitHub. It re-reads the site, extracts every fetch-and-execute
#      target WHEREVER it is hosted, resolves each, hashes each page, and checks
#      GitHub, GitLab and Codeberg for repositories carrying our mark under the
#      same handle. Its gauges reach this Prometheus through node_exporter's
#      textfile collector via the `chatops-node` job.
#
#      Its classifier is an allowlist of KNOWN-BENIGN upstreams, not a list of
#      hosts we think they own, so a move to GitLab or a paste site defaults to
#      suspicious instead of going quiet. The static probes below are therefore
#      the fast path for the endpoint we know; the script is the safety net for
#      the one we do not.
#
# PAGING, AND WHY THIS ONE DIVERGES
# The two existing outside-in rule sets (REDACTED_40e7121b, meshsat-hub)
# deliberately carry no `tier` label and say "No SMS by design". This set does
# carry tier=1, and the payload rule also carries page=sms, by owner decision
# (2026-09-08). The justification is that these rules fire essentially never,
# and when they do fire the first hours are exactly when reporting to Safe
# Browsing and to the registry does the most good. Everything else here routes
# the normal way: Alertmanager -> n8n -> Matrix + YouTrack.
#
# NEGATIVE CONTROL DONE AT AUTHORING (2026-09-08): the three GitHub endpoints
# return 404 and the six copycat pages return 200; the watch script reported
# exec_urls=6, suspect_urls=3, suspect_urls_live=0, pages_reachable=6,
# mark_repos=0, forges_ok=2. GitHub carries the account; Codeberg 404s for the
# handle; GitLab answers 200 with an empty list for an unknown user, so
# forges_ok counts reachability of the check, not presence of an account.
# =============================================================================

resource "kubernetes_manifest" "meshsat_copycat_scrape" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1alpha1"
    kind       = "ScrapeConfig"
    metadata = {
      name      = "meshsat-copycat"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "release"                   = "monitoring"
      }
    }
    spec = {
      jobName        = "meshsat-copycat"
      scrapeInterval = "5m"
      scrapeTimeout  = "30s"
      metricsPath    = "/probe"
      params = {
        module = ["http_2xx"]
      }
      staticConfigs = [
        {
          # The delivery endpoint. A body here is the event this file exists for.
          targets = [
            "https://raw.githubusercontent.com/IngeniiImperator/MeshSat/main/scripts/install.sh",
          ]
          labels = {
            service = "meshsat-copycat"
            role    = "payload"
          }
        },
        {
          # The repository and its tarball. If either goes public the payload
          # endpoint is one push away.
          targets = [
            "https://github.com/IngeniiImperator/MeshSat",
            "https://codeload.github.com/IngeniiImperator/MeshSat/tar.gz/main",
          ]
          labels = {
            service = "meshsat-copycat"
            role    = "repo"
          }
        },
        {
          # The copycat's own pages. These return 200 today; they are probed for
          # reachability history, not for an alert. If they go dark that is a
          # takedown succeeding, which we want recorded but not paged.
          targets = [
            "https://www.meshsat.info/",
            "https://www.meshsat.info/tutorial",
            "https://www.meshsat.info/hardware",
            "https://www.meshsat.info/countdown",
            "https://www.meshsat.info/credits",
            "https://www.meshsat.info/chat",
          ]
          labels = {
            service = "meshsat-copycat"
            role    = "site"
          }
        },
      ]
      relabelings = [
        { sourceLabels = ["__address__"], targetLabel = "__param_target" },
        { sourceLabels = ["__param_target"], targetLabel = "instance" },
        { targetLabel = "__address__", replacement = "10.0.X.X:9115" },
      ]
    }
  }
}

resource "kubernetes_manifest" "REDACTED_38828efd" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_b7b21348"
      namespace = "monitoring"
      labels = {
        "app.kubernetes.io/part-of" = "kube-prometheus"
        "prometheus"                = "monitoring"
        "role"                      = "alert-rules"
        "release"                   = "monitoring"
      }
    }
    spec = {
      groups = [
        {
          name     = "REDACTED_3734eba0"
          interval = "1m"
          rules = [
            {
              # THE rule this file exists for.
              alert = "REDACTED_ca0916ae"
              expr  = "probe_http_status_code{job=\"meshsat-copycat\",role=\"payload\"} == 200"
              for   = "0m"
              labels = {
                severity = "critical"
                service  = "meshsat-copycat"
                tier     = "1"
                page     = "sms"
              }
              annotations = {
                summary     = "meshsat.info install payload is LIVE at {{ $labels.instance }}"
                description = "The install script the copycat advertises now returns 200. It was 404. Anyone following meshsat.info's instructions is piping this into a root shell right now. ACT IN THIS ORDER: (1) capture the body immediately, it may be pulled within minutes, and check ~/.cache/meshsat-copycat-watch/evidence on nlclaude01 where the watch script saves it automatically; (2) report to Google Safe Browsing, which puts an interstitial in front of the whole site in Chrome and Firefox and is the fastest lever; (3) report to the .info registry, Identity Digital, whose Acceptable Use Policy covers malware distribution and who can suspend the domain, abuse@identity.digital; (4) file the GitHub trademark and malware report, staged at trademark/2026-09-08-github-trademark-report-STAGED.md in the funding pack, which finally has a live content URL; (5) reply in Vercel case 01480308 with the artifact. Case record: MESHSAT-689."
              }
            },
            {
              alert = "REDACTED_081e5320"
              expr  = "probe_http_status_code{job=\"meshsat-copycat\",role=\"repo\"} == 200"
              for   = "0m"
              labels = {
                severity = "critical"
                service  = "meshsat-copycat"
                tier     = "1"
              }
              annotations = {
                summary     = "The copycat's GitHub repository is public again: {{ $labels.instance }}"
                description = "IngeniiImperator/MeshSat returned 200. It was 404. The payload endpoint is one push away from serving, and the GitHub report staged in the funding pack now has the live content URL it needs. Snapshot the repository before anything else. No SMS on this one; REDACTED_ca0916ae is the paging rule."
              }
            },
            {
              alert = "REDACTED_7e201894"
              expr  = "absent(probe_http_status_code{job=\"meshsat-copycat\"})"
              for   = "30m"
              labels = {
                severity = "warning"
                service  = "meshsat-copycat"
              }
              annotations = {
                summary     = "Copycat endpoint probing has stopped (30m)"
                description = "No probe_http_status_code series for job=meshsat-copycat: the blackbox exporter on nlclaude01 (10.0.X.X:9115) is down, or this ScrapeConfig was removed. While this is true, REDACTED_ca0916ae cannot fire and the watch is blind."
              }
            },
          ]
        },
        {
          name     = "meshsat-copycat-watch"
          interval = "1m"
          rules = [
            {
              # The script resolves URLs it extracted from the site, so this
              # catches a NEW delivery endpoint that the static ScrapeConfig
              # above knows nothing about. max_over_time holds the alert up for
              # 6h so a transient event cannot be missed between evaluations.
              alert = "REDACTED_d7a51c72"
              expr  = "max_over_time(meshsat_copycat_suspect_urls_live[6h]) > 0"
              for   = "0m"
              labels = {
                severity = "critical"
                service  = "meshsat-copycat"
                tier     = "1"
                page     = "sms"
              }
              annotations = {
                summary     = "A fetch-and-execute URL advertised on meshsat.info is serving content"
                description = "meshsat-copycat-watch.py resolved a curl/wget/git-clone target extracted from meshsat.info that is NOT a recognised third-party upstream, and it returned a body. This covers the two cases the static probes cannot: they changed the install URL, or they moved off GitHub entirely to GitLab, Codeberg, a paste site or their own domain. The classifier is an allowlist of benign upstreams, so a new host defaults to suspicious rather than being silently ignored. The body is saved under ~/.cache/meshsat-copycat-watch/evidence on nlclaude01. Follow the REDACTED_ca0916ae runbook, substituting the forge that is actually hosting it. If the URL turns out to be a legitimate new dependency of their tutorial, add its prefix to BENIGN_PREFIXES in the watch script rather than widening the rule."
              }
            },
            {
              alert = "REDACTED_e5c4ebe7"
              expr  = "max_over_time(meshsat_copycat_mark_repos_new[6h]) > 0"
              for   = "0m"
              labels = {
                severity = "critical"
                service  = "meshsat-copycat"
                tier     = "1"
              }
              annotations = {
                summary     = "A new repository carrying the MeshSat mark appeared under the copycat's handle"
                description = "The handle IngeniiImperator published a repository whose name contains 'meshsat' on GitHub, GitLab or Codeberg (the metric label carries which). Snapshot it, then reassess the staged trademark report: a live repository using the mark is exactly the content a forge's trademark policy requires and which we do not have today. Note GitLab answers 200 with an empty list for an unknown user, so presence there is real only if a repo is actually returned."
              }
            },
            {
              alert = "REDACTED_9676dd91"
              expr  = "max_over_time(meshsat_copycat_exec_urls_new[6h]) > 0"
              for   = "0m"
              labels = {
                severity = "warning"
                service  = "meshsat-copycat"
              }
              annotations = {
                summary     = "A new fetch-and-execute URL is advertised on meshsat.info"
                description = "The set of curl/wget/git-clone targets on the copycat's pages changed. This is a warning rather than a page because their tutorial also references legitimate third-party downloads. Read ~/.cache/meshsat-copycat-watch/state.json on nlclaude01 to see which URL is new, and if it sits on infrastructure they control, add it to the ScrapeConfig in this file."
              }
            },
            {
              alert = "REDACTED_6ebfe436"
              expr  = "max_over_time(meshsat_copycat_pages_changed[24h]) > 0"
              for   = "0m"
              labels = {
                severity = "warning"
                service  = "meshsat-copycat"
              }
              annotations = {
                summary     = "The copycat republished: a page body hash changed"
                description = "At least one of the six meshsat.info pages changed content. They have republished after every report so far (26 Aug and 2 Sep), each time adding material. Informational, but worth a snapshot for the case record on MESHSAT-689."
              }
            },
            {
              alert = "REDACTED_b1217418"
              expr  = "(time() - meshsat_copycat_last_run_timestamp_seconds > 10800) or absent(meshsat_copycat_last_run_timestamp_seconds)"
              for   = "15m"
              labels = {
                severity = "warning"
                service  = "meshsat-copycat"
              }
              annotations = {
                summary     = "meshsat-copycat-watch has not completed a run in over 3 hours"
                description = "The cron entry on nlclaude01 is not running, or the script is failing before it writes its metrics. Note the estate-wide REDACTED_50695a0e rule does NOT cover this: a dead producer's .prom file is re-served forever with a fresh mtime, which is why this rule keys on the script's own last_run timestamp instead. While this is true, every meshsat-copycat-watch rule above is blind."
              }
            },
          ]
        },
      ]
    }
  }
}
