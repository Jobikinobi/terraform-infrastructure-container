#!/bin/bash
# Add webhooks to all GitHub repositories for unified tracking
# This script is SAFE and NON-DESTRUCTIVE - it only adds webhooks

set -e

WORKER_URL="https://terraform-infrastructure-container.joe-1a2.workers.dev/api/github/webhook"
WEBHOOK_EVENTS="push,pull_request,issues,release,create,delete"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Add Webhooks to GitHub Repositories                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Get all non-fork repositories
echo -e "${BLUE}Fetching your repositories (excluding forks)...${NC}"
REPOS=$(gh repo list Jobikinobi --limit 200 --json name,isFork | jq -r '.[] | select(.isFork == false) | .name')

REPO_COUNT=$(echo "$REPOS" | wc -l | tr -d ' ')
echo -e "${GREEN}Found ${REPO_COUNT} repositories (excluding forks)${NC}"
echo ""

# Check which repos already have the webhook
echo -e "${BLUE}Checking existing webhooks...${NC}"
REPOS_WITH_WEBHOOK=()
REPOS_WITHOUT_WEBHOOK=()

for repo in $REPOS; do
  HAS_WEBHOOK=$(gh api "repos/Jobikinobi/${repo}/hooks" 2>/dev/null | jq -r ".[] | select(.config.url == \"$WORKER_URL\") | .id" || echo "")

  if [ -n "$HAS_WEBHOOK" ]; then
    REPOS_WITH_WEBHOOK+=("$repo")
  else
    REPOS_WITHOUT_WEBHOOK+=("$repo")
  fi
done

echo -e "${GREEN}✓ ${#REPOS_WITH_WEBHOOK[@]} repos already have webhook${NC}"
echo -e "${YELLOW}➕ ${#REPOS_WITHOUT_WEBHOOK[@]} repos need webhook${NC}"
echo ""

# Safety check - confirm before proceeding
echo "═══════════════════════════════════════════════════════════"
echo -e "${YELLOW}This will add webhooks to ${#REPOS_WITHOUT_WEBHOOK[@]} repositories${NC}"
echo ""
echo "Webhook will:"
echo "  ✓ Listen for: $WEBHOOK_EVENTS"
echo "  ✓ Send to: $WORKER_URL"
echo "  ✓ Track activity in D1 database"
echo ""
echo "This is SAFE and NON-DESTRUCTIVE:"
echo "  ✓ Only adds webhooks (no other changes)"
echo "  ✓ Doesn't modify repo settings"
echo "  ✓ Doesn't change code or branches"
echo "  ✓ Can be removed anytime"
echo ""
read -p "Continue? (y/N): " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Aborted. No changes made.${NC}"
    exit 0
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${BLUE}Adding webhooks to repositories...${NC}"
echo ""

SUCCESS_COUNT=0
FAIL_COUNT=0
SKIPPED_COUNT=0

for repo in "${REPOS_WITHOUT_WEBHOOK[@]}"; do
  echo -e "${BLUE}→ ${repo}...${NC}"

  # Try to add webhook
  RESULT=$(gh api "repos/Jobikinobi/${repo}/hooks" \
    -X POST \
    -f "name=web" \
    -f "active=true" \
    -f "events[]=$WEBHOOK_EVENTS" \
    -f "config[url]=$WORKER_URL" \
    -f "config[content_type]=json" \
    -f "config[insecure_ssl]=0" 2>&1)

  if echo "$RESULT" | grep -q '"id"'; then
    echo -e "${GREEN}  ✓ Webhook added${NC}"
    ((SUCCESS_COUNT++))
  elif echo "$RESULT" | grep -qi "hook already exists\|already exists"; then
    echo -e "${YELLOW}  ⊘ Webhook already exists${NC}"
    ((SKIPPED_COUNT++))
  else
    echo -e "${RED}  ✗ Failed: $(echo "$RESULT" | jq -r '.message // "Unknown error"' 2>/dev/null || echo "$RESULT")${NC}"
    ((FAIL_COUNT++))
  fi

  # Rate limit protection
  sleep 0.5
done

echo ""
echo "═══════════════════════════════════════════════════════════"
echo -e "${GREEN}✓ Webhook deployment complete!${NC}"
echo ""
echo "Summary:"
echo -e "  ${GREEN}Success: $SUCCESS_COUNT${NC}"
echo -e "  ${YELLOW}Skipped: $SKIPPED_COUNT${NC}"
echo -e "  ${RED}Failed: $FAIL_COUNT${NC}"
echo -e "  ${BLUE}Total: ${#REPOS_WITHOUT_WEBHOOK[@]}${NC}"
echo ""
echo "All repositories are now tracked!"
echo "Activity will be logged to D1 database."
echo ""
echo "To verify:"
echo "  gh api repos/Jobikinobi/<repo-name>/hooks"
echo ""
echo "To view tracked data:"
echo "  npx wrangler d1 execute terraform-deployments \\"
echo "    --command \"SELECT * FROM webhook_events ORDER BY received_at DESC LIMIT 10\" \\"
echo "    --remote"
echo ""
