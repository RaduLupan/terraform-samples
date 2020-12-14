# This module deploys the following Azure resources:
# - 1 x Load Balancer with 1 x Public IP, 1 x Backend Pool, 1 x Probe and 1 x Rule
# - A number of vm_count Linux Virtual Machines in an existing Resource Group and existing Virtual Network/Subnet
# - No Network Security Group for VMs as they inherit the NSG applied at the subnet level
# - Custom script VM extensions for all VMs that install Apache
# - Connects the VM NICs to the Load Balancer Backend Pool via azurerm_network_interface_backend_address_pool_association
# - SystemAssigned Identities for all VMs with corresponding RBAC role assignments that give Contributor role scoped to the current resource group
# - 1 x Storage Account used for boot diags for VMs and everything else
# - Key Vault Access Policies for multiple existing VMs allowing them to access keys/secrets/certificates

# Terraform 0.12 syntax is used so 0.12 is the minimum required version
terraform {
  required_version = "~> 0.13.0"
}

locals {
  common_tags = {
    project                = "terraform-samples-lb-vm"
    role                   = "web"
    environment            = var.environment
    terraform              = true
  }
  
  vnet_location          = var.vnet_resource_group == null ? var.location : data.azurerm_virtual_network.selected[0].location
  subnet_id              = var.vnet_resource_group == null ? azurerm_subnet.default[0].id : "${data.azurerm_virtual_network.selected[0].id}/subnets/${var.subnet_name}"
  vnet_resource_group    = var.vnet_resource_group == null ? azurerm_resource_group.rg[0].name : var.vnet_resource_group
  vnet_resource_group_id = var.vnet_resource_group == null ? azurerm_resource_group.rg[0].id : data.azurerm_resource_group.current[0].id
}

# Create resource group if var.vnet_resource_group is null
resource "azurerm_resource_group" "rg" {
  count = var.vnet_resource_group == null ? 1 : 0

  name     = "rg-${lower(replace(var.location, " ", ""))}-${local.common_tags["project"]}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

# Create default vnet if var.vnet_resource_group is null
resource "azurerm_virtual_network" "default" {
  count = var.vnet_resource_group == null ? 1 : 0

  name                = "vnet-${local.common_tags["project"]}-${var.environment}-01"
  location            = var.location
  resource_group_name = local.vnet_resource_group
  address_space       = ["172.31.0.0/16"]

  tags = local.common_tags
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

resource "azurerm_public_ip" "pip1" {
  name                = "lb-public-ip"
  resource_group_name = local.vnet_resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "web_loadbalancer" {
  name                = "lb-web-${var.environment}-01"
  location            = var.location
  resource_group_name = local.vnet_resource_group
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "lb-public-ip"
    public_ip_address_id = azurerm_public_ip.pip1.id
  }
}

resource "azurerm_lb_backend_address_pool" "web_lb_pool" {
  resource_group_name = local.vnet_resource_group
  loadbalancer_id     = azurerm_lb.web_loadbalancer.id
  name                = "lb-backend-pool"
}

resource "azurerm_lb_probe" "web_lb_probe" {
  resource_group_name = local.vnet_resource_group
  loadbalancer_id     = azurerm_lb.web_loadbalancer.id
  name                = "http-running-probe"
  port                = 80
  protocol            = "Http"   
  request_path        = "/"
}

resource "azurerm_lb_rule" "web_lb_http_rule" {
  resource_group_name            = local.vnet_resource_group
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
  count = var.vm_count

  name                                      = "nic-${var.server_name}-0${count.index}"
  location                                  = var.location
  resource_group_name                       = local.vnet_resource_group
  ip_configuration {
    name                                    = "ip-config-0${count.index}"
    subnet_id                               = local.subnet_id
    private_ip_address_allocation           = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_backend_address_pool_association" {
  count = var.vm_count
  
  network_interface_id    = element(azurerm_network_interface.nic.*.id, count.index)
  ip_configuration_name   = "ip-config-0${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web_lb_pool.id
}

resource "azurerm_virtual_machine" "web_vm" {
  count = var.vm_count

  name                  = "vm-${var.server_name}-0${count.index}"
  location              = var.location
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
    name              = "os-disk-${var.server_name}-0${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.server_name}-0${count.index}"
    admin_username = var.vm_admin_user
    admin_password = var.vm_admin_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  identity {
    type = "SystemAssigned"
  }
  boot_diagnostics {
    enabled     = true
    storage_uri = join(",", azurerm_storage_account.storage_account.*.primary_blob_endpoint)
  }

  tags = local.common_tags
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  count = var.vm_count

  name                 = "var.server_name-0${count.index}"
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

  name = local.vnet_resource_group
}

# The Service Principal that Terraform uses needs to be able to create RBAC role assignments on the defined scope.
# I had to elevate my Terraform Service Principal to Owner in order to be able to assign the Contributor role to the VM.
resource "azurerm_role_assignment" "rbac_role_assignment_vm" {
  count =  var.vm_count
   
  scope              = local.vnet_resource_group_id
  role_definition_name = "Contributor"

  # To figure out the referencing of principal_id of a VM in a list I had to ckeck out the VM list properties in terraform.tfstate file.
  principal_id       = azurerm_virtual_machine.web_vm[count.index].identity[0].principal_id
  
}

# Creates inbound NAT rules on the LB for each VM on different frontend port but there is no target parameter to point to the VM.
resource "azurerm_lb_nat_rule" "web_lb_nat_rule" {
  count = var.vm_count

  resource_group_name            = local.vnet_resource_group
  loadbalancer_id                = azurerm_lb.web_loadbalancer.id
  name                           = "ssh-${var.server_name}-0${count.index}"
  protocol                       = "Tcp"
  frontend_port                  = "5000${count.index}"
  backend_port                   = 22
  frontend_ip_configuration_name = "lb-public-ip"
}

# Creates NAT rule association for each VM's NIC in effect completing the target part of the inbound NAT rules.
resource "azurerm_network_interface_nat_rule_association" "nic_nat_rule_association" {
  count = var.vm_count

  network_interface_id  = element(azurerm_network_interface.nic.*.id, count.index)
  ip_configuration_name = "ip-config-0${count.index}"
  nat_rule_id           = element(azurerm_lb_nat_rule.web_lb_nat_rule.*.id, count.index)
}

# Random string for the storage account name. Must be 3-24 characters, lowercase letters and numbers.
resource "random_string" "random" {
  length = 8
  special = false
}

# Create one storage account for VMs boot diags and everything else.
resource "azurerm_storage_account" "storage_account" {
  name                     = "st${var.environment}${lower(random_string.random.result)}"
  resource_group_name      = local.vnet_resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Restrict access to storage account endpoint to the vnet subnet via service endpoint.
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [local.subnet_id]
  }

  tags = local.common_tags
}

/*
########### From refactored key-vault module - TO BE INTEGRATED HERE ############

# Use this data source to access information about an existing Virtual Machine.
data "azurerm_virtual_machine" "web" {
  count = var.vm_count

  name                = "vm-${var.server_name}-${count.index}"
  resource_group_name = var.resource_group
}

resource "azurerm_key_vault_access_policy" "web_key_vault_access_policy" {
  count = var.vm_count

  key_vault_id = azurerm_key_vault.az_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  # In order to be able to export the identity of a VM I had to upgrade the provider version to 2.10.0.
  # https://github.com/terraform-providers/terraform-provider-azurerm/pull/6826
  # Also, had to check the properties of a VM in terraform.tfstate file to figure out that identity is a list, identity[0] is the first object in that list
  # and principal_id is one of its properties.
  # Finally, in order to resolve ${count.index} you need to enclose it in quotes, NOT the entire expresion as a Powershell user might think!
  object_id = data.azurerm_virtual_machine.web["${count.index}"].identity[0].principal_id

  key_permissions = [
    "get",
    "list",
    "create",
    "update",
  ]

  secret_permissions = [
    "get",
    "list",
    "set",
    "restore",
  ]

  certificate_permissions = [
    "get",
    "list",
    "create",
    "update",
  ]
}
*/