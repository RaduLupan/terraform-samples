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
    location                    = "canadacentral"
    environment                 = "stage"
    vNetAddressSpace            = "172.16.0.0/16"
    frontEndSubnetAddressPrefix = "172.16.1.0/24"
    allowedSshAddressPrefix     = "135.23.87.216/32"
}

module "web" {
    source = "../../modules/web"
    
    subscriptionID              = var.subscriptionID
    location                    = "canadacentral"
    resourceGroup               = module.network.rg-name 
    environment                 = "stage"
    subnetId                    = module.network.fe-subnet-id
    serverName                  = "ubuntu"
    vmNumber                    = 2
    vmAdminUser                 = "azureadmin"
    # Password in clear text alert! Better to create an environment variable TF_VAR_vmAdminPassword or type it in at terraform plan phase.
    vmAdminPassword             = "DontLeaveMeInPlainText!"
}

module "global" {
    source = "../../modules/global"
    
    subscriptionID              = var.subscriptionID
    location                    = "canadacentral"
    resourceGroup               = module.network.rg-name
    environment                 = "stage" 
    subnetIds                   = [module.network.fe-subnet-id]
    serverName                  = "ubuntu"
    vmNumber                    = 2
    cdnSku                      = "Standard_Akamai"
    cdnEndpointDomain           = "stage.lupan.ca"
}

module "data" {
    source = "../../modules/data"
    
    subscriptionID              = var.subscriptionID
    location                    = "canadacentral"
    resourceGroup               = module.network.rg-name 
    environment                 = "stage"
    adminLogin                  = "mysqladmin"
    # Password in clear text alert! Better to create an environment variable TF_VAR_adminLoginPassword or type it in at terraform plan phase.
    adminLoginPassword          = "DontLeaveMeInPlainText!"
    serverSku                   = "GP_Gen5_2"
    serverStorageMb             = 5120
    serverVersion               = "5.7"
    subnetId                    = module.network.fe-subnet-id
}
