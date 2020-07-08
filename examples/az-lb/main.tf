# This template deploys the following Azure resources:
# - 1 x Load Balancer with 1 x Public IP, 1 x Backend Pool, 1 x Probe and 1 x Rule

# Terraform 0.12 syntax is used so 0.12 is the minimum required version
terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
    version = "2.0.0"
    subscription_id = var.subscriptionID
    features {}
}

resource "azurerm_public_ip" "pip01" {
  name                = "lb-pip"
  resource_group_name = var.resourceGroup
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "web_loadbalancer" {
  name                = "web-loadbalancer"
  location            = var.location
  resource_group_name = var.resourceGroup
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "lb-public-ip"
    public_ip_address_id = azurerm_public_ip.pip01.id
  }
}

resource "azurerm_lb_backend_address_pool" "web_lb_pool" {
  resource_group_name = var.resourceGroup
  loadbalancer_id     = azurerm_lb.web_loadbalancer.id
  name                = "lb-backend-pool"
}

resource "azurerm_lb_probe" "web_lb_probe" {
  resource_group_name = var.resourceGroup
  loadbalancer_id     = azurerm_lb.web_loadbalancer.id
  name                = "http-running-probe"
  port                = 80
  protocol            = "Http"   
  request_path        = "/"
}

resource "azurerm_lb_rule" "web_lb_http_rule" {
  resource_group_name            = var.resourceGroup
  loadbalancer_id                = azurerm_lb.web_loadbalancer.id
  name                           = "lb-http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-public-ip"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.web_lb_pool.id
  probe_id                       = azurerm_lb_probe.web_lb_probe.id   
}