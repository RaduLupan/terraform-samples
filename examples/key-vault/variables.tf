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
    default     = null
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
