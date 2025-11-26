# Cloudflare Workers, KV Namespaces, and D1 Databases
# Edge computing, key-value storage, and serverless SQL
# Account: The HOLE Foundation (1a25a792e801e687b9fe4932030cf6a6)

# ===========================================================================
# KV NAMESPACES
# ===========================================================================

# Member & Visitor Management
resource "cloudflare_workers_kv_namespace" "members_kv" {
  account_id = var.cloudflare_account_id
  title      = "MEMBERS_KV"
}

resource "cloudflare_workers_kv_namespace" "members_kv_preview" {
  account_id = var.cloudflare_account_id
  title      = "MEMBERS_KV_PREVIEW_preview"
}

resource "cloudflare_workers_kv_namespace" "visitor_kv" {
  account_id = var.cloudflare_account_id
  title      = "VISITOR_KV"
}

resource "cloudflare_workers_kv_namespace" "visitor_kv_preview" {
  account_id = var.cloudflare_account_id
  title      = "VISITOR_KV_PREVIEW_preview"
}

resource "cloudflare_workers_kv_namespace" "visitor_logs" {
  account_id = var.cloudflare_account_id
  title      = "VISITOR_LOGS"
}

resource "cloudflare_workers_kv_namespace" "theholetruth_visitor_logs" {
  account_id = var.cloudflare_account_id
  title      = "theholetruth-visitor-logs"
}

# Analytics & Tracking
resource "cloudflare_workers_kv_namespace" "analytics_kv" {
  account_id = var.cloudflare_account_id
  title      = "ANALYTICS_KV"
}

resource "cloudflare_workers_kv_namespace" "analytics_kv_preview" {
  account_id = var.cloudflare_account_id
  title      = "ANALYTICS_KV_PREVIEW_preview"
}

resource "cloudflare_workers_kv_namespace" "email_tracking_kv" {
  account_id = var.cloudflare_account_id
  title      = "EMAIL_TRACKING_KV"
}

resource "cloudflare_workers_kv_namespace" "email_tracking_kv_preview" {
  account_id = var.cloudflare_account_id
  title      = "EMAIL_TRACKING_KV_PREVIEW_preview"
}

# Legal & Investigation
resource "cloudflare_workers_kv_namespace" "legal_kv" {
  account_id = var.cloudflare_account_id
  title      = "LEGAL_KV"
}

resource "cloudflare_workers_kv_namespace" "investigation_kv" {
  account_id = var.cloudflare_account_id
  title      = "INVESTIGATION_KV"
}

# Authentication & Security
resource "cloudflare_workers_kv_namespace" "oauth_kv" {
  account_id = var.cloudflare_account_id
  title      = "OAUTH_KV"
}

resource "cloudflare_workers_kv_namespace" "secrets" {
  account_id = var.cloudflare_account_id
  title      = "SECRETS"
}

# Vector & AI Storage
resource "cloudflare_workers_kv_namespace" "vector_store_kv" {
  account_id = var.cloudflare_account_id
  title      = "VECTOR_STORE_KV"
}

resource "cloudflare_workers_kv_namespace" "mixedbread_mcp_vector_store_kv" {
  account_id = var.cloudflare_account_id
  title      = "mixedbread-mcp-VECTOR_STORE_KV"
}

# Caching
resource "cloudflare_workers_kv_namespace" "cache" {
  account_id = var.cloudflare_account_id
  title      = "CACHE"
}

# ===========================================================================
# D1 DATABASES
# ===========================================================================

resource "cloudflare_d1_database" "holetruth_analytics" {
  account_id = var.cloudflare_account_id
  name       = "holetruth-analytics"
}

resource "cloudflare_d1_database" "legal_qdrant_db" {
  account_id = var.cloudflare_account_id
  name       = "legal-qdrant-db"
}

# ===========================================================================
# WORKERS (Script management via Wrangler recommended)
# ===========================================================================
# Note: Workers code is typically managed via wrangler CLI and git repos.
# We're documenting them here for visibility but not importing the actual scripts.
# To manage Worker code via Terraform, you'd use cloudflare_worker_script resource.

# For now, we'll use data sources to reference existing workers without managing their code

# Uncomment below to manage workers via Terraform (requires Worker code)
#
# resource "cloudflare_worker_script" "holetruth_website" {
#   account_id = var.cloudflare_account_id
#   name       = "holetruth-website"
#   content    = file("${path.module}/workers/holetruth-website.js")
# }
