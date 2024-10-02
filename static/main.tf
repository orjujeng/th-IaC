module "tfstate_dynanodb" {
  count         = var.start_service ? 1 : 0
  source        = "./moudle/s3_tfstate"
  dynamedb_name = "${local.perfix}-static-lock"
  perfix        = local.perfix
}

module "vpc" {
  count             = var.start_service ? 1 : 0
  source            = "./moudle/vpc"
  perfix            = local.perfix
  vpc_cidr          = "10.1.0.0/16"
  inside_net_cidr1  = "10.1.101.0/24"
  inside_net_cidr2  = "10.1.102.0/24"
  private_net_cidr1 = "10.1.201.0/24"
  private_net_cidr2 = "10.1.202.0/24"
}
module "container_config" {
  count  = var.start_service ? 1 : 0
  source = "./moudle/container_config"
  perfix = local.perfix
  vpc_id = module.vpc[0].vpc_id
}

module "rds" {
  count                 = var.start_service ? 1 : 0
  source                = "./moudle/rds"
  perfix                = local.perfix
  vpc_id                = module.vpc[0].vpc_id
  rds_subnet_ids        = module.vpc[0].private_subnet_id
  rds_availability_zone = data.aws_availability_zones.available.names[0]
  container_sg_id       = module.container_config[0].container_sg_id
}

module "redis" {
  count            = var.start_service ? 1 : 0
  source           = "./moudle/radis"
  cluster_mode     = false
  perfix           = local.perfix
  vpc_id           = module.vpc[0].vpc_id
  container_sg_id  = module.container_config[0].container_sg_id
  redis_subnet_ids = module.vpc[0].private_subnet_id
}

module "route53" {
  count            = var.start_service && var.shutdown_saving_cost ? 1 : 0
  source           = "./moudle/route53"
  domain_name      = var.domain_name
  perfix           = local.perfix
  rds_address      = module.rds[0].rds_address
  redis_address    = [module.redis[0].redis_address]
}