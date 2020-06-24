provider "azurerm" {
    version = "2.0.0"
    subscription_id = var.subscriptionID
    features {}
}

# Use locals block for simple constants or calculated variables https://www.terraform.io/docs/configuration/locals.html
locals {
    project = "terraform-samples"
    environment = "dev"
    role= "web"
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

resource "azurerm_virtual_machine" "web-vm" {
  count = var.vmNumber

  name                  = "vm-${var.serverName}-${count.index}"
  location              = var.location
  resource_group_name   = var.resourceGroup
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
    name              = "os-disk-${var.serverName}-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "var.serverName-${count.index}"
    admin_username = "azureadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "${local.environment}"
    project = "${local.project}"
    role= "${local.role}"
  }
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  count = var.vmNumber

  name                 = "var.serverName-${count.index}"
  virtual_machine_id   = element(azurerm_virtual_machine.web-vm.*.id, count.index)
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "apt-get -y update && apt-get install -y apache2"
    }
SETTINGS
}