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

module "key-vault" {
  source = "../../modules/key-vault"

  subscription_id     = var.subscription_id
  location            = var.location
  resource_group      = var.resource_group
  environment         = var.environment
  subnet_ids          = var.subnet_ids
}