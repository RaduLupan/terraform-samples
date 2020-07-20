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

variable "subnetIds" {
    description = "List of subnet Ids that are allowed through the Key Vault firewall"
    type        = list(string)
}

variable "serverName" {
    description = "Name of your VM"
    type        = string
}

variable "vmNumber" {
    description = "Number of VMs behind the load balancer"
}

variable "cdnSku" {
    description = "Pricing tier i.e.  Standard_Akamai, Standard_Microsoft, Standard_Verizon or Premium_Verizon"
    type        = string
}

variable "cdnEndpointDomain" {
    description   = "Name of DNS domain that points to the CDN endpoint i.e. example.com" 
    type          = string
}
