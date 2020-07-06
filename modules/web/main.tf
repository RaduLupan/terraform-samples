locals {
    project = "terraform-samples-modules"
    environment = "dev"
    role= "web"
}

resource "azurerm_public_ip" "pip1" {
  name                = "lb-public-ip"
  resource_group_name = var.resourceGroup
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "web_loadbalancer" {
  name                = "web-loadbalancer"
  location            = var.location
  resource_group_name = var.resourceGroup
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "lb-public-ip"
    public_ip_address_id = azurerm_public_ip.pip1.id
  }
}

resource "azurerm_lb_backend_address_pool" "web_lb_pool" {
  resource_group_name = var.resourceGroup
  loadbalancer_id     = azurerm_lb.web_loadbalancer.id
  name                = "lb-backend-pool"
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
  name                           = "lb-http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-public-ip"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.web_lb_pool.id
  probe_id                       = azurerm_lb_probe.web_lb_probe.id   
}

resource "azurerm_network_interface" "nic" {
  count = var.vmNumber

  name                = "nic-${var.serverName}-${count.index}"
  location            = var.location
  resource_group_name = var.resourceGroup

  ip_configuration {
    name                                    = "ip-config-${count.index}"
    subnet_id                               = var.subnetId
    private_ip_address_allocation           = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_backend_address_pool_association" {
  count = var.vmNumber
  
  network_interface_id    = element(azurerm_network_interface.nic.*.id, count.index)
  ip_configuration_name   = "ip-config-${count.index}"
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
  identity {
    type = "SystemAssigned"
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

# Use this data source to access information about an existing Resource Group.
# We will need the Resource Group Id to scope the rbac role assignement for the VMs.
data "azurerm_resource_group" "current" {
  name = var.resourceGroup
}

# The Service Principal that Terraform uses needs to be able to create RBAC role assignments on the defined scope.
# I had to elevate my Terraform Service Principal to Owner in order to be able to assign the Contributor role to the VM.
resource "azurerm_role_assignment" "rbac_role_assignment_vm" {
  count =  var.vmNumber
   
  scope              = data.azurerm_resource_group.current.id
  role_definition_name = "Contributor"

  # To figure out the referencing of principal_id of a VM in a list I had to ckeck out the VM list properties in terraform.tfstate file.
  principal_id       = azurerm_virtual_machine.web_vm[count.index].identity[0].principal_id
  
}

# Creates inbound NAT rules on the LB for each VM on different frontend port but there is no target parameter to point to the VM.
resource "azurerm_lb_nat_rule" "web_lb_nat_rule" {
  count = var.vmNumber

  resource_group_name            = var.resourceGroup
  loadbalancer_id                = azurerm_lb.web_loadbalancer.id
  name                           = "ssh-${var.serverName}-${count.index}"
  protocol                       = "Tcp"
  frontend_port                  = "5000${count.index}"
  backend_port                   = 22
  frontend_ip_configuration_name = "lb-public-ip"
}

# Creates NAT rule association for each VM's NIC in effect completing the target part of the inbound NAT rules.
resource "azurerm_network_interface_nat_rule_association" "nic_nat_rule_association" {
  count = var.vmNumber

  network_interface_id  = element(azurerm_network_interface.nic.*.id, count.index)
  ip_configuration_name = "ip-config-${count.index}"
  nat_rule_id           = element(azurerm_lb_nat_rule.web_lb_nat_rule.*.id, count.index)
}