# Terraform Outputs
# Values to display after terraform apply

# Current Subscription Information
output "subscription_id" {
  description = "Azure Subscription ID"
  value       = data.azurerm_subscription.current.subscription_id
  sensitive   = true
}

output "subscription_display_name" {
  description = "Azure Subscription Display Name"
  value       = data.azurerm_subscription.current.display_name
}

output "tenant_id" {
  description = "Azure Tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
  sensitive   = true
}

# Configuration Values
output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "default_location" {
  description = "Default Azure region"
  value       = var.default_location
}

output "common_tags" {
  description = "Common tags applied to resources"
  value       = local.common_tags
}

# Resource Counts (will be populated as resources are added)
# output "resource_group_count" {
#   description = "Number of resource groups managed by Terraform"
#   value       = length([azurerm_resource_group.example])
# }

# Management Information
# Note: terraform.version is not available in Terraform
# output "terraform_version" {
#   description = "Terraform version used"
#   value       = terraform.version
# }

output "created_date" {
  description = "Date this configuration was applied"
  value       = local.created_date
}

# Cost Management
output "cost_alert_enabled" {
  description = "Whether cost alerts are enabled"
  value       = var.enable_cost_alerts
}

output "cost_alert_threshold" {
  description = "Monthly cost alert threshold (USD)"
  value       = var.cost_alert_threshold
}

# Feature Flags
output "features_enabled" {
  description = "Enabled features in this configuration"
  value = {
    auto_shutdown        = var.enable_auto_shutdown
    private_endpoints    = var.enable_private_endpoints
    diagnostics          = var.enable_diagnostics
    backup               = var.enable_backup
    zone_redundancy      = var.enable_zone_redundancy
    cost_alerts          = var.enable_cost_alerts
  }
}

# Next Steps
output "next_steps" {
  description = "Recommended next steps after initialization"
  value = <<-EOT

  Terraform initialization complete! Next steps:

  1. Review Current Resources:
     az resource list --output table

  2. Export Existing Resources (Azure Portal):
     - Use Azure Portal's Terraform Export feature
     - Or manually create configurations for critical resources

  3. Import Existing Resources:
     terraform import azurerm_resource_group.example /subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/{name}

  4. Apply Tagging Strategy:
     - Add proper tags to all resources
     - Set expiration dates for temporary resources

  5. Enable Cost Controls:
     - Review and enable auto-shutdown
     - Set up cost alerts
     - Implement TTL-based cleanup

  6. Set Up Remote State (Recommended):
     - Create Azure Storage backend
     - Migrate local state to remote

  Documentation: See README.md for detailed instructions

  EOT
}
