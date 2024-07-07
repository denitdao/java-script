data "aws_availability_zones" "available" {}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "java_script_vpc_tf" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.9"

  name = "java-script-vpc-tf"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    app            = "java-script"
    awsApplication = var.java_script_application_resource_group
  }
}
