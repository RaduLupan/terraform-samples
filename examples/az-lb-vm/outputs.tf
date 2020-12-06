output "vm_names" {
  description = "The VM names"
  value       = azurerm_virtual_machine.web_vm[*].name
}
