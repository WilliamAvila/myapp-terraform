locals {
  backend_env_vars = {
    AWS_ACCOUNT_ID     = ""
    AWS_DEFAULT_REGION = ""
    IMAGE_REPO_NAME    = ""
    dockerhub_password = ""
    dockerhub_username = ""
    ecs_container_name = ""
    PG_HOST            = ""
    PG_PORT            = ""
    POSTGRES_USER      = ""
    POSTGRES_PASSWORD  = ""
    POSTGRES_DB        = ""

  }
  #ECS env variables
  JWT_SECRET     = var.JWT_SECRET
  JWT_EXPIRATION = var.JWT_EXPIRATION
  codebuild_configuration = {
    cb_compute_type   = "BUILD_GENERAL1_SMALL"
    cb_image          = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    cb_type           = "LINUX_CONTAINER"
    cb_project_name   = "${var.app_name}-cb-${terraform.workspace}"
    cb_description    = "${var.app_name} ${terraform.workspace} codebuild project"
    cb_source_version = "${terraform.workspace}"
  }
}