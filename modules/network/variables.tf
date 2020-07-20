variable "subscriptionID" {
    description = "Target subscription ID"
    type        = string
}

variable "location" {
    description = "Location of your resource group"
    type        = string
}

variable "environment" {
    description   = "Environment i.e. dev, test, stage, prod" 
    type          = string
}

variable "vNetAddressSpace" {
    description = "Address space for your vNet in CIDR notation"
    type        = string
}

variable "frontEndSubnetAddressPrefix" {
    description = "Address prefix for your front end subnet in CIDR notation"
    type        = string
    
}

variable "allowedSshAddressPrefix" {
    description = "Address prefix for your range of IPs allowed for SSH in CIDR notation"
    type        = string
    
}
