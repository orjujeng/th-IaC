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

#获取artifacts s3桶
data "aws_s3_bucket" "get_artifacts_bucket" {
  bucket = "${var.perfix}-codebuild-artifacts-orjujeng"
}