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
    description = "List of subnet Ids that are allowed through the Key Vault firewall"
}

variable "serverName" {
    type = string
    description = "Name of your VM"
}

variable "vmNumber" {
    description = "Number of VMs behind the load balancer"
}