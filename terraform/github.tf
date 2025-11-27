# GitHub Repository and Project Management
# Manages repositories, issues, projects, and automation

# Import existing terraform-infrastructure-container repository
# This makes the repo manageable by Terraform
resource "github_repository" "terraform_container" {
  name        = "terraform-infrastructure-container"
  description = "Portable, Docker-free Terraform infrastructure management with Cloudflare Workers - Unified development lifecycle system"

  visibility = "public"

  has_issues   = true
  has_projects = true
  has_wiki     = true
  has_downloads = true

  # Topics for discoverability
  topics = [
    "terraform",
    "cloudflare",
    "workers",
    "infrastructure-as-code",
    "docker-free",
    "multicloud",
    "azure",
    "auth0",
    "portable",
    "v8-isolates",
    "project-management",
    "devops"
  ]

  # Repository settings
  allow_auto_merge       = true
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true

  # Security
  vulnerability_alerts = true

  # Homepage
  homepage_url = "https://terraform-infrastructure-container.joe-1a2.workers.dev"

  # Archive on delete instead of destroying
  archive_on_destroy = true
}

# Branch protection for main branch
resource "github_branch_protection" "main" {
  repository_id = github_repository.terraform_container.node_id
  pattern       = "main"

  # Allow admins to bypass (single developer for now)
  enforce_admins = false

  # Require pull request reviews (disabled for single developer)
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = false
    required_approving_review_count = 0
  }

  # Require status checks before merging (when CI/CD is set up)
  # required_status_checks {
  #   strict   = true
  #   contexts = ["terraform-validate", "wrangler-deploy"]
  # }
}

# Note: Classic GitHub Projects (github_repository_project) are deprecated
# The API endpoints have been removed by GitHub
# We'll manage projects via the GitHub UI or new Projects API when available
# For now, we focus on repository and issue management via Terraform

# Issue labels for categorization
resource "github_issue_labels" "terraform_container" {
  repository = github_repository.terraform_container.name

  # Infrastructure labels
  label {
    name        = "infrastructure"
    color       = "0052CC"
    description = "Infrastructure changes or issues"
  }

  label {
    name        = "deployment"
    color       = "1D76DB"
    description = "Deployment related"
  }

  label {
    name        = "terraform"
    color       = "5319E7"
    description = "Terraform configuration changes"
  }

  # Cloud provider labels
  label {
    name        = "cloudflare"
    color       = "F38020"
    description = "Cloudflare resources or issues"
  }

  label {
    name        = "azure"
    color       = "0089D6"
    description = "Azure resources or issues"
  }

  label {
    name        = "auth0"
    color       = "EB5424"
    description = "Auth0 configuration or issues"
  }

  # Priority labels
  label {
    name        = "priority:critical"
    color       = "B60205"
    description = "Critical priority - immediate attention"
  }

  label {
    name        = "priority:high"
    color       = "D93F0B"
    description = "High priority"
  }

  label {
    name        = "priority:medium"
    color       = "FBCA04"
    description = "Medium priority"
  }

  label {
    name        = "priority:low"
    color       = "0E8A16"
    description = "Low priority"
  }

  # Type labels
  label {
    name        = "bug"
    color       = "D73A4A"
    description = "Something isn't working"
  }

  label {
    name        = "enhancement"
    color       = "A2EEEF"
    description = "New feature or request"
  }

  label {
    name        = "documentation"
    color       = "0075CA"
    description = "Documentation improvements"
  }

  label {
    name        = "security"
    color       = "C51162"
    description = "Security related"
  }

  # Component labels
  label {
    name        = "worker"
    color       = "7057FF"
    description = "Cloudflare Worker code"
  }

  label {
    name        = "d1"
    color       = "008672"
    description = "D1 database related"
  }

  label {
    name        = "vpc"
    color       = "5319E7"
    description = "VPC and private networking"
  }

  label {
    name        = "secrets"
    color       = "C51162"
    description = "Secret management"
  }
}

# Webhook for deployment automation
resource "github_repository_webhook" "worker_deployment" {
  repository = github_repository.terraform_container.name

  configuration {
    url          = "https://terraform-infrastructure-container.joe-1a2.workers.dev/api/github/webhook"
    content_type = "json"
    insecure_ssl = false
  }

  events = [
    "push",
    "pull_request",
    "issues",
    "release",
    "create",
    "delete"
  ]

  active = true
}

# GitHub Actions secrets for CI/CD
resource "github_actions_secret" "cloudflare_api_token" {
  repository      = github_repository.terraform_container.name
  secret_name     = "CLOUDFLARE_API_TOKEN"
  plaintext_value = var.cloudflare_api_token
}

resource "github_actions_secret" "azure_credentials" {
  repository  = github_repository.terraform_container.name
  secret_name = "AZURE_CREDENTIALS"
  plaintext_value = jsonencode({
    clientId       = "b43fd258-79da-4fdd-95c8-10c62eeab311"
    clientSecret   = "***REDACTED***"  # Set via GitHub UI for security
    subscriptionId = var.azure_subscription_id
    tenantId       = var.azure_tenant_id
  })
}

resource "github_actions_secret" "auth0_credentials" {
  repository  = github_repository.terraform_container.name
  secret_name = "AUTH0_CREDENTIALS"
  plaintext_value = jsonencode({
    domain       = var.auth0_domain
    clientId     = var.auth0_client_id
    clientSecret = var.auth0_client_secret
  })
}

# Outputs
output "github_repository_url" {
  description = "URL of the managed GitHub repository"
  value       = github_repository.terraform_container.html_url
}

output "github_topics" {
  description = "Repository topics for discoverability"
  value       = github_repository.terraform_container.topics
}

output "github_webhook_url" {
  description = "Webhook URL for GitHub events"
  value       = github_repository_webhook.worker_deployment.url
}
