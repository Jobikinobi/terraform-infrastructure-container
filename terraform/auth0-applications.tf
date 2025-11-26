# Auth0 Applications - Imported Resources
# Domain: dev-4fszoklachwdh46m.us.auth0.com
# Custom Domain: auth.theholetruth.org

# Main SPA - Theholetruth.org
resource "auth0_client" "theholetruth_org" {
  name        = "Theholetruth.org"
  description = "Production SPA for theholetruth.org and theholefoundation.org"
  app_type    = "spa"

  callbacks = [
    "https://theholetruth.org/callback",
    "https://theholefoundation.org/callback",
    "https://auth.theholetruth.org/callback",
    "http://localhost:5173/callback",
  ]

  allowed_logout_urls = [
    "https://theholetruth.org",
    "https://theholefoundation.org",
    "https://auth.theholetruth.org",
    "http://localhost:5173",
  ]

  web_origins = [
    "https://theholetruth.org",
    "https://theholefoundation.org",
    "https://auth.theholetruth.org",
    "http://localhost:5173",
  ]

  allowed_origins = [
    "https://theholetruth.org",
    "https://theholefoundation.org",
    "https://auth.theholetruth.org",
    "http://localhost:5173",
  ]

  grant_types = [
    "authorization_code",
    "refresh_token",
  ]

  oidc_conformant        = true
  is_first_party         = true
  custom_login_page_on   = true
  organization_usage     = "allow"
  organization_require_behavior = "pre_login_prompt"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = 36000
  }
}

# HOLE Foundation Web Apps
resource "auth0_client" "hole_foundation_web_apps" {
  name        = "HOLE Foundation Web Apps"
  description = "Multi-environment SPA for HOLE Foundation web applications"
  app_type    = "spa"

  callbacks = [
    "https://theholetruth.org/callback",
    "https://theholefoundation.org/callback",
    "https://auth.theholetruth.org/callback",
    "http://localhost:8084/callback",
    "http://localhost:8085/callback",
    "http://localhost:5173/callback",
  ]

  allowed_logout_urls = [
    "https://theholetruth.org",
    "https://theholefoundation.org",
    "https://auth.theholetruth.org",
    "http://localhost:8084",
    "http://localhost:8085",
    "http://localhost:5173",
  ]

  web_origins = [
    "https://theholetruth.org",
    "https://theholefoundation.org",
    "https://auth.theholetruth.org",
    "http://localhost:8084",
    "http://localhost:8085",
    "http://localhost:5173",
  ]

  allowed_origins = [
    "https://theholetruth.org",
    "https://theholefoundation.org",
    "https://auth.theholetruth.org",
    "http://localhost:8084",
    "http://localhost:8085",
    "http://localhost:5173",
  ]

  grant_types = [
    "authorization_code",
    "refresh_token",
  ]

  oidc_conformant        = true
  is_first_party         = true
  custom_login_page_on   = true
  organization_usage     = "allow"
  organization_require_behavior = "pre_login_prompt"

  jwt_configuration {
    alg                 = "RS256"
    lifetime_in_seconds = 36000
  }
}

# Outputs
output "auth0_theholetruth_org_client_id" {
  description = "Client ID for theholetruth.org SPA"
  value       = auth0_client.theholetruth_org.client_id
}

output "auth0_hole_foundation_web_apps_client_id" {
  description = "Client ID for HOLE Foundation Web Apps"
  value       = auth0_client.hole_foundation_web_apps.client_id
}
