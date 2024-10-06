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
  # load_balancer_info {
  #   target_group_info {
  #     name = var.ecc_target_group_name
  #   }
  # }
  deployment_config_name      = "CodeDeployDefault.AllAtOnce"
  #tg所对应的ag是什么，我觉得如果使用ag不需要告诉使用哪一个tg
  autoscaling_groups          = [var.ecc_autoscaling_group_id]
  outdated_instances_strategy = "UPDATE"
}


######ecs 部分############

#新建ecs codedeploy app
resource "aws_codedeploy_app" "applicaiton_codedeploy_ecs_app" {
  count = var.mode == "ecs" ?1:0
  compute_platform = "ECS"
  name             = "${var.perfix}_codedeploy_ecs_app"
}

resource "aws_codedeploy_deployment_group" "applicaiton_codedeploy_ecs_group" {
  count = var.mode == "ecs" && var.shutdown_saving_cost?1:0
  app_name              = aws_codedeploy_app.applicaiton_codedeploy_ecs_app[0].name
  deployment_group_name = "${var.perfix}_codedeploy_ecs_group"
  service_role_arn      = aws_iam_role.aplication_ecs_codedeploy_role.arn
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 2
    }
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL" #由alb support逐步替换老的task
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [var.ecs_alb_listener_arn]
      }
      target_group {
        name = var.ecs_tg_name
      }

      target_group {
        name = var.ecs_tg_b_name
      }
    }
  }
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
}


##ecs code deploy 相关的role 主要是操作ecs和s3中拿文件
resource "aws_iam_role" "aplication_ecs_codedeploy_role" {
  name               = "${var.perfix}_ecs_codedeploy_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_to_codedeploy.json
}

resource "aws_iam_role_policy_attachment" "aplication_attach_AWSCodeDeployRoleForECS" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role       = aws_iam_role.aplication_ecs_codedeploy_role.name
}


resource "aws_iam_role_policy_attachment" "aplication_attach_AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.aplication_ecs_codedeploy_role.name
}