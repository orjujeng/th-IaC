
#fe fontend role
resource "aws_iam_role" "application_frontend_codepipeline_role" {
  name = "${var.perfix}_frontend_codepipeline_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
#fe fontend policy
resource "aws_iam_role_policy" "application_frontend_codepipeline_policy" {
  name   = "${var.perfix}_frontend_codepipeline_policy"
  role   = aws_iam_role.application_frontend_codepipeline_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:StartBuild",
        "codebuild:BatchGetBuilds",
        "s3:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

#前端pipeline
resource "aws_codepipeline" "application_frontend_codepipeline" {
  count    = var.shutdown_saving_cost ==true ?1:0
  name     = "${var.perfix}-frontend-codepipeline"
  role_arn = aws_iam_role.application_frontend_codepipeline_role.arn

  artifact_store {
    location = data.aws_s3_bucket.get_artifacts_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "PlaceholdSource"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        S3Bucket    = data.aws_s3_bucket.get_artifacts_bucket.bucket
        S3ObjectKey = "placeholder.zip"
      }
    }
  }

  stage {
    name = "Approval-Needed"
    action {
      name     = "ManualApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
      configuration = {
        "CustomData" : "Below Action Will Use Codebuild"
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build_Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["Frontend_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.application_frontend_codebuild.name
      }
    }
  }
  tags = {
    Name = "${var.perfix}-frontend-codepipeline"
  }
}