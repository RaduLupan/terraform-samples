resource "azurerm_public_ip" "pip01" {
  name                = "LBPublicIp"
  resource_group_name = var.resourceGroup
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "web_loadbalancer" {
  name                = "WebLoadBalancer"
  location            = var.location
  resource_group_name = var.resourceGroup
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LB-PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip01.id
  }
}

resource "azurerm_lb_backend_address_pool" "web_lb_pool" {
  resource_group_name = var.resourceGroup
  loadbalancer_id     = azurerm_lb.web_loadbalancer.id
  name                = "LB-BackendPool"
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
  name                           = "LB-Http-Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LB-PublicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.web_lb_pool.id
  probe_id                       = azurerm_lb_probe.web_lb_probe.id   
}