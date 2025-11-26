#!/bin/bash
# Sync secrets from SecretSpec to Cloudflare Workers
# This script pulls secrets from macOS Keychain (via SecretSpec) and pushes them to Cloudflare

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  SecretSpec → Cloudflare Secrets Sync                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to get secret from SecretSpec (macOS Keychain)
get_secret() {
    local key_name="$1"
    security find-generic-password -s "secretspec/MIPDS-AI-Project/default/${key_name}" -w 2>/dev/null || echo ""
}

# Function to push secret to Cloudflare Worker
push_secret() {
    local secret_name="$1"
    local secret_value="$2"

    if [ -z "$secret_value" ]; then
        echo -e "${YELLOW}⊘ Skipping ${secret_name} - not found in SecretSpec${NC}"
        return 1
    fi

    echo -e "${BLUE}→ Uploading ${secret_name}...${NC}"
    echo "$secret_value" | npx wrangler secret put "$secret_name" 2>&1 | grep -E "(Success|Created)" || true
    echo -e "${GREEN}✓ ${secret_name} uploaded${NC}"
}

echo "Checking for required secrets in SecretSpec..."
echo ""

# Cloudflare secrets
echo "═══ Cloudflare Secrets ═══"
CLOUDFLARE_API_TOKEN=$(get_secret "CLOUDFLARE_GLOBAL_API_KEY")
CLOUDFLARE_ACCOUNT_ID=$(get_secret "CLOUDFLARE_ACCOUNT_ID")

push_secret "CLOUDFLARE_API_TOKEN" "$CLOUDFLARE_API_TOKEN"
push_secret "CLOUDFLARE_ACCOUNT_ID" "$CLOUDFLARE_ACCOUNT_ID"

echo ""
echo "═══ Auth0 Secrets ═══"
# Note: Auth0 secrets might be in keychain under different names
# We'll need to add them manually or update this script

echo -e "${YELLOW}⊘ Auth0 secrets not found in MIPDS-AI-Project SecretSpec${NC}"
echo "  You may need to add these manually:"
echo "  - AUTH0_CLIENT_ID"
echo "  - AUTH0_CLIENT_SECRET"
echo "  - AUTH0_DOMAIN"

echo ""
echo "═══ Azure Secrets ═══"
echo -e "${YELLOW}⊘ Azure secrets not found in MIPDS-AI-Project SecretSpec${NC}"
echo "  You may need to add these manually:"
echo "  - AZURE_CLIENT_ID"
echo "  - AZURE_CLIENT_SECRET"
echo "  - AZURE_TENANT_ID"

echo ""
echo "═══ Additional API Keys (Optional) ═══"
OPENAI_API_KEY=$(get_secret "OPENAI_API_KEY")
MISTRAL_API_KEY=$(get_secret "Mistral_AI_KEY")
PINECONE_API_KEY=$(get_secret "PINECONE_API_KEY")

push_secret "OPENAI_API_KEY" "$OPENAI_API_KEY" || true
push_secret "MISTRAL_API_KEY" "$MISTRAL_API_KEY" || true
push_secret "PINECONE_API_KEY" "$PINECONE_API_KEY" || true

echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}✓ Secret sync complete!${NC}"
echo ""
echo "To view all secrets:"
echo "  npx wrangler secret list"
echo ""
echo "To add a secret manually:"
echo "  npx wrangler secret put SECRET_NAME"
echo ""
