provider "azurerm" {
    # Version 2.10.0 required in order to be able to export the identity of a VM.
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
    location                    = "Canada Central"
    vNetAddressSpace            = "172.16.0.0/16"
    frontEndSubnetAddressPrefix = "172.16.1.0/24"
    allowedSshAddressPrefix     = "135.23.87.216/32"
}

module "web" {
    source = "../../modules/web"
    
    subscriptionID              = var.subscriptionID
    location                    = "Canada Central"
    resourceGroup               = module.network.rg-name 
    subnetId                    = module.network.fe-subnet-id
    serverName                  = "ubuntu"
    vmNumber                    = 2
}

module "global" {
    source = "../../modules/global"
    
    subscriptionID              = var.subscriptionID
    location                    = "Canada Central"
    resourceGroup               = module.network.rg-name 
    subnetIds                   = [module.network.fe-subnet-id]
    serverName                  = "ubuntu"
    vmNumber                    = 2
}
