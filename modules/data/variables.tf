variable "subscriptionID" {
    description = "Target subscription ID"
    type        = string
}

variable "location" {
    description = "Location of your resource group"
    type        = string
}

variable "resourceGroup" {
    description = "Name of your resource group"
    type        = string
}

variable "environment" {
    description   = "Environment i.e. dev, test, stage, prod" 
    type          = string
}

variable "adminLogin" {
    description = "MySQL Server administrator login"
    type        = string
    
}

variable "adminLoginPassword" {
    description = "MySQL Server administrator login password"
    type        = string
}

variable "serverSku" {
    description = "MySQL Server SKU name"
    type        = string   
}

variable "serverStorageMb" {
    description = "MySQL Server storage in MB"
}

variable "serverVersion" {
    description = "MySQL Server version i.e 5.7"
    type        = string
}

variable "subnetId" {
    description = "Id of the virtual network subnet allowed to connect to the MySQL server"
    type        = string
}
