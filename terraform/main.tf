# Main Terraform Configuration
# Azure Infrastructure as Code for HOLE Foundation
# Created: 2025-10-19
# Priority: CRITICAL - Cost control and resource management

# Local values for common resource configurations
locals {
  # Current date for resource creation tracking
  created_date = formatdate("YYYY-MM-DD", timestamp())

  # Default expiration date (90 days from now)
  default_expires_on = formatdate("YYYY-MM-DD", timeadd(timestamp(), "${var.default_ttl_days * 24}h"))

  # Common tags to apply to all resources
  common_tags = merge(var.common_tags, {
    environment  = var.environment
    owner        = var.default_owner
    cost_center  = var.default_cost_center
    created_date = local.created_date
  })

  # Resource naming convention
  # Format: {prefix}-{resource-type}-{suffix}
  resource_name_prefix = "${var.naming_prefix}-${var.environment}"
}

# Data source to get current Azure subscription details
data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

# ============================================================================
# RESOURCE GROUPS
# ============================================================================

# Note: Existing resource groups will be imported rather than created
# This section shows how to reference existing resource groups

# Example: Reference existing HOLE AI Resource Group
# data "azurerm_resource_group" "hole_ai" {
#   name = "HOLE_AI_Resource-Group"
# }

# ============================================================================
# STORAGE ACCOUNTS
# ============================================================================

# Example: Storage account configuration (to be populated after import)
# resource "azurerm_storage_account" "example" {
#   name                     = "${local.resource_name_prefix}storage"
#   resource_group_name      = azurerm_resource_group.example.name
#   location                 = var.default_location
#   account_tier             = var.storage_account_tier
#   account_replication_type = var.storage_replication_type
#
#   tags = merge(local.common_tags, {
#     project = "infrastructure"
#     purpose = "general-storage"
#   })
# }

# ============================================================================
# COGNITIVE SERVICES
# ============================================================================

# Example: Cognitive Services account (to be populated after import)
# resource "azurerm_cognitive_account" "example" {
#   name                = "${local.resource_name_prefix}-cognitive"
#   location            = var.default_location
#   resource_group_name = azurerm_resource_group.example.name
#   kind                = "CognitiveServices"
#   sku_name            = var.cognitive_services_sku
#
#   tags = merge(local.common_tags, {
#     project = "ai-services"
#     purpose = "cognitive-api"
#   })
# }

# ============================================================================
# NETWORKING
# ============================================================================

# Example: Virtual Network (to be populated after import)
# resource "azurerm_virtual_network" "example" {
#   name                = "${local.resource_name_prefix}-vnet"
#   location            = var.default_location
#   resource_group_name = azurerm_resource_group.example.name
#   address_space       = var.vnet_address_space
#
#   tags = merge(local.common_tags, {
#     project = "infrastructure"
#     purpose = "network"
#   })
# }

# ============================================================================
# MONITORING & DIAGNOSTICS
# ============================================================================

# Example: Log Analytics Workspace (to be populated after import)
# resource "azurerm_log_analytics_workspace" "example" {
#   name                = "${local.resource_name_prefix}-logs"
#   location            = var.default_location
#   resource_group_name = azurerm_resource_group.example.name
#   sku                 = "PerGB2018"
#   retention_in_days   = var.log_retention_days
#
#   tags = merge(local.common_tags, {
#     project = "infrastructure"
#     purpose = "monitoring"
#   })
# }

# ============================================================================
# CURRENT STATUS
# ============================================================================

# This is a starter configuration. Next steps:
# 1. Use Azure Portal Terraform Export to generate configurations for existing resources
# 2. Import existing resources into Terraform state
# 3. Apply proper tagging to all resources
# 4. Implement cost optimization features (auto-shutdown, TTL, etc.)
# 5. Set up remote state backend in Azure Storage

# To see current Azure resources:
# az resource list --output table

# To import an existing resource:
# terraform import azurerm_resource_group.example /subscriptions/{subscription-id}/resourceGroups/{resource-group-name}
