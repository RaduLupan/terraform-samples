# This template deploys the following Azure resources:
# - 1 x Key Vault in existing resource group
# - The Key Vault firewall allows traffic from existing vnet subnet via service endpoint

terraform {
  required_version = "~> 0.13.0"
}

locals {
  resource_group     = var.resource_group == null ? azurerm_resource_group.rg[0].name : var.resource_group

  common_tags = {
    terraform   = true
    environment = var.environment
    project     = "terraform-samples-modules"
    role        = "key-vault"
  }
}

# Create Resource Group if var.resource_group is null
resource "azurerm_resource_group" "rg" {
  count = var.resource_group == null ? 1 : 0

  name     = "rg-${lower(replace(var.location," ",""))}-${local.common_tags["project"]}-${local.common_tags["role"]}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

# The random string needed for injecting randomness in the name for storage account, blob container and key vault.
resource "random_string" "random" {
  length  = 4
  special = false
}

## Use this data source to access the configuration of the AzureRM provider.
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "az_key_vault" {
  name                        = "kv-${var.environment}-${lower(random_string.random.result)}"
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
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = var.subnet_ids
  }

  tags = local.common_tags
}

