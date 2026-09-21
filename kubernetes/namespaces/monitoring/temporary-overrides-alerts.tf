# =============================================================================
# Temporary overrides expire (IFRNLLEI01PRD-2850, 2026-09-21)
#
# The Thanos compactor was parked on 2026-09-15 "until nl-s3 has room" and the
# SeaweedFS floor was lowered on 2026-09-10 "temporarily"; neither was undone, and
# nl-s3 filled on 2026-09-21. Any below-standard setting now has to be registered in
# terraform.tfvars `temporary_overrides = { <name> = "YYYY-MM-DD" }` (enforced by the
# k8s/tests/lint_temporary_overrides.py CI lint), and this renders one alert per
# entry that pages from the day after its date until the setting is restored or the
# date is renewed on purpose. OpenTofu has no date->epoch function, so the date is
# compared as YYYYMMDD in PromQL. Canonical; per-site entries come from tfvars.
# =============================================================================

resource "kubernetes_manifest" "REDACTED_ec12bd83" {
  count = length(var.temporary_overrides) > 0 ? 1 : 0
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PrometheusRule"
    metadata = {
      name      = "REDACTED_7d0291eb"
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
          name     = "temporary-overrides"
          interval = "10m"
          rules = [
            for name, date in var.temporary_overrides : {
              alert = "REDACTED_8e8e28d2"
              expr  = "(year() * 10000 + month() * 100 + day_of_month()) > ${replace(date, "-", "")}"
              for   = "1h"
              labels = {
                severity = "critical"
                tier     = "1"
                override = name
                category = "change-management"
              }
              annotations = {
                summary     = "Temporary override ${name} expired on ${date}"
                description = "terraform.tfvars registers ${name} as a temporary exception that ended on ${date}. Restore the standard value (see k8s/tests/lint_temporary_overrides.py STANDARDS) and remove the entry, or renew the date in an MR on purpose. A temporary change nobody revisits is how nl-s3 filled on 2026-09-21."
                impact      = "A setting below the estate standard is still live past its agreed end."
              }
            }
          ]
        },
      ]
    }
  }
}
