# Auto-Shutdown Configuration
# Automatically shut down dev/test resources to save costs

# Auto-shutdown for Container Apps in Dev Environment
# Note: Azure Container Apps don't have built-in auto-shutdown
# Instead, we can scale them to zero replicas on a schedule

# For now, we'll use Azure Automation to manage shutdown schedules
# This requires an Automation Account

resource "azurerm_automation_account" "auto_shutdown" {
  count               = var.enable_auto_shutdown ? 1 : 0
  name                = "${var.naming_prefix}-auto-shutdown"
  location            = var.default_location
  resource_group_name = azurerm_resource_group.ai_agents_dev.name
  sku_name            = "Basic"

  tags = merge(local.common_tags, {
    purpose = "auto-shutdown-automation"
    project = "cost-optimization"
  })
}

# Runbook for Container App shutdown
resource "azurerm_automation_runbook" "container_app_shutdown" {
  count                   = var.enable_auto_shutdown ? 1 : 0
  name                    = "container-app-shutdown"
  location                = var.default_location
  resource_group_name     = azurerm_resource_group.ai_agents_dev.name
  automation_account_name = azurerm_automation_account.auto_shutdown[0].name
  log_verbose             = true
  log_progress            = true
  runbook_type           = "PowerShell"

  content = <<-SCRIPT
    param(
        [string]$ResourceGroupName = "rg-get-started-with-ai-agents-dev",
        [string]$ContainerAppName = "ca-api-rr4alxilkefww"
    )

    # Authenticate using Managed Identity
    Connect-AzAccount -Identity

    # Scale container app to zero
    az containerapp update `
      --name $ContainerAppName `
      --resource-group $ResourceGroupName `
      --min-replicas 0 `
      --max-replicas 0

    Write-Output "Container app $ContainerAppName scaled to zero"
  SCRIPT

  tags = merge(local.common_tags, {
    purpose = "container-app-shutdown"
  })
}

# Schedule for shutdown (6 PM CDT = 11 PM UTC)
resource "azurerm_automation_schedule" "evening_shutdown" {
  count                   = var.enable_auto_shutdown ? 1 : 0
  name                    = "evening-shutdown"
  resource_group_name     = azurerm_resource_group.ai_agents_dev.name
  automation_account_name = azurerm_automation_account.auto_shutdown[0].name
  frequency               = "Day"
  interval                = 1
  timezone                = "America/Chicago"
  start_time              = formatdate("YYYY-MM-DD'T'18:00:00Z", timeadd(timestamp(), "24h"))
  description             = "Shutdown dev resources at 6 PM CDT daily"
}

# Schedule for startup (8 AM CDT = 1 PM UTC)
resource "azurerm_automation_schedule" "morning_startup" {
  count                   = var.enable_auto_shutdown ? 1 : 0
  name                    = "morning-startup"
  resource_group_name     = azurerm_resource_group.ai_agents_dev.name
  automation_account_name = azurerm_automation_account.auto_shutdown[0].name
  frequency               = "Day"
  interval                = 1
  timezone                = "America/Chicago"
  start_time              = formatdate("YYYY-MM-DD'T'08:00:00Z", timeadd(timestamp(), "24h"))
  description             = "Start dev resources at 8 AM CDT on weekdays"
}
