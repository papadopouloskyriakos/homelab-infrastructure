# ========================================================================
# Tetragon Module - Provider Requirements
# ========================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "REDACTED_1158da07"
      version = ">= 2.38.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17.0"
    }
  }
}
