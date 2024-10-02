module "tfstate_dynanodb" {
  count = var.start_service ? 1 : 0
  source = "./moudle/s3_tfstate"
  dynamedb_name ="${local.perfix}-stack-lock"
  perfix= local.perfix
}

module "container" {
  count = var.start_service ? 1 : 0
  source = "./moudle/container"
  perfix= local.perfix
  container_status = var.shutdown_saving_cost #决定ec2实例开关状态，true为开启
}