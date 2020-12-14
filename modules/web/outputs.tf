output "vm_names" {
  description = "The VM names"
  value       = azurerm_virtual_machine.web_vm[*].name
}

output "lb_pip" {
  description = "The public IP of the load balancer"
  value       = azurerm_public_ip.pip1.ip_address
}
