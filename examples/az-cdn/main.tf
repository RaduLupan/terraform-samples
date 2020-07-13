# This template deploys the following Azure resources:
# - 1 x CDN profile with 1 x endpoint

# Terraform 0.12 syntax is used so 0.12 is the minimum required version
terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
    version = "2.10.0"
    subscription_id = var.subscriptionID
    features {}
}