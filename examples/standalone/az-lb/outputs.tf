output "lb_pip" {
  description = "The public IP of the load balancer"
  value       = azurerm_public_ip.pip01.ip_address
}

output "lb_backend_pool_id" {
  description = "The ID of the load balancer backend pool"
  value       = azurerm_lb_backend_address_pool.web_lb_pool.id
}