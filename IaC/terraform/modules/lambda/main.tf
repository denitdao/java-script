resource "aws_s3_bucket" "java_script_lambda_builds" {
  bucket = "java-script-lambda-tf-eu-west-1"

  tags = {
    app            = "java-script"
    awsApplication = var.java_script_application_resource_group
  }
}

resource "aws_s3_object" "java_script_function" {
  bucket = aws_s3_bucket.java_script_lambda_builds.id
  key    = "${filemd5(var.java_script_function_source)}.jar"
  source = var.java_script_function_source

  tags = {
    app            = "java-script"
    awsApplication = var.java_script_application_resource_group
  }
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
    bucket = aws_s3_bucket.java_script_lambda_builds.id
    key    = aws_s3_object.java_script_function.id
  }

  tags = {
    app            = "java-script"
    awsApplication = var.java_script_application_resource_group
  }
}
