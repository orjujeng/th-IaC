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
}

module "backend_codepipeline" {
  count  = var.start_service ? 1 : 0
  source = "./moudle/codepipeline"
  perfix = local.perfix
  mode   = var.mode 
  backend_repo = var.mode == "ecc" ? "https://github.com/orjujeng/th-backend.git" : null
  backend_ecc_branch = var.mode == "ecc" ? "aws-ec2" : null
  ecc_target_group_name = null #var.mode == "ecc" ? module.alb_as[0].applcition_load_balance_name: null
  ecc_autoscaling_group_id = var.mode == "ecc" ? module.alb_as[0].applcition_ec2_autoscaling_id: null
  shutdown_saving_cost = var.shutdown_saving_cost
}


module "api_gateway" {
  count  = var.start_service && var.shutdown_saving_cost ? 1 : 0
  source = "./moudle/api_gateway"
  perfix = local.perfix
  applcition_load_balance_dns_name = module.alb_as[0].applcition_load_balance_dns_name
}