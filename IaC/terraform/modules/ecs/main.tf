# TODO: rewrite using predefined aws-modules

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role-tf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_execution_policy" {
  name = "ecs-execution-policy-tf"
  role = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*",
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_ecr_repository" "java_script_repository_tf" {
  name = "java-script-repository-tf"
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    app            = "java-script"
    awsApplication = var.java_script_application_resource_group
  }
}


resource "aws_ecs_cluster" "java_script_fargate_tf" {
  name = "java-script-cluster-tf"

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
  effective_image_uri = length(var.container_image_uri) > 0 ? var.container_image_uri : "${aws_ecr_repository.java_script_repository_tf.arn}:latest"
  # @formatter:on
}

resource "aws_ecs_task_definition" "java_script_fargate_tf" {
  family       = "java-script-fargate-tf-taskdef"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
  cpu    = "256"
  memory = "1024"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn

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
  name              = "/ecs/java-script-fargate-tf-taskdef"
  retention_in_days = 14
}
