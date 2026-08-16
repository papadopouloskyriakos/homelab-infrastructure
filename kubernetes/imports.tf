# =============================================================================
# One-shot state adoptions (mirror campaign) — prune once applied on main.
# =============================================================================

# Live grafana ingress existed OUT-OF-BAND (created outside TF; the monitoring
# module never declared one until the 2026-08-16 canonicalization). Adopt it.
import {
  to = module.monitoring.kubernetes_ingress_v1.grafana[0]
  id = "monitoring/grafana"
}
