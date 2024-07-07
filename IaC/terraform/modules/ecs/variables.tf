variable "env" {}
variable "aws_region" {}
variable "container_image_uri" {
  description = "The URI of the container image to use. In format [<aws-url>/<repository-name>:latest]."
  type        = string
  default     = ""
}
variable "java_script_private_subnets" {
  description = "List of subnets to associate with the task or service"
  type = list(string)
  default = []
}
variable "java_script_application_resource_group" {}
