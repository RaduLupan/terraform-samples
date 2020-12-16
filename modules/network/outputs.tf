output "rg_name" {
  description = "The name of the resource group the vNet is in"
  value       = azurerm_resource_group.rg.name
}

output "rg_id" {
  description = "The ID of the resource group the vNet is in"
  value       = azurerm_resource_group.rg.id
}

output "vnet_name" {
  description = "The name of the vNet"
  value       = azurerm_virtual_network.vnet1.name
}

output "fe_subnet_id" {
  description = "The ID of the frontend subnet"
  value       = azurerm_subnet.subnet1.id
}

output "fe_subnet_name" {
  description = "The name of the frontend subnet"
  value       = azurerm_subnet.subnet1.name
}

output "nsg_id" {
  description = "The ID of the network security group associated with the subnet"
  value       = azurerm_network_security_group.frontend_nsg.id
}
