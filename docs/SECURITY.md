# Security Configuration Guide

This document covers securing the Terraform Infrastructure Container using Cloudflare Zero Trust and other security measures.

---

## Overview

The security architecture uses multiple layers:

1. **Cloudflare Zero Trust (Access)** - Authentication & authorization at the edge
2. **GitHub Webhook Signature Verification** - Validates webhook payloads
3. **Worker JWT Verification** - Defense-in-depth for Access tokens
4. **Secrets Management** - Cloudflare Worker secrets (never in code)

```
┌─────────────────────────────────────────────────────────────────┐
│                    Cloudflare Edge                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Zero Trust Access (Authentication Layer)                 │  │
│  │  - Authenticates users before reaching Worker             │  │
│  │  - MFA, SSO, device posture checks                        │  │
│  │  - Issues CF-Access-JWT-Assertion header                  │  │
│  └─────────────────────────┬─────────────────────────────────┘  │
│                            ↓                                     │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Worker (Application Layer)                               │  │
│  │  - Verifies Access JWT (defense-in-depth)                 │  │
│  │  - Verifies GitHub webhook signatures                     │  │
│  │  - Handles authorized requests                            │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. Cloudflare Zero Trust Setup

### Step 1: Access the Zero Trust Dashboard

1. Go to [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/)
2. Select your account: **The HOLE Foundation**
3. Navigate to: **Access → Applications**

### Step 2: Create Access Application

Click **"Add an application"** and select **"Self-hosted"**

**Application Configuration:**

| Field | Value |
|-------|-------|
| Application name | `Terraform Infrastructure API` |
| Session duration | `24 hours` (or as needed) |
| Application domain | `terraform-infrastructure-container.joe-1a2.workers.dev` |
| Path | `/api/*` |

> **Note**: If using a custom domain (e.g., `terraform.theholetruth.org`), use that instead.

### Step 3: Configure Access Policy

Create a policy to control who can access the API:

**Policy Configuration:**

| Field | Value |
|-------|-------|
| Policy name | `Infrastructure Team Access` |
| Action | `Allow` |
| Session duration | `24 hours` |

**Include Rules** (who CAN access):

| Rule Type | Value |
|-----------|-------|
| Emails | `joe@theholetruth.org` |
| Emails ending in | `@theholetruth.org` |

**Optional - Require Rules** (additional requirements):

| Rule Type | Value |
|-----------|-------|
| Authentication method | Any (or specific IdP) |
| Country | United States (optional geo-restriction) |

### Step 4: Configure Identity Providers

Zero Trust supports multiple identity providers. Recommended setup:

**Primary: Auth0**
1. Go to **Settings → Authentication → Login methods**
2. Click **Add new** → **Auth0**
3. Configure:
   - Auth0 Domain: `dev-4fszoklachwdh46m.us.auth0.com`
   - Client ID: (create a new M2M app or use existing)
   - Client Secret: (from Auth0 dashboard)

**Alternative: One-Time PIN (OTP)**
- Enabled by default
- Users receive email with login code
- Good for occasional access

**Alternative: Google Workspace**
- If you have Google Workspace configured
- Enables SSO with Google accounts

### Step 5: Test Access

1. Open an incognito window
2. Navigate to: `https://terraform-infrastructure-container.joe-1a2.workers.dev/api/info`
3. You should see the Cloudflare Access login page
4. Authenticate with your configured identity provider
5. After authentication, you should see the API response

---

## 2. Endpoint Protection Strategy

### Protected Endpoints (Require Authentication)

These endpoints should be behind Zero Trust Access:

```
/api/terraform/*      - All Terraform operations
/api/deployments      - Deployment history
/api/artifacts/*      - Artifact management
/api/projects/*       - Project configuration
/api/services         - Service discovery
/api/auth0/*          - Auth0 configuration
/api/cloudflare/*     - Cloudflare resources
/api/dns/*            - DNS management
/api/vpc/*            - VPC testing
```

### Public Endpoints (No Authentication)

These endpoints should remain public:

```
/                     - Health check (useful for monitoring)
/api/github/webhook   - GitHub webhooks (verified by signature)
```

### Access Application Path Configuration

To protect most endpoints while keeping some public:

**Option A: Protect `/api/*` with exceptions**
```
Application 1: terraform-infrastructure-api
  Domain: terraform-infrastructure-container.joe-1a2.workers.dev
  Path: /api/*

Bypass Policy (for webhooks):
  Path: /api/github/webhook
  Action: Bypass
```

**Option B: Protect specific paths**
```
Application 1: terraform-api
  Path: /api/terraform/*

Application 2: admin-api
  Path: /api/projects/*
  Path: /api/services
  Path: /api/deployments
```

---

## 3. GitHub Webhook Security

GitHub webhooks bypass Zero Trust (they're server-to-server), so we verify them using HMAC signatures.

### Step 1: Generate Webhook Secret

```bash
# Generate a secure random secret
openssl rand -hex 32
```

Save this secret - you'll need it in two places.

### Step 2: Add Secret to Cloudflare Worker

```bash
# Add the webhook secret to the Worker
npx wrangler secret put GITHUB_WEBHOOK_SECRET
# Paste the secret when prompted
```

### Step 3: Configure GitHub Webhook

1. Go to your repository: **Settings → Webhooks**
2. Edit the existing webhook or create new:
   - **Payload URL**: `https://terraform-infrastructure-container.joe-1a2.workers.dev/api/github/webhook`
   - **Content type**: `application/json`
   - **Secret**: (paste the same secret from Step 1)
   - **SSL verification**: Enabled
   - **Events**: `push`, `pull_request`, `issues`, `release`

### Step 4: Verification in Worker

The Worker verifies webhooks using the `X-Hub-Signature-256` header:

```typescript
// Already implemented in src/index.ts
async function verifyGitHubWebhook(request: Request, secret: string): Promise<boolean> {
  const signature = request.headers.get('X-Hub-Signature-256');
  if (!signature) return false;

  const body = await request.clone().text();
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );

  const sig = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(body));
  const expectedSignature = 'sha256=' + Array.from(new Uint8Array(sig))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');

  return signature === expectedSignature;
}
```

---

## 4. Worker JWT Verification (Defense-in-Depth)

Even though Access authenticates users at the edge, verifying the JWT in the Worker provides defense-in-depth.

### How It Works

1. User authenticates with Zero Trust Access
2. Access proxies request to Worker with `CF-Access-JWT-Assertion` header
3. Worker verifies the JWT signature against Cloudflare's public keys
4. Worker extracts user identity from JWT claims

### Configuration

Add your Access Application's **Team Domain** and **AUD** (Audience) tag:

```bash
# Your Zero Trust team domain (found in Zero Trust dashboard → Settings)
npx wrangler secret put CF_ACCESS_TEAM_DOMAIN
# Enter: <your-team>.cloudflareaccess.com

# Your Access Application's AUD tag (found in Application → Overview)
npx wrangler secret put CF_ACCESS_AUD
# Enter: (64-character hex string from Access application)
```

### Finding Your AUD Tag

1. Go to Zero Trust Dashboard
2. Navigate to: **Access → Applications**
3. Click on your application
4. Find **Application Audience (AUD) Tag** in the overview

---

## 5. Secrets Management

### Required Secrets

| Secret | Purpose | How to Set |
|--------|---------|------------|
| `GITHUB_WEBHOOK_SECRET` | Verify GitHub webhooks | `wrangler secret put GITHUB_WEBHOOK_SECRET` |
| `CF_ACCESS_AUD` | Verify Access JWTs | `wrangler secret put CF_ACCESS_AUD` |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API access | Already configured |
| `AUTH0_CLIENT_SECRET` | Auth0 M2M auth | Already configured |
| `AZURE_CLIENT_SECRET` | Azure Service Principal | Already configured |

### List Current Secrets

```bash
npx wrangler secret list
```

### Rotate a Secret

```bash
# Update the secret value
npx wrangler secret put SECRET_NAME

# Then update the corresponding service (GitHub, Access, etc.)
```

---

## 6. Security Checklist

### Initial Setup

- [ ] Create Zero Trust Access Application
- [ ] Configure Access Policy with allowed users/groups
- [ ] Set up identity provider (Auth0, Google, OTP)
- [ ] Generate and configure GitHub webhook secret
- [ ] Add `GITHUB_WEBHOOK_SECRET` to Worker secrets
- [ ] Add `CF_ACCESS_AUD` to Worker secrets
- [ ] Test authentication flow
- [ ] Test webhook signature verification

### Ongoing Security

- [ ] Review Access logs monthly (Zero Trust → Logs)
- [ ] Rotate GitHub webhook secret quarterly
- [ ] Review Access policies when team changes
- [ ] Monitor for failed authentication attempts
- [ ] Keep Worker dependencies updated

### Production Hardening

- [ ] Enable Access logging
- [ ] Configure session duration appropriately
- [ ] Set up alerts for suspicious activity
- [ ] Document incident response procedures
- [ ] Enable Cloudflare WAF rules (if applicable)

---

## 7. Troubleshooting

### "Access Denied" on API Endpoints

1. Check you're logged into Zero Trust
2. Verify your email is in the Access policy
3. Check session hasn't expired
4. Try incognito window to clear cached session

### GitHub Webhooks Failing

1. Check webhook secret matches in GitHub and Worker
2. Verify webhook URL is correct
3. Check Worker logs: `npx wrangler tail`
4. Test with GitHub's webhook redeliver feature

### JWT Verification Errors

1. Verify `CF_ACCESS_AUD` matches your application
2. Check clock sync (JWT expiration is time-sensitive)
3. Ensure request is going through Access (not direct)

### View Worker Logs

```bash
# Stream live logs
npx wrangler tail

# Filter for errors
npx wrangler tail --format=json | jq 'select(.level == "error")'
```

---

## 8. Security Architecture Diagram

```
                                    Internet
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         Cloudflare Edge                                 │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                    Zero Trust Access                             │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │   │
│  │  │   Auth0     │  │   Google    │  │   One-Time PIN (OTP)   │  │   │
│  │  │   IdP       │  │   IdP       │  │   (Email)              │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────────────┘  │   │
│  │                           │                                      │   │
│  │                           ▼                                      │   │
│  │  ┌─────────────────────────────────────────────────────────┐    │   │
│  │  │              Access Policy Engine                        │    │   │
│  │  │  - Email allowlist                                       │    │   │
│  │  │  - MFA requirements                                      │    │   │
│  │  │  - Device posture (optional)                            │    │   │
│  │  │  - Geo restrictions (optional)                          │    │   │
│  │  └─────────────────────────────────────────────────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                    │
│                                    │ CF-Access-JWT-Assertion            │
│                                    ▼                                    │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                 Cloudflare Worker                                │   │
│  │                                                                  │   │
│  │   Authenticated Requests          Webhook Requests               │   │
│  │   (/api/*)                        (/api/github/webhook)          │   │
│  │        │                                  │                      │   │
│  │        ▼                                  ▼                      │   │
│  │   ┌──────────────┐               ┌──────────────────┐           │   │
│  │   │ Verify JWT   │               │ Verify HMAC      │           │   │
│  │   │ (optional)   │               │ X-Hub-Signature  │           │   │
│  │   └──────────────┘               └──────────────────┘           │   │
│  │        │                                  │                      │   │
│  │        ▼                                  ▼                      │   │
│  │   ┌─────────────────────────────────────────────────────────┐   │   │
│  │   │              Application Logic                          │   │   │
│  │   │  - Terraform operations                                 │   │   │
│  │   │  - Deployment tracking                                  │   │   │
│  │   │  - Resource management                                  │   │   │
│  │   └─────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                    │                                    │
└────────────────────────────────────┼────────────────────────────────────┘
                                     │
                                     ▼
                    ┌────────────────────────────────┐
                    │    Cloudflare Resources        │
                    │  - D1 Database                 │
                    │  - KV Namespace                │
                    │  - R2 Bucket                   │
                    └────────────────────────────────┘
```

---

## 9. References

- [Cloudflare Zero Trust Documentation](https://developers.cloudflare.com/cloudflare-one/)
- [Cloudflare Access JWT Validation](https://developers.cloudflare.com/cloudflare-one/identity/authorization-cookie/validating-json/)
- [GitHub Webhook Security](https://docs.github.com/en/webhooks/using-webhooks/validating-webhook-deliveries)
- [Cloudflare Workers Security](https://developers.cloudflare.com/workers/configuration/security/)

---

**Last Updated**: 2025-12-05
**Author**: Claude Code Review
