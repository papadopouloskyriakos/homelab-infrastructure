***REMOVED***
# External Secrets Operator
***REMOVED***

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
    labels = {
      "app.kubernetes.io/managed-by" = "opentofu"
    }
  }
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = var.chart_version

  values = [yamlencode({
    installCRDs = true

    serviceMonitor = {
      enabled   = var.REDACTED_46d876c8
      namespace = "monitoring"
    }

    webhook = {
      port = 9443
    }

    resources = {
      requests = {
        cpu    = "50m"
        memory = "128Mi"
      }
      limits = {
        memory = "256Mi"
      }
    }
  })]
}

***REMOVED***
# ClusterSecretStore for OpenBao
***REMOVED***

resource "kubernetes_manifest" "cluster_secret_store" {
  depends_on = [helm_release.external_secrets]

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "openbao"
    }
    spec = {
      provider = {
        vault = {
          server  = var.openbao_address
          path    = "secret"
          version = "v2"
          auth = {
            kubernetes = {
              mountPath = "kubernetes"
              role      = var.openbao_role
              serviceAccountRef = {
                name      = "external-secrets"
                namespace = kubernetes_namespace.external_secrets.metadata[0].name
              }
            }
          }
        }
      }
    }
  }
}

***REMOVED***
# OpenBao TokenReview RBAC
# Allows OpenBao to validate K8s ServiceAccount tokens
***REMOVED***

resource "REDACTED_4ad9fc99" "openbao_auth" {
  metadata {
    name      = "openbao-auth"
    namespace = "kube-system"
  }
}

resource "REDACTED_2b73dc4c" "openbao_tokenreview" {
  metadata {
    name = "openbao-tokenreview"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = REDACTED_4ad9fc99.openbao_auth.metadata[0].name
    namespace = "kube-system"
  }
}

resource "kubernetes_secret" "openbao_auth_token" {
  metadata {
    name      = "openbao-auth-token"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = REDACTED_4ad9fc99.openbao_auth.metadata[0].name
    }
  }
  type = "kubernetes.io/service-account-token"
}
