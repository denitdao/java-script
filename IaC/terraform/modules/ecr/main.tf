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
