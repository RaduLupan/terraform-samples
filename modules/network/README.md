# Network module

This folder contains a Terraform configuration that defines a module for deploying a [virtual network](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview) in an [Azure](https://azure.microsoft.com/free) subscription.

## Quick start

Terraform modules are not meant to be deployed directly. Instead, they are invoked from within other Terraform configurations. 
* See [environments/dev/network](../../environments/dev/network) and [environments/stage/network](../../environments/stage/network) for examples on how to invoke the network module from a local source.
