variable "common_labels" {
  description = "Common labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "metrics_server_selector" {
  description = "PDB selector match_labels for the metrics-server deployment. Per-site: NL's deployment is labelled k8s-app=metrics-server (default); GR's uses app.kubernetes.io/name=metrics-server, so the GR root must override."
  type        = map(string)
  default = {
    "k8s-app" = "metrics-server"
  }
}
