#!/bin/bash
# Configure Cloudflare Access for HOLE Substrate programmatically
# Requires: CLOUDFLARE_API_TOKEN environment variable or from .envrc

set -e

ACCOUNT_ID="1a25a792e801e687b9fe4932030cf6a6"
API_TOKEN="tbeRzIn22V5qvW2o31gVN8vx9vPB4j02pYurEJZY"
WORKER_DOMAIN="hole-substrate.joe-1a2.workers.dev"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Cloudflare Access Setup for HOLE Substrate               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Create Access Application
echo "📱 Creating Access Application..."

APP_RESPONSE=$(curl -s -X POST \
  "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/access/apps" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "name": "HOLE Substrate",
  "domain": "${WORKER_DOMAIN}",
  "type": "self_hosted",
  "session_duration": "24h",
  "auto_redirect_to_identity": false,
  "cors_headers": {
    "allow_all_origins": true,
    "allow_all_methods": true,
    "allow_all_headers": true,
    "allow_credentials": true
  }
}
EOF
)

APP_ID=$(echo "$APP_RESPONSE" | jq -r '.result.id // empty')

if [ -z "$APP_ID" ]; then
  echo "❌ Failed to create application"
  echo "$APP_RESPONSE" | jq -r '.errors[]?.message // "Unknown error"'

  # Check if app already exists
  EXISTING=$(curl -s \
    "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/access/apps" \
    -H "Authorization: Bearer ${API_TOKEN}" | \
    jq -r ".result[] | select(.domain == \"${WORKER_DOMAIN}\") | .id")

  if [ -n "$EXISTING" ]; then
    echo "ℹ️  Application already exists with ID: $EXISTING"
    APP_ID="$EXISTING"
  else
    exit 1
  fi
else
  echo "✅ Access Application created: $APP_ID"
fi

echo ""

# Step 2: Create Access Policies
echo "🔐 Creating Access Policies..."

# Policy 1: Bypass for public endpoints
echo "  Creating public endpoints policy..."
PUBLIC_POLICY=$(curl -s -X POST \
  "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/access/apps/${APP_ID}/policies" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "name": "Public Discovery Endpoints",
  "decision": "bypass",
  "include": [
    {"everyone": {}}
  ],
  "require": [],
  "exclude": [],
  "precedence": 1,
  "isolation_required": false,
  "purpose_justification_required": false,
  "approval_required": false
}
EOF
)

echo "  ✅ Public endpoints policy created"

# Policy 2: Team email access
echo "  Creating team access policy..."
TEAM_POLICY=$(curl -s -X POST \
  "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/access/apps/${APP_ID}/policies" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "name": "HOLE Foundation Team",
  "decision": "allow",
  "include": [
    {
      "email_domain": {
        "domain": "theholetruth.org"
      }
    },
    {
      "email": {
        "email": "joe@theholetruth.org"
      }
    }
  ],
  "require": [],
  "exclude": [],
  "precedence": 2
}
EOF
)

echo "  ✅ Team access policy created"

# Policy 3: Service token access
echo "  Creating service token policy..."
SERVICE_POLICY=$(curl -s -X POST \
  "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/access/apps/${APP_ID}/policies" \
  -H "Authorization: Bearer ${API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d @- <<EOF
{
  "name": "Project Service Tokens",
  "decision": "non_identity",
  "include": [
    {
      "everyone": {}
    }
  ],
  "require": [],
  "exclude": [],
  "precedence": 3
}
EOF
)

echo "  ✅ Service token policy created"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ Cloudflare Access configured successfully!"
echo ""
echo "Application ID: $APP_ID"
echo "Domain: ${WORKER_DOMAIN}"
echo ""
echo "Next steps:"
echo "  1. Generate service tokens"
echo "  2. Add validation middleware to Worker"
echo "  3. Test protected endpoints"
echo ""
