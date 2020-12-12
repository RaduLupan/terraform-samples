output "mysql_server_fqdn" {
  description = "The FQDN of the MySQL server"
  value       = azurerm_mysql_server.mysql_server.fqdn
}