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

variable "subnet_ids" {
  description = "Subnet Ids for subnets that will connect to Azure Key Vault via service endpoints (if null new vnet will be created in the Azure region)"
  type        = list(string)
  default     = null
}

variable "server_name" {
  description = "Name of your VM"
  type        = string
  default     = null
}

variable "vm_number" {
  description = "Number of VMs behind the load balancer"
  type        = number
  default     = 0
}