# MySQL-DB module

This folder contains a Terraform configuration that defines a module for deploying an [Azure database for MySQL](https://docs.microsoft.com/en-ca/azure/mysql/overview) in an [Azure](https://azure.microsoft.com/free) subscription.

## Quick start

Terraform modules are not meant to be deployed directly. Instead, they are invoked from within other Terraform configurations. 
* See [environments/dev/mysql-db](../../environments/dev/mysql-db) for example on how to invoke the MySql-DB module from a local source.
* See [environments/stage/mysql-db](../../environments/stage/mysql-db) example on how to invoke the MySql-DB module from a Github source.
