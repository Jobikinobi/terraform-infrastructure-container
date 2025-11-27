-- GitHub Integration Schema Extension
-- Adds tables for repository management, task tracking, and webhook events

-- GitHub repositories managed by this system
CREATE TABLE IF NOT EXISTS github_repositories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    repo_id INTEGER UNIQUE NOT NULL,
    repo_name TEXT NOT NULL,
    repo_full_name TEXT UNIQUE NOT NULL,
    description TEXT,
    visibility TEXT CHECK(visibility IN ('public', 'private', 'internal')),
    default_branch TEXT DEFAULT 'main',
    homepage_url TEXT,
    topics JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    terraform_managed BOOLEAN DEFAULT TRUE
);

-- Webhook events from GitHub
CREATE TABLE IF NOT EXISTS webhook_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id TEXT UNIQUE,
    event_type TEXT NOT NULL,
    source TEXT CHECK(source IN ('github', 'cloudflare', 'azure', 'other')) DEFAULT 'github',
    repo_full_name TEXT,
    payload JSON NOT NULL,
    processed BOOLEAN DEFAULT FALSE,
    processed_at DATETIME,
    error TEXT,
    received_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (repo_full_name) REFERENCES github_repositories(repo_full_name)
);

-- Git events (commits, pushes, PRs)
CREATE TABLE IF NOT EXISTS git_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    event_id TEXT UNIQUE NOT NULL,
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
    payload JSON,
    FOREIGN KEY (deployment_id) REFERENCES deployments(deployment_id),
    FOREIGN KEY (repo_full_name) REFERENCES github_repositories(repo_full_name)
);

-- Project tasks (GitHub issues)
CREATE TABLE IF NOT EXISTS project_tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER UNIQUE NOT NULL,
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
    deployment_id TEXT,
    FOREIGN KEY (deployment_id) REFERENCES deployments(deployment_id),
    FOREIGN KEY (repo_full_name) REFERENCES github_repositories(repo_full_name)
);

-- Task labels
CREATE TABLE IF NOT EXISTS task_labels (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    label_name TEXT NOT NULL,
    label_color TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(task_id, label_name),
    FOREIGN KEY (task_id) REFERENCES project_tasks(task_id)
);

-- Command execution history
CREATE TABLE IF NOT EXISTS command_history (
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

-- Indexes for GitHub tables
CREATE INDEX IF NOT EXISTS idx_github_repos_full_name ON github_repositories(repo_full_name);
CREATE INDEX IF NOT EXISTS idx_webhook_events_processed ON webhook_events(processed);
CREATE INDEX IF NOT EXISTS idx_webhook_events_type ON webhook_events(event_type);
CREATE INDEX IF NOT EXISTS idx_webhook_events_received ON webhook_events(received_at DESC);
CREATE INDEX IF NOT EXISTS idx_git_events_repo ON git_events(repo_full_name);
CREATE INDEX IF NOT EXISTS idx_git_events_type ON git_events(event_type);
CREATE INDEX IF NOT EXISTS idx_git_events_timestamp ON git_events(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_project_tasks_repo ON project_tasks(repo_full_name);
CREATE INDEX IF NOT EXISTS idx_project_tasks_state ON project_tasks(state);
CREATE INDEX IF NOT EXISTS idx_project_tasks_status ON project_tasks(status);
CREATE INDEX IF NOT EXISTS idx_project_tasks_priority ON project_tasks(priority);
CREATE INDEX IF NOT EXISTS idx_task_labels_task_id ON task_labels(task_id);
CREATE INDEX IF NOT EXISTS idx_command_history_type ON command_history(command_type);
CREATE INDEX IF NOT EXISTS idx_command_history_timestamp ON command_history(executed_at DESC);
