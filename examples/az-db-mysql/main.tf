# This template deploys the following Azure resources:
# - 1 x Database for MySQL Server

# Terraform 0.12 syntax is used so 0.12 is the minimum required version
terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
    version = "2.10.0"
    subscription_id = var.subscriptionID
    features {}
}

locals {
    project = "terraform-samples"
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
  # Turning off public network access is supported only on General Purpose and Memory Optimized pricing tiers.
  # It does not work for basic Sku such as B_Gen5_2.
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_database" "mysql_db" {
  name                = "mysql-db-01"
  resource_group_name = var.resourceGroup
  server_name         = azurerm_mysql_server.mysql_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}