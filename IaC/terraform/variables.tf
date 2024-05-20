variable "env" {}
variable "aws_region" {}
variable "repository_name" {}
variable "cluster_name" {}
variable "task_def_name" {}
variable "container_image_uri" {
  description = "Url to the image. In format [<aws-url>/<repository-name>:latest]"
  default     = ""
}
variable "java_script_application_resource_group" {}
