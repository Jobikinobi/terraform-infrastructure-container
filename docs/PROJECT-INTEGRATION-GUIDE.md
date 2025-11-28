# Integrating Your Project with HOLE Substrate

## 🎯 Quick Start for theholetruth.org-v2

Your project can now get all infrastructure configuration from HOLE Substrate API - no hardcoded values needed!

---

## 🔑 Service Token (theholetruth.org-v2)

**Client ID:** `affdf8d9a5a4c806c70a47c0801590dd.access`
**Client Secret:** `67d025b330518dea73de1f1852cc49628754c48d62d3d06329967901ed5a653c`

**Add to your `.env.local`:**
```bash
# HOLE Substrate API
SUBSTRATE_API_URL=https://hole-substrate.joe-1a2.workers.dev
CF_ACCESS_CLIENT_ID=affdf8d9a5a4c806c70a47c0801590dd.access
CF_ACCESS_CLIENT_SECRET=67d025b330518dea73de1f1852cc49628754c48d62d3d06329967901ed5a653c
```

---

## 📦 Step 1: Create Substrate Client

**File:** `lib/substrate.ts`

```typescript
// theholetruth.org-v2/lib/substrate.ts

const SUBSTRATE_API = process.env.SUBSTRATE_API_URL || 'https://hole-substrate.joe-1a2.workers.dev';
const CLIENT_ID = process.env.CF_ACCESS_CLIENT_ID!;
const CLIENT_SECRET = process.env.CF_ACCESS_CLIENT_SECRET!;

async function substrateAPI(endpoint: string) {
  const response = await fetch(`${SUBSTRATE_API}${endpoint}`, {
    headers: {
      'CF-Access-Client-Id': CLIENT_ID,
      'CF-Access-Client-Secret': CLIENT_SECRET
    }
  });

  if (!response.ok) {
    throw new Error(`Substrate API error: ${response.statusText}`);
  }

  return response.json();
}

// Get Auth0 configuration
export async function getAuth0Config() {
  const data = await substrateAPI('/api/auth0/config/theholetruth-org-v2');
  return data.auth0;
}

// Get Cloudflare resources
export async function getCloudflareResources() {
  const data = await substrateAPI('/api/cloudflare/resources/theholetruth-org');
  return data.cloudflare.resources;
}

// Get DNS configuration
export async function getDNSConfig() {
  const data = await substrateAPI('/api/dns/zone/theholetruth.org');
  return data.zone;
}
```

---

## 🔐 Step 2: Configure Auth0

**File:** `app/auth/[...auth0]/route.ts`

```typescript
import { handleAuth, handleLogin } from '@auth0/nextjs-auth0';
import { getAuth0Config } from '@/lib/substrate';

// Fetch config from Substrate on server startup
const auth0Config = await getAuth0Config();

export const GET = handleAuth({
  login: handleLogin({
    authorizationParams: {
      audience: auth0Config.audience,
      scope: auth0Config.scopes.join(' ')
    }
  })
});
```

**File:** `middleware.ts` (Auth protection)

```typescript
import { withMiddlewareAuthRequired } from '@auth0/nextjs-auth0/edge';

export default withMiddlewareAuthRequired();

export const config = {
  matcher: ['/dashboard/:path*', '/api/:path*']
};
```

---

## 🗄️ Step 3: Configure Database (When Provisioned)

```typescript
// lib/db.ts
import { getProjectConfig } from '@/lib/substrate';

const projectConfig = await getProjectConfig('theholetruth-org-v2');
const connectionString = projectConfig.resources.find(r => r.resource_type === 'database')?.config.connection_url;

export const db = postgres(connectionString);
```

---

## 📦 Step 4: Use Cloudflare Resources

```typescript
// Get KV namespace IDs from Substrate
const cloudflare = await getCloudflareResources();

// Use in wrangler.toml
[[kv_namespaces]]
binding = "CACHE"
id = "${cloudflare.kvNamespaces.cache}"
```

---

## ✅ What You Get

**From ONE API call:**
- ✅ Auth0 domain, client ID, audience, callbacks
- ✅ Cloudflare KV/R2/D1 resource IDs
- ✅ DNS configuration
- ✅ All environment-specific URLs
- ✅ Code examples ready to copy

**No hardcoded values in your project!**

---

## 🚀 Complete Example

```typescript
// theholetruth.org-v2/app/page.tsx
import { getAuth0Config, getCloudflareResources } from '@/lib/substrate';

export default async function HomePage() {
  // Get infrastructure from Substrate
  const [auth0, cloudflare] = await Promise.all([
    getAuth0Config(),
    getCloudflareResources()
  ]);

  return (
    <div>
      <h1>The HOLE Truth V2</h1>
      <p>Powered by HOLE Substrate</p>

      {/* Auth0 configured from Substrate */}
      <LoginButton />

      {/* Cloudflare resources from Substrate */}
      <Analytics kvNamespace={cloudflare.kvNamespaces.analytics} />
    </div>
  );
}
```

**That's it! Your project is fully configured via Substrate!** 🎉
