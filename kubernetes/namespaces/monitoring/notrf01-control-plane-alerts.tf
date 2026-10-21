# =============================================================================
# notrf01 control plane as the HUB sees it (IFRNLLEI01PRD-2950, 21 October 2026)
#
# NL-ONLY, mirror-exempt (scripts/k8s-mirror-exempt.txt). Evaluated on the NL
# Prometheus over the series the notrf01 satellite remote-writes (counters and
# gauges arrive; *_bucket histograms do not, so no quantiles here). The NO
# satellite already evaluates the stock `etcd` group locally; mirroring these
# rules there would fire every event twice.
#
# Why these exist: on 21 October 2026 a four-minute packet loss inside the
# Terrahost Sandefjord network broke the raft stream between the etcd leader
# (dmz03) and the member on dmz05. The leader logged `dropped internal Raft
# message since sending buffer is full` 3823 times in 0.4 s and `peer became
# inactive (EOF)`; the member saw 31 leader changes in a quarter hour; its
# kube-apiserver died twice; three nodes went NotReady; every leader-election
# controller restarted; the CNPG primaries on dmz05 restarted; the Hub answered
# 503 behind all three edges for six minutes. The stock rule
# `etcdHighNumberOfLeaderChanges` fired, warning and untiered, so nobody was
# told. The page that did arrive named a VPS.
#
# The notrf01 etcd peers talk over per-pair xfrm tunnels (10.255.7.11 dmz03,
# 10.255.8.11 dmz04, 10.255.9.11 dmz05), so IPsec or provider loss between those
# three hosts IS raft loss. Member ids as of 21 October 2026 (stable until a
# member is re-added): 6b47e61344c4765e = dmz03 (leader), 3fd1b885d57404a9 =
# dmz04, a3c7b5cb20ec84a8 = dmz05.
#
# Negative control at authoring: `etcd_network_peer_sent_failures_total` grew by
# 0 in every hour of the preceding day except the incident hour (3133 + 870 in
# the two 5-minute windows that cover it), so the threshold of 20 per 5 minutes
# has no quiet-time noise to fire on.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_69ccfedd" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_77004c38-alert-rules"
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
          name     = "REDACTED_77004c38"
          interval = "1m"
          rules = [
            {
              # tier 1 (ntfy, no SMS): the cause, three minutes before the Hub
              # alert that is its consequence. A member that cannot deliver raft
              # messages to a peer is about to lose its API server and every pod
              # that holds a lease on that node.
              alert = "REDACTED_d7c59693"
              expr  = "sum by (instance, To) (increase(etcd_network_peer_sent_failures_total{cluster=\"notrf01\"}[5m])) > 20"
              for   = "1m"
              labels = {
                severity = "critical"
                service  = "REDACTED_77004c38"
                tier     = "1"
              }
              annotations = {
                summary     = "notrf01 etcd member {{ $labels.instance }} cannot deliver raft messages to peer {{ $labels.To }} ({{ $value | printf \"%.0f\" }} failures in 5m)"
                description = <<-EOT
                  The etcd member at {{ $labels.instance }} failed to send raft messages to peer id {{ $labels.To }} (6b47e61344c4765e = dmz03, 3fd1b885d57404a9 = dmz04, a3c7b5cb20ec84a8 = dmz05). The peers talk over per-pair xfrm tunnels, so this is the overlay between the control-plane hosts losing packets: on 21 October 2026 it was the Terrahost network itself (TCP retransmits spiked on five of six hosts at once, no steal, no OOM, no rekey).

                  Expect within three minutes, in this order: the isolated member loses the leader, its kube-apiserver dies on `storage readiness`, its node and any node whose kubelet was pinned to that API server go NotReady, every leader-election controller restarts, the CNPG primaries on that node restart, the Hub crash-loops on `postgres connection failed` and MeshSatBackendDown fires for every edge.

                  Check: `kubectl --context notrf01 get nodes`; `kubectl --context notrf01 -n kube-system logs etcd-notrf01dmz0N --since=10m | grep -E "peer became|EOF|i/o timeout|elect"`; `rate(node_netstat_Tcp_RetransSegs{cluster="notrf01"}[1m])` per node; `ping` the peer overlay address from the member's host; `swanctl --list-sas` on both hosts for the pair tunnel. Nothing on a VPS causes this. Post-mortem: IFRNLLEI01PRD-2950.
                EOT
              }
            },
            {
              # Warning, untiered: the same event seen from the member's side.
              # max by (instance): the remote-written series carry both satellite
              # replica labels, so without it one event would alert twice.
              # It is
              # with the stock etcdHighNumberOfLeaderChanges semantics but per
              # member and with the notrf01 runbook. Keeps firing for the full
              # 15-minute window, which is useful after the burst above has
              # already resolved.
              alert = "REDACTED_6c595701"
              expr  = "max by (instance) (increase(etcd_server_leader_changes_seen_total{cluster=\"notrf01\"}[15m])) >= 3"
              for   = "2m"
              labels = {
                severity = "warning"
                service  = "REDACTED_77004c38"
              }
              annotations = {
                summary     = "notrf01 etcd member {{ $labels.instance }} saw {{ $value | printf \"%.0f\" }} leader changes in 15m"
                description = "A member that keeps losing and re-finding the leader is one whose peer link stalls (see REDACTED_d7c59693) or whose disk is too slow to keep up (`apply request took too long` in its log with seconds, not hundreds of milliseconds). dmz05 is the member that runs the hub and tak Postgres primaries next to etcd and is the one that flapped on 21 October 2026. Post-mortem: IFRNLLEI01PRD-2950."
              }
            },
            {
              # Negative control: while this fires, the two rules above are blind.
              alert = "REDACTED_8f6d2964"
              expr  = "absent(etcd_server_has_leader{cluster=\"notrf01\"})"
              for   = "15m"
              labels = {
                severity = "warning"
                service  = "REDACTED_77004c38"
              }
              annotations = {
                summary     = "notrf01 etcd metrics no longer reach the hub (15m)"
                description = "No etcd_server_has_leader series with cluster=notrf01 on the NL Prometheus: the notrf01 satellite's remote-write stream is down, its kube-etcd scrape is gone, or the sender drop list grew. REDACTED_d7c59693 and REDACTED_6c595701 cannot fire while this is true; the NO satellite's own stock etcd rules still can."
              }
            },
          ]
        },
      ]
    }
  }
}
