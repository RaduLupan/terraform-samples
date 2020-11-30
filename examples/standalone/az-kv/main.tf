# This template deploys the following Azure resources:
# - 1 x vnet with 1 x subnet and service points for Microsoft.KeyVault and Microsoft.Storage
# - 1 x Key Vault: firewall allows traffic from vnet subnet via service endpoint


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
  features {
    # Terraform will automatically recover a soft-deleted Key Vault during creation if one is found.
    # This feature opts out of this behaviour.
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

locals {
  project        = "terraform-samples"
  resource_group = var.resource_group == null ? azurerm_resource_group.rg[0].name : var.resource_group
}

# Create resource group if var.resource_group is null
resource "azurerm_resource_group" "rg" {
  count = var.resource_group == null ? 1 : 0

  name     = "rg-${lower(replace(var.location," ",""))}-${local.project}-${var.environment}"
  location = var.location

  tags = {
    environment = var.environment
    project     = local.project
    terraform   = "true"
  }
}

# Create default vnet 
resource "azurerm_virtual_network" "default" {
  name                = "vnet-${local.project}-${var.environment}-01"
  location            = var.location
  resource_group_name = local.resource_group
  address_space       = ["172.31.0.0/16"]

  tags = {
    environment = var.environment
    project     = local.project
    terraform   = "true"
  }
}

# Create default subnet
resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = local.resource_group
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["172.31.0.0/24"]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

## Use this data source to access the configuration of the AzureRM provider.
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "az_key_vault" {
  name                        = "kv-radulupan-${var.environment}"
  location                    = var.location
  resource_group_name         = local.resource_group
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  sku_name = "standard"

  # Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to false.
  enabled_for_deployment = true

  # Uncomment this line if Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.
  # enabled_for_disk_encryption = true

  # Uncomment this line if Azure Resource Manager is permitted to retrieve secrets from the key vault.
  # enabled_for_template_deployment = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    # To allow this vnet subnet through the key vault firewall, a service endpoint for Microsoft.KeyVault must be enabled at the subnet level.
    virtual_network_subnet_ids = [azurerm_subnet.default.id]
  }

  tags = {
    environment = var.environment
    project     = local.project
    terraform   = "true"
  }
}
