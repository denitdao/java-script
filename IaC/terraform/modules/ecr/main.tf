module "java_script_repository_tf" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.2"

  repository_name               = "java-script-repository-tf"
  repository_image_scan_on_push = false
  create_lifecycle_policy       = false

  tags = {
    app            = "java-script"
    awsApplication = var.java_script_application_resource_group
  }
}
