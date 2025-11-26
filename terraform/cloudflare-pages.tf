# Cloudflare Pages Projects
# Static site hosting and full-stack applications
# Account: The HOLE Foundation (1a25a792e801e687b9fe4932030cf6a6)

# ===========================================================================
# PAGES PROJECTS
# ===========================================================================

resource "cloudflare_pages_project" "builder_theholetruth2" {
  account_id        = var.cloudflare_account_id
  name              = "builder-theholetruth2"
  production_branch = "main"
}

resource "cloudflare_pages_project" "builder_theholefoundation2" {
  account_id        = var.cloudflare_account_id
  name              = "builder-theholefoundation2"
  production_branch = "main"
}

resource "cloudflare_pages_project" "the_hole_truth_dev" {
  account_id        = var.cloudflare_account_id
  name              = "the-hole-truth-dev"
  production_branch = "main"
}

resource "cloudflare_pages_project" "donate_theholetruth" {
  account_id        = var.cloudflare_account_id
  name              = "donate-theholetruth"
  production_branch = "main"

  build_config {
    build_command       = "cd apps/donate && pnpm install && pnpm run build"
    destination_dir     = "apps/donate/dist/spa"
    root_dir            = ""
  }

  source {
    type = "github"
    config {
      owner                         = "The-HOLE-Foundation"
      repo_name                     = "builder-theholetruth2"
      production_branch             = "main"
      pr_comments_enabled           = true
      deployments_enabled           = true
      production_deployment_enabled = true
    }
  }

  deployment_configs {
    production {
      environment_variables = {
        VITE_AUTH0_DOMAIN           = "dev-4fszoklachwdh46m.us.auth0.com"
        VITE_AUTH0_CLIENT_ID        = "DqTnEfRYqURjzK8NngzEIvTI6em9b8nu"
        VITE_AUTH0_AUDIENCE         = "https://api.theholetruth.org"
        VITE_API_URL                = "https://api.theholetruth.org"
        VITE_BUILDER_API_KEY        = "bpk-8f99b440a9f54faeab799ec1b5916415"
      }
      # Stripe keys should be added via Cloudflare dashboard for security
      # VITE_STRIPE_PUBLISHABLE_KEY and STRIPE_SECRET_KEY
    }
  }
}
