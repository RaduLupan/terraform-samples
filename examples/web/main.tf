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

module "web" {
  source = "../../modules/web"

  subscription_id                = var.subscription_id
  location                       = var.location
  environment                    = var.environment
  
  vnet_resource_group            = var.vnet_resource_group
  vnet_name                      = var.vnet_name
  subnet_name                    = var.subnet_name

  server_name                    = var.server_name
  vm_count                       = var.vm_count

  vm_admin_user                  = var.vm_admin_user
  vm_admin_password              = var.vm_admin_password  
}