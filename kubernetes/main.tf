***REMOVED***
# Kubernetes Infrastructure - Main Entry Point
***REMOVED***
#
# This is the root module that orchestrates all K8s workloads.
# Each workload is defined in a separate file under apps/
#
# Workloads managed:
# - NFS Provisioner (storage)
# - Ingress NGINX (networking)
# - Monitoring (Prometheus + Grafana)
# - Kubernetes Dashboard
# - GitLab Runner
# - GitLab Agents (k8s-agent, nlk8s-agent01)
# - AWX (Ansible Automation Platform)
# - Pihole (DNS)
#
# Migration notes:
# - Run import commands before first apply
# - All helm releases will be imported, not recreated
# - See MIGRATION-PLAN.md for details
#
***REMOVED***

locals {
  common_labels = {
    "managed-by"  = "opentofu"
    "environment" = "production"
    "repository"  = "infrastructure/nl/production"
  }
  
  # Timezone for all workloads
  timezone = "Europe/Amsterdam"
}
