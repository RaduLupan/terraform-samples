# Key-vault example

This folder contains a Terraform configuration that shows an example of how to use the [key-vault module](../../modules/key-vault) to deploy a [key vault](https://docs.microsoft.com/en-us/azure/key-vault/general/basic-concepts) in an Azure subscription.

## Pre-requisites

* [Azure subscription](https://azure.microsoft.com/free).
* Terraform 0.13.x installed on your computer. Check out HasiCorp [documentation](https://learn.hashicorp.com/terraform/azure/install) on how to install Terraform.

## Quick start

Configure [Azure authentication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)

Deploy the code:

```
$ terraform init
$ terraform apply
```

Clean up when you are done:

```
$ terraform destroy
```