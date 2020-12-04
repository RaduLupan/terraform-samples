# This template deploys the following Azure resources:
# - 1 x Load Balancer with 1 x Public IP, 1 x Backend Pool, 1 x Probe and 1 x Rule

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.37.0"
    }
  }

  required_version = "~> 0.13.0"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

# Local calculated variables
locals {
  project        = "terraform-samples"
  resource_group = var.resource_group == null ? azurerm_resource_group.rg[0].name : var.resource_group
}

# Create Resource Group if var.resource_group is null
resource "azurerm_resource_group" "rg" {
  count = var.resource_group == null ? 1 : 0

  name     = "rg-${lower(replace(var.location, " ", ""))}-${local.project}-${var.environment}"
  location = var.location

  tags = {
    environment = var.environment
    project     = local.project
    terraform   = "true"
  }
}

resource "azurerm_public_ip" "pip01" {
  name                = "lb-pip"
  resource_group_name = local.resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "web_loadbalancer" {
  name                = "lb-web"
  location            = var.location
  resource_group_name = local.resource_group
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "lb-public-ip"
    public_ip_address_id = azurerm_public_ip.pip01.id
  }

  tags = {
    environment = var.environment
    project     = local.project
    terraform   = "true"
  }
}

resource "azurerm_lb_backend_address_pool" "web_lb_pool" {
  resource_group_name = local.resource_group
  loadbalancer_id     = azurerm_lb.web_loadbalancer.id
  name                = "lb-backend-pool"
}

resource "azurerm_lb_probe" "web_lb_probe" {
  resource_group_name = local.resource_group
  loadbalancer_id     = azurerm_lb.web_loadbalancer.id
  name                = "http-running-probe"
  port                = 80
  protocol            = "Http"
  request_path        = "/"
}

resource "azurerm_lb_rule" "web_lb_http_rule" {
  resource_group_name            = local.resource_group
  loadbalancer_id                = azurerm_lb.web_loadbalancer.id
  name                           = "lb-http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-public-ip"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.web_lb_pool.id
  probe_id                       = azurerm_lb_probe.web_lb_probe.id
}