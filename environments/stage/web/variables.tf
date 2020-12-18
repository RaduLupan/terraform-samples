#----------------------------------------------------------------------------
# REQUIRED PARAMETERS: You must provide a value for each of these parameters.
#----------------------------------------------------------------------------

variable "subscription_id" {
  description = "Target subscription ID"
  type        = string
}

variable "vm_admin_user" {
  description = "Admin user name"
  type        = string
}

variable "vm_admin_password" {
  description = "Admin password"
  type        = string
}

#---------------------------------------------------------------
# OPTIONAL PARAMETERS: These parameters have resonable defaults.
#---------------------------------------------------------------

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
  description = "Number of deployed VMs"
  type        = number
  default     = 2
}
