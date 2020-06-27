# Use locals block for simple constants or calculated variables https://www.terraform.io/docs/configuration/locals.html
locals {
    project = "terraform-samples-modules"
}
resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.project}"
  location = var.location
}

resource "azurerm_network_security_group" "frontend_nsg" {
  name                = "nsg-frontend"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

variable "public_nsg_inbound_rules" {
  type        = map
  description = "A map of allowed inbound ports and their priority values"
  default     = {
    100 = 80
    101 = 443
  }

}

resource "azurerm_network_security_rule" "nsg_inbound_rule" {
  for_each = var.public_nsg_inbound_rules
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

resource "azurerm_network_security_rule" "allow_ssh_rule" {
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
  network_security_group_name = azurerm_network_security_group.frontend_nsg.name
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "virtual-network-1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vNetAddressSpace]

  tags = {
    project = "${local.project}"
  }
}

resource "azurerm_subnet" "subnet1" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix       = var.frontEndSubnetAddressPrefix
}

resource "azurerm_subnet_network_security_group_association" "frontend_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.frontend_nsg.id
}

output "rg-name" {
  value = azurerm_resource_group.rg.name
}

output "fe-subnet-id" {
  value = azurerm_subnet.subnet1.id
}
