# Terraform and Provider Configuration
# Azure Infrastructure as Code for HOLE Foundation

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"  # Use latest 4.x version
    }

    # Uncomment these providers when you're ready to use them:

    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> 5.0"  # Use latest 5.x version
    # }

    # google = {
    #   source  = "hashicorp/google"
    #   version = "~> 6.0"  # Use latest 6.x version
    # }

    # google-beta = {
    #   source  = "hashicorp/google-beta"
    #   version = "~> 6.0"  # Use latest 6.x version for beta features
    # }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"  # Use latest 4.x version
    }

    auth0 = {
      source  = "auth0/auth0"
      version = "~> 1.0"  # Use latest 1.x version
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"  # Use latest 6.x version
    }

  }
}

# Azure Provider Configuration - Main Subscription (Azure subscription 1)
# Authentication via Azure CLI by default
provider "azurerm" {
  features {
    # Feature flags for Azure provider behavior

    resource_group {
      # Prevent accidental deletion of non-empty resource groups
      prevent_deletion_if_contains_resources = true
    }

    key_vault {
      # Purge soft-deleted Key Vaults on destroy
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }

    virtual_machine {
      # Delete OS disk when VM is deleted
      delete_os_disk_on_deletion     = true
      # Note: graceful_shutdown deprecated in v4.0, removed in v5.0
      skip_shutdown_and_force_delete = false
    }

    cognitive_account {
      # Purge soft-deleted Cognitive Services on destroy
      purge_soft_delete_on_destroy = false
    }
  }

  # Main subscription configuration
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}

# Azure Provider Configuration - General Services Subscription
# For managing Entra Domain Services and shared infrastructure
provider "azurerm" {
  alias = "general_services"
  
  features {
    # Feature flags for Azure provider behavior

    resource_group {
      # Prevent accidental deletion of non-empty resource groups
      prevent_deletion_if_contains_resources = true
    }

    key_vault {
      # Purge soft-deleted Key Vaults on destroy
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }

    virtual_machine {
      # Delete OS disk when VM is deleted
      delete_os_disk_on_deletion     = true
      skip_shutdown_and_force_delete = false
    }

    cognitive_account {
      # Purge soft-deleted Cognitive Services on destroy
      purge_soft_delete_on_destroy = false
    }
  }

  # General Services subscription configuration (Contains expensive Entra Domain Services)
  subscription_id = var.azure_general_services_subscription_id
  tenant_id       = var.azure_tenant_id
}

# Azure Provider Configuration - MUA Subscription
# For multi-user access and shared resources
provider "azurerm" {
  alias = "mua"
  
  features {
    # Feature flags for Azure provider behavior

    resource_group {
      # Prevent accidental deletion of non-empty resource groups
      prevent_deletion_if_contains_resources = true
    }

    key_vault {
      # Purge soft-deleted Key Vaults on destroy
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }

    virtual_machine {
      # Delete OS disk when VM is deleted
      delete_os_disk_on_deletion     = true
      skip_shutdown_and_force_delete = false
    }

    cognitive_account {
      # Purge soft-deleted Cognitive Services on destroy
      purge_soft_delete_on_destroy = false
    }
  }

  # MUA subscription configuration
  subscription_id = var.azure_mua_subscription_id
  tenant_id       = var.azure_tenant_id
}

# Azure Provider Configuration - Plan Subscription
# For Azure plan-specific resources and billing
provider "azurerm" {
  alias = "plan"
  
  features {
    # Feature flags for Azure provider behavior

    resource_group {
      # Prevent accidental deletion of non-empty resource groups
      prevent_deletion_if_contains_resources = true
    }

    key_vault {
      # Purge soft-deleted Key Vaults on destroy
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }

    virtual_machine {
      # Delete OS disk when VM is deleted
      delete_os_disk_on_deletion     = true
      skip_shutdown_and_force_delete = false
    }

    cognitive_account {
      # Purge soft-deleted Cognitive Services on destroy
      purge_soft_delete_on_destroy = false
    }
  }

  # Plan subscription configuration
  subscription_id = var.azure_plan_subscription_id
  tenant_id       = var.azure_tenant_id
}

# AWS Provider Configuration
# Authentication via AWS CLI SSO (configured above)
# COMMENTED OUT: Enable when you're ready to manage AWS resources
# provider "aws" {
#   region = var.aws_region
#
#   default_tags {
#     tags = {
#       managed_by   = "terraform"
#       organization = "HOLE Foundation"
#       owner        = "joe@theholetruth.org"
#       created_by   = "terraform"
#     }
#   }
# }

# Google Cloud Provider Configuration - Main Project (The Hole Truth Investigation)
# Authentication via gcloud CLI by default
# COMMENTED OUT: Enable when you're ready to manage GCP resources
# provider "google" {
#   project = var.gcp_main_project_id
#   region  = var.gcp_region
#   zone    = var.gcp_zone
#
#   # Default labels applied to all resources
#   default_labels = {
#     managed-by   = "terraform"
#     organization = "hole-foundation"
#     owner        = "joe-herrmann"
#     created-by   = "terraform"
#     environment  = var.environment
#   }
# }

# Google Cloud Provider Configuration - Beta features
# For accessing Google Cloud beta/preview features
# COMMENTED OUT: Enable when you're ready to manage GCP resources
# provider "google-beta" {
#   project = var.gcp_main_project_id
#   region  = var.gcp_region
#   zone    = var.gcp_zone
#
#   # Default labels applied to all resources
#   default_labels = {
#     managed-by   = "terraform"
#     organization = "hole-foundation"
#     owner        = "joe-herrmann"
#     created-by   = "terraform"
#     environment  = var.environment
#   }
# }

# Google Cloud Provider Configuration - Auth Project
# For Auth0 integration and authentication services
# COMMENTED OUT: Enable when you're ready to manage GCP resources
# provider "google" {
#   alias   = "auth"
#   project = var.gcp_auth_project_id
#   region  = var.gcp_region
#   zone    = var.gcp_zone
#
#   default_labels = {
#     managed-by   = "terraform"
#     organization = "hole-foundation"
#     owner        = "joe-herrmann"
#     created-by   = "terraform"
#     environment  = var.environment
#     service      = "authentication"
#   }
# }

# Cloudflare Provider Configuration
# For DNS, CDN, security, and edge computing
provider "cloudflare" {
  api_token = var.cloudflare_api_token
  # Alternative: email + api_key authentication (less secure, not recommended)
  # email   = var.cloudflare_email
  # api_key = var.cloudflare_api_key
}

# Auth0 Provider Configuration
# For unified authentication across all platforms
# Tenant: dev-4fszoklachwdh46m.us.auth0.com
# Custom Domain: auth.theholetruth.org
provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}

# GitHub Provider Configuration
# For repository, team, and automation management
provider "github" {
  token = var.github_token
  owner = "Jobikinobi"  # Your GitHub username

  # Alternative: GitHub App authentication (more secure for production)
  # app_auth {
  #   id              = var.github_app_id
  #   installation_id = var.github_installation_id
  #   pem_file        = var.github_app_pem_file
  # }
}


