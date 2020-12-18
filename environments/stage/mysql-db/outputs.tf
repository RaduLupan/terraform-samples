output "mysql_server_fqdn" {
  description = "The FQDN of the MySQL server"
  value       = module.mysql-db.mysql_server_fqdn
}