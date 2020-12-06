# This template deploys the following Azure resources:
# - A number of var.vm_count Linux Virtual Machine in an existing resource group and existing virtual network/subnet
# - No Network Security Group for VMs as they inherit the NSG applied at the subnet level
# - Custom script VM extensions for all VMs that install Apache
# - Connects the VM NICs to an existing load balancer backend pool via azurerm_network_interface_backend_address_pool_association
# - SystemAssigned Identities for all VMs with corresponding RBAC role assignments that give Contributor role scoped to the current resource group

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

# Use locals block for simple constants or calculated variables https://www.terraform.io/docs/configuration/locals.html
locals {
  project                = "terraform-samples-lb-vm"
  vnet_location          = var.vnet_resource_group == null ? var.location : data.azurerm_virtual_network.selected[0].location
  subnet_id              = var.vnet_resource_group == null ? azurerm_subnet.default[0].id : "${data.azurerm_virtual_network.selected[0].id}/subnets/${var.subnet_name}"
  vnet_resource_group    = var.vnet_resource_group == null ? azurerm_resource_group.rg[0].name : var.vnet_resource_group
  vnet_resource_group_id = var.vnet_resource_group == null ? azurerm_resource_group.rg[0].id : data.azurerm_resource_group.current[0].id
}

# Create resource group if var.vnet_resource_group is null
resource "azurerm_resource_group" "rg" {
  count = var.vnet_resource_group == null ? 1 : 0

  name     = "rg-${lower(replace(var.location, " ", ""))}-${local.project}-${var.environment}"
  location = var.location

  tags = {
    environment = var.environment
    project     = local.project
    terraform   = "true"
  }
}

# Create default vnet if var.vnet_resource_group is null
resource "azurerm_virtual_network" "default" {
  count = var.vnet_resource_group == null ? 1 : 0

  name                = "vnet-${local.project}-${var.environment}-01"
  location            = var.location
  resource_group_name = local.vnet_resource_group
  address_space       = ["172.31.0.0/16"]

  tags = {
    environment = var.environment
    project     = local.project
    terraform   = "true"
  }
}

# Create default subnet if var.vnet_resource_group is null
resource "azurerm_subnet" "default" {
  count = var.vnet_resource_group == null ? 1 : 0

  name                 = "default"
  resource_group_name  = local.vnet_resource_group
  virtual_network_name = azurerm_virtual_network.default[0].name
  address_prefixes     = ["172.31.0.0/24"]
  service_endpoints    = ["Microsoft.KeyVault", "Microsoft.Storage"]
}

# Use this data source to access information about an existing vNet.
data "azurerm_virtual_network" "selected" {
  count = var.vnet_resource_group == null ? 0 : 1

  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group
}


resource "azurerm_network_interface" "nic" {
  count = var.vm_count

  name                = "nic-${var.server_name}-${count.index}"
  location            = local.vnet_location
  resource_group_name = local.vnet_resource_group

  ip_configuration {
    name                          = "ip-configuration-${count.index}"
    subnet_id                     = local.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_backend_address_pool_association" {
  count = var.vm_count

  network_interface_id    = element(azurerm_network_interface.nic.*.id, count.index)
  ip_configuration_name   = "ip-configuration-${count.index}"
  backend_address_pool_id = var.lb_backend_pool_id
}

resource "azurerm_virtual_machine" "web_vm" {
  count = var.vm_count

  name                  = "vm-${var.server_name}-${count.index}"
  location              = local.vnet_location
  resource_group_name   = local.vnet_resource_group
  network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]
  vm_size               = "Standard_B1ms"

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "os-disk-${var.server_name}-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.server_name}-${count.index}"
    admin_username = var.vm_admin_user
    admin_password = var.vm_admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = var.environment
    project     = local.project
    terraform   = "true"
  }
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  count = var.vm_count

  name                 = "var.server_name-${count.index}"
  virtual_machine_id   = element(azurerm_virtual_machine.web_vm.*.id, count.index)
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "apt-get -y update && apt-get install -y apache2"
    }
SETTINGS
}

# Use this data source to access information about an existing Resource Group.
# We will need the Resource Group Id to scope the rbac role assignement for the VMs.
data "azurerm_resource_group" "current" {
  count = var.vnet_resource_group == null ? 0 : 1

  name = var.vnet_resource_group
}

# The Service Principal that Terraform uses needs to be able to create RBAC role assignments on the defined scope.
# I had to elevate my Terraform Service Principal to Owner in order to be able to assign the Contributor role to the VM.
resource "azurerm_role_assignment" "rbac_role_assignment_vm" {
  count = var.vm_count

  scope                = local.vnet_resource_group_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_virtual_machine.web_vm[count.index].identity[0].principal_id
}