# Getting Started with Terraform Infrastructure Container

This guide will help you set up and use the Terraform Infrastructure Container for the first time.

## What Is This?

A **portable, self-contained development environment** for managing multi-cloud infrastructure with Terraform, built on Cloudflare Workers. No Docker required!

## Why No Docker?

Traditional containerization requires:
- Docker Desktop installation
- Running daemon process
- Managing images and volumes
- Platform-specific configurations

Instead, we use **Cloudflare Workers (Workerd)**:
- V8 isolates (faster than containers)
- No daemon needed
- Same code runs locally and in production
- Cross-platform without virtualization

## Prerequisites

### Required
- **Node.js 18+** - [Download](https://nodejs.org/)
- **Cloudflare account** - [Sign up](https://dash.cloudflare.com/sign-up) (free tier available)

### Optional
- **Terraform CLI** - [Download](https://www.terraform.io/downloads) (for infrastructure changes)
- **Git** - [Download](https://git-scm.com/downloads) (for version control)

## Installation

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd terraform-infrastructure-container
```

### 2. Run the Setup Script

```bash
./scripts/init.sh
```

This will:
- Check Node.js version
- Install dependencies
- Verify Terraform CLI (optional)
- Set up Wrangler
- Initialize Terraform (if .tf files exist)

### 3. Manual Setup (Alternative)

If you prefer manual setup:

```bash
# Install dependencies
npm install

# Login to Cloudflare
npx wrangler login

# Initialize Terraform (optional)
cd terraform
terraform init
cd ..
```

## First Run

### Start Local Development Server

```bash
npm run dev
```

Visit http://localhost:8787 to see your Worker running!

### Test the API

```bash
# Health check
curl http://localhost:8787/

# Project information
curl http://localhost:8787/api/info

# Infrastructure resources
curl http://localhost:8787/api/terraform/resources
```

## Configuration

### Update Wrangler Configuration

Edit `wrangler.toml`:

```toml
# Add your Cloudflare account ID
account_id = "your-account-id-here"
```

Find your account ID at: https://dash.cloudflare.com/

### Set Up Secrets

For sensitive values, use Wrangler secrets:

```bash
# Cloudflare API Token
npx wrangler secret put CLOUDFLARE_API_TOKEN

# Auth0 credentials
npx wrangler secret put AUTH0_CLIENT_ID
npx wrangler secret put AUTH0_CLIENT_SECRET
npx wrangler secret put AUTH0_DOMAIN

# Azure credentials (if managing Azure)
npx wrangler secret put AZURE_CLIENT_ID
npx wrangler secret put AZURE_CLIENT_SECRET
npx wrangler secret put AZURE_TENANT_ID
```

### Configure Cloudflare Resources

#### KV Namespaces (for state storage)

```bash
# Create KV namespace
npx wrangler kv:namespace create TERRAFORM_STATE

# Add to wrangler.toml
[[kv_namespaces]]
binding = "TERRAFORM_STATE"
id = "your-namespace-id"
```

#### R2 Buckets (for artifacts)

```bash
# Create R2 bucket
npx wrangler r2 bucket create terraform-artifacts

# Add to wrangler.toml
[[r2_buckets]]
binding = "TERRAFORM_ARTIFACTS"
bucket_name = "terraform-artifacts"
```

#### D1 Database (for deployment tracking)

```bash
# Create D1 database
npx wrangler d1 create terraform-deployments

# Add to wrangler.toml
[[d1_databases]]
binding = "DEPLOYMENT_DB"
database_name = "terraform-deployments"
database_id = "your-database-id"
```

## Deploy to Cloudflare

### Development Deployment

```bash
npm run deploy
```

Your Worker will be available at:
`https://terraform-infrastructure-container.<your-subdomain>.workers.dev`

### Production Deployment

```bash
npm run deploy -- --env production
```

### Custom Domain (Optional)

Add to `wrangler.toml`:

```toml
[env.production]
routes = [
  { pattern = "terraform.yourdomain.com", custom_domain = true }
]
```

## Using Terraform

### Initialize Terraform

```bash
cd terraform
terraform init
```

### Add Your Terraform Files

Copy your existing Terraform files to the `terraform/` directory:

```bash
cp /path/to/your/*.tf terraform/
```

### Plan Infrastructure Changes

```bash
cd terraform
terraform plan
```

### Apply Changes

```bash
terraform apply
```

## Project Structure

```
terraform-infrastructure-container/
├── src/                    # Worker source code
│   └── index.ts           # Main entry point
├── terraform/             # Terraform configurations
│   ├── *.tf              # Your infrastructure files
│   └── .terraform/       # Terraform state (gitignored)
├── docs/                  # Documentation
│   └── GETTING-STARTED.md # This file
├── scripts/               # Automation scripts
│   └── init.sh           # Setup script
├── wrangler.toml         # Worker configuration
├── package.json          # Dependencies
├── CLAUDE.md             # AI context
└── README.md             # Overview
```

## Next Steps

### 1. Add Your Infrastructure

Copy your existing Terraform files to `terraform/`:

```bash
cp /path/to/main.tf terraform/
cp /path/to/providers.tf terraform/
# etc.
```

### 2. Configure Providers

Update provider configurations in `terraform/providers.tf`:

```hcl
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}
```

### 3. Test Locally

```bash
# Start Worker
npm run dev

# In another terminal, test Terraform
cd terraform
terraform plan
```

### 4. Deploy

```bash
# Deploy Worker to Cloudflare
npm run deploy

# Apply Terraform changes
cd terraform
terraform apply
```

## Troubleshooting

### Node.js version error

```
Error: Node.js 18 or higher required
```

**Solution**: Install Node.js 18+ from https://nodejs.org/

### Wrangler login issues

```
Error: Not logged in to Cloudflare
```

**Solution**:
```bash
npx wrangler login
```

### Terraform not found

```
Warning: Terraform CLI not found
```

**Solution**: Install from https://www.terraform.io/downloads (optional, only needed for infrastructure changes)

### Permission denied on scripts

```
Permission denied: ./scripts/init.sh
```

**Solution**:
```bash
chmod +x scripts/init.sh
```

## Getting Help

- **Documentation**: See `README.md` and `CLAUDE.md`
- **Cloudflare Docs**: https://developers.cloudflare.com/workers/
- **Terraform Docs**: https://www.terraform.io/docs
- **Email**: joe@theholetruth.org

## What's Next?

- Explore the [API endpoints](../README.md#api-endpoints)
- Learn about [Terraform operations](../README.md#terraform-operations-planned)
- Set up [CI/CD with GitHub Actions](../.github/workflows/)
- Configure [custom domains](../README.md#custom-domain-optional)

---

**Welcome to Docker-free containerization!** 🎉
