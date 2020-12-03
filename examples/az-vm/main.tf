# This template deploys the following Azure resources:
# - A number of vm_count Linux Virtual Machine 
# - Public IPs associated with all VM NICs
# - No Network Security Group for VMs as they inherit the NSG applied at the subnet level
# - Custom script VM extensions for all VMs that install Azure CLI
# - SystemAssigned Identities for all VMs with corresponding RBAC role assignments that give Contributor role scoped to the current resource group
# - 1 x Storage Account used for boot diags for VMs and everything else

# If var.vnet_resource_group, var.vnet_name and var.subnet_name have not null values then VMs are created in the specified resource group and vNet.
# If var.vnet_resource_group is null then new resource group, new vNet with default subnet are created and the VMs will sit on the default subnet.

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

# Local calculated variables
locals {
  project                = "terraform-samples"
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
    name                          = "ip-config-${count.index}"
    subnet_id                     = local.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_public_ip" "pip" {
  count = var.vm_count

  name                = "pip-${var.server_name}-${count.index}"
  resource_group_name = local.vnet_resource_group
  location            = local.vnet_location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = var.environment
    project     = local.project
    terraform   = "true"
  }
}

resource "azurerm_virtual_machine" "vm" {
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
  boot_diagnostics {
    enabled     = true
    storage_uri = join(",", azurerm_storage_account.storage_account.*.primary_blob_endpoint)
  }

  tags = {
    environment = var.environment
    project     = local.project
    terraform   = "true"
  }
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  count = var.vm_count

  name                 = "${var.server_name}-${count.index}"
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

# Use this data source to access information about an existing Resource Group.
# We will need the Resource Group Id to scope the rbac role assignement for vm01.
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
  principal_id         = azurerm_virtual_machine.vm[count.index].identity[0].principal_id

}

# Random string for the storage account name. Must be 3-24 characters, lowercase letters and numbers.
resource "random_string" "random" {
  length  = 8
  special = false
}

# Create one storage account for VMs boot diags and everything else.
resource "azurerm_storage_account" "storage_account" {
  name                     = "st${var.environment}${lower(random_string.random.result)}"
  resource_group_name      = local.vnet_resource_group
  location                 = local.vnet_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Restrict access to storage account endpoint to the vnet subnet via service endpoint.
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [local.subnet_id]
  }

 tags = {
    environment = var.environment
    project     = local.project
    terraform   = "true"
  }
}