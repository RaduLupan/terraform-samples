variable "subscriptionID" {
    type = string
    description = "Target subscription ID"
}

variable "resourceGroupName" {
    type = string
    description = "Name of resource group"
}

variable "location" {
    type = string
    description = "Location of your resource group"
}

variable "vNetAddressSpace" {
    type = string
    description = "Address space for your vNet in CIDR notation"
}

variable "frontEndSubnetAddressPrefix" {
    type = string
    description = "Address prefix for your front end subnet in CIDR notation"
}

