# terraform-samples-azure
### Sample configurations developed in my quest to learn Terraform and Azure


The [modules](./modules) folder contains child modules that can be invoked to build consistent environments. 

The [examples](./examples) folder contains example configurations on how to use each module. In the [examples/standalone](./examples/standalone) there are a few configurations that can be run independently.

The [environments](./environments) folder contains a couple of environments: [dev](./environments/dev) and [stage](./environments/dev) that are built by invoking the various modules. 

The environment architecture diagram is below:

![Env-Diagram](terraform-samples-environments.png)

## Resources
[CloudSkills Github Repository](https://github.com/cloudskills)

[How to create reusable infrastructure with Terraform modules](https://blog.gruntwork.io/how-to-create-reusable-infrastructure-with-terraform-modules-25526d65f73d)
