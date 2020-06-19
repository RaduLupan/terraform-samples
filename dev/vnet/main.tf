provider "azurerm" {
    version         = "2.0.0"
    subscription_id = var.subscriptionID
    features {}
}

module "vnet" {
    source = "../../modules/vnet"
    
    subscriptionID              = var.subscriptionID
    location                    = "eastus2"
    vNetAddressSpace            ="10.0.0.0/16"
    frontEndSubnetAddressPrefix = "10.0.0.0/24"
    allowedSshAddressPrefix     = "135.23.87.216/32"
}

output "dev-rg-name" {
    value       = module.vnet.rg-name
    description = "The name of the resource group for dev environment."
}

output "dev-fe-nsg-name" {
    value       = module.vnet.fe-nsg-name
    description = "The name of the network security group associated with the frontend subnet."
}