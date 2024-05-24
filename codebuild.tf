data "aws_iam_policy" "ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}
data "aws_iam_policy_document" "assume_role_cb_backend" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
data "aws_iam_policy_document" "my_cb_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
  }
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages",
    ]
    resources = ["*"]
  }

}
data "local_file" "buildspec_backend_local" {
  filename = "${path.module}/buildspec.yaml"
}
resource "aws_iam_role" "my_cb_iam_role" {
  name               = "${var.app_name}_${terraform.workspace}_cb_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_cb_backend.json
}

resource "aws_iam_role_policy" "my_cb_role_policy" {
  name   = "${var.app_name}-cb-backend-policy-${terraform.workspace}"
  role   = aws_iam_role.my_cb_iam_role.name
  policy = data.aws_iam_policy_document.my_cb_policy.json
}
# resource "aws_codebuild_source_credential" "github_credentials" {
#   auth_type   = "BASIC_AUTH"
#   server_type = "github"
#   token       = var.github_credentials["token"]
#   user_name   = var.github_credentials["user_name"]
# }
resource "aws_iam_role_policy_attachment" "ecs_full_access_policy_attach" {
  role       = aws_iam_role.my_cb_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_codebuild_project" "my_cb" {
  name               = local.codebuild_configuration["cb_project_name"]
  description        = local.codebuild_configuration["cb_description"]
  service_role       = aws_iam_role.my_cb_iam_role.arn
  queued_timeout     = "480"
  project_visibility = "PRIVATE"
  badge_enabled      = "false"
  build_timeout      = "60"

  cache {
    type = "NO_CACHE"
  }

  artifacts {
    encryption_disabled    = "false"
    name                   = "${var.app_name}-cb"
    override_artifact_name = "false"
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  environment {
    compute_type                = local.codebuild_configuration["cb_compute_type"]
    image                       = local.codebuild_configuration["cb_image"]
    type                        = local.codebuild_configuration["cb_type"]
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = "true"

    dynamic "environment_variable" {
      for_each = local.backend_env_vars
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = "false"
      status              = "DISABLED"
    }
  }

  source {
    buildspec           = data.local_file.buildspec_backend_local.content
    git_clone_depth     = "0"
    insecure_ssl        = "false"
    report_build_status = "false"
    type                = "CODEPIPELINE"
  }
  source_version = local.codebuild_configuration["cb_source_version"]
  tags = {
    ENVIRONMENT = "${terraform.workspace}"
  }


}

output "codebuild_name" {
  value = aws_codebuild_project.my_cb.name
}

output "codebuild_id" {
  value = aws_codebuild_project.my_cb.id
}
