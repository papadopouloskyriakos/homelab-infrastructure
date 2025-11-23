#!/bin/bash
###############################################################################
# Drift Detection Fix - Deployment Script
###############################################################################

set -e

echo "============================================================"
echo "  DRIFT DETECTION FIX - DEPLOYMENT"
echo "============================================================"
echo ""

# Pre-flight checks
echo "[1/5] Pre-flight checks..."

if [ ! -f "pre_deploy_drift_gate.py" ]; then
    echo "ERROR: pre_deploy_drift_gate.py not found"
    exit 1
fi

if [ ! -f "filter_dynamic_content.py" ]; then
    echo "ERROR: filter_dynamic_content.py not found"
    exit 1
fi

if [ ! -d ".git" ]; then
    echo "ERROR: Not in a git repository"
    exit 1
fi

echo "   Files found"
echo ""

# Backup current scripts
echo "[2/5] Backing up current scripts..."
if [ -f "network/scripts/pre_deploy_drift_gate.py" ]; then
    cp network/scripts/pre_deploy_drift_gate.py network/scripts/pre_deploy_drift_gate.py.backup
    echo "   Backed up pre_deploy_drift_gate.py"
fi

if [ -f "network/scripts/filter_dynamic_content.py" ]; then
    cp network/scripts/filter_dynamic_content.py network/scripts/filter_dynamic_content.py.backup
    echo "   Backed up filter_dynamic_content.py"
fi
echo ""

# Copy new scripts
echo "[3/5] Installing new scripts..."
cp pre_deploy_drift_gate.py network/scripts/
cp filter_dynamic_content.py network/scripts/

chmod +x network/scripts/pre_deploy_drift_gate.py
chmod +x network/scripts/filter_dynamic_content.py

echo "   Scripts installed"
echo ""

# Git operations
echo "[4/5] Committing changes..."
git add network/scripts/pre_deploy_drift_gate.py
git add network/scripts/filter_dynamic_content.py

git commit -m "Fix: Drift detection MR branching and enhanced filtering

Critical fixes:
- Create drift branches from baseline commit (not current main)
  This ensures MRs correctly show device->baseline changes
  
- Enhanced dynamic content filtering:
  * Building configuration headers
  * Current configuration byte counts (all variations)
  * Last configuration change timestamps
  * NVRAM config timestamps
  * Crypto checksums
  * NTP clock-period
  
- Added filtering statistics to debug output

This resolves:
1. Backward MRs showing removals instead of additions
2. False drift detection from timestamp/byte count changes
3. Unnecessary drift MRs for routine device operations"

echo "   Changes committed"
echo ""

# Push to GitLab
echo "[5/5] Pushing to GitLab..."
echo ""

read -p "Ready to push? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    git push origin main
    echo ""
    echo "   Pushed to GitLab"
else
    echo ""
    echo "   Push cancelled. Push manually later:"
    echo "   git push origin main"
    exit 0
fi

echo ""
echo "============================================================"
echo "  DEPLOYMENT COMPLETE"
echo "============================================================"
echo ""
echo "NEXT STEPS:"
echo ""
echo "1. Close MR #12 (it's backwards)"
echo "   Comment: 'Superseded by drift detection fix'"
echo ""
echo "2. Wait for new pipeline to complete"
echo ""
echo "3. If new drift MR created:"
echo "   - Review it (should show ACTUAL device changes)"
echo "   - Merge it"
echo "   - Rebase your commit:"
echo "     git fetch origin"
echo "     git rebase origin/main"
echo "     git push --force-with-lease"
echo ""
echo "4. If NO drift MR:"
echo "   - Deployment should proceed automatically"
echo ""
echo "============================================================"
echo ""