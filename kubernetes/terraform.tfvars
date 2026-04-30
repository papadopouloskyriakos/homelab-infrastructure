snmp_community = "xK9mQ2vL8nR4pT6w"

# Gatus alerting webhook — disabled 2026-04-28 after fourth pipeline storm in 5 weeks.
# Empty token gates the entire alerting block + per-endpoint alerts entries off
# (see namespaces/gatus/main.tf). Status page now relies on the 5-min schedule
# plus client-side /api/mesh-stats and /api/service-health polling. See
# kyriakos/AUDIT-2026-04-28.md for the post-mortem.
REDACTED_2636fc38 = ""

# -----------------------------------------------------------------------------
# Gatus → Twilio SMS (IFRNLLEI01PRD-802 replacement for the disabled GitLab
# pipeline path).
#
# Variable values come from TF_VAR_gatus_twilio_* env vars on the Atlantis
# runner (loaded via env_file: /srv/atlantis/twilio.env). They are NOT set
# here because tfvars OVERRIDE env vars (precedence: tfvars > TF_VAR_* env).
# Default values in variables.tf are empty strings; with no tfvars override,
# env vars apply, locals.twilio_enabled = true, gatus-twilio Secret is
# created, and Gatus's custom alerting provider routes to Twilio.
# -----------------------------------------------------------------------------
