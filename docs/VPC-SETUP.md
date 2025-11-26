# Cloudflare Workers VPC Setup Guide

## Overview

Cloudflare Workers VPC enables your Terraform Infrastructure Container to securely connect to private resources in Azure, AWS, GCP, or on-premise networks **without exposing them to the public internet**.

**Status**: Open Beta (available now)
**General Availability**: Later in 2025

---

## What Workers VPC Provides

### 1. **Isolated Cloudflare Environment**
- Group your Cloudflare resources (Workers, KV, R2, D1) into secure, isolated spaces
- Only resources within the VPC can access each other
- App-to-app traffic segmentation

### 2. **Cross-Cloud Private Connectivity**
- Connect to Azure VNets privately
- Access Auth0 infrastructure securely
- Connect to databases and APIs without public exposure
- IPsec tunnels or Cloudflare Network Interconnect

### 3. **Global Network (Not Region-Locked)**
- Unlike traditional VPCs, Workers VPC spans all Cloudflare datacenters
- Your Worker can access private resources from anywhere
- Smart Placement ensures Workers colocate with external VPCs for performance

---

## Use Cases for Terraform Infrastructure Container

### 🔐 **Secure Terraform State Management**
```javascript
// Access Azure Storage Account privately
const state = await env.AZURE_STORAGE_VPC.fetch('/tfstate/prod.tfstate');
// State files never exposed to public internet!
```

### 🗄️ **Private Database Access**
```javascript
// Connect to Azure PostgreSQL/MySQL privately
const db = await env.AZURE_DB_VPC.query('SELECT * FROM terraform_resources');
```

### 🔒 **Secure Secret Management**
```javascript
// Access Azure Key Vault privately
const secret = await env.AZURE_KEYVAULT_VPC.fetch('/secrets/terraform-token');
```

### 🌍 **Multi-Tenant Infrastructure Isolation**
```javascript
// Each client gets isolated VPC
env.CLIENT_A_VPC.fetch('/terraform/plan');
env.CLIENT_B_VPC.fetch('/terraform/plan');
// Complete network isolation
```

### 🚀 **Private CI/CD Pipeline**
```javascript
// All Terraform operations stay private
const apply = await env.TERRAFORM_VPC.fetch('/api/apply', {
  method: 'POST',
  body: JSON.stringify({ workspace: 'production' })
});
```

---

## Prerequisites

### Required:
1. **Cloudflare Account** ✅ (You have: The HOLE Foundation)
2. **Wrangler 4.0+** ✅ (You have: 4.50.0)
3. **OAuth Token with `connectivity:admin` scope** ✅ (Just refreshed!)

### To Set Up:
4. **Cloudflare Tunnel** (connects your private network to Cloudflare)
5. **Target Private Network** (Azure VNet, on-premise network, etc.)

---

## Setup Steps

### Step 1: Create a Cloudflare Tunnel

**Option A: Via Dashboard**
1. Go to https://one.dash.cloudflare.com/
2. Navigate to **Networks** → **Tunnels**
3. Click **Create a tunnel**
4. Choose **Cloudflared** tunnel type
5. Name it: `terraform-infrastructure-tunnel`
6. Install `cloudflared` and run the connector:
   ```bash
   # Install cloudflared (macOS)
   brew install cloudflare/cloudflare/cloudflared

   # Authenticate
   cloudflared tunnel login

   # Create tunnel
   cloudflared tunnel create terraform-infrastructure-tunnel

   # Note the Tunnel ID (UUID format)
   ```

**Option B: Automated**
```bash
# Create tunnel programmatically
cloudflared tunnel create terraform-infrastructure-tunnel

# Get tunnel ID
cloudflared tunnel list
```

### Step 2: Create VPC Service

Once you have the Tunnel ID:

```bash
# Create VPC service for Azure Storage
npx wrangler vpc service create azure-storage \
  --type http \
  --tunnel-id <YOUR-TUNNEL-ID> \
  --hostname <your-storage-account>.blob.core.windows.net \
  --https-port 443

# Create VPC service for Azure PostgreSQL
npx wrangler vpc service create azure-postgres \
  --type http \
  --tunnel-id <YOUR-TUNNEL-ID> \
  --hostname <your-postgres-server>.postgres.database.azure.com \
  --https-port 5432
```

### Step 3: Configure Tunnel Routes

Create a tunnel configuration file:

```yaml
# tunnel-config.yml
tunnel: <YOUR-TUNNEL-ID>
credentials-file: /path/to/.cloudflared/<TUNNEL-ID>.json

ingress:
  # Azure Storage
  - hostname: storage.terraform.vpc
    service: https://<storage-account>.blob.core.windows.net
    originRequest:
      noTLSVerify: false

  # Azure PostgreSQL
  - hostname: postgres.terraform.vpc
    service: tcp://localhost:5432
    originRequest:
      noTLSVerify: false

  # Catch-all rule (required)
  - service: http_status:404
```

Run the tunnel:
```bash
cloudflared tunnel run --config tunnel-config.yml terraform-infrastructure-tunnel
```

### Step 4: Update Worker Configuration

Add VPC bindings to `wrangler.toml`:

```toml
# VPC Service Bindings
[[vpc_bindings]]
binding = "AZURE_STORAGE_VPC"
service_id = "<vpc-service-id-from-step-2>"

[[vpc_bindings]]
binding = "AZURE_POSTGRES_VPC"
service_id = "<vpc-service-id-from-step-2>"
```

### Step 5: Use VPC in Worker Code

Update `src/index.ts`:

```typescript
// Access Azure Storage privately
app.get('/terraform/state/:workspace', async (c) => {
  const workspace = c.req.param('workspace');

  // Private connection to Azure Storage via VPC
  const state = await c.env.AZURE_STORAGE_VPC.fetch(
    `/tfstate/${workspace}.tfstate`
  );

  return c.json({ state: await state.json() });
});

// Access private database
app.get('/terraform/resources', async (c) => {
  // Private connection to Azure PostgreSQL via VPC
  const resources = await c.env.AZURE_POSTGRES_VPC.fetch('/query', {
    method: 'POST',
    body: JSON.stringify({
      query: 'SELECT * FROM terraform_managed_resources'
    })
  });

  return c.json(await resources.json());
});
```

---

## Architecture with VPC

### Before VPC:
```
┌─────────────────────────────────┐
│  Terraform Worker (public)      │
│  - Exposes endpoints publicly   │
│  - Secrets via Cloudflare       │
└───────────────┬─────────────────┘
                │ (public internet)
                ↓
        ┌───────┴────────┐
        │                 │
   Azure (public)    Auth0 (public)
```

### After VPC:
```
┌──────────────────────────────────────────┐
│  Workers VPC (Private Network)           │
│  ┌────────────────────────────────────┐  │
│  │ Terraform Worker                   │  │
│  │ - No public exposure               │  │
│  │ - Private resource access          │  │
│  └────────────────────────────────────┘  │
│              ↓ (private)                  │
│  ┌────────────────────────────────────┐  │
│  │ KV, R2, D1 (isolated)             │  │
│  └────────────────────────────────────┘  │
└──────────────┬───────────────────────────┘
               │
      ┌────────┴────────┐
      │ Cloudflare      │
      │ Tunnel (VPC     │
      │ Private Link)   │
      └────────┬────────┘
               │ (private IPsec/Interconnect)
               ↓
    ┌──────────┴──────────┐
    │                     │
Azure VNet          Auth0 Private
(Storage, DB,       (if available)
Key Vault)
```

---

## Benefits

### 🔒 **Security**
- **Zero Trust**: No public internet exposure
- **Network Segmentation**: Isolated environments per client/app
- **Compliance Ready**: HIPAA, SOC2, PCI-DSS compatible

### 💰 **Cost Savings**
- **Reduced Egress**: Cloudflare Network Interconnect pricing
- **No NAT Gateways**: Direct private connections
- **Discounted Bandwidth**: Better rates than public internet

### ⚡ **Performance**
- **Smart Placement**: Workers colocate with your Azure resources
- **Global Distribution**: Access from any Cloudflare datacenter
- **Low Latency**: Private network connections

### 🛠️ **Developer Experience**
```javascript
// Simple binding syntax
const data = await env.PRIVATE_RESOURCE.fetch('/api');
// No complex networking code!
```

---

## Current Limitations (Open Beta)

1. **Tunnel Required**: Must set up Cloudflare Tunnel first
2. **HTTP Only**: Currently only `http` type VPC services
3. **Manual Setup**: Some dashboard configuration required
4. **Beta Status**: Features may change before GA

---

## Next Steps

### Immediate:
1. ✅ **Installed VPC-enabled Wrangler** (4.50.0)
2. ✅ **Refreshed OAuth token** with `connectivity:admin` scope
3. 📋 **Install cloudflared CLI**:
   ```bash
   brew install cloudflare/cloudflare/cloudflared
   ```

### When Ready to Implement:
4. Create Cloudflare Tunnel for Azure VNet
5. Set up VPC service for Azure Storage (Terraform state)
6. Configure tunnel routes
7. Update Worker with VPC bindings
8. Test private connectivity

---

## Resources

- **Cloudflare Tunnel Docs**: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/
- **Workers VPC Announcement**: https://blog.cloudflare.com/workers-virtual-private-cloud/
- **Wrangler VPC Commands**: `npx wrangler vpc --help`
- **Dashboard**: https://dash.cloudflare.com/ → Networks → Tunnels

---

## For Your Terraform Container

**Perfect Use Cases:**
1. Private Azure Storage backend for Terraform state
2. Secure connection to Azure Key Vault for secrets
3. Private database connections for D1 deployment tracking
4. Isolated networks per deployment environment (dev/staging/prod)
5. Secure CI/CD pipeline execution

**Implementation Priority:**
1. **High**: Azure Storage for Terraform state (security + compliance)
2. **Medium**: Azure Key Vault integration (better secret management)
3. **Low**: Database connections (D1 works well for now)

---

## Status

- ✅ VPC Commands Available in Wrangler 4.50.0
- ✅ OAuth Token Has Required Permissions
- ⏳ Cloudflare Tunnel Setup (when ready to implement)
- ⏳ VPC Service Creation (after tunnel setup)
- ⏳ Worker Integration (after VPC services exist)

**Ready to proceed when you want to take the next step!**
