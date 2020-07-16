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

variable "environment" {
    type = string
    description   = "Environment i.e. dev, test, stage, prod" 
}

variable "adminLogin" {
    type = string
    description = "MySQL Server administrator login"
}

variable "adminLoginPassword" {
    type = string
    description = "MySQL Server administrator login password"
}

variable "serverSku" {
    type = string
    description = "MySQL Server SKU name"
}

variable "serverStorageMb" {
    description = "MySQL Server storage in MB"
}

variable "serverVersion" {
    type = string
    description = "MySQL Server version i.e 5.7"
}

variable "subnetId" {
    type = string
    description = "Id of the virtual network subnet allowed to connect to the MySQL server"
}
