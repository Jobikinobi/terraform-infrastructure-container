# Cloudflare Infrastructure Configuration
# Manages DNS, CDN, R2 Storage, Workers, and other Cloudflare services
# Created: 2025-11-14
# Account: joe@theholetruth.org (1a25a792e801e687b9fe4932030cf6a6)

# ============================================================================
# DATA SOURCES
# ============================================================================

# Get Cloudflare account information
data "cloudflare_accounts" "main" {
  name = ".*"  # This will fetch all accounts accessible with the API token
}

# ============================================================================
# DNS ZONES
# ============================================================================

# Example: Manage theholetruth.org zone
# Uncomment and modify after importing existing zones
# resource "cloudflare_zone" "theholetruth_org" {
#   account_id = var.cloudflare_account_id
#   zone       = "theholetruth.org"
#   plan       = "free"  # Options: free, pro, business, enterprise
#   type       = "full"  # Full DNS management
# }

# Example DNS records
# resource "cloudflare_record" "www" {
#   zone_id = cloudflare_zone.theholetruth_org.id
#   name    = "www"
#   value   = "192.0.2.1"  # Your server IP or CNAME target
#   type    = "A"
#   proxied = true  # Enable Cloudflare proxy (orange cloud)
# }

# ============================================================================
# R2 STORAGE BUCKETS
# ============================================================================

# Example: R2 bucket for backups
# resource "cloudflare_r2_bucket" "backups" {
#   account_id = var.cloudflare_account_id
#   name       = "hole-foundation-backups"
#   location   = "WNAM"  # Western North America, or "ENAM" (Eastern), "EEUR" (Eastern Europe), "APAC" (Asia Pacific)
# }

# ============================================================================
# WORKERS & PAGES
# ============================================================================

# Example: Workers KV Namespace
# resource "cloudflare_workers_kv_namespace" "secrets" {
#   account_id = var.cloudflare_account_id
#   title      = "SECRETS"
# }

# Example: Pages project
# resource "cloudflare_pages_project" "website" {
#   account_id        = var.cloudflare_account_id
#   name              = "my-website"
#   production_branch = "main"
#
#   source {
#     type = "github"
#     config {
#       owner             = "your-github-org"
#       repo_name         = "your-repo"
#       production_branch = "main"
#     }
#   }
# }

# ============================================================================
# D1 DATABASES
# ============================================================================

# Example: D1 serverless database
# resource "cloudflare_d1_database" "main" {
#   account_id = var.cloudflare_account_id
#   name       = "my-database"
# }

# ============================================================================
# FIREWALL & SECURITY
# ============================================================================

# Example: WAF rule
# resource "cloudflare_ruleset" "zone_level_firewall" {
#   zone_id     = cloudflare_zone.theholetruth_org.id
#   name        = "Custom firewall ruleset"
#   description = "Zone-level firewall rules"
#   kind        = "zone"
#   phase       = "http_request_firewall_custom"
#
#   rules {
#     action = "block"
#     expression = "(ip.geoip.country eq \"CN\" or ip.geoip.country eq \"RU\")"
#     description = "Block traffic from specific countries"
#   }
# }

# ============================================================================
# LOAD BALANCERS
# ============================================================================

# Example: Load balancer (requires paid plan)
# resource "cloudflare_load_balancer" "main" {
#   zone_id          = cloudflare_zone.theholetruth_org.id
#   name             = "lb.theholetruth.org"
#   fallback_pool_id = cloudflare_load_balancer_pool.primary.id
#   default_pool_ids = [cloudflare_load_balancer_pool.primary.id]
#   description      = "Main load balancer"
#   proxied          = true
# }

# ============================================================================
# NEXT STEPS
# ============================================================================

# To manage existing Cloudflare resources:
# 1. List your zones:
#    terraform console
#    > data.cloudflare_accounts.main
#
# 2. Import existing zones:
#    terraform import cloudflare_zone.theholetruth_org <zone_id>
#
# 3. Import existing DNS records:
#    terraform import cloudflare_record.www <zone_id>/<record_id>
#
# 4. Import R2 buckets:
#    terraform import cloudflare_r2_bucket.backups <account_id>/<bucket_name>
#
# 5. Generate config from existing resources:
#    Use cf-terraforming tool: https://github.com/cloudflare/cf-terraforming
