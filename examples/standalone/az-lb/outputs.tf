output "lb_pip" {
  description = "The public IP of the load balancer"
  value       = azurerm_public_ip.pip01.ip_address
}