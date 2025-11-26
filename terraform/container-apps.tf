# Container Apps Configuration
# Control running state and scaling

# Variable to control if container apps should be running
variable "container_apps_running" {
  description = "Set to false to scale container apps to zero (shutdown)"
  type        = bool
  default     = true  # Set to false to shut down
}

# Example: Container App in Dev Environment
# Uncomment and customize when you want to manage this resource
#
# resource "azurerm_container_app" "api_dev" {
#   name                         = "ca-api-rr4alxilkefww"
#   resource_group_name          = azurerm_resource_group.ai_agents_dev.name
#   container_app_environment_id = azurerm_container_app_environment.dev[0].id
#   revision_mode                = "Single"
#
#   template {
#     min_replicas = var.container_apps_running ? 1 : 0
#     max_replicas = var.container_apps_running ? 10 : 0
#
#     container {
#       name   = "api"
#       image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
#       cpu    = 0.25
#       memory = "0.5Gi"
#     }
#   }
#
#   tags = merge(local.common_tags, {
#     can_shutdown = "true"
#     auto_shutdown_enabled = var.enable_auto_shutdown
#   })
# }

# To SHUT DOWN container apps:
# 1. Set container_apps_running = false in terraform.tfvars
# 2. Run: terraform apply
#
# To START UP container apps:
# 1. Set container_apps_running = true in terraform.tfvars
# 2. Run: terraform apply
