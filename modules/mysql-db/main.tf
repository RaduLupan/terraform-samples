# This template deploys the following Azure resources:
# - 1 x Database for MySQL Server

terraform {
  required_version = "~> 0.13.0"
}

# Local calculated variables
locals {
  common_tags = {
    terraform   = true
    environment = var.environment
    project     = "terraform-samples-modules"
    role        = "data"
  }

  resource_group = var.resource_group == null ? azurerm_resource_group.rg[0].name : var.resource_group

  # If server_sku starts with "B" it's the basic tier. General purpose skus start with GP and memory optimized start with MO: B_Gen5_2, GP_Gen5_4, MO_Gen5_2, etc. 
  # Boolean flags turned on/off if basic tier of mysql server is chosen.
  public_network_access_enabled     = lower(substr(var.server_sku, 0, 1)) == "b" ? true : false
  infrastructure_encryption_enabled = lower(substr(var.server_sku, 0, 1)) == "b" ? false : true
}

# Create Resource Group if var.resource_group is null
resource "azurerm_resource_group" "rg" {
  count = var.resource_group == null ? 1 : 0

  name     = "rg-${lower(replace(var.location, " ", ""))}-${local.common_tags["project"]}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

resource "azurerm_mysql_server" "mysql_server" {
  name                = "db-mysql-${local.common_tags["project"]}-${var.environment}-01"
  location            = var.location
  resource_group_name = local.resource_group

  administrator_login          = var.admin_login
  administrator_login_password = var.admin_password

  sku_name   = var.server_sku
  storage_mb = var.server_storage_mb
  version    = var.server_version

  auto_grow_enabled            = true
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  # Encryption not supported on basic tier. Uncomment if infrastructure double encryption is supported.
  # https://docs.microsoft.com/en-us/azure/mysql/concepts-infrastructure-double-encryption

  # infrastructure_encryption_enabled = local.infrastructure_encryption_enabled

  # Turning off public network access is supported only on general purpose and memory optimized pricing tiers, not basic.
  public_network_access_enabled    = local.public_network_access_enabled
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  tags = local.common_tags
}

resource "azurerm_mysql_database" "mysql_db" {
  name                = "mysql-db-01"
  resource_group_name = local.resource_group
  server_name         = azurerm_mysql_server.mysql_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}