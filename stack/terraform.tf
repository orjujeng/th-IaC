terraform {
  required_version = ">=v1.9.6"
  backend "s3" {
    region         = "ap-northeast-1"
    bucket         = "th-dev-tfstate-orjujeng"
    key            = "stack/th-dev-static-terraform.tfstate"
    dynamodb_table = "th-dev-stack-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region
}