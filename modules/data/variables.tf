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

variable "admin_login" {
  description = "MySQL Server administrator login"
  type        = string
}

variable "admin_password" {
  description = "MySQL Server administrator login password"
  type        = string
}

#---------------------------------------------------------------
# OPTIONAL PARAMETERS: These parameters have resonable defaults.
#---------------------------------------------------------------

variable "resource_group" {
  description = "Name of your resource group (if not specified new resource group will be created in the Azure region)"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment i.e. dev, test, stage, prod"
  type        = string
  default     = "dev"
}

variable "server_sku" {
  description = "MySQL Server SKU name"
  type        = string
  default     = "B_Gen5_2"
}

variable "server_storage_mb" {
  description = "MySQL Server storage in MB"
  type        = number
  default     = 5120
}

variable "server_version" {
  description = "MySQL Server version i.e 5.7"
  type        = string
  default     = "5.7"
}

variable "subnet_id" {
  description = "Id of the virtual network subnet allowed to connect to the MySQL server"
  type        = string
  default     = null
}
