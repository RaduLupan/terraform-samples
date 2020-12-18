# Web module

This folder contains a Terraform configuration that defines a module for deploying multiple [virtual machines](https://docs.microsoft.com/en-ca/azure/virtual-machines/linux/tutorial-manage-vm) (VMs) behind a [load balancer](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-overview) in an [Azure](https://azure.microsoft.com/free) subscription.

## Quick start

Terraform modules are not meant to be deployed directly. Instead, they are invoked from within other Terraform configurations. 
* See [environments/dev/web](../environments/dev/web) for example on how to invoke the web module from a local source.
* See [environments/stage/web](../environments/stage/web) for example on how to invoke the web module from a Github source.
