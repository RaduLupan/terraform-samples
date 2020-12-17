# This module deploys the following Azure resources:
#  - 1 x Resource Group
#  - 1 x Virtual Network with 1 x Subnet called frontend
#  - 1 x Network Security Group associated with the frontend subnet that allows incoming SSH from restricted location and TCP 80 from anywhere
#  - Service Endpoints for Microsoft.KeyVault, Microsoft.Storage and Microsoft.Sql on the frontend subnet

# Terraform 0.12 syntax is used so 0.12 is the minimum required version
terraform {
  required_version = "~> 0.13.0"
}

# Use locals block for simple constants or calculated variables. 
# https://www.terraform.io/docs/configuration/locals.html
locals {

  common_tags = {
    project     = "terraform-samples-modules"
    role        = "network"
    environment = var.environment
    terraform   = true
  }

  public_nsg_inbound_rules = {
    100 = 80
    101 = 443
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.common_tags["role"]}-${var.environment}-${lower(replace(var.location, " ", ""))}"
  location = var.location
}

resource "azurerm_network_security_group" "frontend_nsg" {
  name                = "nsg-frontend"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Rules created in for_each loop based on mapped port-priority values.
resource "azurerm_network_security_rule" "nsg_inbound_rule" {
  for_each                    = local.public_nsg_inbound_rules
  name                        = "allow-tcp-${each.value}"
  priority                    = each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  description                 = "Allows TCP ${each.value} from anywhere"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.frontend_nsg.name
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
  network_security_group_name = azurerm_network_security_group.frontend_nsg.name
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet-${var.environment}-${lower(replace(var.location, " ", ""))}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_address_space]

  tags = local.common_tags
}

resource "azurerm_subnet" "subnet1" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = [var.frontend_subnet_address_prefix]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage", "Microsoft.Sql"]
}

resource "azurerm_subnet_network_security_group_association" "frontend_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.frontend_nsg.id
}
