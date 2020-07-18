## Environment Deployment Guide

1. Prerequisites
- Azure subscription: if you don't already have one you can open a free Azure account [here](https://azure.microsoft.com/free).
- Terraform 0.12 or later installed locally: check out HasiCorp [documentation](https://learn.hashicorp.com/terraform/azure/install) on how to install Terraform.

2. In the /environments/dev folder edit the terraform.tfvars file and add your Azure subscription ID.
3. In the /environments/dev folder edit the main.tf file and add your values for the modules input parameters:
- **location**: the Azure region that your resources will be deployed in. I recommend using the all-lowercase-no-spaces notation i.e. **eastus2** as the location is appended to some resource names and it looks better visually.
- **environment**: this is a tag that gets attached to resources and also appended in some resource names, you can use **dev** or make it something that makes sense to you.
- **vNetAddressSpace**: the address space for the virtual network in CIDR notation.
- **frontEndSubnetAddressPrefix**: the frontend subnet address prefix in CIDR notation.
- **allowedSshAddressPrefix**: the address prefix for the range of IPs allowed to SSH into the VMs. If you want to restrict SSH access to the VMs to a particular IP enter that IP here and that IP will be allowed source for SSH in the network security group attached to the frontend subnet where the VMs will sit.
- **serverName**: a string that will be part of the VM names. For example if you set it to **ubuntu** the VMs will be named: vm-ubuntu-00, vm-ubuntu-01, etc.
- **vmNumber**: the number of VMs you want deployed in the load balancer backend pool.
- **cdnSku**: pricing tier for Azure CDN profile, accepted values are: Standard_Akamai, Standard_Microsoft, Standard_Verizon or Premium_Verizon.
- **cdnEndpointDomain**: the name of domain fronted by Azure CDN. If you set it to dev.example.com the Azure CDN endpoint will be cdn-dev-example-com.azureedge.net and you will need to point your domain to the CDN i.e. dev.example.com CNAME cdn-dev-example-com.azureedge.net.
- **adminLogin**: admin user for the MySQL server.
- **adminLoginPassword**: admin user password. Bad practice, I know, we shoould be storing passwords in vaults. Needs improvment.
- **serverSku**: the MySQL server SKU. I recommend the general purpose SKU GP_Gen5_2 in order to be able to create firewall rules that allow the vnet to access the MySQL server. The basic SKU B_Gen5_2 will work but it will not allow the vnet to access the MySQL server.
- **serverStorageMb**: initial server storage in MB. The **auto_grow_enabled** is set to true so the storage will be expanded as needed.
-**serverVersion**: MySQL version, accepted values currently **5.6**, **5.7** and **8.0**.
