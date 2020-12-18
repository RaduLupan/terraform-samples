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

variable "environment" {
  description = "Environment i.e. dev, test, stage, prod"
  type        = string
  default     = "stage"
}

variable "vnet_address_space" {
  description = "Address space for your vNet in CIDR notation"
  type        = string
  default     = "10.10.0.0/16"
}

variable "frontend_subnet_address_prefix" {
  description = "Address prefix for your front end subnet in CIDR notation"
  type        = string
  default     = "10.10.10.0/24"

}

variable "allowed_ssh_address_prefix" {
  description = "Address prefix for your range of IPs allowed for SSH in CIDR notation"
  type        = string
  default     = null
}
