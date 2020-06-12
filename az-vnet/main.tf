provider "azurerm" {
    version = "2.0.0"
    subscription_id = var.subscriptionID
    features {}
}

resource "azurerm_network_security_group" "frontend-nsg" {
  name                = "frontend-nsg"
  location            = var.location
  resource_group_name = var.resourceGroupName
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
  resource_group_name         = var.resourceGroupName
  network_security_group_name = azurerm_network_security_group.frontend-nsg.name
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "virtualNetwork1"
  location            = var.location
  resource_group_name = var.resourceGroupName
  address_space       = [var.vNetAddressSpace]
  
  subnet {
    name           = "frontend"
    address_prefix = var.frontEndSubnetAddressPrefix
  }

  tags = {
    environment = "Test"
  }
}