provider "aws" {
    region = var.region
}

locals {
    project = "terraform-samples"
}

resource "aws_vpc" "main" {
  cidr_block       = var.vpcCidr  
  instance_tenancy = "default"

  tags = {
    Name = "vpc-${local.project}-${var.environment}-${var.region}"
    environment = var.environment
  }
}

