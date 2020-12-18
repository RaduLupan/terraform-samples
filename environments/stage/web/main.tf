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

locals {
  location       = data.azurerm_virtual_network.selected.location
  vnet_name      = data.terraform_remote_state.network.outputs.vnet_name
  subnet_name    = data.terraform_remote_state.network.outputs.fe_subnet_name
  resource_group = data.terraform_remote_state.network.outputs.rg_name
  key_vault_id   = data.terraform_remote_state.key-vault.outputs.vault_id 
}

# Use this data source to read outputs from the network layer.
data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
  }
}

# Use this data source to read outputs from the key-vault layer.
data "terraform_remote_state" "key-vault" {
  backend = "local"

  config = {
    path = "../key-vault/terraform.tfstate"
  }
}

# Use this data source to access information about an existing virtual network.
data "azurerm_virtual_network" "selected" {
  name                = local.vnet_name
  resource_group_name = local.resource_group
}

module "web" {

  # Github source - public repository. Note that the double-slash in the Git URL after the repository name is required.
  # Also, the v1.0.0 tag had to be pushed using:
  # git tag -a "v1.0.0" -m "First release"
  # git push --follow-tags

  source = "github.com/RaduLupan/terraform-samples-azure//modules/web?ref=v1.0.0"
  
  subscription_id                = var.subscription_id
  location                       = local.location
  environment                    = var.environment
  
  vnet_resource_group            = local.resource_group
  vnet_name                      = local.vnet_name
  subnet_name                    = local.subnet_name

  server_name                    = var.server_name
  vm_count                       = var.vm_count

  vm_admin_user                  = var.vm_admin_user
  vm_admin_password              = var.vm_admin_password

  key_vault_id                   = local.key_vault_id  
}
