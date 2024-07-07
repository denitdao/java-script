module "java_script_ecs_cluster_tf" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.11"

  cluster_name = "java-script-cluster-tf"

  cluster_settings = [
    {
      name  = "containerInsights"
      value = "disabled"
    }
  ]

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = {
    app            = "java-script"
    awsApplication = var.java_script_application_resource_group
  }
}

module "java_script_service_tf" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.11"

  name        = "java-script-service-tf"
  family      = "java-script-fargate-tf-taskdef"
  cluster_arn = module.java_script_ecs_cluster_tf.cluster_arn

  cpu          = 256
  memory       = 1024
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  subnet_ids = var.java_script_private_subnets

  runtime_platform = {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = {
    java-script-container = {
      image     = var.container_image_uri
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/java-script-fargate-tf-taskdef"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  }
  desired_count = 0

  tags = {
    app            = "java-script"
    awsApplication = var.java_script_application_resource_group
  }
}
