#assumerole给codebuild服务
data "aws_iam_policy_document" "assume_role_to_codebuild" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#assumerole给codedeploy服务
data "aws_iam_policy_document" "assume_role_to_codedeploy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

#assumerole给 code pipeline 
data "aws_iam_policy_document" "application_codepipeline_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
# code pipeline 额外的policy
data "aws_iam_policy_document" "application_codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:*"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codedeploy:*"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ecs:*"
    ]
    resources = ["*"]
  }

}