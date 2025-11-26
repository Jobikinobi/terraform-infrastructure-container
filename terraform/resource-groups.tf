# Resource Groups
# Imported from existing Azure infrastructure

# Main AI Services Resource Group
resource "azurerm_resource_group" "hole_ai" {
  name     = "HOLE_AI_Resource-Group"
  location = "eastus"

  tags = merge(local.common_tags, {
    project     = "hole-ai"
    purpose     = "main-ai-services"
    priority    = "high"
    environment = "production"
  })
}

# FOIA Disclosure Document Intelligence
resource "azurerm_resource_group" "foia_disclosure" {
  name     = "FOIA-Disclosure-Document-Intelligence"
  location = "eastus"

  tags = merge(local.common_tags, {
    project     = "foia-disclosure"
    purpose     = "document-intelligence"
    priority    = "high"
    environment = "production"
  })
}

# Core Infrastructure - Domain Services
resource "azurerm_resource_group" "entra_domain" {
  name     = "hole-entra-domain-services"
  location = "eastus"

  tags = merge(local.common_tags, {
    project     = "infrastructure"
    purpose     = "active-directory-domain-services"
    priority    = "critical"
    environment = "production"
  })
}

# AI Agents Development Environment
resource "azurerm_resource_group" "ai_agents_dev" {
  name     = "rg-get-started-with-ai-agents-dev"
  location = "westus"

  tags = merge(local.common_tags, {
    project     = "ai-agents"
    purpose     = "development-environment"
    priority    = "medium"
    environment = "development"
    expires_on  = "2026-01-19"  # Set expiration for dev resources
  })
}

# MIPDS Project Infrastructure - MAIN PROJECT (East US)
# Contains the most costly resources (3 Recovery Vaults + Cognitive Services)
resource "azurerm_resource_group" "mipds" {
  name     = "MIPDS"
  location = "eastus"

  tags = merge(local.common_tags, {
    project     = "mipds"
    purpose     = "main-project-infrastructure"
    priority    = "critical"  # Updated: Main project with highest costs
    environment = "production"
  })
}

# MIPDS Project Infrastructure - West US Region
# Contains: VNet, Translator, Log Analytics, Container App Environment
resource "azurerm_resource_group" "mipds_westus" {
  name     = "rg-mipds-westus"
  location = "westus"

  tags = merge(local.common_tags, {
    project     = "mipds"
    purpose     = "mipds-west-region"
    priority    = "critical"
    environment = "production"
  })
}
