terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49"
    }
  }

  # TODO: values replicate defined in the backends folder. Remove duplication?
  backend "s3" {
    region         = "eu-west-1"
    key            = "java-script-dev.tfstate"
    bucket         = "java-script-state-eu-west-1"
    dynamodb_table = "java-script-terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-1" # Ireland
}

locals {
  # @formatter:off
  effective_image_uri = length(var.container_image_uri) > 0 ? var.container_image_uri : "${module.ecr.java_script_repository_tf_arn}:latest"
  # @formatter:on
}

module "vpc" {
  source                                 = "./modules/vpc"
  env                                    = var.env
  java_script_application_resource_group = var.java_script_application_resource_group
}

module "ecr" {
  source                                 = "./modules/ecr"
  env                                    = var.env
  aws_region                             = var.aws_region
  java_script_application_resource_group = var.java_script_application_resource_group
}

module "ecs" {
  source                                 = "./modules/ecs"
  env                                    = var.env
  aws_region                             = var.aws_region
  container_image_uri                    = local.effective_image_uri
  java_script_private_subnets            = module.vpc.java_script_vpc_tf.private_subnets
  java_script_application_resource_group = var.java_script_application_resource_group
}

module "lambda" {
  source                                 = "./modules/lambda"
  env                                    = var.env
  java_script_function_source            = "${path.module}/../../lambda-app/target/lambda-app-1.0-SNAPSHOT.jar"
  java_script_application_resource_group = var.java_script_application_resource_group
  disable_api_gateway                    = var.disable_api_gateway
}
