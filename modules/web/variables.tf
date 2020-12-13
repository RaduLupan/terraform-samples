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

variable "vnet_resource_group" {
  description = "Name of the resource group for existing vNet (if null new resource group is created)"
  type        = string
  default     = null
}

variable "vnet_name" {
  description = "The name for existing vNet (if null new vNet is created)"
  type        = string
  default     = null
}

variable "subnet_name" {
  description = "The name for the subnet that the VMs will sit on (if null new subnet is created)"
  type        = string
  default     = null
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

variable "lb_backend_pool_id" {
  description = "Backend pool ID of the load balancer"
  type        = string
}
