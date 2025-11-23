#!/bin/bash

# Terraform Infrastructure Container - Initialization Script
# Sets up the development environment for portable Terraform management
# No Docker required!

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Terraform Infrastructure Container - Setup                ║"
echo "║  Portable multi-cloud infrastructure management            ║"
echo "║  No Docker required!                                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check Node.js version
echo "📦 Checking Node.js version..."
NODE_VERSION=$(node -v)
echo "   Node.js version: $NODE_VERSION"

# Verify minimum version (18+)
NODE_MAJOR=$(node -v | cut -d'.' -f1 | sed 's/v//')
if [ "$NODE_MAJOR" -lt 18 ]; then
    echo "❌ Error: Node.js 18 or higher required"
    echo "   Current version: $NODE_VERSION"
    exit 1
fi
echo "   ✅ Node.js version is compatible"
echo ""

# Install dependencies
echo "📥 Installing dependencies..."
npm install
echo "   ✅ Dependencies installed"
echo ""

# Check for Terraform CLI (optional but recommended)
echo "🔍 Checking for Terraform CLI..."
if command -v terraform &> /dev/null; then
    TERRAFORM_VERSION=$(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)
    echo "   ✅ Terraform CLI found: v$TERRAFORM_VERSION"
else
    echo "   ⚠️  Terraform CLI not found (optional)"
    echo "      To manage infrastructure, install from: https://www.terraform.io/downloads"
fi
echo ""

# Check for Wrangler
echo "🔍 Checking for Wrangler..."
if npx wrangler --version &> /dev/null; then
    echo "   ✅ Wrangler is available"
else
    echo "   ❌ Wrangler not available"
    exit 1
fi
echo ""

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p terraform
mkdir -p docs
mkdir -p scripts
echo "   ✅ Directories created"
echo ""

# Check for Cloudflare authentication
echo "🔐 Checking Cloudflare authentication..."
if [ -f ".wrangler/auth.json" ] || [ ! -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "   ✅ Cloudflare authentication configured"
else
    echo "   ⚠️  Cloudflare authentication not found"
    echo "      Run: npx wrangler login"
    echo "      Or set CLOUDFLARE_API_TOKEN environment variable"
fi
echo ""

# Initialize Terraform (if directory exists with .tf files)
if [ -d "terraform" ] && [ "$(ls -A terraform/*.tf 2>/dev/null)" ]; then
    echo "🏗️  Initializing Terraform..."
    cd terraform
    terraform init -upgrade
    cd ..
    echo "   ✅ Terraform initialized"
else
    echo "   ℹ️  No Terraform files found yet"
fi
echo ""

# Generate Wrangler types
echo "📝 Generating TypeScript types..."
npx wrangler types || echo "   ⚠️  Could not generate types (Worker may not be deployed yet)"
echo ""

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  Setup Complete! 🎉                                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Start local development:"
echo "     npm run dev"
echo ""
echo "  2. Visit your Worker:"
echo "     http://localhost:8787"
echo ""
echo "  3. Deploy to Cloudflare:"
echo "     npm run deploy"
echo ""
echo "  4. Configure secrets (if needed):"
echo "     npx wrangler secret put CLOUDFLARE_API_TOKEN"
echo "     npx wrangler secret put AUTH0_CLIENT_ID"
echo "     npx wrangler secret put AUTH0_CLIENT_SECRET"
echo ""
echo "For more information, see README.md"
echo ""
