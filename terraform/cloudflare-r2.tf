# Cloudflare R2 Storage Buckets
# Object storage compatible with S3 API
# Account: The HOLE Foundation (1a25a792e801e687b9fe4932030cf6a6)

# ===========================================================================
# LEGAL & EVIDENTIARY STORAGE (CRITICAL - VALUABLE FILES)
# ===========================================================================

resource "cloudflare_r2_bucket" "legal_documents" {
  account_id = var.cloudflare_account_id
  name       = "legal-documents"
  location   = "WNAM"  # Western North America
}

resource "cloudflare_r2_bucket" "legal_docs" {
  account_id = var.cloudflare_account_id
  name       = "legal-docs"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "legal_docs_2025" {
  account_id = var.cloudflare_account_id
  name       = "legal-docs-2025"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "legal_evidence" {
  account_id = var.cloudflare_account_id
  name       = "legal-evidence"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "hole_truth_evidentiary_files" {
  account_id = var.cloudflare_account_id
  name       = "hole-truth-evidentiary-files"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "foia_statutory_data" {
  account_id = var.cloudflare_account_id
  name       = "foia-statutory-data"
  location   = "WNAM"
}

# ===========================================================================
# CORPORATE & ORGANIZATIONAL DOCUMENTS
# ===========================================================================

resource "cloudflare_r2_bucket" "corporate_documents" {
  account_id = var.cloudflare_account_id
  name       = "corporate-documents"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "hole_foundation_corporate_docs" {
  account_id = var.cloudflare_account_id
  name       = "hole-foundation-corporate-docs"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "hole_foundation_web_docs" {
  account_id = var.cloudflare_account_id
  name       = "hole-foundation-web-docs"
  location   = "WNAM"
}

# ===========================================================================
# WEBSITE & APPLICATION ASSETS
# ===========================================================================

resource "cloudflare_r2_bucket" "holetruth_assets" {
  account_id = var.cloudflare_account_id
  name       = "holetruth-assets"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "hole_foundation_assets" {
  account_id = var.cloudflare_account_id
  name       = "hole-foundation-assets"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "hole_design_system" {
  account_id = var.cloudflare_account_id
  name       = "hole-design-system"
  location   = "WNAM"
}

# ===========================================================================
# MIPDS PROJECT STORAGE
# ===========================================================================

resource "cloudflare_r2_bucket" "mipds" {
  account_id = var.cloudflare_account_id
  name       = "mipds"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "mipds_backup" {
  account_id = var.cloudflare_account_id
  name       = "mipds-backup"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "mipds_files_bucket" {
  account_id = var.cloudflare_account_id
  name       = "mipds-files-bucket"
  location   = "WNAM"
}

# ===========================================================================
# AI & DATA PROCESSING
# ===========================================================================

resource "cloudflare_r2_bucket" "claude_memory_autorag" {
  account_id = var.cloudflare_account_id
  name       = "claude-memory-autorag"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "ray_data_bucket" {
  account_id = var.cloudflare_account_id
  name       = "ray-data-bucket"
  location   = "WNAM"
}

# ===========================================================================
# UTILITIES & TEMPLATES
# ===========================================================================

resource "cloudflare_r2_bucket" "r2_explorer_template" {
  account_id = var.cloudflare_account_id
  name       = "r2-explorer-template"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "pipeline_test_bucket" {
  account_id = var.cloudflare_account_id
  name       = "pipeline-test-bucket"
  location   = "WNAM"
}

resource "cloudflare_r2_bucket" "my_stripe_data" {
  account_id = var.cloudflare_account_id
  name       = "my-stripe-data"
  location   = "WNAM"
}
