locals {
    project = "terraform-samples-modules"
    environment = "dev"
    role= "global"
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

  # Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to false.
  enabled_for_deployment = true

  # Uncomment this line if Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.
  # enabled_for_disk_encryption = true

  # Uncomment this line if Azure Resource Manager is permitted to retrieve secrets from the key vault.
  # enabled_for_template_deployment = true

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = var.subnetIds
  }

  tags = {
    environment = "${local.environment}"
    project     = "${local.project}"
    role        = "${local.role}"
  }
}

# Use this data source to access information about an existing Virtual Machine.
data "azurerm_virtual_machine" "web" {
  count = var.vmNumber
  
  name                = "vm-${var.serverName}-${count.index}"
  resource_group_name = var.resourceGroup
}