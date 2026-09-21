variable "common_labels" {
  description = "Labels applied to every resource"
  type        = map(string)
  default     = {}
}

variable "namespace" {
  description = "Namespace for the janitor. cnpg-system exists on every site (the operator's)."
  type        = string
  default     = "cnpg-system"
}

variable "schedule" {
  description = "Cron schedule. Hourly: releasing a latched Backup is one API call, and every hour it is held is an hour no backup can start."
  type        = string
  default     = "23 * * * *"
}

variable "image" {
  description = "Python image; the script is standard-library only and runs with a read-only root filesystem."
  type        = string
  default     = "docker.io/library/python:3.13-alpine"
}

variable "REDACTED_1f1d9073" {
  description = "A Backup in walArchivingFailing older than this is released."
  type        = number
  default     = 7200
}

variable "stuck_running_seconds" {
  description = "A Backup still pending/started/running/finalizing after this is released. The largest base backup here takes minutes, not hours."
  type        = number
  default     = 43200
}

variable "max_age_hours" {
  description = "Every non-suspended ScheduledBackup must have fired, and its cluster backed up, within this many hours (daily schedules + slack). Override per schedule with annotation cnpg-janitor.example.net/max-age-hours."
  type        = number
  default     = 30
}
