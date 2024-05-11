resource "aws_ecr_repository" "java_script_repository_tf" {
  name = var.repository_name
  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    app            = "java-script"
    awsApplication = var.java_script_application_resource_group
  }
}
