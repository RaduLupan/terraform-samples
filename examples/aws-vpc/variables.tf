variable "region" {
    type = string
    description = "AWS Region"
}

variable "vpcCidr" {
    type = string
    description = "VPC CIDR Block"
    default = "10.0.0.0/16"
}

variable "environment" {
    type = string
    description   = "Environment i.e. dev, test, stage, prod" 
}