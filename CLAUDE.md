# Terraform Infrastructure Container - AI Context

## Project Overview

This is a **portable, self-contained Cloudflare Worker environment** for managing multi-cloud infrastructure with Terraform. This project is part of a larger initiative to modularize and standardize development environments across all HOLE Foundation projects.

### Key Innovation: Docker-Free Containerization

Unlike traditional containerization approaches that rely on Docker, this project uses:
- **Cloudflare Workers (Workerd runtime)** - V8 isolates instead of containers
- **No Docker daemon required** - runs locally via `npx wrangler dev`
- **Edge deployment ready** - deploys to Cloudflare's global network
- **Portable across machines** - clone, install, run (no daemon setup)
- **GitHub-synced** - version controlled and shareable

## Architecture

```
Cloudflare Worker Container
├── Terraform Configurations (all .tf files)
├── Documentation (CLAUDE.md, setup guides, etc.)
├── Scripts (automation, import, deployment)
├── Worker API (TypeScript endpoints for infrastructure management)
└── Cloudflare Resources (KV, R2, D1 for state/artifacts)
```

## Current Infrastructure Managed

This container manages infrastructure across:

1. **Azure** (4 subscriptions)
   - Main subscription: Azure subscription 1
   - General Services: Entra Domain Services, shared infrastructure
   - MUA: Multi-user access
   - Plan: Billing and plan-specific resources

2. **Cloudflare**
   - DNS zones (theholetruth.org, theholefoundation.org)
   - R2 storage buckets
   - Workers & Pages
   - D1 databases
   - KV namespaces
   - Security & WAF

3. **Auth0**
   - Domain: dev-4fszoklachwdh46m.us.auth0.com
   - Custom domain: auth.theholetruth.org
   - Applications: SPAs for theholetruth.org and HOLE Foundation web apps
   - Organization management
   - RBAC and permissions

## Terraform Provider Configuration

### Active Providers
- `azurerm` v4.x - Azure Resource Manager (4 provider aliases)
- `cloudflare` v4.x - Cloudflare services
- `auth0` v1.x - Auth0 authentication platform

### Planned/Commented Providers
- `aws` v5.x - Amazon Web Services
- `google` v6.x - Google Cloud Platform
- `google-beta` v6.x - GCP beta features
- `github` v6.x - GitHub repository management

## Key Files & Structure

### Terraform Files (from main repo)
- `providers.tf` - All provider configurations
- `main.tf` - Main infrastructure definitions
- `variables.tf` - Variable declarations
- `outputs.tf` - Output definitions
- `backend.tf` - State backend configuration
- `cloudflare.tf` - Cloudflare resources
- `cloudflare-zones.tf` - DNS zone management
- `cloudflare-pages.tf` - Pages projects
- `cloudflare-r2.tf` - R2 storage buckets
- `cloudflare-workers-kv-d1.tf` - Workers KV and D1 databases
- `auth0-applications.tf` - Auth0 client applications

### Documentation Files
- `CLAUDE.md` - This file, AI assistant context
- `README.md` - Project setup and usage
- `CLOUDFLARE-COMPLETE.md` - Cloudflare setup documentation
- `AUTH0-TERRAFORM-SETUP.md` - Auth0 integration guide
- `MULTI-CLOUD-ARCHITECTURE.md` - Multi-cloud strategy

## Terraform MCP Server Integration

The HashiCorp Terraform MCP Server can be integrated with this project to provide:
- Real-time Terraform provider documentation
- Module registry access
- Workspace management for HCP Terraform
- AI-assisted configuration generation

### MCP Server Setup (Optional)
```json
{
  "mcp": {
    "servers": {
      "terraform": {
        "command": "docker",
        "args": [
          "run", "-i", "--rm",
          "-e", "TFE_TOKEN=${input:tfe_token}",
          "-e", "TFE_ADDRESS=${input:tfe_address}",
          "hashicorp/terraform-mcp-server:0.3.3"
        ]
      }
    }
  }
}
```

**Note**: MCP server runs separately (locally) to assist AI, not deployed with the Worker.

## Development Workflow

### Local Development (No Docker!)
```bash
# Install dependencies
npm install

# Start local development server
npm run dev

# Worker runs at http://localhost:8787
```

### Cloud Deployment
```bash
# Deploy to Cloudflare Workers
npm run deploy

# Deploy to specific environment
npm run deploy -- --env production
```

### Terraform Operations
```bash
# Initialize Terraform
cd terraform && terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply
```

## Project Goals & Vision

### Immediate Goals
1. Create portable, self-contained development environments
2. Eliminate Docker dependency for containerization
3. Standardize project structure across all HOLE Foundation projects
4. Enable easy transfer between machines and environments

### Long-term Vision
1. **Modular Project System**: Each project as a self-contained container
2. **Standardized Protocol**: Consistent structure across all projects
3. **GitHub Sync**: Version control for entire environments
4. **Machine Independence**: Clone and run on any machine
5. **Cloudflare-Native**: Leverage Cloudflare sponsorship benefits

## Security & Secrets Management

### Environment Variables (wrangler.toml [vars])
- `ENVIRONMENT` - Current environment (development/production)
- `PROJECT_NAME` - HOLE Foundation Infrastructure
- `MANAGED_BY` - terraform

### Secrets (via `wrangler secret put`)
- `CLOUDFLARE_API_TOKEN` - Cloudflare API access
- `AUTH0_CLIENT_ID` - Auth0 M2M application
- `AUTH0_CLIENT_SECRET` - Auth0 credentials
- `AUTH0_DOMAIN` - Auth0 tenant domain
- `AZURE_CLIENT_ID` - Azure service principal
- `AZURE_CLIENT_SECRET` - Azure credentials
- `AZURE_TENANT_ID` - Azure AD tenant

### Best Practices
- Never commit secrets to git
- Use Wrangler secrets for sensitive values
- Use environment variables for non-sensitive config
- Rotate credentials regularly

## Cloudflare Resources Used

### KV Namespaces (Planned)
- `TERRAFORM_STATE` - Terraform state storage
- `TERRAFORM_CONFIG` - Configuration cache

### R2 Buckets (Planned)
- `TERRAFORM_ARTIFACTS` - Large files, backups, artifacts

### D1 Databases (Planned)
- `DEPLOYMENT_DB` - Deployment tracking and metadata

### Workers
- Main worker: Terraform management API
- Routes: Custom domains for production

## AI Assistant Guidelines

When working with this project:

1. **No Docker**: Never suggest Docker commands - use Wrangler instead
2. **Portable First**: Ensure changes maintain portability
3. **Cloudflare Native**: Prefer Cloudflare services over alternatives
4. **Documentation**: Keep CLAUDE.md updated with changes
5. **Security**: Never expose secrets, use Wrangler secrets
6. **Terraform Best Practices**: Follow IaC principles
7. **Multi-cloud Aware**: Remember we manage Azure, Cloudflare, and Auth0

## Source Repository

Original Terraform configuration:
`/Volumes/80F9F6D9-7BEF-4B9D-BE79-A7E2F900F1ED/Library/Daemon Containers/85C492CA-B246-4619-9E1D-E222C06C5FC9/Data/Library/Mobile Documents/com~apple~CloudDocs/Projects/azure-terraform-infrastructure`

This container project is experimental and separate from the main repo until the containerization system is fully validated.

## Contact

- **Project Owner**: joe@theholetruth.org
- **Organization**: HOLE Foundation
- **Cloudflare Account**: 1a25a792e801e687b9fe4932030cf6a6

## Status

**Phase**: Early Development / Proof of Concept
**Goal**: Define containerization standard for all projects
**Current Focus**: Building initial structure and workflow
