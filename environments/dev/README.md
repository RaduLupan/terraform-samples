# Multi tiered web app - dev environment

This folder contains Terraform configurations that invoke various [modules](../../modules) to deploy a multi tier web app in an [Azure](https://azure.microsoft.com/free) subscription. The configurations for each tier are stored in a corresponding subfolder, i.e. for network tier -> the network folder, etc.

## Pre-requisites

* [Azure subscription](https://azure.microsoft.com/free).
* Terraform 0.13.x installed on your computer. Check out HasiCorp [documentation](https://learn.hashicorp.com/terraform/azure/install) on how to install Terraform.

## Quick start

Configure [Azure authentication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)

1. Deploy the network tier:

```
$ cd network
$ terraform init
$ terraform apply
```

2. Deploy the key-vault tier:

```
$ cd key-vault
$ terraform init
$ terraform apply
```

3. Deploy the web tier:

```
$ cd web
$ terraform init
$ terraform apply
```

4. Deploy the mysql-db tier:

```
$ cd mysql-db
$ terraform init
$ terraform apply
```

5. Deploy the cdn tier:

```
$ cd cdn
$ terraform init
$ terraform apply
```
