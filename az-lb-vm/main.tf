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

resource "azurerm_network_interface" "nic" {
  count = var.vmNumber

  name                = "nic-${var.serverName}-${count.index}"
  location            = var.location
  resource_group_name = var.resourceGroup

  ip_configuration {
    name                                    = "IPconfiguration-${count.index}"
    subnet_id                               = var.subnetId
    private_ip_address_allocation           = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_backend_address_pool_association" {
  count = var.vmNumber
  
  network_interface_id    = element(azurerm_network_interface.nic.*.id, count.index)
  ip_configuration_name   = "IPconfiguration-${count.index}"
  backend_address_pool_id = var.lbBackendPoolIDs
}