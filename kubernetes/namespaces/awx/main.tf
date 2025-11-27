***REMOVED***
# AWX (Ansible Automation Platform)
***REMOVED***
# Deployed via AWX Operator
# This file manages: Namespace, StorageClass, PVs, PVC, AWX CR
#
# Import commands (run before first apply):
# tofu import 'module.awx.kubernetes_namespace.awx' 'awx'
# tofu import 'module.awx.REDACTED_5a69a0fb.nfs_sc' 'nfs-sc'
# tofu import 'module.awx.REDACTED_912a6d18.awx_postgres' 'awx-postgres-data-pv'
# tofu import 'module.awx.REDACTED_912a6d18.awx_projects' 'awx-projects-pv'
# tofu import 'module.awx.REDACTED_912a6d18_claim.awx_projects' 'awx/my-awx-projects'
# tofu import 'module.awx.kubernetes_manifest.awx_cr' 'apiVersion=awx.ansible.com/v1beta1,kind=AWX,namespace=awx,name=my-awx'
***REMOVED***

resource "kubernetes_namespace" "awx" {
  metadata {
    name = "awx"
    labels = merge(var.common_labels, {
      app = "awx"
    })
  }
}

resource "REDACTED_5a69a0fb" "nfs_sc" {
  metadata {
    name = "nfs-sc"
  }
  storage_provisioner    = "kubernetes.io/no-provisioner"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
}

resource "REDACTED_912a6d18" "awx_postgres" {
  metadata {
    name = "awx-postgres-data-pv"
    labels = {
      type = "awx-postgres"
    }
  }
  spec {
    capacity = {
      storage = var.REDACTED_3e5e811f
    }
    access_modes                     = ["ReadWriteOnce"]
    storage_class_name               = "nfs-sc"
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      nfs {
        server = var.nfs_server
        path   = "${var.nfs_path}/postgres"
      }
    }
  }
}

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
    REDACTED_912a6d18.awx_postgres
  ]
}

# Import existing AWX CR into state (one-time import)
import {
  to = kubernetes_manifest.awx_cr
  id = "apiVersion=awx.ansible.com/v1beta1,kind=AWX,namespace=awx,name=my-awx"
}
