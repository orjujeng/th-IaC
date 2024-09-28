module "tfstate_dynanodb" {
  count         = var.start_service ? 1 : 0
  source        = "./moudle/s3_tfstate"
  dynamedb_name = "${local.perfix}-static-lock"
  perfix        = local.perfix
}

module "vpc" {
  count = var.start_service ? 1 : 0
  source = "./moudle/vpc"
  perfix = local.perfix
  vpc_cidr = "10.1.0.0/16"
  inside_net_cidr1 = "10.1.101.0/24"
  inside_net_cidr2 = "10.1.102.0/24"
  private_net_cidr1 = "10.1.201.0/24"
  private_net_cidr2 = "10.1.202.0/24"
}