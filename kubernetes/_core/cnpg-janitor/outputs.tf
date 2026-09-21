output "cronjob_name" {
  description = "Name of the janitor CronJob (REDACTED_4c435e3b keys on it)"
  value       = kubernetes_manifest.cnpg_janitor_cronjob.manifest.metadata.name
}
