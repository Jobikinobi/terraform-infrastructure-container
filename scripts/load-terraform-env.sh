#!/bin/bash
# Load Terraform environment variables from Cloudflare Worker secrets
# Usage: source ./scripts/load-terraform-env.sh

echo "Loading Terraform environment variables from Cloudflare Worker secrets..."

# Note: wrangler secret get doesn't exist, so we need to set these manually
# Or use a .env file locally

# For now, let's just document what needs to be set
cat <<'EOF'

To use Terraform with the secrets stored in Cloudflare Worker, you need to either:

Option 1: Use terraform.auto.tfvars file (created in terraform/ directory)
   - Edit terraform/terraform.auto.tfvars
   - Replace placeholder values with actual secrets
   - Run: terraform plan

Option 2: Set environment variables (recommended for security)
   export TF_VAR_cloudflare_api_token="your_cloudflare_token"
   export TF_VAR_auth0_client_id="F1JxAFyBNZBnXbmXz6Vh64VHF9KP97dn"
   export TF_VAR_auth0_client_secret="your_auth0_secret"
   export TF_VAR_auth0_domain="dev-4fszoklachwdh46m.us.auth0.com"
   export TF_VAR_cloudflare_account_id="1a25a792e801e687b9fe4932030cf6a6"

   # Azure (if not using Azure CLI)
   export TF_VAR_azure_client_id="b43fd258-79da-4fdd-95c8-10c62eeab311"
   export TF_VAR_azure_client_secret="your_azure_secret"
   export TF_VAR_azure_tenant_id="c9bc2130-ec1b-4d0b-89c3-4ff196000140"

Option 3: Use Azure CLI authentication (easiest for Azure)
   - You're already logged in via: az login
   - Terraform will automatically use your Azure CLI credentials
   - No need to set AZURE_* environment variables

The secrets are safely stored in Cloudflare and available to your Worker!
They're just not easily retrievable for local Terraform use.

EOF
