module "tfstate_dynanodb" {
  count         = var.start_service ? 1 : 0
  source        = "./moudle/s3_tfstate"
  dynamedb_name = "${local.perfix}-stack-lock"
  perfix        = local.perfix
}

module "container" {
  count            = var.start_service ? 1 : 0
  source           = "./moudle/container"
  perfix           = local.perfix
  container_status = var.shutdown_saving_cost        #决定ec2实例开关状态，true为开启
  bastion_status   = var.bastion_status              #决定ec2作为堡垒机开关，true为开启 必须和container_status都为ture才可以
  ssh_key          = var.ssh_key
}

module "alb_as" {
  count  = var.start_service ? 1 : 0
  source = "./moudle/alb_as"
  perfix = local.perfix
  mode   = var.mode                                    #ec2 or ecs选择不同的容器类型
  max_size = 1
  min_size = 0
  expect_size = var.shutdown_saving_cost ? 1 : 0
  shutdown_saving_cost = var.shutdown_saving_cost
  ecs_base_on_ec2_min_size = 0
  ecs_base_on_ec2_max_size = var.shutdown_saving_cost ? 2 : 0
  ecs_base_on_ec2_desired_capacity = var.shutdown_saving_cost ? 2 : 0 #ecs中ec2 数量
  ecs_cluster_name = module.ecs[0].ecs_cluster_name
}

module "backend_codepipeline" {
  count  = var.start_service ? 1 : 0
  source = "./moudle/codepipeline"
  perfix = local.perfix
  mode   = var.mode 
  backend_repo = var.mode == "ecc" ? "https://github.com/orjujeng/th-backend.git" : "https://github.com/orjujeng/th-backend.git"
  backend_ecc_branch = var.mode == "ecc" ? "aws-ec2" : "aws-ecs"
  ecc_target_group_name = null #var.mode == "ecc" ? module.alb_as[0].applcition_load_balance_name: null
  ecc_autoscaling_group_id =  module.alb_as[0].applcition_ec2_autoscaling_id
  shutdown_saving_cost = var.shutdown_saving_cost
  ecs_tg_name = module.alb_as[0].ecs_tg_name
  ecs_tg_b_name = module.alb_as[0].ecs_tg_b_name
  ecs_alb_listener_arn = module.alb_as[0].ecs_alb_listener_arn
  ecs_service_name = module.ecs[0].ecs_service_name
  ecs_cluster_name = module.ecs[0].ecs_cluster_name
  ecr_repo = module.ecs[0].ecr_repository_url
}


module "api_gateway" {
  count  = var.start_service && var.shutdown_saving_cost ? 1 : 0
  source = "./moudle/api_gateway"
  perfix = local.perfix
  applcition_load_balance_dns_name = module.alb_as[0].applcition_load_balance_dns_name
}

module "frondend_codepipeline" {
  count  = var.start_service ? 1 : 0
  source = "./moudle/codepipeline_frontend"
  shutdown_saving_cost = var.shutdown_saving_cost
  perfix = local.perfix
  frontend_repo = "https://github.com/orjujeng/th-frontend.git"
  frontend_branch = "aws"
}

module "ecs" {
  count  = var.start_service ? 1 : 0
  source = "./moudle/ecs"
  perfix = local.perfix
  mode   = var.mode
  ecs_task_desired_num = var.shutdown_saving_cost ? 2 : 0
  ecs_target_group_arn =  module.alb_as[0].ecs_target_group_arn
  application_ecs_base_on_ec2_autoscaling_arn = module.alb_as[0].application_ecs_base_on_ec2_autoscaling_arn
  ecs_task_min_num = 0
  ecs_task_max_num = 2
  shutdown_saving_cost = var.shutdown_saving_cost
  providers = {
    aws.east = aws.us_east_1
  }
}
