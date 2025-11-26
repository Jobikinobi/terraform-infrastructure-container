-- Terraform Infrastructure Container - D1 Database Schema
-- Tracks deployments, Terraform operations, and resource state

-- Deployments table
CREATE TABLE IF NOT EXISTS deployments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    deployment_id TEXT UNIQUE NOT NULL,
    environment TEXT NOT NULL,
    git_commit TEXT,
    git_branch TEXT,
    started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    status TEXT CHECK(status IN ('pending', 'in_progress', 'success', 'failed', 'rolled_back')) DEFAULT 'pending',
    terraform_version TEXT,
    deployed_by TEXT,
    notes TEXT
);

-- Terraform operations (plan, apply, destroy)
CREATE TABLE IF NOT EXISTS terraform_operations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    deployment_id TEXT NOT NULL,
    operation_type TEXT CHECK(operation_type IN ('init', 'plan', 'apply', 'destroy', 'import')) NOT NULL,
    started_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    status TEXT CHECK(status IN ('pending', 'running', 'success', 'failed')) DEFAULT 'pending',
    resources_added INTEGER DEFAULT 0,
    resources_changed INTEGER DEFAULT 0,
    resources_destroyed INTEGER DEFAULT 0,
    output_log TEXT,
    error_log TEXT,
    FOREIGN KEY (deployment_id) REFERENCES deployments(deployment_id)
);

-- Resource inventory (what's currently managed)
CREATE TABLE IF NOT EXISTS managed_resources (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    resource_type TEXT NOT NULL,
    resource_name TEXT NOT NULL,
    resource_id TEXT,
    provider TEXT CHECK(provider IN ('azure', 'cloudflare', 'auth0', 'aws', 'google', 'github')) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_deployment_id TEXT,
    status TEXT CHECK(status IN ('active', 'destroying', 'destroyed', 'failed')) DEFAULT 'active',
    attributes JSON,
    UNIQUE(provider, resource_type, resource_name),
    FOREIGN KEY (last_deployment_id) REFERENCES deployments(deployment_id)
);

-- State snapshots (for tracking state changes over time)
CREATE TABLE IF NOT EXISTS state_snapshots (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    deployment_id TEXT NOT NULL,
    snapshot_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    state_version INTEGER,
    serial INTEGER,
    lineage TEXT,
    resource_count INTEGER,
    -- State stored in R2, this is just metadata
    r2_key TEXT NOT NULL,
    size_bytes INTEGER,
    checksum TEXT,
    FOREIGN KEY (deployment_id) REFERENCES deployments(deployment_id)
);

-- Deployment logs
CREATE TABLE IF NOT EXISTS deployment_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    deployment_id TEXT NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    level TEXT CHECK(level IN ('debug', 'info', 'warning', 'error')) DEFAULT 'info',
    message TEXT NOT NULL,
    context JSON,
    FOREIGN KEY (deployment_id) REFERENCES deployments(deployment_id)
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_deployments_status ON deployments(status);
CREATE INDEX IF NOT EXISTS idx_deployments_environment ON deployments(environment);
CREATE INDEX IF NOT EXISTS idx_deployments_started_at ON deployments(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_terraform_operations_deployment ON terraform_operations(deployment_id);
CREATE INDEX IF NOT EXISTS idx_terraform_operations_status ON terraform_operations(status);
CREATE INDEX IF NOT EXISTS idx_managed_resources_provider ON managed_resources(provider);
CREATE INDEX IF NOT EXISTS idx_managed_resources_status ON managed_resources(status);
CREATE INDEX IF NOT EXISTS idx_deployment_logs_deployment ON deployment_logs(deployment_id);
CREATE INDEX IF NOT EXISTS idx_deployment_logs_level ON deployment_logs(level);
