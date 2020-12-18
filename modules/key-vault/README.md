# Key-vault module

This folder contains a Terraform configuration that defines a module for deploying an [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/general/basic-concepts) in an [Azure](https://azure.microsoft.com/free) subscription.

## Quick start

Terraform modules are not meant to be deployed directly. Instead, they are invoked from within other Terraform configurations. 
* See [environments/dev/key-vault](../../environments/dev/key-vault) and for example on how to invoke the Key-Vault module from a local source.
* See [environments/stage/key-vault](../../environments/stage/key-vault) for example on how to invoke the Key-Vault module from a Github source.