module "tfstate_dynanodb" {
  count = var.start_service ? 1 : 0
  source = "./moudle/s3_tfstate"
  dynamedb_name ="${local.perfix}-stack-lock"
  perfix= local.perfix
}