***REMOVED***
# AWX (Ansible Automation Platform)
***REMOVED***
# Deployed via AWX Operator
# This file manages: Namespace, StorageClass, PVs, PVC, AWX CR
#
# CSI Migration completed 2024-11-27:
# - PostgreSQL moved from NFS to Synology CSI iSCSI
# - Projects remain on NFS (requires RWX)
***REMOVED***

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
      postgres_storage_class       = ""
      postgres_data_volume_init    = true
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

