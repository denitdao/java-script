# Java Script - is a script written on Java

This repo is a sandbox with a simple Java application that is deployed to AWS

## Services

### EC2/Fargate

Module `server-app`

### Lambda

Module `lambda-app`.

https://micronaut-projects.github.io/micronaut-aws/latest/guide/#lambda

## IaC (Infrastructure as Code)

### Terraform

https://developer.hashicorp.com/terraform/language/resources/syntax

Provisions all required resources and saves state to the S3. Supports configuration via files in /variables folder.

#### Setup

Requires manually created resources on AWS as backend for state

- DynamoDB table called `java-script-terraform-state-lock` with Partition Key `LockID`
- S3 bucket with some available name, equal to one specified in `.tfbackend` file under /terraform/backends

Initialize terraform state:

```shell
terraform init -backend-config="./backends/eu-west-1/dev.s3.tfbackend"
```

Create resources or apply changes:

```shell
terraform apply -var-file="./variables/eu-west-1/dev.tfvars"
```

### Cloudformation

> [!NOTE]
> At some point Cloudformation was considered stupidly complicated, so I decided to proceed with this IaC only using
> Terraform. Thus, Cloudformation version contains fewer features.

`.yaml` files describe resources and `.json` files contain parameters that could be changed for customization (e.g. for
dev/prod envs)

First ECR stack should be initialized.
Then update `ecs.json` with `ContainerImageURI`, build it using output of the ECR stack.
Then ECS stack should be initialized.

#### Commands to create stacks

```shell
aws cloudformation create-stack --stack-name ecr-cf --template-body file://ecr.yaml --parameters file://ecr.json --capabilities CAPABILITY_IAM
```

```shell
aws cloudformation create-stack --stack-name ecs-cf --template-body file://ecs.yaml --parameters file://ecs.json --capabilities CAPABILITY_IAM
```

#### Commands to update stacks

```shell
aws cloudformation update-stack --stack-name ecr-cf --template-body file://ecr.yaml --parameters file://ecr.json --capabilities CAPABILITY_IAM
```

```shell
aws cloudformation update-stack --stack-name ecs-cf --template-body file://ecs.yaml --parameters file://ecs.json --capabilities CAPABILITY_IAM
```

#### Commands to describe stacks

```shell
aws cloudformation describe-stacks --stack-name ecr-cf
```

```shell
aws cloudformation describe-stacks --stack-name ecs-cf
```

## AWS Access

Create non-root IAM user
using [tutorial](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-set-up.html#create-an-admin)

Add its details to ~/.aws/credentials file under [default] profile

## TODO:

- [x] create non-root IAM user for image deployment and infra provisioning
- [x] automate Fargate with Terraform
- [x] manually deploy it to AWS - Lambda
- [x] automate Lambda with Terraform

- [ ] compile images on GraalVm with optimized settings

- [ ] add VPC to Terraform
- [ ] call Lambda from Fargate app
- [ ] inject some AWS secrets into the Fargate app

- [ ] add Ansible to the stack
- [ ] add Pulumi

## Kudos To

https://serverless.tf/

https://github.com/Berehulia/Terraform-In-45-Minutes
