# Project Roadmap

> Prioritized improvements for the Terraform Infrastructure Container

**Last Updated**: 2025-12-05
**Status**: Active Development

---

## Overview

This roadmap consolidates findings from the comprehensive code review and outlines improvements in priority order. The focus is on:

1. **Security** - Critical fixes that must happen first
2. **Cloudflare Capabilities** - Leveraging the full platform
3. **Feature Completion** - Implementing stub endpoints
4. **Code Quality** - Type safety, testing, documentation

---

## Priority Legend

| Priority | Meaning | Timeline |
|----------|---------|----------|
| 🔴 P0 | Critical - Security/Breaking | Immediate |
| 🟠 P1 | High - Core functionality | This sprint |
| 🟡 P2 | Medium - Important features | Next sprint |
| 🟢 P3 | Low - Nice to have | Backlog |

---

## Phase 1: Security Hardening 🔴

### 1.1 Cloudflare Zero Trust Access ✅ DOCUMENTED
**Priority**: 🔴 P0
**Status**: Documentation complete, pending configuration
**Effort**: 2-4 hours

Protect API endpoints using Cloudflare Zero Trust:

- [ ] Create Access Application in Zero Trust dashboard
- [ ] Configure Access Policy (allowed users/groups)
- [ ] Set up Auth0 as identity provider
- [ ] Test authentication flow
- [ ] Add `CF_ACCESS_AUD` secret to Worker

**Documentation**: [docs/SECURITY.md](docs/SECURITY.md)

### 1.2 GitHub Webhook Signature Verification ✅ IMPLEMENTED
**Priority**: 🔴 P0
**Status**: Code complete, pending secret configuration
**Effort**: 1 hour

Verify webhook payloads using HMAC-SHA256:

- [x] Implement signature verification in Worker
- [ ] Generate webhook secret: `openssl rand -hex 32`
- [ ] Add secret to Worker: `wrangler secret put GITHUB_WEBHOOK_SECRET`
- [ ] Configure secret in GitHub repository webhook settings
- [ ] Test webhook delivery

**Code**: `src/index.ts:53-81` (verifyGitHubWebhook function)

### 1.3 Access JWT Verification (Defense-in-Depth) ✅ IMPLEMENTED
**Priority**: 🔴 P0
**Status**: Code complete
**Effort**: Complete

Verify Cloudflare Access tokens in Worker:

- [x] Implement JWT verification middleware
- [x] Add to protected routes (`/api/*`)
- [x] Skip for webhook endpoint (uses signature)
- [x] Skip in development environment

**Code**: `src/index.ts:84-144` (verifyAccessJWT function)

### 1.4 Production Environment Configuration
**Priority**: 🔴 P0
**Status**: Pending
**Effort**: 1 hour

- [ ] Set `ENVIRONMENT=production` in wrangler.toml for prod
- [ ] Configure custom domain (terraform.theholetruth.org)
- [ ] Disable `workers_dev` in production
- [ ] Test security in production environment

---

## Phase 2: Cloudflare Platform Expansion 🟠

### 2.1 Queues for Async Operations
**Priority**: 🟠 P1
**Status**: Not started
**Effort**: 4-6 hours

Use Cloudflare Queues for long-running operations:

```toml
# wrangler.toml additions
[[queues.producers]]
queue = "terraform-operations"
binding = "TERRAFORM_QUEUE"

[[queues.consumers]]
queue = "terraform-operations"
max_batch_size = 1
max_retries = 3
```

**Use Cases**:
- Terraform plan/apply operations
- Large file processing
- Webhook event processing (batch)
- Email notifications

### 2.2 Durable Objects for State
**Priority**: 🟠 P1
**Status**: Commented out in wrangler.toml
**Effort**: 1-2 days

Implement Durable Objects for:

- Terraform execution state
- Long-running operation tracking
- WebSocket connections (real-time updates)

```typescript
export class TerraformExecutor {
  state: DurableObjectState;

  async fetch(request: Request) {
    // Handle terraform operations with persistent state
  }
}
```

### 2.3 Cron Triggers for Scheduled Tasks
**Priority**: 🟡 P2
**Status**: Not started
**Effort**: 2-4 hours

```toml
# wrangler.toml
[triggers]
crons = [
  "0 6 * * *",    # Daily cost report at 6 AM UTC
  "0 */4 * * *",  # Health check every 4 hours
  "0 0 * * 0"     # Weekly infrastructure audit
]
```

**Scheduled Tasks**:
- Daily cost report generation
- Infrastructure drift detection
- Backup verification
- Cleanup of old deployments

### 2.4 Workers AI for Plan Analysis
**Priority**: 🟡 P2
**Status**: Not started
**Effort**: 1 day

```toml
# wrangler.toml
[ai]
binding = "AI"
```

**Use Cases**:
- Analyze terraform plans for security issues
- Generate deployment summaries
- Suggest cost optimizations
- Natural language infrastructure queries

### 2.5 Analytics Engine for Metrics
**Priority**: 🟢 P3
**Status**: Not started
**Effort**: 4-6 hours

```toml
# wrangler.toml
[[analytics_engine_datasets]]
binding = "ANALYTICS"
dataset = "infrastructure_metrics"
```

**Metrics to Track**:
- Deployment frequency and duration
- API response times
- Error rates by endpoint
- Resource utilization

### 2.6 Vectorize (Replace Pinecone)
**Priority**: 🟢 P3
**Status**: Not started
**Effort**: 2-3 days

```toml
# wrangler.toml
[[vectorize]]
binding = "VECTORIZE"
index_name = "infrastructure-docs"
```

Replace external Pinecone dependency with native Cloudflare Vectorize.

### 2.7 Email Workers for Notifications
**Priority**: 🟢 P3
**Status**: Not started
**Effort**: 4-6 hours

```toml
# wrangler.toml
send_email = [
  { name = "NOTIFICATIONS" }
]
```

**Notifications**:
- Deployment success/failure
- Security alerts
- Cost threshold warnings
- Weekly infrastructure summary

---

## Phase 3: Feature Completion 🟡

### 3.1 Terraform State Management
**Priority**: 🟠 P1
**Status**: Stub implemented
**Effort**: 1-2 days

Implement `/api/terraform/state` endpoint:

- [ ] Store state in KV namespace
- [ ] Version state with timestamps
- [ ] Support state locking
- [ ] Backup to R2

### 3.2 Resource Inventory API
**Priority**: 🟠 P1
**Status**: Stub implemented
**Effort**: 1 day

Implement `/api/terraform/resources` endpoint:

- [ ] Query D1 for managed resources
- [ ] Filter by provider (azure, cloudflare, auth0)
- [ ] Include resource metadata
- [ ] Support pagination

### 3.3 Deployment Tracking
**Priority**: 🟠 P1
**Status**: Partial
**Effort**: 1 day

Complete `/api/deployments` endpoint:

- [ ] List deployment history from D1
- [ ] Filter by status, date range
- [ ] Include related terraform operations
- [ ] Link to git commits

### 3.4 Artifact Management
**Priority**: 🟡 P2
**Status**: Stub implemented
**Effort**: 4-6 hours

Implement `/api/artifacts/*` endpoints:

- [ ] Upload artifacts to R2
- [ ] Multipart upload support
- [ ] List artifacts by deployment
- [ ] Download with signed URLs

### 3.5 VPC Integration
**Priority**: 🟡 P2
**Status**: Blocked (waiting for Wrangler)
**Effort**: TBD

Enable private Azure resource access:

- [ ] Monitor Wrangler releases for VPC binding syntax
- [ ] Configure VPC service binding
- [ ] Test private Azure connectivity
- [ ] Document VPC setup

### 3.6 PR Event Handling
**Priority**: 🟡 P2
**Status**: Stub implemented
**Effort**: 4-6 hours

Complete pull request webhook handling:

- [ ] Track PR lifecycle (opened, closed, merged)
- [ ] Link PRs to deployments
- [ ] Comment on PR with deployment status
- [ ] Support review workflows

---

## Phase 4: Code Quality 🟢

### 4.1 TypeScript Improvements
**Priority**: 🟡 P2
**Status**: Partial
**Effort**: 4-6 hours

- [ ] Replace `any` types with proper interfaces
- [ ] Define GitHub webhook payload types
- [ ] Add Hono context type augmentation
- [ ] Enable stricter TypeScript checks

### 4.2 Test Suite
**Priority**: 🟡 P2
**Status**: Not started (vitest configured)
**Effort**: 2-3 days

```typescript
// tests/api.test.ts
describe('API Endpoints', () => {
  test('health check returns healthy', async () => {
    const res = await app.request('/');
    expect(res.status).toBe(200);
  });

  test('webhook rejects invalid signature', async () => {
    const res = await app.request('/api/github/webhook', {
      method: 'POST',
      headers: { 'X-Hub-Signature-256': 'invalid' }
    });
    expect(res.status).toBe(401);
  });
});
```

### 4.3 Error Handling
**Priority**: 🟡 P2
**Status**: Basic
**Effort**: 4-6 hours

- [ ] Create custom error classes
- [ ] Implement error logging to D1
- [ ] Sanitize error messages (no sensitive data)
- [ ] Add request ID tracking

### 4.4 Input Validation
**Priority**: 🟡 P2
**Status**: Missing
**Effort**: 4-6 hours

- [ ] Add Zod or similar for request validation
- [ ] Validate path parameters
- [ ] Validate request bodies
- [ ] Return helpful validation errors

### 4.5 Move Hard-coded Config to D1
**Priority**: 🟢 P3
**Status**: Not started
**Effort**: 1 day

Move from `src/services-api.ts` to D1:

- [ ] Auth0 client configurations
- [ ] Cloudflare resource mappings
- [ ] DNS zone information
- [ ] Create admin API for config updates

---

## Phase 5: Documentation & DevEx 🟢

### 5.1 API Documentation
**Priority**: 🟢 P3
**Status**: Partial (in 404 response)
**Effort**: 4-6 hours

- [ ] Create OpenAPI/Swagger spec
- [ ] Generate API documentation
- [ ] Add request/response examples
- [ ] Host at `/api/docs`

### 5.2 Developer Onboarding
**Priority**: 🟢 P3
**Status**: Good (CLAUDE.md, GETTING-STARTED.md)
**Effort**: 2-4 hours

- [ ] Add troubleshooting guide
- [ ] Create video walkthrough
- [ ] Add architecture decision records (ADRs)
- [ ] Document common workflows

### 5.3 Monitoring Dashboard
**Priority**: 🟢 P3
**Status**: Not started
**Effort**: 2-3 days

- [ ] Create Cloudflare Pages dashboard
- [ ] Display deployment status
- [ ] Show infrastructure metrics
- [ ] Real-time updates via WebSocket

---

## Implementation Schedule

### Sprint 1 (Current)
- [x] Document Zero Trust setup
- [x] Implement webhook signature verification
- [x] Implement Access JWT verification
- [ ] Configure Zero Trust Access Application
- [ ] Add secrets (GITHUB_WEBHOOK_SECRET, CF_ACCESS_AUD)
- [ ] Create this roadmap document
- [ ] Create code review document

### Sprint 2
- [ ] Implement Queues for async operations
- [ ] Complete Terraform state management
- [ ] Complete resource inventory API
- [ ] Add TypeScript improvements

### Sprint 3
- [ ] Implement Durable Objects
- [ ] Add Cron Triggers
- [ ] Complete deployment tracking
- [ ] Add test suite

### Sprint 4
- [ ] Workers AI integration
- [ ] Analytics Engine setup
- [ ] PR event handling
- [ ] Input validation

### Backlog
- Vectorize migration
- Email notifications
- Monitoring dashboard
- VPC integration (when available)

---

## Dependencies & Blockers

| Item | Dependency | Status |
|------|------------|--------|
| VPC Integration | Wrangler binding syntax | Blocked |
| Auth0 IdP in Access | Auth0 M2M credentials | Ready |
| Workers AI | AI binding available | Ready |
| Vectorize | Index creation | Ready |

---

## Success Metrics

### Security
- [ ] Zero unauthenticated API access in production
- [ ] All webhooks verified by signature
- [ ] No secrets in code or logs

### Performance
- [ ] API response time < 100ms (p95)
- [ ] Deployment tracking latency < 1s
- [ ] Queue processing time < 30s

### Reliability
- [ ] 99.9% uptime
- [ ] Zero data loss
- [ ] All deployments tracked

### Developer Experience
- [ ] New developer onboarded in < 1 hour
- [ ] All endpoints documented
- [ ] Test coverage > 80%

---

## Related Documents

- [CODE-REVIEW.md](docs/CODE-REVIEW.md) - Detailed code review findings
- [SECURITY.md](docs/SECURITY.md) - Security configuration guide
- [UNIFIED-SYSTEM-PLAN.md](docs/UNIFIED-SYSTEM-PLAN.md) - Feature development plan
- [CLAUDE.md](CLAUDE.md) - Complete project context

---

## Contributing

When working on roadmap items:

1. Check the item is not blocked
2. Create a branch: `feature/roadmap-X.Y-description`
3. Update status in this document
4. Submit PR with link to roadmap item
5. Update status to complete when merged

---

**Next Review**: End of Sprint 1
**Owner**: joe@theholetruth.org
