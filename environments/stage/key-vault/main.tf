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
  resource_group = data.terraform_remote_state.network.outputs.rg_name
  subnet_ids     = [data.terraform_remote_state.network.outputs.fe_subnet_id]
}

# Use this data source to read outputs from the network layer
data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
  }
}

module "key-vault" {

  # Github source - public repository. Note that the double-slash in the Git URL after the repository name is required.
  # Also, the v1.0.0 tag had to be pushed using:
  # git tag -a "v1.0.0" -m "First release"
  # git push --follow-tags
  
  source = "github.com/RaduLupan/terraform-samples-azure//modules/key-vault?ref=v1.0.0"


  subscription_id     = var.subscription_id
  location            = var.location
  resource_group      = local.resource_group
  environment         = var.environment
  subnet_ids          = local.subnet_ids
}
