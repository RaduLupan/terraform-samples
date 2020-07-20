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

variable "subnetId" {
    description = "Subnet Id for subnet that VM will sit on"
    type        = string
}

variable "serverName" {
    description = "Name of your VM"
    type        = string
}

variable "vmNumber" {
    description = "Number of VMs behind the load balancer"
}

variable "vmAdminUser" {
    description = "Admin user name"
    type        = string
}

variable "vmAdminPassword" {
    description = "Admin password"
    type        = string
}
