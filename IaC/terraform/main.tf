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

module "ecs" {
  source                                 = "./modules/ecs"
  env                                    = var.env
  aws_region                             = var.aws_region
  repository_name                        = var.repository_name
  cluster_name                           = var.cluster_name
  task_def_name                          = var.task_def_name
  container_image_uri                    = var.container_image_uri
  java_script_application_resource_group = var.java_script_application_resource_group
}

module "lambda" {
  source                                 = "./modules/lambda"
  env                                    = var.env
  java_script_function_source            = "${path.module}/../../lambda-app/target/lambda-app-1.0-SNAPSHOT.jar"
  java_script_application_resource_group = var.java_script_application_resource_group
}
