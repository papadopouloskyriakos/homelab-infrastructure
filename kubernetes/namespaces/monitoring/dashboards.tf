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
