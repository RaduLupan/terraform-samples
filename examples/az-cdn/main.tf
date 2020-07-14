# This template deploys the following Azure resources:
# - 1 x Storage Account with 1 x blob container
# - 1 x CDN profile with 1 x endpoint pointing to the blob storage for origin
# Access to cached content stored in blob storage has been confirmed to be working for Standard_Microsoft CDN SKU.
# For Standard_Akamai CDN profile http://<endpoint-name>.azureedge.net/<myPublicContainer>/<BlobName> does NOT work.
# The Verizon SKUs: Standard_Verizon and Premium_Verizon have not been tested. 

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

# The random string needed for injecting randomness in the storage account and blob container names.
resource "random_string" "random" {
  length = 4
  special = false
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "st${var.environment}${lower(random_string.random.result)}"
  resource_group_name      = var.resourceGroup
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Public access is required for CDN to be able to serve content from the blob container.
  network_rules {
    default_action = "Allow"
  }

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
  resource_group_name = var.resourceGroup
  sku                 = var.cdnSku

  tags = {
    environment = var.environment
    project = "${local.project}"
  }
}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  # Creates the CDN endpoint name out of the domain name to ensure uniqness, i.e. cdn-example-com
  name                = join("-",["cdn",replace(var.cdnEndpointDomain,".","-")])
  profile_name        = azurerm_cdn_profile.cdn_profile.name
  location            = var.location
  resource_group_name = var.resourceGroup

  origin {
    name      = "cdn-endpoint-origin"
    # Connect CDN endpoint to blob storage origin. Access cached content via http://<endpoint-name>.azureedge.net/<myPublicContainer>/<BlobName>.
    host_name = azurerm_storage_account.storage_account.primary_blob_host
  }
  
  origin_host_header = azurerm_storage_account.storage_account.primary_blob_host
}