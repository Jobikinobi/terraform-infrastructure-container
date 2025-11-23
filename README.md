# Terraform Infrastructure Container

> Portable, self-contained multi-cloud infrastructure management with Cloudflare Workers - **No Docker required!**

## Overview

This project is a containerized Terraform environment built on Cloudflare Workers that manages infrastructure across Azure, Cloudflare, and Auth0. Unlike traditional container approaches, this uses Cloudflare's Workerd runtime (V8 isolates) instead of Docker, providing:

- **No Docker daemon** - runs locally with `npx wrangler dev`
- **Portable** - clone and run on any machine
- **Edge-ready** - deploys to Cloudflare's global network
- **GitHub-synced** - version controlled and shareable
- **Self-contained** - includes all configs, docs, and context

## Architecture

```
┌────────────────────────────────────────────────┐
│  Cloudflare Worker (Workerd Runtime)          │
│  ┌──────────────────────────────────────────┐ │
│  │  Hono API (TypeScript)                   │ │
│  │  - Health checks                         │ │
│  │  - Terraform operations                  │ │
│  │  - Resource inventory                    │ │
│  │  - Deployment tracking                   │ │
│  └──────────────────────────────────────────┘ │
│                     ↕                          │
│  ┌──────────────────────────────────────────┐ │
│  │  Cloudflare Resources                    │ │
│  │  - KV: State & Config                    │ │
│  │  - R2: Artifacts & Backups               │ │
│  │  - D1: Deployment Database               │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
                     ↓
        Managed Infrastructure
    (Azure • Cloudflare • Auth0)
```

## Quick Start

### Prerequisites

- Node.js 18+ (no Docker!)
- A Cloudflare account
- Terraform CLI (for actual infrastructure changes)

### Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd terraform-infrastructure-container

# Install dependencies
npm install

# Start local development server (no Docker!)
npm run dev

# Visit http://localhost:8787
```

### First Run

```bash
# Check the health endpoint
curl http://localhost:8787/

# Get project information
curl http://localhost:8787/api/info

# View infrastructure resources
curl http://localhost:8787/api/terraform/resources
```

## Infrastructure Managed

This container manages infrastructure across:

### Azure (4 Subscriptions)
- **Main**: Primary Azure resources
- **General Services**: Entra Domain Services, shared infrastructure
- **MUA**: Multi-user access resources
- **Plan**: Billing and plan-specific resources

### Cloudflare
- DNS zones: `theholetruth.org`, `theholefoundation.org`
- R2 storage buckets
- Workers & Pages projects
- D1 serverless databases
- KV namespaces
- WAF and security rules

### Auth0
- Domain: `dev-4fszoklachwdh46m.us.auth0.com`
- Custom domain: `auth.theholetruth.org`
- SPA applications for web properties
- Organization management
- RBAC configuration

## Project Structure

```
terraform-infrastructure-container/
├── src/
│   ├── index.ts              # Main Worker entry point (Hono API)
│   └── terraform-api.ts      # Terraform operation handlers (TODO)
├── terraform/
│   ├── main.tf               # Main infrastructure config
│   ├── providers.tf          # Provider configurations
│   ├── cloudflare.tf         # Cloudflare resources
│   ├── auth0-applications.tf # Auth0 clients
│   └── ...                   # Other .tf files
├── docs/
│   ├── SETUP.md              # Detailed setup guide
│   ├── CLOUDFLARE.md         # Cloudflare documentation
│   └── AUTH0.md              # Auth0 integration guide
├── scripts/
│   ├── init.sh               # Initialization script
│   └── sync.sh               # Sync script for GitHub
├── .github/
│   └── workflows/
│       └── deploy.yml        # CI/CD workflow
├── wrangler.toml             # Cloudflare Workers config
├── package.json              # Dependencies
├── CLAUDE.md                 # AI assistant context
└── README.md                 # This file
```

## Available Commands

```bash
# Development
npm run dev              # Start local dev server (no Docker!)
npm run deploy           # Deploy to Cloudflare Workers
npm run tail             # Stream Worker logs

# Terraform (from terraform/ directory)
cd terraform
terraform init           # Initialize providers
terraform plan           # Preview changes
terraform apply          # Apply changes
terraform destroy        # Destroy resources

# Testing
npm test                 # Run tests with Vitest
```

## API Endpoints

### Health & Info
- `GET /` - Health check
- `GET /api/info` - Project information

### Terraform Operations (Planned)
- `GET /api/terraform/state` - View Terraform state
- `GET /api/terraform/resources` - List managed resources
- `POST /api/terraform/plan` - Run terraform plan
- `POST /api/terraform/apply` - Apply changes (authenticated)

### Deployment Tracking (Planned)
- `GET /api/deployments` - Deployment history
- `POST /api/artifacts/upload` - Upload artifacts to R2

## Configuration

### Environment Variables

Set in `wrangler.toml`:

```toml
[vars]
ENVIRONMENT = "development"
PROJECT_NAME = "HOLE Foundation Infrastructure"
MANAGED_BY = "terraform"
```

### Secrets

Set via Wrangler CLI (never commit to git!):

```bash
# Cloudflare
wrangler secret put CLOUDFLARE_API_TOKEN

# Auth0
wrangler secret put AUTH0_CLIENT_ID
wrangler secret put AUTH0_CLIENT_SECRET
wrangler secret put AUTH0_DOMAIN

# Azure
wrangler secret put AZURE_CLIENT_ID
wrangler secret put AZURE_CLIENT_SECRET
wrangler secret put AZURE_TENANT_ID
```

### Cloudflare Resources

Configure in `wrangler.toml`:

```toml
# KV Namespaces for state storage
[[kv_namespaces]]
binding = "TERRAFORM_STATE"
id = "your-kv-namespace-id"

# R2 Buckets for artifacts
[[r2_buckets]]
binding = "TERRAFORM_ARTIFACTS"
bucket_name = "terraform-artifacts"

# D1 Database for deployment tracking
[[d1_databases]]
binding = "DEPLOYMENT_DB"
database_name = "terraform-deployments"
database_id = "your-d1-database-id"
```

## Deployment

### Local Testing

```bash
# Start local development server
npm run dev

# Visit http://localhost:8787
# API is now available for testing
```

### Deploy to Cloudflare

```bash
# Deploy to development environment
npm run deploy

# Deploy to production
npm run deploy -- --env production

# Stream logs from deployed Worker
npm run tail
```

### Custom Domain (Optional)

Add to `wrangler.toml`:

```toml
[env.production]
routes = [
  { pattern = "terraform.theholetruth.org", custom_domain = true }
]
```

## Terraform MCP Server (Optional)

For AI-assisted Terraform development, install the HashiCorp MCP server:

```json
{
  "mcp": {
    "servers": {
      "terraform": {
        "command": "docker",
        "args": [
          "run", "-i", "--rm",
          "hashicorp/terraform-mcp-server:0.3.3"
        ]
      }
    }
  }
}
```

**Note**: The MCP server runs separately (locally) to assist AI tools like Claude. It's not deployed with the Worker.

## Why No Docker?

Traditional containerization uses Docker, which requires:
- Installing Docker Desktop
- Running a daemon process
- Managing images and volumes
- Platform-specific configurations

This project uses **Cloudflare Workers (Workerd)** instead:
- V8 isolates (much faster than containers)
- No daemon required
- Runs the same locally and in production
- Cross-platform without virtualization
- Sponsored by Cloudflare (free tier!)

## Development Philosophy

This is part of a larger initiative to:

1. **Modularize projects** - Each project as a self-contained container
2. **Standardize structure** - Consistent approach across all work
3. **Eliminate Docker dependency** - Use Cloudflare Workers instead
4. **Enable portability** - Clone and run anywhere
5. **Version control environments** - Not just code, but entire setups

## Security Best Practices

- Never commit secrets to Git
- Use Wrangler secrets for sensitive values
- Rotate credentials regularly
- Implement proper authentication for destructive operations
- Use least-privilege access for service accounts
- Enable audit logging for all changes

## Contributing

This is an experimental project in early development. The goal is to establish a standard for all HOLE Foundation projects.

### Current Status

**Phase**: Proof of Concept
**Focus**: Defining containerization standard
**Next**: Implement full Terraform operations via Worker API

## Source Repository

Original Terraform configuration:
```
/Volumes/.../Projects/azure-terraform-infrastructure
```

This container project is experimental and separate until fully validated.

## Support

- **Email**: joe@theholetruth.org
- **Organization**: HOLE Foundation
- **Cloudflare Account**: 1a25a792e801e687b9fe4932030cf6a6

## License

MIT License - Copyright (c) 2024 HOLE Foundation

---

**Built with Cloudflare Workers** - No Docker required!
