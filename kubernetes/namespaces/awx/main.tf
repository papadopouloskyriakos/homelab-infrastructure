***REMOVED***
# AWX (Ansible Automation Platform)
***REMOVED***
# Deployed via AWX Operator
# This file manages: Namespace, PVs, PVC
# The AWX CR is applied separately after operator is installed
#
# Import commands:
# tofu import 'kubernetes_namespace.awx' 'awx'
# tofu import 'REDACTED_912a6d18.awx_postgres' 'awx-postgres-data-pv'
# tofu import 'REDACTED_912a6d18.awx_projects' 'awx-projects-pv'
# tofu import 'REDACTED_912a6d18_claim.awx_projects' 'awx/my-awx-projects'
***REMOVED***

resource "kubernetes_namespace" "awx" {
  metadata {
    name = "awx"
    labels = merge(var.common_labels, {
      app = "awx"
    })
  }
}

# Manual StorageClass for AWX (different from nfs-client)
# This uses specific NFS paths for AWX data
resource "REDACTED_5a69a0fb" "nfs_sc" {
  metadata {
    name = "nfs-sc"
  }

  storage_provisioner = "kubernetes.io/no-provisioner"
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
}

# PostgreSQL PV - specific NFS path
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

# Projects PV - specific NFS path  
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

# Projects PVC
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

***REMOVED***
# AWX Operator & CR - Apply separately!
***REMOVED***
# The AWX Operator installs CRDs that OpenTofu can't manage until they exist.
# 
# After running OpenTofu:
# 1. Install operator: kubectl apply -k awx-install-clean/
# 2. Apply AWX CR:     kubectl apply -f awx-install-clean/my-awx.yaml
#
# Alternatively, use a null_resource to apply these (uncomment below):
***REMOVED***

# resource "null_resource" "awx_operator" {
#   provisioner "local-exec" {
#     command = "kubectl apply -k ${path.module}/../awx-operator/"
#   }
#   
#   triggers = {
#     always_run = timestamp()
#   }
# }
