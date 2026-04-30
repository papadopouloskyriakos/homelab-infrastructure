snmp_community = "xK9mQ2vL8nR4pT6w"

# Gatus alerting webhook — disabled 2026-04-28 after fourth pipeline storm in 5 weeks.
# Empty token gates the entire alerting block + per-endpoint alerts entries off
# (see namespaces/gatus/main.tf). Status page now relies on the 5-min schedule
# plus client-side /api/mesh-stats and /api/service-health polling. See
# kyriakos/AUDIT-2026-04-28.md for the post-mortem.
gatus_gitlab_pipeline_trigger_token = ""

# -----------------------------------------------------------------------------
# Gatus → Twilio SMS (IFRNLLEI01PRD-802 replacement for the disabled GitLab
# pipeline path). Populates Gatus's `custom` alerting provider when ALL
# values are non-empty; falls back to GitLab pipeline if those are set; falls
# back to no alerting when both are empty.
#
# Real values are NOT committed here. Atlantis is configured to inject them
# via TF_VAR_gatus_twilio_* environment variables sourced from its secret
# store. To populate locally for plan/apply outside Atlantis, copy from
# claude-gateway/.env (TWILIO_*) into a local secrets.auto.tfvars (gitignored).
# -----------------------------------------------------------------------------
gatus_twilio_account_sid    = ""
gatus_twilio_api_key_sid    = ""
gatus_twilio_api_key_secret = ""
gatus_twilio_from_number    = ""
gatus_twilio_to_number      = ""
