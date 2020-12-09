output "rg_name" {
  description = "The name of the resource group the vNet is in"
  value       = module.network.rg_name
}

output "vnet_name" {
  description = "The name of the vNet"
  value       = module.network.vnet_name
}

output "fe_subnet_id" {
  description = "The ID of the frontend subnet"
  value       = module.network.fe_subnet_id
}

output "nsg_id" {
  description = "The ID of the network security group associated with the subnet"
  value       = module.network.nsg_id
}
