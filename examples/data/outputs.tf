output "mysql_server_fqdn" {
  description = "The FQDN of the MySQL server"
  value       = module.data.mysql_server_fqdn
}