#----------------------------------------------------------------------------
# REQUIRED PARAMETERS: You must provide a value for each of these parameters.
#----------------------------------------------------------------------------

variable "subscription_id" {
  description = "Target subscription ID"
  type        = string
}

variable "location" {
  description = "The Azure region where the resources are being deployed"
  type        = string
}

variable "subnet_ids" {
    description = "List of subnet Ids that are allowed through the Key Vault firewall"
    type        = list(string)
}

#---------------------------------------------------------------
# OPTIONAL PARAMETERS: These parameters have resonable defaults.
#---------------------------------------------------------------

variable "resource_group" {
  description = "Name of your resource group (if null new resource group will be created in the Azure region)"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment i.e. dev, test, stage, prod"
  type        = string
  default     = "dev"
}

variable "server_name" {
    description = "Name of your VM"
    type        = string
    default     = "ubuntu"
}

variable "vm_count" {
    description = "Number of VMs behind the load balancer"
    type        = number
    default     = 2
}

variable "cdn_sku" {
    description = "Pricing tier i.e.  Standard_Akamai, Standard_Microsoft, Standard_Verizon or Premium_Verizon"
    type        = string
    default     = "Standard_Verizon"
}

variable "cdn_endpoint_domain" {
    description   = "Name of DNS domain that points to the CDN endpoint i.e. example.com" 
    type          = string
    default       = "example.com"
}
