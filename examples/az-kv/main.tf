provider "azurerm" {
    version = "2.0.0"
    subscription_id = var.subscriptionID
    features {
        # Terraform will automatically recover a soft-deleted Key Vault during creation if one is found.
        # This feature opts out of this behaviour.
        key_vault {
            purge_soft_delete_on_destroy = true
        }
    }
}

locals {
    project = "terraform-samples"
    environment = "dev"
}

## Use this data source to access the configuration of the AzureRM provider.
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "az_key_vault" {
  name                        = "kv-1-${local.environment}"
  location                    = var.location
  resource_group_name         = var.resourceGroup
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]

    storage_permissions = [
      "get",
    ]
  }

  # Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to false.
  enabled_for_deployment = true

  # Uncomment this line if Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.
  # enabled_for_disk_encryption = true

  # Uncomment this line if Azure Resource Manager is permitted to retrieve secrets from the key vault.
  # enabled_for_template_deployment = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = {
    environment = "${local.environment}"
    project     = "${local.project}"
  }
}