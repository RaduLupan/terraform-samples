terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.37.0"
    }
  }

  required_version = "~> 0.13.0"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

module "network" {
  
  # Github source - public repository. Note that the double-slash in the Git URL after the repository name is required.
  # Also, the v1.0.0 tag had to be pushed using:
  # git tag -a "v1.0.0" -m "First release"
  # git push --follow-tags
  source = "github.com/RaduLupan/terraform-samples-azure//modules/network?ref=v1.0.0"
  
  subscription_id                = var.subscription_id
  location                       = var.location
  environment                    = var.environment
  vnet_address_space             = var.vnet_address_space
  frontend_subnet_address_prefix = var.frontend_subnet_address_prefix
  allowed_ssh_address_prefix     = var.allowed_ssh_address_prefix
}
