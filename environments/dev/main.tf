provider "azurerm" {
    version         = "2.0.0"
    subscription_id = var.subscriptionID
    features {}
}

module "network-tier" {
    source = "../../modules/network-tier"
    
    subscriptionID              = var.subscriptionID
    location                    = "eastus2"
    vNetAddressSpace            = "10.0.0.0/16"
    frontEndSubnetAddressPrefix = "10.0.0.0/24"
    allowedSshAddressPrefix     = "135.23.87.216/32"
}

module "web-tier" {
    source = "../../modules/web-tier"
    
    subscriptionID              = var.subscriptionID
    location                    = "eastus2"
    resourceGroup               = module.vnet.rg-name 
    subnetId                    = module.vnet.fe-subnet-id
    serverName                  = "lin-vm"
    vmNumber                    = 2
}
