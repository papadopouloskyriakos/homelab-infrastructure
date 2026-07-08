# =============================================================================
# DMZ Freedom-SA health + mesh iBGP/BFD alert rules  (IFRNLLEI01PRD-1643)
#
# Closes the monitoring gap from the 2026-07-06 incident: a half-dead
# nl-freedom IPsec SA on a notrf01dmz0X host (IKE ESTABLISHED + xfrm iface UP
# but ESP data-plane dead) black-holed the iBGP path to the NL route
# reflectors for ~4h with NO alert. Two metric sources are now watched:
#
#  1) freedom-sa-watchdog.sh (cron */1 on notrf01dmz01..04, scraped via the
#     node_exporter textfile collector under Prometheus job "omoikane-node").
#     It probes the Freedom tunnel data-plane and auto-rekeys a stale SA
#     (automating the proven `swanctl --terminate --ike nl-freedom` recovery).
#     Script + design: infrastructure edge/dmz/_tools/freedom-sa-watchdog.sh.
#
#  2) frr_exporter (:9342) on the route reflectors + VPS edge nodes
#     (jobs "frr-route-reflectors" / "frr-edge-nodes" in main.tf) — the
#     general per-peer iBGP + BFD session state, previously scraped but
#     UN-alerted (only Gatus aggregate counts consumed it).
#
# The 10.0.X.X / 10.0.X.X BFD peers are the NL/GR ASAs, which cannot
# run BFD (ASA 9.16) — their frr_bfd_peer_state is permanently 0 and is
# excluded from MeshBFDSessionDown so it is not a chronic false positive.
#
# Memory: claude-gateway memory/dmz02_bgp_audit_nexthopself_redherring_20260708.md
# =============================================================================

resource "kubernetes_manifest" "REDACTED_d6d62266" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_94437340"
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
          name     = "REDACTED_47434f39"
          interval = "1m"
          rules = [
            {
              # The watchdog cannot reach the Freedom tunnel far-end OR RR1
              # over xfrm-nl-freedom -> ESP data-plane black-holed. The
              # watchdog is force-rekeying it; alert so a human is aware.
              alert = "REDACTED_5718a3e1"
              expr  = "freedom_sa_watchdog_freedom_reachable == 0"
              for   = "3m"
              labels = {
                severity = "warning"
                category = "mesh-ipsec"
              }
              annotations = {
                summary     = "notrf01dmz Freedom data-plane black-holed ({{ $labels.instance }})"
                description = "freedom-sa-watchdog on {{ $labels.instance }} has been unable to reach the nl-freedom tunnel far-end or RR1 over xfrm-nl-freedom for 3+ min = a half-dead/black-holed ESP SA (the IFRNLLEI01PRD-1643 failure class). If the watchdog is armed it is force-rekeying (`swanctl --terminate --ike nl-freedom`); a matching REDACTED_bd0c7e2f should follow. If this persists >10 min the auto-rekey is NOT clearing it — check the nl-freedom SA and the Freedom WAN. Runbook: claude-gateway memory/dmz02_bgp_audit_nexthopself_redherring_20260708.md."
              }
            },
            {
              # The watchdog fired a forced re-key in the last 15 min = a real
              # half-dead SA was auto-recovered. Recurrence => upstream Freedom
              # instability worth chasing at the ISP/underlay.
              alert = "REDACTED_bd0c7e2f"
              expr  = "increase(freedom_sa_watchdog_terminate_total[15m]) > 0"
              for   = "0m"
              labels = {
                severity = "warning"
                category = "mesh-ipsec"
              }
              annotations = {
                summary     = "Freedom-SA watchdog auto-rekeyed a stale SA on {{ $labels.instance }}"
                description = "The IFRNLLEI01PRD-1643 auto-recovery fired: freedom-sa-watchdog force-terminated a half-dead nl-freedom IKE SA on {{ $labels.instance }} in the last 15 min so strongSwan re-established a fresh SA. The incident self-healed, but investigate WHY the SA went stale — repeated firings mean the Freedom underlay/ISP is flapping and the tunnel keeps half-dying."
              }
            },
            {
              # Dead-man for the watchdog cron itself (who-watches-the-watchdog).
              alert = "REDACTED_4113c0dd"
              expr  = "time() - freedom_sa_watchdog_last_run_timestamp > 900"
              for   = "5m"
              labels = {
                severity = "warning"
                category = "mesh-ipsec"
              }
              annotations = {
                summary     = "Freedom-SA watchdog stopped running on {{ $labels.instance }}"
                description = "freedom_sa_watchdog_last_run_timestamp on {{ $labels.instance }} is >15 min old — the */1 cron has stopped, so the -1643 auto-recovery + black-hole detection is dark on this host. Check the root crontab and /usr/local/sbin/freedom-sa-watchdog.sh on the host."
              }
            },
            {
              # nl-freedom IKE itself is DOWN (not half-dead) — a genuine
              # Freedom outage. The watchdog deliberately does NOT rekey a
              # down SA (charon/DPD re-establishes); budget failover should
              # be carrying traffic. Informational so it isn't confused with
              # the half-dead case.
              alert = "DMZFreedomIKEDown"
              expr  = "freedom_sa_watchdog_ike_established == 0"
              for   = "5m"
              labels = {
                severity = "warning"
                category = "mesh-ipsec"
              }
              annotations = {
                summary     = "nl-freedom IKE SA down on {{ $labels.instance }}"
                description = "The nl-freedom IKE SA on {{ $labels.instance }} is not ESTABLISHED for 5+ min — a real Freedom-path outage (distinct from the half-dead case; the watchdog will not force-rekey a down SA). Verify the Freedom WAN and that the budget path (via nlrtr01) is carrying the omoikane traffic."
              }
            },
          ]
        },
        {
          name     = "mesh-ibgp-bfd"
          interval = "1m"
          rules = [
            {
              # A route-reflector or VPS-edge iBGP session left Established.
              alert = "MeshiBGPPeerDown"
              expr  = "frr_bgp_peer_state != 1"
              for   = "10m"
              labels = {
                severity = "warning"
                category = "mesh-bgp"
              }
              annotations = {
                summary     = "iBGP peer {{ $labels.peer }} down on {{ $labels.instance }}"
                description = "frr_bgp_peer_state for peer {{ $labels.peer }} (AS {{ $labels.peer_as }}) on {{ $labels.instance }} has not been Established for 10+ min. This is the AS65000 tunnel mesh (route reflectors + VPS edge). Check the tunnel/IPsec SA carrying that session."
              }
            },
            {
              # A BFD session that should be up went down = sub-second
              # data-plane liveness failure. Excludes the NL/GR ASAs
              # (10.0.X.X / 10.0.X.X) which cannot run BFD.
              alert = "MeshBFDSessionDown"
              expr  = "frr_bfd_peer_state{peer!~\"10.0.X.X|10.0.X.X\"} == 0"
              for   = "5m"
              labels = {
                severity = "warning"
                category = "mesh-bfd"
              }
              annotations = {
                summary     = "BFD session down: {{ $labels.local }} <-> {{ $labels.peer }}"
                description = "A BFD-monitored iBGP session ({{ $labels.local }} <-> {{ $labels.peer }}) has BFD down for 5+ min. BFD exercises the ESP data-plane, so a down BFD session that used to be up signals a black-holed tunnel even while the interface stays up. (ASA peers are excluded — ASA 9.16 has no BFD.)"
              }
            },
          ]
        },
      ]
    }
  }
}
