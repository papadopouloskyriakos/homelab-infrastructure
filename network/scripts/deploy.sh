#!/bin/bash
set -e

echo "============================================================"
echo "  DEPLOYING FIXED DRIFT DETECTION SCRIPTS"
echo "============================================================"
echo ""

# Check files exist
if [ ! -f "filter_dynamic_content.py" ] || [ ! -f "pre_deploy_drift_gate.py" ]; then
    echo "ERROR: Required files not found"
    echo "Download filter_dynamic_content.py and pre_deploy_drift_gate.py first"
    exit 1
fi

# Test the filter first
echo "[1/4] Testing filter..."
python3 test_filter.py
if [ $? -ne 0 ]; then
    echo "ERROR: Filter test failed!"
    exit 1
fi
echo ""

# Backup
echo "[2/4] Backing up old scripts..."
mkdir -p network/scripts/backup
if [ -f "network/scripts/pre_deploy_drift_gate.py" ]; then
    cp network/scripts/pre_deploy_drift_gate.py network/scripts/backup/
fi
if [ -f "network/scripts/filter_dynamic_content.py" ]; then
    cp network/scripts/filter_dynamic_content.py network/scripts/backup/
fi
echo ""

# Install
echo "[3/4] Installing new scripts..."
cp filter_dynamic_content.py network/scripts/
cp pre_deploy_drift_gate.py network/scripts/
chmod +x network/scripts/*.py
echo ""

# Commit
echo "[4/4] Committing..."
git add network/scripts/filter_dynamic_content.py
git add network/scripts/pre_deploy_drift_gate.py

git commit -m "Fix: Super aggressive dynamic content filtering

Changes:
- Use .search() instead of .match() for pattern matching
- More permissive regex patterns
- Catches all variations of dynamic content:
  * Building configuration (any format)
  * Current configuration bytes (any format)
  * Last configuration change (any format)
  * NVRAM timestamps
  * Crypto checksums
  * NTP clock-period

Testing: Verified with test_filter.py - correctly filters
all dynamic content while preserving actual config."

echo ""
echo "============================================================"
echo "  READY TO PUSH"
echo "============================================================"
echo ""
read -p "Push to GitLab now? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    git push origin main
    echo ""
    echo "PUSHED!"
    echo ""
    echo "Next steps:"
    echo "1. Close MR #12 and #13 (broken by old filter)"
    echo "2. Wait for new pipeline"
    echo "3. Should NOT create drift MR for timestamp changes"
else
    echo "Not pushed. Push manually when ready:"
    echo "  git push origin main"
fi