# =============================================================================
# RAG Pipeline Alert Rules
# Emitted by kb-latency-probe (*/5 cron) and weekly-eval-cron on nlclaude01
# via node-exporter textfile collector at
# /var/lib/node_exporter/textfile_collector/kb_rag.prom + kb_rag_eval.prom
# =============================================================================

resource "kubernetes_manifest" "rag_alert_rules" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "rag-alert-rules"
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
          name     = "rag-pipeline-health"
          interval = "1m"
          rules = [
            {
              alert = "REDACTED_8888c6a5"
              expr  = "REDACTED_edef2a32 == 0"
              for   = "5m"
              labels = {
                severity = "warning"
                service  = "rag-rerank"
              }
              annotations = {
                summary     = "bge-reranker-v2-m3 service at nlgpu01:11436 has been down >=5m"
                description = "Retrieval still functions via Ollama yes/no fallback (auto-triggers) but quality degrades ~15 points on the hard eval. Runbook: docs/runbooks/rerank-service.md"
                impact      = "RAG hit@5 degrades ~15 points but pipeline functional. No alerts missed."
              }
            },
            {
              alert = "RAGLatencyP95High"
              expr  = "kb_retrieval_latency_seconds{quantile=\"0.95\"} > 6.0"
              for   = "15m"
              labels = {
                severity = "warning"
                service  = "rag-retrieval"
              }
              annotations = {
                summary     = "RAG retrieval p95 latency > 6s (current: {{ $value }}s)"
                description = "Baseline p95 is 3-5s. Sustained >6s suggests Ollama model swapping, rerank service contention, or corpus growth past sweet spot."
              }
            },
            {
              alert = "REDACTED_1cdf2d60"
              expr  = "REDACTED_aa7df862 >= 1.0"
              for   = "30m"
              labels = {
                severity = "info"
                service  = "rag-retrieval"
              }
              annotations = {
                summary     = "RAG migration trigger fired — FAISS cutover advisable"
                description = "Either embedded vectors > 25k OR p95 > 5s for 30m sustained. FAISS index already synced by */15 cron — safe to switch reads."
              }
            },
            {
              alert = "REDACTED_03bb3127"
              expr  = "increase(kb_qwen_json_failure_total[10m]) > 10"
              for   = "10m"
              labels = {
                severity = "warning"
                service  = "rag-synthesis"
              }
              annotations = {
                summary     = "qwen_json failing >10 times / 10min (KG traverse + synthesis affected)"
                description = "_qwen_json fallback ladder (qwen2.5:7b → qwen3:4b) is failing repeatedly. KG traversal and RAG Fusion variant generation are degraded."
              }
            },
            {
              alert = "REDACTED_47cda31f"
              expr  = "(REDACTED_862400f1 offset 24h) > 0 and (REDACTED_862400f1 - (REDACTED_862400f1 offset 24h)) < 1 and (kb_embedded_rows{table=\"session_transcripts\"} - (kb_embedded_rows{table=\"session_transcripts\"} offset 24h)) < 1"
              for   = "24h"
              labels = {
                severity = "info"
                service  = "rag-indexing"
              }
              annotations = {
                summary     = "No new embedded rows in 24h — indexing pipeline may be stuck"
                description = "Either no new sessions ran (plausible) or archive-session-transcript writer is failing to embed. Check /tmp/index-memories.log + session end workflow."
              }
            },
            {
              alert = "REDACTED_963bc097"
              expr  = "kb_hard_eval_hit_rate < 0.70"
              for   = "7d"
              labels = {
                severity = "warning"
                service  = "rag-quality"
              }
              annotations = {
                summary     = "Hard eval judge hit@5 dropped below 0.70 (currently {{ $value }})"
                description = "Historical hit@5 is 0.88. Sustained drop indicates content-index drift, model swap, or rerank degradation. Check last 3 weekly eval runs in Grafana."
              }
            },
            {
              alert = "REDACTED_094d1e88"
              expr  = "kb_openclaw_sync_errors > 0"
              for   = "30m"
              labels = {
                severity = "warning"
                service  = "openclaw-sync"
              }
              annotations = {
                summary     = "OpenClaw skills sync failing for >=30m (errors={{ $value }})"
                description = "scripts/sync-openclaw-skills.sh cannot copy gateway source into OpenClaw skills dir. OpenClaw quality drifts behind gateway until fixed. Check SSH to nlopenclaw01 and /tmp/sync-openclaw-skills.log."
              }
            },
            {
              alert = "KBOpenClawSyncStale"
              expr  = "(time() - kb_openclaw_sync_last_run_timestamp_seconds) > 172800"
              for   = "1h"
              labels = {
                severity = "warning"
                service  = "openclaw-sync"
              }
              annotations = {
                summary     = "OpenClaw skills sync cron hasn't fired in >48h"
                description = "sync-openclaw-skills.sh cron (daily 04:12 UTC) last ran {{ $value }}s ago. Crontab may have been rewritten. Check crontab -l | grep sync-openclaw on nlclaude01."
              }
            },
            {
              alert = "REDACTED_79f92e77"
              expr  = "kb_content_refresh_age_seconds > 172800"
              for   = "1h"
              labels = {
                severity = "warning"
                service  = "rag-content-refresh"
              }
              annotations = {
                summary     = "Auto-refreshed doc '{{ $labels.doc }}' is >48h old"
                description = "One of the 5 daily auto-refresh scripts has not regenerated its output in over 48h. Check /tmp/refresh-*.log and verify cron is installed."
              }
            },
            {
              alert = "KBWeeklyEvalStale"
              expr  = "(time() - kb_hard_eval_last_run_timestamp_seconds) > 691200"
              for   = "1h"
              labels = {
                severity = "warning"
                service  = "rag-quality"
              }
              annotations = {
                summary     = "Weekly hard-eval cron hasn't fired in >8 days"
                description = "weekly-eval-cron.sh (Monday 05:00 UTC) last ran {{ $value }}s ago. Expected cadence is 7 days. Quality regressions will not be visible until eval resumes. Check /tmp/weekly-eval.log and crontab."
              }
            },
          ]
        },
      ]
    }
  }
}
