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

module "cdn" {

  # Github source - public repository. Note that the double-slash in the Git URL after the repository name is required.
  # Also, the v1.0.0 tag had to be pushed using:
  # git tag -a "v1.0.0" -m "First release"
  # git push --follow-tags
  
  source = "github.com/RaduLupan/terraform-samples-azure//modules/cdn?ref=v1.0.0"

  subscription_id     = var.subscription_id
  location            = var.location
  resource_group      = var.resource_group
  environment         = var.environment
  cdn_sku             = var.cdn_sku
  cdn_endpoint_domain = var.cdn_endpoint_domain

}