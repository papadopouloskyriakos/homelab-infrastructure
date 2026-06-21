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
            {
              # IFRNLLEI01PRD-1037 — Infragraph health (epic IFRNLLEI01PRD-1029).
              # Mirror of claude-gateway prometheus/alert-rules/agentic-health.yml
              # (the YAML is the test+doc copy; this tf is the deployed truth).
              alert = "REDACTED_d60ef67f"
              expr  = "time() - infragraph_exporter_last_run_timestamp > 1800"
              for   = "10m"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "infragraph metrics exporter has not run in 30+ minutes"
                description = "scripts/write-infragraph-metrics.py is cron */5 on nlclaude01 — if its last-run timestamp is more than 30 minutes behind, the cron is wedged or the script errors. Without it, InfragraphSeedStale and REDACTED_74c7322d are blind. Runbook: claude-gateway docs/runbooks/infragraph.md."
              }
            },
            {
              alert = "InfragraphSeedStale"
              expr  = "time() - min by (source) (infragraph_last_seed_timestamp{source=~\"pve|netbox|librenms\"}) > 129600"
              for   = "30m"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "infragraph seed source {{ $labels.source }} stale > 36h"
                description = "scripts/infragraph-seed.py --all is cron 10 4 * * * daily on nlclaude01. A source more than 36h behind means the seeder failed twice or the upstream API (PVE/NetBox/LibreNMS) is unreachable. Automated edges expire 7 days after their last seed (valid_until) — stale seeds degrade into visible stale_edges, never silently wrong predictions, but fix within the week. Run manually and read stderr: python3 scripts/infragraph-seed.py --all. Runbook: claude-gateway docs/runbooks/infragraph.md."
              }
            },
            {
              alert = "REDACTED_74c7322d"
              expr  = "infragraph_precision_30d < 0.80 and infragraph_predictions_evaluated_total > 20"
              for   = "6h"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "infragraph 30d shadow-prediction precision below 0.80"
                description = "Phase B shadow predictions are scoring below 0.80 precision over 30 days (with a meaningful sample). The cascade model is drifting from reality — topology changed without a reseed, or learned dynamics went stale. Phase C suppression eligibility requires >= 0.95 on the conf>=0.8 subset, so investigate BEFORE the IFRNLLEI01PRD-1040 gate review. Scorecard: test-results/infragraph-scorecard.json on nlclaude01. Runbook: claude-gateway docs/runbooks/infragraph.md."
              }
            },
            {
              # IFRNLLEI01PRD-1152 — control-plane dead-man's-switch. The
              # gateway-watchdog.sh cron (*/5 on nlclaude01) already watches
              # the 9 receivers + runner and auto-heals; this watches the WATCHDOG.
              # tier=1+critical => twilio-tier1 SMS (the Matrix alerts the watchdog
              # itself posts are muted by the operator — feedback_operator_does_not_watch_matrix_polls).
              # The absent() clause is the crux: a plain staleness expr returns NO
              # series when node_exporter/claude01 is down ("no data = no alert"),
              # which is exactly the silent-dark failure this issue exists to kill.
              # NOTE: must NOT be named "Watchdog" — that alertname is black-holed
              # to receiver=null in main.tf (the Prometheus stock heartbeat).
              alert = "REDACTED_143a0947"
              expr  = "(time() - max by (host) (gateway_watchdog_heartbeat_timestamp_seconds) > 900) or absent(gateway_watchdog_heartbeat_timestamp_seconds)"
              for   = "5m"
              labels = {
                severity = "critical"
                tier     = "1"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "gateway-watchdog has not run in 15+ min (or its metric is absent) — the autonomy control plane is unmonitored"
                description = "scripts/gateway-watchdog.sh (cron */5 on nlclaude01) emits gateway_watchdog_heartbeat_timestamp_seconds on every run via a trap. Staleness means the cron, the host, node_exporter, or the script itself is dead — i.e. NOTHING is watching/auto-healing the 9 receivers + runner. This is the months-long-silent-dark failure class (memory/pipeline_autoresolve_repair_20260617.md). Triage: ssh nlclaude01; crontab -l | grep gateway-watchdog; tail ~/scripts/watchdog-state/watchdog.log; cat /var/lib/node_exporter/textfile_collector/gateway_watchdog.prom. Runbook: claude-gateway docs/runbooks/gateway-watchdog-deadman.md."
              }
            },
            {
              alert = "REDACTED_8744b7c1"
              expr  = "min by (workflow) (gateway_workflow_active) == 0"
              for   = "15m"
              labels = {
                severity = "critical"
                tier     = "1"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "n8n workflow {{ $labels.workflow }} found inactive across 3+ watchdog runs (auto-reactivation not holding)"
                description = "gateway-watchdog.sh found this workflow inactive and tried to reactivate it, but it is still inactive 15 min later — reactivation is failing (deleted, errored on activate, or n8n rejecting it). A dead receiver/runner means alerts silently stop being dispatched. Triage: ssh nlclaude01; tail ~/scripts/watchdog-state/watchdog.log; check the workflow in the n8n UI. Runbook: claude-gateway docs/runbooks/gateway-watchdog-deadman.md."
              }
            },
            {
              # IFRNLLEI01PRD-1154 — synthetic-incident canary (classify->predict spine).
              # tier=1 SMS ONLY for a live-db LEAK (the isolation safety invariant);
              # spine-degraded / stale are warnings (daily probe, not an outage).
              alert = "SyntheticCanaryLeak"
              expr  = "synthetic_incident_canary_live_db_leak > 0"
              for   = "0m"
              labels = {
                severity = "critical"
                tier     = "1"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "synthetic canary leaked {{ $value }} rows into the LIVE gateway.db — isolation broke"
                description = "synthetic-incident-canary.sh must run the classify->predict spine against an isolated temp DB. A non-zero leak means a canary row reached the live session_risk_audit/infragraph_predictions, which can skew metrics or collide a real fail-closed gate. Disable the cron (crontab -e) and fix before re-enabling. Runbook: claude-gateway docs/runbooks/synthetic-incident-canary.md."
              }
            },
            {
              alert = "REDACTED_d0d0a5b0"
              expr  = "synthetic_incident_canary_stages_passed < 3"
              for   = "6h"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "synthetic canary passing only {{ $value }}/3 spine stages"
                description = "The classify->predict spine is degraded (empty plan, missing band, or broken gate logic) — the months-long-silent-dark class. Inspect ~/logs/claude-gateway/synthetic-canary.log; run scripts/synthetic-incident-canary.sh --verbose. Runbook: claude-gateway docs/runbooks/synthetic-incident-canary.md."
              }
            },
            {
              alert = "SyntheticCanaryStale"
              expr  = "(time() - synthetic_incident_canary_last_run_timestamp > 172800) or absent(synthetic_incident_canary_last_run_timestamp)"
              for   = "1h"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "synthetic canary has not run in 48h+ (or metric absent)"
                description = "The daily 02:37 synthetic-incident-canary cron on nlclaude01 is not firing — the autonomy spine is no longer being probed. Runbook: claude-gateway docs/runbooks/synthetic-incident-canary.md."
              }
            },
            {
              # IFRNLLEI01PRD-1153 — governance metrics freshness.
              alert = "REDACTED_18cc530f"
              expr  = "(time() - chatops_governance_metrics_last_run_timestamp > 3600) or absent(chatops_governance_metrics_last_run_timestamp)"
              for   = "30m"
              labels = {
                severity = "warning"
                category = "agentic-platform"
              }
              annotations = {
                summary     = "governance metrics (false-auto-resolve / repeat-incident) stale 1h+"
                description = "scripts/write-governance-metrics.py (cron */17 on nlclaude01) is wedged — the auto-resolve safety KPIs (false-auto-resolve, repeat-incident) are no longer computed. Run by hand and read stderr."
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
