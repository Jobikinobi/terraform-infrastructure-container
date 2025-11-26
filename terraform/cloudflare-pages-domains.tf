# Cloudflare Pages Custom Domains
# Links Cloudflare Pages projects to custom domains

# ===========================================================================
# DONATE APP CUSTOM DOMAIN
# ===========================================================================

resource "cloudflare_pages_domain" "donate_theholetruth" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.donate_theholetruth.name
  domain       = "donate.theholetruth.org"
}

# The cloudflare_pages_domain resource automatically creates the necessary
# CNAME record pointing to the Pages deployment
# Manual CNAME: donate.theholetruth.org -> donate-theholetruth.pages.dev
