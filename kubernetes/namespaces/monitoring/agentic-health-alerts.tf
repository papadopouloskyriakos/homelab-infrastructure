# =============================================================================
# Agentic-platform health alert rules.
#
# Source of truth was a YAML in the claude-gateway repo
# (prometheus/alert-rules/agentic-health.yml) that was never wired to K8s —
# the YAML existed for ~weeks but no PrometheusRule CRD ever rendered, so
# none of these alerts could fire. Wiring them up properly here, mirroring
# the pattern used by teacher-agent-alerts.tf and rag-alerts.tf.
#
# Metric sources (all node_exporter textfile collector on nlclaude01):
#   - chatops_skill_requires_ok_all          ← scripts/write-skill-metrics.sh   (cron */5)
#   - chatops_skill_metrics_last_run_timestamp ← same cron
#   - chatops_long_horizon_replay_last_run_timestamp ← scripts/long-horizon-replay.py (cron 0 5 * * 1)
#   - chatops_jailbreak_detector_match_total ← scripts/qa/suites/test-jailbreak-corpus.sh (cron 0 5 * * 3) + write-jailbreak-metrics.sh (*/30)
#   - chatops_intermediate_rail_drift_score  ← scripts/write-intermediate-rail-metrics.sh (cron */10)
#
# Metric sources for the REDACTED_765f1697 group (textfile collector on
# nlgpu01, /etc/cron.weekly/gpu01-health-metrics, runs via anacron):
#   - gpu01_docker_dangling_image_bytes  ← `docker images -f dangling=true` (truly orphan layers)
#   - gpu01_docker_reclaimable_bytes{type="..."}  ← `docker system df` (diagnostic only, no alert)
#   - gpu01_fstrim_timer_active          ← `systemctl is-active fstrim.timer`
# Added 2026-05-12 after the qcow2 io-error freeze RCA — see claude-gateway
# memory/gpu01_freeze_qcow2_io_error_20260512.md. The first iteration of
# this group alerted on `gpu01_docker_reclaimable_bytes` but that metric
# drifts upward forever on a healthy host (Docker considers any image not
# pinned to a *running* container "reclaimable", even when stopped
# containers depend on it) — see the second commit on this group for the
# swap to dangling-image bytes, which only counts truly orphan layers.
#
# History: previously contained ReceiverCanaryFailing + ReceiverCanaryStale —
# retired 2026-04-30 alongside the receiver-canary cron itself (real alert
# volume covers silent-dispatch-break detection). See claude-gateway commit
# 2c4af83 + memory/feedback_canary_for_dispatch_chain_changes.md.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_a6ca0194" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_af2aec25"
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
          name     = "agentic-health"
          interval = "1m"
          rules = [
            {
              alert = "SkillPrereqMissing"
              expr  = "min by (skill, kind) (chatops_skill_requires_ok_all) == 0"
              for   = "30m"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "Skill {{ $labels.skill }} ({{ $labels.kind }}) has an unsatisfied prereq"
                description = "One or more entries in the skill's requires.bins or requires.env block are not available on the host (binary missing, or env var unset). Full report: scripts/audit-skill-requires.sh. Source of truth: .claude/{{ $labels.kind }}s/.../*.md frontmatter. Runbook: docs/runbooks/ (general skill-maintenance guidance)."
              }
            },
            {
              alert = "REDACTED_a1528267"
              expr  = "time() - chatops_skill_metrics_last_run_timestamp > 1800"
              for   = "10m"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "skill-metrics exporter has not run in 30+ minutes"
                description = "scripts/write-skill-metrics.sh is cron */5 — if its last-run timestamp is more than 30 minutes behind, the cron is wedged or the script is erroring. Check `crontab -l` and run manually to reproduce. Without this exporter, SkillPrereqMissing cannot fire."
              }
            },
            {
              alert = "REDACTED_a9548c1a"
              expr  = "time() - chatops_long_horizon_replay_last_run_timestamp > 777600"
              for   = "30m"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "long-horizon replay has not run in 9+ days"
                description = "scripts/long-horizon-replay.py is wired to a weekly cron (0 5 * * 1). If its last-run timestamp is more than 9 days behind (777600s), the weekly run is wedged or the cron entry is missing. Check `crontab -l` and run manually with `--limit 5 --dry-run` to reproduce. Without this exporter the NVIDIA dim #9 long-horizon evaluation pillar regresses to A-."
              }
            },
            {
              alert = "REDACTED_3297f03e"
              expr  = "max by (category) (chatops_jailbreak_detector_match_total{status=\"miss\"}) > 0"
              for   = "30m"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "Jailbreak fixture(s) drifted in category {{ $labels.category }}"
                description = "scripts/lib/jailbreak_detector.py produced expected_categories mismatches against scripts/qa/fixtures/jailbreak-corpus.json. Either the corpus expectations need updating or a regression has been introduced. Run `bash scripts/qa/suites/test-jailbreak-corpus.sh` for the full diff."
              }
            },
            {
              alert = "REDACTED_d017f11e"
              expr  = "max by (category) (chatops_intermediate_rail_drift_score) > 0.20"
              for   = "24h"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "Intermediate rail drift > 20% in category {{ $labels.category }} for 24h"
                description = "scripts/lib/intermediate_rail.py is flagging > 20% of intermediate steps as out-of-distribution for this alert category. Either the heuristic keyword bucket is too narrow (false positives), the agent is going off-topic (real drift), or Ollama is returning bad classifications. DARK-FIRST: this alert observes only — no Build Prompt blocking. Inspect with: sqlite3 ~/gitlab/products/cubeos/claude-context/gateway.db \"SELECT payload_json FROM event_log WHERE event_type='REDACTED_be143759' AND emitted_at > datetime('now','-24 hours') ORDER BY id DESC LIMIT 20\""
              }
            },
          ]
        },
        {
          name     = "REDACTED_765f1697"
          interval = "1m"
          rules = [
            {
              # 5368709120 bytes = 5 GiB. Dangling images are truly orphan
              # layers from `docker pull` (tag-replaced) or `docker build`
              # (incremental rebuild). They have no tag and no container
              # reference; `docker image prune` removes them safely. A
              # healthy host carries < 1 GiB of these; > 5 GiB for 6h means
              # build-churn or pull-churn is accumulating without cleanup.
              alert = "REDACTED_c50264b9"
              expr  = "gpu01_docker_dangling_image_bytes{instance=\"nlgpu01\"} > 5368709120"
              for   = "6h"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "nlgpu01 dangling Docker images > 5 GiB"
                description = "More than 5 GiB of dangling (truly orphan) Docker images have accumulated on nlgpu01. Each is a layer with no tag and no container reference — safe to remove. Investigate with `ssh nlgpu01 docker images -f dangling=true` and prune with `docker image prune -f` (no `-a` needed; dangling-only). Builds repulling base layers without an intermediate prune are the most common cause. Runbook: claude-gateway memory/gpu01_freeze_qcow2_io_error_20260512.md."
              }
            },
            {
              # fstrim.timer is what keeps the qcow2 self-maintaining. If it
              # ever flips inactive, the discard=on plumbing becomes a no-op
              # and the 2026-05-12 freeze pattern returns within weeks.
              alert = "REDACTED_228d1bfb"
              expr  = "gpu01_fstrim_timer_active{instance=\"nlgpu01\"} == 0"
              for   = "1h"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "nlgpu01 fstrim.timer is not active"
                description = "The weekly fstrim.timer on nlgpu01 is reported inactive. Without it, deleted Docker layers won't release qcow2 clusters back to the underlying ZFS, and disk-1 (scsi0) will refill toward the 99.56% cluster-allocation level that caused the 2026-05-12 freezes. Re-enable with: `ssh nlgpu01 sudo systemctl enable --now fstrim.timer && systemctl status fstrim.timer`. Runbook: claude-gateway memory/gpu01_freeze_qcow2_io_error_20260512.md."
              }
            },
          ]
        },
      ]
    }
  }
}
