variable "env" {
  description = "Name of the environment"
}
variable "aws_region" {
  description = "AWS region"
}
variable "repository_name" {
  description = "Name of the ECR repository"
}
variable "cluster_name" {
  description = "Name of the ECS cluster"
}
variable "task_def_name" {
  description = "Name of the ECS task definition"
}
variable "container_image_uri" {
  description = "Url to the image. In format [<aws-url>/<repository-name>:latest]"
  default     = ""
}
variable "java_script_application_resource_group" {
  description = "ARN of the application resource group"
}
variable "disable_api_gateway" {
  description = "Whether to allow requests to the API Gateway"
  type        = bool
  default     = false
}
