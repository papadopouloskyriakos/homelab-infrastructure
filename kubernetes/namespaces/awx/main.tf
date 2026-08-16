# =============================================================================
# AWX (Ansible Automation Platform)
# =============================================================================
# Deployed via AWX Operator (operator must be installed separately)
# This file manages: Namespace, StorageClass, PV/PVC, AWX CR, PDBs
#
# CSI Migration completed 2024-11-27 (NL):
# - PostgreSQL moved from NFS to Synology CSI iSCSI
# - Projects remain on NFS (requires RWX)
#
# Storage:
#   - PostgreSQL: iSCSI, two modes selected by var.REDACTED_5ac2e308:
#       * "" (default)  — dynamically provisioned by the CSI driver via the
#         AWX CR (postgres_storage_class + init-container chown/fsGroup 26,
#         needed because a fresh iSCSI volume is root-owned). GR mode.
#       * "<pv-name>"   — static bind to a pre-existing/imported PV via a
#         module-managed PVC; the CR gets postgres_storage_class = "" and no
#         init container (imported volume already has correct perms). NL mode
#         (imported REDACTED_c7d87e23).
#   - Projects: NFS (RWX for multi-node) — static PV.
#     NFS subpath is asymmetric BY HISTORY (NL "projects", GR "awx-projects");
#     renaming the live NFS directory would orphan project data, so the
#     subpath is a variable and each site keeps its live value.
# =============================================================================

resource "kubernetes_namespace" "awx" {
  metadata {
    name = "awx"
    labels = merge(var.common_labels, {
      app = "awx"
    })
  }
}

# =============================================================================
# Storage — NFS for Projects (requires RWX)
# =============================================================================

# Manual storage class for static NFS PVs
resource "REDACTED_5a69a0fb" "nfs_sc" {
  metadata {
    name = "nfs-sc"
  }
  storage_provisioner    = "kubernetes.io/no-provisioner"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
}

# Projects PV — NFS mount for playbook storage
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
        path   = "${var.nfs_path}/${var.REDACTED_0b348a0e}"
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

# PostgreSQL PVC — static-bind mode only (var.REDACTED_5ac2e308 != "").
# The PV itself is managed by the CSI driver (imported volume).
resource "REDACTED_912a6d18_claim" "awx_postgres" {
  count = var.REDACTED_5ac2e308 != "" ? 1 : 0

  metadata {
    name      = "REDACTED_0d7ca6a5"
    namespace = kubernetes_namespace.awx.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = var.postgres_storage_class
    volume_name        = var.REDACTED_5ac2e308
    resources {
      requests = {
        storage = var.REDACTED_3e5e811f
      }
    }
  }
}

# =============================================================================
# AWX Custom Resource (requires AWX Operator to be installed)
# =============================================================================
# NOTE: The AWX Operator must be deployed BEFORE applying this CR.
# Install operator: https://github.com/ansible/awx-operator
# The operator watches for AWX CRs and creates the deployment.
# =============================================================================

resource "kubernetes_manifest" "awx_cr" {
  count = var.REDACTED_18d47a8b ? 1 : 0

  manifest = {
    apiVersion = "awx.ansible.com/v1beta1"
    kind       = "AWX"
    metadata = {
      name      = "my-awx"
      namespace = kubernetes_namespace.awx.metadata[0].name
    }
    spec = merge(
      {
        service_type = "nodeport"

        # Projects — NFS (RWX)
        projects_persistence         = true
        projects_existing_claim      = REDACTED_912a6d18_claim.awx_projects.metadata[0].name
        projects_storage_access_mode = "ReadWriteMany"
        projects_storage_size        = var.REDACTED_12032801

        # PostgreSQL — static-bind mode uses the module-managed PVC above
        # (storage class must be "" so the operator adopts it); dynamic mode
        # lets the operator provision via the CSI storage class.
        postgres_storage_class    = var.REDACTED_5ac2e308 != "" ? "" : var.postgres_storage_class
        postgres_data_volume_init = true
        postgres_storage_requirements = {
          requests = {
            storage = var.REDACTED_3e5e811f
          }
        }

        # Resource limits
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
            value   = jsonencode(["https://${var.awx_hostname}"])
          }
        ]
      },
      # Dynamic-provisioning mode only: fix iSCSI volume permissions —
      # Postgres runs as UID 26 (postgres), fresh iSCSI volumes are root-owned.
      # Deliberately ABSENT in static-bind mode so the NL CR is untouched.
      # jsondecode-over-strings: a plain object conditional fails OpenTofu's
      # type unification (branches carry different attribute sets).
      jsondecode(var.REDACTED_5ac2e308 == "" ? jsonencode({
        postgres_init_container_commands = "chown 26:26 /var/lib/pgsql/data && chmod 700 /var/lib/pgsql/data"
        postgres_security_context_settings = {
          fsGroup = 26
        }
      }) : "{}")
    )
  }
  depends_on = [
    REDACTED_912a6d18_claim.awx_projects,
    REDACTED_912a6d18_claim.awx_postgres
  ]
}

# =============================================================================
# Ingress (gated — GR fronts AWX via ingress-nginx; NL uses NodePort only)
# =============================================================================

resource "kubernetes_ingress_v1" "awx" {
  count = var.awx_ingress_enabled ? 1 : 0

  metadata {
    name      = "awx"
    namespace = kubernetes_namespace.awx.metadata[0].name
    labels    = var.common_labels
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.awx_hostname

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "my-awx-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# =============================================================================
# Pod Disruption Budgets
# =============================================================================

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
