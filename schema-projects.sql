-- Project Management Schema Extension
-- Enables infrastructure-as-a-service for all HOLE Foundation projects

-- Projects consuming this infrastructure service
CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT UNIQUE NOT NULL,
    project_name TEXT NOT NULL,
    display_name TEXT,
    description TEXT,
    github_repo TEXT,
    homepage_url TEXT,
    status TEXT CHECK(status IN ('active', 'archived', 'development')) DEFAULT 'development',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (github_repo) REFERENCES github_repositories(repo_full_name)
);

-- Infrastructure resources per project
CREATE TABLE IF NOT EXISTS project_resources (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT NOT NULL,
    resource_type TEXT CHECK(resource_type IN ('auth0', 'database', 'storage', 'compute', 'dns', 'kv', 'r2', 'd1')) NOT NULL,
    resource_provider TEXT,
    resource_id TEXT NOT NULL,
    resource_name TEXT,
    config JSON,
    provisioned_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    status TEXT CHECK(status IN ('active', 'provisioning', 'failed', 'deprovisioned')) DEFAULT 'active',
    cost_monthly REAL DEFAULT 0,
    uses_credits BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

-- Project environments (dev, staging, production)
CREATE TABLE IF NOT EXISTS project_environments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id TEXT NOT NULL,
    environment TEXT CHECK(environment IN ('development', 'staging', 'production')) NOT NULL,
    url TEXT,
    auth0_client_id TEXT,
    database_url TEXT,
    storage_config JSON,
    cloudflare_config JSON,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, environment),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

-- Cloud credit usage tracking
CREATE TABLE IF NOT EXISTS credit_usage (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    provider TEXT CHECK(provider IN ('azure', 'aws', 'gcp')) NOT NULL,
    project_id TEXT,
    resource_type TEXT,
    amount_usd REAL NOT NULL,
    credits_used REAL DEFAULT 0,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_github_repo ON projects(github_repo);
CREATE INDEX IF NOT EXISTS idx_project_resources_project ON project_resources(project_id);
CREATE INDEX IF NOT EXISTS idx_project_resources_type ON project_resources(resource_type);
CREATE INDEX IF NOT EXISTS idx_project_resources_provider ON project_resources(resource_provider);
CREATE INDEX IF NOT EXISTS idx_project_environments_project ON project_environments(project_id);
CREATE INDEX IF NOT EXISTS idx_credit_usage_provider ON credit_usage(provider);
CREATE INDEX IF NOT EXISTS idx_credit_usage_project ON credit_usage(project_id);

-- Initial projects will be registered via API when they first call the service
