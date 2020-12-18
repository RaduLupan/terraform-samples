# CDN module

This folder contains a Terraform configuration that defines a module for deploying an [Azure CDN](https://docs.microsoft.com/en-us/azure/cdn/cdn-overview) endpoint in an [Azure](https://azure.microsoft.com/free) subscription.

## Quick start

Terraform modules are not meant to be deployed directly. Instead, they are invoked from within other Terraform configurations. 
* See [environments/dev/cdn](../../environments/dev/cdn) for example on how to invoke the CDN module from a local source.
* See [environments/stage/cdn](../../environments/stage/cdn) for example on how to invoke the CDN module from a Github source.
