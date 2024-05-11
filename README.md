# Java Script - is a script written on Java

This repo is a sandbox with a simple Java application that is deployed to AWS

## IaC (Infrastructure as Code)

### Cloudformation

`.yaml` files describe resources and `.json` files contain parameters that could be changed for customization (e.g. for
dev/prod envs)

First ECR stack should be initialized.
Then update `ecs.json` with `ContainerImageURI`, build it using output of the ECR stack.
Then ECS stack should be initialized.

#### Commands to create stacks

```shell
aws cloudformation create-stack --stack-name ecr-cf --template-body file://./IaC/cloudformation/ecr.yaml --parameters file://./IaC/cloudformation/ecr.json --capabilities CAPABILITY_IAM
```

```shell
aws cloudformation create-stack --stack-name ecs-cf --template-body file://./IaC/cloudformation/ecs.yaml --parameters file://./IaC/cloudformation/ecs.json --capabilities CAPABILITY_IAM
```

#### Commands to update stacks

```shell
aws cloudformation update-stack --stack-name ecr-cf --template-body file://./IaC/cloudformation/ecr.yaml --parameters file://./IaC/cloudformation/ecr.json --capabilities CAPABILITY_IAM
```

```shell
aws cloudformation update-stack --stack-name ecs-cf --template-body file://./IaC/cloudformation/ecs.yaml --parameters file://./IaC/cloudformation/ecs.json --capabilities CAPABILITY_IAM
```

#### Commands to describe stacks

```shell
aws cloudformation describe-stacks --stack-name ecr-cf
```

```shell
aws cloudformation describe-stacks --stack-name ecs-cf
```

### Terraform

https://developer.hashicorp.com/terraform/language/resources/syntax

in progress...

## TODO:

- [ ] create non-root IAM user for image deployment and infra provisioning
- [ ] automate Fargate with Terraform
- [ ] manually deploy it to AWS - Lambda
- [ ] automate Lambda with CF
- [ ] automate Lambda with Terraform

- [ ] compile images on GraalVm with optimized settings

- [ ] inject some AWS secrets into the Fargate app
- [ ] add VPC to CF and Terraform
- [ ] call Lambda from Fargate app

- [ ] add Ansible to the stack
- [ ] add Pulumi

## Kudos To

https://github.com/Berehulia/Terraform-In-45-Minutes
