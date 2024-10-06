#ec2 ecs共用role
resource "aws_iam_role" "application_codepipeline_role" {
  name               = "${var.perfix}_codepipeline_role"
  assume_role_policy = data.aws_iam_policy_document.application_codepipeline_assume_role.json
}

#关联额外policy
resource "aws_iam_role_policy" "application_codepipeline_policy" {
  name   = "${var.perfix}_codepipeline_policy"
  role   = aws_iam_role.application_codepipeline_role.id
  policy = data.aws_iam_policy_document.application_codepipeline_policy.json
}

#codepipline ec2专用pipeline
resource "aws_codepipeline" "application_ec2_backend_codepipeline" {
  count = var.mode =="ecc" && var.shutdown_saving_cost ==true ?1:0
  name     = "${var.perfix}-ec2-backend-codepipeline"
  role_arn = aws_iam_role.application_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.application_artifacts_file.bucket
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
        S3Bucket    = aws_s3_bucket.application_artifacts_file.bucket
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
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["codebuild_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.application_ecc_codebuild[0].name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["codebuild_output"]
      version         = "1"
      configuration = {
        ApplicationName     = aws_codedeploy_app.applcaiton_codedeploy_ecc_app[0].name
        DeploymentGroupName = aws_codedeploy_deployment_group.applcaiton_codedeploy_ecc_group[0].deployment_group_name
      }
    }
  }
  tags = {
    Name = "${var.perfix}-ec2-backend-codepipeline"
  }
}

##ecs pipeline
resource "aws_codepipeline" "application_ecs_codepipeline" {
  count = var.mode =="ecs" && var.shutdown_saving_cost ==true ?1:0
  name     = "${var.perfix}-ecs-codepipeline"
  role_arn = aws_iam_role.application_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.application_artifacts_file.bucket
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
      output_artifacts = ["ecs_source_output"]
      configuration = {
        S3Bucket    = aws_s3_bucket.application_artifacts_file.bucket
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
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["ecs_source_output"]
      output_artifacts = ["ecs_build_output"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.application_codebuild_ecs_compile[0].name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["ecs_build_output"]
      version         = "1"
      configuration = {
        ApplicationName                = aws_codedeploy_app.applicaiton_codedeploy_ecs_app[0].name
        DeploymentGroupName            = aws_codedeploy_deployment_group.applicaiton_codedeploy_ecs_group[0].deployment_group_name
        TaskDefinitionTemplateArtifact = "ecs_build_output"
        AppSpecTemplateArtifact        = "ecs_build_output"
      }
    }
  }
  tags = {
    Name = "${var.perfix}_ecs_codepipeline"
  }
}