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
  source = "../../../modules/network"

  subscription_id                = var.subscription_id
  location                       = var.location
  environment                    = var.environment
  vnet_address_space             = var.vnet_address_space
  frontend_subnet_address_prefix = var.frontend_subnet_address_prefix
  allowed_ssh_address_prefix     = var.allowed_ssh_address_prefix
}
