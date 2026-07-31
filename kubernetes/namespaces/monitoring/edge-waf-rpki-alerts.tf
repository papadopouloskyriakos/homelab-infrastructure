# =============================================================================
# Edge WAF (CrowdSec AppSec/SPOA) + RPKI ROV alerting
#
# Closes the last gap identified in the 2026-07-31 edge security audit.
#
# The CrowdSec AppSec WAF went live on all three VPS on 2026-07-30 and RPKI Route
# Origin Validation on 2026-07-31. NEITHER HAD ANY ALERTING. The SPOA bouncer's
# Prometheus endpoint is bound to 127.0.0.1:60601 and nothing scraped it; FRR's RPKI
# cache state is not exported by frr_exporter at all.
#
# BOTH CONTROLS FAIL OPEN, which is why silence is dangerous:
#   * `option set-on-error error` in /etc/haproxy/crowdsec.cfg means a dead or slow SPOA
#     agent leaves txn.crowdsec.remediation unset — traffic passes UNEVALUATED. That is
#     the correct availability trade-off, and it is exactly why it must be alerted.
#   * With no RTR cache session, every route becomes `notfound` instead of `invalid`, so
#     the `match rpki invalid` deny stops dropping hijacked prefixes.
#
# In both cases the estate keeps serving happily while the control is gone — the shape of
# every incident in this estate's history: the empty ufw chains that rendered as a
# configured firewall, three months of PartiallyFailed Velero backups, a 19h inter-site
# BGP outage nobody saw.
#
# Fed by edge/_tools/waf-rpki-probe.sh (10-min timer on each VPS, node_exporter textfile
# collector). The probe asserts ENFORCEMENT, not liveness: it fires a real attack payload
# at the AppSec engine and requires 403, and a benign request and requires 200. It uses
# source IP 192.0.2.66 (RFC 5737 documentation range) against the AppSec API directly, so
# it creates NO CrowdSec decision and cannot ban anything — unlike attacking a peer, which
# bans that peer and tears down the IPsec mesh and its iBGP session (proven live
# 2026-07-30, CH<->TX BGP reset to 8m uptime).
#
# FIVE TRAPS THESE RULES DELIBERATELY AVOID — do not "simplify" them:
#
#  A) `systemctl is-active` is NOT proof of enforcement. A running SPOA agent that HAProxy
#     never consults protects nothing. EdgeWafNotWired keys on the live haproxy.cfg
#     containing `filter spoe engine crowdsec` — because on 2026-07-31 a config transform
#     silently missed its anchor on notrf01vps01 and `haproxy -c` happily validated the
#     UNMODIFIED file. Syntax validity proves nothing about semantics.
#
#  B) reachable == 0 is UNKNOWN, not healthy. If the AppSec engine does not answer, the
#     blocks/allows gauges are meaningless — hence REDACTED_41c52c37 is its own
#     alert and the enforcement rules are qualified on reachability.
#
#  C) A dead probe leaves the LAST value behind. node_exporter serves the .prom file until
#     it is rewritten, so a crashed probe leaves healthy 1s frozen in place forever.
#     REDACTED_b5622ab0 is mandatory, not decoration.
#
#  D) If the probe is removed everywhere there are no series left to be 0, so a rule keyed
#     only on `== 0` goes silent. REDACTED_523d348a uses absent().
#
#  E) Do NOT scope by job. The VPS are scraped under `node-exporter-edge` today, but
#     notrf01dmz01-04 sit in `omoikane-node` — the same estate-wide inconsistency
#     documented in edge-firewall-alerts.tf. Expressions here aggregate by instance and
#     never name a job.
#
# tier="1" + severity="critical" is the Twilio SMS route (main.tf alertmanager route ->
# 10.0.X.X:9106). Applied only to the two that mean "the control protecting every
# public site is GONE": EdgeWafNotEnforcing and EdgeWafNotWired. RPKI failing open is
# serious but degrades to pre-2026-07-31 behaviour, so it alerts as `warning`.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_ab779e5c" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_e754d835"
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
          name     = "edge-waf-rpki"
          interval = "1m"
          rules = [
            {
              # THE alert: the WAF answered, and did NOT block a known-bad payload.
              # Qualified on reachable==1 so an unreachable engine fires the separate
              # UNKNOWN alert instead of this one (trap B).
              alert = "EdgeWafNotEnforcing"
              expr  = "edge_waf_appsec_blocks_attack == 0 and edge_waf_appsec_reachable == 1"
              for   = "10m"
              labels = {
                severity = "critical"
                tier     = "1"
                team     = "infra"
                scope    = "edge"
              }
              annotations = {
                summary     = "Edge WAF is NOT blocking attacks on {{ $labels.instance }}"
                description = <<-EOT
                  The CrowdSec AppSec engine on {{ $labels.instance }} answered the probe but did
                  NOT return 403 for a known-blocked payload (PHPUnit RCE path). The WAF is up and
                  permitting attacks - every public hostname on this node is unprotected at the
                  payload layer.

                  This is enforcement, not liveness: the engine is reachable, so this is a rules or
                  configuration regression, not a crash.

                  Check: sudo cscli metrics show appsec ; ls /etc/crowdsec/appsec-rules/ | wc -l
                  (expected ~197). Re-probe by hand with the documented 192.0.2.66 engine probe in
                  edge/CLAUDE.md - never by attacking from a peer VPS, which bans the peer and
                  drops the IPsec mesh.
                EOT
              }
            },
            {
              # The WAF is running but HAProxy is not consulting it. Config-level, and
              # invisible to any process check (trap A).
              alert = "EdgeWafNotWired"
              expr  = "edge_waf_spoe_filters == 0 or edge_waf_spoa_backend == 0"
              for   = "10m"
              labels = {
                severity = "critical"
                tier     = "1"
                team     = "infra"
                scope    = "edge"
              }
              annotations = {
                summary     = "HAProxy is not consulting the WAF on {{ $labels.instance }}"
                description = <<-EOT
                  The live /etc/haproxy/haproxy.cfg on {{ $labels.instance }} is missing either the
                  `filter spoe engine crowdsec` line or the `backend crowdsec-spoa` block. The SPOA
                  agent may be perfectly healthy - HAProxy simply never asks it, so no request is
                  evaluated by the WAF.

                  This is the failure mode a process check cannot see. It happened on 2026-07-31: a
                  config transform missed its insertion anchor on notrf01vps01 and `haproxy -c`
                  validated the unmodified file as correct.

                  Check: grep -c 'filter spoe engine crowdsec' /etc/haproxy/haproxy.cfg
                  Repo copy: edge/vps/<host>/haproxy/haproxy.cfg
                EOT
              }
            },
            {
              # Engine not answering at all - UNKNOWN state, and fail-open means traffic
              # is passing unevaluated right now.
              alert = "REDACTED_41c52c37"
              expr  = "edge_waf_appsec_reachable == 0"
              for   = "10m"
              labels = {
                severity = "critical"
                team     = "infra"
                scope    = "edge"
              }
              annotations = {
                summary     = "CrowdSec AppSec engine unreachable on {{ $labels.instance }}"
                description = <<-EOT
                  The AppSec engine on 127.0.0.1:7422 did not answer the probe on
                  {{ $labels.instance }}. WAF enforcement state is UNKNOWN - and because
                  `option set-on-error error` makes SPOE fail open, requests are almost certainly
                  passing unevaluated right now.

                  Check: systemctl status crowdsec ; ss -tlnp | grep 7422 ;
                  cat /etc/crowdsec/acquis.d/appsec.yaml
                EOT
              }
            },
            {
              # Over-blocking is an outage in the other direction.
              alert = "EdgeWafOverBlocking"
              expr  = "edge_waf_appsec_allows_benign == 0 and edge_waf_appsec_reachable == 1"
              for   = "10m"
              labels = {
                severity = "warning"
                team     = "infra"
                scope    = "edge"
              }
              annotations = {
                summary     = "Edge WAF is blocking benign requests on {{ $labels.instance }}"
                description = <<-EOT
                  The AppSec engine on {{ $labels.instance }} returned a non-200 verdict for a
                  benign URI (/index.html). Legitimate visitors are likely being blocked.

                  Most often caused by adding a broad ruleset (e.g. crowdsecurity/appsec-crs) whose
                  false-positive rate the narrow default vpatch/generic set does not have.
                  Check: sudo cscli metrics show appsec ; recent changes under /etc/crowdsec/appsec-*
                EOT
              }
            },
            {
              # SPOA daemon dead. Distinct from NotWired: config is right, agent is gone.
              alert = "EdgeWafSpoaDown"
              expr  = "edge_waf_spoa_active == 0 or edge_waf_crowdsec_active == 0"
              for   = "10m"
              labels = {
                severity = "critical"
                team     = "infra"
                scope    = "edge"
              }
              annotations = {
                summary     = "CrowdSec SPOA bouncer or engine down on {{ $labels.instance }}"
                description = <<-EOT
                  crowdsec-spoa-bouncer or crowdsec is not active on {{ $labels.instance }}. SPOE
                  fails open, so HAProxy keeps serving with no WAF evaluation and no IP remediation.

                  Check: systemctl status crowdsec-spoa-bouncer crowdsec ;
                  journalctl -u crowdsec-spoa-bouncer -n 50 ;
                  /usr/bin/crowdsec-spoa-bouncer -c /etc/crowdsec/bouncers/crowdsec-spoa-bouncer.yaml -t
                EOT
              }
            },
            {
              # RPKI fail-open. Degrades to pre-2026-07-31 behaviour, so warning not SMS.
              alert = "EdgeRpkiCacheDown"
              expr  = "edge_rpki_cache_connected == 0 and edge_rpki_module_loaded == 1"
              for   = "15m"
              labels = {
                severity = "warning"
                team     = "infra"
                scope    = "edge"
              }
              annotations = {
                summary     = "RPKI RTR cache disconnected on {{ $labels.instance }}"
                description = <<-EOT
                  FRR on {{ $labels.instance }} has no live RTR cache session, so every received
                  route is now `notfound` rather than `invalid` and the `match rpki invalid` deny
                  drops nothing. Route Origin Validation has silently stopped protecting this node.

                  rtr.rpki.cloudflare.com:8282 is the ONLY configured cache - NTT's public RTR
                  (rtr.rpki.ntt.net) no longer resolves at all, so there is no fallback.

                  The cache can take over a minute to reconnect after an FRR restart; the 15m `for`
                  covers that. Check: vtysh -c 'show rpki cache-connection' (expect "Connected to
                  group 1"; do NOT grep for a "(connected)" suffix, it is not always printed) ;
                  vtysh -c 'show rpki prefix-table' | grep 'Number of'
                EOT
              }
            },
            {
              # Module gone => the deny rules reference validation that cannot happen.
              alert = "REDACTED_17cb083c"
              expr  = "edge_rpki_module_loaded == 0"
              for   = "15m"
              labels = {
                severity = "warning"
                team     = "infra"
                scope    = "edge"
              }
              annotations = {
                summary     = "FRR RPKI module not loaded on {{ $labels.instance }}"
                description = <<-EOT
                  bgpd on {{ $labels.instance }} is not running with `-M rpki`, so RPKI validation
                  is not happening at all and the `match rpki invalid` route-map entries match
                  nothing.

                  Usually an FRR package upgrade that reset /etc/frr/daemons. Check:
                  grep bgpd_options /etc/frr/daemons (expect `-M rpki`) ;
                  dpkg -l frr-rpki-rtrlib (must match the frr version exactly) ;
                  ls /usr/lib/x86_64-linux-gnu/frr/modules/bgpd_rpki.so
                  Requires `systemctl restart frr` - a reload will NOT load a module.
                EOT
              }
            },
            {
              # ROA table collapsed while still "connected" - a cache serving nothing.
              alert = "REDACTED_c54e59f2"
              # `on(instance)` is load-bearing: the left side carries family="ipv6" and the
              # right side does not, so a bare `and` matches on the full label set, finds no
              # pair, and the rule can NEVER fire. Caught by testing the inverted expression
              # against live Prometheus before shipping — it returned 0 series while all
              # three nodes were healthy and should have matched.
              expr = "edge_rpki_roa_prefixes{family=\"ipv6\"} < 1000 and on(instance) edge_rpki_cache_connected == 1"
              for  = "15m"
              labels = {
                severity = "warning"
                team     = "infra"
                scope    = "edge"
              }
              annotations = {
                summary     = "RPKI ROA table nearly empty on {{ $labels.instance }}"
                description = <<-EOT
                  {{ $labels.instance }} reports a live RTR session but only {{ $value }} IPv6 ROA
                  prefixes (healthy baseline is ~230,000). A connected cache serving no data
                  validates nothing while looking healthy - the same "control present but empty"
                  shape as the ufw chains with zero rules.

                  Check: vtysh -c 'show rpki prefix-table' | grep 'Number of' ;
                  vtysh -c 'show rpki cache-connection'
                EOT
              }
            },
            {
              # Trap C: a dead probe freezes healthy values in place forever.
              alert = "REDACTED_b5622ab0"
              expr  = "time() - max by (instance) (edge_waf_rpki_last_run_timestamp) > 3600"
              for   = "5m"
              labels = {
                severity = "warning"
                team     = "infra"
                scope    = "edge"
              }
              annotations = {
                summary     = "WAF/RPKI probe stale on {{ $labels.instance }}"
                description = <<-EOT
                  waf-rpki-probe.sh has not completed on {{ $labels.instance }} for over an hour
                  (10-min timer). Every edge_waf_* and edge_rpki_* metric for this host is now
                  STALE and still reading healthy, because node_exporter keeps serving the last
                  .prom file until it is rewritten.

                  Check: systemctl status edge-waf-rpki-probe.timer edge-waf-rpki-probe.service ;
                  journalctl -u edge-waf-rpki-probe -n 50
                EOT
              }
            },
            {
              # Trap D: everything removed => no series left to be 0.
              alert = "REDACTED_523d348a"
              expr  = "absent(edge_waf_appsec_blocks_attack)"
              for   = "15m"
              labels = {
                severity = "critical"
                team     = "infra"
                scope    = "edge"
              }
              annotations = {
                summary     = "Edge WAF/RPKI verification has disappeared entirely"
                description = <<-EOT
                  edge_waf_appsec_blocks_attack has no series at all. Either waf-rpki-probe.sh was
                  removed from every VPS, the node_exporter textfile collector is not reading
                  /var/lib/prometheus/node-exporter/, or the VPS scrape target was dropped.

                  This is the failure mode where a missing check looks identical to a passing one -
                  the exact shape that let notrf01dmz01-04 sit unfirewalled for months while the
                  daily report read CLEAN.

                  Verify on a VPS: systemctl list-timers edge-waf-rpki-probe.timer ;
                  cat /var/lib/prometheus/node-exporter/edge_waf_rpki_state.prom
                EOT
              }
            },
          ]
        },
      ]
    }
  }
}
