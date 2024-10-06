terraform {
  required_version = ">=v1.9.6"
  backend "s3" {
    region         = "ap-northeast-1"
    bucket         = "th-dev-tfstate-orjujeng"
    key            = "static/th-dev-static-terraform.tfstate"
    dynamodb_table = "th-dev-static-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}