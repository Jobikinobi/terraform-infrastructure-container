# Securing Infrastructure Service with Cloudflare Access

## 🎯 Goal

Protect the Infrastructure-as-a-Service API using **Cloudflare Zero Trust / Access** - leveraging your existing Zero Trust setup to secure this Worker.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│  Cloudflare Zero Trust (Your Existing Setup)        │
│  ┌───────────────────────────────────────────────┐  │
│  │ Access Policies                               │  │
│  │ - Team: joe@theholetruth.org (admin)         │  │
│  │ - Service Tokens: Per-project access         │  │
│  │ - GitHub: Webhook IPs allowed                │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────┬───────────────────────────────────┘
                  │ (protects)
                  ↓
┌─────────────────────────────────────────────────────┐
│  Infrastructure Service Worker                      │
│  terraform-infrastructure-container                 │
│  ┌───────────────────────────────────────────────┐  │
│  │ Public (No Auth):                             │  │
│  │ - GET /api/services (discovery)              │  │
│  │ - GET / (health check)                        │  │
│  └───────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────┐  │
│  │ Protected (Service Token):                    │  │
│  │ - GET /api/auth0/config/:project             │  │
│  │ - GET /api/cloudflare/resources/:project     │  │
│  │ - GET /api/projects/:project                  │  │
│  └───────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────┐  │
│  │ Admin Only (Team Email):                      │  │
│  │ - POST /api/database/provision                │  │
│  │ - POST /api/terraform/apply                   │  │
│  │ - POST /api/admin/*                           │  │
│  └───────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────┐  │
│  │ Webhooks (IP Allow List):                     │  │
│  │ - POST /api/github/webhook                    │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

---

## 🚀 Setup Steps

### **Step 1: Add Application to Cloudflare Access**

**Via Dashboard:**
1. Go to https://one.dash.cloudflare.com/
2. Navigate to **Zero Trust** → **Access** → **Applications**
3. Click **"Add an application"**
4. Select **"Self-hosted"**
5. Configure:
   - **Application name**: `HOLE Infrastructure Service`
   - **Session duration**: `24 hours`
   - **Application domain**:
     - Subdomain: `terraform-infrastructure-container`
     - Domain: `joe-1a2.workers.dev`
   - **Application type**: `API`

### **Step 2: Create Access Policies**

**Policy 1: Admin Access (You)**
```
Name: HOLE Foundation Admin
Action: Allow
Decision: Allow
Include:
  - Emails: joe@theholetruth.org
Paths:
  - /api/admin/*
  - /api/terraform/*
  - /api/database/provision
  - /api/projects
```

**Policy 2: Service Token Access (Projects)**
```
Name: Project API Access
Action: Allow
Include:
  - Service Token: theholetruth-v2
  - Service Token: mipds
  - Service Token: legal-intelligence
Paths:
  - /api/auth0/*
  - /api/cloudflare/*
  - /api/projects/*
```

**Policy 3: Public Endpoints (No Auth)**
```
Name: Public Discovery
Action: Allow
Include:
  - Everyone
Paths:
  - /api/services
  - /
  - /api/info
```

**Policy 4: GitHub Webhooks**
```
Name: GitHub Webhooks
Action: Allow
Include:
  - IP ranges:
    - 192.30.252.0/22
    - 185.199.108.0/22
    - 140.82.112.0/20
    - 143.55.64.0/20
    - 2a0a:a440::/29
    - 2606:50c0::/32
Paths:
  - /api/github/webhook
```

### **Step 3: Generate Service Tokens**

**For each project:**

1. Go to **Access** → **Service Auth** → **Service Tokens**
2. Click **"Create Service Token"**
3. Create tokens:

```
Token Name: theholetruth-org-v2
Duration: Non-expiring
Note: API access for theholetruth.org v2 project

Generated:
  Client ID: 1a2b3c4d5e6f7g8h9i0j.access
  Client Secret: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
```

**Repeat for:**
- mipds
- legal-intelligence
- us-transparency
- (Any project that needs API access)

### **Step 4: Update Worker to Read Access Headers**

**Cloudflare automatically adds headers:**
```
CF-Access-Authenticated-User-Email: joe@theholetruth.org
CF-Access-Client-Id: service-token-id
CF-Access-JWT-Assertion: eyJhbGc...
```

**Worker can use these:**
```typescript
// src/access-middleware.ts

export async function getAuthenticatedIdentity(c: Context) {
  const email = c.req.header('CF-Access-Authenticated-User-Email');
  const serviceToken = c.req.header('CF-Access-Client-Id');
  const jwt = c.req.header('CF-Access-JWT-Assertion');

  if (email) {
    return { type: 'user', identity: email, isAdmin: true };
  }

  if (serviceToken) {
    const project = await getProjectForServiceToken(serviceToken);
    return { type: 'service', identity: serviceToken, project };
  }

  return null;
}

// Use in endpoints:
app.get('/api/auth0/config/:project', async (c) => {
  const auth = await getAuthenticatedIdentity(c);

  if (!auth) {
    return c.json({ error: 'Unauthorized' }, 401);
  }

  const requestedProject = c.req.param('project');

  // Service tokens can only access their own project
  if (auth.type === 'service' && auth.project !== requestedProject) {
    return c.json({ error: 'Service token can only access its own project' }, 403);
  }

  // Admin users can access any project
  if (auth.type === 'user' && !auth.isAdmin) {
    return c.json({ error: 'Admin access required' }, 403);
  }

  // Return configuration
  return getAuth0ConfigForProject(requestedProject);
});
```

---

## 🔑 Service Token Management in D1

**Store service token mappings:**

```sql
CREATE TABLE service_tokens (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    token_id TEXT UNIQUE NOT NULL,  -- CF-Access-Client-Id
    project_id TEXT NOT NULL,
    token_name TEXT,
    scopes JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME,
    last_used_at DATETIME,
    revoked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

-- Map service token to project
INSERT INTO service_tokens (token_id, project_id, token_name, scopes)
VALUES ('1a2b3c4d5e6f7g8h9i0j.access', 'theholetruth-org-v2', 'theholetruth-v2',
        json('["read:auth0", "read:cloudflare"]'));
```

---

## 🎯 Usage in Projects

### **theholetruth.org-v2 Integration:**

**Environment Variables:**
```bash
# .env.local
INFRASTRUCTURE_SERVICE_URL=https://terraform-infrastructure-container.joe-1a2.workers.dev
CF_ACCESS_CLIENT_ID=1a2b3c4d5e6f7g8h9i0j.access
CF_ACCESS_CLIENT_SECRET=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
```

**Fetch Infrastructure Config:**
```typescript
// lib/infrastructure.ts

export async function getInfraConfig() {
  const response = await fetch(
    `${process.env.INFRASTRUCTURE_SERVICE_URL}/api/auth0/config/theholetruth-org-v2`,
    {
      headers: {
        'CF-Access-Client-Id': process.env.CF_ACCESS_CLIENT_ID!,
        'CF-Access-Client-Secret': process.env.CF_ACCESS_CLIENT_SECRET!
      }
    }
  );

  if (!response.ok) {
    throw new Error('Failed to fetch infrastructure config');
  }

  return response.json();
}
```

**Use in App:**
```typescript
// app/auth/[...auth0]/route.ts
import { getInfraConfig } from '@/lib/infrastructure';

const infra = await getInfraConfig();

export const GET = handleAuth({
  login: handleLogin({
    authorizationParams: {
      audience: infra.auth0.audience,
      scope: infra.auth0.scopes.join(' ')
    }
  })
});
```

---

## 📋 Setup Checklist

### **In Cloudflare Dashboard:**
- [ ] Go to Zero Trust → Access → Applications
- [ ] Add "HOLE Infrastructure Service" application
- [ ] Set domain: `terraform-infrastructure-container.joe-1a2.workers.dev`
- [ ] Create access policies (team email + service tokens)
- [ ] Create service tokens for each project
- [ ] Configure path-based policies

### **In This Container:**
- [ ] Add service token validation middleware
- [ ] Map tokens to projects in D1
- [ ] Add audit logging for all access
- [ ] Update endpoints to check authentication
- [ ] Deploy secured Worker

### **In Projects (theholetruth.org-v2):**
- [ ] Add CF_ACCESS_CLIENT_ID to .env
- [ ] Add CF_ACCESS_CLIENT_SECRET to .env
- [ ] Create infrastructure.ts to fetch config
- [ ] Use fetched config instead of hardcoded values

---

## 🔐 Security Benefits

**With Cloudflare Access:**
- ✅ **Zero Trust** - Every request authenticated
- ✅ **Team access** - Your email can access admin endpoints
- ✅ **Service tokens** - Each project has isolated access
- ✅ **Audit logs** - Cloudflare logs all access
- ✅ **IP allow lists** - GitHub webhooks allowed
- ✅ **No passwords** - Token-based authentication
- ✅ **Revocable** - Disable token = instant access removal

**Without exposing:**
- ❌ Infrastructure details to public
- ❌ Configuration to unauthorized users
- ❌ Admin operations to projects

---

## 🚀 Next Step

Since you already have Cloudflare Zero Trust, we just need to:

**1. Add this Worker as a protected application** (5 minutes via dashboard)

**2. Generate service tokens** (2 minutes per project)

**3. Add validation middleware** to Worker (30 minutes coding)

**4. Test** with one project (10 minutes)

**Ready to secure it?** We can do this quickly since your Zero Trust is already set up!