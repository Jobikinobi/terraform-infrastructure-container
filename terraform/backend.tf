# Terraform Backend Configuration
#
# CURRENT: Local backend (state stored on local machine)
# FUTURE: Can migrate to Terraform Cloud or Azure Storage backend
#
# Local Backend:
# - State stored in terraform.tfstate (gitignored)
# - Simple setup, works with Azure CLI auth
# - Good for solo development
#
# To migrate to Terraform Cloud later, uncomment the cloud block and run:
# terraform init -migrate-state

# terraform {
#   cloud {
#     # The HOLE Foundation - Terraform Cloud Organization
#     organization = "theholetruth"
#
#     workspaces {
#       # Azure Infrastructure workspace
#       name = "azure-infrastructure"
#     }
#   }
# }

# Local backend (default - no configuration needed)
# State will be stored in terraform.tfstate in this directory
