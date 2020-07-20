# This template deploys the following Azure resources:
# - A number of vmNumber Linux Virtual Machine in an existing Resource Group and existing Virtual Network/Subnet
# - Public IPs associated with all VM NICs
# - No Network Security Group for VMs as they inherit the NSG applied at the subnet level
# - Custom script VM extensions for all VMs that install Azure CLI
# - SystemAssigned Identities for all VMs with corresponding RBAC role assignments that give Contributor role scoped to the current resource group
# - 1 x Storage Account used for boot diags for VMs and everything else

# Terraform 0.12 syntax is used so 0.12 is the minimum required version
terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
    version = "2.0.0"
    subscription_id = var.subscriptionID
    features {}
}

# Use locals block for simple constants or calculated variables. https://www.terraform.io/docs/configuration/locals.html
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
    name                                    = "ip-config-${count.index}"
    subnet_id                               = var.subnetId
    private_ip_address_allocation           = "Dynamic"
    public_ip_address_id                    = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_virtual_machine" "vm" {
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
    admin_username = var.vmAdminUser
    admin_password = var.vmAdminPassword
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

  tags = {
    environment = "${local.environment}"
    project = "${local.project}"
  }
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  count = var.vmNumber

  name                 = "${var.serverName}-${count.index}"
  virtual_machine_id   = element(azurerm_virtual_machine.vm.*.id, count.index)
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  # Install Azure CLI on Ubuntu as per https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
  settings = <<SETTINGS
    {
        "commandToExecute": "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    }
SETTINGS
}

resource "azurerm_public_ip" "pip" {
  count = var.vmNumber

  name                = "pip-${var.serverName}-${count.index}"
  resource_group_name = var.resourceGroup
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = "${local.environment}"
    project = "${local.project}"
  }
}

# Use this data source to access information about an existing Resource Group.
# We will need the Resource Group Id to scope the rbac role assignement for vm01.
data "azurerm_resource_group" "current" {
  name = var.resourceGroup
}

# The Service Principal that Terraform uses needs to be able to create RBAC role assignments on the defined scope.
# I had to elevate my Terraform Service Principal to Owner in order to be able to assign the Contributor role to the VM.
resource "azurerm_role_assignment" "rbac_role_assignment_vm" {
  count =  var.vmNumber
   
  scope                = data.azurerm_resource_group.current.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_virtual_machine.vm[count.index].identity[0].principal_id
  
}

# Random string for the storage account name. Must be 3-24 characters, lowercase letters and numbers.
resource "random_string" "random" {
  length = 8
  special = false
}

# Create one storage account for VMs boot diags and everything else.
resource "azurerm_storage_account" "storage_account" {
  name                     = "st${local.environment}${lower(random_string.random.result)}"
  resource_group_name      = var.resourceGroup
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Restrict access to storage account endpoint to the vnet subnet via service endpoint.
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [var.subnetId]
  }

  tags = {
    environment = "${local.environment}"
    project = "${local.project}"
  }
}