locals {
    project = "terraform-samples-modules"
    environment = "dev"
    role= "web-tier"
}

resource "azurerm_public_ip" "pip01" {
  name                = "LBPublicIp"
  resource_group_name = var.resourceGroup
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "web_loadbalancer" {
  name                = "WebLoadBalancer"
  location            = var.location
  resource_group_name = var.resourceGroup
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LB-PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip01.id
  }
}

resource "azurerm_lb_backend_address_pool" "web_lb_pool" {
  resource_group_name = var.resourceGroup
  loadbalancer_id     = azurerm_lb.web_loadbalancer.id
  name                = "LB-BackendPool"
}

resource "azurerm_lb_probe" "web_lb_probe" {
  resource_group_name = var.resourceGroup
  loadbalancer_id     = azurerm_lb.web_loadbalancer.id
  name                = "http-running-probe"
  port                = 80
  protocol            = "Http"   
  request_path        = "/"
}

resource "azurerm_lb_rule" "web_lb_http_rule" {
  resource_group_name            = var.resourceGroup
  loadbalancer_id                = azurerm_lb.web_loadbalancer.id
  name                           = "LB-Http-Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LB-PublicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.web_lb_pool.id
  probe_id                       = azurerm_lb_probe.web_lb_probe.id   
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
  backend_address_pool_id = azurerm_lb_backend_address_pool.web_lb_pool.id
}

resource "azurerm_virtual_machine" "web_vm" {
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

## Creates inbound NAT rules on the LB for each VM on different frontend port but there is no target parameter to point to the VM
resource "azurerm_lb_nat_rule" "web_lb_nat_rule" {
  count = var.vmNumber

  resource_group_name            = var.resourceGroup
  loadbalancer_id                = azurerm_lb.web_loadbalancer.id
  name                           = "ssh-var.serverName-${count.index}"
  protocol                       = "Tcp"
  frontend_port                  = "5000${count.index}"
  backend_port                   = 22
  frontend_ip_configuration_name = "LB-PublicIPAddress"
}

## Creates NAT rule association for each VM's NIC in effect completing the target part of the inbound NAT rules
resource "azurerm_network_interface_nat_rule_association" "nic_nat_rule_association" {
  count = var.vmNumber

  network_interface_id  = element(azurerm_network_interface.nic.*.id, count.index)
  ip_configuration_name = "IPconfiguration-${count.index}"
  nat_rule_id           = element(azurerm_lb_nat_rule.web_lb_nat_rule.*.id, count.index)
}