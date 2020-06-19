provider "azurerm" {
    version = "2.0.0"
    subscription_id = var.subscriptionID
    features {}
}

module "vnet" {
    source = "../../modules/vnet"
    subscriptionID = var.subscriptionID
    location = "eastus2"
    vNetAddressSpace ="10.0.0.0/16"
    frontEndSubnetAddressPrefix = "10.0.0.0/24"
    allowedSshAddressPrefix = "135.23.87.216/32"
}
