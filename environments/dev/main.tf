provider "azurerm" {
    version         = "2.10.0"
    subscription_id = var.subscriptionID
    features {
        # Terraform will automatically recover a soft-deleted Key Vault during creation if one is found.
        # This feature opts out of this behaviour.
        key_vault {
            purge_soft_delete_on_destroy = true
        }
    }
}

module "network" {
    source = "../../modules/network"
    
    subscriptionID              = var.subscriptionID
    location                    = "eastus2"
    vNetAddressSpace            = "10.0.0.0/16"
    frontEndSubnetAddressPrefix = "10.0.0.0/24"
    allowedSshAddressPrefix     = "135.23.87.216/32"
}

module "web" {
    source = "../../modules/web"
    
    subscriptionID              = var.subscriptionID
    location                    = "eastus2"
    resourceGroup               = module.vnet.rg-name 
    subnetId                    = module.vnet.fe-subnet-id
    serverName                  = "lin-vm"
    vmNumber                    = 2
}
