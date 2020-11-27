# This template deploys the following Azure resources:
# - 1 x Storage Account with 1 x blob container
# - 1 x CDN profile with 1 x endpoint pointing to the blob storage for origin

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

# Local calculated variables
locals {
  project            = "terraform-samples"
  resource_group     = var.resource_group == null ? azurerm_resource_group.rg[0].name : var.resource_group
  cached_content_url = "http://${azurerm_cdn_endpoint.cdn_endpoint.name}.azureedge.net/${azurerm_storage_container.container.name}/<BlobName>"
}

# Create Resource Group if var.resource_group is null
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

# The random string needed for injecting randomness in the storage account and blob container names.
resource "random_string" "random" {
  length  = 4
  special = false
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "st${var.environment}${lower(random_string.random.result)}"
  resource_group_name      = local.resource_group
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
    project     = local.project
    terraform   = "true"
  }
}

resource "azurerm_storage_container" "container" {
  name = "${local.project}-${var.environment}-${var.location}-${lower(random_string.random.result)}"

  # Blob access type means "anonymous read access for blobs only". 
  container_access_type = "blob"

  storage_account_name = azurerm_storage_account.storage_account.name
}

resource "azurerm_cdn_profile" "cdn_profile" {
  name                = "cdn-profile-${var.environment}-${lower(random_string.random.result)}"
  location            = var.location
  resource_group_name = local.resource_group
  sku                 = var.cdn_sku

  tags = {
    environment = var.environment
    project     = local.project
    terraform   = "true"
  }
}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  # Creates the CDN endpoint name out of the domain name to ensure uniqueness, i.e. cdn-example-com
  name                = join("-", ["cdn", replace(var.cdn_endpoint_domain, ".", "-")])
  profile_name        = azurerm_cdn_profile.cdn_profile.name
  location            = var.location
  resource_group_name = local.resource_group

  origin {
    name = "cdn-endpoint-origin"
    # Connect CDN endpoint to blob storage origin. Access cached content via http://<endpoint-name>.azureedge.net/<myPublicContainer>/<BlobName>.
    host_name = azurerm_storage_account.storage_account.primary_blob_host
  }

  origin_host_header = azurerm_storage_account.storage_account.primary_blob_host
}