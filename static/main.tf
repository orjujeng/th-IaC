module "tfstate_dynanodb" {
  count = var.start_service ? 1 : 0
  source = "./moudle/s3_tfstate"
  dynamedb_name ="${local.perfix}-static-lock"
  perfix= local.perfix
}