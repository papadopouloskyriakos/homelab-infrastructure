#!/bin/bash
set -e

echo "========================================================"
echo "  FINAL FIX: Write Filtered Config to MR Branch"
echo "========================================================"
echo ""

if [ ! -f "pre_deploy_drift_gate.py" ]; then
    echo "ERROR: pre_deploy_drift_gate.py not found"
    exit 1
fi

echo "[1/3] Backing up old script..."
mkdir -p network/scripts/backup
cp network/scripts/pre_deploy_drift_gate.py network/scripts/backup/ 2>/dev/null || true
echo ""

echo "[2/3] Installing new script..."
cp pre_deploy_drift_gate.py network/scripts/
chmod +x network/scripts/pre_deploy_drift_gate.py
echo ""

echo "[3/3] Committing..."
git add network/scripts/pre_deploy_drift_gate.py
git commit -m "Fix: Write filtered config to drift MR branch

Critical fix: MR now writes filtered config (without timestamps/
byte counts/headers) to the branch instead of raw config.

This prevents MR diffs from showing timestamp noise while still
correctly detecting actual configuration drift.

Changes:
- compare_configs() now returns filtered configs
- create_drift_merge_request() writes filtered config to branch
- MR diffs will show only real configuration changes

Result: Clean MR diffs showing only actual config differences."

echo ""
echo "========================================================"
echo "  READY TO PUSH"
echo "========================================================"
echo ""
read -p "Push to GitLab now? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    git push origin main
    echo ""
    echo "PUSHED!"
    echo ""
    echo "Next:"
    echo "1. Close MRs #12, #13, #14 (broken)"
    echo "2. Wait for new pipeline"
    echo "3. New MR will show CLEAN diff (no timestamps)"
else
    echo "Not pushed. Push when ready:"
    echo "  git push origin main"
fi