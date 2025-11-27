# HOLE Foundation Infrastructure-as-a-Service (IaaS)

## 🎯 Vision

Transform the Terraform Infrastructure Container into a **centralized infrastructure service** that ALL HOLE Foundation projects can consume via API, eliminating the need to duplicate infrastructure setup in each project.

---

## 🏗️ Architecture Model

### **Traditional Approach (What We're Avoiding):**
```
Every project has:
├── Duplicate Auth0 configuration
├── Duplicate database setup
├── Duplicate Terraform configs
├── Duplicate secret management
└── Maintenance nightmare
```

### **Infrastructure-as-a-Service Approach:**
```
┌─────────────────────────────────────────────────────┐
│  Centralized Infrastructure Service                 │
│  (terraform-infrastructure-container)               │
│  ┌────────────────────────────────────────────────┐ │
│  │ Single Source of Truth                         │ │
│  │ - Auth0: All clients configured                │ │
│  │ - Azure: $3000+ credits, all resources         │ │
│  │ - AWS: $3000+ credits, all resources           │ │
│  │ - Cloudflare: All zones, workers, storage     │ │
│  │ - Neon: All databases                          │ │
│  │ - GitHub: All 38 repos                         │ │
│  └────────────────────────────────────────────────┘ │
│                                                      │
│  ┌────────────────────────────────────────────────┐ │
│  │ Service API                                    │ │
│  │ GET /api/auth0/config/:project                │ │
│  │ POST /api/database/provision                   │ │
│  │ GET /api/cloudflare/resources/:project        │ │
│  │ POST /api/azure/provision                      │ │
│  │ POST /api/aws/provision                        │ │
│  └────────────────────────────────────────────────┘ │
└──────────────────────┬───────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ↓              ↓              ↓
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ theholetruth │ │ MIPDS        │ │ Legal RAG    │
│ .org-v2      │ │ Project      │ │ System       │
│              │ │              │ │              │
│ Just calls   │ │ Just calls   │ │ Just calls   │
│ the API!     │ │ the API!     │ │ the API!     │
└──────────────┘ └──────────────┘ └──────────────┘
```

---

## 🌐 Complete Service Catalog

### **1. Authentication Service (Auth0)**

**What Projects Get:**
```javascript
GET /api/auth0/config/theholetruth-org
{
  "domain": "dev-4fszoklachwdh46m.us.auth0.com",
  "customDomain": "auth.theholetruth.org",
  "clientId": "96qWGonLhLBlMcQZzM8NXnJGJxV5WlEV",
  "audience": "https://api.theholetruth.org",
  "scopes": ["openid", "profile", "email"],
  "callbacks": ["https://theholetruth.org/callback"],
  "logoutUrls": ["https://theholetruth.org"]
}
```

**Usage in Project:**
```typescript
// theholetruth.org-v2/lib/auth.ts
const auth0Config = await fetch('https://infra.../api/auth0/config/theholetruth-org').then(r => r.json());

export const auth0 = new Auth0Client(auth0Config);
// Done! No hardcoded config needed.
```

---

### **2. Database Service (Neon PostgreSQL + Azure SQL)**

**Provision New Database:**
```javascript
POST /api/database/provision
{
  "project": "theholetruth-org-v2",
  "type": "postgres",
  "provider": "neon",  // or "azure"
  "region": "us-east-1",
  "plan": "free"  // Use AWS/Azure credits
}

Response:
{
  "database_id": "neon-db-123",
  "connection_url": "postgresql://user:pass@host/db",
  "connection_pooled": "postgresql://...",
  "region": "us-east-1",
  "provisioned_at": "2025-11-27T...",
  "provider": "neon",
  "cost": "$0 (credits applied)"
}
```

**Get Existing Database:**
```javascript
GET /api/database/connection/theholetruth-org-v2
{
  "connection_url": "postgresql://...",
  "status": "active",
  "tables": 15,
  "size_mb": 245
}
```

---

### **3. Storage Service (Cloudflare R2 + Azure Blob + AWS S3)**

**Provision Storage:**
```javascript
POST /api/storage/provision
{
  "project": "theholetruth-org-v2",
  "type": "r2",  // or "azure-blob", "s3"
  "purpose": "user-uploads",
  "public": false
}

Response:
{
  "bucket_name": "theholetruth-uploads",
  "endpoint": "https://...",
  "access_key": "...",  // Returned via secure endpoint
  "region": "auto",
  "provider": "cloudflare-r2",
  "cost": "$0 (sponsored)"
}
```

---

### **4. Compute Service (Cloudflare Workers + Azure Container Apps + AWS Lambda)**

**Deploy Worker:**
```javascript
POST /api/compute/deploy
{
  "project": "theholetruth-org-v2",
  "type": "worker",
  "code_url": "https://github.com/Jobikinobi/theholetruth.org/archive/main.zip",
  "environment": "production"
}

Response:
{
  "worker_url": "https://theholetruth-org-v2.joe-1a2.workers.dev",
  "deployment_id": "deploy-123",
  "status": "deployed"
}
```

---

### **5. DNS Service (Cloudflare)**

**Get DNS Config:**
```javascript
GET /api/dns/config/theholetruth.org
{
  "zone_id": "...",
  "nameservers": ["ns1.cloudflare.com", "ns2.cloudflare.com"],
  "records": [
    { "type": "A", "name": "@", "value": "..." },
    { "type": "CNAME", "name": "www", "value": "..." }
  ]
}
```

---

### **6. Secrets Service**

**Get Secrets for Project:**
```javascript
GET /api/secrets/theholetruth-org-v2
{
  "auth0_client_secret": "*** (from Cloudflare Worker secrets)",
  "database_password": "*** (from Cloudflare Worker secrets)",
  "api_keys": {
    "stripe": "*** (from Cloudflare Worker secrets)",
    "sendgrid": "***"
  }
}
```

---

## 💰 Credit Utilization Strategy

### **Azure Credits ($3000+)**

**Use For:**
- Azure Container Apps (full apps)
- Azure SQL Database (when Postgres not enough)
- Azure Blob Storage (large file storage)
- Azure Functions (serverless compute)
- Azure Cognitive Services (AI/ML)

**Provisioning:**
```javascript
POST /api/azure/provision
{
  "project": "mipds",
  "resource": "container-app",
  "spec": {
    "cpu": 1.0,
    "memory": "2Gi",
    "replicas": {
      "min": 0,
      "max": 10
    }
  }
}
```

### **AWS Credits ($3000+)**

**Use For:**
- AWS Lambda (serverless functions)
- S3 (object storage)
- DynamoDB (NoSQL database)
- SQS/SNS (messaging)
- Bedrock (AI models)

**Provisioning:**
```javascript
POST /api/aws/provision
{
  "project": "legal-rag-system",
  "resource": "lambda",
  "spec": {
    "runtime": "nodejs20.x",
    "memory": 1024,
    "timeout": 30
  }
}
```

---

## 🔧 Required Terraform Additions

### **1. Enable AWS Provider**

```hcl
# terraform/providers.tf
terraform {
  required_providers {
    # ... existing ...

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  # Use credits
  default_tags {
    tags = {
      managed_by   = "terraform"
      organization = "HOLE Foundation"
      cost_center  = "credits"
    }
  }
}
```

### **2. Create Service Resource Modules**

```hcl
# terraform/modules/project-infrastructure/main.tf
module "project_infrastructure" {
  source = "./modules/project-infrastructure"

  for_each = var.projects

  project_name = each.key

  # Auth0
  create_auth0_client = each.value.needs_auth
  auth0_callbacks     = each.value.callback_urls

  # Database
  create_database = each.value.needs_database
  database_type   = each.value.database_type  // "neon", "azure-sql", "aws-rds"

  # Storage
  create_storage = each.value.needs_storage
  storage_type   = each.value.storage_type  // "r2", "azure-blob", "s3"

  # Compute
  create_compute = each.value.needs_compute
  compute_type   = each.value.compute_type  // "worker", "container-app", "lambda"
}
```

### **3. Project Configuration**

```hcl
# terraform/projects.tf (new)
variable "projects" {
  description = "All HOLE Foundation projects and their infrastructure needs"
  type = map(object({
    needs_auth      = bool
    needs_database  = bool
    needs_storage   = bool
    needs_compute   = bool
    callback_urls   = list(string)
    database_type   = string
    storage_type    = string
    compute_type    = string
  }))

  default = {
    "theholetruth-org-v2" = {
      needs_auth     = true
      needs_database = true
      needs_storage  = true
      needs_compute  = true
      callback_urls  = ["https://theholetruth.org/callback"]
      database_type  = "neon"
      storage_type   = "r2"
      compute_type   = "worker"
    }

    "mipds" = {
      needs_auth     = true
      needs_database = true
      needs_storage  = true
      needs_compute  = true
      callback_urls  = ["https://mipds.../callback"]
      database_type  = "azure-sql"  // Use Azure credits!
      storage_type   = "azure-blob"  // Use Azure credits!
      compute_type   = "container-app"  // Use Azure credits!
    }

    "legal-rag-system" = {
      needs_auth     = true
      needs_database = true
      needs_storage  = true
      needs_compute  = true
      callback_urls  = ["https://legal.../callback"]
      database_type  = "neon"
      storage_type   = "s3"  // Use AWS credits!
      compute_type   = "lambda"  // Use AWS credits!
    }
  }
}
```

---

## 🌐 Complete Service API Design

### **Service Discovery**

```typescript
GET /api/services
{
  "available_services": {
    "auth": {
      "provider": "auth0",
      "endpoints": {
        "get_config": "/api/auth0/config/:project",
        "list_clients": "/api/auth0/clients"
      }
    },
    "database": {
      "providers": ["neon", "azure-sql", "aws-rds"],
      "endpoints": {
        "provision": "/api/database/provision",
        "get_connection": "/api/database/connection/:project",
        "list_databases": "/api/database/list"
      }
    },
    "storage": {
      "providers": ["cloudflare-r2", "azure-blob", "aws-s3"],
      "endpoints": {
        "provision": "/api/storage/provision",
        "get_config": "/api/storage/config/:project"
      }
    },
    "compute": {
      "providers": ["cloudflare-workers", "azure-container-apps", "aws-lambda"],
      "endpoints": {
        "deploy": "/api/compute/deploy",
        "get_status": "/api/compute/status/:project"
      }
    },
    "dns": {
      "provider": "cloudflare",
      "endpoints": {
        "get_zone": "/api/dns/zone/:domain",
        "create_record": "/api/dns/record"
      }
    }
  },
  "credits": {
    "azure": "$3000+",
    "aws": "$3000+",
    "cloudflare": "sponsored"
  }
}
```

---

### **Project Provisioning**

```typescript
POST /api/projects/provision
{
  "name": "theholetruth-org-v2",
  "infrastructure": {
    "auth": {
      "provider": "auth0",
      "type": "spa",
      "callbacks": ["https://theholetruth.org/callback"],
      "allowed_origins": ["https://theholetruth.org"]
    },
    "database": {
      "provider": "neon",
      "name": "theholetruth_v2",
      "region": "us-east-1"
    },
    "storage": {
      "provider": "cloudflare-r2",
      "buckets": [
        { "name": "user-uploads", "public": false },
        { "name": "assets", "public": true }
      ]
    },
    "compute": {
      "provider": "cloudflare-workers",
      "workers": [
        { "name": "api", "routes": ["api.theholetruth.org/*"] },
        { "name": "web", "routes": ["theholetruth.org/*"] }
      ]
    },
    "dns": {
      "zone": "theholetruth.org",
      "records": [
        { "type": "A", "name": "@", "proxied": true },
        { "type": "CNAME", "name": "api", "value": "..." }
      ]
    }
  }
}

Response:
{
  "project_id": "proj-theholetruth-v2-001",
  "provisioned": {
    "auth0_client_id": "...",
    "database_url": "postgresql://...",
    "storage": {
      "uploads": "r2://theholetruth-uploads",
      "assets": "r2://theholetruth-assets"
    },
    "workers": {
      "api": "https://api.theholetruth.org",
      "web": "https://theholetruth.org"
    }
  },
  "terraform_applied": true,
  "total_cost": "$0 (credits)",
  "estimated_monthly": "$15 (after credits expire)"
}
```

---

## 📦 Client SDK for Projects

### **NPM Package: `@hole-foundation/infrastructure`**

```typescript
// Published to npm for easy use in all projects
import { HOLEInfrastructure } from '@hole-foundation/infrastructure';

const infra = new HOLEInfrastructure({
  apiUrl: 'https://terraform-infrastructure-container.joe-1a2.workers.dev'
});

// In theholetruth.org-v2
export async function getInfrastructureConfig() {
  const [auth, db, storage, dns] = await Promise.all([
    infra.auth.getConfig('theholetruth-org'),
    infra.database.getConnection('theholetruth-org-v2'),
    infra.storage.getConfig('theholetruth-org-v2'),
    infra.dns.getZone('theholetruth.org')
  ]);

  return { auth, db, storage, dns };
}
```

### **SDK Implementation:**

```typescript
// packages/infrastructure-client/src/index.ts

export class HOLEInfrastructure {
  constructor(private config: { apiUrl: string }) {}

  // Auth0 service
  auth = {
    getConfig: async (project: string) => {
      const res = await fetch(`${this.config.apiUrl}/api/auth0/config/${project}`);
      return res.json();
    },

    listClients: async () => {
      const res = await fetch(`${this.config.apiUrl}/api/auth0/clients`);
      return res.json();
    }
  };

  // Database service
  database = {
    provision: async (params: DatabaseProvisionParams) => {
      const res = await fetch(`${this.config.apiUrl}/api/database/provision`, {
        method: 'POST',
        body: JSON.stringify(params)
      });
      return res.json();
    },

    getConnection: async (project: string) => {
      const res = await fetch(`${this.config.apiUrl}/api/database/connection/${project}`);
      return res.json();
    },

    list: async () => {
      const res = await fetch(`${this.config.apiUrl}/api/database/list`);
      return res.json();
    }
  };

  // Storage service
  storage = {
    provision: async (params: StorageProvisionParams) => {
      const res = await fetch(`${this.config.apiUrl}/api/storage/provision`, {
        method: 'POST',
        body: JSON.stringify(params)
      });
      return res.json();
    },

    getConfig: async (project: string) => {
      const res = await fetch(`${this.config.apiUrl}/api/storage/config/${project}`);
      return res.json();
    }
  };

  // Cloudflare service
  cloudflare = {
    getResources: async (project: string) => {
      const res = await fetch(`${this.config.apiUrl}/api/cloudflare/resources/${project}`);
      return res.json();
    }
  };

  // DNS service
  dns = {
    getZone: async (domain: string) => {
      const res = await fetch(`${this.config.apiUrl}/api/dns/zone/${domain}`);
      return res.json();
    }
  };
}
```

---

## 🗄️ Extended D1 Schema for Project Management

```sql
-- Projects using this infrastructure service
CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT UNIQUE NOT NULL,
    project_name TEXT NOT NULL,
    display_name TEXT,
    description TEXT,
    github_repo TEXT,
    status TEXT CHECK(status IN ('active', 'archived', 'development')) DEFAULT 'development',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (github_repo) REFERENCES github_repositories(repo_full_name)
);

-- Infrastructure resources per project
CREATE TABLE IF NOT EXISTS project_resources (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT NOT NULL,
    resource_type TEXT CHECK(resource_type IN ('auth0', 'database', 'storage', 'compute', 'dns')) NOT NULL,
    resource_provider TEXT,  -- 'neon', 'azure', 'aws', 'cloudflare'
    resource_id TEXT NOT NULL,
    resource_name TEXT,
    config JSON,  -- Full configuration
    provisioned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status TEXT CHECK(status IN ('active', 'provisioning', 'failed', 'deprovisioned')) DEFAULT 'active',
    cost_monthly REAL DEFAULT 0,
    uses_credits BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

-- Project environments (dev, staging, prod)
CREATE TABLE IF NOT EXISTS project_environments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT NOT NULL,
    environment TEXT CHECK(environment IN ('development', 'staging', 'production')) NOT NULL,
    url TEXT,
    auth0_client_id TEXT,
    database_url TEXT,
    storage_config JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, environment),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

-- Credit usage tracking
CREATE TABLE IF NOT EXISTS credit_usage (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    provider TEXT CHECK(provider IN ('azure', 'aws', 'gcp')) NOT NULL,
    project_id TEXT,
    resource_type TEXT,
    amount_usd REAL NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_project_resources_project ON project_resources(project_id);
CREATE INDEX IF NOT EXISTS idx_project_resources_type ON project_resources(resource_type);
CREATE INDEX IF NOT EXISTS idx_credit_usage_provider ON credit_usage(provider);
CREATE INDEX IF NOT EXISTS idx_credit_usage_project ON credit_usage(project_id);
```

---

## 🎯 Usage Example: theholetruth.org-v2

### **Step 1: Install SDK in Project**

```bash
# In theholetruth.org-v2 directory
npm install @hole-foundation/infrastructure
```

### **Step 2: Configure Infrastructure**

```typescript
// theholetruth.org-v2/lib/infrastructure.ts
import { HOLEInfrastructure } from '@hole-foundation/infrastructure';

const infra = new HOLEInfrastructure({
  apiUrl: 'https://terraform-infrastructure-container.joe-1a2.workers.dev'
});

// Get all infrastructure for this project
export async function getProjectInfrastructure() {
  try {
    const config = await fetch(
      'https://terraform-infrastructure-container.joe-1a2.workers.dev/api/projects/theholetruth-org-v2'
    ).then(r => r.json());

    return {
      auth0: config.auth0,
      database: config.database,
      storage: config.storage,
      cloudflare: config.cloudflare
    };
  } catch (error) {
    console.error('Failed to fetch infrastructure config:', error);
    throw error;
  }
}
```

### **Step 3: Use in Application**

```typescript
// app/auth/config.ts
import { getProjectInfrastructure } from '@/lib/infrastructure';

const infra = await getProjectInfrastructure();

export const auth0Config = {
  domain: infra.auth0.domain,
  clientId: infra.auth0.clientId,
  audience: infra.auth0.audience,
  redirectUri: infra.auth0.callbacks[0]
};
```

```typescript
// app/api/db.ts
import { getProjectInfrastructure } from '@/lib/infrastructure';

const infra = await getProjectInfrastructure();
const db = postgres(infra.database.connection_url);

export { db };
```

**NO hardcoded configuration needed!** Everything comes from the central infrastructure service!

---

## 💡 Benefits of This Approach

### **For theholetruth.org-v2:**

✅ **No infrastructure code** - Just API calls
✅ **No Terraform** - Centrally managed
✅ **No secrets** - Fetched from service
✅ **Auto-tracked** - Webhook already connected
✅ **Standardized** - Same patterns as all projects

### **For You:**

✅ **Single place to manage** - All infrastructure in one container
✅ **Credit optimization** - Route to AWS/Azure based on credits
✅ **Complete visibility** - D1 shows all project resource usage
✅ **Easy provisioning** - New project? One API call.
✅ **Consistent** - All projects use same Auth0, same patterns

### **Cost Optimization:**

```javascript
// Container intelligently routes based on credits
POST /api/database/provision
{
  "project": "new-project",
  "type": "postgres"
}

// Worker logic:
if (azureCreditsRemaining > 1000) {
  // Use Azure SQL (credits)
  return provisionAzureSQL();
} else if (awsCreditsRemaining > 1000) {
  // Use AWS RDS (credits)
  return provisionAWSRDS();
} else {
  // Use Neon (sponsored)
  return provisionNeon();
}
```

---

## 🚀 Implementation Plan

### **Phase 1: Service API Foundation** (2-3 hours)

1. Create service endpoints
2. Add project configuration table
3. Implement Auth0 config endpoint
4. Test with theholetruth.org-v2

### **Phase 2: AWS Provider** (1-2 hours)

1. Enable AWS provider in Terraform
2. Add AWS credentials to secrets
3. Create AWS resource modules
4. Test provisioning

### **Phase 3: Resource Provisioning** (3-4 hours)

1. Database provisioning (Neon + Azure + AWS)
2. Storage provisioning (R2 + Blob + S3)
3. Compute provisioning (Workers + Container Apps + Lambda)
4. Track all in D1

### **Phase 4: Client SDK** (2-3 hours)

1. Create npm package
2. TypeScript client
3. Usage examples
4. Publish to npm registry

### **Phase 5: Documentation** (1-2 hours)

1. Service API docs
2. Integration guides
3. Usage examples for each project

---

## 📊 What This Container Becomes

**From:** Terraform infrastructure manager

**To:** Complete HOLE Foundation Infrastructure Platform

**Manages:**
- ☁️ Multi-cloud resources (Azure, AWS, Cloudflare)
- 🔐 Authentication (Auth0)
- 🗄️ Databases (Neon, Azure SQL, AWS RDS)
- 📦 Storage (R2, Blob, S3)
- ⚡ Compute (Workers, Container Apps, Lambda)
- 🌐 DNS (Cloudflare)
- 📂 GitHub (All 38 repos)
- 💰 Credit optimization

**Provides:**
- 🌐 REST API for all services
- 📚 Client SDK for easy integration
- 🗄️ D1 tracking of all resources
- 📊 Unified dashboard
- 🔍 Complete visibility
- 💰 Automatic credit utilization

---

## 🎯 Next Steps

Want me to start implementing this? I can:

1. **Create service API endpoints** - Auth0, database, storage, etc.
2. **Enable AWS provider** - Add to Terraform
3. **Build project provisioning** - One API call = complete infrastructure
4. **Create client SDK** - npm package for easy integration
5. **Document everything** - Complete IaaS guide

This would make setting up theholetruth.org-v2 as simple as:

```bash
npm install @hole-foundation/infrastructure
```

```typescript
import { infra } from '@hole-foundation/infrastructure';
const config = await infra.getProjectConfig('theholetruth-org-v2');
// Everything configured!
```

**Should we build this?** 🚀