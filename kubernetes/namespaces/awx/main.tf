# =============================================================================
# AWX (Ansible Automation Platform)
# =============================================================================
# Deployed via AWX Operator
# This file manages: Namespace, StorageClass, PVs, PVC, AWX CR
#
# CSI Migration completed 2024-11-27:

# - PostgreSQL moved from NFS to Synology CSI iSCSI
# - Projects remain on NFS (requires RWX)
# =============================================================================

resource "kubernetes_namespace" "awx" {
  metadata {
    name = "awx"
    labels = merge(var.common_labels, {
      app = "awx"
    })
  }
}

# NFS storage class - still needed for projects (RWX)
resource "REDACTED_5a69a0fb" "nfs_sc" {
  metadata {
    name = "nfs-sc"
  }
  storage_provisioner    = "kubernetes.io/no-provisioner"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
}

# Projects PV - stays on NFS (requires RWX for multi-node access)
resource "REDACTED_912a6d18" "awx_projects" {
  metadata {
    name = "awx-projects-pv"
    labels = {
      type = "awx-projects"
    }
  }
  spec {
    capacity = {
      storage = var.REDACTED_12032801
    }
    access_modes                     = ["ReadWriteMany"]
    storage_class_name               = "nfs-sc"
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      nfs {
        server = var.nfs_server
        path   = "${var.nfs_path}/projects"
      }
    }
  }
}

resource "REDACTED_912a6d18_claim" "awx_projects" {
  metadata {
    name      = "my-awx-projects"
    namespace = kubernetes_namespace.awx.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs-sc"
    resources {
      requests = {
        storage = var.REDACTED_12032801
      }
    }
    volume_name = REDACTED_912a6d18.awx_projects.metadata[0].name
  }
}

# PostgreSQL PVC - CSI iSCSI (dynamically provisioned, imported)
# The PV is managed by Synology CSI driver
resource "REDACTED_912a6d18_claim" "awx_postgres" {
  metadata {
    name      = "REDACTED_0d7ca6a5"
    namespace = kubernetes_namespace.awx.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "REDACTED_b280aec5"
    volume_name        = "REDACTED_c7d87e23"
    resources {
      requests = {
        storage = var.REDACTED_3e5e811f
      }
    }
  }
}

resource "kubernetes_manifest" "awx_cr" {
  manifest = {
    apiVersion = "awx.ansible.com/v1beta1"
    kind       = "AWX"
    metadata = {
      name      = "my-awx"
      namespace = kubernetes_namespace.awx.metadata[0].name
    }
    spec = {
      service_type                 = "nodeport"
      projects_persistence         = true
      projects_existing_claim      = REDACTED_912a6d18_claim.awx_projects.metadata[0].name
      projects_storage_access_mode = "ReadWriteMany"
      projects_storage_size        = var.REDACTED_12032801
      # PostgreSQL uses existing CSI PVC managed above
      postgres_storage_class    = ""
      postgres_data_volume_init = true
      postgres_storage_requirements = {
        requests = {
          storage = var.REDACTED_3e5e811f
        }
      }
      web_resource_requirements = {
        limits   = { cpu = "1", memory = "2Gi" }
        requests = { cpu = "500m", memory = "1Gi" }
      }
      task_resource_requirements = {
        limits   = { cpu = "1", memory = "2Gi" }
        requests = { cpu = "500m", memory = "1Gi" }
      }
      postgres_resource_requirements = {
        limits   = { cpu = "500m", memory = "1Gi" }
        requests = { cpu = "250m", memory = "512Mi" }
      }
      ee_resource_requirements = {
        limits   = { cpu = "500m", memory = "1Gi" }
        requests = { cpu = "250m", memory = "512Mi" }
      }
      extra_settings = [
        {
          setting = "REDACTED_db732a25"
          value   = jsonencode(["https://awx.${var.domain}"])
        }
      ]
    }
  }
  depends_on = [
    REDACTED_912a6d18_claim.awx_projects,
    REDACTED_912a6d18_claim.awx_postgres
  ]
}

# -----------------------------------------------------------------------------
# AWX Pod Disruption Budgets
# -----------------------------------------------------------------------------
resource "REDACTED_e0540b90" "awx_postgres" {
  metadata {
    name      = "awx-postgres-pdb"
    namespace = kubernetes_namespace.awx.metadata[0].name
    labels    = var.common_labels
  }

  spec {
    min_available = "1"
    selector {
      match_labels = {
        "app.kubernetes.io/name"     = "postgres-15"
        "app.kubernetes.io/instance" = "postgres-15-my-awx"
      }
    }
  }
}

resource "REDACTED_e0540b90" "awx_web" {
  metadata {
    name      = "awx-web-pdb"
    namespace = kubernetes_namespace.awx.metadata[0].name
    labels    = var.common_labels
  }

  spec {
    min_available = "1"
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "my-awx-web"
      }
    }
  }
}

resource "REDACTED_e0540b90" "awx_task" {
  metadata {
    name      = "awx-task-pdb"
    namespace = kubernetes_namespace.awx.metadata[0].name
    labels    = var.common_labels
  }

  spec {
    min_available = "1"
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "my-awx-task"
      }
    }
  }
}

# -----------------------------------------------------------------------------
# AWX Default Instance Group Fix
# -----------------------------------------------------------------------------
# The AWX operator creates the task instance in the "controlplane" group but NOT
# in the "default" group. Job templates use "default" by default, so jobs queue
# forever as "pending" with no execution capacity. This CronJob runs awx-manage
# every 5 minutes to ensure the task instance is in both groups.
# Root cause: AWX operator does not expose instance group membership in the CR spec.
resource "kubernetes_cron_job_v1" "awx_instance_group_fix" {
  metadata {
    name      = "awx-instance-group-fix"
    namespace = kubernetes_namespace.awx.metadata[0].name
    labels    = var.common_labels
  }

  spec {
    schedule                      = "*/5 * * * *"
    successful_jobs_history_limit = 1
    failed_jobs_history_limit     = 1
    concurrency_policy            = "Forbid"

    job_template {
      metadata {
        labels = var.common_labels
      }
      spec {
        backoff_limit              = 1
        active_deadline_seconds    = 60
        ttl_seconds_after_finished = 120

        template {
          metadata {
            labels = var.common_labels
          }
          spec {
            restart_policy       = "Never"
            service_account_name = "my-awx"

            container {
              name    = "fix-instance-group"
              image   = "bitnami/kubectl:latest"
              command = ["/bin/sh", "-c"]
              args = [<<-EOT
                kubectl exec -n awx deploy/my-awx-task -c my-awx-task -- \
                  awx-manage shell -c '
from awx.main.models import Instance, InstanceGroup
try:
    ig = InstanceGroup.objects.get(name="default")
    for inst in Instance.objects.all():
        if inst not in ig.instances.all():
            ig.instances.add(inst)
            ig.save()
            print("Added", inst.hostname, "to default group")
        else:
            print(inst.hostname, "already in default group")
except Exception as e:
    print("Error:", e)
'
              EOT
              ]
            }
          }
        }
      }
    }
  }
}

