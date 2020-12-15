output "vault_uri" {
    description = "The URI of the Key Vault"
    value       = azurerm_key_vault.az_key_vault.vault_uri
}

output "vault_id" {
    description = "The ID of the Key Vault"
    value       = azurerm_key_vault.az_key_vault.id
}