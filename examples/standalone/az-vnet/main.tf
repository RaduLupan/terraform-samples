# This template deploys the following Azure resources:
#  - 1 x Resource Group
#  - 1 x Virtual Network with 1 x Subnet called frontend
#  - 1 x Network Security Group associated with the frontend subnet that allows incoming SSH from restricted location and TCP 80 from anywhere
#  - 1 x Service Endpoint for Microsoft.KeyVault on the frontend subnet

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

locals {
  project = "terraform-samples"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.project}"
  location = var.location
}

resource "azurerm_network_security_group" "frontend" {
  name                = "nsg-frontend"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_tcp_80" {
  name                        = "allow-tcp-80"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  description                 = "Allows HTTP from anywhere"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.frontend.name
}

# If var.allowed_ssh_address_prefix is not null then create allow_ssh rule
resource "azurerm_network_security_rule" "allow_ssh" {
  count = var.allowed_ssh_address_prefix == null ? 0 : 1

  name                        = "allow-tcp-22"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.allowed_ssh_address_prefix
  destination_address_prefix  = "*"
  description                 = "Allows SSH from restricted CIDR range"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.frontend.name
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.project}-${var.environment}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_address_space]

  tags = {
    environment = var.environment
    project     = local.project
    terraform   = "true"
  }
}

resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.frontend_subnet_address_prefix]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

resource "azurerm_subnet_network_security_group_association" "frontend_nsg_association" {
  subnet_id                 = azurerm_subnet.frontend.id
  network_security_group_id = azurerm_network_security_group.frontend.id
}