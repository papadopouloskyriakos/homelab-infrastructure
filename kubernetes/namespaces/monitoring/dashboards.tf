# -----------------------------------------------------------------------------
# Grafana Dashboard ConfigMaps
# -----------------------------------------------------------------------------
# Provisioned via the Grafana sidecar, which watches for ConfigMaps
# with label grafana_dashboard=1 in the monitoring namespace.
# Dashboard JSON files are stored in the dashboards/ directory.
# -----------------------------------------------------------------------------

resource "REDACTED_a9df2e77" "REDACTED_5c442e4b" {
  metadata {
    name      = "REDACTED_4aec8d26"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "chatops-platform.json" = file("${path.module}/dashboards/chatops-platform.json")
  }
}

resource "REDACTED_a9df2e77" "REDACTED_1e59c91b" {
  metadata {
    name      = "REDACTED_d16a67df"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "infra-overview.json" = file("${path.module}/dashboards/infra-overview.json")
  }
}

resource "REDACTED_a9df2e77" "REDACTED_f1ba806b" {
  metadata {
    name      = "REDACTED_ee93e94e"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "infra-project.json" = file("${path.module}/dashboards/infra-project.json")
  }
}

resource "REDACTED_a9df2e77" "REDACTED_1e672c99" {
  metadata {
    name      = "REDACTED_aa68e812"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "meshsat-project.json" = file("${path.module}/dashboards/meshsat-project.json")
  }
}

resource "REDACTED_a9df2e77" "REDACTED_10ebf48e" {
  metadata {
    name      = "REDACTED_7ebaabb7"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "cubeos-project.json" = file("${path.module}/dashboards/cubeos-project.json")
  }
}

resource "REDACTED_a9df2e77" "REDACTED_db2e277e" {
  metadata {
    name      = "REDACTED_8acf86b6"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "chaos-engineering.json" = file("${path.module}/dashboards/chaos-engineering.json")
  }
}

# -----------------------------------------------------------------------------
# Imported dashboards (previously created via kubectl, now IaC-managed)
# Import blocks are in k8s/imports.tf (root module requirement).
# Remove import blocks after first successful apply.
# -----------------------------------------------------------------------------

resource "REDACTED_a9df2e77" "REDACTED_539bef88" {
  metadata {
    name      = "REDACTED_5b332095"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "chatops-subsystem.json" = file("${path.module}/dashboards/chatops-subsystem.json")
  }
}

resource "REDACTED_a9df2e77" "REDACTED_4bb7c763" {
  metadata {
    name      = "REDACTED_36bc0539"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "chatsecops-subsystem.json" = file("${path.module}/dashboards/chatsecops-subsystem.json")
  }
}

resource "REDACTED_a9df2e77" "REDACTED_7d9d2400" {
  metadata {
    name      = "REDACTED_7962fb12"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "REDACTED_d3dde0ed.json" = file("${path.module}/dashboards/REDACTED_d3dde0ed.json")
  }
}

resource "REDACTED_a9df2e77" "REDACTED_12611a94" {
  metadata {
    name      = "REDACTED_6b3ca3f9"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "otel-traces.json" = file("${path.module}/dashboards/otel-traces.json")
  }
}

resource "REDACTED_a9df2e77" "REDACTED_d82d0340" {
  metadata {
    name      = "REDACTED_67b32728"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "rag-observability.json" = file("${path.module}/dashboards/rag-observability.json")
  }
}

# IFRNLLEI01PRD-654 teacher-agent loop — 12-panel dashboard fed by
# /var/lib/node_exporter/textfile_collector/learning_progress.prom
# (cron scripts/write-learning-metrics.sh on nlclaude01, */5).
resource "REDACTED_a9df2e77" "REDACTED_dae6e5e3" {
  metadata {
    name      = "REDACTED_b0f6b4c9"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "teacher-agent.json" = file("${path.module}/dashboards/teacher-agent.json")
  }
}

# My Money — UNIFIED dashboard (uid finops). Fuses the former finops-simple +
# finops-details + finops-behavior into ONE page: calm single-hue blue, plain-word
# value mappings, variance-first, live SQL on the ledger, 30-min auto-refresh.
# Sections: ① right now ② this month ③ where it goes ④ trends ⑤ data health.
resource "REDACTED_a9df2e77" "REDACTED_4c4c1a1a" {
  metadata {
    name      = "REDACTED_9e73b182"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "finops.json" = file("${path.module}/dashboards/finops.json")
  }
}

# finops-simple: real subscriptions (Wallos snapshot wallos_subs) + "what changed" YoY panel — 2026-06-08
# finops: food-targets panel + deterministic Dutch number format (de_DE in SQL) — 2026-06-11
# finops: stat panels with string values need reduceOptions.fields=/.*/ — 2026-06-11
# finops: bargauges -> hidden-value bars + Dutch string amounts (audit iteration 3) — 2026-06-11

# Agora — finops-agora paper-trading cockpit (uid agora). NAV-vs-index race, open
# prediction ledger, methodology scoreboard, verdict history, pipeline health.
# Reads finops_agora.* via the finops-ledger datasource (grafana_ro granted 2026-06-11).
resource "REDACTED_a9df2e77" "grafana_dashboard_agora" {
  metadata {
    name      = "grafana-dashboard-agora"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }
  data = {
    "agora.json" = file("${path.module}/dashboards/agora.json")
  }
}
