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

module "data" {
  source = "../../modules/data"

  subscription_id     = var.subscription_id
  location            = var.location
  resource_group      = var.resource_group
  environment         = var.environment
  
  admin_login         = var.admin_login
  admin_password      = var.admin_password

  server_sku          = var.server_sku
  server_storage_mb   = var.server_storage_mb
  server_version      = var.server_version
  subnet_id           = var.subnet_id
}