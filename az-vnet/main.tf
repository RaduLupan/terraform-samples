provider "azurerm" {
    version = "2.0.0"
    subscription_id = var.subscriptionID
    features {}
}

# Use locals block for simple constants or calculated variables https://www.terraform.io/docs/configuration/locals.html
locals {
    project = "TerraformSamples"
    environment = "Test"
}
resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.project}"
  location = var.location
}

resource "azurerm_network_security_group" "frontend-nsg" {
  name                = "frontend-nsg"
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

resource "azurerm_virtual_network" "vnet1" {
  name                = "virtualNetwork1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vNetAddressSpace]
  
  subnet {
    name           = "frontend"
    address_prefix = var.frontEndSubnetAddressPrefix
  }

  tags = {
    environment = "${local.environment}"
  }
}