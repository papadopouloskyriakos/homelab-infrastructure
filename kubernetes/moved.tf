***REMOVED***
# State Migration - Moved Blocks
***REMOVED***
# These blocks tell OpenTofu that resources moved from root to modules.
# After successful apply, these can be removed.
***REMOVED***

# -----------------------------------------------------------------------------
# Core Infrastructure
# -----------------------------------------------------------------------------
moved {
  from = helm_release.nfs_provisioner
  to   = module.nfs_provisioner.helm_release.nfs_provisioner
}

moved {
  from = helm_release.ingress_nginx
  to   = module.ingress_nginx.helm_release.ingress_nginx
}

moved {
  from = helm_release.gitlab_agent_k8s
  to   = module.gitlab_agent.helm_release.gitlab_agent_k8s
}

# -----------------------------------------------------------------------------
# AWX Module
# -----------------------------------------------------------------------------
moved {
  from = kubernetes_namespace.awx
  to   = module.awx.kubernetes_namespace.awx
}

moved {
  from = REDACTED_5a69a0fb.nfs_sc
  to   = module.awx.REDACTED_5a69a0fb.nfs_sc
}

moved {
  from = REDACTED_912a6d18.awx_postgres
  to   = module.awx.REDACTED_912a6d18.awx_postgres
}

moved {
  from = REDACTED_912a6d18.awx_projects
  to   = module.awx.REDACTED_912a6d18.awx_projects
}

moved {
  from = REDACTED_912a6d18_claim.awx_projects
  to   = module.awx.REDACTED_912a6d18_claim.awx_projects
}

# -----------------------------------------------------------------------------
# MinIO Module
# -----------------------------------------------------------------------------
moved {
  from = kubernetes_namespace.minio
  to   = module.minio.kubernetes_namespace.minio
}

moved {
  from = kubernetes_secret.minio_credentials
  to   = module.minio.kubernetes_secret.minio_credentials
}

moved {
  from = REDACTED_912a6d18_claim.minio_data
  to   = module.minio.REDACTED_912a6d18_claim.minio_data
}

moved {
  from = kubernetes_deployment.minio
  to   = module.minio.kubernetes_deployment.minio
}

moved {
  from = kubernetes_service.minio_api
  to   = module.minio.kubernetes_service.minio_api
}

moved {
  from = kubernetes_service.minio_console
  to   = module.minio.kubernetes_service.minio_console
}

moved {
  from = kubernetes_ingress_v1.minio_console
  to   = module.minio.kubernetes_ingress_v1.minio_console
}

moved {
  from = kubernetes_job.minio_create_bucket
  to   = module.minio.kubernetes_job.minio_create_bucket
}

# -----------------------------------------------------------------------------
# Monitoring Module
# -----------------------------------------------------------------------------
moved {
  from = helm_release.monitoring
  to   = module.monitoring.helm_release.monitoring
}

# -----------------------------------------------------------------------------
# Pi-hole Module
# -----------------------------------------------------------------------------
moved {
  from = kubernetes_namespace.pihole
  to   = module.pihole.kubernetes_namespace.pihole
}

moved {
  from = kubernetes_config_map.pihole_custom_dns
  to   = module.pihole.kubernetes_config_map.pihole_custom_dns
}

moved {
  from = REDACTED_912a6d18_claim.pihole_data
  to   = module.pihole.REDACTED_912a6d18_claim.pihole_data
}

moved {
  from = kubernetes_deployment.pihole
  to   = module.pihole.kubernetes_deployment.pihole
}

moved {
  from = kubernetes_service.pihole_dns_tcp
  to   = module.pihole.kubernetes_service.pihole_dns_tcp
}

moved {
  from = kubernetes_service.pihole_dns_udp
  to   = module.pihole.kubernetes_service.pihole_dns_udp
}

moved {
  from = kubernetes_service.pihole_web
  to   = module.pihole.kubernetes_service.pihole_web
}

moved {
  from = kubernetes_ingress_v1.pihole_ingress
  to   = module.pihole.kubernetes_ingress_v1.pihole_ingress
}

# -----------------------------------------------------------------------------
# Velero Module
# -----------------------------------------------------------------------------
moved {
  from = kubernetes_namespace.velero
  to   = module.velero.kubernetes_namespace.velero
}

moved {
  from = kubernetes_secret.velero_s3_credentials
  to   = module.velero.kubernetes_secret.velero_s3_credentials
}

moved {
  from = REDACTED_4ad9fc99.velero
  to   = module.velero.REDACTED_4ad9fc99.velero
}

moved {
  from = REDACTED_2b73dc4c.velero
  to   = module.velero.REDACTED_2b73dc4c.velero
}

moved {
  from = kubernetes_deployment.velero
  to   = module.velero.kubernetes_deployment.velero
}

moved {
  from = kubernetes_daemonset.velero_node_agent
  to   = module.velero.kubernetes_daemonset.velero_node_agent
}

moved {
  from = kubernetes_deployment.velero_ui
  to   = module.velero.kubernetes_deployment.velero_ui
}

moved {
  from = kubernetes_service.velero_ui
  to   = module.velero.kubernetes_service.velero_ui
}

moved {
  from = kubernetes_ingress_v1.velero_ui
  to   = module.velero.kubernetes_ingress_v1.velero_ui
}

moved {
  from = kubernetes_manifest.velero_backup_location
  to   = module.velero.kubernetes_manifest.velero_backup_location
}

moved {
  from = kubernetes_manifest.velero_snapshot_location
  to   = module.velero.kubernetes_manifest.velero_snapshot_location
}

moved {
  from = kubernetes_manifest.velero_schedule_daily
  to   = module.velero.kubernetes_manifest.velero_schedule_daily
}

moved {
  from = kubernetes_manifest.velero_schedule_weekly
  to   = module.velero.kubernetes_manifest.velero_schedule_weekly
}
