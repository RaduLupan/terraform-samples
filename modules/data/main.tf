# This template deploys the following Azure resources:
# - 1 x Database for MySQL Server

# Terraform 0.12 syntax is used so 0.12 is the minimum required version
terraform {
  required_version = ">= 0.12"
}

locals {
    project = "terraform-samples-modules"
}

resource "azurerm_mysql_server" "mysql_server" {
  name                = "db-mysql-${local.project}-${var.environment}-01"
  location            = var.location
  resource_group_name = var.resourceGroup

  administrator_login          = var.adminLogin
  administrator_login_password = var.adminLoginPassword

  sku_name   = var.serverSku
  storage_mb = var.serverStorageMb
  version    = var.serverVersion

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = true
  # Turning off public network access means that only private endpoint connections will be allowed.
  # If you want to be able to create vnet rules in the server firewall you need public access enabled.
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

# Virtual Network rules do not work on Basic Sku, make sure you use a General Purpose or Memory Optimized server.
# https://docs.microsoft.com/en-us/azure/mysql/concepts-data-access-and-security-vnet
resource "azurerm_mysql_virtual_network_rule" "mysql_vnet_rule" {
  name                = "rule-allow-frontend-subnet"
  resource_group_name = var.resourceGroup
  server_name         = azurerm_mysql_server.mysql_server.name
  subnet_id           = var.subnetId
}

resource "azurerm_mysql_database" "mysql_db" {
  name                = "mysql-db-01"
  resource_group_name = var.resourceGroup
  server_name         = azurerm_mysql_server.mysql_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}