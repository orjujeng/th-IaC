#task exec 的policy
data "aws_iam_policy_document" "application_ecs_execution_policy_doc" {
  statement {
    effect  = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "ssm:GetParameters",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}