***REMOVED***
# Kubernetes Infrastructure - Main Entry Point
***REMOVED***

locals {
  common_labels = {
    "managed-by"  = "opentofu"
    "environment" = "production"
    "repository"  = "REDACTED_25022d4e"
  }
  
  # Timezone for all workloads
  timezone = "Europe/Amsterdam"
}
