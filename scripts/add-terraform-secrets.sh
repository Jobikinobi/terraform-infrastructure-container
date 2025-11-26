#!/bin/bash
# Add Terraform-specific secrets to Cloudflare Worker
# This script will prompt you for Auth0 and Cloudflare credentials

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Add Terraform Secrets to Cloudflare Worker               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}This script will help you add the remaining secrets needed for Terraform.${NC}"
echo ""

# Auth0 Credentials
echo "═══════════════════════════════════════════════════════════"
echo -e "${YELLOW}Auth0 Credentials${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Found your Auth0 Terraform-Management M2M application:"
echo -e "  ${GREEN}Client ID: F1JxAFyBNZBnXbmXz6Vh64VHF9KP97dn${NC}"
echo -e "  ${GREEN}Domain: dev-4fszoklachwdh46m.us.auth0.com${NC}"
echo ""
echo "To get the Client Secret:"
echo "  1. Open: https://manage.auth0.com/dashboard/us/dev-4fszoklachwdh46m/"
echo "  2. Go to: Applications → Terraform-Management"
echo "  3. Click 'Settings' tab"
echo "  4. Find 'Client Secret' and click 'Show'"
echo ""
read -p "Press ENTER when you have the Client Secret ready..."
echo ""

echo -e "${BLUE}→ Adding AUTH0_CLIENT_ID...${NC}"
echo "F1JxAFyBNZBnXbmXz6Vh64VHF9KP97dn" | npx wrangler secret put AUTH0_CLIENT_ID
echo -e "${GREEN}✓ AUTH0_CLIENT_ID added${NC}"
echo ""

echo -e "${BLUE}→ Adding AUTH0_CLIENT_SECRET...${NC}"
echo "Paste the Client Secret when prompted:"
npx wrangler secret put AUTH0_CLIENT_SECRET
echo -e "${GREEN}✓ AUTH0_CLIENT_SECRET added${NC}"
echo ""

echo -e "${BLUE}→ Adding AUTH0_DOMAIN...${NC}"
echo "dev-4fszoklachwdh46m.us.auth0.com" | npx wrangler secret put AUTH0_DOMAIN
echo -e "${GREEN}✓ AUTH0_DOMAIN added${NC}"
echo ""

# Cloudflare API Token
echo "═══════════════════════════════════════════════════════════"
echo -e "${YELLOW}Cloudflare API Token${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "You need to create a Cloudflare API Token (not the Global API Key)."
echo ""
echo "Steps:"
echo "  1. Open: https://dash.cloudflare.com/profile/api-tokens"
echo "  2. Click 'Create Token'"
echo "  3. Use template: 'Edit Cloudflare Workers' OR create custom with:"
echo "     - Account → Workers Scripts → Edit"
echo "     - Account → Workers KV Storage → Edit"
echo "     - Account → Workers R2 Storage → Edit"
echo "     - Zone → DNS → Edit"
echo "     - Zone → Zone → Read"
echo "  4. Click 'Continue to summary' → 'Create Token'"
echo "  5. Copy the token (shown only once!)"
echo ""
read -p "Press ENTER when you have the API Token ready..."
echo ""

echo -e "${BLUE}→ Adding CLOUDFLARE_API_TOKEN...${NC}"
echo "Paste the API Token when prompted:"
npx wrangler secret put CLOUDFLARE_API_TOKEN
echo -e "${GREEN}✓ CLOUDFLARE_API_TOKEN added${NC}"
echo ""

# Azure Secrets (optional - may already be set via Azure CLI)
echo "═══════════════════════════════════════════════════════════"
echo -e "${YELLOW}Azure Credentials (Optional)${NC}"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Azure authentication can work via:"
echo "  - Azure CLI (az login) - currently authenticated"
echo "  - Service Principal credentials"
echo ""
read -p "Do you want to add Azure Service Principal credentials? (y/N): " add_azure

if [[ $add_azure =~ ^[Yy]$ ]]; then
    echo ""
    echo "You'll need Azure Service Principal credentials."
    echo "If you don't have them, you can create one with:"
    echo "  az ad sp create-for-rbac --name terraform-sp"
    echo ""

    echo -e "${BLUE}→ Adding AZURE_CLIENT_ID...${NC}"
    npx wrangler secret put AZURE_CLIENT_ID
    echo -e "${GREEN}✓ AZURE_CLIENT_ID added${NC}"
    echo ""

    echo -e "${BLUE}→ Adding AZURE_CLIENT_SECRET...${NC}"
    npx wrangler secret put AZURE_CLIENT_SECRET
    echo -e "${GREEN}✓ AZURE_CLIENT_SECRET added${NC}"
    echo ""

    echo -e "${BLUE}→ Adding AZURE_TENANT_ID...${NC}"
    npx wrangler secret put AZURE_TENANT_ID
    echo -e "${GREEN}✓ AZURE_TENANT_ID added${NC}"
    echo ""
else
    echo -e "${YELLOW}⊘ Skipping Azure credentials - will use Azure CLI authentication${NC}"
    echo ""
fi

echo "═══════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}✓ Secret setup complete!${NC}"
echo ""
echo "To verify all secrets:"
echo "  npx wrangler secret list"
echo ""
echo "To test Terraform with new credentials:"
echo "  cd terraform"
echo "  terraform plan"
echo ""
