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

variable "subnetId" {
    type = string
    description = "Subnet Id for subnet that VM will sit on"
}

variable "serverName" {
    type = string
    description = "Name of your VM"
}

variable "vmNumber" {
    description = "Number of VMs behind the load balancer"
}