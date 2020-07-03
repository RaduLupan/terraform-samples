variable "subscriptionID" {
    type = string
    description = "Target subscription ID"
}

variable "location" {
    type = string
    description = "Location of your resource group"
}

variable "resourceGroup" {
    type = string
    description = "Name of your resource group"
}

variable "subnetIds" {
    type = list(string)
    description = "Subnet Ids for subnets that will connect to Azure Key Vault via service endpoints"
}