# =============================================================================
# Inter-site (NL<->GR) iBGP leg health alert rules.
#
# Mirror of:
#   claude-gateway prometheus/alert-rules/intersite-bgp-mesh.yml
# When adding / changing / removing an alert, edit BOTH files. This .tf is
# the deployed truth; the YAML is the test+doc copy.
#
# Metric source (node_exporter textfile collector on nlclaude01):
#   scripts/bgp-mesh-watchdog.sh  (cron */5, IFRNLLEI01PRD-671)
#   -> /var/lib/node_exporter/textfile_collector/bgp_mesh_watchdog.prom
#
# The two inter-site legs, each an iBGP session over an IPsec VTI:
#   budget  leg: nlrtr01 Tunnel1 (10.255.200.0) <-> grfw01 vti-nl  (10.255.200.1)
#   freedom leg: nlfw01  Tunnel4 (10.255.200.10) <-> grfw01 vti-gr (10.255.200.11 = NL neighbor label)
# Alerts key on the NL-side vantage (nlrtr01 -> 10.255.200.1 and
# nlfw01 -> 10.255.200.11): the watchdog polls those devices over the
# NL-local network, so the vantage survives an inter-site partition. The
# GR-side series (grfw01 -> 10.255.200.0/.10) exist too but are polled
# over the public OOB path and can be unreachable exactly when they matter.
#
# Background: 2026-08-08 — the freedom leg's IKEv2 SA wedged (SA READY,
# child SA gone, BGP Idle) and sat silently down for 19.5 h; when the budget
# leg then degraded, the sites partitioned for ~7 h (site prefixes cannot
# transit the VPS spokes due to iBGP split-horizon). 4th occurrence of the
# silent-first-leg pattern. ASA 9.16(4) rejects BFD on VTI interfaces, so
# detection-by-alert is the durable control.
# Memory: claude-gateway memory/intersite_tunnel_degradation_email_flood_20260808.md.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_dc9f406e" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_51fe99b0"
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
          name     = "REDACTED_2eaf5fb6"
          interval = "1m"
          rules = [
            {
              # One inter-site leg has left Established. Losing one leg is
              # exactly the "first leg sat silently down" precursor state:
              # every full partition so far started this way, 19-40 h before
              # the second leg failed. 10 min for: absorbs rekey blips.
              alert = "IntersiteBGPLegDown"
              expr  = "bgp_session_state{local_host=~\"nlrtr01|nlfw01\",neighbor=~\"10\\\\.255\\\\.200\\\\.(1|11)\"} == 0"
              for   = "10m"
              labels = {
                severity = "critical"
                category = "bgp-intersite"
              }
              annotations = {
                summary     = "Inter-site BGP leg down: {{ $labels.local_host }} -> {{ $labels.neighbor }} not Established for 10+ min"
                description = "The {{ if eq $labels.neighbor \"10.255.200.1\" }}budget (nlrtr01 Tunnel1 <-> grfw01 vti-nl){{ else }}freedom (nlfw01 Tunnel4 vti-gr-f <-> grfw01 vti-gr){{ end }} inter-site leg is down. Cross-site redundancy is reduced to ONE leg — historically the second leg fails 19-40h later and partitions the sites (corosync cluster eu-nlgr-pvecl01 rides these tunnels). Check for the wedged-SA signature: 'show crypto ikev2 sa' READY but VTI ping dead and no child SA in 'show crypto ipsec sa peer'. Proven fix 2026-08-08: 'vpn-sessiondb logoff ipaddress <peer-wan-ip> noconfirm' on the NL ASA (or SA bounce on the initiator side) forces clean renegotiation. Memory: intersite_tunnel_degradation_email_flood_20260808.md."
              }
            },
            {
              # BOTH legs down = active inter-site partition. Site prefixes
              # cannot transit the VPS spokes (iBGP split-horizon), so this
              # is a hard NL<->GR outage: corosync loses the GR nodes, GR
              # loses quorum, cross-site monitoring goes dark both ways.
              alert = "IntersiteBGPPartition"
              expr  = "sum(bgp_session_state{local_host=~\"nlrtr01|nlfw01\",neighbor=~\"10\\\\.255\\\\.200\\\\.(1|11)\"}) == 0"
              for   = "5m"
              labels = {
                severity = "critical"
                tier     = "1"   # 2026-08-25 ntfy cutover: total NL<->GR partition pages
                page     = "sms" # ULTRA-urgent (operator decision 2026-08-25)
                category = "bgp-intersite"
              }
              annotations = {
                summary     = "Inter-site PARTITION: both NL<->GR BGP legs down for 5+ min"
                description = "Both the budget (rtr01) and freedom (nlfw01) inter-site legs are down simultaneously — NL and GR are partitioned for site prefixes. Expect: corosync knet loss to gr-pve01/02 (GR side loses quorum, pmxcfs read-only), cross-site LibreNMS device-down storms from both NMS instances, GR K8s clustermesh degradation. Diagnose per-leg (wedged SA vs WAN loss) and bounce the wedged SA first: vpn-sessiondb logoff on the ASA / clear crypto session on nlrtr01. Memory: intersite_tunnel_degradation_email_flood_20260808.md."
              }
            },
            {
              # Broad mesh coverage: any of the 52 expected iBGP sessions
              # missing. Catches VPS-spoke and FRR legs too. Long for:
              # keeps this a tidy-up signal rather than a pager.
              alert = "BGPMeshSessionsMissing"
              expr  = "bgp_mesh_missing_count > 0"
              for   = "30m"
              labels = {
                severity = "warning"
                category = "bgp-intersite"
              }
              annotations = {
                summary     = "{{ $value }} iBGP mesh session(s) missing for 30+ min"
                description = "bgp-mesh-watchdog.sh reports {{ $value }} of the 52 expected iBGP sessions not Established for 30+ min. Check bgp_session_state{} == 0 series in Prometheus to identify which (local_host, neighbor) pairs are down, then diagnose the corresponding tunnel/host."
              }
            },
            {
              # Dead-man for the watchdog itself. absent() clause closes the
              # no-data=no-alert hole (watchdog-deadman lesson): if the cron
              # dies or the textfile stops refreshing we must hear about it,
              # because every rule above goes silently blind at that moment.
              alert = "REDACTED_912b16d4"
              expr  = "(time() - bgp_mesh_last_run_timestamp) > 1800 or absent(bgp_mesh_last_run_timestamp)"
              for   = "5m"
              labels = {
                severity = "warning"
                category = "bgp-intersite"
              }
              annotations = {
                summary     = "bgp-mesh-watchdog metrics stale for 30+ min — inter-site BGP alerting is blind"
                description = "bgp_mesh_watchdog.prom on nlclaude01 has not been refreshed for 30+ min (cron */5 — 6 missed cycles) or the metric is absent entirely. IntersiteBGPLegDown / IntersiteBGPPartition cannot fire while this persists. Check the claude-runner cron and scripts/bgp-mesh-watchdog.sh on nlclaude01, and node_exporter textfile collection."
              }
            },
          ]
        },
      ]
    }
  }
}
