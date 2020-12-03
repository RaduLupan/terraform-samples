output "vm_pip" {
    description = "The public IPs of the VMs"
    value = azurerm_public_ip.pip[*]
}