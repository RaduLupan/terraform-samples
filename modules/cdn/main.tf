# - 1 x Storage Account with 1 x blob container
# - 1 x CDN profile with 1 x endpoint pointing to the blob storage for origin

terraform {
  required_version = "~> 0.13.0"
}

locals {
  common_tags = {
    terraform   = true
    environment = var.environment
    project     = "terraform-samples-modules"
    role        = "cdn"
  }
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

  tags = local.common_tags
}

resource "azurerm_storage_container" "container" {
  name = "${local.common_tags["project"]}-${var.environment}-${var.location}-${lower(random_string.random.result)}"
  # Blob access type means "anonymous read access for blobs only". 
  container_access_type = "blob"
  storage_account_name  = azurerm_storage_account.storage_account.name
}

resource "azurerm_cdn_profile" "cdn_profile" {
  name                = "cdn-profile-${var.environment}-${lower(random_string.random.result)}"
  location            = var.location
  resource_group_name = var.resource_group
  sku                 = var.cdn_sku

  tags = local.common_tags
}

resource "azurerm_cdn_endpoint" "cdn_endpoint" {
  # Creates the CDN endpoint name out of the domain name to ensure uniqueness, i.e. cdn-example-com
  name                = join("-", ["cdn", replace(var.cdn_endpoint_domain, ".", "-")])
  profile_name        = azurerm_cdn_profile.cdn_profile.name
  location            = var.location
  resource_group_name = var.resource_group

  origin {
    name = "cdn-endpoint-origin"
    # Connect CDN endpoint to blob storage origin. Access cached content via http://<endpoint-name>.azureedge.net/<myPublicContainer>/<BlobName>.
    host_name = azurerm_storage_account.storage_account.primary_blob_host
  }

  origin_host_header = azurerm_storage_account.storage_account.primary_blob_host
}
