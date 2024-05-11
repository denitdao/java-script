variable "env" {}

variable "aws_region" {
  default = "eu-west-1"
}

variable "repository_name" {
  default = "java-script-repository-tf"
}

variable "cluster_name" {
  default = "java-script-cluster-tf"
}

variable "task_def_name" {
  default = "java-script-fargate-tf-taskdef"
}

variable "container_image_uri" {
  description = "Url to the image. In format [<aws-url>/<repository-name>:latest]"
  default     = ""
}

variable "java_script_application_resource_group" {
  default = "yours"
}
