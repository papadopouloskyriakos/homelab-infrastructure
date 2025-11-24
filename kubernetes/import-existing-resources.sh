#!/bin/bash
***REMOVED***
# import-existing-resources.sh
***REMOVED***
# Run this ONCE before the first OpenTofu apply to import existing resources
# This prevents OpenTofu from destroying and recreating your running workloads
#
# Prerequisites:
# - kubectl access to cluster
# - OpenTofu installed
# - Environment variables set (TF_VAR_k8s_host, TF_VAR_k8s_token, etc.)
#
# Usage:
#   export TF_VAR_k8s_host="https://api-k8s.example.net:6443"
#   export TF_VAR_k8s_token="<your-token>"
#   export TF_VAR_k8s_ca_cert="<base64-ca-cert>"
#   ./import-existing-resources.sh
***REMOVED***

set -e

cd "$(dirname "$0")"

echo "=============================================="
echo "  OpenTofu Import - Existing K8s Resources"
echo "=============================================="
echo ""

# Initialize OpenTofu
echo "[1/5] Initializing OpenTofu..."
tofu init

# Function to import with error handling
import_resource() {
    local resource=$1
    local id=$2
    echo "  Importing: $resource"
    if tofu import "$resource" "$id" 2>/dev/null; then
        echo "    ✓ Success"
    else
        echo "    ⚠ Skipped (may not exist or already imported)"
    fi
}

# Import Helm releases
echo ""
echo "[2/5] Importing Helm releases..."
import_resource 'helm_release.nfs_provisioner' 'nfs-provisioner/nfs-provisioner'
import_resource 'helm_release.ingress_nginx' 'ingress-nginx/ingress-nginx'
import_resource 'helm_release.monitoring' 'monitoring/monitoring'
import_resource 'helm_release.REDACTED_ac4dcdf5' 'REDACTED_d97cef76/REDACTED_d97cef76'
import_resource 'helm_release.gitlab_agent_k8s[0]' 'REDACTED_01b50c5d/k8s-agent'
import_resource 'helm_release.gitlab_runner[0]' 'REDACTED_01b50c5d/gitlab-runner'

# Import Pihole resources
echo ""
echo "[3/5] Importing Pihole resources..."
import_resource 'kubernetes_namespace.pihole' 'pihole'
import_resource 'kubernetes_config_map.pihole_custom_dns' 'pihole/pihole-custom-dns'
import_resource 'REDACTED_912a6d18_claim.pihole_data' 'pihole/pihole-data'
import_resource 'kubernetes_deployment.pihole' 'pihole/pihole'
import_resource 'kubernetes_service.pihole_web' 'pihole/pihole-web'
import_resource 'kubernetes_service.pihole_dns_tcp' 'pihole/pihole-dns-tcp'
import_resource 'kubernetes_service.pihole_dns_udp' 'pihole/pihole-dns-udp'
import_resource 'kubernetes_ingress_v1.pihole_ingress' 'pihole/pihole-ingress'

# Import AWX resources
echo ""
echo "[4/5] Importing AWX resources..."
import_resource 'kubernetes_namespace.awx' 'awx'
import_resource 'REDACTED_5a69a0fb.nfs_sc' 'nfs-sc'
import_resource 'REDACTED_912a6d18.awx_postgres' 'awx-postgres-data-pv'
import_resource 'REDACTED_912a6d18.awx_projects' 'awx-projects-pv'
import_resource 'REDACTED_912a6d18_claim.awx_projects' 'awx/my-awx-projects'

# Import Dashboard RBAC
echo ""
echo "[5/5] Importing Dashboard RBAC..."
import_resource 'REDACTED_4ad9fc99.dashboard_admin' 'REDACTED_d97cef76/dashboard-admin'
import_resource 'REDACTED_2b73dc4c.dashboard_admin' 'dashboard-admin'
import_resource 'kubernetes_secret.REDACTED_00f72976' 'REDACTED_d97cef76/REDACTED_c48f3618'

echo ""
echo "=============================================="
echo "  Import Complete!"
echo "=============================================="
echo ""
echo "Next steps:"
echo "  1. Run 'tofu plan' to verify no destructive changes"
echo "  2. Review the plan carefully"
echo "  3. Commit changes to Git"
echo "  4. Run pipeline (manual apply)"
echo ""
