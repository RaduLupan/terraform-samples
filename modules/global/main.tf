# This template deploys the following Azure resources:
# - 1 x Key Vault in existing resource group
# - The Key Vault firewall allows traffic from existing vnet subnet via service endpoint
# - Key Vault Access Policies for multiple existing VMs allowing them to access keys/secrets/certificates
# - 1 x Storage Account with 1 x blob container
# - 1 x CDN profile with 1 x endpoint pointing to the blob storage for origin

terraform {
  required_version = "~> 0.13.0"
}

locals {
    project = "terraform-samples-modules"
    role= "global"
}

# The random string needed for injecting randomness in the name for storage account, blob container and key vault.
resource "random_string" "random" {
  length = 4
  special = false
}

## Use this data source to access the configuration of the AzureRM provider.
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "az_key_vault" {
  name                        = "kv-${var.environment}-${lower(random_string.random.result)}"
  location                    = var.location
  resource_group_name         = var.resource_group
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

  tags = {
    environment = var.environment
    project     = "${local.project}"
    role        = "${local.role}"
  }
}

# Use this data source to access information about an existing Virtual Machine.
data "azurerm_virtual_machine" "web" {
  count = var.vm_count
  
  name                = "vm-${var.server_name}-${count.index}"
  resource_group_name = var.resource_group
}

resource "azurerm_key_vault_access_policy" "web_key_vault_access_policy" {
  count = var.vm_count

  key_vault_id = azurerm_key_vault.az_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  
  # In order to be able to export the identity of a VM I had to upgrade the provider version to 2.10.0.
  # https://github.com/terraform-providers/terraform-provider-azurerm/pull/6826
  # Also, had to check the properties of a VM in terraform.tfstate file to figure out that identity is a list, identity[0] is the first object in that list
  # and principal_id is one of its properties.
  # Finally, in order to resolve ${count.index} you need to enclose it in quotes, NOT the entire expresion as a Powershell user might think!
  object_id    = data.azurerm_virtual_machine.web["${count.index}"].identity[0].principal_id
  
  key_permissions = [
    "get",
    "list",
    "create",
    "update",
  ]

  secret_permissions = [
    "get",
    "list",
    "set",
    "restore",
  ]

  certificate_permissions = [
    "get",
    "list",
    "create",
    "update",
  ]
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "st${var.environment}${lower(random_string.random.result)}"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

# Public access is required for CDN to be able to serve content from the blob container.
  allow_blob_public_access = "true"

  network_rules {
    default_action = "Allow"
  }

  # If no SSL certificate present you need to disable https_traffic_only
  enable_https_traffic_only = "false"

  tags = {
    environment = var.environment
    project = "${local.project}"
  }
}

resource "azurerm_storage_container" "container" {
  name                  = "${local.project}-${var.environment}-${var.location}-${lower(random_string.random.result)}"
  # Blob access type means "anonymous read access for blobs only". 
  container_access_type = "blob"
  storage_account_name  = azurerm_storage_account.storage_account.name
}

resource "azurerm_cdn_profile" "cdn_profile" {
  name                = "cdn-profile-${var.environment}-${lower(random_string.random.result)}"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = var.cdn_sku

  tags = {
    environment = var.environment
    project = "${local.project}"
  }
}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  # Creates the CDN endpoint name out of the domain name to ensure uniqueness, i.e. cdn-example-com
  name                = join("-",["cdn",replace(var.cdn_endpoint_domain,".","-")])
  profile_name        = azurerm_cdn_profile.cdn_profile.name
  location            = var.location
  resource_group_name = var.resource_group

  origin {
    name      = "cdn-endpoint-origin"
    # Connect CDN endpoint to blob storage origin. Access cached content via http://<endpoint-name>.azureedge.net/<myPublicContainer>/<BlobName>.
    host_name = azurerm_storage_account.storage_account.primary_blob_host
  }
  
  origin_host_header = azurerm_storage_account.storage_account.primary_blob_host
}
