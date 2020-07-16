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
    location                    = "eastus2"
    environment                 = "dev"
    vNetAddressSpace            = "10.0.0.0/16"
    frontEndSubnetAddressPrefix = "10.0.0.0/24"
    allowedSshAddressPrefix     = "135.23.87.216/32"
}

module "web" {
    source = "../../modules/web"
    
    subscriptionID              = var.subscriptionID
    location                    = "eastus2"
    resourceGroup               = module.network.rg-name 
    environment                 = "dev"
    subnetId                    = module.network.fe-subnet-id
    serverName                  = "ubuntu"
    vmNumber                    = 2
}

module "global" {
    source = "../../modules/global"
    
    subscriptionID              = var.subscriptionID
    location                    = "eastus2"
    resourceGroup               = module.network.rg-name 
    environment                 = "dev"
    subnetIds                   = [module.network.fe-subnet-id]
    serverName                  = "ubuntu"
    vmNumber                    = 2
    cdnSku                      = "Standard_Verizon"
    cdnEndpointDomain           = "dev.lupan.ca"
}

module "data" {
    source = "../../modules/data"
    
    subscriptionID              = var.subscriptionID
    location                    = "eastus2"
    resourceGroup               = module.network.rg-name 
    environment                 = "dev"
    adminLogin                  = "mysqladmin"
    adminLoginPassword          = "DontLeaveMeInPlainText!"
    serverSku                   = "GP_Gen5_2"
    serverStorageMb             = 5120
    serverVersion               = "5.7"
    subnetId                    = module.network.fe-subnet-id
}
