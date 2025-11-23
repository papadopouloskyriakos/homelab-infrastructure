#!/bin/bash
################################################################################
# Rebase After Drift MR
#
# Helper script to rebase your commit after merging a drift detection MR.
# 
# This handles the common workflow:
# 1. Drift MR was merged (device changes now in main)
# 2. Your commit needs to be rebased on top
# 3. Force push to trigger new pipeline
#
# Usage: ./network/scripts/rebase-after-drift.sh
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo "========================================================================"
echo "🔄 Rebase After Drift MR Merge"
echo "========================================================================"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}ERROR: Not in a git repository${NC}"
    exit 1
fi

# Check if we're on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "${YELLOW}WARNING: You're on branch '$CURRENT_BRANCH', not 'main'${NC}"
    echo "This script is designed for main branch workflow."
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}ERROR: You have uncommitted changes${NC}"
    echo ""
    echo "Please commit or stash your changes first:"
    echo "  git add ."
    echo "  git commit -m 'Your message'"
    echo ""
    echo "Or to stash:"
    echo "  git stash"
    echo ""
    exit 1
fi

echo "Step 1: Fetching latest from origin..."
echo "----------------------------------------"
git fetch origin

# Check how many commits ahead we are
COMMITS_AHEAD=$(git rev-list --count origin/main..HEAD)

if [ "$COMMITS_AHEAD" -eq 0 ]; then
    echo -e "${GREEN}✅ Already up to date with origin/main${NC}"
    echo ""
    echo "No rebase needed. Your branch is already synced."
    exit 0
fi

echo ""
echo "You have $COMMITS_AHEAD commit(s) to rebase"
echo ""

# Show what will be rebased
echo "Commits that will be rebased:"
echo "----------------------------------------"
git log --oneline origin/main..HEAD
echo ""

# Confirm with user
read -p "Proceed with rebase? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Step 2: Rebasing onto origin/main..."
echo "----------------------------------------"

if git rebase origin/main; then
    echo ""
    echo -e "${GREEN}✅ Rebase successful!${NC}"
    echo ""
    
    echo "Step 3: Force pushing to origin..."
    echo "----------------------------------------"
    
    # Show what we're about to push
    echo ""
    echo "About to force push these commits:"
    git log --oneline origin/main..HEAD
    echo ""
    
    read -p "Push to origin/main? (Y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo ""
        echo "Rebase complete but not pushed."
        echo "Push manually with:"
        echo -e "  ${BLUE}git push origin main --force-with-lease${NC}"
        exit 0
    fi
    
    echo ""
    if git push origin main --force-with-lease; then
        echo ""
        echo "========================================================================"
        echo -e "${GREEN}✅ SUCCESS${NC}"
        echo "========================================================================"
        echo ""
        echo "Your commit has been rebased and pushed!"
        echo ""
        echo "Next steps:"
        echo "  1. Check GitLab - a new pipeline should start automatically"
        echo "  2. The pipeline will now deploy BOTH:"
        echo "     • The device drift changes (from merged MR)"
        echo "     • Your GitLab changes (rebased on top)"
        echo ""
        echo "========================================================================"
    else
        echo ""
        echo -e "${RED}ERROR: Push failed${NC}"
        echo ""
        echo "This can happen if:"
        echo "  • Someone else pushed to main while you were rebasing"
        echo "  • You don't have push permissions"
        echo ""
        echo "Try running this script again, or push manually with:"
        echo -e "  ${BLUE}git push origin main --force-with-lease${NC}"
        exit 1
    fi
else
    echo ""
    echo -e "${RED}ERROR: Rebase failed with conflicts${NC}"
    echo ""
    echo "You'll need to resolve conflicts manually:"
    echo ""
    echo "1. Check conflicted files:"
    echo -e "   ${BLUE}git status${NC}"
    echo ""
    echo "2. Edit files to resolve conflicts"
    echo ""
    echo "3. Mark as resolved:"
    echo -e "   ${BLUE}git add <file>${NC}"
    echo ""
    echo "4. Continue rebase:"
    echo -e "   ${BLUE}git rebase --continue${NC}"
    echo ""
    echo "5. Push after rebase completes:"
    echo -e "   ${BLUE}git push origin main --force-with-lease${NC}"
    echo ""
    echo "Or to abort the rebase:"
    echo -e "   ${BLUE}git rebase --abort${NC}"
    echo ""
    exit 1
fi