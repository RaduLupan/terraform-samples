variable "subscription_id" {
  description = "Target subscription ID"
  type        = string
}

variable "location" {
  description = "The Azure region where the resources are being deployed"
  type        = string
}

variable "resource_group" {
  description = "Name of your resource group"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment i.e. dev, test, stage, prod"
  type        = string
  default     = "dev"
}

variable "cdn_sku" {
  description = "Pricing tier i.e.  Standard_Akamai, Standard_Microsoft, Standard_Verizon or Premium_Verizon"
  type        = string
  default     = "Standard_Microsoft"
}

variable "cdn_endpoint_domain" {
  description = "Name of DNS domain that points to the CDN endpoint i.e. example.com"
  type        = string
  default     = "example.com"
}

