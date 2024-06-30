terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49"
    }
  }

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

module "iam" {
  source = "./modules/iam"
  env    = var.env
}

module "ecr" {
  source                                 = "./modules/ecr"
  env                                    = var.env
  repository_name                        = var.repository_name
  java_script_application_resource_group = var.java_script_application_resource_group
}

locals {
  js_function_source = "${path.module}/../../lambda-app/target/lambda-app-1.0-SNAPSHOT.jar"
}

resource "aws_s3_bucket" "js_lambda_builds" {
  bucket = "java-script-lambda-tf-eu-west-1"
}

resource "aws_s3_object" "js_function" {
  bucket = aws_s3_bucket.js_lambda_builds.id
  key    = "${filemd5(local.js_function_source)}.jar"
  source = local.js_function_source
}

module "java_script_lambda_tf" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.7"

  function_name = "java-script-tf"
  description   = "Lambda created by Terraform"
  handler       = "com.denitdao.learn.javascript.FunctionRequestHandler::execute"
  runtime       = "java21"
  architectures = ["arm64"]

  memory_size = 512
  timeout     = 15

  create_package = false
  s3_existing_package = {
    bucket = aws_s3_bucket.js_lambda_builds.id
    key    = aws_s3_object.js_function.id
  }

  tags = {
    app            = "java-script"
    awsApplication = var.java_script_application_resource_group
  }
}

resource "aws_ecs_cluster" "java_script_fargate_tf" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }

  tags = {
    app            = "java-script"
    awsApplication = var.java_script_application_resource_group
  }
}

resource "aws_ecs_cluster_capacity_providers" "java_script_fargate_tf" {
  cluster_name = aws_ecs_cluster.java_script_fargate_tf.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

locals {
  # @formatter:off
  effective_image_uri = length(var.container_image_uri) > 0 ? var.container_image_uri : "${module.ecr.java_script_repository_tf_arn}:latest"
  # @formatter:on
}

resource "aws_ecs_task_definition" "java_script_fargate_tf" {
  family       = var.task_def_name
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  cpu    = "256"
  memory = "1024"

  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "java-script-container"
      image     = local.effective_image_uri
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.java_script_fargate_tf.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    app            = "java-script"
    awsApplication = var.java_script_application_resource_group
  }
}

resource "aws_cloudwatch_log_group" "java_script_fargate_tf" {
  name              = "/ecs/${var.task_def_name}"
  retention_in_days = 14
}
