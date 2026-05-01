# =============================================================================
# Custom Prometheus Alert Rules
# Covers gaps not included in REDACTED_d8074874 defaults:
# - OOM kills, Ingress health, Cilium/CNI, NFS mounts, App health
# =============================================================================

resource "kubernetes_manifest" "custom_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "custom-alert-rules"
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
          name = "custom-oom"
          rules = [
            {
              alert = "ContainerOOMKilled"
              expr  = "kube_pod_container_status_last_terminated_reason{reason=\"OOMKilled\"} == 1"
              for   = "0m"
              labels = {
                severity = "critical"
              }
              annotations = {
                summary     = "Container {{ $labels.container }} in pod {{ $labels.pod }} ({{ $labels.namespace }}) was OOM killed"
                description = "Container {{ $labels.container }} in pod {{ $labels.pod }} namespace {{ $labels.namespace }} was OOM killed. This indicates the container needs more memory or has a memory leak."
              }
            },
            {
              alert = "REDACTED_879bd353"
              expr  = "(container_memory_working_set_bytes / container_spec_memory_limit_bytes) > 0.9 and container_spec_memory_limit_bytes > 0"
              for   = "5m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Container {{ $labels.container }} in {{ $labels.pod }} ({{ $labels.namespace }}) using >90% memory limit"
                description = "Container {{ $labels.container }} is using {{ $value | humanizePercentage }} of its memory limit. OOM kill is imminent."
              }
            }
          ]
        },
        {
          name = "custom-ingress"
          rules = [
            {
              alert = "REDACTED_02123891"
              expr  = "kube_endpoint_address_available{namespace!=\"\"} == 0 and kube_endpoint_info{namespace!=\"\"}"
              for   = "5m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Endpoint {{ $labels.endpoint }} in {{ $labels.namespace }} has no available addresses"
                description = "The endpoint {{ $labels.endpoint }} in namespace {{ $labels.namespace }} has zero available backend addresses. Services routing to this endpoint will fail."
              }
            },
            {
              alert = "REDACTED_a8a7eee8"
              expr  = "sum(rate(nginx_ingress_controller_requests{status=~\"5...\"}[5m])) by (ingress, namespace) / sum(rate(nginx_ingress_controller_requests[5m])) by (ingress, namespace) > 0.1"
              for   = "5m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Ingress {{ $labels.ingress }} ({{ $labels.namespace }}) has >10% error rate"
                description = "Ingress {{ $labels.ingress }} in namespace {{ $labels.namespace }} has a 5xx error rate of {{ $value | humanizePercentage }}."
              }
            },
            {
              alert = "REDACTED_67797f17"
              expr  = "(nginx_ingress_controller_ssl_expire_time_seconds - time()) / 86400 < 14"
              for   = "1h"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "TLS certificate for {{ $labels.host }} expires in {{ $value | humanize }} days"
                description = "The TLS certificate for ingress host {{ $labels.host }} expires in less than 14 days. Check cert-manager renewal."
              }
            }
          ]
        },
        {
          name = "custom-cilium"
          rules = [
            {
              alert = "CiliumAgentNotReady"
              expr  = "cilium_unreachable_nodes > 0"
              for   = "15m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Cilium agent on {{ $labels.instance }} has {{ $value }} unreachable nodes"
                description = "Cilium agent reports unreachable nodes, indicating network connectivity issues in the cluster mesh."
              }
            },
            {
              alert = "REDACTED_b94e0389"
              expr  = "cilium_endpoint_state{endpoint_state=\"not-ready\"} > 0"
              for   = "10m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Cilium has {{ $value }} not-ready endpoints on {{ $labels.instance }}"
                description = "Endpoints in not-ready state indicate pods that cannot communicate via Cilium. Check cilium-agent logs."
              }
            },
            {
              alert = "REDACTED_e52ce3d8"
              expr  = "increase(cilium_policy_import_errors_total[5m]) > 0"
              for   = "0m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Cilium policy import errors on {{ $labels.instance }}"
                description = "Cilium failed to import network policies. Check policy syntax and cilium-agent logs."
              }
            }
          ]
        },
        {
          name = "custom-nfs"
          rules = [
            {
              alert = "NFSMountStale"
              expr  = "node_filesystem_readonly{fstype=\"nfs4\"} == 1"
              for   = "5m"
              labels = {
                severity = "critical"
              }
              annotations = {
                summary     = "NFS mount {{ $labels.mountpoint }} on {{ $labels.instance }} is read-only/stale"
                description = "NFS mount at {{ $labels.mountpoint }} on node {{ $labels.instance }} is in read-only state. This typically indicates a stale NFS mount — the NFS server may be unreachable."
              }
            },
            {
              alert = "NFSMountHighLatency"
              expr  = "rate(node_nfs_rpc_retransmissions_total[5m]) > 0.1"
              for   = "10m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "High NFS RPC retransmissions on {{ $labels.instance }}"
                description = "Node {{ $labels.instance }} is experiencing NFS RPC retransmissions, indicating network issues or NFS server load."
              }
            }
          ]
        },
        {
          name = "custom-apps"
          rules = [
            {
              alert = "ArgocdAppDegraded"
              expr  = "argocd_app_info{health_status!=\"Healthy\",health_status!=\"Progressing\"} == 1"
              for   = "10m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "ArgoCD app {{ $labels.name }} health is {{ $labels.health_status }}"
                description = "ArgoCD application {{ $labels.name }} has been in {{ $labels.health_status }} state for more than 10 minutes."
              }
            },
            {
              alert = "ArgocdAppOutOfSync"
              expr  = "argocd_app_info{sync_status=\"OutOfSync\"} == 1"
              for   = "30m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "ArgoCD app {{ $labels.name }} is OutOfSync for >30 minutes"
                description = "ArgoCD application {{ $labels.name }} has been OutOfSync for more than 30 minutes. Check if auto-sync is failing."
              }
            },
            {
              alert = "HighPodRestartRate"
              expr  = "increase(kube_pod_container_status_restarts_total[1h]) > 5"
              for   = "0m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Pod {{ $labels.pod }} ({{ $labels.namespace }}) restarted {{ $value }} times in 1h"
                description = "Container {{ $labels.container }} in pod {{ $labels.pod }} namespace {{ $labels.namespace }} has restarted {{ $value }} times in the last hour. Investigate logs for crash reason."
              }
            }
          ]
        },
        {
          # Pacemaker cluster (HAHA / IoT) — catches forgotten "crm node standby"
          # state. Today's incident: weekly-update playbook left iot02 in standby
          # for ~16h with zero alerting, so the cluster lost failover redundancy
          # silently. Metric source: native/haha/pacemaker-standby-exporter/
          # (textfile collector on iot01/iot02/iotarb01).
          name = "custom-pacemaker"
          rules = [
            {
              alert = "REDACTED_2aa4f351"
              expr  = "max by (node) (pacemaker_node_standby) == 1"
              for   = "30m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "Pacemaker node {{ $labels.node }} stuck in standby for >30m"
                description = "Pacemaker node {{ $labels.node }} has been in standby (no resources allowed) for more than 30 minutes — cluster has lost failover redundancy. Likely cause: a maintenance / weekly-update playbook left the node in standby and forgot to bring it back online. Recover with 'crm node online {{ $labels.node }}' from any cluster member."
              }
            },
            {
              alert = "REDACTED_d78e0784"
              expr  = "(time() - max by (instance) (node_textfile_mtime_seconds{file=~\".*pacemaker_standby.prom\"})) > 600"
              for   = "5m"
              labels = {
                severity = "warning"
              }
              annotations = {
                summary     = "pacemaker-standby-exporter on {{ $labels.instance }} has not refreshed in >10m"
                description = "The pacemaker-standby-exporter.timer on {{ $labels.instance }} has not updated /var/lib/node_exporter/textfile_collector/pacemaker_standby.prom in over 10 minutes. REDACTED_2aa4f351 may be evaluating stale data. Check 'systemctl status pacemaker-standby-exporter.timer'."
              }
            }
          ]
        }
      ]
    }
  }
}
