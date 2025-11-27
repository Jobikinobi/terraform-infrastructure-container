# Unified Infrastructure & Project Management System - Implementation Plan

## 🎯 Vision

Transform the Terraform Infrastructure Container into a **complete development lifecycle management system** that manages:

1. **Infrastructure** (Azure, Cloudflare, Auth0) ✅ Already working
2. **Code Repositories** (GitHub via Terraform) ➕ To add
3. **Project Tasks** (GitHub Issues/Projects) ➕ To add
4. **Command History** (CLI tracing and audit) ➕ To add
5. **Deployment Tracking** (D1 database) ✅ Already working

**Result**: One portable container managing your entire development ecosystem!

---

## 🏗️ System Architecture

### Current State
```
┌────────────────────────────────────────────┐
│  Terraform Infrastructure Container        │
│  ┌──────────────────────────────────────┐  │
│  │ Cloudflare Worker (V8)               │  │
│  │ - Terraform operations               │  │
│  │ - Infrastructure management          │  │
│  └──────────────────────────────────────┘  │
│  ┌──────────────────────────────────────┐  │
│  │ D1 Database                          │  │
│  │ - deployments                        │  │
│  │ - terraform_operations               │  │
│  │ - managed_resources                  │  │
│  └──────────────────────────────────────┘  │
└────────────────────────────────────────────┘
         ↓ manages
   Azure, Cloudflare, Auth0
```

### Target State
```
┌────────────────────────────────────────────────────────────┐
│  Unified Development Lifecycle Container                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Cloudflare Worker (V8)                               │  │
│  │ - Infrastructure management (Terraform)              │  │
│  │ - Repository management (GitHub provider)            │  │
│  │ - Task management (GitHub API + D1)                  │  │
│  │ - Command tracing (D1 logging)                       │  │
│  │ - Unified dashboard (All data in one view)           │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ Extended D1 Database                                 │  │
│  │ Infrastructure Tracking:                             │  │
│  │ - deployments ✅                                     │  │
│  │ - terraform_operations ✅                            │  │
│  │ - managed_resources ✅                               │  │
│  │                                                      │  │
│  │ Repository & Project Management:                     │  │
│  │ - github_repositories ➕                             │  │
│  │ - project_tasks ➕                                   │  │
│  │ - task_labels ➕                                     │  │
│  │ - milestones ➕                                      │  │
│  │                                                      │  │
│  │ Command & Audit Tracking:                            │  │
│  │ - command_history ➕                                 │  │
│  │ - git_events ➕                                      │  │
│  │ - webhook_events ➕                                  │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────┘
         ↓ manages
   Azure, Cloudflare, Auth0, GitHub
```

---

## 📋 Implementation Phases

### Phase 1: GitHub Provider Integration ⚡ High Priority

**Goal**: Enable Terraform to manage GitHub repositories and projects

**Tasks**:
1. Enable GitHub provider in Terraform
2. Add GitHub token to Cloudflare secrets
3. Create terraform/github.tf for repository management
4. Test repository creation
5. Enable issue and project management

**Deliverables**:
- GitHub provider configured
- This repository managed by Terraform
- Example repo/project created via Terraform

**Estimated Effort**: 2-3 hours
**Dependencies**: GitHub token

---

### Phase 2: Extended D1 Schema 🗄️ High Priority

**Goal**: Expand D1 database to track repositories, tasks, and commands

**Tasks**:
1. Design extended schema
2. Create migration SQL
3. Apply to local and remote D1
4. Update schema.sql
5. Test queries

**New Tables**:
- `github_repositories` - Track repos managed by Terraform
- `project_tasks` - Tasks/issues with status tracking
- `task_labels` - Label taxonomy
- `milestones` - Project milestones
- `command_history` - CLI command audit trail
- `git_events` - Webhook events from GitHub
- `webhook_events` - All webhook activity

**Deliverables**:
- Extended schema.sql
- Migration applied to D1
- Sample data inserted

**Estimated Effort**: 2-3 hours
**Dependencies**: None

---

### Phase 3: Worker API Extensions 🌐 Medium Priority

**Goal**: Add endpoints for repository and task management

**New Endpoints**:

**Repository Management**:
- `GET /api/repos` - List all managed repositories
- `GET /api/repos/:owner/:name` - Get repository details
- `POST /api/repos` - Create new repository (via Terraform)
- `DELETE /api/repos/:owner/:name` - Archive repository

**Task Management**:
- `GET /api/tasks` - List all tasks (GitHub issues)
- `GET /api/tasks/:id` - Get task details
- `POST /api/tasks` - Create new task/issue
- `PATCH /api/tasks/:id` - Update task status
- `GET /api/tasks/dashboard` - Task dashboard view

**Command Tracking**:
- `POST /api/commands/log` - Log command execution
- `GET /api/commands/history` - Get command history
- `GET /api/commands/stats` - Command statistics

**Unified Dashboard**:
- `GET /api/dashboard` - Complete system status
  - Infrastructure health
  - Recent deployments
  - Active tasks
  - Command history
  - Repository status

**Deliverables**:
- Extended src/index.ts with new endpoints
- API documentation
- Example requests/responses

**Estimated Effort**: 4-5 hours
**Dependencies**: Phase 2 (D1 schema)

---

### Phase 4: GitHub Webhook Integration 🔔 Medium Priority

**Goal**: Real-time sync between GitHub events and D1 database

**Tasks**:
1. Create webhook endpoint in Worker
2. Configure webhook in GitHub (via Terraform)
3. Process push, PR, issue events
4. Store events in D1
5. Trigger deployments on push

**Webhook Events to Handle**:
- `push` - Code pushed, log in D1, trigger deployment
- `pull_request` - PR opened/merged, update tasks
- `issues` - Issue created/updated, sync to D1
- `release` - Release published, track version

**Deliverables**:
- Webhook endpoint: POST /api/github/webhook
- Event processing logic
- D1 event storage
- Automated deployment triggers

**Estimated Effort**: 3-4 hours
**Dependencies**: Phase 2, Phase 3

---

### Phase 5: CLI Command Tracing 🖥️ Low Priority

**Goal**: Automatic logging of CLI commands executed in the project

**Approach**:
```bash
# Wrapper function in .envrc or shell config
terraform() {
  local start_time=$(date +%s%3N)

  # Run actual terraform
  command terraform "$@"
  local exit_code=$?

  local end_time=$(date +%s%3N)
  local duration=$((end_time - start_time))

  # Log to Worker
  curl -X POST https://terraform-infrastructure-container.joe-1a2.workers.dev/api/commands/log \
    -H "Content-Type: application/json" \
    -d "{
      \"command\": \"terraform $*\",
      \"exit_code\": $exit_code,
      \"duration_ms\": $duration,
      \"working_directory\": \"$PWD\"
    }"

  return $exit_code
}
```

**Commands to Track**:
- `terraform plan/apply/destroy`
- `wrangler deploy/secret/dev`
- `git commit/push/pull`
- `npm install/run`

**Deliverables**:
- Shell wrapper functions
- Command logging API endpoint
- D1 storage and queries
- Command analytics dashboard

**Estimated Effort**: 2-3 hours
**Dependencies**: Phase 2

---

### Phase 6: Unified Dashboard UI 📊 Low Priority

**Goal**: Web interface for viewing all system state

**Features**:
- Infrastructure status (resources across clouds)
- Active deployments
- Task board (GitHub issues as cards)
- Command history timeline
- Repository health metrics

**Implementation**:
- Could be Cloudflare Pages project
- React/Vue/Svelte frontend
- Calls Worker API endpoints
- Real-time updates via webhooks

**Deliverables**:
- Dashboard UI (Cloudflare Pages)
- Integrated with Worker API
- Real-time status updates

**Estimated Effort**: 8-10 hours
**Dependencies**: All previous phases

---

## 🗄️ Extended D1 Database Schema

### New Tables to Add

```sql
-- GitHub Repositories managed by Terraform
CREATE TABLE github_repositories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    repo_id INTEGER UNIQUE NOT NULL,  -- GitHub repo ID
    repo_name TEXT NOT NULL,
    repo_full_name TEXT UNIQUE NOT NULL,  -- owner/repo
    description TEXT,
    visibility TEXT CHECK(visibility IN ('public', 'private', 'internal')),
    default_branch TEXT DEFAULT 'main',
    has_issues BOOLEAN DEFAULT TRUE,
    has_projects BOOLEAN DEFAULT TRUE,
    has_wiki BOOLEAN DEFAULT FALSE,
    homepage_url TEXT,
    topics JSON,  -- Array of topic strings
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    terraform_managed BOOLEAN DEFAULT TRUE,
    last_deployment_id TEXT,
    FOREIGN KEY (last_deployment_id) REFERENCES deployments(deployment_id)
);

-- Project tasks (synced with GitHub Issues)
CREATE TABLE project_tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER UNIQUE NOT NULL,  -- GitHub issue number
    repo_full_name TEXT NOT NULL,
    title TEXT NOT NULL,
    body TEXT,
    state TEXT CHECK(state IN ('open', 'closed')) DEFAULT 'open',
    status TEXT CHECK(status IN ('todo', 'in_progress', 'review', 'done')) DEFAULT 'todo',
    priority TEXT CHECK(priority IN ('low', 'medium', 'high', 'critical')) DEFAULT 'medium',
    assignee TEXT,
    milestone_title TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    closed_at DATETIME,
    deployment_id TEXT,  -- Link to deployment if task triggers one
    FOREIGN KEY (deployment_id) REFERENCES deployments(deployment_id),
    FOREIGN KEY (repo_full_name) REFERENCES github_repositories(repo_full_name)
);

-- Task labels (many-to-many with tasks)
CREATE TABLE task_labels (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    label_name TEXT NOT NULL,
    label_color TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(task_id, label_name),
    FOREIGN KEY (task_id) REFERENCES project_tasks(task_id)
);

-- Milestones
CREATE TABLE milestones (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    milestone_id INTEGER UNIQUE NOT NULL,  -- GitHub milestone ID
    repo_full_name TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    state TEXT CHECK(state IN ('open', 'closed')) DEFAULT 'open',
    due_date DATE,
    open_issues INTEGER DEFAULT 0,
    closed_issues INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (repo_full_name) REFERENCES github_repositories(repo_full_name)
);

-- Command execution history
CREATE TABLE command_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    command TEXT NOT NULL,
    command_type TEXT CHECK(command_type IN ('terraform', 'git', 'wrangler', 'npm', 'az', 'other')),
    arguments TEXT,
    working_directory TEXT,
    exit_code INTEGER,
    stdout TEXT,
    stderr TEXT,
    duration_ms INTEGER,
    executed_by TEXT,
    executed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    deployment_id TEXT,
    repo_full_name TEXT,
    FOREIGN KEY (deployment_id) REFERENCES deployments(deployment_id),
    FOREIGN KEY (repo_full_name) REFERENCES github_repositories(repo_full_name)
);

-- Git events from webhooks
CREATE TABLE git_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id TEXT UNIQUE NOT NULL,  -- GitHub event ID
    event_type TEXT CHECK(event_type IN ('push', 'pull_request', 'issue', 'release', 'create', 'delete')) NOT NULL,
    repo_full_name TEXT NOT NULL,
    branch TEXT,
    commit_sha TEXT,
    commit_message TEXT,
    author TEXT,
    author_email TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    triggered_deployment BOOLEAN DEFAULT FALSE,
    deployment_id TEXT,
    payload JSON,  -- Full webhook payload
    FOREIGN KEY (deployment_id) REFERENCES deployments(deployment_id),
    FOREIGN KEY (repo_full_name) REFERENCES github_repositories(repo_full_name)
);

-- Webhook event log
CREATE TABLE webhook_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    webhook_id TEXT,
    event_type TEXT NOT NULL,
    source TEXT CHECK(source IN ('github', 'cloudflare', 'azure', 'auth0', 'other')),
    repo_name TEXT,
    payload JSON NOT NULL,
    processed BOOLEAN DEFAULT FALSE,
    processed_at DATETIME,
    error TEXT,
    received_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Project board columns (for Kanban-style tracking)
CREATE TABLE project_columns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    column_id INTEGER UNIQUE NOT NULL,  -- GitHub column ID
    repo_full_name TEXT NOT NULL,
    project_name TEXT NOT NULL,
    column_name TEXT NOT NULL,
    position INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (repo_full_name) REFERENCES github_repositories(repo_full_name)
);

-- Link tasks to project columns (Kanban board state)
CREATE TABLE task_column_assignments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    column_id INTEGER NOT NULL,
    moved_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    moved_by TEXT,
    FOREIGN KEY (task_id) REFERENCES project_tasks(task_id),
    FOREIGN KEY (column_id) REFERENCES project_columns(column_id)
);

-- Indexes for performance
CREATE INDEX idx_github_repos_full_name ON github_repositories(repo_full_name);
CREATE INDEX idx_project_tasks_repo ON project_tasks(repo_full_name);
CREATE INDEX idx_project_tasks_state ON project_tasks(state);
CREATE INDEX idx_project_tasks_status ON project_tasks(status);
CREATE INDEX idx_task_labels_task_id ON task_labels(task_id);
CREATE INDEX idx_command_history_type ON command_history(command_type);
CREATE INDEX idx_command_history_timestamp ON command_history(executed_at DESC);
CREATE INDEX idx_git_events_repo ON git_events(repo_full_name);
CREATE INDEX idx_git_events_type ON git_events(event_type);
CREATE INDEX idx_git_events_timestamp ON git_events(timestamp DESC);
CREATE INDEX idx_webhook_events_processed ON webhook_events(processed);
```

---

## 🔧 Terraform GitHub Provider Configuration

### Step 1: Enable Provider

**File**: `terraform/providers.tf`

```hcl
terraform {
  required_providers {
    # ... existing providers ...

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  token = var.github_token
  owner = "Jobikinobi"  # Your GitHub username/org
}
```

### Step 2: Add GitHub Token

```bash
# Add to Cloudflare secrets
npx wrangler secret put GITHUB_TOKEN

# Add to terraform/.envrc
export TF_VAR_github_token="your_github_token_here"
```

### Step 3: Manage This Repository

**File**: `terraform/github-repos.tf` (new)

```hcl
# Manage the terraform-infrastructure-container repo itself!
resource "github_repository" "terraform_container" {
  name        = "terraform-infrastructure-container"
  description = "Portable, Docker-free Terraform infrastructure management with Cloudflare Workers"

  visibility = "public"

  has_issues   = true
  has_projects = true
  has_wiki     = true

  topics = [
    "terraform",
    "cloudflare",
    "workers",
    "infrastructure-as-code",
    "docker-free",
    "multicloud",
    "azure",
    "auth0",
    "portable"
  ]

  allow_auto_merge       = true
  allow_merge_commit     = true
  allow_squash_merge     = true
  delete_branch_on_merge = true

  vulnerability_alerts = true

  template {
    include_all_branches = false
  }
}

# Branch protection for main
resource "github_branch_protection" "main" {
  repository_id = github_repository.terraform_container.node_id
  pattern       = "main"

  enforce_admins = false

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = false
    required_approving_review_count = 0  # Single developer, but can change
  }

  # Require status checks before merging
  required_status_checks {
    strict   = true
    contexts = []  # Add when CI/CD is set up
  }
}

# Project board for task management
resource "github_repository_project" "infrastructure_tasks" {
  name       = "Infrastructure Management"
  repository = github_repository.terraform_container.name
  body       = "Track infrastructure deployments, features, and improvements"
}

# Project columns (Kanban board)
resource "github_project_column" "todo" {
  project_id = github_repository_project.infrastructure_tasks.id
  name       = "To Do"
}

resource "github_project_column" "in_progress" {
  project_id = github_repository_project.infrastructure_tasks.id
  name       = "In Progress"
}

resource "github_project_column" "review" {
  project_id = github_repository_project.infrastructure_tasks.id
  name       = "Review"
}

resource "github_project_column" "done" {
  project_id = github_repository_project.infrastructure_tasks.id
  name       = "Done"
}

# Issue labels
resource "github_issue_labels" "terraform_container" {
  repository = github_repository.terraform_container.name

  label {
    name        = "infrastructure"
    color       = "0052CC"
    description = "Infrastructure changes"
  }

  label {
    name        = "deployment"
    color       = "1D76DB"
    description = "Deployment related"
  }

  label {
    name        = "terraform"
    color       = "5319E7"
    description = "Terraform configuration"
  }

  label {
    name        = "cloudflare"
    color       = "F38020"
    description = "Cloudflare resources"
  }

  label {
    name        = "azure"
    color       = "0089D6"
    description = "Azure resources"
  }

  label {
    name        = "auth0"
    color       = "EB5424"
    description = "Auth0 configuration"
  }

  label {
    name        = "priority:high"
    color       = "D93F0B"
    description = "High priority"
  }

  label {
    name        = "priority:low"
    color       = "0E8A16"
    description = "Low priority"
  }
}

# Webhook for deployment automation
resource "github_repository_webhook" "deploy_on_push" {
  repository = github_repository.terraform_container.name

  configuration {
    url          = "https://terraform-infrastructure-container.joe-1a2.workers.dev/api/github/webhook"
    content_type = "json"
    insecure_ssl = false
    secret       = var.github_webhook_secret
  }

  events = ["push", "pull_request", "issues", "release"]
  active = true
}

# GitHub Actions secrets (for CI/CD)
resource "github_actions_secret" "cloudflare_api_token" {
  repository       = github_repository.terraform_container.name
  secret_name      = "CLOUDFLARE_API_TOKEN"
  plaintext_value  = var.cloudflare_api_token
}

resource "github_actions_secret" "azure_credentials" {
  repository      = github_repository.terraform_container.name
  secret_name     = "AZURE_CREDENTIALS"
  plaintext_value = jsonencode({
    clientId       = var.azure_client_id
    clientSecret   = var.azure_client_secret
    subscriptionId = var.azure_subscription_id
    tenantId       = var.azure_tenant_id
  })
}
```

---

## 🌐 Worker API Design

### Extended API Structure

```typescript
// src/github-api.ts (new file)

import { Context } from 'hono';

/**
 * Repository Management Endpoints
 */
export async function listRepositories(c: Context) {
  const repos = await c.env.DEPLOYMENT_DB.prepare(
    'SELECT * FROM github_repositories ORDER BY created_at DESC'
  ).all();

  return c.json({ repositories: repos.results });
}

export async function createRepository(c: Context) {
  const { name, description, visibility } = await c.req.json();

  // Call GitHub API to create repo
  const response = await fetch('https://api.github.com/user/repos', {
    method: 'POST',
    headers: {
      'Authorization': `token ${c.env.GITHUB_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ name, description, private: visibility === 'private' })
  });

  const repo = await response.json();

  // Store in D1
  await c.env.DEPLOYMENT_DB.prepare(
    'INSERT INTO github_repositories (repo_id, repo_name, repo_full_name, description, visibility) VALUES (?, ?, ?, ?, ?)'
  ).bind(repo.id, repo.name, repo.full_name, description, visibility).run();

  return c.json({ repository: repo });
}

/**
 * Task Management Endpoints
 */
export async function listTasks(c: Context) {
  const status = c.req.query('status') || 'open';
  const repo = c.req.query('repo');

  let query = 'SELECT * FROM project_tasks WHERE state = ?';
  const params = [status];

  if (repo) {
    query += ' AND repo_full_name = ?';
    params.push(repo);
  }

  query += ' ORDER BY created_at DESC';

  const tasks = await c.env.DEPLOYMENT_DB.prepare(query)
    .bind(...params)
    .all();

  return c.json({ tasks: tasks.results });
}

export async function createTask(c: Context) {
  const { repo, title, body, labels, assignee } = await c.req.json();

  // Create GitHub issue
  const response = await fetch(`https://api.github.com/repos/${repo}/issues`, {
    method: 'POST',
    headers: {
      'Authorization': `token ${c.env.GITHUB_TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ title, body, labels, assignee })
  });

  const issue = await response.json();

  // Store in D1
  await c.env.DEPLOYMENT_DB.prepare(
    'INSERT INTO project_tasks (task_id, repo_full_name, title, body, assignee) VALUES (?, ?, ?, ?, ?)'
  ).bind(issue.number, repo, title, body, assignee).run();

  // Add labels
  if (labels && labels.length > 0) {
    for (const label of labels) {
      await c.env.DEPLOYMENT_DB.prepare(
        'INSERT INTO task_labels (task_id, label_name) VALUES (?, ?)'
      ).bind(issue.number, label).run();
    }
  }

  return c.json({ task: issue });
}

export async function updateTaskStatus(c: Context) {
  const { id } = c.req.param();
  const { status, state } = await c.req.json();

  // Update in D1
  await c.env.DEPLOYMENT_DB.prepare(
    'UPDATE project_tasks SET status = ?, state = ?, updated_at = ? WHERE task_id = ?'
  ).bind(status, state, new Date().toISOString(), parseInt(id)).run();

  // Update in GitHub if state changed
  if (state) {
    await fetch(`https://api.github.com/repos/Jobikinobi/terraform-infrastructure-container/issues/${id}`, {
      method: 'PATCH',
      headers: {
        'Authorization': `token ${c.env.GITHUB_TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ state })
    });
  }

  return c.json({ updated: true });
}

/**
 * Command Tracking Endpoints
 */
export async function logCommand(c: Context) {
  const { command, command_type, exit_code, duration_ms, working_directory, stdout, stderr } = await c.req.json();

  const result = await c.env.DEPLOYMENT_DB.prepare(
    'INSERT INTO command_history (command, command_type, exit_code, duration_ms, working_directory, stdout, stderr, executed_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
  ).bind(
    command,
    command_type,
    exit_code,
    duration_ms,
    working_directory,
    stdout,
    stderr,
    new Date().toISOString()
  ).run();

  return c.json({ logged: true, id: result.meta.last_row_id });
}

export async function getCommandHistory(c: Context) {
  const limit = parseInt(c.req.query('limit') || '50');
  const command_type = c.req.query('type');

  let query = 'SELECT * FROM command_history';
  const params = [];

  if (command_type) {
    query += ' WHERE command_type = ?';
    params.push(command_type);
  }

  query += ' ORDER BY executed_at DESC LIMIT ?';
  params.push(limit);

  const history = await c.env.DEPLOYMENT_DB.prepare(query)
    .bind(...params)
    .all();

  return c.json({ history: history.results });
}

/**
 * Webhook Handler
 */
export async function handleGitHubWebhook(c: Context) {
  const event = c.req.header('X-GitHub-Event');
  const payload = await c.req.json();

  // Log webhook event
  await c.env.DEPLOYMENT_DB.prepare(
    'INSERT INTO webhook_events (event_type, source, repo_name, payload, received_at) VALUES (?, ?, ?, ?, ?)'
  ).bind(event, 'github', payload.repository?.full_name, JSON.stringify(payload), new Date().toISOString()).run();

  // Handle different event types
  switch (event) {
    case 'push':
      await handlePushEvent(c, payload);
      break;
    case 'issues':
      await handleIssueEvent(c, payload);
      break;
    case 'pull_request':
      await handlePREvent(c, payload);
      break;
    // ... more events
  }

  return c.json({ processed: true });
}

async function handlePushEvent(c: Context, payload: any) {
  // Log git event
  await c.env.DEPLOYMENT_DB.prepare(
    'INSERT INTO git_events (event_id, event_type, repo_full_name, branch, commit_sha, commit_message, author, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
  ).bind(
    payload.head_commit.id,
    'push',
    payload.repository.full_name,
    payload.ref.replace('refs/heads/', ''),
    payload.head_commit.id,
    payload.head_commit.message,
    payload.head_commit.author.name,
    new Date().toISOString()
  ).run();

  // Auto-deploy if push to main
  if (payload.ref === 'refs/heads/main') {
    // Trigger deployment
    // ... deployment logic
  }
}

/**
 * Unified Dashboard
 */
export async function getDashboard(c: Context) {
  // Parallel queries for all data
  const [
    infrastructureStats,
    recentDeployments,
    activeTasks,
    commandHistory,
    recentGitEvents
  ] = await Promise.all([
    // Infrastructure stats
    c.env.DEPLOYMENT_DB.prepare(
      'SELECT provider, COUNT(*) as count FROM managed_resources WHERE status = "active" GROUP BY provider'
    ).all(),

    // Recent deployments
    c.env.DEPLOYMENT_DB.prepare(
      'SELECT * FROM deployments ORDER BY started_at DESC LIMIT 10'
    ).all(),

    // Active tasks
    c.env.DEPLOYMENT_DB.prepare(
      'SELECT * FROM project_tasks WHERE state = "open" ORDER BY priority DESC, created_at DESC'
    ).all(),

    // Command history
    c.env.DEPLOYMENT_DB.prepare(
      'SELECT command, command_type, exit_code, duration_ms, executed_at FROM command_history ORDER BY executed_at DESC LIMIT 20'
    ).all(),

    // Recent git events
    c.env.DEPLOYMENT_DB.prepare(
      'SELECT * FROM git_events ORDER BY timestamp DESC LIMIT 15'
    ).all()
  ]);

  return c.json({
    infrastructure: {
      resources_by_provider: infrastructureStats.results,
      total_resources: infrastructureStats.results.reduce((sum, r) => sum + r.count, 0)
    },
    deployments: {
      recent: recentDeployments.results,
      in_progress: recentDeployments.results.filter(d => d.status === 'in_progress').length
    },
    tasks: {
      active: activeTasks.results,
      open_count: activeTasks.results.length,
      by_priority: {
        high: activeTasks.results.filter(t => t.priority === 'high').length,
        medium: activeTasks.results.filter(t => t.priority === 'medium').length,
        low: activeTasks.results.filter(t => t.priority === 'low').length
      }
    },
    commands: {
      recent: commandHistory.results,
      by_type: {} // Could aggregate by type
    },
    git_activity: {
      recent_events: recentGitEvents.results
    },
    system: {
      worker_version: '1.0.0',
      environment: c.env.ENVIRONMENT,
      uptime: 'always_on',
      edge_deployment: true
    }
  });
}
```

---

## 📱 CLI Integration (Command Tracing)

### Shell Wrapper Functions

**File**: `scripts/cli-wrapper.sh` (new)

```bash
#!/bin/bash
# CLI Command Wrapper with Auto-logging
# Source this in your shell: source scripts/cli-wrapper.sh

WORKER_URL="https://terraform-infrastructure-container.joe-1a2.workers.dev"

# Wrapper for terraform commands
terraform() {
  local start_time=$(date +%s%3N)
  local stdout_file=$(mktemp)
  local stderr_file=$(mktemp)

  # Run actual terraform, capturing output
  command terraform "$@" > "$stdout_file" 2> "$stderr_file"
  local exit_code=$?

  local end_time=$(date +%s%3N)
  local duration=$((end_time - start_time))

  # Display output
  cat "$stdout_file"
  cat "$stderr_file" >&2

  # Log to Worker asynchronously
  (
    curl -s -X POST "$WORKER_URL/api/commands/log" \
      -H "Content-Type: application/json" \
      -d "{
        \"command\": \"terraform $*\",
        \"command_type\": \"terraform\",
        \"exit_code\": $exit_code,
        \"duration_ms\": $duration,
        \"working_directory\": \"$PWD\",
        \"stdout\": $(cat "$stdout_file" | jq -R -s .),
        \"stderr\": $(cat "$stderr_file" | jq -R -s .)
      }" &
  )

  rm "$stdout_file" "$stderr_file"
  return $exit_code
}

# Wrapper for wrangler commands
wrangler() {
  local start_time=$(date +%s%3N)

  command wrangler "$@"
  local exit_code=$?

  local end_time=$(date +%s%3N)
  local duration=$((end_time - start_time))

  # Log to Worker
  (
    curl -s -X POST "$WORKER_URL/api/commands/log" \
      -H "Content-Type: application/json" \
      -d "{
        \"command\": \"wrangler $*\",
        \"command_type\": \"wrangler\",
        \"exit_code\": $exit_code,
        \"duration_ms\": $duration,
        \"working_directory\": \"$PWD\"
      }" &
  )

  return $exit_code
}

# Wrapper for git commands
git() {
  local start_time=$(date +%s%3N)

  command git "$@"
  local exit_code=$?

  local end_time=$(date +%s%3N)
  local duration=$((end_time - start_time))

  # Log significant git commands
  if [[ "$1" == "commit" || "$1" == "push" || "$1" == "pull" || "$1" == "merge" ]]; then
    (
      curl -s -X POST "$WORKER_URL/api/commands/log" \
        -H "Content-Type: application/json" \
        -d "{
          \"command\": \"git $*\",
          \"command_type\": \"git\",
          \"exit_code\": $exit_code,
          \"duration_ms\": $duration,
          \"working_directory\": \"$PWD\"
        }" &
    )
  fi

  return $exit_code
}

echo "✅ CLI command tracing enabled"
echo "Commands will be logged to: $WORKER_URL"
```

---

## 🎯 Unified Dashboard API Response

### GET /api/dashboard Example

```json
{
  "infrastructure": {
    "resources_by_provider": [
      { "provider": "azure", "count": 45 },
      { "provider": "cloudflare", "count": 38 },
      { "provider": "auth0", "count": 10 }
    ],
    "total_resources": 93,
    "last_deployment": {
      "id": "deploy-2025-11-26-001",
      "status": "success",
      "resources_created": 1,
      "started_at": "2025-11-26T10:30:00Z"
    }
  },

  "repositories": {
    "total": 1,
    "managed": [
      {
        "name": "terraform-infrastructure-container",
        "full_name": "Jobikinobi/terraform-infrastructure-container",
        "visibility": "public",
        "open_issues": 3,
        "last_push": "2025-11-26T15:45:00Z"
      }
    ]
  },

  "tasks": {
    "open_count": 12,
    "active": [
      {
        "id": 1,
        "title": "Implement GitHub provider",
        "status": "in_progress",
        "priority": "high",
        "assignee": "joe@theholetruth.org",
        "labels": ["infrastructure", "terraform"]
      },
      {
        "id": 2,
        "title": "Add VPC connector to Azure",
        "status": "todo",
        "priority": "medium",
        "labels": ["cloudflare", "azure", "vpc"]
      }
    ],
    "by_priority": {
      "high": 3,
      "medium": 7,
      "low": 2
    },
    "by_status": {
      "todo": 5,
      "in_progress": 4,
      "review": 2,
      "done": 15
    }
  },

  "commands": {
    "recent": [
      {
        "command": "terraform apply",
        "exit_code": 0,
        "duration_ms": 45231,
        "executed_at": "2025-11-26T15:30:00Z"
      },
      {
        "command": "wrangler deploy",
        "exit_code": 0,
        "duration_ms": 6090,
        "executed_at": "2025-11-26T15:25:00Z"
      },
      {
        "command": "git push",
        "exit_code": 0,
        "duration_ms": 2345,
        "executed_at": "2025-11-26T15:20:00Z"
      }
    ],
    "stats": {
      "total_commands_today": 47,
      "terraform_runs": 8,
      "deployments": 3,
      "git_operations": 15
    }
  },

  "git_activity": {
    "recent_events": [
      {
        "type": "push",
        "repo": "terraform-infrastructure-container",
        "branch": "main",
        "author": "joe@theholetruth.org",
        "message": "Add unified system plan",
        "timestamp": "2025-11-26T15:45:00Z"
      }
    ],
    "commits_today": 12,
    "open_prs": 0
  },

  "system": {
    "worker_version": "1.0.0",
    "environment": "production",
    "uptime": "always_on",
    "edge_deployment": true,
    "features": {
      "infrastructure_management": true,
      "repository_management": true,
      "task_tracking": true,
      "command_history": true,
      "vpc_ready": true
    }
  }
}
```

---

## 🚀 Implementation Roadmap

### Week 1: Foundation

**Day 1-2: GitHub Provider**
- [ ] Uncomment GitHub provider in providers.tf
- [ ] Add GitHub token to secrets
- [ ] Create terraform/github.tf
- [ ] Test managing this repository
- [ ] Apply and verify

**Day 3-4: D1 Schema Extension**
- [ ] Design extended schema
- [ ] Create migration SQL file
- [ ] Test locally
- [ ] Apply to remote D1
- [ ] Verify tables and indexes

**Day 5: Initial API Endpoints**
- [ ] Create src/github-api.ts
- [ ] Add repository list endpoint
- [ ] Add task list endpoint
- [ ] Test endpoints locally
- [ ] Deploy and verify

### Week 2: Integration

**Day 1-2: Task Management**
- [ ] Implement task creation endpoint
- [ ] Implement task update endpoint
- [ ] GitHub issue sync logic
- [ ] Test create/update/close workflow

**Day 3-4: Command Tracking**
- [ ] Create CLI wrapper script
- [ ] Add command logging endpoint
- [ ] Test command capture
- [ ] Verify D1 storage

**Day 5: Webhooks**
- [ ] Create webhook endpoint
- [ ] Configure webhook in GitHub (via Terraform)
- [ ] Test push event handling
- [ ] Test issue event handling

### Week 3: Dashboard & Polish

**Day 1-3: Unified Dashboard API**
- [ ] Implement dashboard endpoint
- [ ] Aggregate all data sources
- [ ] Optimize queries
- [ ] Test response times

**Day 4-5: Documentation & Testing**
- [ ] Update CLAUDE.md
- [ ] Create API documentation
- [ ] End-to-end testing
- [ ] Performance optimization

---

## 🎯 Success Criteria

### Phase 1 Complete When:
- ✅ GitHub provider managing this repository
- ✅ Can create issues via Terraform
- ✅ Project board exists with columns
- ✅ All tracked in D1

### Phase 2 Complete When:
- ✅ Extended D1 schema deployed
- ✅ Can query repos, tasks, commands
- ✅ All relationships working

### Phase 3 Complete When:
- ✅ Worker API has all endpoints
- ✅ Can CRUD repositories and tasks
- ✅ Dashboard returns complete data

### Phase 4 Complete When:
- ✅ Webhooks receiving GitHub events
- ✅ Auto-deployment on push working
- ✅ Task sync bidirectional

### Phase 5 Complete When:
- ✅ Commands auto-logged
- ✅ Audit trail complete
- ✅ Analytics available

### Complete System When:
- ✅ One command shows everything: `curl .../api/dashboard`
- ✅ Infrastructure + code + tasks + history all unified
- ✅ Fully portable (clone → works)
- ✅ Template ready for other projects

---

## 💡 Benefits of Unified System

### For Development

**Single Source of Truth**:
- All infrastructure in one place
- All tasks visible
- All commands logged
- Complete audit trail

**Better Workflow**:
```bash
# Instead of:
terraform apply        # (where did this run?)
# Open GitHub
# Create issue manually
# Check deployment status separately
# Search terminal history

# You get:
terraform apply        # (auto-logged to D1)
# Worker creates GitHub issue automatically
# Dashboard shows deployment + task in one view
# Complete history queryable via API
```

### For Operations

**Visibility**:
- What infrastructure exists?
- What tasks are in progress?
- What commands ran recently?
- What changed and when?

**Traceability**:
- Link tasks to deployments
- Link deployments to git commits
- Link commands to outcomes
- Complete chain of causality

### For Compliance

**Audit Trail**:
- Every command logged
- Every deployment tracked
- Every change recorded
- Immutable D1 history

**Reporting**:
- Who did what when?
- What infrastructure exists?
- What changes were made?
- All queryable via SQL

---

## 🎨 Example Workflows

### Workflow 1: Create New Project

```bash
# 1. Create task
curl -X POST $WORKER_URL/api/tasks \
  -d '{
    "repo": "Jobikinobi/terraform-infrastructure-container",
    "title": "Add VPC connector to Azure",
    "body": "Deploy cloudflared to Azure Container Instance",
    "labels": ["infrastructure", "azure", "vpc"],
    "priority": "high"
  }'

# 2. Work on it (auto-logged)
terraform plan
terraform apply

# 3. Push changes (webhook triggers)
git commit -m "Add VPC connector"
git push

# 4. Worker automatically:
#    - Logs git event
#    - Links commit to task
#    - Updates deployment tracking
#    - Comments on GitHub issue with deployment status

# 5. Check dashboard
curl $WORKER_URL/api/dashboard
# See task + deployment + git event all linked!
```

### Workflow 2: Infrastructure Change

```bash
# 1. Modify Terraform
vim terraform/cloudflare.tf

# 2. Plan (auto-logged)
terraform plan

# 3. Create task automatically from plan
# Worker sees terraform plan command
# Parses output: "Plan: 5 to add, 2 to change"
# Creates GitHub issue: "Deploy: 5 new resources"
# Links to deployment in D1

# 4. Apply (auto-logged)
terraform apply

# 5. Worker updates:
#    - Deployment status in D1
#    - GitHub issue with results
#    - Command history
#    - Resource inventory
```

### Workflow 3: Query Everything

```bash
# Single API call shows complete system state
curl $WORKER_URL/api/dashboard | jq

# Get specific views
curl $WORKER_URL/api/repos                    # All repositories
curl $WORKER_URL/api/tasks?status=in_progress # Active tasks
curl $WORKER_URL/api/commands/history         # Recent commands
curl $WORKER_URL/api/deployments              # Deployment history
```

---

## 🔮 Future Possibilities

### Advanced Features

**1. AI-Powered Task Generation**
```javascript
// Worker analyzes terraform plan output
// Automatically creates tasks for each resource change
// Assigns priorities based on risk
// Links to documentation
```

**2. Predictive Analytics**
```javascript
// Based on command history:
// "You usually run terraform apply after plan"
// "This deployment took 45s last time"
// "Similar changes failed 2/5 times previously"
```

**3. Automated Rollback**
```javascript
// Deployment fails
// Worker automatically:
// - Runs terraform destroy on failed resources
// - Reverts to previous state
// - Creates incident issue
// - Notifies team
```

**4. Cost Tracking**
```javascript
// Track costs in D1:
// - Resource costs from Azure/Cloudflare APIs
// - Link to deployments
// - Alert on budget exceeded
// - Automatic shutdown of expensive resources
```

**5. Multi-Project Dashboard**
```javascript
// Manage multiple HOLE Foundation projects
// Each in its own container
// Unified dashboard across all
// Central command center
```

---

## 📊 Data Model Relationships

```
github_repositories
    ├─── project_tasks (issues)
    │       ├─── task_labels
    │       ├─── task_column_assignments
    │       └─── → deployments (triggered by)
    │
    ├─── milestones
    │       └─── project_tasks (linked)
    │
    ├─── git_events (commits, pushes)
    │       └─── → deployments (triggered)
    │
    └─── command_history
            └─── → deployments (part of)

deployments
    ├─── terraform_operations
    ├─── managed_resources
    ├─── state_snapshots
    ├─── deployment_logs
    └─── ← project_tasks (linked)

webhook_events
    └─── → git_events (creates)
```

---

## 🎯 Next Steps

### To Begin Implementation:

1. **Review this plan** - Ensure it aligns with vision
2. **Prioritize phases** - Which to implement first?
3. **Gather credentials** - GitHub token needed
4. **Start Phase 1** - Enable GitHub provider
5. **Iterate** - Build incrementally, test frequently

### Questions to Consider:

- Should we manage ALL your GitHub repos or just this one?
- Do you want automatic deployment on git push?
- Should command logging be optional or always-on?
- Public dashboard or auth-protected?
- Multi-project support from day one?

---

## 🌟 The Big Picture

This transforms your container from:
**"Terraform infrastructure manager"**

To:
**"Complete development lifecycle orchestrator"**

Managing:
- ☁️ Cloud infrastructure
- 📦 Code repositories
- ✅ Project tasks
- 🖥️ Command execution
- 📊 Complete audit trail

All in:
- 🚀 One Cloudflare Worker
- 🗄️ One D1 database
- 🌍 Deployed globally
- 📱 Accessible via API
- 🔐 Secure and portable

**This is the future of development environment management!**

---

**Ready to start implementing?** Which phase should we tackle first?
