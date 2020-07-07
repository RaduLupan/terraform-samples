# terraform-samples
### Sample configurations for Azure and AWS developed in my quest to learn Terraform

The **examples** folder contains stand alone configurations that can be deployed individually. For instance:

**az-vnet** deploys:
* 1 x resource group, 1 x virtual network with one subnet, 1 x network security group associated with the subnet

**az-vm** deploys:
* 1 x vm running Ubuntu with 1 public IP	
 
To deploy an example just fill in your values for the input parameters in the corresponding **terraform.tvars** file and from the folder run

```
$ terraform init

$ terraform plan

$ terraform apply
```
The **modules** folder contains child modules that can be invoked to build consistent environments. There are only three modules there for now: network, web and global with more to come.

The **environments** folder contains root modules that build environments by invoking the child modules. 
The only difference between the **dev** and **stage** environments is the values of the input parameters injected into the child modules, but the modules themselves have the same code!

## Resources
[CloudSkills Github Repository](https://github.com/cloudskills)

[How to create reusable infrastructure with Terraform modules](https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d)
