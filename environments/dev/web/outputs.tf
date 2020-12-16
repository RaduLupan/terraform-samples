output "vm_names" {
  description = "The VM names"
  value       = module.web.vm_names
}

output "lb_pip" {
  description = "The public IP of the load balancer"
  value       = module.web.lb_pip
}
