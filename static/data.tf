locals {
  perfix = terraform.workspace
}

data "aws_availability_zones" "available" {}