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

variable "cdnSku" {
    type = string
    description = "Pricing tier i.e.  Standard_Akamai, Standard_Microsoft, Standard_Verizon or Premium_Verizon"
}

variable "cdnEndpointDomain" {
    type = string
    description   = "Name of DNS domain that points to the CDN endpoint i.e. example.com" 
}

