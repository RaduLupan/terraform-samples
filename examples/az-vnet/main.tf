# This template deploys the following Azure resources:
#  - 1 x Resource Group
#  - 1 x Virtual Network with 1 x Subnet called frontend
#  - 1 x Network Security Group associated with the frontend subnet that allows incoming SSH from restricted location and TCP 80 from anywhere
#  - 1 x Service Endpoint for Microsoft.KeyVault on the frontend subnet

# Terraform 0.12 syntax is used so 0.12 is the minimum required version
terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
    version = "2.0.0"
    subscription_id = var.subscriptionID
    features {}
}

# Use locals block for simple constants or calculated variables https://www.terraform.io/docs/configuration/locals.html
locals {
    project = "terraform-samples"
    environment = "dev"
}
resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.project}"
  location = var.location
}

resource "azurerm_network_security_group" "frontend-nsg" {
  name                = "nsg-frontend"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow-tcp-80-rule" {
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
  network_security_group_name = azurerm_network_security_group.frontend-nsg.name
}

resource "azurerm_network_security_rule" "allow-ssh-rule" {
  name                        = "allow-tcp-22"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.allowedSshAddressPrefix
  destination_address_prefix  = "*"
  description                 = "Allows SSH from restricted CIDR range"  
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.frontend-nsg.name
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "virtualNetwork1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vNetAddressSpace]

  tags = {
    environment = "${local.environment}"
    project = "${local.project}"
  }
}

resource "azurerm_subnet" "subnet1" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix       = var.frontEndSubnetAddressPrefix
  service_endpoints    =["Microsoft.KeyVault"] 
}

resource "azurerm_subnet_network_security_group_association" "frontend-nsg-association" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.frontend-nsg.id
}