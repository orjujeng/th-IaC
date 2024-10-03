#codedeploy 的iam role
resource "aws_iam_role" "application_codedeploy_role" {
  name               = "${var.perfix}_codedeploy_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_to_codedeploy.json
}

#ecs ecr 共用，暂时只有codedeploy role和ecr的full access
resource "aws_iam_role_policy_attachment" "application_AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.application_codedeploy_role.name
}

resource "aws_iam_role_policy_attachment" "application_AmazonEC2ContainerRegistryFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.application_codedeploy_role.name
}

###ec2 独有 codedeploy分为app 应用程序（针对部署的平台，ec2.ecs.lambda） 下面有group 会让你选择部署方式（autoscaling）
#codedeploy app
resource "aws_codedeploy_app" "applcaiton_codedeploy_ecc_app" {
  count = var.mode == "ecc" ?1:0
  compute_platform = "Server" #ec2
  name             = "${var.perfix}_codedeploy_ecc_app"
}

#codedeploy group 
resource "aws_codedeploy_deployment_group" "applcaiton_codedeploy_ecc_group" {
  count = var.mode == "ecc" ?1:0
  app_name              = aws_codedeploy_app.applcaiton_codedeploy_ecc_app[0].name
  deployment_group_name = "${var.perfix}_codedeploy_ecc_group"
  service_role_arn      = aws_iam_role.application_codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "${var.perfix}-ecc-ec2"
    }
  }
  #部署到哪一个tg
  load_balancer_info {
    target_group_info {
      name = var.ecc_target_group_name
    }
  }
  deployment_config_name      = "CodeDeployDefault.AllAtOnce"
  #tg所对应的ag是什么，我觉得如果使用ag不需要告诉使用哪一个tg
  autoscaling_groups          = [var.ecc_autoscaling_group_id]
  outdated_instances_strategy = "UPDATE"
}