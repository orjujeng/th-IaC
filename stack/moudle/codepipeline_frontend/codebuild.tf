#建立一个s3的存储桶用来放前端文件
resource "aws_s3_bucket" "s3_frontend" {
  bucket = "${var.perfix}-frontend-orjujeng"
  tags = {
    Name = "${var.perfix}-frontend-orjujeng"
  }
}

#codebuild 前端的role:
resource "aws_iam_role" "applcation_frontend_codebuild_role" {
  name               = "${var.perfix}_frontend_codebuild_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_to_codebuild.json
}

#s3权限，用于拉取 placeholder
resource "aws_iam_role_policy_attachment" "applcation_frontend_codebuild_role_attach_AmazonS3FullAccess" {
  role       = aws_iam_role.applcation_frontend_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "applcation_ecc_codebuild_role_attach_AWSCodeBuildDeveloperAccess" {
  role       = aws_iam_role.applcation_frontend_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

#cloudwatch 权限
resource "aws_iam_role_policy_attachment" "applcation_ecc_codebuild_role_attach_CloudWatchFullAccess" {
  role       = aws_iam_role.applcation_frontend_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

#codepipeline 权限
resource "aws_iam_role_policy_attachment" "applcation_ecc_codebuild_role_attach_AWSCodePipeline_FullAccess" {
  role       = aws_iam_role.applcation_frontend_codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

#前端codebuild
resource "aws_codebuild_project" "application_frontend_codebuild" {
  name                 = "${var.perfix}_frontend_codebuild"
  description          = "${var.perfix}_frontend_codebuild"
  build_timeout        = 60  #1hours
  service_role         = aws_iam_role.applcation_frontend_codebuild_role.arn
  resource_access_role = aws_iam_role.applcation_frontend_codebuild_role.arn

  artifacts {
    type      = "S3"
    location  = data.aws_s3_bucket.get_artifacts_bucket.bucket
    packaging = "ZIP"
    path      = "/${var.perfix}_frontend_codebuild_artifacts/"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0" #node v18.20.0
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "REPO_HTTPS"
      value =  var.frontend_repo
    }
    environment_variable {
      name  = "BRANCH"
      value = var.frontend_branch
    }
    environment_variable {
      name  = "S3_DST"
      value = "${var.perfix}-frontend-orjujeng"
    }
  }
  source {
    type      = "NO_SOURCE"
    buildspec = file("./moudle/codepipeline_frontend/buildspec/front_buildcode.yml")
  }
  tags = {
    Name = "${var.perfix}_frontend_codebuild"
  }
}