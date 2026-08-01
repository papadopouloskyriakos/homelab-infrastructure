# =============================================================================
# Edge source-IP-gated CONTROL VERIFICATION alerts
#
# Closes the blind spot found on 2026-07-30 while triaging the daily security scan.
#
# On 2026-07-29 a rule was added to all three VPS denying /metrics to the internet
# (`http-request deny deny_status 404 if is_metrics_path !whitelisted_ip`), because
# hub.meshsat.net/metrics was serving 64 metric families and app.omoikane.coach/metrics
# 208 — AI token spend, GDPR request cascades, internal methodology — unauthenticated,
# on a commercial SaaS.
#
# NOTHING COULD CONFIRM THAT RULE STILL WORKS, and the existing scanners structurally
# never can. `whitelisted_ip` is exactly three source IPs — 203.0.113.X (NL ASA),
# 91.211.213.72 (GR ASA), 145.53.163.13 (NL Budget/rtr01). nlsec01 egresses via the
# first and grsec01 via the second, so BOTH scanners sit inside the control's own
# exemption set and see HTTP 200 forever. Verified 2026-07-30: claude-runner (via
# 203.0.113.X) received 200 with a real metrics body while txhou01vps01 received 404
# for the identical URL. So a regression — someone deleting the deny, or reordering it
# after the rate-limit stick-table — would have been invisible to every existing check,
# and the daily scan would have kept reporting it as the known false positive it is.
#
# Fed by edge/_tools/control-probe.sh, which runs ON each VPS (10-min timer) and probes
# its PEERS' public IPs. VPS public IPs are NOT in whitelisted_ip, so a peer sees exactly
# what the internet sees; they ARE in CrowdSec's `omoikane-trusted` allowlist with
# `never` expiry, so probing does not get the prober banned.
#
# This asserts a control is PRESENT — the inverse of what a scanner does. A scanner
# reports what it can reach, so absence of a finding is ambiguous: it could mean the
# control works, or that nothing looked. Here, "failed to deny" is itself the alarm.
# Same lesson as the empty ufw chains: verify enforcement, never configuration.
#
# ⚠ FOUR TRAPS THESE RULES DELIBERATELY AVOID — do not "simplify" them:
#
#  A) Aggregate with min(), never avg(). Each control is probed from TWO independent
#     peers. If one vantage is served while another is denied, that is a real partial
#     regression (one VPS's haproxy.cfg drifted) — avg() would smear it to 0.5 and hide
#     it. min() fires if ANY untrusted vantage got through.
#
#  B) reachable == 0 is UNKNOWN, not healthy. If a peer is down, the probe emits no
#     edge_control_denied for it at all. A rule keyed only on `== 0` would go quiet, and
#     quiet must never read as pass — hence the staleness and absent() rules below.
#
#  C) A dead probe leaves the LAST value behind. node_exporter keeps serving the .prom
#     file until it is rewritten, so a crashed probe leaves 1s (healthy) frozen in place
#     forever. REDACTED_79d3915a is mandatory, not optional decoration.
#
#  D) Do NOT scope by job. The VPS are scraped under the edge node-exporter job today,
#     but notrf01dmz01-04 sit in `omoikane-node` — the same estate-wide inconsistency
#     documented in edge-firewall-alerts.tf. Expressions here aggregate by instance/host
#     and never name a job.
#
# tier="1" + severity="critical" is the Twilio SMS route (main.tf alertmanager route ->
# 10.0.X.X:9106). Applied to REDACTED_06ec64ac because it means a control the
# estate believes is protecting an unauthenticated telemetry endpoint on a commercial
# SaaS has silently stopped protecting it.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_c209409f" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_3e0dafbe-alert-rules"
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
          name     = "REDACTED_3e0dafbe"
          interval = "1m"
          rules = [
            {
              # THE alert. min() per host+path so a single leaking vantage fires (trap A).
              alert = "REDACTED_06ec64ac"
              expr  = "min by (host, path) (edge_control_denied) == 0"
              for   = "10m"
              labels = {
                severity  = "critical"
                tier      = "1"
                category  = "edge-control"
                service   = "edge"
                namespace = "edge-firewall"
              }
              annotations = {
                summary     = "Edge control GONE: {{ $labels.host }}{{ $labels.path }} is being served to untrusted sources"
                description = "A VPS probing a PEER VPS's public IP received a success response for {{ $labels.host }}{{ $labels.path }}, which must be denied to anything outside the whitelisted_ip ACL. The HAProxy rule has been removed, or reordered after the rate-limit stick-table so it no longer evaluates. Check on each VPS: grep -n -A2 'is_metrics_path' /etc/haproxy/haproxy.cfg, and confirm the deny sits BEFORE the stick-table lines. ⚠ Do NOT verify from claude-runner or either scanner — all three egress whitelisted IPs (203.0.113.X / 91.211.213.72) and will see 200 even when the control is working correctly. Reproduce from a VPS: curl -sk --resolve {{ $labels.host }}:443:<other-vps-public-ip> https://{{ $labels.host }}{{ $labels.path }} -o /dev/null -w '%%{http_code}'."
                impact      = "An unauthenticated telemetry endpoint is exposed to the internet. hub.meshsat.net/metrics previously served 64 metric families and app.omoikane.coach/metrics 208, including AI token spend, provider fallbacks, GDPR request cascades and internal methodology design — on a commercial SaaS."
              }
            },
            {
              # Trap C: node_exporter keeps serving the last .prom, so a dead probe leaves
              # healthy 1s frozen in place. Without this, "probe died" reads as "all clear".
              alert = "REDACTED_79d3915a"
              expr  = "time() - max by (instance) (edge_control_last_run_timestamp) > 3600"
              for   = "10m"
              labels = {
                severity  = "warning"
                category  = "edge-control"
                service   = "edge"
                namespace = "edge-firewall"
              }
              annotations = {
                summary     = "Edge control probe stale on {{ $labels.instance }} ({{ $value | humanizeDuration }} since last run)"
                description = "control-probe.sh has not completed on {{ $labels.instance }} for over an hour (10-min timer). Its edge_control_denied metrics are now STALE and still reading healthy, because node_exporter keeps serving the last .prom file until it is rewritten. Check: systemctl status edge-control-probe.timer edge-control-probe.service; journalctl -u edge-control-probe -n 50."
                impact      = "Source-IP-gated edge controls are no longer being verified from this vantage. A regression would not be detected."
              }
            },
            {
              # Trap B/C combined: if every probe stops, there are no series left to be 0,
              # so REDACTED_06ec64ac cannot fire and REDACTED_79d3915a has no
              # instance to attach to. absent() is the only thing that catches total loss.
              alert = "REDACTED_9ab9d42d"
              expr  = "absent(edge_control_denied)"
              for   = "30m"
              labels = {
                severity = "critical"
                # tier = "1"  # SMS-disabled 2026-08-01 (operator SMS triage — uncomment to re-page)
                category  = "edge-control"
                service   = "edge"
                namespace = "edge-firewall"
              }
              annotations = {
                summary     = "Edge control verification has stopped entirely — no probe is reporting"
                description = "edge_control_denied has no series at all. Either control-probe.sh was removed from every VPS, the node_exporter textfile collector is not reading /var/lib/prometheus/node-exporter/, or the VPS scrape target was dropped. This is the failure mode where a missing check looks identical to a passing one — the exact shape that let notrf01dmz01-04 sit unfirewalled for months while the daily report read CLEAN. Verify on a VPS: systemctl list-timers edge-control-probe.timer and cat /var/lib/prometheus/node-exporter/edge_control_state.prom."
                impact      = "No untrusted-vantage verification of any source-IP-gated edge control. Regressions are undetectable."
              }
            },
          ]
        },
      ]
    }
  }
}
