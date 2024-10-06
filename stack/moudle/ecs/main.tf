#ecs 的相关配置
#1.新建 ecs cluster 您的所有任务、服务和容量都必须属于一个集群。
resource "aws_ecs_cluster" "application_ecs_cluster" {
  count = var.mode== "ecs" && var.shutdown_saving_cost ? 1 : 0 
  name = "${var.perfix}-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  tags = {
    name = "${var.perfix}-ecs-cluster"
  }
}

#2 新建ecs的容器来源
resource "aws_ecs_capacity_provider" "application_ecs_provider" {
  count = var.mode== "ecs" && var.shutdown_saving_cost ? 1 : 0 
  name = "${var.perfix}_ecs_provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = var.application_ecs_base_on_ec2_autoscaling_arn
    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
    }
  }
}
#3 集群和provider 绑定
resource "aws_ecs_cluster_capacity_providers" "application_ecs_cluster_provider_attach" {
  count = var.mode == "ecs" && var.shutdown_saving_cost ? 1 : 0
  cluster_name = aws_ecs_cluster.application_ecs_cluster[0].name
  capacity_providers = [aws_ecs_capacity_provider.application_ecs_provider[0].name]
}

#4 创建task def
resource "aws_ecs_task_definition" "application_specific_service_task_definition" {
  count = var.mode== "ecs" && var.shutdown_saving_cost ? 1 : 0 
  family                = "${var.perfix}-task-definition"
  execution_role_arn    = aws_iam_role.application_ecs_exec_role.arn
  task_role_arn         = aws_iam_role.application_ecs_task_role.arn
  container_definitions =  templatefile("moudle/ecs/buildspec/${var.perfix}-task-definition.tpl", { name = "${var.perfix}-api",image = "${aws_ecrpublic_repository.applciation_ecr_pubilc_repo.repository_uri}:latest"})//host = 0 容器外部防止端口冲突，自动分配
  network_mode          = "bridge"
  #cpu 在resource中是fragete定义每个task容器大小
}

# 1. execution_role_arn
# 用途: 这个角色用于 ECS 服务在启动和管理任务时所需的权限。
# 功能:
# 它允许 ECS 代理访问其他 AWS 服务，例如：
# 拉取 Docker 镜像（从 Amazon ECR 或其他容器注册表）。
# 发送日志到 CloudWatch Logs。
# 访问 Secrets Manager 或 Parameter Store 中的密钥和参数。
# 适用场景: 在任务启动时，ECS 代理需要这个角色来执行相关操作。
# 2. task_role_arn
# 用途: 这个角色用于 ECS 任务本身在运行时所需的权限。
# 功能:
# 它允许任务中的应用程序访问 AWS 服务，例如：
# 访问 S3 存储桶。
# 读取 DynamoDB 表。
# 发送消息到 SQS 队列。

#exec_role 开启了ssm和sm权限 容器在拉取时可以拿到
resource "aws_iam_role" "application_ecs_exec_role" {
  name               = "${var.perfix}_ecs_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "application_ecs_execution_policy" {
  name   = "${var.perfix}_ecs_execution_policy"
  policy = data.aws_iam_policy_document.application_ecs_execution_policy_doc.json
  role   = aws_iam_role.application_ecs_exec_role.id
}


#task_role 实际上什么都没有
resource "aws_iam_role" "application_ecs_task_role" {
  name               = "${var.perfix}_ecs_task_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

#5 创建ecs service 并与cluster和task_Def绑定
resource "aws_ecs_service" "application_specific_service" {
  count =  var.mode == "ecs" && var.shutdown_saving_cost? 1 : 0 
  name     = "${var.perfix}_api_service"
  iam_role = aws_iam_role.application_ecs_service_role.arn
  cluster  = aws_ecs_cluster.application_ecs_cluster[0].id
  task_definition = aws_ecs_task_definition.application_specific_service_task_definition[0].arn
  desired_count                      = var.ecs_task_desired_num
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }
  load_balancer {
    target_group_arn = var.ecs_target_group_arn
    container_name   = "${var.perfix}-api"
    container_port   = "8080"
  }
  deployment_controller {
    type = "CODE_DEPLOY"
  }
  lifecycle {
    ignore_changes = [task_definition,load_balancer] #当更改了lb ts一些东西 需要注意
  }
}

# ecs service role 主要是获取ec2和elb的信息
resource "aws_iam_role" "application_ecs_service_role" {
  name               = "${var.perfix}_ecs_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "ecs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_AmazonEC2ContainerServiceRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
  role       = aws_iam_role.application_ecs_service_role.name
}

#ecs autoscaling 
resource "aws_appautoscaling_target" "application_ecs_service_as" {
  count =  var.mode == "ecs" && var.shutdown_saving_cost? 1 : 0 
  max_capacity       = var.ecs_task_max_num
  min_capacity       = var.ecs_task_min_num
  resource_id        = "service/${aws_ecs_cluster.application_ecs_cluster[0].name}/${aws_ecs_service.application_specific_service[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

## Policy for CPU tracking
resource "aws_appautoscaling_policy" "application_ecs_cpu_policy" {
  count =  var.mode == "ecs" && var.shutdown_saving_cost? 1 : 0 
  name               = "${var.perfix}_ecs_CPUTarget_tracking_scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.application_ecs_service_as[0].resource_id
  scalable_dimension = aws_appautoscaling_target.application_ecs_service_as[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.application_ecs_service_as[0].service_namespace
  target_tracking_scaling_policy_configuration {
    target_value = 85
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

##ecs总结：
  #1.新建集群 绑定一个provider 这个provider需要绑定一个控制ec2的 autoscaling 
  #2. 新建service 和 taskdef taskdef决定往容器中拉什么镜像，配置是什么
  #3. 当然，alb必须和tg关联， service 必须和tg关联。
  #4. ecs的ag是单独控制，需要resource_id