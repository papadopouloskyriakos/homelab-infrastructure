# =============================================================================
# Edge host firewall ENFORCEMENT alerts
#
# Closes the monitoring gap found on 2026-07-29: notrf01dmz01-04 sat directly on
# the public internet for months with `iptables -P INPUT ACCEPT` on v4 AND v6,
# zero filtering rules and ufw not installed — ~35 world-open ports each,
# including a YugabyteDB YSQL endpoint, CloudBeaver, unauthenticated Grafana
# Tempo ingest and cleartext IMAP. NOTHING alerted, and the daily external
# security scan reported CLEAN every day for 57 consecutive days.
#
# Two reasons it stayed invisible, both of which shape these rules:
#
#  1) "Firewall down" cannot be seen from outside. Flush the ruleset but leave
#     the same services listening and an external port scan is byte-identical.
#     Detection therefore has to be ON the host — posture-probe.sh (5-min timer,
#     node_exporter textfile collector). Script: edge/_tools/posture-probe.sh.
#
#  2) The host LOOKED configured. The persisted ruleset still carried the seven
#     `ufw-*` chain JUMPS in INPUT, so `iptables -L` rendered a tidy, firewalled
#     host while every one of those chains was EMPTY — all seven jumps carrying
#     the identical packet count, i.e. nothing was ever terminated. So the probe
#     measures rules INSIDE the ufw chains, which score ~0 in that state while
#     the jump count still reads 7.
#
# ⚠ TWO TRAPS THESE RULES DELIBERATELY AVOID — do not "simplify" them:
#
#  A) NEVER alert on `node_systemd_unit_state{name="ufw.service"}`. ufw.service
#     is Type=oneshot and on notrf01dmz01-04 it lacks RemainAfterExit, so it
#     reports inactive/dead WHILE THE HOST IS FULLY ENFORCING (verified on all
#     four, 2026-07-29: policy DROP both families, 90 v4 / 89 v6 rules). An
#     alert keyed on unit state would false-positive on precisely the four hosts
#     this exists to protect. edge_posture_context{unit="ufw"} is exported for
#     humans only.
#
#  B) NEVER scope these by job. notrf01dmz01-04 are scraped under job
#     "omoikane-node", NOT "node-exporter-edge" — a job="node-exporter-edge"
#     selector silently excludes all four. nldmz01 is in BOTH jobs, so
#     every expression below aggregates with `max by (instance)` to avoid
#     firing twice for that host.
#
# tier="1" + severity="critical" routes to the Twilio SMS receiver
# (main.tf alertmanager route -> 10.0.X.X:9106, group_wait 10s). That is
# reserved here for a firewall that has actually stopped enforcing on an
# internet-facing host — the one condition that warrants waking someone.
#
# namespace="edge-firewall" is set because the n8n Prometheus receiver dedups on
# alertname+":"+namespace; edge hosts have no k8s namespace, so without it every
# host would collapse into a single dedup key and only the first would surface.
#
# Related: IFRNLLEI01PRD-1983 (remaining hardening), edge/CLAUDE.md host-firewall
# section, native/sec/CLAUDE.md coverage reconciliation.
# =============================================================================

resource "kubernetes_manifest" "edge_firewall_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "edge-firewall-alert-rules"
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
          name     = "REDACTED_98655edf"
          interval = "1m"
          rules = [
            {
              # THE alert. Composite: default policy DROP on BOTH families AND the
              # ufw chains actually populated. Anything less is not enforcing,
              # however configured it may look.
              alert = "REDACTED_c39c23d4"
              expr  = "max by (instance) (edge_firewall_enforcing) == 0"
              for   = "2m"
              labels = {
                severity  = "critical"
                tier      = "1"
                category  = "host-firewall"
                service   = "edge"
                namespace = "edge-firewall"
              }
              annotations = {
                summary     = "Host firewall NOT enforcing on internet-facing host {{ $labels.instance }}"
                description = "{{ $labels.instance }} is directly internet-facing and its firewall is NOT enforcing: either the default INPUT policy is no longer DROP on one/both address families, or the ufw chains have been emptied. This is the exact state in which notrf01dmz01-04 sat exposed for months in 2026 with ~35 world-open ports while every report read CLEAN. Check `iptables -S INPUT | head -1`, `ip6tables -S INPUT | head -1` and `iptables -S | grep -c '^-A ufw'` on the host. Do NOT be reassured by `systemctl is-active ufw` — it is Type=oneshot and reads inactive on the notrf01dmz0X hosts while they are fully enforcing."
                impact      = "The host is on the public internet with no packet filtering. Every listening service is world-reachable, including any bound only for local/overlay use."
              }
            },
            {
              # Split out from the composite so the annotation can name WHICH family
              # regressed — a v6-only regression is easy to miss and just as fatal,
              # and the original incident had both families wide open.
              alert = "REDACTED_e67edccb"
              expr  = "max by (instance, family) (edge_firewall_input_policy_drop) == 0"
              for   = "2m"
              labels = {
                severity  = "critical"
                tier      = "1"
                category  = "host-firewall"
                service   = "edge"
                namespace = "edge-firewall"
              }
              annotations = {
                summary     = "Default INPUT policy is not DROP ({{ $labels.family }}) on {{ $labels.instance }}"
                description = "The default INPUT policy for {{ $labels.family }} on {{ $labels.instance }} is no longer DROP/REJECT, so anything not explicitly denied is now ACCEPTED. Note IPv6 is a separate policy and regresses independently — notrf01dmz01-04 were open on BOTH families in the 2026-07-29 finding. Fix: `ufw --force enable` (or `iptables -P INPUT DROP` / `ip6tables -P INPUT DROP`) then confirm with the probe."
                impact      = "Default-allow on an internet-facing host."
              }
            },
            {
              # The empty-skeleton signature: jumps present, chains hollow. This is
              # what `iptables -L` cannot show you at a glance.
              alert = "REDACTED_578414e4"
              expr  = "max by (instance) (edge_firewall_rule_count{family=\"ipv4\"}) < 20"
              for   = "5m"
              labels = {
                severity  = "critical"
                tier      = "1"
                category  = "host-firewall"
                service   = "edge"
                namespace = "edge-firewall"
              }
              annotations = {
                summary     = "Firewall ruleset collapsed on {{ $labels.instance }} ({{ $value }} rules)"
                description = "{{ $labels.instance }} has only {{ $value }} rules inside its ufw chains; the live baseline across the nine edge hosts is 85-135. This is the empty-skeleton signature from the 2026-07-29 finding: the INPUT jumps into ufw-* survive so `iptables -L` still renders a configured-looking host, but the chains they point at are hollow and terminate nothing. Compare `iptables -S | grep -c '^-A ufw'` against edge_firewall_input_jump_count."
                impact      = "The host presents as firewalled while filtering little or nothing."
              }
            },
            {
              # Docker publishes ports by DNAT through FORWARD; they never traverse
              # INPUT, so ufw cannot filter them and DOCKER-USER is the only control.
              # Metric is absent on the Docker-less VPS hosts, so absent() is not used.
              alert = "REDACTED_b7c28f85"
              expr  = "max by (instance) (edge_docker_user_rules) < 2"
              for   = "5m"
              labels = {
                severity  = "critical"
                category  = "host-firewall"
                service   = "edge"
                namespace = "edge-firewall"
              }
              annotations = {
                summary     = "DOCKER-USER unguarded on {{ $labels.instance }} ({{ $value }} rules)"
                description = "DOCKER-USER on {{ $labels.instance }} has {{ $value }} rules. Docker DNATs published ports in nat/PREROUTING and FORWARDs them to the container, so they NEVER traverse INPUT and ufw cannot filter them — with ufw active and INPUT DROP, published ports were still reachable from the internet until this chain was populated (confirmed by probe on 2026-07-29). Expect at least a conntrack ESTABLISHED,RELATED RETURN followed by a DROP on the public interface. Docker FLUSHES this chain on restart, which is why docker-user-guard.service exists — check it is enabled."
                impact      = "Published container ports are reachable from any source that can route to the host, bypassing ufw entirely."
              }
            },
            {
              # CrowdSec BOUNCER — the component that actually enforces bans. If the
              # engine keeps detecting but the bouncer is dead, attacks are logged and
              # NOT blocked, which looks healthy in every dashboard that counts
              # detections. Added 2026-07-29 after it was noticed that crowdsec state
              # was exported but nothing consumed it.
              #
              # Unlike ufw.service this IS a long-running daemon, so unit state is a
              # truthful signal here. The "never alert on unit state" warning at the top
              # of this file applies specifically to ufw.service being Type=oneshot.
              alert = "REDACTED_22590886"
              expr  = "max by (instance) (edge_posture_context{unit=\"crowdsec-firewall-bouncer\"}) == 0"
              for   = "5m"
              labels = {
                severity  = "critical"
                category  = "host-firewall"
                service   = "edge"
                namespace = "edge-firewall"
              }
              annotations = {
                summary     = "CrowdSec bouncer down on {{ $labels.instance }} — bans not enforced"
                description = "crowdsec-firewall-bouncer is not running on {{ $labels.instance }}. The CrowdSec engine may still be detecting and logging attacks, but nothing is inserting the block rules — so the host is being attacked, is aware of it, and is doing nothing about it. This fails silently: detection dashboards still look busy. Check `systemctl status crowdsec-firewall-bouncer` and `cscli decisions list` on the host."
                impact      = "Intrusion decisions are no longer enforced on an internet-facing host."
              }
            },
            {
              # CrowdSec engine itself — no engine, no detection at all.
              alert = "EdgeCrowdSecDown"
              expr  = "max by (instance) (edge_posture_context{unit=\"crowdsec\"}) == 0"
              for   = "5m"
              labels = {
                severity  = "warning"
                category  = "host-firewall"
                service   = "edge"
                namespace = "edge-firewall"
              }
              annotations = {
                summary     = "CrowdSec engine down on {{ $labels.instance }}"
                description = "The CrowdSec engine is not running on {{ $labels.instance }}, so no log parsing, no scenario matching and no new decisions are being produced on an internet-facing host. Existing bans may still be enforced by the bouncer until they expire. Check `systemctl status crowdsec` and its acquisition config."
                impact      = "No intrusion detection on this host."
              }
            },
            {
              # Mandatory dead-man, matching REDACTED_33f74497 /
              # REDACTED_4113c0dd. Without it a dead probe leaves stale
              # all-green metrics and silence reads as health — the precise failure
              # mode this whole effort exists to eliminate.
              alert = "REDACTED_2316d114"
              expr  = "time() - max by (instance) (edge_posture_last_run_timestamp) > 3600"
              for   = "5m"
              labels = {
                severity  = "warning"
                category  = "host-firewall"
                service   = "edge"
                namespace = "edge-firewall"
              }
              annotations = {
                summary     = "Firewall posture probe stale on {{ $labels.instance }}"
                description = "edge-posture-probe has not written fresh metrics on {{ $labels.instance }} for over an hour (timer is every 5 min). Its firewall metrics are therefore STALE and the green values above cannot be trusted — a dead check must never be mistaken for a passing one. Check `systemctl status edge-posture-probe.timer edge-posture-probe.service` and that /var/lib/prometheus/node-exporter is writable."
                impact      = "Firewall enforcement on this host is currently unmonitored."
              }
            },
          ]
        },
      ]
    }
  }
}
