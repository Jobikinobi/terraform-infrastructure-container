# Terraform Variables
# Input variables for Azure infrastructure configuration

# Azure Multi-Subscription Configuration
variable "azure_subscription_id" {
  description = "Azure Subscription ID (Main)"
  type        = string
  default     = "de602062-dafa-4c8b-91b7-98a75bcd7cff"
  sensitive   = true
}

variable "azure_general_services_subscription_id" {
  description = "Azure General Services Subscription ID (Contains Entra Domain Services)"
  type        = string
  default     = "a0132917-af47-4cf9-baa8-d284ca129cd1"
  sensitive   = true
}

variable "azure_mua_subscription_id" {
  description = "Azure MUA Subscription ID"
  type        = string
  default     = "11963af3-2198-4a64-bab5-32bc15bc0f05"
  sensitive   = true
}

variable "azure_plan_subscription_id" {
  description = "Azure Plan Subscription ID"
  type        = string
  default     = "c7ad271d-1f69-435c-ab3a-5d864397530b"
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  default     = "c9bc2130-ec1b-4d0b-89c3-4ff196000140"
  sensitive   = true
}

# Default Location
variable "default_location" {
  description = "Default Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "secondary_location" {
  description = "Secondary Azure region for redundancy"
  type        = string
  default     = "westus"
}

# Environment
variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

# Common Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    organization = "HOLE Foundation"
    managed_by   = "terraform"
    created_by   = "terraform"
  }
}

# Owner Information
variable "default_owner" {
  description = "Default resource owner email"
  type        = string
  default     = "joe@theholetruth.org"
}

# Cost Center
variable "default_cost_center" {
  description = "Default cost center for resource allocation"
  type        = string
  default     = "engineering"

  validation {
    condition     = contains(["engineering", "research", "operations", "legal"], var.default_cost_center)
    error_message = "Cost center must be one of: engineering, research, operations, legal."
  }
}

# Resource Naming
variable "naming_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "hole"
}

variable "naming_suffix" {
  description = "Suffix for resource names (e.g., environment)"
  type        = string
  default     = "prod"
}

# Resource Lifecycle
variable "default_ttl_days" {
  description = "Default TTL in days for temporary resources"
  type        = number
  default     = 90

  validation {
    condition     = var.default_ttl_days > 0 && var.default_ttl_days <= 365
    error_message = "TTL must be between 1 and 365 days."
  }
}

# Enable Cost Optimization Features
variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown for dev/test VMs"
  type        = bool
  default     = true
}

variable "auto_shutdown_time" {
  description = "Time to auto-shutdown VMs (24-hour format, e.g., '1800' for 6 PM)"
  type        = string
  default     = "1800"
}

variable "auto_shutdown_timezone" {
  description = "Timezone for auto-shutdown schedule"
  type        = string
  default     = "America/Chicago"
}

# Network Configuration
variable "vnet_address_space" {
  description = "Address space for virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection for virtual networks"
  type        = bool
  default     = false  # Expensive, enable only if needed
}

# Security
variable "enable_private_endpoints" {
  description = "Enable private endpoints for supported resources"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "IP ranges allowed to access resources"
  type        = list(string)
  default     = []  # Empty list means allow all (not recommended for production)
}

# Storage
variable "storage_account_tier" {
  description = "Storage account performance tier"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage tier must be Standard or Premium."
  }
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"  # Locally Redundant Storage (cheapest)

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

# Cognitive Services
variable "cognitive_services_sku" {
  description = "Default SKU for Cognitive Services"
  type        = string
  default     = "S0"  # Standard tier
}

# Monitoring
variable "enable_diagnostics" {
  description = "Enable diagnostic settings for resources"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain diagnostic logs"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 0 && var.log_retention_days <= 365
    error_message = "Log retention must be between 0 and 365 days."
  }
}

# Backup
variable "enable_backup" {
  description = "Enable backup for supported resources"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 9999
    error_message = "Backup retention must be between 7 and 9999 days."
  }
}

# High Availability
variable "enable_zone_redundancy" {
  description = "Enable zone redundancy for supported resources"
  type        = bool
  default     = false  # More expensive, enable only if needed
}

# Development
variable "enable_debug_mode" {
  description = "Enable debug mode (additional logging, relaxed policies)"
  type        = bool
  default     = false
}

# Feature Flags
variable "enable_cost_alerts" {
  description = "Enable cost alerts and budgets"
  type        = bool
  default     = true
}

variable "cost_alert_threshold" {
  description = "Monthly cost threshold for alerts (USD)"
  type        = number
  default     = 500
}

# Multi-Cloud Configuration
variable "enable_aws_resources" {
  description = "Enable AWS resource management"
  type        = bool
  default     = true  # Now enabled!
}

# AWS Account Configuration
variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "420073135340"
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.aws_region))
    error_message = "AWS region must be a valid region format (e.g., us-east-1)."
  }
}

# Google Cloud Platform Configuration
variable "gcp_main_project_id" {
  description = "Google Cloud Main Project ID (The Hole Truth Investigation)"
  type        = string
  default     = "the-hole-truth-investigation"
  sensitive   = true
}

variable "gcp_auth_project_id" {
  description = "Google Cloud Auth Project ID (for Auth0 integration)"
  type        = string
  default     = "autho-474702"  # Based on your project list
  sensitive   = true
}

variable "gcp_region" {
  description = "Google Cloud region for resources"
  type        = string
  default     = "us-central1"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+\\d+$", var.gcp_region))
    error_message = "GCP region must be a valid region format (e.g., us-central1)."
  }
}

variable "gcp_zone" {
  description = "Google Cloud zone for resources"
  type        = string
  default     = "us-central1-a"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+\\d+-[a-f]$", var.gcp_zone))
    error_message = "GCP zone must be a valid zone format (e.g., us-central1-a)."
  }
}

# Cloudflare Configuration
variable "cloudflare_api_token" {
  description = "Cloudflare API Token (recommended over email/api_key)"
  type        = string
  default     = ""  # Set via environment variable CLOUDFLARE_API_TOKEN
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
  default     = ""  # Set in terraform.tfvars
  sensitive   = true
}

variable "cloudflare_email" {
  description = "Cloudflare account email (alternative to API token)"
  type        = string
  default     = "joe@theholetruth.org"
  sensitive   = true
}

variable "cloudflare_api_key" {
  description = "Cloudflare Global API Key (alternative to API token)"
  type        = string
  default     = ""  # Set via environment variable CLOUDFLARE_API_KEY
  sensitive   = true
}

# Auth0 Configuration
variable "auth0_domain" {
  description = "Auth0 domain (e.g., your-tenant.auth0.com)"
  type        = string
  default     = "dev-4fszoklachwdh46m.us.auth0.com"  # Auth0 tenant domain (not custom domain)
  sensitive   = true
}

variable "auth0_client_id" {
  description = "Auth0 Management API Client ID"
  type        = string
  default     = ""  # Will need your Auth0 client ID
  sensitive   = true
}

variable "auth0_client_secret" {
  description = "Auth0 Management API Client Secret"
  type        = string
  default     = ""  # Will need your Auth0 client secret
  sensitive   = true
}

# GitHub Configuration
variable "github_token" {
  description = "GitHub Personal Access Token or GitHub App token"
  type        = string
  default     = ""  # Set via environment variable GITHUB_TOKEN
  sensitive   = true
}

variable "github_organization" {
  description = "GitHub organization or username"
  type        = string
  default     = "Jobikinobi"  # Based on your repo owner
  sensitive   = false
}


